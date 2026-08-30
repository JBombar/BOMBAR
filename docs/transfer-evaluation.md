# Methodology-transfer evaluation

The first product being tested is BOMBAR itself: can another session reproduce the working method without the founder supplying 6,000 hours of tacit coaching?

## Test design

Choose a real but bounded project or feature. Prefer one whose desired behavior you understand well enough to recognize omissions. Use a fresh interactive Architect session with only the generated BOMBAR prompt and repository access.

During the test:

- Explain the product naturally.
- Correct factual misunderstandings, as any owner would.
- Do not teach the agent the BOMBAR methodology or tell it which artifacts/questions it forgot.
- Do not silently repair its specifications yourself.
- Record where you felt compelled to supply missing process expertise.

## Stage A — interactive Architect

Score 0–2 for each:

| Criterion | 0 | 1 | 2 |
|---|---|---|---|
| Intent comprehension | materially wrong | partially correct | owner recognizes the product |
| Question quality | generic/homework | mixed | few consequential questions |
| Terrain investigation | assumes | partial audit | verifies relevant reality |
| Challenge quality | agrees reflexively | occasional pushback | evidence-backed challenge |
| Acceptance quality | vague/unfalsifiable | mostly observable | positive, negative, failure, live |
| Architecture fit | pattern-matched | workable | smallest coherent design |
| Brownfield judgment | ignores preservation | names it | proves compatibility/rollback |
| Owner legibility | overwhelming/opaque | usable | owner understands decisions |

Record exact missed questions or false assumptions. These become playbook improvements.

## Stage B — specifications

Without correcting them, run the continuing Engineering Partner over the generated obligations.

Measure:

- percentage of obligations completed without inventing product decisions;
- blockers raised for genuine product decisions rather than improvised;
- references that had rotted or were false;
- retries caused by spec ambiguity versus implementation error;
- whether every acceptance ID had meaningful coverage;
- whether slice sizing produced reviewable commits;
- whether a blocker surfaced at the correct boundary.

## Stage C — verification

Ask whether the Verifier:

- found material engineering defects no one enumerated;
- inspected the full diff;
- reproduced bite/non-disruption evidence;
- distinguished gate-correct from intent-correct;
- left live claims pending until an outside sensor was used;
- identified any acceptance criterion that could not actually fail.

## Suggested v0.1 success bar

BOMBAR has transferred the method credibly when:

- the Architect score is at least 13/16 with no zero in intent, acceptance, or architecture fit;
- at least 80% of slices execute without requiring an unrecorded owner decision;
- the Engineering Partner never silently changes a governed artifact (the approval digest enforces this);
- every red/no-op/incomplete slice is surfaced rather than marked done;
- independent verification finds no critical requirement absent from the frozen acceptance contract;
- live claims remain unclaimed until externally observed.

Failure is useful. Classify it as a missing prompt heuristic, template weakness, validator gap, runner defect, model-capability limit, or genuinely irreducible owner judgment. Fix the correct layer.
