#!/usr/bin/env bash
# ============================================================================
# Ubuntu 24 一键部署本配置仓库（bootstrap）
#
# 目标环境：Ubuntu 24.04（x86_64）· fish · starship · ghostty · neovim(0.11+) · git
# 本脚本负责：
#   1. 安装基础依赖（curl、p7zip-full、fontconfig）
#   2. 安装系统包：fish、git、ghostty、starship、fonts-noto-cjk、fd-find、bat、fzf、ripgrep、eza、zoxide、git-delta、lazygit、yazi、tmux、atuin、fisher、exiftool、cargo
#   3. 安装新版 Neovim（>= 0.11，本仓库 nvim 配置依赖 0.11+ API，Ubuntu 自带 0.9 不可用）
#   4. 安装 fish 插件（fisher + fish_plugins 列表）
#   5. 执行 ./install.sh（GNU Stow 软链各包到 $HOME）
#   6. 检查 ghostty 的字体回退链（Noto Sans Mono CJK SC / Noto Sans CJK SC 至少其一）
#   7. 安装 OpenCode CLI + uv、Claude Code（curl 官方安装脚本，非 apt/npm）
#
# 用法：
#   ./bootstrap.sh          # 交互：执行前询问确认（可 --yes 跳过）
#   ./bootstrap.sh --yes    # 非交互：直接执行
#   ./bootstrap.sh --dry-run# 只打印将要执行的操作，不做任何改动
#   ./bootstrap.sh --help
#
# 说明：
#   - 依赖 sudo（apt 安装）。已安装的包会跳过，可重复执行。
#   - 默认 shell 不会自动切换为 fish（避免越权），末尾会提示命令。
#   - 需要 sudo 密码的会话请先 sudo -v 提权。
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
            sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
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

# run: 执行命令；dry-run 模式只打印
run() {
    if $DRY_RUN; then
        echo -e "\033[1;33m[dry-run]\033[0m $*"
    else
        "$@"
    fi
}

# ---------- 平台检查 ----------
if ! command -v apt-get >/dev/null 2>&1; then
    die "本脚本仅支持 apt 系发行版（Ubuntu/Debian）。当前系统缺少 apt-get。"
fi

. /etc/os-release 2>/dev/null || true
if [ "${ID:-}" = "ubuntu" ] && [ "${VERSION_ID:-}" != "24.04" ]; then
    warn "当前 Ubuntu 版本为 ${VERSION_ID}，脚本按 24.04 编写，可能不适用。"
fi

ARCH="$(uname -m)"
[ "$ARCH" = "x86_64" ] || warn "当前架构 $ARCH，脚本针对 x86_64 编写，可能不适用。"

if [ "$(id -u)" -eq 0 ]; then
    warn "正在以 root 运行；脚本会写入 $HOME，root 的 $HOME 通常不是期望位置。"
fi

# ---------- 确认 ----------
if $DRY_RUN; then
    echo -e "\033[1;33m==> DRY-RUN 模式：仅预览，不做任何改动\033[0m"
elif $ASSUME_YES; then
    :
else
    echo ""
    echo "本脚本将安装/更新系统包（需要 sudo）并部署配置到 \$HOME。"
    read -r -p "确认继续？[y/N] " ans
    case "$ans" in
        y | Y | yes | YES) : ;;
        *) die "已取消。" ;;
    esac
fi

# 先提权，避免中途 sudo 失败
if ! $DRY_RUN && ! sudo -v 2>/dev/null; then
    warn "sudo 不可用或未授权，apt 安装步骤可能会失败。"
fi

# ============================================================================
# 1. 基础依赖 + 系统包（Ubuntu 24.04 源）
# ============================================================================
BASE_PKGS=(curl p7zip-full fontconfig stow)
PKGS=(
    fish git
    ghostty starship
    fonts-noto-cjk          # 中文回退字体（ghostty 回退链需要）
    fd-find bat fzf ripgrep eza zoxide
    git-delta               # git pager（.gitconfig 引用 delta）
    lazygit yazi            # nvim <leader>gg / fish y 函数
    tmux atuin              # 终端复用 / shell 历史搜索
    exiftool                # nvim 插件（image/audio）可选依赖
    cargo                   # nvim mcp.lua 构建需要
)

step "安装系统包（已安装的自动跳过）..."
run sudo apt-get update
run sudo apt-get install -y "${BASE_PKGS[@]}" "${PKGS[@]}"

# bat/fd 在 Ubuntu 中命令名为 batcat/fdfind，补符号链接（幂等）
if cmd_exists batcat && ! cmd_exists bat; then
    info "链接 batcat -> ~/.local/bin/bat"
    run mkdir -p "$HOME/.local/bin"
    run ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi
if cmd_exists fdfind && ! cmd_exists fd; then
    info "链接 fdfind -> ~/.local/bin/fd"
    run mkdir -p "$HOME/.local/bin"
    run ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# ============================================================================
