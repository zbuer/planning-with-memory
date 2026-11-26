# Project memory

planning-with-memory keeps two layers on disk: a **task plan** for the work in progress, and **project memory** for what should outlive that plan.

## The gap the three files leave open

`task_plan.md`, `findings.md`, and `progress.md` are working memory for **one board**. They answer: where am I in this slice, what did I find, what did I try.

They are a poor fit for **project-level** facts:

- A finished board is replaced or archived; the next board does not automatically inherit its conclusions.
- Important decisions live in chat or in a `findings.md` that nobody opens again.
- Hard constraints (“never touch X”, “API must stay Y”) get rediscovered every few sessions.

Project memory is the durable layer for that class of knowledge.

## What `.memory/` holds

```text
.memory/
  CHARTER.md?       # optional: purpose, scope, hard constraints
  KNOWLEDGE.md      # conclusions / research / decisions / trials (append-only)
  TASK_INDEX.md     # short index of finished task-plans
  TASK_LOG.md       # per finished task-plan summary
```

| File | Role |
|------|------|
| `CHARTER.md` | North star when the project needs one. Created with `/charter` or `ensure-memory.sh --with-charter`. |
| `KNOWLEDGE.md` | Append-only store of lasting conclusions. Prefer capture at board completion over rewriting history. |
| `TASK_INDEX.md` | Compact list of finished boards; good for session start. |
| `TASK_LOG.md` | Longer per-board summary when you need detail. |

Recommend git-tracking `.memory/` so the team shares the same spine.

## How it fits the plan

```text
charter?  →  task-plan (phases)  →  complete  →  INDEX / LOG / capture into KNOWLEDGE
                ↑__________________________________________|
                         next board still sees .memory/
```

1. **Start:** `ensure-memory.sh` (Claude `/plan` and Cursor `/task-plan` paths run this via the product skill’s `init-session`). Optional `/charter` for a new project.
2. **Work:** same 3-file workflow as the planning core: phases, findings, progress, hooks.
3. **Finish:** when all phases are complete, run `complete-task-plan.sh` (Cursor stop may do this once). That updates INDEX/LOG and can capture findings into `KNOWLEDGE.md`.
4. **Next board:** hooks inject a compact digest (charter purpose + recent INDEX rows), not the full knowledge file.

## Token policy

- Session open / hooks: one-line charter purpose + recent `TASK_INDEX` rows + plan head.
- Do not inject full `KNOWLEDGE.md` or full `TASK_LOG.md` every turn.
- Read LOG / KNOWLEDGE on demand by search or anchor.

## Scale

One task-plan ≈ a small multi-step slice (Plan-mode sized), not an epic. Split large work across multiple boards; use human gates inside phases when needed. Memory is how those boards share durable context.

## Further reading

- Skill: [`skills/planning-with-memory/SKILL.md`](../skills/planning-with-memory/SKILL.md)
- File map and env vars: [`skills/planning-with-memory/memory-reference.md`](../skills/planning-with-memory/memory-reference.md)
- Quick start: [quickstart.md](quickstart.md)
