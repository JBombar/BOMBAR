# Specification contract

A BOMBAR specification is simultaneously a human work order and a machine-validated execution unit.

## Metadata

The Markdown file begins with embedded JSON:

```markdown
<!-- BOMBAR_SPEC
{
  "id": "BILLING-03",
  "title": "Period-end cancellation",
  "depends_on": ["BILLING-01"],
  "risk": "high",
  "change_mode": "brownfield",
  "touchable_paths": ["src/billing/**", "tests/billing/**"],
  "protected_paths": ["src/billing/ledger/**"],
  "requires_live_probe": true,
  "acceptance_ids": ["AC-BILL-4", "AC-SAFE-2"]
}
-->
```

JSON was chosen for the initial release because Python's standard library can validate it identically on every supported host. The surrounding document remains ordinary Markdown.

## Required sections

- Outcome
- Current State
- Scope
- Out of Scope
- Acceptance Criteria
- Verification
- Definition of Done

Brownfield also requires:

- Compatibility and Non-disruption
- Rollback

## Sizing rule

One specification is one bounded obligation — one green repository state and one reviewable commit — sized as a coherent unit of work the continuing Engineering Partner completes before the next. Split work when:

- it crosses unrelated components;
- it needs more than one architectural hold point;
- meaningful gates cannot pass halfway;
- review would require understanding multiple independent behaviors;
- a failure would make later work ambiguous.

Do not split into horizontal layers that produce no usable behavior unless the foundational invariant genuinely requires it.

## Exact references and drift

Planning should cite real files and symbols, but Builders must re-verify them. A reference is evidence of planning depth, not permission to force today's code into yesterday's line number.

## Touchable paths

Touchable paths are a mechanical epistemic boundary. If correct implementation requires another path, the Builder does not widen the list—it files a change request. The Architect decides whether the plan was incomplete.
