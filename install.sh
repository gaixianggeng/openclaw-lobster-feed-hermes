#!/usr/bin/env bash
set -euo pipefail

HERMES_INSTALL_URL="https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh"
RAW_INSTALL_URL="https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh"
TOTAL_STEPS=5

log() {
  local level="$1"
  shift
  printf '[%s] %s\n' "$level" "$*"
}

info() {
  log INFO "$@"
}

warn() {
  log WARN "$@" >&2
}

error() {
  log ERROR "$@" >&2
}

step() {
  local num="$1"
  shift
  printf '\n[STEP %s/%s] %s\n' "$num" "$TOTAL_STEPS" "$*"
}

die() {
  error "$1"
  exit 1
}

show_source_override_hint() {
  echo "        本地脚本：OPENCLAW_DIR=/path/to/.openclaw bash ./install.sh"
  echo "        Raw 单文件：OPENCLAW_DIR=/path/to/.openclaw bash -c \"\$(curl -fsSL $RAW_INSTALL_URL)\""
}

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

step 1 "检查安装前提"
info "OpenClaw → Hermes 一键迁移开始"
info "默认策略：安装 Hermes（若缺失）→ 迁移兼容资产 → 运行 hermes doctor"
info "安全默认值：preset=full, --yes, 不默认覆盖已有 Hermes 数据"

if ! command -v git >/dev/null 2>&1; then
  die "未检测到 git。Hermes 官方安装器依赖 git，请先安装 git 后重试。"
fi
info "git: $(git --version)"

OPENCLAW_DIR="${OPENCLAW_DIR:-}"

step 2 "定位 OpenClaw 源目录"
if [ -n "$OPENCLAW_DIR" ]; then
  if [ ! -d "$OPENCLAW_DIR" ]; then
    error "你指定的 OPENCLAW_DIR 不存在：$OPENCLAW_DIR"
    show_source_override_hint
    exit 1
  fi
  info "使用用户指定目录：$OPENCLAW_DIR"
else
  if ! OPENCLAW_DIR="$(find_openclaw_dir)"; then
    error "未发现 OpenClaw 目录（~/.openclaw / ~/.clawdbot / ~/.moltbot）。"
    error "如果这台机器并没有 OpenClaw，请改走普通 Hermes 安装流程。"
    show_source_override_hint
    exit 1
  fi
  info "自动探测到 OpenClaw 目录：$OPENCLAW_DIR"
fi

export PATH="$HOME/.local/bin:$PATH"

step 3 "确保 hermes 可执行"
if command -v hermes >/dev/null 2>&1; then
  info "已检测到 hermes，跳过安装。"
else
  info "未检测到 hermes，开始执行 Hermes 官方安装器..."
  if ! command -v curl >/dev/null 2>&1; then
    die "未检测到 curl，无法拉取 Hermes 官方安装器。请先安装 curl 后重试。"
  fi
  if ! curl -fsSL "$HERMES_INSTALL_URL" | bash; then
    error "Hermes 官方安装器执行失败。"
    error "若当前网络无法访问 raw.githubusercontent.com，请稍后重试或改走手动安装 fallback。"
    exit 1
  fi
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v hermes >/dev/null 2>&1; then
  error "安装后仍找不到 hermes。请先刷新 shell 环境后重试："
  echo "        source ~/.bashrc    # 或 source ~/.zshrc"
  echo "        export PATH=\"$HOME/.local/bin:$PATH\""
  exit 1
fi
info "Hermes version: $(hermes --version)"

step 4 "执行兼容迁移"
info "迁移来源：$OPENCLAW_DIR"
info "执行命令：hermes claw migrate --source \"$OPENCLAW_DIR\" --preset full --yes"
if ! hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes; then
  error "迁移命令执行失败；上方输出是排查依据。"
  error "本脚本默认未加 --overwrite，已有 Hermes 数据不会被静默覆盖。"
  exit 1
fi

step 5 "运行验收"
info "执行命令：hermes doctor"
set +e
hermes doctor
doctor_rc=$?
set -e
if [ "$doctor_rc" -ne 0 ]; then
  warn "hermes doctor 返回非 0（exit=$doctor_rc）；请根据上方输出继续补配置。"
else
  info "hermes doctor 通过。"
fi

echo
echo "[DONE] 一键安装 + 迁移流程已执行完成。"
echo "       下一步建议："
echo "       1. hermes"
echo "       2. 如需检查模型选择：hermes model"
echo "       3. 如需复查环境：hermes doctor"
