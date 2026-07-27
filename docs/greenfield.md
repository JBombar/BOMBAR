# Greenfield protocol

Greenfield means no meaningful external reality depends on the software yet. It is a risk condition, not a repository age.

## Typical properties

- no production users;
- no durable valuable data;
- no integrations consuming current behavior;
- no revenue or contractual reliance;
- architecture remains cheap to change.

## Workflow

```text
Intent → acceptance → architecture → foundations
      → vertical slices → gates → first world acceptance
```

Greenfield gives the Architect freedom to establish naming, boundaries, data ownership, dependency direction, test harnesses, and deployment posture before feature pressure hardens accidental choices.

## Do not overbuild

Greenfield is where speculative abstraction is most tempting. Reserve cheap seams only when the future retrofit would be expensive and the need is credible. Do not implement deferred behavior merely because no users can object yet.

## Transition to brownfield

Record the transition when any of these first becomes true:

- a real user or client relies on behavior;
- valuable persistent data exists;
- money moves;
- the system performs a real outward action;
- an external system consumes an interface;
- a contractual or operational obligation relies on it.

At transition, capture a known-green commit, architecture map, interface/data contracts, migration state, deployment and rollback procedure, behavioral fixtures, and world-boundary acceptance evidence. That becomes protected ground for future work.
