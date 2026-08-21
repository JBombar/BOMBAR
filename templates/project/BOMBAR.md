# Project build contract

Every BOMBAR Architect, Planner, Builder, Verifier, and Auditor reads this contract before acting.

## Authority

The project owner holds product intent and authorization. The interactive Architect translates that intent into the governed artifacts under `__development/bombar/`. Builders are disposable execution contexts: they implement one approved specification and may not redesign the product or edit governed artifacts.

## Canonical read order

1. This contract.
2. `__development/bombar/00_PRODUCT_BRIEF.md`.
3. `__development/bombar/02_ARCHITECTURE.md` and `03_INVARIANTS.md`.
4. `__development/bombar/04_ACCEPTANCE_CONTRACT.md`.
5. `__development/bombar/05_IMPLEMENTATION_PLAN.md`.
6. The assigned specification only, plus the repository files it explicitly references.

## Hard rules

1. Implement the assigned specification completely. Use engineering judgment for small, clearly-necessary things just outside its letter (a helper, a script, a bit of wiring)—touching a sensible path is welcome, not a violation. Do not redesign the product.
2. Do not alter the approved product brief, architecture, invariants, acceptance contract, plan, specifications, approval manifest, agent-control machinery, or CI workflows.
3. If implementation requires a product or architectural decision absent from the specification, record a blocker/change request and stop. Never improvise authority.
4. Preserve existing behavior and data when the specification is brownfield. Follow its compatibility, migration, non-disruption, and rollback requirements.
5. No live network call, paid provider action, production mutation, message, deployment, or other outward action is authorized in an unattended Builder session unless the approved specification and project profile explicitly authorize it. The default is no.
6. Tests, fixtures, and gates remain hermetic unless a separately authorized awake canary says otherwise.
7. Run every configured gate. Agent prose cannot waive a red gate.
8. Produce the required evidence record with exact commands and results, acceptance mapping, changed files, and limitations.
9. Commit only after the gates pass. One specification ends in one reviewable green commit.
10. Report uncertainty honestly. `research_needed`, an explicit blocker, or a pending live probe can be correct outcomes; false success cannot.

## Definition of done for a Builder slice

- Approved specification implemented exactly.
- Acceptance criteria covered by tests or named evidence.
- Configured gates pass.
- Evidence file exists and is honest.
- No unapproved live action occurred.
- One green commit exists and the Builder stops.
