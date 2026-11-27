# push-to-hackmd — iteration-2 eval results

**Date:** 2026-11-27
**CLI:** `@hackmd/hackmd-cli/2.6.0`
**Skill install:** `npx skills add <checkout> --skill push-to-hackmd --copy` (single skill directory, no `shared/`)

Each eval ran in a fresh agent that only had the installed skill directory.

## Summary

| Eval | Result | Notes |
|------|--------|-------|
| #1 | **pass** | Personal note created with owner/owner permissions. |
| #2 | **pass** | Run against team `ss-team` (no `engineering` team). Team folder `Runbooks` created with `team-folders create`; note created with `--parentFolderId`; `GetTeamNote` shows it under `folderPaths`. No curl. |
| #3 | **pass** | Target was the eval #1 note. `scripts/resolve-note.sh` resolved the URL; `scripts/safe-sync.sh` exited 0; Custom CSS comment added. |
| #4 | **pass** | `api call UploadNoteImage` returned `data.link`; local path replaced through `safe-sync.sh`. No curl, token never read. |

**Overall:** 4/4 pass

## Issues found and fixed in SKILL.md

- `notes create --output=json` returns an array; the skill now says to read `.[0].id` and not to re-run create on a parse error.
- `notes --output=json` has only table columns; verification now uses `api call GetNote` / `GetTeamNote` (`folderPaths`, permissions, `publishLink`).
- The token question is skipped when `hackmd-cli whoami` succeeds.
- `visualize-hmd` is optional; the missing `hackmd-cli.mdc` reference was removed.

## Open

- Team notes default to `--readPermission=owner`. Decide whether team backups should default to team-readable.
- `--content="$(cat file)"` drops the trailing newline. HackMD does not keep it either, so the content is unaffected.
