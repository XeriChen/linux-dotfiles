#!/usr/bin/env bash
# ============================================================================
# bootstrap.sh — 部署本仓库配置到当前机器
#
# 本脚本负责「环境检查 + 配置部署 + 必要插件初始化」，不负责「安装系统工具」。
# 系统工具请先执行 ./setup.sh（或逐条执行 setup/ 下的子脚本）。
#
# 本脚本做的事：
#   1. 检查依赖（stow / fish / tmux / nvim / ghostty）
#   2. 执行 install.sh（GNU Stow 软链 15 个包到 $HOME）
#   3. 安装 fish 插件（fisher + fish_plugins）
#   4. 安装 tmux TPM + 插件
#   5. 检查 ghostty 中文回退字体
#   6. 初始化 fish 已安装工具集成（fzf/atuin/zoxide/starship 等）
#
# 用法：
#   ./bootstrap.sh          # 交互确认
#   ./bootstrap.sh --yes    # 非交互
#   ./bootstrap.sh --dry-run
#   ./bootstrap.sh --help
#
# 前置条件：
#   1. ./setup.sh 已执行（或手动装好所有工具）
#   2. 本仓库已 clone 到当前目录
# ============================================================================
set -euo pipefail

# ---------- 参数 ----------
ASSUME_YES=false
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --yes | -y) ASSUME_YES=true ;;
        --dry-run)  DRY_RUN=true ;;
        --help | -h)
            sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
    esac
done

# ---------- 工具函数 ----------
step() { echo -e "\033[1;36m==>\033[0m $*"; }
info() { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
die()  { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }
cmd_exists() { command -v "$1" >/dev/null 2>&1; }

check_command_version() {
    local cmd="$1"
    if cmd_exists "$cmd"; then
        info "$cmd 已安装"
    else
        warn "$cmd 未安装"
    fi
}

# run: 执行命令；dry-run 模式只打印，不执行
run() {
    if $DRY_RUN; then
        echo -e "\033[1;33m[dry-run]\033[0m $*"
    else
        "$@"
    fi
}

check_environment() {
    step "检查部署环境..."

    check_command_version stow
    check_command_version fish
    check_command_version tmux
    check_command_version nvim
    check_command_version ghostty

    if cmd_exists nvim; then
        local version
        version="$(nvim --version | head -n1)"
        if [[ "$version" =~ NVIM[[:space:]]v0\.([0-9]+) ]]; then
            if (( BASH_REMATCH[1] < 11 )); then
                warn "Neovim 版本低于 0.11，lazy.nvim 配置可能不可用"
            fi
        fi
    fi
}

# ---------- 确认 ----------
if $DRY_RUN; then
    echo -e "\033[1;33m==> DRY-RUN：仅预览\033[0m"
elif $ASSUME_YES; then
    :
else
    echo ""
    echo "本脚本将部署本仓库配置到 \$HOME（stow 软链 + 安装 fish/tmux 插件）。"
    echo "前置：请先执行 ./setup.sh 安装所有系统工具。"
    read -r -p "确认继续？[y/N] " ans
    case "$ans" in
        y | Y | yes | YES) : ;;
        *) die "已取消。" ;;
    esac
fi

# ============================================================================
# 0. 前置检查
# ============================================================================
check_environment

if ! cmd_exists stow; then
    die "未找到 stow，请先执行：sudo apt install stow 或 bash setup/01-apt-base.sh"
fi

# ============================================================================
# 1. Stow 部署（install.sh）
#    ⚠️ 必须在 fish 插件安装之前：fish_plugins 靠 stow 软链到 ~/.config/fish
# ============================================================================
step "部署配置（stow 软链 15 个包到 \$HOME）..."
run bash ./install.sh

# ============================================================================
# 2. fisher + fish 插件
# ============================================================================
step "安装 fish 插件..."
run bash setup/06-fisher-plugins.sh

# ============================================================================
# 3. tmux TPM + 插件
# ============================================================================
if cmd_exists tmux; then
    step "安装 tmux TPM..."
    run bash setup/07-tmux-tpm.sh
else
    warn "tmux 未安装，跳过 TPM。"
fi

# ============================================================================
# 4. 中文回退字体检查
# ============================================================================
step "检查中文回退字体（ghostty 需要）..."
if cmd_exists fc-list; then
    if fc-list 2>/dev/null | grep -qi "Noto Sans Mono CJK SC\|Noto Sans CJK SC"; then
        info "中文回退字体已安装（Noto Sans CJK SC）"
    else
        warn "未检测到 Noto CJK 字体。请确认：sudo apt install fonts-noto-cjk"
    fi
else
    warn "缺少 fc-list，跳过字体检查。"
fi

# ============================================================================
# 完成
# ============================================================================
if $DRY_RUN; then
    echo -e "\033[1;33m==> DRY-RUN 结束：以上为将要执行的操作\033[0m"
else
    info "bootstrap 完成。"
fi
echo ""
echo "  首次打开 nvim 会自动安装 lazy.nvim 插件。"
echo "  将默认 shell 切换为 fish（可选）：chsh -s \$(which fish)"
echo "  安装 tmux 插件：启动 tmux 后按 Ctrl+b 再按 Shift+I。"
