#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:?prompt file required}"
command -v codex >/dev/null 2>&1 || { echo "codex is not on PATH" >&2; exit 127; }

# `codex exec` is the non-interactive surface. Review the installed CLI's help
# before first use; BOMBAR does not silently add a sandbox or approval bypass.
exec codex exec - < "$prompt_file"
