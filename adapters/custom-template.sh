#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:?prompt file required}"

# Replace the next line with the reviewed command for your coding agent.
# The adapter must start a fresh session and must not use continuation state.
echo "Configure this adapter to consume: $prompt_file" >&2
exit 2
