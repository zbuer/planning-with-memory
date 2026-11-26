# planning-with-memory (fork notes)

Fork of [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) with **project memory** under `.memory/`.

- Product README: [README.md](README.md)
- [README-PWF.md](README-PWF.md): verbatim copy of upstream `README.md` (path rename only; do not edit for product copy). On tag sync, take upstream `README.md` into this file.

## Layout

| Path | Role |
|------|------|
| `skills/planning-with-memory/` | Product skill (English). Users install and invoke this. |
| `skills/i18n/planning-with-memory-zh/` | Simplified Chinese product skill |
| `skills/planning-with-files/` (+ its i18n) | Upstream tree for merging release tags (`user-invocable: false`) |
| `commands/` | Claude Code slash commands (`/plan`, `/charter`, …) |
| `.cursor/commands/` | Cursor slash commands (`/task-plan`, `/charter`, …) |

Runnable scripts for planning live under `skills/planning-with-memory/scripts/` (plugin: `${CLAUDE_PLUGIN_ROOT}/skills/planning-with-memory/scripts/`).

## Memory additions

- `.memory/`: optional charter, append-only knowledge, task index + log
- Scripts: `ensure-memory.sh`, `complete-task-plan.sh`, `init-charter.sh`, `memory-digest.sh`
- Hooks inject a compact memory digest; Stop may run `complete-task-plan.sh` when all phases complete

## Host entry points

| Host | Entry |
|------|--------|
| Cursor | `/task-plan`, `/charter`, `/task-plan-status`, … |
| Claude Code (plugin) | `/plan`, `/pwf`, `/start`, `/charter`, … |
| Claude Code (`npx skills add`) | `skills/planning-with-memory` (no root slash commands) |
| Codex | invoke **planning-with-memory** skill |

## Sync upstream

Remotes: `origin` = this fork; `upstream` = [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files).

Merge upstream **release tags** only (e.g. `v3.29.1`). Do not track `upstream/master` day-to-day.

```bash
git fetch upstream --tags
git tag -l 'v*' | sort -V | tail
git rebase --onto v3.30.0 v3.29.1 master   # example
# or: git merge v3.30.0
```

After a tag updates `skills/planning-with-files/`, copy engine scripts/templates/reference into `skills/planning-with-memory/`, keep memory scripts and patches (`ensure-memory` in `init-session`, digest/complete in `skill-hook`), and leave the upstream tree non-invocable. Re-check `.cursor/commands/task-plan*` when upstream `commands/plan*` contracts change.

Product version: **0.1.0** (plugin / skill metadata). Upstream baseline: **v3.29.1**.
