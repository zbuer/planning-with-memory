---
description: Bridge Cursor /loop to a planning-aware tick on the active task-plan. Not Cursor Plan mode.
---

Bridge the active **task-plan** to Cursor’s built-in **`/loop`** (same idea as Claude Code’s `/plan-loop` → `/loop`).

## Resolve skill scripts

Prefer `planning-with-memory` (then `planning-with-files`) with `check-complete.sh`. Call it `PWM_SKILL_DIR`.

## Steps

1. Parse args: first token matching `^\d+[smhd]$` is the interval (default `10m`); remaining text is an optional custom tick prompt.
2. Resolve the active plan (same as `/task-plan-status`). Refuse if no `task_plan.md`; suggest `/task-plan`.
3. Compose the loop prompt:
   - If the user passed a task prompt: use it.
   - Else default:
     ```
     Read task_plan.md and progress.md. Run scripts/check-complete.sh for remaining phases.
     If no progress.md entry since the last loop tick, write one summarizing current state.
     If a phase finished, update its Status: line in task_plan.md.
     Continue the next phase if work remains.
     ```
4. **Issue Cursor’s `/loop <interval> <prompt>`** with that text (compose with the host primitive). Prefer invoking `/loop` so the host owns scheduling; do not fake a sleep loop unless `/loop` is unavailable in this session.
5. Confirm: interval, plan path / PLAN_ID, and that bare `/loop` without this command uses Cursor’s default maintenance prompt — `/task-plan-loop` always grounds the tick in planning files.

## Notes

- `/task-plan-loop` does **not** replace `/loop`.
- Combine with `/task-plan-goal` for “babysit until plan complete.”
- Prefixed name avoids confusion with Cursor **Plan mode**.
