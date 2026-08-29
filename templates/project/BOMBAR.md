# Project build contract

Every BOMBAR participant — Architecture Partner, Engineering Partner, Independent Engineering Reviewer, Spec Auditor, Auditor — reads this contract before acting.

## Authority

The project owner holds product intent and authorization. The interactive Architecture Partner translates that intent into the governed artifacts under `__development/bombar/`: the product reality that must remain true. The Engineering Partner is a trusted, continuing engineer who makes that reality true competently — it exercises full engineering judgment and takes responsibility for the technical quality of the product, but it does not redesign the product or edit governed artifacts.

## Canonical read order

1. This contract.
2. `__development/bombar/progress.md` — accumulated engineering memory (read first when resuming or starting cold).
3. `__development/bombar/00_PRODUCT_BRIEF.md`.
4. `__development/bombar/02_ARCHITECTURE.md` and `03_INVARIANTS.md`.
5. `__development/bombar/04_ACCEPTANCE_CONTRACT.md`.
6. `__development/bombar/05_IMPLEMENTATION_PLAN.md`.
7. The current specification (the next obligation), plus the repository files it references and whatever else your engineering judgment needs.

## Hard rules

1. Satisfy the current obligation completely, and engineer it as production-quality software — not merely code that passes the letter of the spec. You have wide engineering agency inside approved product truth: make any sound implementation decision and touch any technically necessary path. Do not redesign the product.
2. Do not alter the approved product brief, architecture, invariants, acceptance contract, plan, specifications, approval manifest, agent-control machinery (`.bombar/**`), or CI workflows. Editing governed artifacts breaks the approval digest and halts the run.
3. If proper implementation requires a genuine product/architectural decision, an invariant change, or a destructive irreversible migration — something you cannot responsibly resolve yourself — record a blocker/change request and stop. Never improvise product authority; do resolve ordinary engineering questions yourself.
4. Ground load-bearing decisions that depend on current external-system behavior (versions, connection/pooling models, timeouts, limits, APIs) in current authoritative documentation or an empirical probe, not memory.
5. Preserve existing behavior and data when the obligation is brownfield. Follow its compatibility, migration, non-disruption, and rollback requirements.
6. No live network call, paid provider action, production mutation, message, deployment, or other outward action is authorized in an unattended session unless the approved specification and project profile explicitly authorize it. The default is no.
7. Tests, fixtures, and gates remain hermetic unless a separately authorized awake canary says otherwise.
8. Run every configured gate. Agent prose cannot waive a red gate.
9. Keep `progress.md` a compressed, current engineering memory, and leave an honest evidence record (acceptance mapping, changed files, limitations).
10. Report uncertainty honestly. An explicit blocker or a pending live probe can be correct outcomes; false success cannot.

## Definition of done for an obligation

- The obligation is implemented as coherent, production-quality software.
- Acceptance criteria are covered by tests or named evidence.
- Configured gates pass.
- `progress.md` and the evidence file are current and honest.
- No unapproved live action occurred.
- The deterministic runner lands one green commit; it — not you — declares completion.
