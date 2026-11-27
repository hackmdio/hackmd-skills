#!/usr/bin/env bash
# Copy files from shared/ into each skill so every installed skill is self-contained.
# `npx skills add` and `gh skill install` copy only the skill directory, so skills
# must not reference ../shared at runtime.
#
# Usage:
#   scripts/sync-shared.sh          # update the copies
#   scripts/sync-shared.sh --check  # exit 1 if any copy differs from shared/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# skill:file-under-shared — the file is copied to <skill>/<file>
MANIFEST=(
  push-to-hackmd:scripts/safe-sync.sh
  push-to-hackmd:scripts/resolve-note.sh
  push-to-hackmd:references/contract.md
  push-to-hackmd:references/api.md
  agentic-work-log:scripts/safe-sync.sh
  agentic-work-log:scripts/resolve-note.sh
  agentic-work-log:references/contract.md
  agentic-work-log:references/api.md
  visualize-hmd:scripts/safe-sync.sh
  visualize-hmd:scripts/resolve-note.sh
  visualize-hmd:references/contract.md
  visualize-hmd:references/api.md
)

CHECK=false
case "${1:-}" in
  "") ;;
  --check) CHECK=true ;;
  *) echo "usage: scripts/sync-shared.sh [--check]" >&2; exit 2 ;;
esac

stale=0
for entry in "${MANIFEST[@]}"; do
  skill="${entry%%:*}"
  file="${entry#*:}"
  src="shared/$file"
  dest="$skill/$file"
  if $CHECK; then
    if ! cmp -s "$src" "$dest"; then
      echo "Out of date: $dest (source: $src)" >&2
      stale=1
    fi
  else
    mkdir -p "$(dirname "$dest")"
    cp -p "$src" "$dest"
  fi
done

if $CHECK && [[ $stale -ne 0 ]]; then
  echo "Run scripts/sync-shared.sh and commit the result." >&2
  exit 1
fi
