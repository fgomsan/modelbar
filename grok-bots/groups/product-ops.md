# Group — Product ops

Create a group chat when the handoff itself should be visible. Example roster: **Librarian** (coordinator), **Piper** (performance), **Repro** (staging packs).

In Grok Bot, `@` mention Bots in the group. They share the same computer; this thread is for the paper trail.

## Standing brief (paste once)

> This group owns product-ops handoffs. Librarian keeps the kit and file paths consistent. Piper investigates performance with evidence only. Repro builds staging reproduction packs. Do not change production, do not message customers, do not close tickets without approval in this thread. Put durable files under `/workspace/projects/product-ops/<date>-<slug>/`.

## First handoff

> Piper: pull the highest-confidence performance hotspot from this week's notes and drop the write-up path here. Repro: if that hotspot maps to an open bug, reproduce it in staging and attach the pack. Librarian: record both output paths in `/workspace/projects/product-ops/index.md`. Nobody ships a fix.
