# openclaw-lobster-feed-hermes

[English](./README.md) | [简体中文](./README.zh-CN.md)

**One-click install Hermes on a machine that already runs OpenClaw, then migrate the reusable parts automatically.**

This project packages a practical upgrade path for existing OpenClaw users who want to move fast:

- install Hermes
- reuse compatible model / provider settings when possible
- import supported keys, memories, persona, skills, and allowlists
- finish with `hermes doctor`

It is designed as a **distribution-ready migration product**, not just a personal helper script.

---

## What’s inside

This repository ships two deliverables:

1. **A publishable Hermes skill** — `SKILL.md`
2. **A standalone one-click script** — `install.sh`

The standalone entrypoint means users can run it directly from GitHub Raw without cloning the repo first.

---

## Who this is for

This is for users who:

- already have OpenClaw installed
- want to switch to Hermes quickly
- want to preserve as much existing setup as possible
- do not want to manually rebuild their environment from scratch

The script auto-detects these common source directories:

- `~/.openclaw`
- `~/.clawdbot`
- `~/.moltbot`

Or you can point it at a custom location:

```bash
OPENCLAW_DIR=/path/to/.openclaw bash ./install.sh
```

---

## Quick start

### Option A — run the local script

```bash
bash ./install.sh
```

### Option B — run directly from GitHub Raw

```bash
curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh | bash
```

If OpenClaw lives somewhere else:

```bash
OPENCLAW_DIR=/path/to/.openclaw bash -c "$(curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh)"
```

---

## Demo

Want to preview the installer UX before touching a real OpenClaw directory? See the captured CLI transcript:

- [`docs/demo-cli-invalid-source.md`](./docs/demo-cli-invalid-source.md)

This demo intentionally uses a missing `OPENCLAW_DIR` so the repository can show the step-based output and error guidance without performing a real migration.

---

## Example scenarios

### 1. Upgrade an existing OpenClaw workstation in place

Use this when the machine already has OpenClaw in a standard directory and you want the fastest path to Hermes:

```bash
bash ./install.sh
```

Expected flow:

- auto-detect `~/.openclaw`, `~/.clawdbot`, or `~/.moltbot`
- install Hermes if missing
- migrate with the `full` preset
- finish with `hermes doctor`

### 2. Migrate from a non-standard source directory

Use this when the OpenClaw data lives on an external disk, another home directory, or a manually renamed folder:

```bash
OPENCLAW_DIR=/data/team-a/.openclaw bash ./install.sh
```

This keeps the migration source explicit and avoids depending on auto-detection.

### 3. Run the migration from a support or onboarding playbook

Use the raw entrypoint when you want a copy-pasteable command for internal docs, customer onboarding, or operator handoff:

```bash
OPENCLAW_DIR=/path/to/.openclaw bash -c "$(curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh)"
```

This is the lowest-friction way to distribute the workflow without asking the user to clone the repository first.

---

## What the script does

The default flow is:

1. verify `git` exists
2. detect the OpenClaw directory
3. install Hermes if it is missing
4. run:
   ```bash
   hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes
   ```
5. run:
   ```bash
   hermes doctor
   ```

---

## Product defaults

This package intentionally chooses the fastest safe default for distribution:

- **default migration mode:** `full`
- **default behavior:** `--yes`
- **does not default to:** `--overwrite`
- **always prefers:** explicit `--source`
- **does not claim success without:** `hermes doctor`

That means it is optimized for **low-friction onboarding without silently overwriting an existing Hermes setup**.

---

## What may be reused

This repository relies on Hermes’ official OpenClaw migration support. In practice, it will try to carry over compatible items such as:

- default model settings
- custom providers
- allowlisted compatible API keys / secrets
- `SOUL.md`
- `MEMORY.md`
- `USER.md`
- OpenClaw skills
- command allowlists
- selected messaging settings
- TTS assets

The migration report remains the source of truth for what actually moved.

---

## Security notes

Before using this as a team-facing or customer-facing distribution entrypoint, keep these safety rules explicit:

1. **Review the script before piping it into `bash`.** For production onboarding docs, prefer linking the repository, pinning a reviewed commit, or vendoring the script internally.
2. **Run the migration with the right account and host boundary.** The script reads from an existing OpenClaw directory and may expose provider configuration, memory files, and compatible secrets to the current operator account.
3. **Treat migration output and follow-up files as sensitive.** Do not paste logs, config snippets, or migration reports into tickets, chats, or commits if they may contain provider URLs, tokens, or personal memory content.
4. **Re-check secrets after migration.** Hermes can reuse supported secrets, but not every OpenClaw secret source is portable; validate imported credentials and rotate them if the original machine or operator boundary should no longer retain access.

---

## Known limits

Because this uses Hermes’ official migration path, some limits still apply:

1. not every OpenClaw secret can be imported automatically
2. `source: "file"` and `source: "exec"` secret refs usually need manual follow-up
3. WhatsApp-style pairings are not seamlessly portable
4. if the target machine cannot reach `raw.githubusercontent.com`, the Hermes installer step may fail and require the manual fallback path

---

## Repository structure

```text
.
├── README.md
├── README.zh-CN.md
├── SKILL.md
├── install.sh
├── docs/
│   └── demo-cli-invalid-source.md
├── scripts/
│   └── openclaw_lobster_feed_install.sh
└── LICENSE
```

---

## As a Hermes skill

If you want to distribute this through a skill-style workflow:

- skill file: `SKILL.md`
- standalone script: `install.sh`
- internal helper script: `scripts/openclaw_lobster_feed_install.sh`

Skill name:

- `openclaw-lobster-feed-hermes`

---

## Verification

Recommended post-run checks:

```bash
hermes --version
hermes doctor
```

If you want to verify model/provider selection after migration:

```bash
hermes model
hermes
```

---

## License

MIT
