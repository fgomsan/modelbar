# Routine — Weekly account health

Paste this to **Harbor** after two successful one-off watch lists. Then **Test run**.

> Every Monday at 9:00 AM in my Grok Bot time zone, run the Weekly account health skill against the current account list. Post a linked watch list in this conversation. Do not contact customers. If the source data is unavailable, report the failure instead of using old data.

Confirm before saving:

- Owning Bot: Harbor
- Schedule: Monday 09:00, app time zone
- Input: current CRM view / portfolio export path the human names
- Result: ranked watch list + CSV under `/workspace/projects/account-health/`
- Approval: no customer contact, no CRM edits
- Missing source: fail, do not reuse last week

After a CRM or export format change, pause the routine, re-test the skill, then enable again.
