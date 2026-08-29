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

The owner approves the resulting behavior and architecture. The first slice is a thin end-to-end walking skeleton — a real customer upgrades their plan through the actual UI and Stripe test-mode, proven by a required test that drives that exact path from the customer's seat. Later slices *thicken* that working thread — downgrade, period-end cancellation, proration, failed-payment handling, webhook idempotency, existing-customer migration, live test-mode canary — each keeping the journey test green. Note what this is *not*: a pile of layer slices ("customer model," then "webhook," then "UI") that are each individually green but never add up to a customer who can actually change their plan. Builders do not receive the original ambiguous sentence and improvise the rest.

## Where the owner re-enters

The owner returns when:

- the Architect needs a genuine business or authority decision;
- a Builder files a change request outside approved scope;
- a high-risk hold point is reached;
- independent verification finds an intent ambiguity;
- a live or paid action requires authorization;
- final semantic acceptance is due.

Everything else is a candidate for bounded automation.

## Guaranteeing the journeys are complete

The owner cannot always name every journey up front — so before freeze an independent **Spec Auditor** (`prompts/spec-auditor.md`) enumerates the journeys a product of this type normally needs, diffs them against the specifications, and interrogates the owner (with proposed defaults) about anything missing or unreachable. The result is the **Journey Map** (`__development/bombar/JOURNEY_MAP.md`): every launch journey owned by a spec with a required end-to-end test that drives it from the actor's seat, or explicitly deferred. The plan does not freeze while a launch journey is unowned. This is the check whose absence lets a structurally green plan ship a product no one can actually use.
