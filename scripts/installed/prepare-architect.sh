#!/usr/bin/env bash
set -euo pipefail

CONTROL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(git -C "$CONTROL_DIR" rev-parse --show-toplevel)"
source "$CONTROL_DIR/lib/common.sh"
py="$(bombar_python)"

cd "$ROOT_DIR"
facts="$($py .bombar/lib/bombar.py repository-facts --root "$ROOT_DIR")"
mkdir -p .bombar/context
cp .bombar/prompts/architect.md .bombar/context/ARCHITECT_SESSION.md

bombar_log "Interactive Architect preparation complete."
printf '\nStart a NEW INTERACTIVE agent session and give it this file:\n\n'
printf '  %s/.bombar/context/ARCHITECT_SESSION.md\n\n' "$ROOT_DIR"
printf 'Orientation facts were written to:\n\n  %s/%s\n\n' "$ROOT_DIR" "$facts"
printf '%s\n' 'Do not run a headless Architect. Do not run Builders yet.'
printf '%s\n' 'The Architect must work with the owner until the governed artifacts are correct.'
printf '%s\n' 'After the owner approves them: bash .bombar/validate-plan.sh --freeze --approved-by "Name"'
