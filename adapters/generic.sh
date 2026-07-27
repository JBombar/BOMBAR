#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:?prompt file required}"

cat >&2 <<'EOF'
The generic BOMBAR adapter is intentionally inert.

Choose and review an explicit adapter in .bombar/project-profile.json, or copy
.bombar/adapters/custom-template.sh and implement its one-operation contract:

  custom-adapter.sh <prompt-file>

It must start ONE FRESH non-interactive coding-agent session, wait for it to
finish, and return the agent process exit code. It must not use conversation
continuation/resume state.
EOF
exit 2
