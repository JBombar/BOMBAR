# LINK-02 — injected HTTP adapter, CLI, and JSON report

<!-- BOMBAR_SPEC
{
  "id": "LINK-02",
  "title": "Injected HTTP adapter, CLI, and JSON report",
  "depends_on": ["LINK-01"],
  "risk": "medium",
  "change_mode": "greenfield",
  "touchable_paths": ["src/linkcheck/**", "tests/**"],
  "protected_paths": [],
  "requires_live_probe": true,
  "acceptance_ids": ["AC-LINK-1", "AC-LINK-2", "AC-LINK-3"]
}
-->

## Outcome

The CLI checks parsed links through an injected adapter and writes a deterministic JSON report.

## Current State

LINK-01 provides the parser and closed result vocabulary.

## Scope

Adapter port, standard-library implementation, CLI, report serialization, provider-double tests, and an awake canary runbook.

## Out of Scope

Unattended live HTTP in tests or the Builder session, browser rendering, and distributed crawling.

## Acceptance Criteria

AC-LINK-1/2 pass hermetically. AC-LINK-3 remains explicitly live-pending until the owner runs the canary.

## Verification

Provider doubles cover reachable, 404, timeout, and malformed response. The live probe uses one approved fixture URL after offline verification.

## Definition of Done

Offline gates and evidence pass, the live probe is documented but not executed unattended, and the slice commits independently.
