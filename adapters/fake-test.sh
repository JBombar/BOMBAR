#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:?prompt file required}"
if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,11) else 1)' >/dev/null 2>&1; then
  py="$(command -v python3)"
elif command -v python >/dev/null 2>&1 && python -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,11) else 1)' >/dev/null 2>&1; then
  py="$(command -v python)"
elif command -v py >/dev/null 2>&1; then
  py="$(py -3 -c 'import sys; print(sys.executable)')"
else
  echo "Python 3.11+ not found" >&2; exit 127
fi
"$py" - "$prompt_file" <<'PY'
import os, pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
match = re.search(r"Specification ID: `([^`]+)`", text)
if not match:
    raise SystemExit("missing specification ID")
sid = match.group(1)
pathlib.Path("result.txt").write_text(f"implemented {sid}\n", encoding="utf-8")
evidence = pathlib.Path("__development/bombar/evidence") / f"{sid}_EVIDENCE.md"
evidence.parent.mkdir(parents=True, exist_ok=True)
evidence.write_text(
    f"# {sid} evidence\n\n"
    "## Gate Results\n\nFixture gate passed.\n\n"
    "## Acceptance Evidence\n\nAC-FIXTURE-1 is demonstrated by result.txt.\n\n"
    "## Changed Files\n\n- result.txt\n\n"
    "## Limitations\n\nHermetic fake adapter; no live provider.\n",
    encoding="utf-8",
)
PY
