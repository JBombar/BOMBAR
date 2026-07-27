# BOMBAR constitution

This is the repository-level contract for developing BOMBAR itself. A project initialized by BOMBAR receives its own project-specific contract.

## Purpose

BOMBAR transfers a disciplined human-plus-agent software-development method without pretending that foundational product judgment is autonomous.

## Invariants

1. **Intent remains interactive.** No headless process may invent or approve the product purpose, architecture, acceptance contract, or implementation plan.
2. **Approval is content-addressed.** Autonomous execution requires an explicit approval manifest whose digests match every governed artifact.
3. **One fresh Builder per slice.** A retry is also a fresh session. No conversational continuation is treated as isolation.
4. **The deterministic runner is the arbiter.** Agent prose never decides whether a slice is complete.
5. **One slice, bounded scope.** Every specification declares dependencies, touchable paths, protected paths, outcomes, non-goals, acceptance, and verification.
6. **No silent redesign.** Builders execute approved specifications or file a blocker/change request. They do not change the governing artifacts.
7. **Tests must bite.** Outcome-bearing protections include a falsification or mutation demonstration whenever practical.
8. **Evidence is required.** Every completed slice produces an evidence record tied to the exact specification digest and commit.
9. **World claims need world sensors.** A ledger cannot certify its own external effect. Live acceptance is an awake, authorized act.
10. **Brownfield raises the bar.** Existing behavior, data, interfaces, users, and operations are preserved explicitly, with rollback and non-disruption proof proportional to risk.
11. **Failure is visible.** No-op, red gate, scope breach, changed approval digest, missing evidence, and exhausted retry all halt loudly.
12. **Provider neutrality.** The core contract does not depend on one model vendor or command-line interface.

## Development gates

```bash
bash tests/run.sh
python -m compileall scripts/lib
```

Tests are hermetic: they use fixture repositories and fake adapters only. They perform no network call, paid action, repository publication, or live provider operation.
