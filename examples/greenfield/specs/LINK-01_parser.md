# LINK-01 — Markdown link parser and explicit result model

<!-- BOMBAR_SPEC
{
  "id": "LINK-01",
  "title": "Markdown link parser and explicit result model",
  "depends_on": [],
  "risk": "low",
  "change_mode": "greenfield",
  "requires_live_probe": false,
  "acceptance_ids": ["AC-LINK-1", "AC-LINK-2"]
}
-->

## Outcome

A pure parser returns every Markdown link with its URL and source location, with a result vocabulary that distinguishes `reachable`, `unreachable`, and `unknown`. This obligation establishes the parser and result model; the CLI and HTTP checking arrive in LINK-02.

## Acceptance criteria

AC-LINK-1 and the vocabulary portion of AC-LINK-2 pass in unit tests.

## Verification

Parser fixtures cover inline/reference links, duplicates, malformed syntax, and zero links. A negative fixture proves a timeout cannot be represented as an empty result.
