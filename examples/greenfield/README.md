# Greenfield example — link-check report

This sanitized example shows the artifact shape for a small new CLI that reads a Markdown file, checks links through an injected transport, and writes a JSON report. No user, production data, or external consumer exists yet.

The example is intentionally small enough to inspect in minutes. It demonstrates that BOMBAR does not require enterprise ceremony for every project:

- three acceptance criteria;
- one invariant;
- two vertical slices;
- no rollback section because both slices are genuinely greenfield;
- live network behavior deferred to an awake canary.

See `ACCEPTANCE.md`, `PLAN.md`, and `specs/`.
