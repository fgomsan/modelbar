#!/usr/bin/env bash
# Publish this kit to github.com/fgomsan/grok-bots (repo must already exist).
#
# Nested inside another git repo (prefix grok-bots/):
#   ./grok-bots/scripts/publish.sh https://github.com/fgomsan/grok-bots.git
#
# Already the git root of the kit:
#   ./scripts/publish.sh https://github.com/fgomsan/grok-bots.git

set -euo pipefail

REMOTE="${1:-https://github.com/fgomsan/grok-bots.git}"
BRANCH="${2:-grok-bots-main}"

root="$(git rev-parse --show-toplevel)"
cd "$root"

if [[ -d bots && -d .grok/skills ]]; then
  echo "kit root; pushing HEAD to $REMOTE main"
  git push -u "$REMOTE" HEAD:main
  exit 0
fi

PREFIX="grok-bots"
if [[ ! -d "$PREFIX" ]]; then
  echo "error: expected $PREFIX/ or a kit root (bots/ + .grok/skills/)" >&2
  exit 1
fi

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git branch -D "$BRANCH"
fi

git subtree split -P "$PREFIX" -b "$BRANCH"
echo "split ok: $BRANCH"
git push -u "$REMOTE" "$BRANCH:main"
