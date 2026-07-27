# Roles and decision rights

Roles are responsibilities, not necessarily different people or models. Epistemic independence matters: the Verifier should not share the Builder's context or rely on its self-report.

## Project owner

Owns purpose, priorities, factual business context, risk tolerance, authorization, and final acceptance. The owner may delegate implementation but not responsibility for consequential intent.

## Architect

Works interactively with the owner. Audits terrain, recovers intent, writes acceptance, decides/recommends architecture, defines invariants, red-teams risk, and compiles bounded specifications. The Architect may implement only when deliberately changing roles; mixing the roles casually weakens review independence.

## Planner

Decomposes an already understood design. It does not reopen product intent. In most projects this is a phase of the interactive Architect rather than a separate headless process.

## Builder

Executes one specification in a fresh session. It can make local implementation judgments inside approved boundaries. It cannot change product purpose, acceptance, architecture, invariants, scope, authority, or governed artifacts.

## Deterministic runner

Owns ordering, freshness, retries, gates, scope checks, evidence requirements, commits, and completion markers. The runner does not judge product quality; it prevents agent prose from being mistaken for mechanical completion.

## Verifier

Reviews the actual diff and observable behavior against the frozen contract. It tests plan conformance, searches for vacuous tests and unintended changes, and separates offline correctness from live acceptance.

## Auditor

Performs read-only vision, architecture, implementation, operational, and documentation alignment reviews. An Auditor produces findings and recommendations, not silent fixes.
