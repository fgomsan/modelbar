# Changelog

## 0.1.1

- `scripts/extract_selftest.sh` proves a tarball extract is a kit root (no ModelBar app files)
- ModelBar workflow `publish-grok-bots.yml`: one secret `GROK_BOTS_TOKEN`, then Run workflow

## 0.1.0

First extractable kit for [Grok Bot](https://docs.x.ai/grok-bot/overview).

- 9 Bots (official xAI use-case roles + Librarian)
- 11 skills under `.grok/skills/`
- 6 routines (5 scheduled + 1 event)
- `scripts/check_roster.py`, `scripts/publish.sh`, `scripts/package.sh`
- Version tag on ModelBar: `grok-bots-v0.1.0` (kit as repo root; does not use `v*`)
- Intended remote: `https://github.com/fgomsan/grok-bots`
