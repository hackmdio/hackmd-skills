# Shared files (source)

This directory holds the single source for files used by more than one skill:

- [references/contract.md](references/contract.md) — safe update contract and destination policy
- [references/api.md](references/api.md) — raw API fallback when `hackmd-cli` is unavailable
- [scripts/safe-sync.sh](scripts/safe-sync.sh) — push with recheck
- [scripts/resolve-note.sh](scripts/resolve-note.sh) — URL or permalink → note id

Skills do not read this directory at runtime. `npx skills add` and `gh skill install` copy only the skill directory, so each skill carries its own copy under `scripts/` and `references/`.

To change a shared file, edit it here, then run:

```bash
scripts/sync-shared.sh
```

CI runs `scripts/sync-shared.sh --check` and fails if a copy differs from its source. The list of which skill gets which file is in `scripts/sync-shared.sh`.
