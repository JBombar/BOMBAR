#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:?prompt file required}"

cat >&2 <<'EOF'
The generic BOMBAR adapter is intentionally inert.

Choose and review an explicit adapter in .bombar/project-profile.json (the
claude-code adapter is the reference), or copy .bombar/adapters/custom-template.sh
and implement the runtime contract in .bombar/adapters/CONTRACT.md:

  custom-adapter.sh <prompt-file>

One invocation drives one Engineering Partner turn. The runner supplies
BOMBAR_SESSION_ID (a stable session id) and BOMBAR_RESUME (1 = continue that
session with warm context, else start it). Honor continuity if your runtime can
(resume by id, else continue the most recent session); if it cannot, ignore the
vars and run the self-contained prompt. Emitting native structured output/JSON
lets BOMBAR capture telemetry. Return the agent process exit code.
EOF
exit 2
