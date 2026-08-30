# WEBHOOK-01 — webhook idempotency at the entitlement boundary

<!-- BOMBAR_SPEC
{
  "id": "WEBHOOK-01",
  "title": "Webhook idempotency at the entitlement boundary",
  "depends_on": [],
  "risk": "high",
  "change_mode": "brownfield",
  "requires_live_probe": true,
  "acceptance_ids": ["AC-WEBHOOK-1", "AC-WEBHOOK-2", "AC-WEBHOOK-3", "AC-WEBHOOK-4"]
}
-->

## Outcome

Repeated delivery of one provider event cannot repeat the entitlement side effect. Today the handler writes the event receipt after mutating entitlement, leaving a crash/concurrency window, and event IDs exist but uniqueness is not enforced. This obligation makes the effect idempotent; invoice calculation and subscription-plan design are settled product decisions it must not alter.

## Compatibility and non-disruption

Historical rows remain unchanged and readable. A control test proves a distinct event keeps the same entitlement behavior and response shape as before. Pre-migration duplicate detection fails loudly rather than deleting or merging data.

## Acceptance criteria

AC-WEBHOOK-1/2/3 pass offline. AC-WEBHOOK-4 remains pending for an explicitly authorized provider test-mode probe.

## Verification

Two concurrent handler calls share a provider-double side-effect counter and assert at most one mutation. Reverting the claim-before-effect order makes the concurrency test fail. Migration is tested on historical fixtures.

## Rollback

Code can return to the tagged pre-change commit. The additive receipt-uniqueness constraint may remain safely; removing it requires a separate reviewed migration. No destructive down migration is automated.
