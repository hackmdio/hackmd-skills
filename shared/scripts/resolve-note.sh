#!/usr/bin/env bash
# Resolve a hackmd.io URL, permalink, short id, or note id → internal note id (stdout).
# Team path on stderr as team:PATH when the note belongs to a team.
# Every reference is checked with `hackmd-cli notes --noteId=...` (read-only), so a
# link that is not a note fails with exit 2 instead of returning a fake id.
#
# Accepted:
#   https://hackmd.io/<noteId>            https://hackmd.io/s/<shortId>
#   https://hackmd.io/@team/slug          https://hackmd.io/c/<book>/%2F%40team%2Fslug
#   @team/slug   @user/slug   <noteId>   <shortId>
# URLs may carry /edit, ?query or #anchor. Only hackmd.io URLs are accepted; for
# HackMD EE, pass the note id or @team/slug instead.
set -euo pipefail

INPUT="${1:?usage: resolve-note.sh <url-or-note-id>}"

# Book URLs encode the note path (%2F%40team%2Fslug). Decode only these two.
INPUT="${INPUT//%2F//}"; INPUT="${INPUT//%2f//}"; INPUT="${INPUT//%40/@}"

fail() { echo "ERROR: $*" >&2; exit 2; }

lookup() {
  command -v jq >/dev/null || fail "jq required"
  local json id team
  json="$(hackmd-cli notes --noteId="$1" --output=json)" || fail "no note found for $1"
  id="$(jq -r 'if type == "array" then .[0] else . end | .id // empty' <<<"$json")"
  team="$(jq -r 'if type == "array" then .[0] else . end | .teamPath // empty' <<<"$json")"
  [[ -n "$id" ]] || fail "no note found for $1"
  echo "$id"
  [[ -z "$team" ]] || echo "team:$team" >&2
}

REF='[A-Za-z0-9_-]{8,}'
if [[ "$INPUT" =~ ^https?:// ]]; then
  [[ "$INPUT" =~ ^https?://hackmd\.io/ ]] || fail "only hackmd.io URLs are supported; pass the note id or @team/slug instead"
  PATH_PART="${INPUT#*://hackmd.io/}"
  PATH_PART="${PATH_PART%%[?#]*}"
  if [[ "$PATH_PART" =~ ^(c/[^/]+/+)?(@[^/]+/[^/]+) ]]; then
    lookup "${BASH_REMATCH[2]}"
  elif [[ "$PATH_PART" =~ ^(s/)?($REF)(/.*)?$ ]]; then
    lookup "${BASH_REMATCH[2]}"
  else
    fail "not a note URL: $1"
  fi
elif [[ "$INPUT" =~ ^@[^/]+/[^/?#]+$ || "$INPUT" =~ ^$REF$ ]]; then
  lookup "$INPUT"
else
  fail "cannot parse note reference: $1"
fi
