# Linux 配置文件仓库（dotfiles）

个人 Linux dotfiles 配置仓库，目标环境 **Ubuntu 24 + fish + starship + ghostty**，GNU Stow 管理。

> 双远程：  
> GitHub：[https://github.com/XeriChen/linux-dotfiles](https://github.com/XeriChen/linux-dotfiles)  
> Gitee 镜像：[https://gitee.com/xeri_chen/linux-dotfiles](https://gitee.com/xeri_chen/linux-dotfiles)

## 原教旨原则

- **不替换默认快捷键**，只新增自定义键并确保不冲突
- **不使用第三方颜色主题**，保持软件默认/自带主题
- **只用 GNU Stow**（纯 git + 符号链接），不引入其他配置管理工具
- **代理非侵入**（不修改全局 git 配置，用 `proxy-switch.sh` 环境变量）
- **不提交私人项**（model/API Key 留空，只留注释示例）

## 目录结构

```
linux配置文件/
├── DOCS.md               # 完整说明文档（个人偏好、配置细节、决策记录）
├── bootstrap.sh          # Ubuntu 24 一键部署
├── install.sh            # stow 软链各包到 $HOME
├── proxy-switch.sh       # 代理开关（source 后 proxy_on / gh_clone）
├── upstream/             # 上游克隆临时区（gitignored）
├── fish/                 # → ~/.config/fish/（vi 模式 + atuin/zoxide/fzf/direnv）
├── starship/             # → ~/.config/starship.toml（默认配色 + OS 图标）
├── ghostty/              # → ~/.config/ghostty/config（默认主题 + Nerd Font 回退链）
├── git/                  # → ~/.gitconfig（delta pager + alias）
├── fonts/                # → ~/.local/share/fonts/（UbuntuSansMono NFM）
├── nvim/                 # → ~/.config/nvim/（lazy.nvim，需 >= 0.11）
├── codex/                # → ~/.codex/（Codex CLI）
├── opencode/             # → ~/.config/opencode/（OpenCode CLI）
├── claude/               # → ~/.claude/（Claude Code 完整配置）
├── atuin/                # → ~/.config/atuin/config.toml（shell 历史搜索）
├── fontconfig/           # → ~/.config/fontconfig/fonts.conf（中文字体优先级）
├── tmux/                 # → ~/.config/tmux/（i3 风格 + TPM 插件 + scripts）
└── clangd/               # → ~/.config/clangd/config.yaml（C/C++ LSP）
```

## 安装

```bash
# 一键部署（推荐）
git clone https://github.com/XeriChen/linux-dotfiles.git ~/linux配置文件
cd ~/linux配置文件
./bootstrap.sh            # 交互确认，--yes 跳过

# 或手动只做软链
./install.sh
```

> ⚠️ Neovim 需 >= 0.11（Ubuntu 24 自带 0.9.5），bootstrap.sh 会自动添加 PPA 安装新版。

## 更多信息

完整说明（个人偏好、配置细节、决策记录、上游对比）见 [DOCS.md](./DOCS.md)。
