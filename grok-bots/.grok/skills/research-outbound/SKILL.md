---
name: research-outbound
description: >
  Research a CRM view against ICP and intent, pick contacts, and draft
  outreach for review. Skip active sequences. Never send or enroll.
when-to-use: outbound research, ICP score, draft LinkedIn, CRM prospect list
argument-hint: "[CRM view]"
metadata:
  author: fgomsan
  short-description: Review-ready outbound research
---

# Research outbound

Owner Bot: **Quill**.

## When to use it

A CRM view or account list needs scoring, contacts, and draft outreach — not a send.

## Required inputs and access

- Account list or CRM view
- ICP notes and outreach style examples
- CRM / intent / company sites / email / professional networks as permitted

## Sequence of work

1. Snapshot the input list (count, date, source). Skip active sequences.
2. Score remaining accounts against ICP and recent intent.
3. Up to three relevant contacts per account, with evidence for why them.
4. Draft email and LinkedIn in the attached voice. Do not send.
5. Write a review list under `/workspace/projects/outbound/`.

## How to validate

- Skipped rows are listed with the skip reason.
- Every draft points at a named contact and account.
- No messages sent, no sequence enrollment.

## What to return

Ranked review list plus draft copy. Conversation holds the summary.

## What requires approval

Sending email or LinkedIn, enrolling sequences, CRM writes, scraping that violates source terms.
