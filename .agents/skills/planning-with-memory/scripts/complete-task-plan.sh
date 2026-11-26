#!/usr/bin/env bash
# Complete current task-plan: write TASK_INDEX + TASK_LOG, auto-capture findings → KNOWLEDGE.
# Usage: complete-task-plan.sh [--status complete|cancelled|partial] [--title "..."] [--no-capture]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${PM_PLAN_ROOT:-${PWF_PLAN_ROOT:-$(pwd)}}"
"$SCRIPT_DIR/ensure-memory.sh"

STATUS="complete"
TITLE=""
NO_CAPTURE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --status)
      STATUS="${2:-complete}"
      shift 2
      ;;
    --title)
      TITLE="${2:-}"
      shift 2
      ;;
    --no-capture)
      NO_CAPTURE=1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# PWF resolve-plan-dir may print empty → legacy project root
PLAN_DIR="$(sh "$SCRIPT_DIR/resolve-plan-dir.sh" 2>/dev/null || true)"
PLAN_DIR="${PLAN_DIR:-$ROOT}"
PLAN="$PLAN_DIR/task_plan.md"
FINDINGS="$PLAN_DIR/findings.md"
PROGRESS="$PLAN_DIR/progress.md"
MEM="$ROOT/.memory"
DATE="$(date +%Y-%m-%d)"
MARKER="$PLAN_DIR/.pm_completed"

if [[ ! -f "$PLAN" ]]; then
  echo "[planning-with-memory] no task_plan.md to complete" >&2
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  TITLE="$(grep -E '^# (Task Plan:|任务计划：|任務計畫：)' "$PLAN" | head -1 \
    | sed -E 's/^# (Task Plan:|任务计划：|任務計畫：)[[:space:]]*//' || true)"
  [[ -z "$TITLE" ]] && TITLE="$(basename "$PLAN_DIR")"
fi

ANCHOR="$(echo "$DATE-$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
# CJK / non-latin titles often strip to date-only; keep a stable suffix
if [[ "$ANCHOR" == "$DATE" ]]; then
  SUFFIX="$(printf '%s' "$TITLE" | cksum | awk '{print $1}')"
  ANCHOR="${DATE}-${SUFFIX}"
fi
ANCHOR="$(echo "$ANCHOR" | cut -c1-60)"

GOAL="$(awk '/^## (Goal|目标|目標)/{flag=1; next} /^## /{flag=0} flag && NF{print; exit}' "$PLAN" || true)"
GOAL="$(echo "$GOAL" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

REL_PLAN="${PLAN#"$ROOT"/}"

# --- summary from progress / decisions (best-effort) ---
SUMMARY=""
if [[ -f "$PROGRESS" ]]; then
  SUMMARY="$(awk '
    /^### / { if (block) print block; block=$0; next }
    /^## / && !/^## Session/ { if (block) print block; block="" }
    block && NF { block=block "\n" $0 }
    END { if (block) print block }
  ' "$PROGRESS" | tail -n 40 || true)"
fi
if [[ -z "$SUMMARY" ]]; then
  SUMMARY="$(awk '/^## Decisions Made/{flag=1; next} /^## /{flag=0} flag' "$PLAN" | head -n 20 || true)"
fi
SUMMARY="$(echo "$SUMMARY" | sed '/^[[:space:]]*$/d' | head -n 25)"
if [[ -z "$SUMMARY" ]]; then
  SUMMARY="(auto summary empty — please add 5–15 lines)"
fi

# --- INDEX (idempotent: same log anchor) ---
if grep -qF "| #$ANCHOR |" "$MEM/TASK_INDEX.md" 2>/dev/null; then
  echo "[planning-with-memory] TASK_INDEX already has #$ANCHOR — skip row"
else
  if grep -q '_(example — delete when real entries exist)_' "$MEM/TASK_INDEX.md" 2>/dev/null; then
    grep -v '_(example — delete when real entries exist)_' "$MEM/TASK_INDEX.md" > "$MEM/TASK_INDEX.md.tmp"
    mv "$MEM/TASK_INDEX.md.tmp" "$MEM/TASK_INDEX.md"
  fi
  echo "| $DATE | $STATUS | $TITLE | #$ANCHOR |" >> "$MEM/TASK_INDEX.md"
  echo "[planning-with-memory] TASK_INDEX += $TITLE"
