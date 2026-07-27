# Acceptance contract

**Status:** TODO: draft until the owner freezes it before implementation.

Every criterion is observable and capable of failing. Use `[auto]`, `[probe]`, `[negative]`, or `[owner]` to name the verification method. Live/world effects use a sensor outside the system's own ledger.

## Core acceptance criteria

- **AC-CORE-1** — TODO — `[auto|probe|negative|owner]`

## Compatibility and preservation criteria

- **AC-COMPAT-1** — TODO — `[auto|probe|negative|owner]`

## Safety and refusal criteria

- **AC-SAFE-1** — TODO — `[negative]`

## Live/world acceptance

- **AC-LIVE-1** — TODO; name the external boundary and authorization required — `[probe]`

## Acceptance rule

The product is not declared complete until every core criterion passes its named method, every negative criterion is actively attempted and refuses, and any required live probe is performed awake under explicit authorization.
