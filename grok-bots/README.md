# Grok Bots

Aquí voy a experimentar con grok bots.

Kit versionado para **[Grok Bot](https://docs.x.ai/grok-bot/overview)** de xAI: compañeros con nombre, ordenador en la nube, skills y routines.

No es un bot de Discord, Telegram, ni de la API de chat. Es el roster que copias a la app de escritorio (macOS/Windows) o iOS.

Versioned kit for **[Grok Bot](https://docs.x.ai/grok-bot/overview)**: named teammates, a shared cloud computer, skills, and routines.

This is not a Discord/Telegram bot and not a chat-completions client. It is the roster you paste into the Grok Bot app.

Intended remote: `https://github.com/fgomsan/grok-bots`. Kit version: see [`VERSION`](VERSION). Extract: [`EXTRACT.md`](EXTRACT.md).

## Requisitos / Requirements

- Plan eligible: SuperGrok Plus, SuperGrok Heavy, Cursor Pro+, Cursor Ultra, or Cursor Teams Standard/Premium
- [Grok Bot desktop](https://docs.x.ai/grok-bot/get-started) (macOS or Windows) or iOS 18+
- Cursor account (Grok Bot does not support Legacy Privacy Mode)

Linux desktop, Android, and iPad are not supported at launch.

## Cómo cargar el kit / Load the kit

1. Install Grok Bot and sign in with Cursor.
2. Clone this repository onto the **shared Agent Computer**, for example:
   ```text
   /workspace/grok-bots
   ```
3. Create each Bot: **New → Create new agent → Bot actions → Edit Profile**.
4. Paste **Name**, **Title**, and **Description** from `bots/<id>/PROFILE.md`.
5. Send the prompt in `FIRST_TASK.md` (read-only, no external sends).
6. When the result is good, send the save-skill prompt in that file.
7. Enable the in-app skill for that Bot under **Settings → Plugins → Yours**.
8. Only then paste a prompt from `routines/` and use **Test run**.

In chat: `/` attaches a saved skill; `@` attaches Bots, groups, routines, and connectors.

New role: copy [`bots/_template`](bots/_template) and follow [`promote-to-durable-bot`](.grok/skills/promote-to-durable-bot/SKILL.md).

## Roster

Official xAI use-case roles plus a Librarian that owns this kit on the computer.

| Bot | Title | Owns | Profile |
| --- | --- | --- | --- |
| Librarian | Roster keeper | This repo on the cloud computer | [`bots/librarian`](bots/librarian/PROFILE.md) |
| Piper | Product performance | Investigations with evidence | [`bots/piper`](bots/piper/PROFILE.md) |
| Repro | Bug reproduction | Staging repro packs | [`bots/repro`](bots/repro/PROFILE.md) |
| Scribe | Chief of staff | Source-linked digest | [`bots/scribe`](bots/scribe/PROFILE.md) |
| Harbor | Account health | Ranked watch list | [`bots/harbor`](bots/harbor/PROFILE.md) |
| Quill | Sales Outbound | Research and review-ready outreach | [`bots/quill`](bots/quill/PROFILE.md) |
| Scout | Talent Scout | Sourcing shortlist, no contact | [`bots/scout`](bots/scout/PROFILE.md) |
| Spend | Paid Media | Budget recommendations | [`bots/spend`](bots/spend/PROFILE.md) |
| Ledger | Expense Manager | Weekly reconcile and drafts | [`bots/ledger`](bots/ledger/PROFILE.md) |

Focused Bots beat one catch-all. An account can have up to 50 Bots and group chats combined. All of them share **one** computer: files, cookies, and CLI credentials.

Start with Librarian + the one role you will actually run this week. Duplicate a Bot (same role, new scope) instead of stretching one description.

## Skills

Grok discovers folders under [`.grok/skills/`](.grok/skills/). Each `SKILL.md` is also the text to save in Grok Bot (**Settings → Plugins** or *“Save this process as a skill named …”*).

| Skill | When |
| --- | --- |
| [`load-this-kit`](.grok/skills/load-this-kit/SKILL.md) | Clone/sync this repo on the Agent Computer |
| [`save-skill-from-task`](.grok/skills/save-skill-from-task/SKILL.md) | Turn a good run into a skill |
| [`promote-to-durable-bot`](.grok/skills/promote-to-durable-bot/SKILL.md) | Librarian: task → profile → skill → routine |
| [`investigate-performance`](.grok/skills/investigate-performance/SKILL.md) | Piper: latency/error investigation |
| [`reproduce-bug`](.grok/skills/reproduce-bug/SKILL.md) | Repro: staging reproduction pack |
| [`morning-digest`](.grok/skills/morning-digest/SKILL.md) | Scribe: daily attention list |
| [`weekly-account-health`](.grok/skills/weekly-account-health/SKILL.md) | Harbor: ranked watch list |
| [`research-outbound`](.grok/skills/research-outbound/SKILL.md) | Quill: ICP research, no send |
| [`source-candidates`](.grok/skills/source-candidates/SKILL.md) | Scout: shortlist, no contact |
| [`campaign-budget-review`](.grok/skills/campaign-budget-review/SKILL.md) | Spend: recs, no budget writes |
| [`weekly-expense-reconcile`](.grok/skills/weekly-expense-reconcile/SKILL.md) | Ledger: policy-cited summary |

A useful skill states: when to use it, required inputs, sequence, how to validate, what to return, and what needs approval.

When **Teach a task** is in the computer view, record one browser path (up to ten minutes, no microphone). Review the draft skill, add failure and approval rules, then test on a second input. If the control is missing, save from written instructions instead.

## Routines

A **skill** is how. A **routine** is when (schedule or event) and **which Bot** owns it. Max 50 routines per Bot. Background runs continue with the laptop closed.

| Routine | Owner | File |
| --- | --- | --- |
| Weekday 08:00 digest | Scribe | [`routines/weekday-morning-digest.md`](routines/weekday-morning-digest.md) |
| Weekly account health | Harbor | [`routines/weekly-account-health.md`](routines/weekly-account-health.md) |
| Nightly outbound research | Quill | [`routines/nightly-outbound-research.md`](routines/nightly-outbound-research.md) |
| Weekday paid media | Spend | [`routines/weekday-paid-media.md`](routines/weekday-paid-media.md) |
| Weekly expense reconcile | Ledger | [`routines/weekly-expense-reconcile.md`](routines/weekly-expense-reconcile.md) |
| Event: needs repro | Repro | [`routines/event-needs-repro.md`](routines/event-needs-repro.md) |

Test the skill twice before automating. Use **Test run**; it does real work.

## Connectors

[`CONNECTORS.md`](CONNECTORS.md) maps each Bot to the official plugin list. Install under **Settings → Plugins**. Event routines use Cursor account integrations, not the Slack/GitHub plugin.

## Group and sharing

- [`groups/product-ops.md`](groups/product-ops.md) — Librarian + Piper + Repro.
- [`groups/sales-outbound.md`](groups/sales-outbound.md) — Quill + Scribe.
- [`groups/hiring.md`](groups/hiring.md) — Scout + Scribe.
- [`SHARE.md`](SHARE.md) — strip secrets before a public Bot share link.

## Safety (non-negotiable)

- Do not use separate Bots as a security boundary.
- Strip secrets before [sharing a Bot](https://docs.x.ai/grok-bot/bots). Share links are public copies of config, not of your computer.
- Passwords, 2FA, CAPTCHAs, and payments: human takes over **Agent Computer**. Never paste them in chat.
- Sending, publishing, purchasing, deleting, and production changes stay behind approval.
- Put standing rules in the **description**; put the day’s work in the **message**.

Official docs: [overview](https://docs.x.ai/grok-bot/overview) · [get started](https://docs.x.ai/grok-bot/get-started) · [bots](https://docs.x.ai/grok-bot/bots) · [skills & routines](https://docs.x.ai/grok-bot/skills-routines-and-automations) · [computer](https://docs.x.ai/grok-bot/computer-and-apps) · [approvals](https://docs.x.ai/grok-bot/approvals-security-and-privacy)

## Check

From the root of **this** kit:

```bash
python3 scripts/check_roster.py
```

## Extraer / Publish to github.com/fgomsan/grok-bots

Full playbook: [`EXTRACT.md`](EXTRACT.md). From a machine logged in as **fgomsan** with write access to that repo:

```bash
./grok-bots/scripts/publish.sh --force   # nested in ModelBar
./scripts/publish.sh --force             # kit is already the git root
```

`--force` replaces the GitHub-generated README on `main`. This Cloud Agent cannot push (token is scoped to ModelBar) until Cursor’s GitHub App is granted `fgomsan/grok-bots`.

## License

MIT.
