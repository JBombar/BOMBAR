# Specification contract

A BOMBAR specification is the **next required product obligation** in a continuing engineering mission. It is simultaneously a human work order and a machine-validated unit — but it is *not* the boundary of what the Engineering Partner may think about or touch. Specs preserve obligations; the Engineering Partner engineers the product.

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
  "requires_live_probe": true,
  "acceptance_ids": ["AC-BILL-4", "AC-SAFE-2"]
}
-->
```

The metadata carries only what the deterministic runner needs to sequence and account for obligations: identity, dependencies, risk, change mode, whether a live probe is required, and which acceptance criteria the obligation covers. It deliberately does **not** declare which implementation files may be touched. JSON was chosen because Python's standard library validates it identically on every supported host; the surrounding document is ordinary Markdown.

## Required sections

- Outcome — the product capability that must become true (a user-observable result).
- Acceptance criteria — the AC-IDs this obligation covers.
- Verification — how the outcome is meaningfully verified, proportional to risk and the behavior affected.

Brownfield also requires:

- Compatibility and Non-disruption
- Rollback

Optional context (verified references, relevant invariants, deferrals to later obligations) is welcome where it is load-bearing; it is not a required ritual.

## Sizing rule

One specification is one bounded obligation — one green repository state and one reviewable commit — sized as a coherent unit of work the continuing Engineering Partner completes before the next. Split work when:

- it crosses unrelated components;
- it needs more than one architectural hold point;
- meaningful gates cannot pass halfway;
- review would require understanding multiple independent behaviors;
- a failure would make later work ambiguous.

Do not split into horizontal layers that produce no usable behavior unless the foundational invariant genuinely requires it.

## Exact references and drift

Planning may cite real files and symbols, but the Engineering Partner re-verifies them at execution time. A reference is evidence of planning depth, not permission to force today's code into yesterday's line number.

## What a spec constrains, and what it does not

A spec constrains **product truth**: the outcome, the acceptance it must satisfy, the invariants and architectural decisions it must respect, and (for brownfield) what must be preserved. Those are owner/Architecture-Partner decisions; the Engineering Partner does not silently rewrite them — it raises a blocker.

A spec does **not** constrain **engineering agency**: which files or modules to touch, what to refactor, what surrounding technical work competent implementation requires. If good engineering of the obligation needs a shared helper, a new module, a migration, or a fix in an adjacent area consistent with approved product intent, the Engineering Partner just does it. Protect product truth; do not pre-authorize implementation file-by-file.
