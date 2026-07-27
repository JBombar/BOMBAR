# Verification model

## Tests are necessary and insufficient

A test can be green because it never reached the intended path, asserted on an empty collection, mocked away the important boundary, or encoded the same mistaken assumption as the implementation. BOMBAR therefore requires evidence at several layers.

## Layer 1 — structural and deterministic gates

Examples: formatting, lint, types, unit/integration tests, schema checks, builds, import/dependency tripwires, protected-path checks, and clean commits. The project profile defines the real commands.

## Layer 2 — falsification

For load-bearing behavior, demonstrate that the protection bites:

1. temporarily remove or reverse the fix;
2. observe the relevant test fail for the intended reason;
3. restore the implementation;
4. observe it pass;
5. record the demonstration in evidence.

Not every cosmetic change warrants mutation proof. Use it where a passing-but-vacuous test would create false confidence.

## Layer 3 — independent conformance

A fresh Verifier receives the frozen contract, specifications, full Git diff, evidence, and test machinery. It does not receive the Builder's transcript and does not treat changed-file instructions as authority.

## Layer 4 — world-boundary probes

Use an external sensor for an external claim:

| Claim | Internal evidence is insufficient | Better sensor |
|---|---|---|
| email sent | send ledger | provider Sent folder + receiving inbox |
| deployment succeeded | deploy job status | outside HTTP/user-path probe |
| payment worked | local payment row | payment-provider test event/receipt |
| crawler found no result | empty adapter list | source outcome proving the source succeeded and genuinely returned zero |

Live probes are awake, explicitly authorized operations. The unattended runner records them as pending; it does not perform them by default.

## Evidence record

Each slice's evidence answers:

- What exact commands ran and what were their exact results?
- Which AC-IDs are proven, by what?
- What changed and why?
- Which important test was shown to bite?
- What existing behavior was proven unaffected?
- What remains unknown, deferred, or live-pending?

Evidence is a review aid, not self-certification. The Verifier checks it against reality.
