#!/usr/bin/env bash
# Resolve a hackmd.io URL, permalink, or raw id → internal note id (stdout).
# Team path on stderr as team:PATH when the note belongs to a team.
set -euo pipefail

INPUT="${1:?usage: resolve-note.sh <url-or-note-id>}"

# Book URLs encode the note path, e.g. /c/tutorials/%2F%40docs%2Fmcp-server-setup
INPUT="$(printf '%b' "${INPUT//%/\\x}")"

lookup() {
  command -v jq >/dev/null || { echo "ERROR: jq required for permalinks" >&2; exit 2; }
  local json id team
  json="$(hackmd-cli notes --noteId="$1" --output=json)" \
    || { echo "ERROR: no note found for $1" >&2; exit 2; }
  id="$(jq -r 'if type == "array" then .[0] else . end | .id // empty' <<<"$json")"
  team="$(jq -r 'if type == "array" then .[0] else . end | .teamPath // empty' <<<"$json")"
  [[ -n "$id" ]] || { echo "ERROR: no note found for $1" >&2; exit 2; }
  echo "$id"
  [[ -z "$team" ]] || echo "team:$team" >&2
}

if [[ "$INPUT" =~ (@[^/?#]+/[^/?#]+) ]]; then
  lookup "${BASH_REMATCH[1]}"
elif [[ "$INPUT" =~ ^https?://hackmd\.io/([^/?#]+) ]]; then
  echo "${BASH_REMATCH[1]}"
elif [[ "$INPUT" =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "$INPUT"
else
  echo "ERROR: cannot parse note reference: $INPUT" >&2
  exit 2
fi
