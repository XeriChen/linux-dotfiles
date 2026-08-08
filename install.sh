#!/usr/bin/env bash
# ============================================================================
# 在 Linux（Ubuntu 24）上安装本配置仓库：把各 stow 包软链到 $HOME
#
# 用法：
#   sudo apt install stow        # 先装 GNU Stow
#   git clone <你的仓库> ~/linux配置文件
#   cd ~/linux配置文件
#   ./install.sh
#
# 撤销某个包（注意：stow -D 按「包内路径」逐目录精确撤销，
# 不会误删 $HOME 下本仓库之外的文件）：
#   stow -D -t "$HOME" fish
# ============================================================================
set -euo pipefail

cd "$(dirname "$0")"

# fonts 包重新纳入：UbuntuSansMono NFM 字体文件随仓库走（已收进 git），
# 中文回退用的 Noto Sans Mono CJK SC 由系统包 fonts-noto-cjk 提供，不进仓库。
packages=(fish starship ghostty git fonts nvim codex opencode claude atuin fontconfig tmux clangd gdb bin)

if ! command -v stow >/dev/null 2>&1; then
  echo "未找到 GNU Stow，请先安装： sudo apt install stow"
  exit 1
fi

for pkg in "${packages[@]}"; do
  if [ -d "$pkg" ]; then
    echo "stow -> $pkg"
    stow -t "${HOME:-$HOME}" -v "$pkg"
  fi
done

# 字体包软链后刷新 fontconfig 缓存（UbuntuSansMono NFM 才能生效；
# 中文回退字体 Noto Sans Mono CJK SC 需先 sudo apt install fonts-noto-cjk）
if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f >/dev/null 2>&1 && echo "字体缓存已刷新 (fc-cache -f)"
fi

echo "完成。可用 'stow -D -t \"\$HOME\" <pkg>' 撤销某个包。"
