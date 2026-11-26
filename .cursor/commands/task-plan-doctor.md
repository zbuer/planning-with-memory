---
description: Self-check task-plan resolution, hooks, attestation. Not Cursor Plan mode.
---

Run the plan doctor against the current project (diagnostic only).

## Resolve skill scripts

Prefer `planning-with-memory` (then `planning-with-files`) containing `scripts/plan-doctor.sh`.

## Steps

1. From the project root: `sh "$PWM_SKILL_DIR/scripts/plan-doctor.sh"`
2. Report PASS/WARN/FAIL lines verbatim.
3. On FAIL, explain remediation (resolver / injection / `PLANNING_DISABLED` / tamper → `/task-plan-attest`).
4. Cursor checks: `.cursor/hooks.json` present and trusted; skill under `.cursor/skills/planning-with-memory` or Agent Skills path.
