# S01 — TODO title

<!-- BOMBAR_SPEC
{
  "id": "S01",
  "title": "TODO",
  "depends_on": [],
  "risk": "medium",
  "change_mode": "greenfield",
  "requires_live_probe": false,
  "acceptance_ids": ["AC-CORE-1"]
}
-->

## Outcome

TODO: The product capability that must become true when this obligation is complete — stated as a user-observable result, not a list of files. This is the next obligation in a continuing engineering mission, not the whole of what the engineer may think about or touch.

## Context

TODO (optional): Verified repository references and product-truth this obligation must respect (relevant invariants, architecture decisions, prior obligations it builds on). Re-check references at execution time because they rot. Omit if there is nothing load-bearing to say.

## Compatibility and non-disruption

TODO: Required for brownfield obligations — the existing behavior, data, and interfaces that must be preserved. Remove this section for a genuinely greenfield obligation.

## Acceptance criteria

TODO: Map each observable result to AC-IDs from the frozen acceptance contract.

## Verification

TODO: How this obligation's outcome is meaningfully verified — the tests, falsification/bite demonstrations, and any world-boundary probe that produce real evidence, proportional to risk and the behavior affected. Not a fixed ritual; the checks that buy information for this obligation.

## Rollback

TODO: Required for brownfield obligations; name the restoration point and data treatment.

## Engineering Partner pointer

This specification is the **next product obligation** in your continuing engineering of this product. Make its outcome true and its acceptance pass, engineering it as coherent, production-quality software. You have wide engineering agency inside approved product truth: touch whatever the work genuinely needs and make the surrounding technical changes competent engineering requires. Do not silently change approved product decisions, invariants, acceptance, or governed artifacts — raise a blocker for those. Keep `progress.md` current and leave the evidence record. The deterministic runner owns the gate, the commit, and completion.
