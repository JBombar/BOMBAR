# Architect playbook

The templates encode shape. This playbook encodes recurring judgment.

## Ask versus discover

Discover repository facts yourself. Ask the owner about purpose, business reality, authority, priorities, risk tolerance, and facts unavailable in the repository. Do not ask the owner to inventory code you can inspect.

## Decide versus recommend versus defer

- Decide local reversible technical details inside an accepted architecture.
- Recommend consequential choices with a concrete default and trade-off.
- Ask the owner about business meaning, irreversible commitments, legal posture, spend, production actions, and meaningful scope changes.
- Defer capabilities that do not pay current rent, while reserving only cheap seams whose retrofit cost is credible.

## Invariant versus preference

An invariant protects safety, integrity, architectural coherence, legal/financial correctness, or honest outcome. Naming style and minor implementation taste are conventions, not invariants.

## When to write an ADR

Write an ADR when a choice:

- crosses subsystem boundaries;
- constrains future architecture materially;
- reverses an earlier decision;
- changes authority or external-effect posture;
- chooses among credible alternatives future maintainers will question.

Record context, decision, consequences, rejected alternatives, status, and links. Supersede old ADRs; do not erase history.

## When to red-team

Red-team before specifications when the design touches production mutation, money, identity/auth, secrets, irreversible data migration, autonomous outward action, client obligations, or a large new orchestration substrate. Require concrete failure scenarios and mechanisms, not generic “consider security” advice.

## When a slice is too large

Split when one obligation cannot be a coherent unit of work, gates cannot be honestly green at the end, the diff would hide multiple review subjects, or the obligation contains separate risk decisions. Do not split merely to maximize obligation count — the continuing Engineering Partner carries context across them, so over-splitting only adds ceremony.

## When external verification is mandatory

Require it whenever the claim crosses a membrane: delivery, payment, deployment, search/source emptiness, provider permission, DNS, browser behavior, or third-party state. The system's own ledger is evidence of its belief, not of the world.

## The unstated-tail audit

For each capability, ask what the owner implicitly expects after the happy-path sentence:

- partial failure;
- retries and idempotency;
- existing data;
- empty/error/loading states;
- cancellation and recovery;
- authorization and auditability;
- human-visible output;
- operation after restart;
- cost and rate limits;
- what happens when a dependency lies or disappears.

Turn relevant answers into acceptance, invariants, or explicit risk acceptance.
