# LINK-02 — injected HTTP adapter, CLI, and JSON report

<!-- BOMBAR_SPEC
{
  "id": "LINK-02",
  "title": "Injected HTTP adapter, CLI, and JSON report",
  "depends_on": ["LINK-01"],
  "risk": "medium",
  "change_mode": "greenfield",
  "requires_live_probe": true,
  "acceptance_ids": ["AC-LINK-1", "AC-LINK-2", "AC-LINK-3"]
}
-->

## Outcome

The CLI checks parsed links through an injected adapter and writes a deterministic JSON report, building on LINK-01's parser and result vocabulary.

## Acceptance criteria

AC-LINK-1/2 pass hermetically. AC-LINK-3 stays explicitly live-pending until the owner runs the canary; no live HTTP is performed unattended.

## Verification

Provider doubles cover reachable, 404, timeout, and malformed response. The live probe uses one approved fixture URL after offline verification, run awake under explicit authorization.
