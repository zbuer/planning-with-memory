# AGENTS.md, planning-with-memory

For agents doing work in this repository. Code and `scripts/` are discoverable; this file holds decisions that are not.

Layout, sync commands, and host entry points: [FORK.md](FORK.md). User-facing product: [README.md](README.md). Project memory: [docs/project-memory.md](docs/project-memory.md).

## Docs map

| Doc | Role |
|-----|------|
| `README.md` | Product (planning-with-memory) |
| `README-PWF.md` | Verbatim upstream `README.md` (path rename only). On tag sync, replace from upstream `README.md`; do not edit for product copy. |
| `FORK.md` | Fork layout and upstream sync |
| `docs/project-memory.md` | Why `.memory/` and how it fits the 3-file board |
| `skills/planning-with-memory/` | Product skill (scripts under this tree for `/plan` and related commands) |

## Project memory

- Consumer projects use `.memory/`: optional `CHARTER.md`, append-only `KNOWLEDGE.md`, `TASK_INDEX.md`, `TASK_LOG.md` (recommend git-track).
- `ensure-memory.sh` creates knowledge/index/log; `--with-charter` or `/charter` for charter.
- When all phases complete, `complete-task-plan.sh` updates INDEX/LOG and may capture findings into `KNOWLEDGE`. Stop hooks may run complete once; keep soft-fail behaviour.
- Hooks inject a compact digest (charter purpose + recent INDEX). Do not inject full `KNOWLEDGE` or `TASK_LOG` every turn.
- One task-plan ≈ a Plan-sized slice, not an epic. Cross-board facts belong in `.memory/`.
- Details: `skills/planning-with-memory/memory-reference.md`.

## Planning board (execution model)

- Live board: `task_plan.md`, `findings.md`, `progress.md` (or under `.planning/<slug>/`). Orchestrator owns the shared plan; workers use ledgers or assigned files.
- Markdown on disk is shared agent state; no runtime-only plan or memory store.
- When this repo’s own agent workflow uses a user-owned `task_plan.md` / `DESIGN.md`: agents do not rewrite those as their primary return channel; subagent returns go to `progress.md`. Append design/research notes to `findings.md` under `## Design Context` when that workflow applies.

## Upstream sync

- Remotes: `origin` = this repo; `upstream` = OthmanAdi/planning-with-files.
- Merge **release tags** only. After `skills/planning-with-files/` updates, port engine scripts/templates/reference into `skills/planning-with-memory/`, keep memory scripts and patches (`ensure-memory` in `init-session`, digest/complete in `skill-hook`), leave the upstream skill tree `user-invocable: false`.
- Refresh `README-PWF.md` from upstream `README.md` with no product edits.
- Re-check `.cursor/commands/task-plan*` when upstream `commands/plan*` contracts change.

## Authorship and git

- Contributor commits keep the contributor as `Author:`. Prefer rebase/cherry-pick; avoid squash merges that reassign authorship.
- Maintenance commits use Conventional Commits (`fix:`, `feat:`, `docs:`, `release:`, …). Credit people in CHANGELOG / CONTRIBUTORS when those files are used; no invented `Co-Authored-By` for the AI.
- No `--no-verify`. No force-push to the default branch unless the human maintainer explicitly authorises it.

## Releases

Product version is independent of upstream (starts at **0.1.0**). Record upstream baseline in `FORK.md`. Keep `.claude-plugin/plugin.json` (and sibling plugin manifests) aligned with `skills/planning-with-memory/SKILL.md` `metadata.version`.

Follow the human maintainer. Defaults:

1. Reproduce the claim; keep `python -m pytest tests/ -q` green when the suite applies.
2. Ship user-visible behaviour with matching product docs (`README.md`, `docs/project-memory.md`, skill/memory reference).
3. Prefer existing bump/parity scripts when they still match this tree; do not force product version to equal upstream `3.x.y`.
4. If publishing the bundled Pi package under `.pi/skills/planning-with-files/`: run `python scripts/build-npm-readme.py` (source is `README-PWF.md`). `--check` reports staleness. Do not publish to upstream package identities from this repo unless the maintainer says so.
5. Release notes / git tags describe this product (`v0.1.0`, …), not a claim to own upstream PWF releases.

## Public prose

Matter-of-fact. No em-dashes. No filler thanks. Product docs state current behaviour only.
