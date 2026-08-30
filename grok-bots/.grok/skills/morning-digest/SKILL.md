---
name: morning-digest
description: >
  Build a source-linked digest of what changed and needs attention,
  filtered to a written priority list. Drafts only; never send messages
  or change meetings.
when-to-use: morning digest, chief of staff brief, what needs my attention
argument-hint: "[since when]"
metadata:
  author: fgomsan
  short-description: Priority-filtered daily digest
---

# Morning digest

Owner Bot: **Scribe**.

## When to use it

Start of day, or on the weekday routine, against a written priority document.

## Required inputs and access

- Priority document (attachment or path)
- Approved sources only: named Slack channels, inbox, calendar, notes
- Time window (default: since yesterday, human's time zone)

## Sequence of work

1. Read the priority document. Items that do not map to it are dropped (optionally a “noise” count, no detail).
2. Scan only approved sources. If a source is down, say so; do not use memory as a substitute.
3. For each kept item: source link, why it matters, proposed next step, decision owed (yes/no).
4. Sort: decisions owed first, then time-sensitive, then the rest.
5. Stop at a reviewable digest. No sends.

## How to validate

- Every item has a source link or an honest “no link, from attached export.”
- No messages sent, no events created.
- Corrections from the last digest (useful vs noise) are applied if the human recorded them.

## What to return

Digest in the conversation. Optional file `/workspace/projects/digest/YYYY-MM-DD.md`.

## What requires approval

Sending Slack or email, creating or moving meetings, paging, posting in public channels.
