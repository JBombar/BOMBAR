# WEBHOOK-01 — webhook idempotency at the entitlement boundary

<!-- BOMBAR_SPEC
{
  "id": "WEBHOOK-01",
  "title": "Webhook idempotency at the entitlement boundary",
  "depends_on": [],
  "risk": "high",
  "change_mode": "brownfield",
  "touchable_paths": ["src/billing/webhooks/**", "migrations/**", "tests/billing/**"],
  "protected_paths": ["src/billing/invoices/**"],
  "requires_live_probe": true,
  "acceptance_ids": ["AC-WEBHOOK-1", "AC-WEBHOOK-2", "AC-WEBHOOK-3", "AC-WEBHOOK-4"]
}
-->

## Outcome

Repeated delivery of one provider event cannot repeat the entitlement side effect.

## Current State

The handler writes the event receipt after mutating entitlement, leaving a crash/concurrency window. Existing rows contain provider event IDs but uniqueness is not enforced.

## Scope

Additive uniqueness mechanism, claim-before-effect transaction, duplicate acknowledgement, concurrency tests, characterization control, and test-mode canary runbook.

## Out of Scope

Invoice calculation, subscription-plan redesign, production data deletion, and live production webhook replay.

## Compatibility and Non-disruption

Historical rows remain unchanged and readable. The control test proves a distinct event uses the same entitlement behavior and response shape as before. Pre-migration duplicate detection fails loudly rather than deleting or merging data.

## Acceptance Criteria

AC-WEBHOOK-1/2/3 pass offline. AC-WEBHOOK-4 remains pending for an explicitly authorized provider test-mode probe.

## Verification

Two concurrent handler calls share a provider-double side-effect counter and assert a maximum of one mutation. Reverting the claim-before-effect order makes the concurrency test fail. Migration is tested on historical fixtures.

## Rollback

Code can return to the tagged pre-change commit. The additive receipt uniqueness constraint may remain safely; removing it requires a separate reviewed migration. No destructive down migration is automated.

## Definition of Done

Configured gates pass, migration preflight is clean, bite and non-disruption evidence are recorded, offline implementation commits, and the provider canary remains an awake release hold point.
