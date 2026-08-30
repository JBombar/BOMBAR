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
One continuing Engineering Partner under deterministic gates
        ↓
Fresh independent engineering review
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

The Engineering Partner should not need the owner's accumulated intuition. The Architecture Partner compiles the relevant part of that intuition into:

- explicit outcomes and non-goals;
- architecture boundaries;
- invariants;
- acceptance criteria;
- tests and world sensors;
- stop conditions.

The durable product intelligence lives in the structure, so the work survives a change of engineer — but within that structure the Engineering Partner's own engineering intelligence is trusted and relied upon, not designed around.

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

When an approved obligation cannot be completed without new authority or changed product intent, stopping is correct. A headless Engineering Partner that asks the owner questions it could responsibly resolve itself, invents an answer to a genuine product decision, or silently changes approved product truth has crossed the autonomy boundary. Touching whatever files competent implementation needs is not crossing it.

## Postmortems grow the surface

Every escaped defect should add a durable prevention mechanism proportional to the lesson — but prefer the smallest one that works, and prefer strengthening engineering judgment and independent review over encoding ordinary competence as an ever-growing rule catalogue. Sometimes the right fix is an invariant, test, negative probe, or clearer artifact; sometimes it is better framing that lets the Engineering Partner catch the class itself. Fixing code without strengthening the method guarantees recurrence.
