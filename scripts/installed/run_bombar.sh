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
RUNTIME_DIR=".bombar/runtime"
mkdir -p "$STATE_DIR" "$LOG_DIR" "$CONTEXT_DIR" "$RUNTIME_DIR"
MAIN_LOG="$LOG_DIR/run_bombar.log"
RUN_FILE="$RUNTIME_DIR/run.jsonl"
SESSIONS_FILE="$RUNTIME_DIR/sessions.json"
TELEMETRY=".bombar/lib/telemetry.py"

log() { bombar_log "$*" | tee -a "$MAIN_LOG"; }
die() { log "FATAL: $*"; exit 1; }

# Telemetry is best-effort and never fatal to a run.
tele() { "$py" "$TELEMETRY" event --run "$RUN_FILE" --kind "$1" --data "${2:-{}}" 2>/dev/null || true; }

json_str() { "$py" -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1"; }

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

fmt_hms() {
  local s="$1"
  printf '%02d:%02d:%02d' $((s/3600)) $(((s%3600)/60)) $((s%60))
}

heartbeat_run() {
  local label="$1" logfile="$2" heartbeat="$3"; shift 3
  "$@" >"$logfile" 2>&1 &
  local pid=$! start now last elapsed elapsed_fmt
  start=$(date +%s)
  while kill -0 "$pid" 2>/dev/null; do
    sleep "$heartbeat" || true
    kill -0 "$pid" 2>/dev/null || break
    now=$(date +%s)
    elapsed=$((now-start))
    elapsed_fmt="$(fmt_hms "$elapsed")"
    last="$(tail -n 1 "$logfile" 2>/dev/null | tr -d '\r' | cut -c1-160)"
    if [ -n "$last" ]; then
      log "$label still running — $elapsed_fmt — $last"
    else
      log "$label still running — $elapsed_fmt"
    fi
  done
  wait "$pid"
}

# run_gates <logfile> <stage> [profile_key]  — profile_key defaults to "gates".
run_gates() {
  local logfile="$1" stage="$2" key="${3:-gates}" rc=0 index=0 command
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
  done < <("$py" - "$PROFILE" "$key" <<'PY'
import json, sys
for command in json.load(open(sys.argv[1], encoding="utf-8"))["execution"].get(sys.argv[2]) or []:
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

# write_prompt <index> <attempt> <prior_log> <mode>
#   mode: begin (first obligation of the run) | next (a later obligation, warm) | fix (retry, warm)
write_prompt() {
  local index="$1" attempt="$2" prior_log="${3:-}" mode="${4:-next}"
  local sid title spec_path risk change_mode live_probe prompt_path
  sid="$(spec_field "$index" id)"; title="$(spec_field "$index" title)"; spec_path="$(spec_field "$index" path)"
  risk="$(spec_field "$index" risk)"; change_mode="$(spec_field "$index" change_mode)"; live_probe="$(spec_field "$index" requires_live_probe)"
  prompt_path="$CONTEXT_DIR/${sid}_ATTEMPT_${attempt}.md"
  {
    case "$mode" in
      begin)
        printf '# Begin work on this product — first implementation obligation\n\n'
        printf 'This is the first obligation of the run. Orient yourself from the governed artifacts and `progress.md`, then engineer this obligation as the continuing engineer responsible for the whole product.\n\n---\n\n'
        ;;
      fix)
        printf '# Continue and fix — your prior attempt on this obligation is in the working tree\n\n'
        printf 'You already worked this obligation and the gate then failed. Use the context you retain — do NOT start over or rediscover the codebase. Diagnose the SPECIFIC failure below: it may be flaky/environmental (a timeout under load) rather than a logic bug, in which case re-running or raising a too-tight limit is the right fix, not a rebuild. Fix what is actually wrong, then run the gate yourself to confirm green. Contract and assignment follow for reference.\n\n---\n\n'
        ;;
      *)
        printf '# Next implementation obligation — continuing on this product\n\n'
        printf 'You have been engineering this product across previous obligations; keep your accumulated understanding. This is the next outstanding obligation. Check `progress.md` for anything a continuing engineer should know, then proceed.\n\n---\n\n'
        ;;
    esac
    cat .bombar/prompts/builder.md
    printf '\n\n## Generated assignment\n\n'
    printf -- '- Specification: `%s`\n' "$spec_path"
    printf -- '- Specification ID: `%s`\n' "$sid"
    printf -- '- Title: %s\n' "$title"
    printf -- '- Risk: `%s`\n' "$risk"
    printf -- '- Change mode: `%s`\n' "$change_mode"
    printf -- '- Live probe required for final acceptance: `%s`\n' "$live_probe"
    printf -- '- Evidence file required: `__development/bombar/evidence/%s_EVIDENCE.md`\n' "$sid"
    if [ -n "$prior_log" ] && [ -f "$prior_log" ]; then
      printf '\n## Deterministic gate failure to fix\n\nThe following gate output is what failed. Diagnose the root cause; do not merely silence the checker.\n\n```text\n'
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
    printf '**Why:** The approved obligation did not satisfy the gate after the configured attempts.\n\n'
    printf '**Tried:** See `%s`.\n\n' "$detail_log"
    printf '**Suggested:** Return to an interactive Architecture Partner/owner session if the issue requires a scope, architecture, invariant, acceptance, or authorization change. Otherwise repair the implementation on this branch and rerun.\n'
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
[ "$allow_live" = false ] || die "BOMBAR never permits live actions in unattended Engineering Partner sessions"

"$py" .bombar/lib/bombar.py specs --root "$ROOT_DIR" --require-approval > "$STATE_DIR/specs.json" || die "cannot load approved specifications"
spec_count="$($py -c 'import json; print(len(json.load(open(".bombar/state/specs.json"))))')"

# One Engineering Partner continues across all obligations. Reuse the partner id
# from a prior run of this project if present (cross-run continuity); otherwise
# mint one. A new partner is created only when continuation is impossible — never
# because a spec completed, a subsystem changed, or context grew.
if [ -f "$SESSIONS_FILE" ]; then
  PARTNER_ID="$($py -c 'import json,sys; print(json.load(open(sys.argv[1])).get("partner_id",""))' "$SESSIONS_FILE" 2>/dev/null || echo "")"
else
  PARTNER_ID=""
fi
if [ -n "$PARTNER_ID" ]; then
  session_started=1
  log "Continuing Engineering Partner session $PARTNER_ID (from a prior run)"
else
  PARTNER_ID="$($py -c 'import uuid; print(uuid.uuid4())')"
  session_started=0
  "$py" -c 'import json,sys; open(sys.argv[1],"w").write(json.dumps({"partner_id":sys.argv[2],"runtime":sys.argv[3],"specs":[]},indent=2))' "$SESSIONS_FILE" "$PARTNER_ID" "$adapter_rel" 2>/dev/null || true
  log "Engineering Partner session $PARTNER_ID (new)"
  tele session.created "$(printf '{"session_id":%s,"runtime":%s}' "$(json_str "$PARTNER_ID")" "$(json_str "$adapter_rel")")"
fi

tele run.started "$(printf '{"specs":%d,"adapter":%s,"session_id":%s}' "$spec_count" "$(json_str "$adapter_rel")" "$(json_str "$PARTNER_ID")")"

baseline_log="$LOG_DIR/baseline.gates.log"
project_state="$(profile_value project.state 2>/dev/null || echo unknown)"
done_count="$($py -c 'import json,sys; print(sum(1 for s in json.load(open(sys.argv[1])) if s.get("status")=="done"))' "$STATE_DIR/specs.json" 2>/dev/null || echo -1)"
if [ "$project_state" = greenfield ] && [ "$done_count" -eq 0 ] 2>/dev/null; then
  log "Greenfield first-bootstrap run (no obligations completed yet): skipping the baseline gate check — the toolchain does not exist until the first obligation builds it. Per-obligation gates remain fully enforced."
else
  log "Running baseline gates before the Engineering Partner receives the repository"
  run_gates "$baseline_log" baseline || die "baseline gates are red; fix or deliberately redesign the gate policy interactively"
fi

run_start=$(date +%s)
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
  tele spec.started "$(printf '{"spec_id":%s,"title":%s}' "$(json_str "$sid")" "$(json_str "$title")")"
  slice_start=$(date +%s)
  pre_head="$(git rev-parse HEAD)"
  success=0
  last_log=""
  for ((attempt=0; attempt<=max_retries; attempt++)); do
    attempt_number=$((attempt+1))
    # Continuity: the same Engineering Partner is resumed for every obligation and
    # every retry. Only the very first invocation of the run creates the session.
    if [ "$session_started" -eq 1 ]; then resume_env=1; else resume_env=0; fi
    if [ "$attempt" -gt 0 ]; then mode=fix
    elif [ "$resume_env" -eq 0 ]; then mode=begin
    else mode=next
    fi
    resumed_bool=$([ "$resume_env" -eq 1 ] && echo true || echo false)
    prompt="$(write_prompt "$index" "$attempt_number" "$last_log" "$mode")"
    agent_log="$LOG_DIR/${sid}.attempt-${attempt_number}.agent.log"
    verification_log="$LOG_DIR/${sid}.attempt-${attempt_number}.verification.log"
    if [ "$resume_env" -eq 1 ]; then
      log "$sid attempt $attempt_number/$((max_retries+1)) — resuming Engineering Partner ($mode) via $adapter_rel"
    else
      log "$sid attempt $attempt_number/$((max_retries+1)) — starting Engineering Partner via $adapter_rel"
    fi
    [ "$attempt" -eq 0 ] || tele retry "$(printf '{"spec_id":%s,"attempt":%d}' "$(json_str "$sid")" "$attempt_number")"

    turn_start=$(date +%s)
    BOMBAR_UNATTENDED=1 BOMBAR_SPEC_ID="$sid" BOMBAR_SESSION_ID="$PARTNER_ID" BOMBAR_RESUME="$resume_env" \
      heartbeat_run "$sid agent" "$agent_log" "$heartbeat" "$adapter" "$prompt" || true
    turn_secs=$(( $(date +%s) - turn_start ))
    session_started=1  # from now on we always resume this partner

    native_json="$("$py" "$TELEMETRY" native "$agent_log" 2>/dev/null || echo '{}')"
    [ -n "$native_json" ] || native_json='{}'
    tele agent.turn "$(printf '{"spec_id":%s,"attempt":%d,"mode":%s,"resumed":%s,"duration_s":%d,"native":%s}' \
      "$(json_str "$sid")" "$attempt_number" "$(json_str "$mode")" "$resumed_bool" "$turn_secs" "$native_json")"

    if [ "$(git rev-parse HEAD)" = "$pre_head" ] && [ -z "$(git status --porcelain)" ]; then
      printf 'NO-OP: the agent produced no commit and no working-tree change.\n' > "$verification_log"
      log "$sid NO-OP"
      last_log="$verification_log"
      continue
    fi

    # Scope / protected-path enforcement is intentionally not a hard abort: the
    # Engineering Partner is trusted to touch technically necessary paths. Governed
    # product truth is still protected by the approval digest (checked at preflight
    # and mark-done); an otherwise-green build is never aborted over a touched path.
    printf '# Scope\nEngineering Partner is trusted to touch necessary paths; product truth stays protected by the approval digest.\n' > "$verification_log"

    gate_log="$LOG_DIR/${sid}.attempt-${attempt_number}.gates.log"
    gate_start=$(date +%s)
    if ! run_gates "$gate_log" "$sid"; then
      gate_secs=$(( $(date +%s) - gate_start ))
      tele gate.completed "$(printf '{"spec_id":%s,"stage":"per-obligation","result":"fail","duration_s":%d}' "$(json_str "$sid")" "$gate_secs")"
      cat "$gate_log" >> "$verification_log"
      log "$sid gates FAILED"
      last_log="$verification_log"
      continue
    fi
    gate_secs=$(( $(date +%s) - gate_start ))
    tele gate.completed "$(printf '{"spec_id":%s,"stage":"per-obligation","result":"pass","duration_s":%d}' "$(json_str "$sid")" "$gate_secs")"

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
    slice_secs=$(( $(date +%s) - slice_start ))
    log "DONE $sid in $(fmt_hms "$slice_secs") — $(git log -1 --oneline)"
    tele spec.completed "$(printf '{"spec_id":%s,"duration_s":%d,"commit":%s}' "$(json_str "$sid")" "$slice_secs" "$(json_str "$(git rev-parse --short HEAD)")")"
    "$py" .bombar/lib/bombar.py specs --root "$ROOT_DIR" --require-approval > "$STATE_DIR/specs.json" || die "cannot refresh specification status"
    success=1
    break
  done

  if [ "$success" -ne 1 ]; then
    record_blocker "$sid" "gate remained red after $((max_retries+1)) attempt(s)" "$last_log"
    tele blocker.raised "$(printf '{"spec_id":%s}' "$(json_str "$sid")")"
    log "BLOCKED $sid — work preserved; chain halted"
    tele run.completed "$(printf '{"specs_done":%d,"halted":true}' "$index")"
    "$py" "$TELEMETRY" summary --run "$RUN_FILE" 2>/dev/null | tee -a "$MAIN_LOG" || true
    exit 1
  fi
done

# Optional stronger final tier: integration/E2E/product-level gates, run once after
# the whole chain, when the profile defines execution.final_gates.
if "$py" -c 'import json,sys; sys.exit(0 if (json.load(open(".bombar/project-profile.json"))["execution"].get("final_gates")) else 1)' 2>/dev/null; then
  log "Running final gates (product-level tier)"
  final_log="$LOG_DIR/final.gates.log"
  fg_start=$(date +%s)
  if run_gates "$final_log" final final_gates; then
    tele final_gates.completed "$(printf '{"result":"pass","duration_s":%d}' "$(( $(date +%s) - fg_start ))")"
  else
    tele final_gates.completed "$(printf '{"result":"fail","duration_s":%d}' "$(( $(date +%s) - fg_start ))")"
    log "Final gates FAILED — review $final_log before independent review."
  fi
fi

log "All approved implementation obligations completed — $spec_count in $(fmt_hms $(( $(date +%s) - run_start )))."
tele run.completed "$(printf '{"specs_done":%d,"halted":false}' "$spec_count")"
"$py" "$TELEMETRY" summary --run "$RUN_FILE" 2>/dev/null | tee -a "$MAIN_LOG" || true
log "Next: bash .bombar/prepare-verification.sh   (fresh Independent Engineering Reviewer)"
