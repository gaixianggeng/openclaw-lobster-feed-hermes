# openclaw-lobster-feed-hermes

把**已经装好 OpenClaw** 的机器，快速切到 **Hermes** 的一键迁移包。

这个仓库包含两部分：

1. **可发布的 Hermes skill**：`SKILL.md`
2. **可直接执行的一键脚本**：`install.sh`

目标不是“从零手配 Hermes”，而是：

- 安装 Hermes
- 尽量复用 OpenClaw 现有模型 / provider / 兼容密钥
- 迁移 memory / profile / skills / allowlist 等兼容资产
- 最后用 `hermes doctor` 验收

---

## 适用场景

适合这类用户：

- 本机已经安装过 OpenClaw
- 想尽快迁到 Hermes
- 希望尽量复用已有模型配置与 provider
- 不想手动翻很多文档

支持自动探测这些源目录：

- `~/.openclaw`
- `~/.clawdbot`
- `~/.moltbot`

也支持手动指定：

```bash
OPENCLAW_DIR=/path/to/.openclaw bash ./install.sh
```

---

## 一键跑法

### 方式 A：直接跑仓库里的脚本

```bash
bash ./install.sh
```

### 方式 B：直接跑 GitHub Raw 单文件脚本

```bash
curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh | bash
```

如果 OpenClaw 不在默认目录：

```bash
OPENCLAW_DIR=/path/to/.openclaw bash ./install.sh
```

脚本会自动做：

1. 检查 `git`
2. 探测 OpenClaw 目录
3. 如未安装 Hermes，则执行官方安装器
4. 执行：
   ```bash
   hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes
   ```
5. 运行：
   ```bash
   hermes doctor
   ```

---

## 默认策略

- **默认 full compatible migration**
- **默认不加 `--overwrite`**
- **默认显式指定 `--source`**
- **没有 `hermes doctor` 不算完成**

这意味着它偏向“先跑通、少交互、但不主动覆盖现有 Hermes 数据”。

---

## 安全边界 / 已知限制

这个仓库复用的是 Hermes 官方迁移能力，因此有这些边界：

1. 不是所有 OpenClaw secret 都能自动迁移
2. `source: "file"` / `source: "exec"` 这类 secret refs 通常不能自动解析
3. WhatsApp 这类需要重新 pairing 的能力不能直接无缝平移
4. 如果用户本机无法访问 `raw.githubusercontent.com`，官方安装器可能失败，此时需要走 README / SKILL 里的手动安装 fallback

---

## 复用范围（依赖 Hermes 官方迁移能力）

通常会尽量导入：

- 默认模型配置
- 自定义 provider
- allowlist 内兼容 API keys / secrets
- `SOUL.md`
- `MEMORY.md`
- `USER.md`
- OpenClaw skills
- command allowlist
- 部分 messaging settings
- TTS assets

最终是否真的迁成，以 `hermes claw migrate` 的报告为准。

---

## 作为 skill 使用

如果你想把这个仓库当成可分发的 skill 源：

- 主 skill 文件：`SKILL.md`
- 备用脚本：`scripts/openclaw_lobster_feed_install.sh`
- 单文件入口：`install.sh`

skill 名称：

- `openclaw-lobster-feed-hermes`

---

## 推荐验收命令

```bash
hermes --version
hermes doctor
```

如果想继续验证模型：

```bash
hermes model
hermes
```

---

## License

MIT
