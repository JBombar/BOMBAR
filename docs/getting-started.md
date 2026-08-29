# Getting started

This guide takes a repository from uninitialized to ready for its first bounded Builder. Do not skip the interactive architecture stage.

## 1. Check the host

```bash
cd /path/to/BOMBAR
bash bin/bombar.sh doctor
```

BOMBAR v0.1 requires Git, Bash, and Python 3.11+. On Windows, use WSL or Git Bash and ensure the same Git repository is visible to the agent CLI.

## 2. Initialize a target repository

```bash
bash bin/bombar.sh init /path/to/project
cd /path/to/project
git add -A
git commit -m "chore: initialize BOMBAR control kit"
```

For an empty directory, `init` also creates Git. It detects an empty project as greenfield and an existing project conservatively as `legacy_unknown`; the interactive Architect corrects that classification after inspection.

Initialization is refusal-safe: it will not overwrite an existing `.bombar/` or `__development/bombar/` installation.

## 3. Start the interactive Architect

```bash
bash .bombar/prepare-architect.sh
```

Open the generated `.bombar/context/ARCHITECT_SESSION.md` in a new **interactive** frontier-agent session. Give the agent the repository and talk naturally. You do not need to learn the artifact format before explaining the product.

The Architect should:

1. recover and restate your intent;
2. audit the relevant terrain;
3. classify greenfield/brownfield risk;
4. write acceptance before final architecture;
5. propose and discuss the architecture;
6. red-team consequential choices;
7. write bounded dependency-ordered specifications;
8. walk you through the result.

Do not approve because the documents look professional. Approve when you recognize the intended product, understand the important trade-offs, and see no unresolved ambiguity a Builder would have to invent.

## 4. Configure real gates and an agent adapter

Edit `.bombar/project-profile.json` during the interactive architecture session.

Example Node gates:

```json
"gates": [
  "npm run typecheck",
  "npm run lint",
  "npm test",
  "npm run build"
]
```

Example Python gates:

```json
"gates": [
  "ruff check .",
  "mypy src",
  "pytest"
]
```

Select an explicit adapter. The generic default refuses to run. Review [Agent adapters](agent-adapters.md) before choosing one.

## 5. Validate, review, freeze

```bash
bash .bombar/validate-plan.sh
```

This checks completeness, placeholders, specification metadata, acceptance coverage, dependency cycles, brownfield sections, and profile configuration. It does not approve anything.

Commit the reviewed artifacts, then perform the explicit owner act:

```bash
git add BOMBAR.md .bombar/project-profile.json __development/bombar
git commit -m "docs: approve BOMBAR architecture and implementation plan"
bash .bombar/validate-plan.sh --freeze --approved-by "Your Name"
git add __development/bombar/APPROVAL.json
git commit -m "docs: freeze owner approval for BOMBAR plan"
```

The approval file records SHA-256 digests over every governed artifact. Any later edit locks autonomous execution until you review and freeze again.

## 6. Create an implementation branch

```bash
git switch -c feature/bombar-implementation
```

The default profile refuses to run Builders on the default branch.

## 7. Execute approved slices

```bash
bash .bombar/run_bombar.sh
```

The runner first requires a clean tree and green baseline gates. It then works through the obligations in dependency order with **one continuing Engineering Partner** (id-addressed session, resumed across obligations and retries). It owns gates, commits, completion markers, approval-digest integrity, and telemetry. Watch `.bombar/runtime/run.jsonl` and the end-of-run summary for objective run facts.

Monitor:

```bash
tail -f .bombar/logs/run_bombar.log
bash .bombar/status.sh
```

If an obligation blocks, the runner preserves the work, records the failure, and halts. Return to an interactive Architecture Partner session only when the blocker requires a new decision or changed scope.

## 8. Verify independently

```bash
bash .bombar/prepare-verification.sh
```

Start a new, independent review session with the generated reviewer prompt — a fresh context, never the Engineering Partner's. The Independent Engineering Reviewer judges whether this is coherent, production-quality software, not only literal spec compliance. Resolve findings and perform required live probes awake under explicit authorization.

## 9. Evaluate the methodology transfer

For your first adoption, keep a short journal:

- What did the Architect understand without coaching?
- Which important questions did it fail to ask?
- Were the specifications executable without invention?
- Did Builders remain bounded?
- Which runner controls caught real problems?
- Did verification distinguish tests from practical outcome?
- What parts still depended on tacit expertise?

Those observations are the acceptance test for BOMBAR itself.

Use the structured rubric in [Methodology-transfer evaluation](transfer-evaluation.md) so the result is comparable across projects and models.
