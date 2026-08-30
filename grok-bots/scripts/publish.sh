#!/usr/bin/env bash
# Publish this kit to github.com/fgomsan/grok-bots (repo must already exist).
#
# Nested inside ModelBar (prefix grok-bots/):
#   ./grok-bots/scripts/publish.sh --force
#
# Already the git root of the kit:
#   ./scripts/publish.sh --force
#
# --force is required while remote main is only the GitHub-generated README.

set -euo pipefail

REMOTE="https://github.com/fgomsan/grok-bots.git"
LOCAL_BRANCH="grok-bots-main"
FORCE=0
DRY_RUN=0
# Initial commit on fgomsan/grok-bots (README only). Safe to replace.
PLACEHOLDER_SHA="2e4369a2a4182a0593021a411de8c10407aa5f6f"

usage() {
  cat <<'EOF'
Usage: publish.sh [--remote URL] [--branch NAME] [--force] [--dry-run]

  --remote   Destination git URL (default: https://github.com/fgomsan/grok-bots.git)
  --branch   Local split branch name when publishing from a nested grok-bots/ prefix
  --force    Allow updating a non-placeholder remote main (always used for the
             known GitHub README placeholder SHA)
  --dry-run  Split if needed and print the push; do not contact the remote
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      REMOTE="${2:?}"
      shift 2
      ;;
    --branch)
      LOCAL_BRANCH="${2:?}"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      # Back-compat: publish.sh <remote> [branch]
      if [[ "$1" == http* || "$1" == git@* ]]; then
        REMOTE="$1"
        shift
        if [[ $# -gt 0 && "$1" != --* ]]; then
          LOCAL_BRANCH="$1"
          shift
        fi
      else
        echo "error: unknown argument: $1" >&2
        usage >&2
        exit 1
      fi
      ;;
  esac
done

root="$(git rev-parse --show-toplevel)"
cd "$root"

push_ref=""
if [[ -d bots && -d .grok/skills ]]; then
  echo "kit root; will push HEAD to ${REMOTE} main"
  push_ref="HEAD"
else
  PREFIX="grok-bots"
  if [[ ! -d "$PREFIX" ]]; then
    echo "error: expected ${PREFIX}/ or a kit root (bots/ + .grok/skills/)" >&2
    exit 1
  fi
  if git show-ref --verify --quiet "refs/heads/${LOCAL_BRANCH}"; then
    git branch -D "$LOCAL_BRANCH"
  fi
  git subtree split -P "$PREFIX" -b "$LOCAL_BRANCH"
  echo "split ok: ${LOCAL_BRANCH}"
  push_ref="$LOCAL_BRANCH"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "dry-run: would push ${push_ref} to ${REMOTE} main"
  echo "dry-run: placeholder SHA ${PLACEHOLDER_SHA} is auto-force; otherwise pass --force"
  exit 0
fi

remote_sha="$(git ls-remote "$REMOTE" refs/heads/main 2>/dev/null | awk '{print $1}' || true)"

if [[ -z "$remote_sha" ]]; then
  echo "remote main missing or not readable; pushing ${push_ref}:main"
  git push -u "$REMOTE" "${push_ref}:main"
  exit 0
fi

if [[ "$remote_sha" == "$PLACEHOLDER_SHA" ]]; then
  echo "remote main is the GitHub README placeholder (${PLACEHOLDER_SHA}); force-pushing kit"
  git push --force -u "$REMOTE" "${push_ref}:main"
  exit 0
fi

if [[ "$FORCE" -eq 1 ]]; then
  echo "warning: --force replacing ${remote_sha} on ${REMOTE} main"
  git push --force -u "$REMOTE" "${push_ref}:main"
  exit 0
fi

echo "pushing ${push_ref} onto ${REMOTE} main (${remote_sha})"
if git push -u "$REMOTE" "${push_ref}:main"; then
  exit 0
fi

echo "error: remote main is ${remote_sha}, not the placeholder README." >&2
echo "Review github.com/fgomsan/grok-bots, then re-run with --force." >&2
exit 1
