#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd "$SELF_DIR/.." && pwd -P)"
source "$SELF_DIR/lib/common.sh"

target="${1:-}"
[ -n "$target" ] || bombar_die "usage: bash bin/bombar.sh init <target-repository>"
mkdir -p "$target"
target="$(cd "$target" && pwd -P)"

if [ ! -d "$target/.git" ]; then
  git -C "$target" init -b main >/dev/null
  bombar_log "Initialized Git repository at $target"
fi

preexisting_count="$(find "$target" -type f -not -path "$target/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
initial_state="greenfield"
[ "$preexisting_count" -eq 0 ] || initial_state="legacy_unknown"

if [ -e "$target/.bombar" ] || [ -e "$target/__development/bombar" ]; then
  bombar_die "BOMBAR already appears initialized at $target; refusing to overwrite"
fi

cp -R "$ROOT_DIR/templates/project/." "$target/"
mkdir -p "$target/.bombar/lib" "$target/.bombar/prompts" "$target/.bombar/adapters" "$target/.bombar/schemas"
cp "$ROOT_DIR/scripts/lib/bombar.py" "$target/.bombar/lib/bombar.py"
cp "$ROOT_DIR/scripts/lib/common.sh" "$target/.bombar/lib/common.sh"
cp "$ROOT_DIR/scripts/installed/"*.sh "$target/.bombar/"
cp "$ROOT_DIR/prompts/"*.md "$target/.bombar/prompts/"
cp "$ROOT_DIR/adapters/"*.sh "$target/.bombar/adapters/"
cp "$ROOT_DIR/schemas/"*.json "$target/.bombar/schemas/"

py="$(bombar_python)"
"$py" - "$target/.bombar/project-profile.json" "$target" "$initial_state" <<'PY'
import json, pathlib, sys
profile_path = pathlib.Path(sys.argv[1])
target = pathlib.Path(sys.argv[2])
profile = json.loads(profile_path.read_text(encoding="utf-8"))
profile["project"]["name"] = target.name
profile["project"]["state"] = sys.argv[3]
profile_path.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")
PY

gitignore="$target/.gitignore"
touch "$gitignore"
for line in ".bombar/logs/" ".bombar/state/" ".bombar/context/"; do
  grep -qxF "$line" "$gitignore" 2>/dev/null || printf '%s\n' "$line" >> "$gitignore"
done

chmod +x "$target/.bombar/"*.sh "$target/.bombar/adapters/"*.sh 2>/dev/null || true
bombar_log "BOMBAR installed into $target"
bombar_log "Detected initial project state: $($py -c 'import json,sys; print(json.load(open(sys.argv[1]))["project"]["state"])' "$target/.bombar/project-profile.json")"
bombar_log "Next: cd \"$target\" && bash .bombar/prepare-architect.sh"
