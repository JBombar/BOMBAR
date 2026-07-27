# Brownfield example — idempotent webhook repair

This example represents an existing billing service with real subscriptions and a duplicated webhook side effect. The change is small, but the blast radius is not.

The brownfield additions are load-bearing:

- characterization of current behavior;
- compatibility and non-disruption;
- additive migration treatment;
- rollback limits;
- concurrency proof at the side-effect boundary;
- payment-provider test-mode canary.
