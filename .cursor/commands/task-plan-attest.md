---
description: Attest or show/clear SHA-256 lock on active task_plan.md. Not Cursor Plan mode.
---

Run the plan attestation helper for the active task-plan.

## Resolve skill scripts

Prefer `planning-with-memory` (then `planning-with-files`) containing `scripts/attest-plan.sh` / `.ps1`.

## Steps

1. Forward the operation: no flag = attest; `--show` / `-Show`; `--clear` / `-Clear`.
2. Let the helper resolve the selected plan. On rejected pin or ambiguity, ask for `PLAN_ID`.
3. Report the helper result and storage path.

After attest, hooks that compare the plan hash block injection if `task_plan.md` changes until re-attested. Re-run `/task-plan-attest` after intentional edits.
