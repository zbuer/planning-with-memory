---
description: "Create or update project charter (.memory/CHARTER.md). planning-with-memory; optional charter layer."
---

Use **planning-with-memory** for the charter (not a task-plan board).

## Resolve skill scripts

Prefer the first directory that contains `scripts/ensure-memory.sh`:

- `${CLAUDE_PLUGIN_ROOT}/skills/planning-with-memory`
- `$HOME/.claude/skills/planning-with-memory`
- `${CLAUDE_SKILL_DIR}` when it is the planning-with-memory skill
- `${CLAUDE_PLUGIN_ROOT}` if `scripts/ensure-memory.sh` lives there

Call that directory `PWM_SKILL_DIR`. Refuse if none exist.

## Steps

1. From the project root (`PWF_PLAN_ROOT` / `PM_PLAN_ROOT` when set and valid, else cwd), run:
   `sh "$PWM_SKILL_DIR/scripts/ensure-memory.sh" --with-charter`
   (or `init-charter.sh`). This also ensures KNOWLEDGE / TASK_INDEX / TASK_LOG.
2. **New project:** clarify purpose / scope / hard constraints / non-goals with the user, then fill `.memory/CHARTER.md`.
3. **Existing project:** if CHARTER already exists, **do not blank-overwrite**; read the repo and revise sections; record changes in the charter’s change log.
4. Confirm the path and briefly quote the Purpose section.