# 2. Neovim：Ubuntu 24.04 自带 0.9.5（太旧），从官方 PPA 安装 >= 0.11
# ============================================================================
ensure_neovim() {
    local need=0
    if ! cmd_exists nvim; then
        need=1
    else
        local ver
        ver="$(nvim --version | sed -n 's/^NVIM v\([0-9]*\)\..*/\1/p' | head -n1)"
        if [ -z "$ver" ] || [ "$ver" -lt 11 ]; then
            warn "检测到 Neovim 版本过旧（$(nvim --version | head -n1)），需要 >= 0.11"
            need=1
        else
            info "Neovim 已满足要求：$(nvim --version | head -n1)"
        fi
    fi
    if [ "$need" -eq 1 ]; then
        step "安装 Neovim >= 0.11（PPA: ppa:neovim-ppa/unstable）..."
        run sudo apt-get install -y software-properties-common
        run sudo add-apt-repository -y ppa:neovim-ppa/unstable
        run sudo apt-get update
        run sudo apt-get install -y neovim
    fi
}
ensure_neovim

# ============================================================================
# 3. Stow 部署（install.sh）
#    ⚠️ 必须在 fish 插件安装之前执行：fish_plugins 靠 stow 软链到 ~/.config/fish
# ============================================================================
step "部署配置（stow）..."
if cmd_exists stow; then
    run bash ./install.sh
else
    die "未找到 stow，部署失败。"
fi

# ============================================================================
# 4. fisher + fish 插件（按 fish_plugins 列表安装）
# ============================================================================
ensure_fish_plugins() {
    local fconf="$HOME/.config/fish"
    [ -f "$fconf/fish_plugins" ] || return 0
    if ! cmd_exists fisher; then
        step "安装 fisher（fish 插件管理器）..."
        run fish -c "curl -sfSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    fi
    step "安装 fish 插件（fish_plugins）..."
    run fish -c "fisher update"
}
ensure_fish_plugins

# ============================================================================
# 6. OpenCode CLI + 运行时依赖（插件/MCP）
# ============================================================================
ensure_opencode() {
    if ! cmd_exists opencode; then
        step "安装 OpenCode CLI（curl -fsSL https://opencode.ai/install | bash）..."
        run bash -c "\$(curl -fsSL https://opencode.ai/install)"
    else
        info "OpenCode 已安装：$(opencode --version 2>/dev/null || echo 'unknown')"
    fi
    # npm（openocde 插件/本地 MCP 的 npx 依赖）
    if ! cmd_exists npm; then
        warn "未找到 npm；请安装 Node.js >= 22"
    fi
    # uv（AGENTS.md 中指定 Python 首选运行时）
    if ! cmd_exists uv; then
        step "安装 uv（Python 包管理器）..."
        run bash -c "\$(curl -fsSL https://astral.sh/uv/install.sh)"
    else
        info "uv 已安装"
    fi
}
ensure_opencode

# ============================================================================
# 7. Claude Code（官方原生安装器，非 apt/npm；装到 ~/.local/bin/claude，自动更新）
# ============================================================================
ensure_claude() {
    if ! cmd_exists claude; then
        step "安装 Claude Code（curl -fsSL https://claude.ai/install.sh | bash）..."
        run bash -c "\$(curl -fsSL https://claude.ai/install.sh)"
    else
        info "Claude Code 已安装：$(claude --version 2>/dev/null || echo 'unknown')"
    fi
}
ensure_claude

# ============================================================================
# 7.5. tmux 插件安装（TPM）
# ============================================================================
ensure_tmux_plugins() {
    if ! cmd_exists tmux; then
        warn "tmux 未安装，跳过插件安装"
        return 0
    fi
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$tpm_dir" ]; then
        step "安装 TPM (Tmux Plugin Manager)..."
        run git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        info "TPM 安装完成。启动 tmux 后按 prefix + I (Ctrl+b 然后 I) 安装插件"
    else
        info "TPM 已安装"
    fi
}
ensure_tmux_plugins

# ============================================================================
# 8. 中文回退字体检查（ghostty font-family 第二行需要）
# ============================================================================
check_cjk() {
    if ! cmd_exists fc-list; then
        warn "缺少 fc-list，跳过中文回退字体检查。"
        return 0
    fi
    if fc-list 2>/dev/null | grep -qi "Noto Sans Mono CJK SC\|Noto Sans CJK SC"; then
        info "中文回退字体已安装（Noto Sans CJK SC）"
    else
        warn "未检测到 Noto CJK 字体。请确认：sudo apt install fonts-noto-cjk"
    fi
}
check_cjk

# ============================================================================
# 完成
# ============================================================================
if $DRY_RUN; then
    echo -e "\033[1;33m==> DRY-RUN 结束：以上为将要执行的操作\033[0m"
else
    echo ""
    info "bootstrap 完成。"
    echo "  提示：将默认 shell 切换为 fish（可选）："
    echo "    chsh -s \$(which fish)"
    echo "  首次打开 nvim 会自动安装插件（lazy.nvim），耗时取决于网络。"
    echo "  AI 补全（minuet）为可选，需本机运行 Ollama，参见 nvim/README.md。"
fi
