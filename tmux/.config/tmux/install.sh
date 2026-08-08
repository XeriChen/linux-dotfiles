#!/usr/bin/env bash
# tmux 配置安装脚本 - 安装 TPM (Tmux Plugin Manager)
# 首次使用 tmux 前运行此脚本

set -euo pipefail

TPM_PATH="$HOME/.tmux/plugins/tpm"

echo "=== tmux 配置安装 ==="

# 检查 tmux
if ! command -v tmux &>/dev/null; then
    echo "错误: tmux 未安装"
    echo "  Ubuntu: sudo apt install tmux"
    exit 1
fi

# 检查 tmux 版本
TMUX_VERSION=$(tmux -V | grep -oP '\d+\.\d+' | head -1)
echo "tmux 版本: $TMUX_VERSION (需要 >= 3.2)"

# 检查 fzf
if ! command -v fzf &>/dev/null; then
    echo "警告: fzf 未安装（session 切换/zoxide 跳转需要）"
fi

# 检查 zoxide
if ! command -v zoxide &>/dev/null; then
    echo "警告: zoxide 未安装（Alt+g 目录跳转需要）"
fi

# 安装 TPM
if [[ ! -d "$TPM_PATH" ]]; then
    echo "安装 TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    echo "TPM 安装完成"
else
    echo "TPM 已安装"
fi

echo ""
echo "=== 安装完成 ==="
echo "下一步:"
echo "  1. 启动 tmux: tmux new -s main"
echo "  2. 安装插件: 按 prefix + I (Ctrl+b 然后大写 I)"
echo "  3. 查看键位: cat ~/.config/tmux/keybindings.md"
echo ""
echo "常用键位:"
echo "  Alt+h/j/k/l    - pane 焦点切换"
echo "  Alt+1-9        - 切换窗口 1-9"
echo "  Alt+0          - 切换到窗口 10"
echo "  Alt+u          - 切换到上次窗口"
echo "  Alt+\\          - 水平分屏"
echo "  Alt+-          - 垂直分屏"
echo "  Alt+z          - zoom toggle"
echo "  Alt+f          - session 切换弹窗"
echo "  Alt+g          - zoxide 目录跳转"
echo "  Alt+e          - 捕获并编辑输出"
echo "  Alt+d          - 关闭 pane"
echo "  Alt+i          - 切换到上次 session"