fi

# --- LOG (idempotent on anchor) ---
if grep -qF "{#$ANCHOR}" "$MEM/TASK_LOG.md" 2>/dev/null; then
  echo "[planning-with-memory] TASK_LOG already has #$ANCHOR — skip log body"
else
  {
    echo ""
    echo "## $DATE — $TITLE {#$ANCHOR}"
    echo ""
    echo "- **Status:** $STATUS"
    echo "- **Goal:** ${GOAL:-"(see task_plan)"}"
    echo "- **Summary:**"
    echo "$SUMMARY" | sed 's/^/  /'
    echo "- **Knowledge:** see auto-capture below (if findings had content)"
    echo "- **Plan path:** $REL_PLAN"
    echo ""
  } >> "$MEM/TASK_LOG.md"
  echo "[planning-with-memory] TASK_LOG += #$ANCHOR"
fi

# --- auto-capture findings → KNOWLEDGE ---
capture_findings() {
  local src="$1"
  [[ -f "$src" ]] || return 0
  # Strip template scaffolding; keep substance
  local body
  body="$(awk '
    BEGIN { skip=0; in_checklist=0 }
    /^<!--/ { skip=1; next }
    /^-->/ { skip=0; next }
    skip { next }
    /^# Findings/ { next }
    /^Scratch pad/ { next }
    /^Important items must/ { next }
    /^## Capture checklist/ { in_checklist=1; next }
    /^## / { in_checklist=0 }
    in_checklist { next }
    {
      line=$0
      if (line ~ /^-[[:space:]]*-?[[:space:]]*$/) next
      if (line ~ /^\|[[:space:]]*\|[[:space:]]*\|[[:space:]]*\|[[:space:]]*$/) next
      if (line ~ /^\|[[:space:]]*-+/) next
      if (line ~ /^\|[[:space:]]*Attempt/) next
      if (line ~ /^What happened/) next
      print
    }
  ' "$src")"
  # Count lines that look like substance (not bare ## headings)
  local nonempty
  nonempty="$(printf '%s\n' "$body" | sed '/^[[:space:]]*$/d' | grep -cvE '^## ' || true)"
  if [[ "${nonempty:-0}" -lt 1 ]]; then
    echo "[planning-with-memory] findings.md empty-ish — no KNOWLEDGE capture"
    return 0
  fi
  local cap_anchor="capture-$ANCHOR"
  if grep -qF "{#$cap_anchor}" "$MEM/KNOWLEDGE.md" 2>/dev/null; then
    echo "[planning-with-memory] KNOWLEDGE already has #$cap_anchor — skip capture"
    return 0
  fi
  {
    echo ""
    echo "## $DATE — Captured from task-plan: $TITLE {#$cap_anchor}"
    echo ""
    echo "- **Type:** mixed (auto-captured from findings.md; please curate)"
    echo "- **Context:** task-plan \"$TITLE\""
    echo "- **Content:**"
    echo ""
    echo "$body"
    echo ""
    echo "- **Pointers:** $REL_PLAN / findings.md"
    echo ""
  } >> "$MEM/KNOWLEDGE.md"
  echo "[planning-with-memory] KNOWLEDGE += auto-capture from findings.md"
}

if [[ "$NO_CAPTURE" -eq 0 ]]; then
  capture_findings "$FINDINGS"
else
  echo "[planning-with-memory] --no-capture: skipped findings → KNOWLEDGE"
fi

# marker so stop hook won't re-run forever
{
  echo "date=$DATE"
  echo "title=$TITLE"
  echo "anchor=$ANCHOR"
  echo "status=$STATUS"
} > "$MARKER"
echo "[planning-with-memory] wrote $MARKER"
echo "[planning-with-memory] complete-task-plan done."
