---
name: reproduce-bug
description: >
  Reproduce a bug in staging with a fresh test account and return a pack:
  steps, expected vs actual, screenshots, environment, console/network
  notes. Never use production customer data.
when-to-use: repro, reproduce ticket, staging bug pack, steps to reproduce
argument-hint: "[ticket or report]"
metadata:
  author: fgomsan
  short-description: Staging reproduction pack
---

# Reproduce bug

Owner Bot: **Repro**.

## When to use it

A tracker ticket, email, or attached report needs a reliable reproduction pack.

## Required inputs and access

- The report (link or attachment)
- Staging URL and a fresh test account
- Credentials via secure handoff, not chat
- Browser on the Agent Computer

## Sequence of work

1. Quote the claimed expected vs actual behavior.
2. Use staging only. Refuse production customer data.
3. Create or use a fresh test account.
4. Follow the report, then minimize steps.
5. Capture screenshots, browser/OS, console and network notes.
6. If blocked by 2FA, CAPTCHA, or payment, stop for Agent Computer takeover.
7. Save artifacts under `/workspace/projects/repro/<ticket-id>/`.

## How to validate

- Another person could follow the steps without the original report.
- Pack includes all required fields or an explicit “could not capture” line.
- No production PII in files or chat.

## What to return

Repro pack in the conversation plus the folder path. Minimal test case when possible.

## What requires approval

Editing or commenting on the ticket, contacting the reporter, deploying, changing staging data beyond the test account, anything in production.
