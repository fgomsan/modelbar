---
name: investigate-performance
description: >
  Investigate product performance (latency, errors, checkout) from
  observability tools. Return a short write-up with facts first, then
  hypotheses, plus screenshots and links. Never change production.
when-to-use: latency, error rate, checkout slow, flamegraph, dashboard regression
argument-hint: "[symptom or time window]"
metadata:
  author: fgomsan
  short-description: Evidence-first performance write-up
---

# Investigate performance

Owner Bot: **Piper**.

## When to use it

A performance symptom has a time window (release, deploy, or “since yesterday”).

## Required inputs and access

- Symptom and time window (time zone named)
- Observability / analytics / tracing (connector or signed-in browser)
- Optional: release notes, PR link, prior incident doc

## Sequence of work

1. Restate the symptom, window, and services in scope.
2. Pull current dashboards and traces. Screenshot the relevant state. Keep the source URL.
3. Compare with the previous comparable window when data exists.
4. Identify the highest-confidence hotspot. Prefer one primary issue.
5. Write up using `/workspace/grok-bots/workspace/templates/investigation.md`.
6. List follow-up checks. Do not apply fixes.

## How to validate

- Every numeric claim has a link or screenshot.
- Facts and hypotheses are in separate sections.
- Action log lists what was opened and what was not changed.

## What to return

Short summary (highest-impact issue first), evidence section, hypotheses, unanswered questions, file path of the write-up.

## What requires approval

Changing alerts, dashboards, feature flags, production config, paging, or posting to Slack/status pages.
