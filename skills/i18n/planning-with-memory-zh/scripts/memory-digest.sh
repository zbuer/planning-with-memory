#!/usr/bin/env bash
# Print a compact project-memory digest for hook injection (stdout).
# Ensures .memory knowledge/index/log exist; does not create charter.
# Usage: memory-digest.sh [project_root]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-${PM_PLAN_ROOT:-${PWF_PLAN_ROOT:-${CURSOR_PROJECT_DIR:-$(pwd)}}}}"
cd "$ROOT" 2>/dev/null || true

if [ -f "$SCRIPT_DIR/ensure-memory.sh" ]; then
  sh "$SCRIPT_DIR/ensure-memory.sh" >/dev/null 2>&1 || true
fi

MEM="$ROOT/.memory"
[ -d "$MEM" ] || exit 0

out="[planning-with-memory] Compact memory digest (not full KNOWLEDGE/TASK_LOG)."$'\n'
if [ -f "$MEM/CHARTER.md" ]; then
  PURPOSE="$(awk '/^## (Purpose|目的)/{flag=1; next} /^## /{flag=0} flag && NF{print; exit}' "$MEM/CHARTER.md" 2>/dev/null || true)"
  [ -n "${PURPOSE:-}" ] && out+="Charter purpose: ${PURPOSE}"$'\n'
fi
if [ -f "$MEM/TASK_INDEX.md" ]; then
  rows="$(grep -E '^\|' "$MEM/TASK_INDEX.md" | tail -n 9 || true)"
  if [ -n "$rows" ]; then
    out+=$'\n'"--- TASK_INDEX (recent) ---"$'\n'
    out+="${rows}"$'\n'
  fi
fi
printf '%s' "$out"
