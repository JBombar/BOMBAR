# Implementation specifications

One Markdown file equals one bounded fresh Builder session. Every file starts with a `BOMBAR_SPEC` JSON metadata block and contains all required sections.

The interactive Architect owns these specifications. Builders may not edit them. If implementation reveals a missing decision, the Builder writes `../BLOCKERS.md` and stops; the owner and Architect decide whether to revise and re-freeze the governed artifacts.

`S01_REPLACE_ME.md` is a deliberately invalid template. Replace it with real specifications before plan validation.
