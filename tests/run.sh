#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT_DIR"

if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,11) else 1)' >/dev/null 2>&1; then
  py="$(command -v python3)"
elif command -v python >/dev/null 2>&1 && python -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,11) else 1)' >/dev/null 2>&1; then
  py="$(command -v python)"
elif command -v py >/dev/null 2>&1; then
  py="$(py -3 -c 'import sys; print(sys.executable)')"
else
  echo "Python 3.11+ not found" >&2; exit 127
fi

echo "== Python core tests =="
"$py" -m unittest discover -s tests -p 'test_*.py' -v
"$py" -m compileall -q scripts/lib tests

echo "== Shell syntax =="
while IFS= read -r script; do bash -n "$script"; done < <(find bin scripts adapters tests -name '*.sh' -type f | sort)

echo "== Full fixture lifecycle =="
fixture="$(mktemp -d)"
cleanup() {
  rc=$?
  if [ "$rc" -ne 0 ] && [ -d "$fixture/project/.bombar/logs" ]; then
    echo "== Fixture failure logs ==" >&2
    find "$fixture/project/.bombar/logs" -type f -maxdepth 1 -print -exec sh -c 'echo "--- $1"; tail -n 120 "$1"' _ {} \; >&2 || true
  fi
  rm -rf "$fixture"
  exit "$rc"
}
trap cleanup EXIT

git config --global user.email >/dev/null 2>&1 || git config --global user.email "bombar-test@example.invalid"
git config --global user.name >/dev/null 2>&1 || git config --global user.name "BOMBAR Test"

bash bin/bombar.sh init "$fixture/project"
if (cd "$fixture/project" && bash .bombar/validate-plan.sh >/dev/null 2>&1); then
  echo "Untouched templates unexpectedly validated" >&2; exit 1
fi
"$py" tests/make_fixture.py "$fixture/project"
cd "$fixture/project"
git add -A
git commit -m "test: approved fixture plan" >/dev/null
bash .bombar/validate-plan.sh
bash .bombar/validate-plan.sh --freeze --approved-by "BOMBAR Test"
git add __development/bombar/APPROVAL.json
git commit -m "test: freeze fixture approval" >/dev/null

cp __development/bombar/00_PRODUCT_BRIEF.md "$fixture/product-brief.backup"
printf '\nchanged after approval\n' >> __development/bombar/00_PRODUCT_BRIEF.md
if "$py" .bombar/lib/bombar.py approval --root "$fixture/project" >/dev/null 2>&1; then
  echo "Approval drift unexpectedly passed" >&2; exit 1
fi
cp "$fixture/product-brief.backup" __development/bombar/00_PRODUCT_BRIEF.md
test -z "$(git status --porcelain)"

git switch -c feature/fixture >/dev/null
BOMBAR_TRACE="${BOMBAR_TRACE:-0}" bash .bombar/run_bombar.sh

test "$(cat result.txt)" = "implemented FIXTURE-01"
test -s __development/bombar/evidence/FIXTURE-01_EVIDENCE.md
test -s .bombar/state/FIXTURE-01.done.json
test -z "$(git status --porcelain)"
bash .bombar/status.sh | grep -q '^done.*FIXTURE-01'

before="$(git rev-parse HEAD)"
bash .bombar/run_bombar.sh
test "$(git rev-parse HEAD)" = "$before"
bash .bombar/prepare-verification.sh
test -s .bombar/context/VERIFIER_SESSION.md

echo "BOMBAR fixture lifecycle: PASS"
