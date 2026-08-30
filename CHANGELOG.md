# Changelog

All notable changes to BOMBAR are documented here.

## [0.4.2] — 2026-08-30

Empirical fix from the first MimiBakeryB2B dogfood. The fresh-context Spec Auditor worked well — invoked as a genuinely independent sub-agent, it found real omissions (result curation, whole-run failure/recovery, an orphaned needs-review state, zero-result behavior, run cancellation, account provisioning) that the Architecture Partner had missed. But its raw output exposed two framework problems, both fixed here by recalibrating the Auditor's mandate — no new taxonomy, matrix, scoring, or orchestration.

### Changed — Auditor authority calibration (challenge, don't legislate)

The Auditor was promoting discovered-but-plausible journeys (self-service password reset, user-facing data deletion, operator-editable cost cap) straight to **critical launch requirements**. It now distinguishes, by confidence relative to *approved product truth*: a **contradiction/incompleteness** with what the brief and acceptance already commit to (must be resolved before freeze); a **strongly-implied gap** (needs an Owner decision); or a **plausible additional journey** (an open scope question with a proposed default — never an automatic requirement). Discovering a reasonable feature does not grant authority to require it; the Architecture Partner and Owner decide scope. The Auditor surfaces uncertainty; it does not set scope.

### Changed — Auditor proportional verification (no E2E-everywhere)

The Auditor was assigning a required browser end-to-end test to nearly every discovered journey and gating freeze on it — the same "important → therefore E2E → therefore run it every slice" pathology removed elsewhere in v0.4. It now names *what outcome needs credible proof* and explicitly does **not** prescribe the mechanism; verification type and cadence are the Architecture/Engineering Partners' proportional judgment (risk, affected behavior, information value, cost). Important journeys still get appropriate product-level verification. Fixed at the semantic source: `prompts/spec-auditor.md`, the `JOURNEY_MAP.md` template (the "Required test" column is now "outcome that needs credible proof"), `prompts/architect.md`, `docs/roles.md`, `docs/user-journey.md`.

### Changed — fresh Auditor handoff

The Architecture Partner now runs the Auditor as a **genuinely fresh independent sub-agent** where its runtime supports one (e.g. a Claude Code subagent that does not inherit the conversation) — the intended low-friction path proven in the dogfood — falling back to an Owner-run standalone session otherwise. One independent review boundary, not an agent society.

### Added

- Guardrail test `test_spec_auditor_challenges_without_legislating_or_defaulting_to_e2e`.

### Migration

- No mechanical migration; the Journey Map is not validator-enforced. For an existing v0.4.x project, re-read the Auditor's findings under the calibrated mandate: downgrade any "plausible feature" it marked critical to an Owner scope decision, and replace any blanket per-journey browser-E2E requirement with proportional verification.

## [0.4.1] — 2026-08-30

Semantic migration. v0.4.0 moved the philosophy into the prompts and runtime, but the machinery that *manufactures* specifications still taught the old bounded-executor model — so a well-behaved Architecture Partner, reading the templates/schema/validator "so the artifacts pass," re-instantiated exactly the narrow-executor semantics we set out to remove. This deletes those remnants. It is a net removal (−247/+116), not a new layer.

### Removed — obsolete bounded-executor machinery

- **Spec metadata `touchable_paths` / `protected_paths`.** A specification no longer pre-authorizes which implementation files the Engineering Partner may touch. Dropped from the schema, the validator (`REQUIRED_META`), the spec template, the examples, the planner, and the docs. Engineering agency inside approved product truth is not granted file-by-file.
- **Profile `execution.protected_paths` and the scope-enforcement subsystem** (`check_scope`, `path_matches`, `changed_paths`, the `check-scope` command). Governed product truth is protected solely by the content-addressed approval digest — the one real boundary.
- **The spec template's "Builder pointer"** ("Implement exactly this slice… commit once green, and stop") and the required `Scope` / `Out of Scope` / `Current State` / `Definition of Done` sections. Required sections are now just **Outcome, Acceptance criteria, Verification** (brownfield adds Compatibility/Rollback).

### Changed

