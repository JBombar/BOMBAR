#!/usr/bin/env python3
"""Deterministic control plane for BOMBAR.

The Python module validates and freezes human-authored artifacts. It never asks an
LLM to decide whether a plan or implementation is approved.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import pathlib
import re
import subprocess
import sys
from collections import Counter, deque
from typing import Any


SCHEMA_VERSION = "0.1"
CONTROL_DIR = pathlib.Path(".bombar")
DEV_DIR = pathlib.Path("__development/bombar")
APPROVAL_PATH = DEV_DIR / "APPROVAL.json"
REQUIRED_ARTIFACTS = (
    pathlib.Path("BOMBAR.md"),
    CONTROL_DIR / "project-profile.json",
    DEV_DIR / "00_PRODUCT_BRIEF.md",
    DEV_DIR / "01_REPOSITORY_ASSESSMENT.md",
    DEV_DIR / "02_ARCHITECTURE.md",
    DEV_DIR / "03_INVARIANTS.md",
    DEV_DIR / "04_ACCEPTANCE_CONTRACT.md",
    DEV_DIR / "05_IMPLEMENTATION_PLAN.md",
    DEV_DIR / "specs/README.md",
)
# A specification states the next product obligation: what must become true, how we
# know (acceptance), and how it is meaningfully verified. It deliberately does NOT
# declare which implementation files the Engineering Partner may touch — engineering
# agency inside approved product truth is not pre-authorized file-by-file.
REQUIRED_SPEC_SECTIONS = (
    "outcome",
    "acceptance criteria",
    "verification",
)
REQUIRED_META = (
    "id",
    "title",
    "depends_on",
    "risk",
    "change_mode",
    "requires_live_probe",
)
PLACEHOLDER_PATTERNS = (
    re.compile(r"\bTODO\b", re.IGNORECASE),
    re.compile(r"\bTBD\b", re.IGNORECASE),
    re.compile(r"<replace[-_ ]me>", re.IGNORECASE),
    re.compile(r"\breplace-me\b", re.IGNORECASE),
    re.compile(r"BOMBAR_CONFIGURE", re.IGNORECASE),
    re.compile(r"\[describe .+?\]", re.IGNORECASE),
)


class BombarError(RuntimeError):
    pass


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path: pathlib.Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise BombarError(f"missing file: {path.as_posix()}") from exc
    except json.JSONDecodeError as exc:
        raise BombarError(f"invalid JSON in {path.as_posix()}: {exc}") from exc
    if not isinstance(value, dict):
        raise BombarError(f"expected a JSON object in {path.as_posix()}")
    return value


def write_json(path: pathlib.Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def run_git(root: pathlib.Path, *args: str, check: bool = True) -> str:
    proc = subprocess.run(
        ["git", "-C", str(root), *args],
        check=False,
        text=True,
        capture_output=True,
        encoding="utf-8",
        errors="replace",
    )
    if check and proc.returncode != 0:
        raise BombarError(proc.stderr.strip() or f"git {' '.join(args)} failed")
    return proc.stdout.strip()


def project_root(start: str | None = None) -> pathlib.Path:
    here = pathlib.Path(start or os.getcwd()).resolve()
    proc = subprocess.run(
        ["git", "-C", str(here), "rev-parse", "--show-toplevel"],
        check=False,
        text=True,
        capture_output=True,
        encoding="utf-8",
    )
    if proc.returncode != 0:
        raise BombarError(f"not inside a Git repository: {here}")
    return pathlib.Path(proc.stdout.strip()).resolve()


def load_profile(root: pathlib.Path) -> dict[str, Any]:
    profile = read_json(root / CONTROL_DIR / "project-profile.json")
    errors: list[str] = []
    if profile.get("schema_version") != SCHEMA_VERSION:
        errors.append(f"schema_version must be {SCHEMA_VERSION!r}")
    project = profile.get("project")
    if not isinstance(project, dict):
        errors.append("project must be an object")
    elif project.get("state") not in {"greenfield", "incubating", "live_brownfield", "legacy_unknown"}:
        errors.append("project.state must be greenfield, incubating, live_brownfield, or legacy_unknown")
    execution = profile.get("execution")
    if not isinstance(execution, dict):
        errors.append("execution must be an object")
    else:
        if not isinstance(execution.get("agent_adapter"), str) or not execution.get("agent_adapter"):
            errors.append("execution.agent_adapter must be a non-empty path")
        gates = execution.get("gates")
        if not isinstance(gates, list) or not gates or not all(isinstance(g, str) and g.strip() for g in gates):
            errors.append("execution.gates must contain at least one command")
        if not isinstance(execution.get("max_retries", 0), int) or execution.get("max_retries", 0) < 0:
            errors.append("execution.max_retries must be a non-negative integer")
        if not isinstance(execution.get("heartbeat_seconds"), int) or execution.get("heartbeat_seconds", 0) < 5:
            errors.append("execution.heartbeat_seconds must be an integer of at least 5")
        if execution.get("allow_live_actions_unattended") is not False:
            errors.append("execution.allow_live_actions_unattended must be false in BOMBAR v0.1")
    if errors:
        raise BombarError("invalid project profile:\n  - " + "\n  - ".join(errors))
    return profile


def parse_spec(path: pathlib.Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"<!--\s*BOMBAR_SPEC\s*(\{.*?\})\s*-->", text, flags=re.DOTALL)
    if not match:
        raise BombarError(f"{path.as_posix()}: missing <!-- BOMBAR_SPEC {{...}} --> metadata")
    try:
        meta = json.loads(match.group(1))
    except json.JSONDecodeError as exc:
        raise BombarError(f"{path.as_posix()}: invalid BOMBAR_SPEC JSON: {exc}") from exc
    if not isinstance(meta, dict):
        raise BombarError(f"{path.as_posix()}: BOMBAR_SPEC metadata must be an object")
    meta["_path"] = path
    meta["_text"] = text
    meta["_digest"] = sha256(path)
    return meta


def spec_dir(root: pathlib.Path, profile: dict[str, Any]) -> pathlib.Path:
    configured = profile["execution"].get("spec_dir", DEV_DIR.as_posix() + "/specs")
    return root / pathlib.Path(configured)


def evidence_dir(root: pathlib.Path, profile: dict[str, Any]) -> pathlib.Path:
    configured = profile["execution"].get("evidence_dir", DEV_DIR.as_posix() + "/evidence")
    return root / pathlib.Path(configured)


def load_specs(root: pathlib.Path, profile: dict[str, Any]) -> list[dict[str, Any]]:
    directory = spec_dir(root, profile)
    if not directory.is_dir():
        raise BombarError(f"specification directory does not exist: {directory.relative_to(root).as_posix()}")
    paths = sorted(p for p in directory.glob("*.md") if p.name.lower() != "readme.md")
    if not paths:
        raise BombarError(f"no implementation specifications found in {directory.relative_to(root).as_posix()}")
    return [parse_spec(path) for path in paths]


def headings(text: str) -> set[str]:
    return {
        re.sub(r"\s+", " ", match.group(1).strip().lower())
        for match in re.finditer(r"^#{2,4}\s+(.+?)\s*$", text, flags=re.MULTILINE)
    }


def has_placeholder(text: str) -> bool:
    return any(pattern.search(text) for pattern in PLACEHOLDER_PATTERNS)


def topological_specs(specs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_id = {str(spec["id"]): spec for spec in specs}
    indegree = {spec_id: 0 for spec_id in by_id}
    children: dict[str, list[str]] = {spec_id: [] for spec_id in by_id}
    for spec_id, spec in by_id.items():
        for dep in spec["depends_on"]:
            dep_id = str(dep)
            if dep_id not in by_id:
                raise BombarError(f"{spec_id}: unknown dependency {dep_id}")
            indegree[spec_id] += 1
            children[dep_id].append(spec_id)
    ready = deque(sorted(spec_id for spec_id, degree in indegree.items() if degree == 0))
    ordered: list[dict[str, Any]] = []
    while ready:
        spec_id = ready.popleft()
        ordered.append(by_id[spec_id])
        for child in sorted(children[spec_id]):
            indegree[child] -= 1
            if indegree[child] == 0:
                ready.append(child)
    if len(ordered) != len(specs):
        cycle = sorted(spec_id for spec_id, degree in indegree.items() if degree > 0)
        raise BombarError("dependency cycle detected among: " + ", ".join(cycle))
    return ordered


def acceptance_ids(root: pathlib.Path) -> set[str]:
    text = (root / DEV_DIR / "04_ACCEPTANCE_CONTRACT.md").read_text(encoding="utf-8")
    return set(re.findall(r"\bAC-[A-Z][A-Z0-9-]*\b", text))


def validate_artifacts(root: pathlib.Path) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    errors: list[str] = []
    for rel in REQUIRED_ARTIFACTS:
        path = root / rel
        if not path.is_file():
            errors.append(f"missing required artifact: {rel.as_posix()}")
            continue
        text = path.read_text(encoding="utf-8")
        if len(text.strip()) < 80:
            errors.append(f"artifact is too small to be meaningful: {rel.as_posix()}")
        if has_placeholder(text):
            errors.append(f"artifact still contains TODO/TBD/template placeholders: {rel.as_posix()}")
    try:
        profile = load_profile(root)
    except BombarError as exc:
        errors.append(str(exc))
        profile = {}
    specs: list[dict[str, Any]] = []
    if profile:
        try:
            specs = load_specs(root, profile)
        except BombarError as exc:
            errors.append(str(exc))
    ids: list[str] = []
    known_acceptance = acceptance_ids(root) if (root / DEV_DIR / "04_ACCEPTANCE_CONTRACT.md").is_file() else set()
    covered_acceptance: set[str] = set()
    for spec in specs:
        path = pathlib.Path(spec["_path"])
        rel = path.relative_to(root).as_posix()
        for key in REQUIRED_META:
            if key not in spec:
                errors.append(f"{rel}: missing metadata field {key}")
        spec_id = str(spec.get("id", ""))
        if not re.fullmatch(r"[A-Z][A-Z0-9-]{1,31}", spec_id):
            errors.append(f"{rel}: id must match [A-Z][A-Z0-9-]{{1,31}}")
        ids.append(spec_id)
        if spec.get("risk") not in {"low", "medium", "high", "critical"}:
            errors.append(f"{rel}: risk must be low, medium, high, or critical")
        if spec.get("change_mode") not in {"greenfield", "brownfield"}:
            errors.append(f"{rel}: change_mode must be greenfield or brownfield")
        if not isinstance(spec.get("depends_on"), list) or not all(isinstance(v, str) for v in spec.get("depends_on", [])):
            errors.append(f"{rel}: depends_on must be a list of strings")
        if not isinstance(spec.get("requires_live_probe"), bool):
            errors.append(f"{rel}: requires_live_probe must be boolean")
        present = headings(str(spec.get("_text", "")))
        for section in REQUIRED_SPEC_SECTIONS:
            if section not in present:
                errors.append(f"{rel}: missing section '## {section.title()}'")
        if has_placeholder(str(spec.get("_text", ""))):
            errors.append(f"{rel}: contains TODO/TBD/template placeholders")
        covers = spec.get("acceptance_ids", [])
        if not isinstance(covers, list) or not covers:
            errors.append(f"{rel}: acceptance_ids must contain at least one AC-ID")
        else:
            covered_acceptance.update(str(value) for value in covers)
            unknown = sorted(set(str(value) for value in covers) - known_acceptance)
            if unknown:
                errors.append(f"{rel}: unknown acceptance IDs: {', '.join(unknown)}")
        if spec.get("change_mode") == "brownfield":
            for section in ("compatibility and non-disruption", "rollback"):
                if section not in present:
                    errors.append(f"{rel}: brownfield spec missing '## {section.title()}'")
    duplicates = sorted(value for value, count in Counter(ids).items() if count > 1)
    if duplicates:
        errors.append("duplicate specification IDs: " + ", ".join(duplicates))
    missing_coverage = sorted(known_acceptance - covered_acceptance)
    if missing_coverage:
        errors.append("acceptance criteria not covered by any spec: " + ", ".join(missing_coverage))
    if specs:
        try:
            topological_specs(specs)
        except BombarError as exc:
            errors.append(str(exc))
    if errors:
        raise BombarError("plan validation failed:\n  - " + "\n  - ".join(errors))
    return profile, topological_specs(specs)


def governed_paths(root: pathlib.Path, profile: dict[str, Any], specs: list[dict[str, Any]]) -> list[pathlib.Path]:
    paths = list(REQUIRED_ARTIFACTS)
    paths.extend(pathlib.Path(spec["_path"]).relative_to(root) for spec in specs)
    extra = profile.get("approval", {}).get("additional_artifacts", [])
    paths.extend(pathlib.Path(value) for value in extra)
    unique = sorted(set(paths), key=lambda p: p.as_posix())
    missing = [path.as_posix() for path in unique if not (root / path).is_file()]
    if missing:
        raise BombarError("approval artifacts missing: " + ", ".join(missing))
    return unique


def make_approval(root: pathlib.Path, approved_by: str) -> dict[str, Any]:
    profile, specs = validate_artifacts(root)
    paths = governed_paths(root, profile, specs)
    return {
        "schema_version": SCHEMA_VERSION,
        "status": "approved",
        "approved_by": approved_by,
        "approved_at": utc_now(),
        "git_commit_at_approval": run_git(root, "rev-parse", "HEAD"),
        "artifacts": [
            {"path": path.as_posix(), "sha256": sha256(root / path)}
            for path in paths
        ],
    }


def verify_approval(root: pathlib.Path, profile: dict[str, Any], specs: list[dict[str, Any]]) -> dict[str, Any]:
    approval = read_json(root / APPROVAL_PATH)
    if approval.get("status") != "approved":
        raise BombarError("approval status is not approved")
    expected_paths = {path.as_posix() for path in governed_paths(root, profile, specs)}
    recorded = approval.get("artifacts")
    if not isinstance(recorded, list):
        raise BombarError("approval.artifacts must be a list")
    recorded_paths = {str(item.get("path")) for item in recorded if isinstance(item, dict)}
    if expected_paths != recorded_paths:
        missing = sorted(expected_paths - recorded_paths)
        stale = sorted(recorded_paths - expected_paths)
        raise BombarError(f"approval artifact set changed; missing={missing}, stale={stale}")
    drift: list[str] = []
    for item in recorded:
        path = root / str(item["path"])
        if not path.is_file() or sha256(path) != item.get("sha256"):
            drift.append(str(item["path"]))
    if drift:
        raise BombarError(
            "approved artifacts changed after approval: " + ", ".join(drift)
            + ". Review interactively and freeze again."
        )
    return approval


def marker_path(root: pathlib.Path, spec_id: str) -> pathlib.Path:
    return root / CONTROL_DIR / "state" / f"{spec_id}.done.json"


def spec_status(root: pathlib.Path, spec: dict[str, Any]) -> str:
    marker = marker_path(root, str(spec["id"]))
    if not marker.is_file():
        return "pending"
    data = read_json(marker)
    if data.get("spec_sha256") != spec["_digest"]:
        return "stale"
    return "done"


def command_validate(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    profile, specs = validate_artifacts(root)
    print(f"Plan valid: {len(specs)} specification(s), dependency graph acyclic, acceptance covered.")
    if args.freeze:
        if not args.approved_by or not args.approved_by.strip():
            raise BombarError("--freeze requires --approved-by NAME")
        dirty = run_git(root, "status", "--porcelain")
        if dirty:
            raise BombarError("commit the architecture/specification artifacts before freezing approval")
        approval = make_approval(root, args.approved_by.strip())
        write_json(root / APPROVAL_PATH, approval)
        print(f"Approval frozen by {approval['approved_by']} over {len(approval['artifacts'])} artifacts.")
        print(f"Commit {APPROVAL_PATH.as_posix()} before running the Engineering Partner.")
    elif (root / APPROVAL_PATH).is_file():
        verify_approval(root, profile, specs)
        print("Approval digest valid: governed artifacts are unchanged.")
    else:
        print("Plan is not approved. Review interactively, then rerun with --freeze --approved-by NAME.")


def command_specs(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    profile, specs = validate_artifacts(root)
    if args.require_approval:
        verify_approval(root, profile, specs)
    payload = [
        {
            "id": spec["id"],
            "title": spec["title"],
            "path": pathlib.Path(spec["_path"]).relative_to(root).as_posix(),
            "sha256": spec["_digest"],
            "depends_on": spec["depends_on"],
            "risk": spec["risk"],
            "change_mode": spec["change_mode"],
            "requires_live_probe": spec["requires_live_probe"],
            "status": spec_status(root, spec),
        }
        for spec in specs
    ]
    print(json.dumps(payload, ensure_ascii=False))


def command_approval(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    profile, specs = validate_artifacts(root)
    approval = verify_approval(root, profile, specs)
    print(json.dumps(approval, ensure_ascii=False))


def command_status(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    profile, specs = validate_artifacts(root)
    approval_state = "not approved"
    if (root / APPROVAL_PATH).is_file():
        try:
            verify_approval(root, profile, specs)
            approval_state = "approved"
        except BombarError:
            approval_state = "approval stale"
    print(f"BOMBAR status — {profile['project']['name']} — {approval_state}")
    for spec in specs:
        deps = ",".join(spec["depends_on"]) or "-"
        print(f"{spec_status(root, spec):8} {spec['id']:12} deps={deps:16} {spec['title']}")


def command_mark(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    profile, specs = validate_artifacts(root)
    verify_approval(root, profile, specs)
    spec = next((item for item in specs if item["id"] == args.spec_id), None)
    if spec is None:
        raise BombarError(f"unknown specification ID: {args.spec_id}")
    evidence = evidence_dir(root, profile) / f"{args.spec_id}_EVIDENCE.md"
    # Evidence is an audit-trail nicety, NEVER a gate. A green, gate-passing,
    # committed build is DONE regardless of whether the evidence file exists or
    # how it is formatted. Record it if present and move on — a build is never
    # thrown away over evidence bureaucracy.
    marker = {
        "schema_version": SCHEMA_VERSION,
        "spec_id": args.spec_id,
        "spec_sha256": spec["_digest"],
        "commit": run_git(root, "rev-parse", "HEAD"),
        "completed_at": utc_now(),
        "evidence": evidence.relative_to(root).as_posix() if evidence.is_file() else None,
        "live_probe_pending": bool(spec["requires_live_probe"]),
    }
    write_json(marker_path(root, args.spec_id), marker)
    print(marker_path(root, args.spec_id).relative_to(root).as_posix())


def command_facts(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    files = [path for path in root.rglob("*") if path.is_file() and ".git" not in path.parts and ".bombar" not in path.parts]
    suffixes = Counter((path.suffix.lower() or "[none]") for path in files)
    top_dirs = Counter(path.relative_to(root).parts[0] for path in files if path.relative_to(root).parts)
    status = run_git(root, "status", "--short", check=False) or "clean"
    recent = run_git(root, "log", "-5", "--oneline", check=False) or "no commits"
    report = [
        "# Repository facts for the interactive Architect",
        "",
        f"Generated: {utc_now()}",
        f"Repository: `{root}`",
        f"Current branch: `{run_git(root, 'branch', '--show-current', check=False) or '[unborn]'}`",
        "",
        "## Git state",
        "",
        "```text",
        status,
        "```",
        "",
        "## Recent commits",
        "",
        "```text",
        recent,
        "```",
        "",
        "## File-extension distribution",
        "",
    ]
    report.extend(f"- `{suffix}`: {count}" for suffix, count in suffixes.most_common(20))
    report.extend(["", "## Top-level file distribution", ""])
    report.extend(f"- `{name}`: {count}" for name, count in top_dirs.most_common(20))
    report.extend([
        "",
        "> These are orientation facts, not an architecture assessment. The interactive Architect must inspect the relevant documentation and code before drawing conclusions.",
        "",
    ])
    output = root / CONTROL_DIR / "context" / "REPOSITORY_FACTS.md"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(report), encoding="utf-8")
    print(output.relative_to(root).as_posix())


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="bombar.py")
    sub = parser.add_subparsers(dest="command", required=True)

    validate = sub.add_parser("validate")
    validate.add_argument("--root")
    validate.add_argument("--freeze", action="store_true")
    validate.add_argument("--approved-by")
    validate.set_defaults(func=command_validate)

    specs = sub.add_parser("specs")
    specs.add_argument("--root")
    specs.add_argument("--require-approval", action="store_true")
    specs.set_defaults(func=command_specs)

    approval = sub.add_parser("approval")
    approval.add_argument("--root")
    approval.set_defaults(func=command_approval)

    status = sub.add_parser("status")
    status.add_argument("--root")
    status.set_defaults(func=command_status)

    mark = sub.add_parser("mark-done")
    mark.add_argument("spec_id")
    mark.add_argument("--root")
    mark.set_defaults(func=command_mark)

    facts = sub.add_parser("repository-facts")
    facts.add_argument("--root")
    facts.set_defaults(func=command_facts)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    try:
        args.func(args)
    except BombarError as exc:
        print(f"BOMBAR ERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
