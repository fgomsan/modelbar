# Routine — Weekday paid media

Paste this to **Spend** after two good one-off reviews. Then **Test run**.

> Every weekday at 9:30 AM in my Grok Bot time zone, run the Campaign budget review skill against live ads data and this month's budget. Post the recommendation and Slack draft here. Do not change budgets or send the message. If a platform is unavailable, report the failure instead of using cached numbers as current.

Confirm before saving:

- Owning Bot: Spend
- Schedule: weekdays 09:30, app time zone
- Input: ads platforms + budget targets
- Result: memo + Slack draft in this conversation
- Approval: no campaign writes, no Slack post
- Missing source: fail that platform, do not backfill
