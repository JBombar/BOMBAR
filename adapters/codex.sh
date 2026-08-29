#!/usr/bin/env bash
set -euo pipefail

# BOMBAR Codex CLI adapter — EXPERIMENTAL / best-effort (see adapters/CONTRACT.md).
#
# Claude Code is the reference runtime. Codex is supported best-effort because its
# non-interactive session/resume surface is newer and version-sensitive, and could
# not be validated on this machine. Before relying on it, confirm on your installed
# `codex` that `codex exec resume --last` continues a prior exec session and that
# `--json` emits `thread.started` / `turn.completed` events.
#
# Contract env the runner supplies: BOMBAR_SESSION_ID (Codex cannot assign it, so
# it is ignored) and BOMBAR_RESUME=1 (continue the most recent exec session).
prompt_file="${1:?prompt file required}"
command -v codex >/dev/null 2>&1 || { echo "codex is not on PATH" >&2; exit 127; }

prompt="$(cat "$prompt_file")"
# Headless policy — overridable; defaults let an unattended run actually edit code.
sandbox="${BOMBAR_CODEX_SANDBOX:-workspace-write}"
approval="${BOMBAR_CODEX_APPROVAL:-never}"
common=(--json --sandbox "$sandbox" --ask-for-approval "$approval")

if [ "${BOMBAR_RESUME:-0}" = "1" ]; then
  # Continue the most recent exec session (id-addressed resume is not assignable in
  # Codex; --last is the closest reliable equivalent for a serial runner).
  exec codex exec resume --last "${common[@]}" "$prompt"
else
  exec codex exec "${common[@]}" "$prompt"
fi
