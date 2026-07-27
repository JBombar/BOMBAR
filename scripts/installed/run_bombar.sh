#!/usr/bin/env bash
set -uo pipefail
[ "${BOMBAR_TRACE:-0}" != "1" ] || set -x

CONTROL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(git -C "$CONTROL_DIR" rev-parse --show-toplevel 2>/dev/null)" || { echo "Run inside an initialized Git repository." >&2; exit 1; }
source "$CONTROL_DIR/lib/common.sh"
py="$(bombar_python 2>/dev/null)" || bombar_die "Python 3.11+ is required"
cd "$ROOT_DIR"

PROFILE=".bombar/project-profile.json"
STATE_DIR=".bombar/state"
LOG_DIR=".bombar/logs"
CONTEXT_DIR=".bombar/context"
mkdir -p "$STATE_DIR" "$LOG_DIR" "$CONTEXT_DIR"
MAIN_LOG="$LOG_DIR/run_bombar.log"

log() { bombar_log "$*" | tee -a "$MAIN_LOG"; }
die() { log "FATAL: $*"; exit 1; }

profile_value() {
  "$py" - "$PROFILE" "$1" <<'PY'
import json, sys
value = json.load(open(sys.argv[1], encoding="utf-8"))
for part in sys.argv[2].split("."):
    value = value[part]
if isinstance(value, bool):
    print("true" if value else "false")
else:
    print(value)
PY
}

heartbeat_run() {
  local label="$1" logfile="$2" heartbeat="$3"; shift 3
  "$@" >"$logfile" 2>&1 &
  local pid=$! start now last
  start=$(date +%s)
  while kill -0 "$pid" 2>/dev/null; do
    sleep "$heartbeat" || true
    kill -0 "$pid" 2>/dev/null || break
    now=$(date +%s)
    last="$(tail -n 1 "$logfile" 2>/dev/null | tr -d '\r' | cut -c1-160)"
    log "$label still running — $((now-start))s — ${last:-no output yet}"
  done
  wait "$pid"
}

run_gates() {
  local logfile="$1" stage="$2" rc=0 index=0 command
  : > "$logfile"
  while IFS= read -r -d '' command; do
    index=$((index+1))
    (
      printf '\n## Gate %d\n%s\n\n' "$index" "$command"
      bash -lc "$command"
      gate_rc=$?
      printf '\nexit_code=%d\n' "$gate_rc"
      exit "$gate_rc"
    ) >>"$logfile" 2>&1
    if [ $? -eq 0 ]; then log "$stage gate $index PASS — $command"
    else log "$stage gate $index FAIL — $command"; rc=1
    fi
  done < <("$py" - "$PROFILE" <<'PY'
import json, sys
for command in json.load(open(sys.argv[1], encoding="utf-8"))["execution"]["gates"]:
    sys.stdout.buffer.write(command.encode() + b"\0")
PY
)
  return "$rc"
}

spec_field() {
  local index="$1" field="$2"
  "$py" - "$STATE_DIR/specs.json" "$index" "$field" <<'PY'
import json, sys
value = json.load(open(sys.argv[1], encoding="utf-8"))[int(sys.argv[2])][sys.argv[3]]
if isinstance(value, bool): print("true" if value else "false")
elif isinstance(value, list): print(",".join(value))
else: print(value)
PY
}

