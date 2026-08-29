#!/usr/bin/env bash
set -euo pipefail

# BOMBAR Claude Code adapter — the reference runtime.
#
# Contract (see adapters/CONTRACT.md): one invocation drives one Engineering
# Partner turn. The runner supplies:
#   $1                 prompt file
#   BOMBAR_SESSION_ID  the Engineering Partner's stable session id (a UUID)
#   BOMBAR_RESUME=1    continue that existing session (warm context); else start it
# Claude Code lets us ASSIGN the id (--session-id) and RESUME it by id (--resume),
# so continuity is deterministic and id-addressed rather than "most recent".
prompt_file="${1:?prompt file required}"
command -v claude >/dev/null 2>&1 || { echo "claude is not on PATH" >&2; exit 127; }

model_args=()
[ -z "${BOMBAR_CLAUDE_MODEL:-}" ] || model_args=(--model "$BOMBAR_CLAUDE_MODEL")
max_turns="${BOMBAR_MAX_TURNS:-600}"

session_args=()
if [ -n "${BOMBAR_SESSION_ID:-}" ]; then
  if [ "${BOMBAR_RESUME:-0}" = "1" ]; then
    session_args=(--resume "$BOMBAR_SESSION_ID")
  else
    session_args=(--session-id "$BOMBAR_SESSION_ID")
  fi
fi

# Native structured telemetry: stream-json emits JSONL events as work happens
# (so the runner's heartbeat still shows liveness) and a final {"type":"result"}
# object carrying session_id, usage, cost, duration, num_turns and status. The
# runner parses that; nothing here parses the internal ~/.claude transcript.
# Permission behavior is deliberately not bypassed — configure the Claude Code
# environment per the repository's own sandbox/permission policy.
exec claude -p "$(cat "$prompt_file")" \
  "${model_args[@]}" \
  --max-turns "$max_turns" \
  --output-format stream-json --verbose \
  "${session_args[@]}"
