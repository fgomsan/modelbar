---
name: load-this-kit
description: >
  Clone or verify the grok-bots kit on the Grok Bot Agent Computer, then
  return a roster table of Bots, skills, and routines. Use when the human
  says load this kit, sync the roster, or asks which Grok Bots exist.
when-to-use: load kit, sync roster, list bots, where is grok-bots
argument-hint: "[clone path]"
metadata:
  author: fgomsan
  short-description: Sync and list the Grok Bot kit
---

# Load this kit

## When to use it

The kit should live on the shared Agent Computer (default `/workspace/grok-bots`) and match git.

## Required inputs and access

- Git remote for this kit (no tokens in the skill text)
- Path of the clone
- Read access to `bots/`, `.grok/skills/`, `routines/`, `AGENTS.md`

## Sequence of work

1. Resolve the clone path. If missing, clone to `/workspace/grok-bots`.
2. `git status` and `git log -1 --oneline`. Do not push.
3. Read `AGENTS.md` and `README.md`.
4. Inventory:
   - `VERSION`
   - each `bots/*/PROFILE.md` (skip `_template`) → Name, Title, first standing rule
   - each `.grok/skills/*/SKILL.md` → `name` and `short-description`
   - each `routines/*.md` → owner Bot named in the file
   - `CONNECTORS.md` for the plugin list per Bot
5. Flag gaps: profile without a first task, skill without an owner Bot, routine whose skill file is missing.
6. Write the table into the conversation. Optionally save a copy under `/workspace/projects/grok-bots/roster-latest.md`.

## How to validate

- Every PROFILE Name/Title matches the README roster.
- No `.env`, `mcp_credentials.json`, or files named `*secret*` are proposed for commit.

## What to return

A markdown table of Bots / skills / routines, git HEAD, and a short gap list.

## What requires approval

Creating Bots, saving in-app skills, creating routines, `git push`, installing connectors, anything that leaves the computer (email, Slack, GitHub writes).
