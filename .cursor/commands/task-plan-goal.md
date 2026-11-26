---
description: Bridge Cursor /goal to the active task-plan until all phases complete. Not Cursor Plan mode.
---

Bridge the active **task-plan** to Cursor’s built-in **`/goal`** (same idea as Claude Code’s `/plan-goal` → `/goal`).

## Resolve skill scripts

Prefer `planning-with-memory` (then `planning-with-files`) with `resolve-plan-dir.sh` and `check-complete.sh`. Call it `PWM_SKILL_DIR`.

## Steps

1. Resolve the selected plan (same rules as `/task-plan-status`). Refuse if no `task_plan.md`; suggest `/task-plan`.
2. Read the selected `task_plan.md` and keep its absolute path.
3. Derive a goal condition:
   - Default: all phases in that task_plan report `Status: complete` and `check-complete.sh` for that path reports all phases complete.
   - If the user passed extra text, AND it into the condition (e.g. `/task-plan-goal until tests pass`).
4. **Issue Cursor’s `/goal <condition>`** with that derived text (compose with the host primitive; do not invent a substitute loop). If the environment exposes a CreateGoal / goal tool instead of slash text, use that with the same condition.
5. Confirm to the user: print the goal condition, plan path / PLAN_ID, and that clearing the goal (host UI / stop-goal) cancels.

## Notes

- `/task-plan-goal` does **not** replace `/goal`; it derives the condition from the file-based plan.
- Pair with `/task-plan-loop` for cadence + termination.
- Name is prefixed so it is not confused with Cursor **Plan mode** (`/plan`).
