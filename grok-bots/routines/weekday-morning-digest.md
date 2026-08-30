# Routine — Weekday morning digest

Paste this to **Scribe** after the skill has succeeded on two real mornings. Then use **Test run** before enabling.

> Every weekday at 8:00 AM in my Grok Bot time zone, run the Morning digest skill against the current priority document in this conversation (or `/workspace/projects/digest/priorities.md` if I have placed it there). Post the linked digest here. Do not send messages or change meetings. If a source is unavailable, report the failure instead of using old data or memory.

Confirm before saving:

- Owning Bot: Scribe
- Schedule: weekdays 08:00, app time zone
- Input: priority document
- Result: digest in this conversation
- Approval: no sends, no calendar writes
- Missing source: fail that section, do not backfill

A Bot can own up to 50 routines. Deleting a routine has no undo. Hiding Scribe does **not** pause this routine — pause it under **View conversation details → Routines**.
