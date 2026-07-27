# Acceptance contract

- **AC-LINK-1** — Given a Markdown file with two links, the CLI emits one result per link with source location and status — `[auto]`.
- **AC-LINK-2** — A transport timeout becomes an explicit `unknown/timeout` result and does not disappear as “no links” — `[auto/negative]`.
- **AC-LINK-3** — Against one explicitly approved public fixture URL, the real adapter's result matches the observed HTTP status — `[probe]`.
