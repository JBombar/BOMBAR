# Agent adapters

An adapter is the only provider-specific part of the autonomous loop.

## Contract

```text
adapter.sh <prompt-file>
```

It must:

1. start one **fresh** non-interactive coding-agent session;
2. give it the complete prompt file;
3. run from the target repository root;
4. wait until the session finishes;
5. stream ordinary output to stdout/stderr;
6. return the process exit code;
7. never use conversation continuation/resume state.

The deterministic runner does not trust exit code alone; it independently checks repository changes, gates, and commit state, and records telemetry.

## Selection

Set `.bombar/project-profile.json`:

```json
"agent_adapter": ".bombar/adapters/custom.sh"
```

The default `generic.sh` refuses to run so that BOMBAR never silently guesses a provider or permission posture.

## Review permissions explicitly

An agent CLI may offer flags that disable approval prompts or widen filesystem/network access. BOMBAR does not add such flags automatically. Decide the sandbox and permissions proportional to the project. A high-risk brownfield session should run within external isolation and should never receive production/origin credentials.

## Provider adapters

Example Codex and Claude Code adapters are included as starting points. CLI contracts evolve; run the installed tool's help and review the adapter before first use. Provider adapters are convenience, not BOMBAR's source of truth.

## Testing an adapter

Before real implementation, point it at a throwaway fixture specification that changes one known file, writes evidence, and stops. Confirm:

- a fresh context is created on every invocation;
- the process returns;
- logs are captured;
- no continuation state leaks;
- permissions match your expectation;
- no live credential is exposed.
