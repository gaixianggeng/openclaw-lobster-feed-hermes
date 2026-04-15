---
name: openclaw-lobster-feed-hermes
description: 已安装 OpenClaw 的机器上，一键安装 Hermes 并尽量复用 OpenClaw 现有模型、provider、兼容密钥与用户资产。适合“先喂龙虾，再切 Hermes”的快速迁移场景。
version: 1.0.0
author: Taiyi / Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [openclaw, hermes, migration, install, one-click, bootstrap]
    related_skills: [hermes-agent, openclaw-migration]
---

# OpenClaw 龙虾投喂版：一键安装 Hermes

## 适用场景
当用户已经在本机装好 OpenClaw（或旧目录 `~/.clawdbot` / `~/.moltbot`），现在想：

1. 直接装上 Hermes
2. 尽量复用 OpenClaw 现有模型 / provider / 兼容密钥
3. 少手配，尽快跑起来
4. 保留后续回滚与人工检查空间

这个 skill 不是“从零配置 Hermes”，而是“吃掉现成 OpenClaw 配置做快速落地”。

---

## 默认最快路径

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"
hermes claw migrate --source ~/.openclaw --preset full --yes
hermes doctor
```

如果源目录不是 `~/.openclaw`，则替换成：

- `~/.clawdbot`
- `~/.moltbot`
- 用户显式给出的自定义路径

---

## 官方已确认可复用的东西

根据 Hermes 官方 OpenClaw 迁移文档与 CLI 文档，可迁移/复用的关键项包括：

### 模型 / Provider 侧
- `agents.defaults.model` → Hermes `config.yaml` 的模型配置
- `models.providers.*` → Hermes `custom_providers`
- 兼容的 provider API keys → 当前 Hermes home 下的 `.env`

### 用户资产侧
- `SOUL.md`
- `MEMORY.md`
- `USER.md`
- OpenClaw skills
- command allowlist
- 部分 messaging settings
- TTS assets

### allowlist 内兼容密钥（以 Hermes 官方迁移器为准）
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

---

## 硬规则

1. 默认不覆盖已有 Hermes 数据
   - 不主动加 `--overwrite`
   - 只有用户明确要求时才覆盖

2. 默认显式指定 `--source`
   - 不只依赖自动探测

3. 没有验收命令，不算完成
   - 至少执行：
     - `hermes --version`
     - `hermes claw migrate ...`
     - `hermes doctor`

4. 如果迁移报告里有 `conflict` / `skipped` / unsupported secret refs，要如实汇报
   - 不能把“已跳过”说成“已复用成功”

5. 如果用户明确要“一键”且未要求精细交互，默认用：
   - `--preset full --yes`
   - 但仍然不默认加 `--overwrite`

---

## 标准执行流程

### Step 1：探测 OpenClaw 源目录
优先顺序：

1. `~/.openclaw`
2. `~/.clawdbot`
3. `~/.moltbot`
4. 用户给出的自定义路径

建议命令：

```bash
for d in "$HOME/.openclaw" "$HOME/.clawdbot" "$HOME/.moltbot"; do
  [ -d "$d" ] && echo "$d"
done
```

如果都不存在：
- 停止
- 明确说明没有找到 OpenClaw 目录
- 要求用户给出 `--source` 路径，或改走普通 Hermes 安装

### Step 2：检查安装前提

```bash
git --version
command -v hermes || true
```

说明：
- 官方安装文档写明 Git 是前提
- Hermes 若已存在，则跳过安装阶段，直接走迁移

### Step 3：安装 Hermes（若未安装）

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"
```

如果 `hermes` 仍不可执行，再提示用户：

```bash
source ~/.bashrc
# 或
source ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

然后再次验证：

```bash
hermes --version
```

### Step 4：执行一键迁移（默认 full compatible migration）

如果源目录为 `$OPENCLAW_DIR`：

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes
```

#### 何时改用 `user-data`
只有当用户明确说：
- 不要碰 API keys / secrets
- 只迁用户数据

才改为：

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset user-data --yes
```

#### 何时加 `--overwrite`
只有当用户明确说：
- 我知道本机 Hermes 已有旧数据
- 我就是要覆盖

才使用：

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset full --overwrite --yes
```

### Step 5：验收
最低验收：

```bash
hermes --version
hermes doctor
```

可选补验：

```bash
hermes config path
hermes config env-path
```

如果用户要继续验证模型可用，再引导：

```bash
hermes model
hermes
```

---

## 推荐的一键脚本

本 skill 自带辅助脚本：

- `scripts/openclaw_lobster_feed_install.sh`

推荐运行：

```bash
bash ./scripts/openclaw_lobster_feed_install.sh
```

这个脚本会做：
1. 探测 OpenClaw 目录
2. 检查 Git
3. 若 Hermes 未安装则执行官方安装器
4. 显式指定 `--source` 执行 `hermes claw migrate --preset full --yes`
5. 跑 `hermes doctor`

---

## 结果汇报模板

执行后建议按这个结构汇报：

- 安装状态：Hermes 是否已安装 / 版本号
- 迁移来源：实际使用的 OpenClaw 目录
- 迁移模式：`full` / `user-data`
- 复用成功项：只列 report 里明确 `migrated` 的内容
- 跳过 / 冲突项：列出 `skipped` / `conflict` 与原因
- 验收结果：`hermes doctor` 是否通过
- 报告路径：当前 Hermes home 下的 `migration/openclaw/<timestamp>/`

---

## 常见卡点与处理

### 1. `raw.githubusercontent.com` 拉不下来
现象：安装器命令失败。

处理：改走手动安装：

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

然后再执行：

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes
```

### 2. 迁移后模型没复用成功
原因通常是：
- OpenClaw 的 key 不在 allowlist 内
- key 用的是 `source: "file"` / `source: "exec"`，这两类通常不能自动解析
- provider 配置是定制版，Hermes 不能完全等价映射

处理：
- 查看迁移报告
- 手动补 `.env`
- 用 `hermes model` 重新绑定 provider

### 3. 已有 Hermes 数据冲突
默认行为是跳过，不覆盖。

处理：
- 保守迁移：保持默认
- 强制覆盖：用户明确授权后加 `--overwrite`

### 4. skills 导入了但当前会话不生效
官方说明：新导入 skills 需要新 session / 重启后生效。

### 5. WhatsApp 不能直接复用
官方说明：WhatsApp 需要重新 pairing，不能靠 token 直接平移。

---

## 验收标准

满足以下 4 条才算完成：

1. `hermes --version` 能正常输出
2. `hermes claw migrate --source ... --preset full --yes` 已实际执行
3. `hermes doctor` 已实际执行
4. 已给出迁移报告路径，并说明哪些复用成功、哪些没迁过来

---

## 不要做的事

- 不要默认加 `--overwrite`
- 不要在没有发现 OpenClaw 目录时假装能迁移
- 不要把 `skipped` / `conflict` 说成成功
- 不要把无法自动解析的 secret refs 说成“已复用”
- 不要跳过最终 `hermes doctor`
