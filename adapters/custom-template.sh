#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:?prompt file required}"

# Replace the next line with the reviewed command for your coding agent.
# One invocation drives one Engineering Partner turn (see adapters/CONTRACT.md).
# Honor continuity when your runtime can: BOMBAR_SESSION_ID is the stable session
# id and BOMBAR_RESUME=1 means continue that session (warm context); otherwise start
# it. If your runtime cannot continue a session, ignore both and run the prompt
# fresh — the prompt is self-contained. Prefer native structured/JSON output so
# BOMBAR can capture telemetry. Return the agent process exit code.
echo "Configure this adapter to consume: $prompt_file" >&2
exit 2
