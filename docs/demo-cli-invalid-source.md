# Demo: installer UX with an invalid source path

This transcript is a safe CLI demo for distribution docs. It shows the installer UX and error guidance without performing a real migration.

## Command

```bash
OPENCLAW_DIR=/tmp/openclaw-demo-missing-path bash ./install.sh
```

## Output

```text
[STEP 1/5] 检查安装前提
[INFO] OpenClaw → Hermes 一键迁移开始
[INFO] 默认策略：安装 Hermes（若缺失）→ 迁移兼容资产 → 运行 hermes doctor
[INFO] 安全默认值：preset=full, --yes, 不默认覆盖已有 Hermes 数据
[INFO] git: git version 2.50.1 (Apple Git-155)

[STEP 2/5] 定位 OpenClaw 源目录
[ERROR] 你指定的 OPENCLAW_DIR 不存在：/tmp/openclaw-demo-missing-path
        本地脚本：OPENCLAW_DIR=/path/to/.openclaw bash ./install.sh
        Raw 单文件：OPENCLAW_DIR=/path/to/.openclaw bash -c "$(curl -fsSL https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh)"
```

## Why this demo exists

- shows the step-based installer output
- shows the explicit error message when `OPENCLAW_DIR` is wrong
- shows the follow-up commands the user should run next
- avoids mutating a real Hermes/OpenClaw environment during documentation capture
