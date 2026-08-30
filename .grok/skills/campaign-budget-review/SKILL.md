---
name: campaign-budget-review
description: >
  Compare live ads spend and performance with budget and target CAC, then
  recommend reallocations with numbers. Draft Slack; do not change campaigns
  or send the message.
when-to-use: paid media, CAC, campaign budget, ads reallocation
argument-hint: "[time window]"
metadata:
  author: fgomsan
  short-description: Budget recommendations, no campaign writes
---

# Campaign budget review

Owner Bot: **Spend**.

## When to use it

Current spend needs a recommendation against monthly budget and target CAC.

## Required inputs and access

- Ads platforms, analytics, budget spreadsheet
- Time window and time zone
- Target CAC / budget numbers (attachment if not in the UI)

## Sequence of work

1. Pull spend and performance by campaign for the window.
2. Compare with budget and target CAC.
3. Recommend reallocations with before/after numbers and expected impact.
4. Draft a Slack update. Do not post. Do not change budgets.

## How to validate

- Every figure has a source UI link or export path and a timestamp.
- No campaign or budget field was edited.
- Slack text is clearly a draft.

## What to return

Recommendation memo + Slack draft. Optional CSV under `/workspace/projects/paid-media/`.

## What requires approval

Changing budgets, pausing/enabling campaigns, posting Slack, spending increases.
