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
