#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:?prompt file required}"
command -v claude >/dev/null 2>&1 || { echo "claude is not on PATH" >&2; exit 127; }

model_args=()
[ -z "${BOMBAR_CLAUDE_MODEL:-}" ] || model_args=(--model "$BOMBAR_CLAUDE_MODEL")
max_turns="${BOMBAR_MAX_TURNS:-300}"

# Permission behavior is deliberately not bypassed here. Configure the Claude
# Code environment according to the repository's own sandbox/permission policy.
exec claude -p "$(cat "$prompt_file")" "${model_args[@]}" --max-turns "$max_turns"
