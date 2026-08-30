#!/usr/bin/env bash
# Prove the kit extracts as its own repo root (no ModelBar app files).
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

if [[ -f grok-bots/scripts/package.sh ]]; then
  pkg="grok-bots/scripts/package.sh"
elif [[ -f scripts/package.sh ]]; then
  pkg="scripts/package.sh"
else
  echo "error: package.sh not found" >&2
  exit 1
fi

pkg_out="$(bash "$pkg")"
printf '%s\n' "$pkg_out"
wrote="$(printf '%s\n' "$pkg_out" | awk '/^wrote / { print $2 }')"
if [[ -z "$wrote" || ! -f "$wrote" ]]; then
  echo "error: package.sh did not write a tarball" >&2
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work" "$wrote"' EXIT
mkdir "$work/kit"
tar -xzf "$wrote" -C "$work/kit"

if [[ -e "$work/kit/ModelBar.swift" || -e "$work/kit/Info.plist" ]]; then
  echo "error: extract contains ModelBar app files" >&2
  exit 1
fi
if [[ ! -f "$work/kit/bots/librarian/PROFILE.md" ]]; then
  echo "error: extract missing bots/librarian/PROFILE.md" >&2
  exit 1
fi
if [[ ! -f "$work/kit/.grok/skills/load-this-kit/SKILL.md" ]]; then
  echo "error: extract missing load-this-kit skill" >&2
  exit 1
fi
if [[ ! -d "$work/kit/routines" ]]; then
  echo "error: extract missing routines/" >&2
  exit 1
fi

python3 "$work/kit/scripts/check_roster.py"
echo "extract selftest ok"
