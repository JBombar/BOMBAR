#!/usr/bin/env bash
set -euo pipefail

CONTROL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(git -C "$CONTROL_DIR" rev-parse --show-toplevel)"
source "$CONTROL_DIR/lib/common.sh"
py="$(bombar_python)"
cd "$ROOT_DIR"
exec "$py" .bombar/lib/bombar.py status --root "$ROOT_DIR" "$@"
