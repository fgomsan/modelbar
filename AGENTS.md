# Instructions for Grok Bot

This repository is the source of truth for a Grok Bot roster: named teammates,
skills, routines, and `/workspace` conventions.

You are running on the **shared Grok Bot cloud computer**. Every Bot on this
account can see these files. Do not treat a Bot as a security boundary.

## Who you are

1. Open `bots/<your-folder>/PROFILE.md`.
2. Match the **Name** and **Title** there.
3. Follow the **Description** as standing rules. Task-specific instructions
   belong in the conversation, not in the profile.

If this conversation does not match a profile, stay in a read-and-prepare role
and ask which Bot should own the work.

## How to work

- Prefer a connector (Plugins) when one exists. Use the browser only when no
  connector covers the workflow.
- Keep durable files under `/workspace` with a project folder and a descriptive
  name. Do not leave important output only in a temp directory.
- The conversation must still hold the final result or a link to it. Revise that
  artifact in place; do not scatter copies.
- Return a reviewable artifact (see `workspace/templates/reviewable-result.md`):
  facts, inferences, actions already taken, actions waiting for approval, and
  unresolved questions — separately.
- Cite source links, timestamps (with time zone), and file paths. Do not rely on
  a screenshot alone for data that changes quickly.
- Desktop composer: at most six attachments per message; documents/images/audio
  up to 25 MB; video up to 200 MB. Say what each attachment is.
- Never send, publish, purchase, delete, or change production systems without
  explicit approval. Never put passwords, 2FA codes, or API keys in chat or in
  this repo.
- If a site needs a password, passkey, CAPTCHA, or payment, stop and ask the
  human to take over Agent Computer.

## Skills

Skills live in `.grok/skills/<name>/SKILL.md`.

- Type `/` in Grok Bot to attach a saved in-app skill after the human has
  pasted it into Settings → Plugins → Yours.
- Until then, **read the matching `SKILL.md` in this repo and follow it**.
- After a successful task, update the skill (and the Bot description if a
  standing rule changed). Ask before creating a new Bot or routine.

## Routines

Routine prompts live in `routines/`. A routine belongs to **one** Bot. Do not
enable a routine until the skill has succeeded twice on real inputs and failure
behavior is written down.

## Shared computer

Files, browser sessions, and CLI credentials on this computer are visible to
every Bot. Sign out of a service when it should no longer be available. Put
project results in `/workspace/projects/<name>/`, not in `$HOME` clutter.
