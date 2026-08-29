# BOMBAR agent-runtime adapter contract

An adapter is the seam between BOMBAR's deterministic runner and one coding-agent
CLI. BOMBAR is runtime-agnostic: it drives an **Engineering Partner** that normally
continues across obligations. The adapter maps three logical operations onto a CLI.

## Invocation

```
adapter.sh <prompt-file>
```

One invocation drives **one Engineering Partner turn**. The runner captures stdout
+ stderr to a per-attempt log and reads the process exit code.

## Environment the runner supplies

| Var | Meaning |
|---|---|
| `BOMBAR_SESSION_ID` | The Engineering Partner's stable session id (a UUID). Use it to **start** and later **resume** the same session, if your runtime supports id-addressed sessions. |
| `BOMBAR_RESUME` | `1` = continue the existing session with warm context; `0`/unset = start it. |
| `BOMBAR_SPEC_ID`, `BOMBAR_UNATTENDED` | Current obligation id; unattended marker. |
| `BOMBAR_MAX_TURNS`, `BOMBAR_CLAUDE_MODEL` | Optional turn cap / model override (adapter-specific). |

## The three operations

1. **start** — `BOMBAR_RESUME` unset/`0`: begin a session. Prefer assigning
   `BOMBAR_SESSION_ID` if the runtime allows (Claude Code: `--session-id`). If it
   does not (Codex: ids are auto-generated), start normally.
2. **resume** — `BOMBAR_RESUME=1`: continue the same session with its accumulated
   context. Prefer resume-by-id (`--resume <id>`); otherwise continue the most
   recent session (`--continue` / `resume --last`).
3. **structured result** — prefer a native JSON/stream-json output mode so BOMBAR
   can capture telemetry (session id, tokens, duration, status) without parsing the
   runtime's private transcript files. Optional but recommended.

If a runtime cannot continue a session at all, **ignore the continuity vars and run
the self-contained prompt fresh** — every prompt stands on its own. Continuity is an
optimization for quality and speed, never a correctness requirement.

## Non-negotiables

- Do not bypass the repository's own sandbox/permission policy silently.
- Never perform live/paid/production/deployment actions; the runner forbids them.
- Return the agent process exit code.

## Reference status

- `claude-code.sh` — **reference**, fully verified: id-addressed `--session-id` /
  `--resume`, stream-json telemetry.
- `codex.sh` — **experimental**, best-effort: `resume --last`, `--json` telemetry;
  validate on your installed `codex` before relying on it.
