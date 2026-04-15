#!/usr/bin/env bash
set -euo pipefail

find_openclaw_dir() {
  local candidates=("$HOME/.openclaw" "$HOME/.clawdbot" "$HOME/.moltbot")
  local d
  for d in "${candidates[@]}"; do
    if [ -d "$d" ]; then
      printf '%s\n' "$d"
      return 0
    fi
  done
  return 1
}

if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] git 未安装；Hermes 官方安装器要求 git 可用。"
  exit 1
fi

OPENCLAW_DIR="${OPENCLAW_DIR:-}"
if [ -z "$OPENCLAW_DIR" ]; then
  if ! OPENCLAW_DIR="$(find_openclaw_dir)"; then
    echo "[ERROR] 未发现 OpenClaw 目录（~/.openclaw / ~/.clawdbot / ~/.moltbot）。"
    echo "        你可以手动指定：OPENCLAW_DIR=/path/to/.openclaw bash $0"
    exit 1
  fi
fi

export PATH="$HOME/.local/bin:$PATH"

if ! command -v hermes >/dev/null 2>&1; then
  echo "[INFO] 未检测到 hermes，开始执行官方安装器..."
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v hermes >/dev/null 2>&1; then
  echo "[ERROR] 安装后仍找不到 hermes。请先执行："
  echo "        source ~/.bashrc    # 或 source ~/.zshrc"
  echo "        export PATH=\"$HOME/.local/bin:$PATH\""
  exit 1
fi

echo "[INFO] OpenClaw source: $OPENCLAW_DIR"
echo "[INFO] Hermes version: $(hermes --version)"

echo "[INFO] 开始迁移：full compatible migration"
hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes

echo "[INFO] 运行 hermes doctor 验收"
set +e
hermes doctor
doctor_rc=$?
set -e
if [ "$doctor_rc" -ne 0 ]; then
  echo "[WARN] hermes doctor 返回非 0（exit=$doctor_rc）；请根据输出继续补配置。"
fi

echo "[DONE] 一键安装 + 迁移已跑完。"
echo "       下一步建议：hermes"
echo "       如需验证模型选择：hermes model"
