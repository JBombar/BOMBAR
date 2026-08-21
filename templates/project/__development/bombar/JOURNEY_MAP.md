# Journey Map

The launch-critical journeys — the things a real person must be able to **do**, end to end.

Every launch journey must be **owned** by a specification whose required end-to-end test drives it
from the actor's seat, or **explicitly deferred** by the owner with a reason. A journey whose backend
service exists but that no real user can reach through the UI is *not* owned.

The independent **Spec Auditor** (`prompts/spec-auditor.md`) helps complete this table before freeze
by enumerating the journeys the product needs and interrogating the owner about the gaps. The owner
confirms it. **The plan is not ready while any launch journey below is unowned and not deferred.**

| Journey ID | Actor | End-to-end steps (actor's seat) | Owning spec(s) | Required test | Status |
|---|---|---|---|---|---|
| `J-EXAMPLE-BUY` | customer | browse catalogue → open product → add to cart → checkout → pay → see confirmation | S06, S08, S09 | `test:checkout` | owned |
| `J-EXAMPLE-FULFILL` | staff | sign in → open order queue → mark order fulfilled | S10 | `test:operations` | owned |

Replace the example rows above with this product's real journeys.

## Deferred journeys

Journeys deliberately out of launch scope, each with the owner's reason. Nothing here may quietly
become a launch requirement without returning to the owner.

- _none yet_
