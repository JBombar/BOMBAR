# Anti-patterns and scars

## The heroic prompt

Giving one agent an ambiguous product request, a large repository, and permission to “finish everything” collapses intent, architecture, implementation, and verification into one unreviewable context.

## Autonomous architecture theater

A headless session can produce impressive documents without establishing shared understanding. Foundational architecture is interactive because the owner must recognize and correct the model before it becomes rails.

## Green means real

Tests can certify a simulation. A system may report `sent` while using a fake transport, or report an empty source after swallowing an authentication failure. Pair external actions with external sensors.

## Builder-authored success criteria

If acceptance changes after implementation to describe what was built, the project cannot fail. Freeze acceptance first and require a new owner approval when it changes.

## Silent scope expansion

“I noticed this adjacent improvement” is not authority. Builders either remain within the approved slice or file a change request.

## Always-on context landfill

Giving every session the complete vision, research library, roadmap, and history dilutes the slice. Use progressive disclosure: stable contract, relevant design, assigned specification, local terrain.

## Documentation as executable misinformation

In an agent-built system, stale canonical documents are worse than missing documents because fresh sessions trust them. Keep status and supersession explicit. Reconcile documentation when behavior changes.

## Fake independence

A “Verifier” that receives the Builder transcript or reviews only the Builder's summary is anchored by the author. Independence requires the actual diff, frozen criteria, bounded context, and a fresh session.

## Infinite repair autonomy

Repeated retries can burn cost while degrading the tree. BOMBAR bounds fresh retries, preserves evidence, and halts the chain.

## Premature framework construction

Do not generalize a one-off workflow into a DSL before repeated implementations reveal the stable shape. Profiles are data for demonstrated variation, not permission to invent an inner platform.

## Human backstop nobody can sustain

A safety design that assumes an always-attentive operator is not safe. Automate objective checks, surface hold points clearly, and reserve the human for genuine judgment and authorization.
