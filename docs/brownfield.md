# Brownfield protocol

Brownfield means a change can damage something that already matters. The relevant unit is the change: a new isolated module in a mature product may be greenfield-like, while connecting it to production is brownfield.

## Begin with evidence

```text
Read-only audit → behavioral baseline → impact map
→ change acceptance → compatibility requirements
→ bounded implementation → regression proof
→ rollback → canary → production verification
```

The Architect identifies:

- existing behavior and users;
- durable data and migration history;
- public/internal interfaces and consumers;
- live integrations and external effects;
- operational workers and deployment reality;
- current gates and their blind spots;
- a restoration point and rollback limitations.

## Required specification additions

Every brownfield specification includes:

- `## Compatibility and Non-disruption`;
- `## Rollback`;
- behavior/data/interface preservation criteria;
- migration classification when data changes;
- proportional negative and failure tests;
- a live canary when offline evidence cannot prove the claim.

BOMBAR's validator enforces the two required sections mechanically. The Architect must make their content meaningful.

## Legacy/unknown

Legacy/unknown is brownfield with inadequate understanding. Treat undocumented behavior as a discovery problem before treating it as a redesign opportunity. Characterization tests and outside-in probes often precede architecture changes.

## Non-disruption is not “the old tests passed”

State which real paths remain inert, which queries or interfaces are unchanged, which data is preserved, and why the change cannot affect live behavior outside its intended scope. Where proof is incomplete, say so and add a canary or hold point.
