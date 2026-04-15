---
name: openclaw-lobster-feed-hermes
description: Upgrade a machine that already runs OpenClaw to Hermes with a distribution-ready one-click installer, explicit migration defaults, and validation steps.
version: 1.1.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [migration, openclaw, hermes, installer, bootstrap, distribution]
    related_skills: [hermes-agent]
---

# OpenClaw → Hermes migration bootstrap

Use this skill when a machine already has OpenClaw data and you want the fastest safe path to Hermes without rebuilding everything by hand.

This repository is positioned as a **distribution-ready migration product**, not just a private helper script.

---

## When to use

Use this skill when the operator wants to:

1. install Hermes on a machine that already has OpenClaw
2. reuse compatible model, provider, secret, memory, and skill data when possible
3. run the migration with explicit defaults instead of ad-hoc commands
4. finish with a reproducible validation step

Typical source directories:

- `~/.openclaw`
- `~/.clawdbot`
- `~/.moltbot`
- a user-provided custom path via `OPENCLAW_DIR`

---

## What this skill ships

This repo provides two user-facing entrypoints and one internal reference:

- standalone installer: `install.sh`
- helper script: `scripts/openclaw_lobster_feed_install.sh`
- product docs: `README.md` and `README.zh-CN.md`

For public distribution, prefer `install.sh` because it can be run locally or fetched directly from GitHub Raw.

---

## Recommended entrypoints

### Local repo entrypoint

```bash
bash ./install.sh
```

### Raw single-file entrypoint

```bash
curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh | bash
```

### CDN single-file entrypoint (for constrained China-network environments)

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/gaixianggeng/openclaw-lobster-feed-hermes@main/install.sh | bash
```

### Explicit source directory

```bash
OPENCLAW_DIR=/path/to/.openclaw bash ./install.sh
```

Or, if using the Raw entrypoint:

```bash
OPENCLAW_DIR=/path/to/.openclaw bash -c "$(curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh)"
```

---

## Product defaults

This skill standardizes the migration around these defaults:

- migration preset: `full`
- non-interactive behavior: `--yes`
- source handling: prefer explicit `--source`
- overwrite policy: **do not default to `--overwrite`**
- validation: always run `hermes doctor`

These defaults optimize for fast onboarding **without silently overwriting an existing Hermes setup**.

---

## Standard execution flow

### Step 1 — locate the OpenClaw source

Check these locations in order:

1. `~/.openclaw`
2. `~/.clawdbot`
3. `~/.moltbot`
4. `OPENCLAW_DIR` if explicitly provided

Example:

```bash
for d in "$HOME/.openclaw" "$HOME/.clawdbot" "$HOME/.moltbot"; do
  [ -d "$d" ] && echo "$d"
done
```

If no source directory exists, stop and use the normal Hermes install path instead of pretending migration can proceed.

### Step 2 — check prerequisites

Minimum checks:

```bash
git --version
command -v curl
command -v hermes || true
```

Why this matters:

- the official Hermes installer depends on `git`
- `curl` is required for the Raw installer path
- if `hermes` already exists, installation can be skipped

### Step 3 — install Hermes if missing

Official installer path:

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"
```

Built-in fallback behavior in this repo's installer:

- first try GitHub Raw
- if that fails, try jsDelivr automatically
- operators can override the primary source with `HERMES_INSTALL_URL`
- operators can append extra candidates with `HERMES_INSTALL_FALLBACK_URLS`

Example overrides:

```bash
HERMES_INSTALL_URL=https://your-approved-mirror.example/install.sh bash ./install.sh
HERMES_INSTALL_FALLBACK_URLS="https://cdn.jsdelivr.net/gh/NousResearch/hermes-agent@main/scripts/install.sh" bash ./install.sh
```

If `hermes` is still not on `PATH`, refresh the shell and verify again:

```bash
source ~/.bashrc
# or
source ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
hermes --version
```

### Step 4 — run the migration

Default command:

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes
```

Use `user-data` only when the operator explicitly says not to migrate provider keys or secrets:

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset user-data --yes
```

Add `--overwrite` only when the operator explicitly authorizes replacing existing Hermes data:

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset full --overwrite --yes
```

### Step 5 — validate

Minimum validation:

```bash
hermes --version
hermes doctor
```

Optional follow-up checks:

```bash
hermes config path
hermes config env-path
hermes model
```

---

## What may be migrated

This workflow relies on Hermes' official OpenClaw migration support. In practice, it may carry over compatible items such as:

### Model and provider configuration

- OpenClaw model defaults
- custom providers
- compatible provider API keys into the Hermes environment

### User assets

- `SOUL.md`
- `MEMORY.md`
- `USER.md`
- OpenClaw skills
- command allowlists
- selected messaging settings
- TTS assets

### Common allowlisted compatible secrets

- `OPENROUTER_API_KEY`
- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `DEEPSEEK_API_KEY`
- `GEMINI_API_KEY`
- `ZAI_API_KEY`
- `MINIMAX_API_KEY`
- `ELEVENLABS_API_KEY`
- `TELEGRAM_BOT_TOKEN`
- `VOICE_TOOLS_OPENAI_KEY`

The migration report remains the source of truth for what actually moved.

---

## Known limits

Keep these limits explicit in any user-facing distribution:

1. not every OpenClaw secret can be imported automatically
2. `source: "file"` and `source: "exec"` secret refs usually require manual follow-up
3. WhatsApp-style pairings are not seamlessly portable
4. if the machine cannot reach `raw.githubusercontent.com`, this repo's installer will try the built-in jsDelivr fallback next; fully locked-down environments may still require an approved internal mirror or a manual fallback
5. imported skills may require a new Hermes session before they become visible

---

## Fallback when GitHub Raw is blocked

If the machine cannot fetch the official installer from `raw.githubusercontent.com`, use the manual Hermes installation path first:

```bash
git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git
cd hermes-agent
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv venv --python 3.11
export VIRTUAL_ENV="$(pwd)/venv"
uv pip install -e ".[all]"
export PATH="$(pwd)/venv/bin:$PATH"
hermes --version
```

Then resume the migration:

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes
hermes doctor
```

---

## Validation standard

Do not call the migration complete unless all of these are true:

1. `hermes --version` runs successfully
2. `hermes claw migrate --source ... --preset full --yes` was actually executed
3. `hermes doctor` was actually executed
4. the report states what migrated successfully and what was skipped or conflicted
5. the migration report path is included in the handoff when available

---

## Operator handoff template

Use this structure when reporting results:

- installation status: whether Hermes was already installed or newly installed
- migration source: the exact OpenClaw directory used
- migration mode: `full` or `user-data`
- migrated items: only items explicitly confirmed by the migration report
- skipped/conflicted items: list them clearly with reasons
- validation result: whether `hermes doctor` passed
- report path: `migration/openclaw/<timestamp>/` under the active Hermes home

---

## Do not do this

- do not default to `--overwrite`
- do not pretend migration can run if no OpenClaw directory exists
- do not describe `skipped` or `conflict` items as successful migrations
- do not claim file-based or exec-based secret refs were reused unless the report proves it
- do not skip `hermes doctor`
