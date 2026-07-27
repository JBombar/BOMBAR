#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd "$SELF_DIR/.." && pwd -P)"

usage() {
  cat <<'EOF'
BOMBAR — Bounded Orchestration Method for Building with Agents, Reliably

Usage:
  bash bin/bombar.sh doctor
  bash bin/bombar.sh init <target-repository>
  bash bin/bombar.sh prepare-architect [target-repository]
  bash bin/bombar.sh validate-plan [target-repository] [--freeze --approved-by NAME]
  bash bin/bombar.sh run [target-repository]
  bash bin/bombar.sh prepare-verification [target-repository]
  bash bin/bombar.sh status [target-repository]

`prepare-architect` prepares an interactive-session prompt. It never starts a
headless architecture session. Autonomous execution begins only after `validate-plan
--freeze` records the owner's approval over exact artifact digests.
EOF
}

cmd="${1:-}"
[ -n "$cmd" ] || { usage; exit 2; }
shift || true

case "$cmd" in
  doctor) exec bash "$ROOT_DIR/scripts/doctor.sh" "$@" ;;
  init) exec bash "$ROOT_DIR/scripts/init.sh" "$@" ;;
  prepare-architect) exec bash "$ROOT_DIR/scripts/dispatch-installed.sh" prepare-architect.sh "$@" ;;
  validate-plan) exec bash "$ROOT_DIR/scripts/dispatch-installed.sh" validate-plan.sh "$@" ;;
  run) exec bash "$ROOT_DIR/scripts/dispatch-installed.sh" run_bombar.sh "$@" ;;
  prepare-verification) exec bash "$ROOT_DIR/scripts/dispatch-installed.sh" prepare-verification.sh "$@" ;;
  status) exec bash "$ROOT_DIR/scripts/dispatch-installed.sh" status.sh "$@" ;;
  help|-h|--help) usage ;;
  *) echo "Unknown command: $cmd" >&2; usage >&2; exit 2 ;;
esac
