# User journey

## What the owner supplies

The owner speaks in ordinary product language:

- the situation and problem;
- the people affected;
- what should become possible;
- constraints and unacceptable outcomes;
- real examples and corrections;
- authority for consequential actions.

The owner is not expected to author architecture maps or implementation specifications manually.

## What the Architect supplies

The interactive Architect discovers repository facts, turns ambiguous intent into a shared product model, recommends technical choices, exposes trade-offs, and writes the durable artifact set. It returns to the owner for corrections until the owner recognizes the intended product.

## What automation supplies

After approval, automation performs the long mechanical work:

- working through obligations in dependency order;
- continuing one Engineering Partner across them (fresh only when continuation is impossible);
- running gates and landing green commits;
- protecting governed product truth via the approval digest;
- recording evidence, progress memory, and telemetry;
- preserving resumability;
- assembling fresh, independent review material.

Automation does not approve the product, reinterpret the acceptance contract, authorize live actions, or decide a new architecture.

## A typical session

An owner says:

> Add subscription billing. Customers should upgrade, downgrade, and cancel. We use Stripe.

The Architect audits the existing account and payment model, then asks only consequential questions: cancellation timing, proration, currencies, existing customer migration, webhook authority, failed-payment behavior, and what a real acceptance probe should demonstrate.

The owner approves the resulting behavior and architecture. The first slice is a thin end-to-end walking skeleton — a real customer upgrades their plan through the actual UI and Stripe test-mode, proven by a product-level test that drives that exact path (mechanism proportional to the product). Later slices *thicken* that working thread — downgrade, period-end cancellation, proration, failed-payment handling, webhook idempotency, existing-customer migration, live test-mode canary — each verified proportionally to what it actually changes, not by re-running a full browser suite on every slice. Note what this is *not*: a pile of layer slices ("customer model," then "webhook," then "UI") that are each individually green but never add up to a customer who can actually change their plan. Builders do not receive the original ambiguous sentence and improvise the rest.

## Where the owner re-enters

The owner returns when:

- the Architect needs a genuine business or authority decision;
- the Engineering Partner files a change request for a genuine product decision;
- a high-risk hold point is reached;
- independent verification finds an intent ambiguity;
- a live or paid action requires authorization;
- final semantic acceptance is due.

Everything else is a candidate for bounded automation.

## Guaranteeing the journeys are complete

The owner cannot always name every journey up front — so before freeze an independent **Spec Auditor** (`prompts/spec-auditor.md`) enumerates the journeys a product of this type normally needs, diffs them against the specifications, and interrogates the owner (with proposed defaults) about anything missing or unreachable. The result is the **Journey Map** (`__development/bombar/JOURNEY_MAP.md`): every launch journey owned by a spec that delivers it with appropriate product-level verification (the mechanism an engineering call, not a mandatory browser E2E), explicitly deferred, or recorded as an open scope question for the owner. A plausible journey the Auditor discovers is a scope decision for the owner, not an automatic requirement. The plan does not freeze while a contradiction with approved product truth remains. This is the check whose absence lets a structurally green plan ship a product no one can actually use.
