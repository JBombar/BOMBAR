# BOMBAR constitution

This is the repository-level contract for developing BOMBAR itself. A project initialized by BOMBAR receives its own project-specific contract.

## Purpose

BOMBAR transfers a disciplined human-plus-agent software-development method without pretending that foundational product judgment is autonomous.

## Invariants

1. **Intent remains interactive.** No headless process may invent or approve the product purpose, architecture, acceptance contract, or implementation plan.
2. **Approval is content-addressed.** Autonomous execution requires an explicit approval manifest whose digests match every governed artifact.
3. **One continuing Engineering Partner; a fresh Independent Reviewer.** The implementer normally continues across obligations in one warm session (continuity improves engineering quality); review is done by a separate fresh context that does not share the Partner's session or self-report. A new Engineering Partner is created only when continuation is impossible.
4. **The deterministic runner is the arbiter.** Agent prose never decides whether an obligation is complete.
5. **Bounded obligations, agency within.** Every specification declares dependencies, outcomes, non-goals, acceptance, and verification; within approved product truth the Engineering Partner has wide engineering agency.
6. **No silent redesign.** The Engineering Partner engineers approved specifications or files a blocker/change request. It does not change the governing artifacts (protected by the approval digest).
7. **Tests must bite.** Outcome-bearing protections include a falsification or mutation demonstration whenever practical.
8. **Evidence is recorded.** Every completed obligation leaves an evidence record and updated engineering memory as an audit trail; evidence is a nicety, never a gate.
9. **World claims need world sensors.** A ledger cannot certify its own external effect. Live acceptance is an awake, authorized act.
10. **Brownfield raises the bar.** Existing behavior, data, interfaces, users, and operations are preserved explicitly, with rollback and non-disruption proof proportional to risk.
11. **Failure is visible.** No-op, red gate, changed approval digest, and exhausted retry all halt loudly.
12. **Provider neutrality.** The core contract does not depend on one model vendor or command-line interface.

## Development gates

```bash
bash tests/run.sh
python -m compileall scripts/lib
```

Tests are hermetic: they use fixture repositories and fake adapters only. They perform no network call, paid action, repository publication, or live provider operation.