- Spec template, examples (LINK-01/02, WEBHOOK-01), planner, `docs/specifications.md`, methodology, anti-patterns, transfer-evaluation, user-journey, agent-adapters, architect-playbook, and the boundary diagram reframed: a specification is the **next product obligation** in a continuing engineering mission, with wide engineering agency inside approved product truth — not a cage on files.
- README corrected: it had advertised removed guarantees ("scope enforcement / protected paths cannot be touched", "fresh-session-per-spec runner", "one session per slice").

### Added

- Guardrail test `test_specs_are_obligations_not_bounded_executors` — fails if scope metadata, the scope-enforcement functions, or "implement exactly / commit and stop / disposable" framing ever return to the spec machinery.

### Migration

- v0.4.0-generated projects keep validating unchanged — leftover `touchable_paths`/`protected_paths` in existing specs are now simply ignored, not enforced. To fully adopt the model, drop those fields and any "implement exactly / Scope / Out of Scope" body framing from spec files, or regenerate them from the new template. No runtime break.

## [0.4.0] — 2026-08-29

The Engineering Partner release: stop framing the implementer as a disposable executor and start treating it as a trusted, continuing engineer responsible for the whole product — then observe, with lightweight telemetry, what continuity and responsibility actually do. Motivated by a forensic review of a real project where an N+1 query fan-out and a Supabase/postgres.js production freeze escaped a framework strong at proving *specified* behavior but silent on *engineering fitness* and *current external-system behavior*. The bet: better framing, continuity, information, and independent feedback should prevent such defects at the source — with cheap sensors and a fresh reviewer as defense-in-depth, not as a growing rule catalogue.

### Changed — participant model: from disposable executor to Engineering Partner

- **One Engineering Partner continues across all obligations**, normally in a single warm session, carrying accumulated product/repository understanding forward. The runner drives id-addressed sessions (Claude Code `--session-id`/`--resume`), not per-spec cold starts. A new session is created only when continuation is impossible — never because an obligation finished, a subsystem changed, or context grew. Deterministic/topological obligation ordering is preserved; there is no LLM orchestrator.
- **Rewritten role prompts and contract.** The implementer prompt (`prompts/builder.md`) is now an Engineering Partner with wide engineering agency inside approved product truth, an explicit responsibility for quality/coherence/reliability/maintainability, and encouragement to raise and resolve its own engineering questions and to ground load-bearing external-system decisions in current docs or an empirical probe. The reviewer (`prompts/verifier.md`) is now a fresh **Independent Engineering Reviewer** whose question is "is this coherent, production-quality software?" — with authority to find material defects no one enumerated. The Architect is the **Architecture Partner**, and now derives operational/liveness invariants where load-bearing (bounded request-path IO, work that must not scale pathologically) as properties, never as a rule catalogue.
- **Removed lingering "don't think beyond the ticket" framing** ("disposable session", "only that specification", "execution, not product redesign", "fresh session").

### Added

- **Lightweight native-first telemetry** (`scripts/lib/telemetry.py`): an append-only `.bombar/runtime/run.jsonl` event stream (run/session/obligation/gate/retry/blocker events) enriched with native structured output from the runtime (Claude Code stream-json: session id, tokens, cache, cost, duration, turns, status; Codex `--json` best-effort), plus a concise end-of-run summary. No context score, no kill threshold, no dashboards — capture first, interpret after real runs.
- **Minimal shared state.** `progress.md` (compressed engineering memory for whoever continues) and mechanical session/runtime state under `.bombar/runtime/` (`run.jsonl`, `sessions.json`). `BLOCKERS.md` unchanged.
- **Tiered gate cadence.** The per-obligation `gates` stay fast; an optional `execution.final_gates` runs the stronger integration/E2E/product-level tier once after the chain. The strong product-level judgment is the fresh Independent Engineering Reviewer.
- **Runtime abstraction** (`adapters/CONTRACT.md`): start / resume-by-id / structured-result. Claude Code is the verified reference (id-addressed sessions, stream-json telemetry, empirically confirmed); Codex is a documented best-effort adapter (`resume --last`, `--json`) pending validation on an installed CLI.

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
