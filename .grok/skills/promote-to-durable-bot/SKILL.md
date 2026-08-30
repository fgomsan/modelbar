---
name: promote-to-durable-bot
description: >
  Turn a successful one-off into a durable Grok Bot: profile fields, skill,
  second-input test, then routine only when failure cases are defined.
  Use when the human says make this a Bot, save this role, or promote this
  workflow.
when-to-use: durable bot, new agent, promote workflow, save this role
argument-hint: "[role name]"
metadata:
  author: fgomsan
  short-description: Official 7-step path from task to Bot
---

# Promote to durable Bot

Owner Bot: **Librarian** (coordinates). The new role may become its own Bot.

Follow [Turn an example into a durable Bot](https://docs.x.ai/grok-bot/use-cases).

## When to use it

A one-off task produced a reviewable result and should have a long-lived owner.

## Required inputs and access

- The successful conversation (or Teach-a-task draft)
- Proposed Name, Title, and standing boundaries
- This kit on disk

## Sequence of work

1. Put the job, source systems, output format, and standing boundaries in a draft `bots/<kebab>/PROFILE.md` (Name, Title, Description). Do not create the in-app Bot until the human approves.
2. Keep the first real task in `FIRST_TASK.md` with a safe, read-or-draft scope.
3. Ask the human to correct the result until it is reviewable (facts / inferences / done / waiting / unresolved).
4. Save the method as a skill (six sections + `.grok/skills/<name>/SKILL.md`). Use `save-skill-from-task`.
5. Name a **second**, distinct input and run the skill against it before automating.
6. Draft a routine only when retries, missing-source, and stale-data behavior are written. One owning Bot. Test run is real work.
7. Keep sending, publishing, purchasing, deletion, and production changes behind approval in the description **and** the skill.

Also write: “Description = standing rules. Message = today's work.”

## How to validate

- Profile has one primary job, not “general helper.”
- Skill has all six sections and no secrets.
- Routine is absent, or names owner, schedule/event, input, result, approval, missing-source.
- Second test input is explicit.

## What to return

Draft PROFILE, FIRST_TASK, SKILL.md, optional routine prompt, and the in-app clicks: Create new agent → Edit Profile → Plugins → Yours → Routines.

## What requires approval

Creating the in-app Bot, enabling skills on other Bots, creating/enabling routines, git commit/push, installing connectors.
