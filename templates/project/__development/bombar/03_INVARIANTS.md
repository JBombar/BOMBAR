# Product and architecture invariants

> TODO: Keep this set small and load-bearing. An invariant is not a preference; violating it makes the product unsafe, incoherent, or dishonest.

| ID | Invariant | Mechanism | Checker |
|---|---|---|---|
| INV-1 | TODO | TODO | test / gate / probe / audit |

## Outcome and liveness invariants

| ID | What must actually happen | Sensor outside the actor's own claim | Tolerance |
|---|---|---|---|
| OI-1 | TODO | TODO | TODO |

## Invariant change policy

Changing an invariant requires an interactive Architect session, an ADR explaining the reason and consequences, owner approval, and a new approval digest. Builders never change invariants.
