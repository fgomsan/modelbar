# Routine — Weekly expense reconcile

Paste this to **Ledger** after two good one-off weeks. Then **Test run**.

> Every Friday at 4:00 PM in my Grok Bot time zone, run the Weekly expense reconcile skill against this week's expense system export and the attached policy. Post the summary and draft follow-ups here. Do not send messages or change reimbursements. If the expense system is unavailable, report the failure instead of using last week's file.

Confirm before saving:

- Owning Bot: Ledger
- Schedule: Friday 16:00, app time zone
- Input: expense system + policy
- Result: summary + drafts in this conversation
- Approval: no sends, no reimbursement writes
- Missing source: fail, do not reuse last week
