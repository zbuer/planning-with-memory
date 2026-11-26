#!/usr/bin/env bash
# Inject selected plan + project-memory digest (Cursor sessionStart).

if [ "${PLANNING_DISABLED:-}" = "1" ]; then
    echo '{}'
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CURSOR_PROJECT_DIR:-$(pwd)}"
cd "$ROOT" 2>/dev/null || true

# Prefer project skill, then user skill
SKILL=""
for c in \
  "$ROOT/.cursor/skills/planning-with-memory" \
  "$HOME/.cursor/skills/planning-with-memory" \
  "$ROOT/.cursor/skills/planning-with-files" \
  "$SCRIPT_DIR/../skills/planning-with-memory"
do
  if [ -f "$c/scripts/ensure-memory.sh" ] || [ -f "$c/scripts/resolve-plan-dir.sh" ]; then
    SKILL="$c"
    break
  fi
done

MEM_CTX=""
if [ -n "$SKILL" ] && [ -f "$SKILL/scripts/memory-digest.sh" ]; then
  MEM_CTX="$(sh "$SKILL/scripts/memory-digest.sh" "$ROOT" 2>/dev/null || true)"
elif [ -n "$SKILL" ] && [ -f "$SKILL/scripts/ensure-memory.sh" ]; then
  sh "$SKILL/scripts/ensure-memory.sh" >/dev/null 2>&1 || true
fi

# Existing PWF plan injection
CONTEXT="$(sh "${SCRIPT_DIR}/user-prompt-submit.sh" 2>/dev/null || true)"
if [ -n "$MEM_CTX" ]; then
  CONTEXT="${MEM_CTX}"$'\n'"${CONTEXT}"
fi

if [ -z "${CONTEXT}" ]; then
  echo '{}'
  exit 0
fi

RESPONSE=""
for PYTHON in "$(command -v python3 2>/dev/null)" "$(command -v python 2>/dev/null)"; do
  [ -n "${PYTHON}" ] || continue
  RESPONSE="$(printf '%s' "${CONTEXT}" | "$PYTHON" -I -X utf8 -c 'import json,sys; print(json.dumps({"additional_context": sys.stdin.buffer.read().decode("utf-8", "replace")}))' 2>/dev/null)" || RESPONSE=""
  [ -n "${RESPONSE}" ] && break
done

if [ -n "${RESPONSE}" ]; then
  printf '%s\n' "${RESPONSE}"
else
  echo '{}'
fi
exit 0
