# The BOMBAR method

BOMBAR treats agentic software development as a controlled translation chain rather than one heroic prompt.

## The chain

```text
Horizon / business need
        ↓
Interactive intent recovery
        ↓
Falsifiable acceptance contract
        ↓
Architecture + invariants + ADRs
        ↓
Adversarial review where risk warrants it
        ↓
Dependency-ordered bounded specifications
        ↓
Content-addressed owner approval
        ↓
Fresh Builder sessions under deterministic gates
        ↓
Independent verification
        ↓
Authorized world-boundary acceptance
        ↓
Escaped defects strengthen permanent rails
```

## Freeze the right layers

- **Intent and direction** are stable enough to guide the work.
- **Invariants** are binding until deliberately changed.
- **Significant decisions** retain their rationale in ADRs.
- **Acceptance** is frozen before implementation so success cannot drift toward whatever was built.
- **Sequence** remains adaptable. The Architect may reslice or reorder through a new approved plan when reality changes.

This preserves agility without making direction implicit.

## Compile vision into rails

Builders should not need the owner's accumulated intuition. The interactive Architect compiles the relevant part of that intuition into:

- explicit outcomes and non-goals;
- architecture boundaries;
- invariants;
- acceptance criteria;
- touchable and protected paths;
- tests and world sensors;
- stop conditions.

The builder is interchangeable because the durable intelligence lives in the structure around it.

## Three kinds of correctness

**Gate-correct** means configured tests and build checks pass.

**Intent-correct** means the implementation does what the owner and Architect agreed—not merely what the ticket literally happened to say.

**World-correct** means the promised effect occurs outside the system. An email ledger cannot prove delivery; a deployment ledger cannot prove an external user can reach the service.

Each layer needs its own verifier.

## Sequence by irreversibility

Capture facts and define one-way-door constraints before building reversible presentation or convenience machinery. In brownfield work, data compatibility, authority, external effects, migrations, and rollback precede UI polish.

## Repeat before abstracting

Do not build a universal inner platform from one example. Implement a pattern concretely, observe it two or three times, then extract the shared mechanism. BOMBAR itself follows this rule: its public abstractions come from repeated build loops, not a speculative orchestration diagram.

## A blocker is a control result

When an approved specification cannot be completed without new authority or changed intent, stopping is correct. A headless Builder that asks the owner questions, invents an answer, or silently expands scope has crossed the autonomy boundary.

## Postmortems grow the surface

Every escaped defect should add a durable prevention mechanism proportional to the lesson: an invariant, test, negative probe, vital sign, scope guard, or clearer artifact. Fixing code without strengthening the method guarantees recurrence across disposable agents.
