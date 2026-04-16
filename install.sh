#!/usr/bin/env bash
set -euo pipefail

HERMES_INSTALL_URL_DEFAULT="https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh"
HERMES_INSTALL_FALLBACK_URLS_DEFAULT="https://cdn.jsdelivr.net/gh/NousResearch/hermes-agent@main/scripts/install.sh"
HERMES_INSTALL_ARGS_DEFAULT="--skip-setup"
RAW_INSTALL_URL="https://raw.githubusercontent.com/gaixianggeng/openclaw-lobster-feed-hermes/main/install.sh"
RAW_INSTALL_URL_CDN="https://cdn.jsdelivr.net/gh/gaixianggeng/openclaw-lobster-feed-hermes@main/install.sh"
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

success() {
  log DONE "$@"
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
  echo "        默认会自动探测：~/.openclaw ~/.clawdbot ~/.moltbot"
  echo "        本地脚本：OPENCLAW_DIR=/path/to/.openclaw bash ./install.sh"
  echo "        Raw 单文件：OPENCLAW_DIR=/path/to/.openclaw bash -c \"\$(curl -fsSL $RAW_INSTALL_URL)\""
  echo "        CDN 单文件：OPENCLAW_DIR=/path/to/.openclaw bash -c \"\$(curl -fsSL $RAW_INSTALL_URL_CDN)\""
}

show_network_fallback_hint() {
  echo "        可强制指定 Hermes 安装源：HERMES_INSTALL_URL=<url> bash ./install.sh"
  echo "        可追加候选源：HERMES_INSTALL_FALLBACK_URLS=\"<url1> <url2>\" bash ./install.sh"
  echo "        可覆盖 Hermes 安装参数：HERMES_INSTALL_ARGS=\"--skip-setup --branch main\" bash ./install.sh"
  echo "        若 GitHub Raw 受限，可直接走 CDN 单文件：bash -c \"\$(curl -fsSL $RAW_INSTALL_URL_CDN)\""
}

show_path_refresh_hint() {
  echo "        source ~/.bashrc    # 或 source ~/.zshrc"
  echo "        export PATH=\"$HOME/.local/bin:$PATH\""
}

show_migration_failure_hint() {
  local source_dir="$1"
  echo "        可先确认源目录是否可读：ls \"$source_dir\""
  echo "        可单独确认 Hermes 是否可用：hermes --version"
  echo "        可手动重试迁移：hermes claw migrate --source \"$source_dir\" --preset full --yes"
}

show_doctor_followup_hint() {
  echo "       排查建议："
  echo "       1. 根据上方 doctor 输出补齐 provider / model / env 配置"
  echo "       2. 如需检查当前配置目录：hermes config path"
  echo "       3. 如需重新选择模型：hermes model"
  echo "       4. 完成后再次执行：hermes doctor"
}

show_completion_summary() {
  local source_dir="$1"
  local doctor_rc="$2"
  echo "[DONE] 一键安装 + 迁移流程已执行完成。"
  echo "       OpenClaw 来源：$source_dir"
  if [ "$doctor_rc" -eq 0 ]; then
    echo "       验收状态：hermes doctor 通过"
  else
    echo "       验收状态：hermes doctor 返回非 0（exit=$doctor_rc），需继续补配置"
  fi
  echo "       下一步建议："
  echo "       1. hermes"
  echo "       2. 如需检查模型选择：hermes model"
  echo "       3. 如需复查环境：hermes doctor"
}

run_remote_script() {
  local url="$1"
  local tmp_script
  tmp_script="$(mktemp)"

  if ! curl -fsSL --connect-timeout 15 --retry 2 --retry-delay 1 -o "$tmp_script" "$url"; then
    rm -f "$tmp_script"
    return 1
  fi

  if [ "${HERMES_INSTALL_ARGS+x}" = "x" ]; then
    # Intentionally allow simple shell-style splitting for installer flags.
    # Example: HERMES_INSTALL_ARGS="--skip-setup --branch main"
    if ! bash "$tmp_script" $HERMES_INSTALL_ARGS; then
      rm -f "$tmp_script"
      return 1
    fi
  elif ! bash "$tmp_script" $HERMES_INSTALL_ARGS_DEFAULT; then
    rm -f "$tmp_script"
    return 1
  fi

  rm -f "$tmp_script"
  return 0
}

