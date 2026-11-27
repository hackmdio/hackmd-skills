# HackMD API fallback

Use `hackmd-cli` 2.6.0 or later for everything: notes, team notes, folders, image upload, and any other v1 operation through `hackmd-cli api call <OperationId>`. With the CLI, the agent never handles the token.

Use the raw API below **only when the CLI cannot be installed**.

Base URL: `https://api.hackmd.io/v1`
Auth header: `Authorization: Bearer $HMD_API_ACCESS_TOKEN` (the same variable `hackmd-cli` reads; the user sets it — never read, echo, or paste the token)

Full spec: [swagger.json](https://api.hackmd.io/v1/docs/swagger.json)

## CLI equivalents

| Need | CLI | Raw API |
|------|-----|---------|
| Folders (list/create/move) | `hackmd-cli folders`, `team-folders --teamPath=<team>` | `/folders`, `/teams/{teampath}/folders` |
| Place note in folder | `--parentFolderId=<folder-id>` on `notes create` / `notes update` | `parentFolderId` on `POST`/`PATCH` note |
| Image upload | `hackmd-cli api call UploadNoteImage --path noteId=<id> --file image=@<path>` | `POST /notes/{noteId}/images` |
| Anything else | `hackmd-cli api operations`, then `api call <OperationId>` | see swagger.json |

## Folders (personal workspace)

```bash
# List
curl -s -H "Authorization: Bearer $HMD_API_ACCESS_TOKEN" https://api.hackmd.io/v1/folders

# Create (root folder — omit parentFolderId; null is rejected)
curl -s -X POST https://api.hackmd.io/v1/folders \
  -H "Authorization: Bearer $HMD_API_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"My Folder"}'

# Create note inside folder
curl -s -X POST https://api.hackmd.io/v1/notes \
  -H "Authorization: Bearer $HMD_API_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Title\",\"content\":$(jq -Rs . < note.md),\"parentFolderId\":\"<folder-uuid>\",\"readPermission\":\"owner\",\"writePermission\":\"owner\"}"

# Move existing note into folder
curl -s -X PATCH "https://api.hackmd.io/v1/notes/<noteId>" \
  -H "Authorization: Bearer $HMD_API_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"parentFolderId":"<folder-uuid>"}'
```

Team folders: replace `/folders` with `/teams/{teampath}/folders` and team notes under `/teams/{teampath}/notes`.

## Image upload

`POST /v1/notes/{noteId}/images` — `multipart/form-data`, field name `image`.

```bash
curl -s -X POST "https://api.hackmd.io/v1/notes/<noteId>/images" \
  -H "Authorization: Bearer $HMD_API_ACCESS_TOKEN" \
  -F "image=@/path/to/screenshot.png"
```

Response shape (same for `hackmd-cli api call UploadNoteImage`):

```json
{ "data": { "link": "https://..." } }
```

Insert in markdown: `![alt](<link>)`.

Upload requires an existing note id (create note first, then upload, then patch content if images were embedded inline).

## Team notes

```bash
# List
curl -s -H "Authorization: Bearer $HMD_API_ACCESS_TOKEN" \
  "https://api.hackmd.io/v1/teams/<teampath>/notes"

# Create
curl -s -X POST "https://api.hackmd.io/v1/teams/<teampath>/notes" \
  -H "Authorization: Bearer $HMD_API_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Title\",\"content\":$(jq -Rs . < note.md)}"

# Update
curl -s -X PATCH "https://api.hackmd.io/v1/teams/<teampath>/notes/<noteId>" \
  -H "Authorization: Bearer $HMD_API_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"content\":$(jq -Rs . < note.md)}"
```

## Note ids

- **API note id**: long alphanumeric (e.g. `raUuSTetT5uQbqQfLnz9lA`) — use for `export`, `update`, API paths.
- **Permalink**: `@team/slug` or `@user/slug` from the note URL. `hackmd-cli` accepts it directly as `--noteId=@team/slug`. To get the API note id, run [../scripts/resolve-note.sh](../scripts/resolve-note.sh) or `hackmd-cli notes --noteId=@team/slug --output=json`.

## Permissions (common values)

- `readPermission` / `writePermission`: `owner` | `signed_in` | `guest`
- `commentPermission`: `disabled` | `forbidden` | `owners` | `signed_in_users` | `everyone`

Match CLI defaults (`owner` / `owner` / `disabled`) unless the user specifies otherwise.
