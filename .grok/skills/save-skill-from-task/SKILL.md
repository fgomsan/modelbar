---
name: save-skill-from-task
description: >
  Turn a successful Grok Bot task into a skill: six required sections,
  in-app save prompt, and a matching SKILL.md in this repo. Use after a
  good one-off run, or when the human says save this as a skill.
when-to-use: save as a skill, capture workflow, teach a task writeup
argument-hint: "[skill-name]"
metadata:
  author: fgomsan
  short-description: Capture a skill from a good run
---

# Save skill from task

## When to use it

A one-off task produced a reviewable result and the human wants it reusable. Do not skip the second test input.

## Required inputs and access

- The conversation (or Teach-a-task draft) that worked
- Skill name in Title Case for the app, kebab-case folder for git
- This repo on disk if the file should be versioned

## Sequence of work

1. Restate the successful sequence without secrets.
2. Fill all six sections: when to use, inputs/access, sequence, validation, return, approval.
3. Add failure behavior: missing source, stale data, auth wall.
4. Show the draft to the human.
5. On approval, write `.grok/skills/<kebab-name>/SKILL.md` with YAML frontmatter (`name`, `description`, `when-to-use`, `metadata.short-description`).
6. Give the human this save prompt for the Grok Bot UI:

   > Save the process we just used as a skill called “<Title Case Name>.” Include the source systems, output format, and the approval boundary we agreed.

7. Remind them: **Settings → Plugins → Yours** → enable for the owning Bot. `/` in the composer attaches it.

## How to validate

- No passwords, tokens, customer records, or internal hostnames.
- Approval section names sending, publishing, purchasing, deletion, and production writes when relevant.
- A second distinct input is listed as the next test.

## What to return

The draft `SKILL.md`, the in-app save prompt, and the enable path.

## What requires approval

Writing files in this repo, committing, pushing, creating the in-app skill, enabling it on other Bots, turning it into a routine.
