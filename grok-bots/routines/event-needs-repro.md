# Routine — Event: needs repro

Cursor account integrations can start a routine from a Slack or GitHub event. They are separate from Slack/GitHub **plugins** and may need their own connection.

Paste this to **Repro** after the reproduce-bug skill works on two tickets. Keep the matcher **narrow**. Then **Test run**.

> When a message in `#customer-escalations` contains a support ticket link and the phrase “needs repro,” open the ticket, reproduce the issue in staging using a fresh test account, and post a repro pack in this conversation. Never post back to Slack without approval. Never use production customer data. If staging or the ticket is unavailable, report the failure instead of guessing.

Confirm before saving:

- Owning Bot: Repro
- Trigger: Slack `#customer-escalations` AND ticket link AND the phrase `needs repro` (not every new message)
- Input: that ticket
- Result: repro pack in this conversation
- Approval: no Slack posts back, no production, no ticket field writes unless approved
- Missing source: fail, do not invent steps
