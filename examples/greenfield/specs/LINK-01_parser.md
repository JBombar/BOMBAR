# LINK-01 — Markdown link parser and explicit result model

<!-- BOMBAR_SPEC
{
  "id": "LINK-01",
  "title": "Markdown link parser and explicit result model",
  "depends_on": [],
  "risk": "low",
  "change_mode": "greenfield",
  "touchable_paths": ["src/linkcheck/**", "tests/**"],
  "protected_paths": [],
  "requires_live_probe": false,
  "acceptance_ids": ["AC-LINK-1", "AC-LINK-2"]
}
-->

## Outcome

A pure parser returns every Markdown link with its URL and source location. The result vocabulary distinguishes `reachable`, `unreachable`, and `unknown`.

## Current State

The scaffold and test command exist; no link-check domain code exists.

## Scope

Pure parser, result types, timeout reason vocabulary, and unit tests.

## Out of Scope

HTTP, CLI, concurrency, retries, and report files.

## Acceptance Criteria

AC-LINK-1 and the vocabulary portion of AC-LINK-2 pass in unit tests.

## Verification

Parser fixtures cover inline/reference links, duplicates, malformed syntax, and zero links. A negative fixture proves timeout cannot be represented as an empty result.

## Definition of Done

Configured gates pass, evidence is recorded, and the slice commits independently.
