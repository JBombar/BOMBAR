# Product and architecture invariants

> TODO: Keep this set small and load-bearing. An invariant is not a preference; violating it makes the product unsafe, incoherent, or dishonest.

| ID | Invariant | Mechanism | Checker |
|---|---|---|---|
| INV-1 | TODO | TODO | test / gate / probe / audit |

## Outcome and liveness invariants

> Include **operational** invariants here when they are genuinely load-bearing, not only functional ones — e.g. request-path liveness (external and datastore IO must fail bounded, never hang a request to a platform timeout) and work that must not scale pathologically with data. State them as properties that must remain true, at the altitude of intent. Do **not** turn this into a catalogue of ordinary competence ("don't N+1", "don't waste IO"); that is the Engineering Partner's professional responsibility to exercise. Add an operational invariant only where a specific liveness or resource property genuinely matters for this product.

| ID | What must actually happen | Sensor outside the actor's own claim | Tolerance |
|---|---|---|---|
| OI-1 | TODO | TODO | TODO |

## Invariant change policy

Changing an invariant requires an interactive Architect session, an ADR explaining the reason and consequences, owner approval, and a new approval digest. Builders never change invariants.
