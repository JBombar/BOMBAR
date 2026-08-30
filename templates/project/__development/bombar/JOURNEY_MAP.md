# Journey Map

The launch-critical journeys — the things a real person must be able to **do**, end to end.

Every launch journey must be **owned** by a specification that delivers it and lets a real actor reach the
outcome through the real interface, or **explicitly deferred** by the owner with a reason. A journey whose
backend service exists but that no real user can reach is *not* owned.

Each owned journey names **what outcome must be credibly proven** — not how. The verification mechanism and
cadence (a browser journey, an integration test, a targeted probe, a cheaper proof) are the Architecture
Partner's and Engineering Partner's proportional judgment, based on risk, affected behavior, information
value, and cost. Important journeys deserve appropriate product-level verification; that is **not** a
standing requirement to run a browser E2E suite for every journey on every slice.

The independent **Spec Auditor** (`prompts/spec-auditor.md`) helps complete this table before freeze by
enumerating the journeys the product needs and interrogating the owner about the gaps. The owner confirms
it. A plausible journey the Auditor discovers is an **open question for the owner**, not an automatic launch
requirement.

| Journey ID | Actor | End-to-end steps (actor's seat) | Owning spec(s) | Outcome that needs credible proof | Status |
|---|---|---|---|---|---|
| `J-EXAMPLE-BUY` | customer | browse catalogue → open product → add to cart → checkout → pay → see confirmation | S06, S08, S09 | a real buyer completes one purchase and sees confirmation (mechanism: engineer's call) | owned |
| `J-EXAMPLE-FULFILL` | staff | sign in → open order queue → mark order fulfilled | S10 | staff can advance a real order to fulfilled (mechanism: engineer's call) | owned |

Replace the example rows above with this product's real journeys.

## Deferred journeys

Journeys deliberately out of launch scope, each with the owner's reason. Nothing here may quietly
become a launch requirement without returning to the owner.

- _none yet_

## Open questions

Plausible journeys the Auditor raised that the owner has not yet decided — in or out. Resolve before freeze.

- _none yet_
