---
description: Show current task-plan status (phases, files, .memory). Not Cursor Plan mode.
---

Show a compact **task-plan** status for the selected board (planning-with-memory / PWF). Not Cursor Plan mode.

## Resolve skill scripts

Prefer the first directory that contains `scripts/resolve-plan-dir.sh` under `planning-with-memory` (then `planning-with-files`). Call the skill root `PWM_SKILL_DIR`.

## Resolve the selected task

Validate `PWF_PLAN_ROOT` / `PM_PLAN_ROOT` when set. Run `resolve-plan-dir.sh` / `.ps1`. Same selection rules as upstream status: selected dir, rejected pin, ambiguity, or legacy root. Do **not** create a plan.

Note whether `.memory/` files exist without dumping full contents.

## What to show

1. Current phase and progress counts
2. Short phase list with status
3. Files: task_plan / findings / progress
4. Memory: CHARTER / KNOWLEDGE / TASK_INDEX / TASK_LOG presence
5. Error table count if present

If no plan: suggest `/task-plan`.
