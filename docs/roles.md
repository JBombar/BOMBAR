# Roles and decision rights

Roles are responsibilities, not necessarily different people or models. Two kinds of
independence matter and are treated differently:

- **Continuity** for the implementer — one Engineering Partner normally carries its
  accumulated understanding across obligations, because rich cross-subsystem context
  improves engineering quality.
- **Fresh independence** for review — the Independent Engineering Reviewer must not
  share the Engineering Partner's context or rely on its self-report.

## Project owner

Owns purpose, priorities, factual business context, risk tolerance, authorization,
and final acceptance. The owner may delegate implementation but not responsibility
for consequential intent.

## Architecture Partner

Works interactively with the owner. Audits terrain, recovers intent, writes
acceptance, decides/recommends architecture, defines invariants (functional **and**
operational/liveness where load-bearing), red-teams risk, and compiles the bounded
obligations. Its job is to compile the *product reality that must remain true*
exhaustively — then trust the Engineering Partner to determine how to make it true.
It implements only when deliberately changing roles.

## Engineering Partner

The continuing engineer for the product. It exercises full engineering judgment and
takes responsibility for the technical quality, coherence, reliability, and
maintainability of the software, across successive obligations, normally in one
warm session. It has wide engineering agency **inside approved product truth**: it
may make any sound implementation decision and touch any technically necessary path,
but it cannot change product purpose, acceptance, architecture, invariants, or
governed artifacts — those are owner/Architecture-Partner decisions and, if needed,
blockers. It grounds load-bearing external-system decisions in current documentation
or an empirical probe, and keeps `progress.md` as compressed engineering memory.

## Deterministic runner

Owns ordering, dependency gating, the approval digest, per-obligation gates,
commits, completion markers, session continuity, and telemetry. It does not judge
product quality; it prevents agent prose from being mistaken for mechanical
completion, and it records objective facts about the run. It does not hard-abort a
build over a touched path — product truth is protected by the approval digest.

## Independent Engineering Reviewer

A fresh, independent senior engineer. Given the product intent, architecture,
invariants, the real repository and diff, and observable behavior — but **not** the
Engineering Partner's context — it asks: *is this coherent, production-quality
software that does what the product is supposed to do?* It verifies acceptance and
invariants, and has full authority to find material engineering defects no one
enumerated (reliability, performance, unbounded IO, concurrency, integration,
security, incomplete/unreachable behavior). It produces ranked findings and a
verdict; it does not implement and does not grant final acceptance.

## Spec Auditor

An independent completeness reviewer, run in a fresh session before freeze. Given
the owner's intent (brief, acceptance) and the proposed obligations, it enumerates
the full set of user journeys the product needs — from domain knowledge, not only
what the owner stated — and finds every human outcome that would be missing or
unreachable if the obligations were implemented literally. It interrogates the owner
about gaps with proposed defaults, produces the Journey Map, and reviews the slicing
(flagging fragmented, oversized, or horizontal-layer specs). It probes WHAT users
must do, never HOW to build it, and it neither freezes nor implements. Prompt:
`prompts/spec-auditor.md`.

## Auditor

Performs read-only vision, architecture, implementation, operational, and
documentation alignment reviews. An Auditor produces findings and recommendations,
not silent fixes.
