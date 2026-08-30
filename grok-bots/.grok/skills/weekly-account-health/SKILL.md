---
name: weekly-account-health
description: >
  Rank a customer portfolio into a linked watch list from usage, support,
  renewal, and stakeholder signals. Never contact customers or edit the CRM.
when-to-use: account health, churn watch list, expansion signals, CS weekly
argument-hint: "[portfolio or CRM view]"
metadata:
  author: fgomsan
  short-description: Ranked account watch list
---

# Weekly account health

Owner Bot: **Harbor**.

## When to use it

A portfolio or CRM view needs a ranked watch list. Nightly or weekly routines must not use stale data as if it were current.

## Required inputs and access

- Account list or CRM view
- Usage, support, billing/renewal, CS notes as available
- Risk thresholds if the human has set them; otherwise label scores uncalibrated

## Sequence of work

1. Snapshot the input list (count, date, source).
2. For each account, gather usage, escalations, renewal timing, stakeholder activity.
3. Rank. Skip anyone already marked out of scope or in an active sequence if the human said so.
4. Fill `/workspace/grok-bots/workspace/templates/watch-list.csv` (copy, do not overwrite the template).
5. Suggested next step is a recommendation, not an outbound.

## How to validate

- Totals reconcile to the source list (in, skipped, missing data).
- Every flag has an evidence link or export path.
- If a source is unavailable: fail that section; do not copy last week.

## What to return

Ranked watch list (CSV + short narrative). Conversation holds the summary; CSV is the artifact.

## What requires approval

Customer contact, CRM edits, sequence enrollment, Slack to the customer, billing changes.
