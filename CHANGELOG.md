# Changelog

All notable changes to BOMBAR are documented here.

## [0.3.0] — 2026-08-21

Keep the harness thin and the sessions warm: stop paying a cold-start tax on retries, and let the reviewer that already reads the whole plan also judge how it's sliced.

### Added

- **Warm-resume retries.** When a builder's work fails the runner's independent verification gate, the **first retry now resumes the same session** (warm — it already knows the codebase and its own prior work) instead of spawning a cold one that must rediscover everything. A flaky timeout or a small fix is handled in minutes, the way an interactive session would, rather than in a fresh ~30-minute session. Best-effort and portable: the claude-code adapter continues the session (`--continue` on `BOMBAR_RESUME=1`); adapters without session continuation ignore it and run the self-contained retry prompt fresh. Further retries run fresh — the "fresh eyes" escalation for a genuinely wrong approach.
- **Spec Auditor also reviews slicing.** In the same completeness pass, the auditor flags decomposition problems — a journey fragmented across too many small specs (recommend merge), an oversized/mixed spec (recommend split), or a horizontal-layer spec with no reachable outcome (recommend re-slicing vertically) — as proposals for the Architect. Good slicing at plan time is what makes one-session-per-slice the right size, and it removes the need for any runtime spec-combining machinery.

## [0.2.0] — 2026-08-21

Two lessons from running real projects through BOMBAR: the framework was hobbling capable models with ceremony that protected nothing, and it validated the *structure* of a plan without ever checking whether the plan delivered a *usable product*.

### Changed — trust the models, guard only the real boundaries

- Removed scope / protected-path enforcement and the evidence-heading gate. A green, gate-passing, committed build is never discarded over a touched path or evidence formatting. Guardrails now sit only at real boundaries: authority, external effects, governed artifacts, and the configured gate.
- Broadened Builder autonomy — Builders may touch any sensible application path and do the connective work a slice needs; they stop only for genuinely unsafe or out-of-authority actions (business policy, invariant change, destructive migration, live/paid/production effects).
- Raised defaults: `max_retries` 1 → 2, adapter `max_turns` 300 → 600.

### Added — semantic completeness (stop shipping green-but-unusable products)

- Journey-first slicing rule in the Architect: at least one slice must be the end-to-end path a real user takes to get the core value, built early as a walking skeleton with a required test that drives it from the actor's seat.
- **Spec Auditor** (`prompts/spec-auditor.md`): an independent, fresh-session completeness review before freeze. It enumerates the journeys a product of this type needs, diffs them against the specifications, and interrogates the owner about gaps with proposed defaults — catching human outcomes that would otherwise be missing or unreachable.
- **Journey Map** governed artifact (`__development/bombar/JOURNEY_MAP.md`): every launch journey owned by a spec with a required end-to-end test, or explicitly deferred by the owner.

## [0.1.0] — 2026-07-27

### Added

- Interactive Architect preparation and role contract.
- Greenfield and brownfield project lifecycle model.
- Machine-validated implementation specification format.
- Content-addressed owner approval gate.
- Fresh-session-per-spec autonomous Bash runner.
- Dependency, protected-path, no-op, gate, evidence, commit, and retry controls.
- Independent verification-pack preparation.
- Provider-neutral agent adapter contract.
- Hermetic end-to-end fixture tests.
