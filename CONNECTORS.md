# Connectors (Plugins)

Install in **Settings → Plugins**. Type `@` in chat to attach one. Connectors
are **account-wide**: signing in for one Bot shares the session with every Bot
on the computer. Prefer a connector over clicking a website.

Event routines (Slack message, GitHub notification) use **Cursor account
integrations**. Those are not the same as Slack/GitHub plugins and may need a
second connect flow.

Do not put tokens in this file. Authenticate in the app.

| Bot | Official job | Connect (from [use cases](https://docs.x.ai/grok-bot/use-cases)) |
| --- | --- | --- |
| Librarian | Roster keeper | Git (this repo on `/workspace`). No customer systems. |
| Piper | Product Performance | Observability, analytics, incident tooling, source-control links |
| Repro | Bug Reproduction | Issue tracker, staging, browser, network tools |
| Scribe | Chief of Staff | Slack, email, calendar, meeting notes, planning docs |
| Harbor | Account Health | CRM, product usage, support, billing, CS notes |
| Quill | Sales Outbound | CRM, product-intent, company sites, email, professional networks |
| Scout | Talent Scout | ATS, approved sourcing tools, email, calendar |
| Spend | Paid Media | Ads platforms, analytics, budget spreadsheet, Slack |
| Ledger | Expense Manager | Expense system, email, shared drive, finance spreadsheets |

Start with **read-and-prepare**. Add send/write connectors only after the
reviewable result is reliable.

If a site needs a password, passkey, CAPTCHA, or payment: human takes over
**Agent Computer**. Never paste those into chat.
