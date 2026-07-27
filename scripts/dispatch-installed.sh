#!/usr/bin/env bash
set -euo pipefail

script_name="${1:?installed script name required}"
shift

target="$PWD"
if [ "${1:-}" != "" ] && [ -d "${1:-}" ]; then
  target="$(cd "$1" && pwd -P)"
  shift
fi

installed="$target/.bombar/$script_name"
[ -f "$installed" ] || {
  echo "BOMBAR is not initialized at $target (missing .bombar/$script_name)." >&2
  echo "Run: bash bin/bombar.sh init $target" >&2
  exit 1
}
cd "$target"
exec bash "$installed" "$@"
