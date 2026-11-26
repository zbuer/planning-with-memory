# planning-with-memory reference

## File map (consumer project)

```text
.memory/                 # recommend git-tracking
  CHARTER.md?            # optional charter
  KNOWLEDGE.md           # knowledge (append-only)
  TASK_INDEX.md          # task index (injection / session start)
  TASK_LOG.md            # task detail log
task_plan.md             # current task-plan (or under .planning/<slug>/)
findings.md
progress.md
.planning/
  .active_plan           # optional active slug
  <slug>/                # parallel task-plans
```

## Token policy

- sessionStart / session open: one-line CHARTER purpose + recent TASK_INDEX rows + task_plan head
- Never inject full KNOWLEDGE.md or full TASK_LOG.md
- Read LOG/KNOWLEDGE on demand by anchor or search

## Host support

| | Notes |
|--|------|
| Any Agent Skills host | Load `skills/planning-with-memory` and run scripts |
| Cursor | Optional hooks + `/task-plan` `/charter` (this repo’s `.cursor/`) |
| Other IDEs | No mandatory plugin; loading the skill is enough |

## Env vars

| Variable | Meaning |
|----------|---------|
| `PM_PLAN_ROOT` | Absolute project root for plans/memory |
| `PLAN_ID` | Active slug under `.planning/` |
| `PM_SKILL_DIR` | Override skill install path |

If set, `PWF_PLAN_ROOT` may alias `PM_PLAN_ROOT` (compat with upstream env names). No separate planning skill install is required.
