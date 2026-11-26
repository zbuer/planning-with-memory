#!/bin/bash
# planning-with-files: Stop hook for Cursor
# Checks if all phases in task_plan.md are complete.
# Returns followup_message to auto-continue if phases are incomplete.
# Always exits 0 — uses JSON stdout for control.

# Issue #195 opt-out. The disabled branch reproduces this hook's own
# no-plan-file behaviour, so the Cursor protocol shape never changes.
[ "${PLANNING_DISABLED:-}" = "1" ] && exit 0

HOOK_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || exit 0
[ -f "${HOOK_DIR}/resolve-plan-context.sh" ] || exit 0
. "${HOOK_DIR}/resolve-plan-context.sh"
cursor_resolve_plan_context "${HOOK_DIR}"
[ -n "${CURSOR_PLAN_DIR}" ] || exit 0
PLAN_FILE="${CURSOR_PLAN_DIR}/task_plan.md"

if [ ! -f "$PLAN_FILE" ]; then
    # No plan file = no planning session, allow stop
    exit 0
fi

# Count total phases
TOTAL=$(grep -c "### Phase" "$PLAN_FILE" || true)

# Check for **Status:** format first
COMPLETE=$(grep -cF "**Status:** complete" "$PLAN_FILE" || true)
IN_PROGRESS=$(grep -cF "**Status:** in_progress" "$PLAN_FILE" || true)
PENDING=$(grep -cF "**Status:** pending" "$PLAN_FILE" || true)

# Fallback: check for [complete] inline format
if [ "$COMPLETE" -eq 0 ] && [ "$IN_PROGRESS" -eq 0 ] && [ "$PENDING" -eq 0 ]; then
    COMPLETE=$(grep -c "\[complete\]" "$PLAN_FILE" || true)
    IN_PROGRESS=$(grep -c "\[in_progress\]" "$PLAN_FILE" || true)
    PENDING=$(grep -c "\[pending\]" "$PLAN_FILE" || true)
fi

# Default to 0 if empty
: "${TOTAL:=0}"
: "${COMPLETE:=0}"
: "${IN_PROGRESS:=0}"
: "${PENDING:=0}"

# issue #191: no "### Phase" headings -> not phase-structured. Avoid the false
# "0/0 phases done ... continue working" auto-continue message.
if [ "$TOTAL" -eq 0 ]; then
    exit 0
fi

if [ "$COMPLETE" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
    # planning-with-memory: auto-complete once (INDEX/LOG + findings capture)
    ROOT="${CURSOR_PROJECT_DIR:-$(pwd)}"
    SKILL=""
    for c in \
      "$ROOT/.cursor/skills/planning-with-memory" \
      "$HOME/.cursor/skills/planning-with-memory" \
      "${HOOK_DIR}/../skills/planning-with-memory"
    do
      if [ -f "$c/scripts/complete-task-plan.sh" ]; then
        SKILL="$c"
        break
      fi
    done
    MARKER="${CURSOR_PLAN_DIR}/.pm_completed"
    if [ -n "$SKILL" ] && [ ! -f "$MARKER" ]; then
      sh "$SKILL/scripts/complete-task-plan.sh" >/tmp/pm-complete-$$.log 2>&1 || true
      TAIL="$(tail -n 6 /tmp/pm-complete-$$.log 2>/dev/null || true)"
      rm -f /tmp/pm-complete-$$.log
      # One followup to ask human to skim auto-written memory (then stop)
      printf '%s\n' "{\"followup_message\": \"[planning-with-memory] All phases complete. Ran complete-task-plan.sh (TASK_INDEX/TASK_LOG + findings→KNOWLEDGE). Briefly verify, then stop unless the user wants more. ${TAIL}\"}"
      exit 0
    fi
    # Already completed/logged — stay silent
    exit 0
else
    # Phases incomplete — auto-continue via followup_message
    echo "{\"followup_message\": \"[planning-with-memory] Task incomplete ($COMPLETE/$TOTAL phases done). Update progress.md, then read task_plan.md and continue the remaining phases. If the user asked to stop, respect that.\"}"
    exit 0
fi
