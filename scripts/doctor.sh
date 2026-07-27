#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "$SELF_DIR/lib/common.sh"

fail=0
for command_name in git bash; do
  if command -v "$command_name" >/dev/null 2>&1; then
    bombar_log "PASS command: $command_name"
  else
    bombar_log "FAIL missing command: $command_name"; fail=1
  fi
done

if py="$(bombar_python 2>/dev/null)"; then
  version="$($py -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
  if "$py" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)'; then
    bombar_log "PASS Python $version"
  else
    bombar_log "FAIL Python 3.11+ required; found $version"; fail=1
  fi
else
  bombar_log "FAIL Python 3.11+ not found"; fail=1
fi

if command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1; then
  bombar_log "PASS native SHA utility (Python fallback also available)"
else
  bombar_log "INFO no native SHA utility; BOMBAR will use Python"
fi

[ "$fail" -eq 0 ] || exit 1
bombar_log "BOMBAR host readiness: PASS"
