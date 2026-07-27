# Contributing

BOMBAR improves from demonstrated failures and reproducible adoption evidence, not from adding ceremony.

## Good contributions

- A fixture reproducing an escaped defect in the methodology or runner.
- A simpler mechanism that preserves an existing invariant.
- A provider adapter with a documented, tested fresh-session boundary.
- A sanitized case study showing where methodology transfer succeeded or failed.
- Documentation that makes a first user's next action clearer.

## Pull requests

1. Explain the practical problem and failure scenario.
2. Keep provider-specific behavior behind an adapter.
3. Add or update hermetic tests.
4. Run `bash tests/run.sh` and `python -m compileall scripts/lib`.
5. State compatibility implications for already initialized projects.

Do not include client data, credentials, private prompts, production dumps, or proprietary source material in issues, fixtures, or pull requests.
