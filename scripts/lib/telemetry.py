#!/usr/bin/env python3
"""BOMBAR lightweight telemetry — capture first, interpret later.

Deterministic and best-effort: this module records objective run facts and reads
native structured output from the coding-agent CLIs. It never scores context,
never sets a kill threshold, and never parses unstable private transcript formats
when a native structured interface exists. Any failure here is non-fatal to a run.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import pathlib
import sys
from typing import Any


def _utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def append_event(run_file: pathlib.Path, event: dict[str, Any]) -> None:
    run_file.parent.mkdir(parents=True, exist_ok=True)
    record = {"ts": _utc_now(), **event}
    with run_file.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(record, ensure_ascii=False) + "\n")


def _iter_json_lines(path: pathlib.Path) -> list[dict[str, Any]]:
    objects: list[dict[str, Any]] = []
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return objects
    for line in text.splitlines():
        line = line.strip()
        if not line or line[0] != "{":
            continue
        try:
            value = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(value, dict):
            objects.append(value)
    return objects


def native_from_agent_log(path: pathlib.Path) -> dict[str, Any]:
    """Normalize native telemetry from a Claude Code stream-json log or a Codex
    --json log. Returns {} when the log is not structured (e.g. a fake adapter)."""
    objects = _iter_json_lines(path)
    if not objects:
        return {}

    # Claude Code: a final {"type":"result", ...} object carries everything.
    result = next((o for o in reversed(objects) if o.get("type") == "result"), None)
    if result is not None:
        usage = result.get("usage") or {}
        model = None
        model_usage = result.get("modelUsage") or {}
        if isinstance(model_usage, dict) and model_usage:
            # the priciest / main model is a fine label for the turn
            model = max(
                model_usage.items(),
                key=lambda kv: (kv[1] or {}).get("costUSD", 0) if isinstance(kv[1], dict) else 0,
            )[0]
        return {
            "runtime": "claude-code",
            "session_id": result.get("session_id"),
            "model": model,
            "input_tokens": usage.get("input_tokens"),
            "output_tokens": usage.get("output_tokens"),
            "cache_read_input_tokens": usage.get("cache_read_input_tokens"),
            "cache_creation_input_tokens": usage.get("cache_creation_input_tokens"),
            "cost_usd": result.get("total_cost_usd"),
            "duration_ms": result.get("duration_ms"),
            "num_turns": result.get("num_turns"),
            "status": result.get("subtype") or result.get("terminal_reason"),
            "is_error": result.get("is_error"),
        }

    # Codex CLI (best-effort): thread.started + turn.completed usage.
    thread = next((o for o in objects if o.get("type") == "thread.started"), None)
    turns = [o for o in objects if o.get("type") == "turn.completed"]
    failed = [o for o in objects if o.get("type") == "turn.failed"]
    if thread is not None or turns:
        inp = out = cached = 0
        for turn in turns:
            u = turn.get("usage") or {}
            inp += int(u.get("input_tokens") or 0)
            out += int(u.get("output_tokens") or 0)
            cached += int(u.get("cached_input_tokens") or 0)
        return {
            "runtime": "codex",
            "session_id": (thread or {}).get("thread_id") or (thread or {}).get("id"),
            "model": None,  # not surfaced in Codex events; tracked out of band
            "input_tokens": inp or None,
            "output_tokens": out or None,
            "cache_read_input_tokens": cached or None,
            "cost_usd": None,
            "duration_ms": None,
            "num_turns": len(turns) or None,
            "status": "failed" if failed else ("completed" if turns else None),
            "is_error": bool(failed),
        }

    return {}


def _fmt_hms(seconds: float) -> str:
    s = int(seconds)
    return f"{s // 3600:02d}:{(s % 3600) // 60:02d}:{s % 60:02d}"


def summary(run_file: pathlib.Path) -> str:
    events = _iter_json_lines(run_file)
    started = next((e for e in events if e.get("kind") == "run.started"), {})
    specs_total = started.get("specs")
    specs_done = sum(1 for e in events if e.get("kind") == "spec.completed")
    sessions = sum(1 for e in events if e.get("kind") == "session.created")
    resumes = sum(1 for e in events if e.get("kind") == "agent.turn" and e.get("resumed"))
    retries = sum(1 for e in events if e.get("kind") == "retry")
    blockers = sum(1 for e in events if e.get("kind") == "blocker.raised")
    interventions = sum(1 for e in events if e.get("kind") == "human.intervention")

    impl_s = sum(float(e.get("duration_s") or 0) for e in events if e.get("kind") == "agent.turn")
    gate_s = sum(float(e.get("duration_s") or 0) for e in events if e.get("kind") in ("gate.completed", "final_gates.completed"))
    review_s = sum(float(e.get("duration_s") or 0) for e in events if e.get("kind") == "reviewer.completed")

    in_tok = sum(int((e.get("native") or {}).get("input_tokens") or 0) for e in events if e.get("kind") == "agent.turn")
    out_tok = sum(int((e.get("native") or {}).get("output_tokens") or 0) for e in events if e.get("kind") == "agent.turn")
    cost = sum(float((e.get("native") or {}).get("cost_usd") or 0) for e in events if e.get("kind") == "agent.turn")

    verdict_event = next((e for e in reversed(events) if e.get("kind") == "reviewer.completed"), None)
    verdict = (verdict_event or {}).get("verdict", "n/a (independent review run separately)")

    total_label = f"{specs_done}/{specs_total}" if specs_total is not None else str(specs_done)
    lines = [
        "BOMBAR run summary",
        "==================",
        f"Specs:               {total_label}",
        f"Partner sessions:    {sessions}",
        f"Session resumes:     {resumes}",
        f"Implementation:      {_fmt_hms(impl_s)}",
        f"Gates:               {_fmt_hms(gate_s)}",
        f"Verification:        {_fmt_hms(review_s)}",
        f"Retries:             {retries}",
        f"Blockers:            {blockers}",
        f"Human interventions: {interventions}",
        f"Tokens (in/out):     {in_tok} / {out_tok}",
        f"Est. cost (USD):     {cost:.4f}",
        f"Final review:        {verdict}",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(prog="telemetry.py")
    sub = parser.add_subparsers(dest="command", required=True)

    ev = sub.add_parser("event")
    ev.add_argument("--run", required=True)
    ev.add_argument("--kind", required=True)
    ev.add_argument("--data", default="{}", help="JSON object merged into the event")

    nat = sub.add_parser("native")
    nat.add_argument("agent_log")

    sm = sub.add_parser("summary")
    sm.add_argument("--run", required=True)

    args = parser.parse_args()
    try:
        if args.command == "event":
            try:
                data = json.loads(args.data)
            except json.JSONDecodeError:
                data = {}
            if not isinstance(data, dict):
                data = {}
            append_event(pathlib.Path(args.run), {"kind": args.kind, **data})
        elif args.command == "native":
            print(json.dumps(native_from_agent_log(pathlib.Path(args.agent_log)), ensure_ascii=False))
        elif args.command == "summary":
            print(summary(pathlib.Path(args.run)))
    except Exception as exc:  # telemetry is never fatal to a run
        print(f"telemetry non-fatal error: {exc}", file=sys.stderr)
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
