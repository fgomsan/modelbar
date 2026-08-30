#!/usr/bin/env bash
# Build grok-bots-<VERSION>.tar.gz of the kit (no .git).
#
# Nested: ./grok-bots/scripts/package.sh
# Kit root: ./scripts/package.sh

set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

if [[ -d bots && -d .grok/skills && -f VERSION ]]; then
  kit="."
  out_dir="$root"
elif [[ -d grok-bots/bots && -f grok-bots/VERSION ]]; then
  kit="grok-bots"
  out_dir="$root/grok-bots"
else
  echo "error: expected kit root or grok-bots/ prefix" >&2
  exit 1
fi

version="$(tr -d '[:space:]' < "${kit}/VERSION")"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: bad VERSION: ${version}" >&2
  exit 1
fi

out="${out_dir}/grok-bots-${version}.tar.gz"
tmp="$(mktemp "${TMPDIR:-/tmp}/grok-bots.XXXXXX.tar.gz")"
rm -f "$out"

tar -czf "$tmp" \
  --exclude .git \
  --exclude 'grok-bots-*.tar.gz' \
  --exclude '__pycache__' \
  --exclude '.DS_Store' \
  -C "$kit" \
  .

members="$(tar -tzf "$tmp")"
if ! grep -qx './bots/librarian/PROFILE.md' <<<"$members" \
  && ! grep -qx 'bots/librarian/PROFILE.md' <<<"$members"; then
  echo "error: tarball missing bots/librarian/PROFILE.md" >&2
  rm -f "$tmp"
  exit 1
fi
if ! grep -qx './.grok/skills/load-this-kit/SKILL.md' <<<"$members" \
  && ! grep -qx '.grok/skills/load-this-kit/SKILL.md' <<<"$members"; then
  echo "error: tarball missing .grok/skills/load-this-kit/SKILL.md" >&2
  rm -f "$tmp"
  exit 1
fi

mv "$tmp" "$out"
echo "wrote ${out}"
