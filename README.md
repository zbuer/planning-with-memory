**planning-with-memory**

File-based task planning *and* durable project memory for coding agents.

Built on [planning-with-files](https://github.com/OthmanAdi/planning-with-files): the same 3-file plan on disk, plus `.memory/` so knowledge survives across boards.

Keep the live plan in Markdown so work survives `/clear`.  
Keep what the project learned in `.memory/` so the next plan does not start from zero.

**[3-file plan](#the-3-file-pattern)** · **[Project memory](#project-memory)** · **[Install](#quick-install)** · **Memory guide**

![Stars](https://img.shields.io/github/stars/zbuer/planning-with-memory?style=flat&color=yellow)![Latest release](https://img.shields.io/github/v/release/zbuer/planning-with-memory?style=flat&label=release)![Issues](https://img.shields.io/github/issues/zbuer/planning-with-memory?style=flat)![MIT license](https://img.shields.io/github/license/zbuer/planning-with-memory?style=flat)

---

## What this is

**planning-with-memory** is an agent skill that puts two layers on disk in your project:

1. **Task plan:** `task_plan.md`, `findings.md`, `progress.md` for the board you are running now.
2. **Project memory:** `.memory/` (optional charter, append-only knowledge, task index and log) that outlives any one board.

Product skill path: `skills/planning-with-memory/`. Current product version: **0.1.0**. Maintainer notes: [FORK.md](FORK.md).

The 3-file execution model, hooks, attestation, long-running modes, host matrices, release history, and benchmarks come from [planning-with-files](https://github.com/OthmanAdi/planning-with-files) (upstream baseline noted in FORK.md). That shared core is documented in this repo as **[README-PWF.md](README-PWF.md)**. Use that file when you need PWF-depth detail; use this README for the memory product.



## Quick install

```bash
# Agent Skills (skill + templates + scripts)
npx skills add zbuer/planning-with-memory --skill planning-with-memory -g

# Claude Code plugin (slash commands + lifecycle hooks)
# /plugin marketplace add zbuer/planning-with-memory
# /plugin install planning-with-memory@planning-with-memory
```

| Host | Start a board | Charter |
|------|----------------|---------|
| Claude Code | `/plan`, `/pwf`, `/start` | `/charter` |
| Cursor | `/task-plan` | `/charter` |
| Other Agent Skills hosts | Invoke **planning-with-memory** | scripts under the skill |

More routes and host quirks: [docs/installation.md](docs/installation.md). Cursor-specific setup: [docs/cursor.md](docs/cursor.md). Planning-core install matrices (shared with PWF): [README-PWF.md](README-PWF.md#readme-nav-quick-install).



## The 3-file pattern

```
Context Window = RAM (volatile, limited)
Filesystem = Disk (persistent, unlimited)

→ Anything important gets written to disk.
```

```
your-project/
├── task_plan.md   ← phases + checkboxes; resume point after /clear
├── findings.md    ← research and decisions
└── progress.md    ← session log and tests
```

Parallel boards can live under `.planning/YYYY-MM-DD-slug/` with the same three files.

**Why three files?** Context windows reset. In-window todos die with the session. A plan on disk is re-read and re-injected every turn, so the agent resumes at the current phase after `/clear`, compaction, or a crash.

Full Manus-style rationale, recovery story, and long-running modes: [README-PWF.md](README-PWF.md#the-3-file-pattern) and [docs/long-running-agent-tasks.md](docs/long-running-agent-tasks.md).



## Project memory

The three files solve **one task**. They do not solve **the project**.

When a board finishes, the next `/plan` (or Cursor `/task-plan`) starts a new board. Without a separate layer, useful conclusions scatter across old `findings.md` files, get overwritten, or never leave the chat. The agent re-discovers the same constraints, re-tries failed approaches, and forgets why a decision was made.

**planning-with-memory** adds durable project memory under `.memory/` (recommend git-tracking):

```
your-project/
├── .memory/
│   ├── CHARTER.md?      ← optional: purpose, scope, hard constraints
│   ├── KNOWLEDGE.md     ← conclusions / research / decisions / trials (append-only)
│   ├── TASK_INDEX.md    ← short index of finished task-plans
│   └── TASK_LOG.md      ← per finished task-plan summary
├── task_plan.md
├── findings.md
└── progress.md
```

| Layer | Lifetime | Job |
|-------|----------|-----|
| Task plan (3 files) | One board / one slice | Drive phases until complete |
| Project memory | Across boards and sessions | Keep what the project learned |

**What that buys you**

- **Continuity across plans:** next session opens with charter purpose + recent task index, not a blank slate.
- **Capture instead of folklore:** when phases complete, `complete-task-plan.sh` writes INDEX/LOG and can fold findings into `KNOWLEDGE.md`.
- **Cheap injection:** hooks inject a compact digest; full `KNOWLEDGE` / `TASK_LOG` are read on demand.
- **Optional charter:** `/charter` for purpose and hard constraints when the project needs a north star.

One board stays Plan-sized (a multi-step slice, not an epic). Split large work across boards; memory is how those boards share a spine.

Details: [docs/project-memory.md](docs/project-memory.md). File map and env vars: [skills/planning-with-memory/memory-reference.md](skills/planning-with-memory/memory-reference.md).

## How a board runs

1. Invoke `/plan` (Claude) or `/task-plan` (Cursor) and describe the work.
2. `init-session` creates or resumes the three files and runs `ensure-memory.sh`.
3. Work in phases; update findings and progress; hooks re-inject plan context (and a compact memory digest).
4. When all phases are complete, run `complete-task-plan.sh` (Cursor stop may do this once).
5. Start the next board; `.memory/` is still there.

Quick walkthrough: [docs/quickstart.md](docs/quickstart.md).

## Documentation map

| Doc | Contents |
|-----|----------|
| [docs/project-memory.md](docs/project-memory.md) | Why `.memory/`, lifecycle, token policy |
| [docs/quickstart.md](docs/quickstart.md) | Step-by-step first board |
| [docs/installation.md](docs/installation.md) | Install routes for this product |
| [docs/cursor.md](docs/cursor.md) | Cursor hooks and `/task-plan` |
| [FORK.md](FORK.md) | Fork layout and upstream sync |
| **[README-PWF.md](README-PWF.md)** | Full planning-with-files core: hosts, commands, releases, benchmarks, multi-agent, FAQ |

## License

MIT. See [LICENSE](LICENSE).

Planning-core lineage and acknowledgments: [README-PWF.md](README-PWF.md#acknowledgments).
