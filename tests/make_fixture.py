#!/usr/bin/env python3
"""Turn an initialized BOMBAR project into a small valid test project."""

from __future__ import annotations

import json
import pathlib
import sys


root = pathlib.Path(sys.argv[1]).resolve()
dev = root / "__development/bombar"

documents = {
    "00_PRODUCT_BRIEF.md": """# Product brief

## One-sentence outcome

Create one deterministic fixture result from one approved bounded specification.

## Users and their situation

The BOMBAR test suite needs proof that its control loop works without a live coding provider.

## Problems and desired changes

The fake Builder must create a result and evidence while the runner owns completion.

## Primary workflows

Initialize, approve, run, verify, and resume without repeating completed work.

## Success in practical terms

The repository ends with result.txt, a green commit, evidence, and a completion marker.

## Scope

One hermetic slice using the fake adapter.

## Non-goals

No network, provider, payment, deployment, or production action.

## Constraints and owner decisions

Use only Python standard library, Git, and Bash.

## Unknowns and assumptions

The CI host provides Git, Bash, and Python 3.11 or later.
""",
    "01_REPOSITORY_ASSESSMENT.md": """# Repository assessment

## Project state

Greenfield fixture with no user, data, external consumer, or live behavior.

## Current capabilities

Only the installed BOMBAR control kit exists.

## Architecture and dependency direction

The fake adapter writes a result; deterministic machinery validates it.

## Data, interfaces, and external systems

No persistent or external system exists.

## Existing gates and operational machinery

The configured gate asserts that result.txt contains the expected value when present.

## Risks and weak spots

The fixture proves orchestration mechanics, not real model quality.

## Behavior that must be preserved

Initialization and validation remain hermetic.

## Evidence and verified repository references

The installed files under `.bombar/` and `__development/bombar/` are the complete terrain.
""",
    "02_ARCHITECTURE.md": """# Target architecture

## Architecture decision summary

One fake adapter acts inside one bounded slice; the deterministic runner remains arbiter.

## Components and responsibilities

The adapter writes implementation/evidence; the runner checks scope, gates, commit, and state.

## Data and control flow

Approved spec to fresh adapter invocation to deterministic verification to completion marker.

## Interfaces and dependency direction

The adapter receives only a prompt path and knows nothing about runner internals.

## Deterministic and model-reasoning boundaries

No model reasoning exists in the fixture; every acceptance decision is deterministic.

## Security, authority, and external effects

No external effect or credential is used.

## Failure, recovery, and observability

Logs and preserved work make failure visible; rerun skips a valid done marker.

## Greenfield/brownfield implications

This is greenfield and requires no migration or rollback.

## Deliberately deferred capabilities

Live provider and model-quality evaluation are outside this mechanical fixture.
""",
    "03_INVARIANTS.md": """# Product and architecture invariants

| ID | Invariant | Mechanism | Checker |
|---|---|---|---|
| INV-1 | The runner, never adapter prose, owns completion. | marker after gates and evidence | fixture test |

## Outcome and liveness invariants

| ID | What must actually happen | Sensor outside the actor's own claim | Tolerance |
|---|---|---|---|
| OI-1 | result.txt exists after the run | shell assertion on filesystem | immediate |

## Invariant change policy

The fixture owner must update and refreeze the contract before changing this invariant.
""",
    "04_ACCEPTANCE_CONTRACT.md": """# Acceptance contract

**Status:** Frozen by the fixture owner before implementation.

## Core acceptance criteria

- **AC-FIXTURE-1** — The approved fake slice produces result.txt, evidence, a green commit, and a valid completion marker — `[auto]`.

## Compatibility and preservation criteria

No prior behavior or data exists in this greenfield fixture.

## Safety and refusal criteria

The fake adapter performs no network, paid, production, or messaging action.

## Live/world acceptance

No live claim exists; filesystem and Git state are the external sensors for this mechanical test.

## Acceptance rule

The test passes only when the deterministic assertions observe all four artifacts.
""",
    "05_IMPLEMENTATION_PLAN.md": """# Implementation plan

## Sequencing rationale

One vertical slice is sufficient to prove the v0.1 runner mechanics.

## Slice map

| Order | ID | Outcome | Depends on | Risk | Change mode | Acceptance IDs |
|---|---|---|---|---|---|---|
| 1 | FIXTURE-01 | Produce a deterministic result | — | low | greenfield | AC-FIXTURE-1 |

## Dependency graph

```text
FIXTURE-01
```

## Cross-slice rules

The adapter remains hermetic and the runner owns the commit.

## Parallelism decisions

There is one slice, so no parallelism decision exists.

## Release and live acceptance sequence

Run the fixture and generate the independent verification pack; no live action follows.
""",
}

for name, content in documents.items():
    (dev / name).write_text(content, encoding="utf-8")

spec_dir = dev / "specs"
for path in spec_dir.glob("*.md"):
    path.unlink()
(spec_dir / "README.md").write_text(
    "# Implementation specifications\n\nThe fixture contains one approved bounded specification.\n",
    encoding="utf-8",
)
(spec_dir / "FIXTURE-01_result.md").write_text(
    """# FIXTURE-01 — produce a deterministic result

<!-- BOMBAR_SPEC
{
  "id": "FIXTURE-01",
  "title": "Produce a deterministic result",
  "depends_on": [],
  "risk": "low",
  "change_mode": "greenfield",
  "touchable_paths": ["result.txt"],
  "protected_paths": [],
  "requires_live_probe": false,
  "acceptance_ids": ["AC-FIXTURE-1"]
}
-->

## Outcome

Create result.txt containing `implemented FIXTURE-01` and a conforming evidence file.

## Current State

No result file or evidence exists before execution.

## Scope

The result file and its slice evidence only.

## Out of Scope

All source, control, CI, network, provider, and deployment behavior.

## Architecture and Invariants

The fake adapter writes; the runner verifies and owns completion.

## Acceptance Criteria

AC-FIXTURE-1 is satisfied when all deterministic artifacts are observed.

## Verification

The configured Python gate validates exact result content; runner checks evidence headings and commit.

## Definition of Done

Scope and gate pass, evidence exists, one commit is created, and the completion marker is valid.
""",
    encoding="utf-8",
)

profile_path = root / ".bombar/project-profile.json"
profile = json.loads(profile_path.read_text(encoding="utf-8"))
profile["project"]["state"] = "greenfield"
profile["execution"]["agent_adapter"] = ".bombar/adapters/fake-test.sh"
profile["execution"]["heartbeat_seconds"] = 5
profile["execution"]["gates"] = [
    "test ! -f result.txt || grep -qx 'implemented FIXTURE-01' result.txt"
]
profile_path.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")
