#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:?prompt file required}"
command -v claude >/dev/null 2>&1 || { echo "claude is not on PATH" >&2; exit 127; }

model_args=()
[ -z "${BOMBAR_CLAUDE_MODEL:-}" ] || model_args=(--model "$BOMBAR_CLAUDE_MODEL")
max_turns="${BOMBAR_MAX_TURNS:-600}"

# Warm-resume: when the runner asks for a resume (BOMBAR_RESUME=1), continue the
# most recent session in this repo instead of starting cold — so a retry keeps the
# codebase context the prior turn already built, and fixes a flake or a small bug
# in minutes rather than rediscovering everything. Adapters that cannot continue a
# session simply ignore BOMBAR_RESUME; the runner's retry prompt is self-contained.
resume_args=()
[ "${BOMBAR_RESUME:-0}" = "1" ] && resume_args=(--continue)

# Permission behavior is deliberately not bypassed here. Configure the Claude
# Code environment according to the repository's own sandbox/permission policy.
exec claude -p "$(cat "$prompt_file")" "${model_args[@]}" --max-turns "$max_turns" "${resume_args[@]}"
