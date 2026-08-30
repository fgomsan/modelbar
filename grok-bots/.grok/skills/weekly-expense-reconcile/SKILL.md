---
name: weekly-expense-reconcile
description: >
  Reconcile weekly expenses against policy, match receipts, flag exceptions
  with citations, and draft owner follow-ups. Do not send or change
  reimbursements.
when-to-use: expense report, receipt matching, policy exception, weekly finance
argument-hint: "[week]"
metadata:
  author: fgomsan
  short-description: Policy-cited expense summary
---

# Weekly expense reconcile

Owner Bot: **Ledger**.

## When to use it

A week's expenses need a summary, receipt match, and exception follow-ups.

## Required inputs and access

- Expense system
- Policy document
- Finance inbox or receipt folder

## Sequence of work

1. Export or list this week's expenses. Record the source total.
2. Match receipts. Flag missing categories or policy exceptions with citations.
3. Draft one follow-up per owner. Do not send.
4. Reconcile totals to the source. Explain any delta.

## How to validate

- Source total, matched total, and exception total add up or the gap is named.
- Every exception cites a policy section.
- No reimbursement fields changed.

## What to return

Summary spreadsheet or markdown + draft follow-ups. Path under `/workspace/projects/expenses/`.

## What requires approval

Sending follow-ups, changing reimbursements, paying cards, deleting receipts.
