---
name: source-candidates
description: >
  Source candidates for a role, exclude people already in the ATS, explain
  match evidence, and draft outreach in the human's voice. Do not contact anyone.
when-to-use: talent scout, source candidates, ATS exclude, recruiting shortlist
argument-hint: "[role description]"
metadata:
  author: fgomsan
  short-description: Evidence-backed candidate shortlist
---

# Source candidates

Owner Bot: **Scout**.

## When to use it

A role description needs a shortlist with evidence and draft outreach.

## Required inputs and access

- Role description with must-haves
- ATS export or named view for exclusions
- Approved sourcing tools, email, calendar as needed

## Sequence of work

1. Extract must-have vs nice-to-have criteria.
2. Exclude anyone already in the ATS.
3. Find the requested count (default 20) who meet must-haves.
4. For each: evidence, source, draft outreach in the human's voice.
5. Save under `/workspace/projects/talent/<role-slug>/`.

## How to validate

- Every name has evidence tied to a must-have.
- ATS exclusions are accounted for (count in vs skipped).
- No candidate was contacted.

## What to return

Shortlist table + draft messages. Note regional/privacy constraints applied.

## What requires approval

Contacting candidates, ATS status changes, calendar invites, posting the role publicly.