write_prompt() {
  local index="$1" attempt="$2" prior_log="${3:-}"
  local sid title spec_path risk change_mode live_probe prompt_path
  sid="$(spec_field "$index" id)"; title="$(spec_field "$index" title)"; spec_path="$(spec_field "$index" path)"
  risk="$(spec_field "$index" risk)"; change_mode="$(spec_field "$index" change_mode)"; live_probe="$(spec_field "$index" requires_live_probe)"
  prompt_path="$CONTEXT_DIR/${sid}_ATTEMPT_${attempt}.md"
  {
    cat .bombar/prompts/builder.md
    printf '\n\n## Generated assignment\n\n'
    printf -- '- Specification: `%s`\n' "$spec_path"
    printf -- '- Specification ID: `%s`\n' "$sid"
    printf -- '- Title: %s\n' "$title"
    printf -- '- Risk: `%s`\n' "$risk"
    printf -- '- Change mode: `%s`\n' "$change_mode"
    printf -- '- Live probe required for final acceptance: `%s`\n' "$live_probe"
    printf -- '- Evidence file required: `__development/bombar/evidence/%s_EVIDENCE.md`\n' "$sid"
    printf -- '- Attempt: `%s` (this is a fresh session)\n' "$attempt"
    if [ -n "$prior_log" ] && [ -f "$prior_log" ]; then
      printf '\n## Prior deterministic verification failure\n\nA previous fresh attempt left the following verification output. Diagnose the root cause; do not merely silence the checker.\n\n```text\n'
      tail -n 180 "$prior_log"
      printf '\n```\n'
    fi
  } > "$prompt_path"
  printf '%s\n' "$prompt_path"
}

record_blocker() {
  local sid="$1" reason="$2" detail_log="$3"
  {
    printf '\n## %s — %s blocked by the deterministic runner\n\n' "$(bombar_ts)" "$sid"
    printf '**What:** %s\n\n' "$reason"
    printf '**Why:** The approved slice did not satisfy the runner after bounded fresh attempts.\n\n'
    printf '**Tried:** See `%s`.\n\n' "$detail_log"
    printf '**Suggested:** Return to an interactive Architect/owner session if the issue requires a scope, architecture, invariant, acceptance, or authorization change. Otherwise repair the implementation on this branch and rerun.\n'
  } >> __development/bombar/BLOCKERS.md
}

log "BOMBAR autonomous execution preflight"
"$py" .bombar/lib/bombar.py approval --root "$ROOT_DIR" >/dev/null || die "approval missing or stale"

[ -z "$(git status --porcelain)" ] || die "working tree must be clean before autonomous execution"
default_branch="$(profile_value project.default_branch)"
current_branch="$(git branch --show-current)"
require_branch="$(profile_value execution.require_non_default_branch)"
if [ "$require_branch" = true ] && [ "$current_branch" = "$default_branch" ]; then
  die "refusing to implement on default branch '$default_branch'; create a dedicated implementation branch"
fi

adapter_rel="$(profile_value execution.agent_adapter)"
adapter="$ROOT_DIR/$adapter_rel"
[ -x "$adapter" ] || die "agent adapter is not executable: $adapter_rel"
heartbeat="$(profile_value execution.heartbeat_seconds)"
max_retries="$(profile_value execution.max_retries)"
auto_commit="$(profile_value execution.auto_commit)"
allow_live="$(profile_value execution.allow_live_actions_unattended)"
[ "$allow_live" = false ] || die "BOMBAR v0.1 never permits live actions in unattended Builder sessions"

"$py" .bombar/lib/bombar.py specs --root "$ROOT_DIR" --require-approval > "$STATE_DIR/specs.json" || die "cannot load approved specifications"
spec_count="$($py -c 'import json; print(len(json.load(open(".bombar/state/specs.json"))))')"

log "Running baseline gates before any Builder receives the repository"
baseline_log="$LOG_DIR/baseline.gates.log"
run_gates "$baseline_log" baseline || die "baseline gates are red; fix or deliberately redesign the gate policy interactively"

for ((index=0; index<spec_count; index++)); do
  sid="$(spec_field "$index" id)"
  title="$(spec_field "$index" title)"
  status="$(spec_field "$index" status)"
  deps="$(spec_field "$index" depends_on)"
  if [ "$status" = done ]; then log "SKIP $sid — already done"; continue; fi
  [ "$status" != stale ] || die "$sid completion marker is stale because the approved spec changed"

  if [ -n "$deps" ]; then
    IFS=',' read -r -a dep_array <<< "$deps"
    for dep in "${dep_array[@]}"; do
      dep_status="$($py - "$STATE_DIR/specs.json" "$dep" <<'PY'
