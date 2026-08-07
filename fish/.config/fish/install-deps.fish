#!/usr/bin/env fish
# Ubuntu 24 依赖安装（可选，按需执行）
# 用法: fish install-deps.fish
# 说明: exa 已停止维护，Ubuntu 24 使用 eza；bat/fd 在 Ubuntu 中命令名为 batcat/fdfind

sudo apt install fzf bat ripgrep fd-find eza zoxide

# bat/fd 的 Ubuntu 命令名 -> 通用名符号链接
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat
ln -sf /usr/bin/fdfind ~/.local/bin/fd
