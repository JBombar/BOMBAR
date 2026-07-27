# Acceptance contract

- **AC-WEBHOOK-1** — Two deliveries with the same provider event ID produce at most one entitlement mutation — `[auto/concurrency]`.
- **AC-WEBHOOK-2** — Existing historical webhook rows remain readable and require no destructive backfill — `[auto]`.
- **AC-WEBHOOK-3** — A new unrelated event follows the existing entitlement path unchanged — `[auto/non-disruption]`.
- **AC-WEBHOOK-4** — A provider test-mode duplicate is acknowledged twice while the observed entitlement changes once — `[probe]`.