import json, sys
for item in json.load(open(sys.argv[1], encoding="utf-8")):
    if item["id"] == sys.argv[2]: print(item["status"]); break
PY
)"
      [ "$dep_status" = done ] || die "$sid depends on incomplete $dep"
    done
  fi

  log "START $sid — $title"
  pre_head="$(git rev-parse HEAD)"
  success=0
  last_log=""
  for ((attempt=0; attempt<=max_retries; attempt++)); do
    attempt_number=$((attempt+1))
    prompt="$(write_prompt "$index" "$attempt_number" "$last_log")"
    agent_log="$LOG_DIR/${sid}.attempt-${attempt_number}.agent.log"
    verification_log="$LOG_DIR/${sid}.attempt-${attempt_number}.verification.log"
    log "$sid attempt $attempt_number/$((max_retries+1)) — fresh agent via $adapter_rel"
    BOMBAR_UNATTENDED=1 BOMBAR_SPEC_ID="$sid" heartbeat_run "$sid agent" "$agent_log" "$heartbeat" "$adapter" "$prompt" || true

    if [ "$(git rev-parse HEAD)" = "$pre_head" ] && [ -z "$(git status --porcelain)" ]; then
      printf 'NO-OP: the agent produced no commit and no working-tree change.\n' > "$verification_log"
      log "$sid NO-OP"
      last_log="$verification_log"
      continue
    fi

    (
      echo "# Scope verification"
      "$py" .bombar/lib/bombar.py check-scope "$sid" "$pre_head" --root "$ROOT_DIR"
      scope_rc=$?
      echo "scope_exit_code=$scope_rc"
      exit "$scope_rc"
    ) > "$verification_log" 2>&1
    if [ $? -ne 0 ]; then log "$sid scope/protected-path check FAILED"; last_log="$verification_log"; continue; fi

    gate_log="$LOG_DIR/${sid}.attempt-${attempt_number}.gates.log"
    if ! run_gates "$gate_log" "$sid"; then
      cat "$gate_log" >> "$verification_log"
      log "$sid gates FAILED"
      last_log="$verification_log"
      continue
    fi

    evidence="__development/bombar/evidence/${sid}_EVIDENCE.md"
    if [ ! -s "$evidence" ]; then
      printf '\nMISSING EVIDENCE: %s\n' "$evidence" >> "$verification_log"
      log "$sid evidence FAILED"
      last_log="$verification_log"
      continue
    fi

    if [ "$auto_commit" = true ] && [ -n "$(git status --porcelain)" ]; then
      git add -A
      git commit -m "BOMBAR $sid: $title" >> "$verification_log" 2>&1 || {
        log "$sid commit FAILED"; last_log="$verification_log"; continue;
      }
    fi
    [ "$(git rev-parse HEAD)" != "$pre_head" ] || {
      printf '\nNO GREEN COMMIT: HEAD is unchanged.\n' >> "$verification_log"
      log "$sid commit requirement FAILED"; last_log="$verification_log"; continue;
    }
    [ -z "$(git status --porcelain)" ] || {
      printf '\nDIRTY AFTER COMMIT\n' >> "$verification_log"
      log "$sid tree is dirty after commit"; last_log="$verification_log"; continue;
    }

    "$py" .bombar/lib/bombar.py mark-done "$sid" --root "$ROOT_DIR" >> "$verification_log" 2>&1 || {
      log "$sid evidence schema FAILED"; last_log="$verification_log"; continue;
    }
    log "DONE $sid — $(git log -1 --oneline)"
    "$py" .bombar/lib/bombar.py specs --root "$ROOT_DIR" --require-approval > "$STATE_DIR/specs.json" || die "cannot refresh specification status"
    success=1
    break
  done

  if [ "$success" -ne 1 ]; then
    record_blocker "$sid" "verification remained red after $((max_retries+1)) fresh attempt(s)" "$last_log"
    log "BLOCKED $sid — work preserved; chain halted"
    exit 1
  fi
done

log "All approved implementation specifications completed."
log "Next: bash .bombar/prepare-verification.sh"
