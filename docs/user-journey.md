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

- selecting dependency-ready slices;
- starting fresh Builder contexts;
- running gates;
- checking scope and protected paths;
- requiring evidence and commits;
- preserving resumability;
- assembling independent review material.

Automation does not approve the product, reinterpret the acceptance contract, authorize live actions, or decide a new architecture.

## A typical session

An owner says:

> Add subscription billing. Customers should upgrade, downgrade, and cancel. We use Stripe.

The Architect audits the existing account and payment model, then asks only consequential questions: cancellation timing, proration, currencies, existing customer migration, webhook authority, failed-payment behavior, and what a real acceptance probe should demonstrate.

The owner approves the resulting behavior and architecture. Builders receive slices such as customer model, webhook idempotency, period-end cancellation, UI, and live test-mode canary. They do not receive the original ambiguous sentence and improvise the rest.

## Where the owner re-enters

The owner returns when:

- the Architect needs a genuine business or authority decision;
- a Builder files a change request outside approved scope;
- a high-risk hold point is reached;
- independent verification finds an intent ambiguity;
- a live or paid action requires authorization;
- final semantic acceptance is due.

Everything else is a candidate for bounded automation.
