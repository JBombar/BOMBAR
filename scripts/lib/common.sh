#!/usr/bin/env bash
set -euo pipefail

bombar_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
bombar_log() { printf '[%s] %s\n' "$(bombar_ts)" "$*"; }
bombar_die() { bombar_log "FATAL: $*" >&2; exit 1; }

bombar_find_root() {
  local start="${1:-$PWD}"
  git -C "$start" rev-parse --show-toplevel 2>/dev/null || return 1
}

bombar_require_installed() {
  local root="$1"
  [ -f "$root/.bombar/project-profile.json" ] || bombar_die "BOMBAR is not initialized in $root"
  [ -f "$root/.bombar/lib/bombar.py" ] || bombar_die "Missing .bombar/lib/bombar.py in $root"
}

bombar_python() {
  if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)' >/dev/null 2>&1; then
    command -v python3
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)' >/dev/null 2>&1; then
    command -v python
  elif command -v py >/dev/null 2>&1; then
    py -3 -c 'import sys; print(sys.executable); raise SystemExit(0 if sys.version_info >= (3, 11) else 1)' 2>/dev/null
  else return 1
  fi
}

bombar_sha256() {
  local py="$1" path="$2"
  "$py" -c 'import hashlib, pathlib, sys; print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())' "$path"
}
