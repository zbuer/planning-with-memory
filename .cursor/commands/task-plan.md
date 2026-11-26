---
description: Start or reset a task-plan (not Cursor Plan mode). planning-with-memory.
---

Use the **planning-with-memory** skill:

1. Run `scripts/ensure-memory.sh` (creates `.memory/` if needed).
2. Run `scripts/init-session.sh` with an optional title; for parallel work use a slug / `--plan-dir` as documented in the skill.
3. If an unfinished root `task_plan.md` exists, ask whether to `complete-task-plan.sh` (and capture knowledge) before `--force` overwrite or a new slug.
4. Fill Goal, Next Step, Phases. Remind: **task-plan ≠ Cursor Plan mode** — do not switch Plan mode unless the user asks.
5. Confirm paths and the next action.