install_hermes_with_fallback() {
  local primary_url="${HERMES_INSTALL_URL:-$HERMES_INSTALL_URL_DEFAULT}"
  local fallback_urls="${HERMES_INSTALL_FALLBACK_URLS:-$HERMES_INSTALL_FALLBACK_URLS_DEFAULT}"
  local install_args="${HERMES_INSTALL_ARGS-$HERMES_INSTALL_ARGS_DEFAULT}"
  local url
  local index=1

  info "Hermes 安装源候选列表："
  info "  $index) $primary_url"
  index=$((index + 1))
  for url in $fallback_urls; do
    [ "$url" = "$primary_url" ] && continue
    info "  $index) $url"
    index=$((index + 1))
  done
  info "Hermes 安装参数：${install_args:-<empty>}"

  info "尝试安装源：$primary_url"
  if run_remote_script "$primary_url"; then
    return 0
  fi

  for url in $fallback_urls; do
    [ "$url" = "$primary_url" ] && continue
    warn "主安装源失败，尝试 fallback：$url"
    if run_remote_script "$url"; then
      return 0
    fi
  done

  return 1
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
hermes_just_installed=0

step 3 "确保 hermes 可执行"
if command -v hermes >/dev/null 2>&1; then
  info "已检测到 hermes，跳过安装。"
else
  info "未检测到 hermes，开始执行 Hermes 官方安装器..."
  if ! command -v curl >/dev/null 2>&1; then
    die "未检测到 curl，无法拉取 Hermes 官方安装器。请先安装 curl 后重试。"
  fi
  if ! install_hermes_with_fallback; then
    error "Hermes 官方安装器执行失败。"
    error "已依次尝试默认源与 fallback 源；若当前网络无法访问 raw.githubusercontent.com，可继续改用 CDN 或手动安装。"
    show_network_fallback_hint
    exit 1
  fi
  export PATH="$HOME/.local/bin:$PATH"
  hermes_just_installed=1
  success "Hermes 官方安装器执行完成。"
fi

if ! command -v hermes >/dev/null 2>&1; then
  error "安装后仍找不到 hermes。请先刷新 shell 环境后重试："
  show_path_refresh_hint
  exit 1
fi
info "Hermes version: $(hermes --version)"
success "已确认 hermes 可执行。"

step 4 "执行兼容迁移"
should_overwrite=0
case "${HERMES_MIGRATE_OVERWRITE:-auto}" in
  auto)
    if [ "$hermes_just_installed" -eq 1 ]; then
      should_overwrite=1
    fi
    ;;
  1|true|TRUE|yes|YES|on|ON)
    should_overwrite=1
    ;;
  0|false|FALSE|no|NO|off|OFF)
    should_overwrite=0
    ;;
  *)
    die "HERMES_MIGRATE_OVERWRITE 只能是 auto/true/false，当前值：${HERMES_MIGRATE_OVERWRITE}"
    ;;
esac

info "迁移来源：$OPENCLAW_DIR"
if [ "$should_overwrite" -eq 1 ]; then
  info "迁移覆盖策略：启用 --overwrite（用于新装 Hermes 的默认模板，或由 HERMES_MIGRATE_OVERWRITE 显式开启）"
  info "执行命令：hermes claw migrate --source \"$OPENCLAW_DIR\" --preset full --yes --overwrite"
  if ! hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes --overwrite; then
    error "迁移命令执行失败；上方输出是排查依据。"
    show_migration_failure_hint "$OPENCLAW_DIR"
    exit 1
  fi
else
  info "迁移覆盖策略：不覆盖已有 Hermes 数据"
  info "执行命令：hermes claw migrate --source \"$OPENCLAW_DIR\" --preset full --yes"
  if ! hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes; then
    error "迁移命令执行失败；上方输出是排查依据。"
    error "本脚本默认未加 --overwrite，已有 Hermes 数据不会被静默覆盖。"
    show_migration_failure_hint "$OPENCLAW_DIR"
    exit 1
  fi
fi
success "迁移命令执行完成。"

step 5 "运行验收"
info "执行命令：hermes doctor"
set +e
hermes doctor
doctor_rc=$?
set -e
if [ "$doctor_rc" -ne 0 ]; then
  warn "hermes doctor 返回非 0（exit=$doctor_rc）；请根据上方输出继续补配置。"
  show_doctor_followup_hint
else
  success "hermes doctor 通过。"
fi

echo
show_completion_summary "$OPENCLAW_DIR" "$doctor_rc"
