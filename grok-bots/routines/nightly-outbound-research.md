# Routine — Nightly outbound research

Paste this to **Quill** after two successful review lists. Then **Test run**.

> Every weekday at 6:00 PM in my Grok Bot time zone, run the Research outbound skill against the current CRM view we named in this conversation. Post the review list here. Skip anyone already in an active sequence. Do not send or enroll anyone. If the CRM view is unavailable, report the failure instead of using an old export.

Confirm before saving:

- Owning Bot: Quill
- Schedule: weekdays 18:00, app time zone
- Input: named CRM view
- Result: review list in this conversation
- Approval: no sends, no enrollment
- Missing source: fail, do not reuse yesterday
