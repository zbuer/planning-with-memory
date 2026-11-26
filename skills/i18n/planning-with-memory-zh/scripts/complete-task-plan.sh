#!/usr/bin/env bash
# 完工当前 task-plan：写入 TASK_INDEX + TASK_LOG，自动沉淀 findings → KNOWLEDGE。
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

PLAN_DIR="$(sh "$SCRIPT_DIR/resolve-plan-dir.sh" 2>/dev/null || true)"
PLAN_DIR="${PLAN_DIR:-$ROOT}"
PLAN="$PLAN_DIR/task_plan.md"
FINDINGS="$PLAN_DIR/findings.md"
PROGRESS="$PLAN_DIR/progress.md"
MEM="$ROOT/.memory"
DATE="$(date +%Y-%m-%d)"
MARKER="$PLAN_DIR/.pm_completed"
TAG="[planning-with-memory-zh]"

if [[ ! -f "$PLAN" ]]; then
  echo "$TAG no task_plan.md to complete" >&2
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

SUMMARY=""
if [[ -f "$PROGRESS" ]]; then
  SUMMARY="$(awk '
    /^### / { if (block) print block; block=$0; next }
    /^## / && !/^## (Session|会话|會話)/ { if (block) print block; block="" }
    block && NF { block=block "\n" $0 }
    END { if (block) print block }
  ' "$PROGRESS" | tail -n 40 || true)"
fi
if [[ -z "$SUMMARY" ]]; then
  SUMMARY="$(awk '/^## (Decisions Made|已做决策|已做決策)/{flag=1; next} /^## /{flag=0} flag' "$PLAN" | head -n 20 || true)"
fi
SUMMARY="$(echo "$SUMMARY" | sed '/^[[:space:]]*$/d' | head -n 25)"
if [[ -z "$SUMMARY" ]]; then
  SUMMARY="（自动摘要为空：请后补 5–15 行）"
fi

EXAMPLE_RE='_(example — delete when real entries exist)_|_(示例 — 有真实条目后删除)_|_(示例 — 有真實條目後刪除)_'

if grep -qF "| #$ANCHOR |" "$MEM/TASK_INDEX.md" 2>/dev/null; then
  echo "$TAG TASK_INDEX already has #$ANCHOR — skip row"
else
  if grep -qE "$EXAMPLE_RE" "$MEM/TASK_INDEX.md" 2>/dev/null; then
    grep -vE "$EXAMPLE_RE" "$MEM/TASK_INDEX.md" > "$MEM/TASK_INDEX.md.tmp"
    mv "$MEM/TASK_INDEX.md.tmp" "$MEM/TASK_INDEX.md"
  fi
  echo "| $DATE | $STATUS | $TITLE | #$ANCHOR |" >> "$MEM/TASK_INDEX.md"
  echo "$TAG TASK_INDEX += $TITLE"
fi

if grep -qF "{#$ANCHOR}" "$MEM/TASK_LOG.md" 2>/dev/null; then
  echo "$TAG TASK_LOG already has #$ANCHOR — skip log body"
else
  {
    echo ""
    echo "## $DATE — $TITLE {#$ANCHOR}"
    echo ""
    echo "- **状态:** $STATUS"
    echo "- **目标:** ${GOAL:-"（见 task_plan）"}"
    echo "- **摘要:**"
    echo "$SUMMARY" | sed 's/^/  /'
    echo "- **相关沉淀:** 见下方自动沉淀（若有 findings）"
    echo "- **计划路径:** $REL_PLAN"
    echo ""
  } >> "$MEM/TASK_LOG.md"
  echo "$TAG TASK_LOG += #$ANCHOR"
fi

capture_findings() {
  local src="$1"
  [[ -f "$src" ]] || return 0
  local body
  body="$(awk '
    BEGIN { skip=0; in_checklist=0 }
    /^<!--/ { skip=1; next }
    /^-->/ { skip=0; next }
    skip { next }
    /^# (Findings|发现|發現)/ { next }
    /^Scratch pad/ { next }
    /^Important items must/ { next }
    /^## (Capture checklist|沉淀清单|沉澱清單)/ { in_checklist=1; next }
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
  local nonempty
  nonempty="$(printf '%s\n' "$body" | sed '/^[[:space:]]*$/d' | grep -cvE '^## ' || true)"
  if [[ "${nonempty:-0}" -lt 1 ]]; then
    echo "$TAG findings.md empty-ish — no KNOWLEDGE capture"
    return 0
  fi
  local cap_anchor="capture-$ANCHOR"
  if grep -qF "{#$cap_anchor}" "$MEM/KNOWLEDGE.md" 2>/dev/null; then
    echo "$TAG KNOWLEDGE already has #$cap_anchor — skip capture"
    return 0
  fi
  {
    echo ""
    echo "## $DATE — 沉淀自任务规划：$TITLE {#$cap_anchor}"
    echo ""
    echo "- **类型:** 混合（自动从 findings.md 沉淀；请人工甄别）"
    echo "- **上下文:** task-plan「$TITLE」"
    echo "- **内容:**"
    echo ""
    echo "$body"
    echo ""
    echo "- **指针:** $REL_PLAN / findings.md"
    echo ""
  } >> "$MEM/KNOWLEDGE.md"
  echo "$TAG KNOWLEDGE += auto-capture from findings.md"
}

if [[ "$NO_CAPTURE" -eq 0 ]]; then
  capture_findings "$FINDINGS"
else
  echo "$TAG --no-capture: skipped findings → KNOWLEDGE"
fi

{
  echo "date=$DATE"
  echo "title=$TITLE"
  echo "anchor=$ANCHOR"
  echo "status=$STATUS"
} > "$MARKER"
echo "$TAG wrote $MARKER"
echo "$TAG complete-task-plan done."
