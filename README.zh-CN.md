# openclaw-lobster-feed-hermes

[English](./README.md) | [简体中文](./README.zh-CN.md)

**给已经安装了 OpenClaw 的机器，一键安装 Hermes，并尽量自动复用可迁移资产。**

这个项目提供的是一条面向分发的升级路径，不只是一个临时脚本：

- 安装 Hermes
- 尽量复用兼容的模型 / provider 配置
- 导入支持的密钥、记忆、人格、skills、allowlist
- 最后用 `hermes doctor` 做验收

它的目标是把“从 OpenClaw 切到 Hermes”做成一个**可分发、可复用、可产品化**的迁移包。

---

## 仓库包含什么

这个仓库包含两个交付物：

1. **可发布的 Hermes skill** —— `SKILL.md`
2. **可独立运行的一键脚本** —— `install.sh`

其中 `install.sh` 是单文件入口，可以直接通过 GitHub Raw 执行，不要求用户先 clone 仓库。

---

## 适合谁

适合这类用户：

- 已经装过 OpenClaw
- 想快速切到 Hermes
- 希望尽量保留已有模型 / provider 配置
- 不想手动从零重建环境

脚本会自动探测这些常见目录：

- `~/.openclaw`
- `~/.clawdbot`
- `~/.moltbot`

也支持手动指定路径：

```bash
OPENCLAW_DIR=/path/to/.openclaw bash ./install.sh
```

---

## 快速开始

### 方式 A：直接运行仓库里的脚本

```bash
bash ./install.sh
```

### 方式 B：直接运行 GitHub Raw 单文件脚本

```bash
curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh | bash
```

如果 OpenClaw 不在默认路径：

```bash
OPENCLAW_DIR=/path/to/.openclaw bash -c "$(curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh)"
```

---

## Demo

如果你想先看安装器的交互风格、再决定是否在真实 OpenClaw 目录上执行，可以先看这份已捕获的 CLI 输出：

- [`docs/demo-cli-invalid-source.md`](./docs/demo-cli-invalid-source.md)

这个 demo 故意传入了一个不存在的 `OPENCLAW_DIR`，用于展示分步骤输出和报错提示，同时避免对真实迁移环境产生副作用。

---

## 示例场景

### 1. 在已有 OpenClaw 工作机上原地升级

适用于机器已经在标准目录里安装了 OpenClaw，你只想用最低操作成本切到 Hermes：

```bash
bash ./install.sh
```

预期流程：

- 自动探测 `~/.openclaw`、`~/.clawdbot` 或 `~/.moltbot`
- 如果 Hermes 缺失则先安装
- 用 `full` preset 执行迁移
- 最后运行 `hermes doctor`

### 2. 从非标准目录迁移

适用于 OpenClaw 数据放在外接磁盘、其他 home 目录，或手动改名过的目录：

```bash
OPENCLAW_DIR=/data/team-a/.openclaw bash ./install.sh
```

这样可以显式指定迁移来源，不依赖自动探测。

### 3. 作为运维 / 客服 / onboarding 文档里的复制即用命令

适用于你要把这条迁移流程分发到内部 SOP、客户接入文档或交接手册里：

```bash
OPENCLAW_DIR=/path/to/.openclaw bash -c "$(curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh)"
```

这种方式分发成本最低，不要求用户先 clone 仓库。

---

## 脚本会做什么

默认流程是：

1. 检查 `git` 是否存在
2. 探测 OpenClaw 目录
3. 如果 Hermes 未安装，则先安装 Hermes
4. 执行：
   ```bash
   hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes
   ```
5. 执行：
   ```bash
   hermes doctor
   ```

---

## 默认产品策略

这个包默认选择的是“低摩擦但不过度冒进”的迁移策略：

- **默认迁移模式：** `full`
- **默认行为：** `--yes`
- **不会默认加：** `--overwrite`
- **始终优先：** 显式 `--source`
- **没有执行：** `hermes doctor` 不算完成

也就是说，它追求的是：

> **先尽快跑通，但不静默覆盖用户已有的 Hermes 数据。**

---

## 可能复用哪些东西

这个仓库依赖 Hermes 官方 OpenClaw 迁移能力，通常会尽量迁移这些兼容内容：

- 默认模型配置
- 自定义 provider
- allowlist 内兼容 API keys / secrets
- `SOUL.md`
- `MEMORY.md`
- `USER.md`
- OpenClaw skills
- command allowlists
- 部分 messaging settings
- TTS assets

最终以 Hermes 的迁移报告为准，报告才是实际结果的唯一依据。

---

## 安全说明

如果你要把它当作团队内部或面向客户的分发入口，建议把下面这些安全前提写清楚：

1. **先审脚本，再决定是否 `curl | bash`。** 用在正式 onboarding / SOP 时，优先给仓库链接、固定已审核 commit，或者把脚本纳入你自己的内部分发源。
2. **在正确的账号和机器边界内执行迁移。** 脚本会读取现有 OpenClaw 目录，当前操作者账号可能接触到 provider 配置、记忆文件以及兼容的 secrets。
3. **把迁移输出和后续排查文件都当作敏感信息处理。** 如果日志、配置片段或迁移报告里可能带有 provider URL、token 或个人记忆内容，就不要直接贴到工单、聊天记录或 git 提交里。
4. **迁移后重新核验 secrets。** Hermes 会尽量复用支持的 secrets，但不是所有 OpenClaw secret source 都能无损迁移；如果原机器或原操作者本应失去访问权，请补做校验与轮换。

---

## 已知限制

因为它复用的是 Hermes 官方迁移路径，所以仍然有这些边界：

1. 不是所有 OpenClaw secret 都能自动导入
2. `source: "file"` 和 `source: "exec"` 这类 secret refs 通常需要手工补处理
3. 像 WhatsApp 这类 pairing 关系不能无缝平移
4. 如果目标机器访问不了 `raw.githubusercontent.com`，Hermes 官方安装器阶段可能失败，需要改走手动安装 fallback

---

## 仓库结构

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

## 作为 Hermes skill 使用

如果你要把它当作 skill 源分发：

- skill 文件：`SKILL.md`
- 单文件脚本：`install.sh`
- 内部辅助脚本：`scripts/openclaw_lobster_feed_install.sh`

skill 名称：

- `openclaw-lobster-feed-hermes`

---

## 验收建议

建议迁移完成后至少执行：

```bash
hermes --version
hermes doctor
```

如果你还想继续核验模型 / provider：

```bash
hermes model
hermes
```

---

## License

MIT
