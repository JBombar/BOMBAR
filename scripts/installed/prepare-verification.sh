#!/usr/bin/env bash
set -euo pipefail

CONTROL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(git -C "$CONTROL_DIR" rev-parse --show-toplevel)"
source "$CONTROL_DIR/lib/common.sh"
py="$(bombar_python)"
cd "$ROOT_DIR"

"$py" .bombar/lib/bombar.py approval --root "$ROOT_DIR" >/dev/null
specs_json="$($py .bombar/lib/bombar.py specs --root "$ROOT_DIR" --require-approval)"
pending="$($py -c 'import json,sys; print(", ".join(x["id"] for x in json.loads(sys.argv[1]) if x["status"] != "done"))' "$specs_json")"
[ -z "$pending" ] || bombar_die "implementation is incomplete; pending/stale specs: $pending"

mkdir -p .bombar/context
baseline="$($py -c 'import json; print(json.load(open("__development/bombar/APPROVAL.json"))["git_commit_at_approval"])')"
head="$(git rev-parse HEAD)"
{
  cat .bombar/prompts/verifier.md
  printf '\n\n## Generated verification coordinates\n\n'
  printf -- '- Project root: `%s`\n' "$ROOT_DIR"
  printf -- '- Approval baseline: `%s`\n' "$baseline"
  printf -- '- Implementation HEAD: `%s`\n' "$head"
  printf -- '- Governed approval: `__development/bombar/APPROVAL.json`\n'
  printf -- '- Specifications: `__development/bombar/specs/`\n'
  printf -- '- Evidence: `__development/bombar/evidence/`\n'
  printf -- '- Engineering memory: `__development/bombar/progress.md` (a claim to check, not authority)\n'
  printf -- '- Run telemetry: `.bombar/runtime/run.jsonl`\n'
  printf '\nInspect the spine-computed diff with:\n\n```bash\ngit diff --stat %s..%s\ngit diff %s..%s\n```\n' "$baseline" "$head" "$baseline" "$head"
} > .bombar/context/VERIFIER_SESSION.md

bombar_log "Independent verification pack prepared."
printf '\nStart a NEW, INDEPENDENT interactive review session with:\n\n  %s/.bombar/context/VERIFIER_SESSION.md\n\n' "$ROOT_DIR"
printf '%s\n' 'The Independent Engineering Reviewer is a fresh context, not the Engineering Partner. Its question is whether this is coherent, production-quality software. Final semantic/live acceptance remains an owner + Architecture Partner decision.'
