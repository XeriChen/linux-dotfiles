# Linux 配置文件仓库 —— 完整说明文档

> 最后更新：2026-08-08

---

## 一、仓库概览

个人 Linux dotfiles 配置仓库，管理方式为 **GNU Stow**（纯 git + 符号链接，结构透明、零黑盒）。

| 项目 | 值 |
|------|-----|
| 目标环境 | **Ubuntu 24.04（x86_64）+ fish + starship + ghostty** |
| 配置管理 | GNU Stow（13 个 stow 包） |
| 开发机 | Windows（只在上面编写/整理，不运行不测试） |
| 主远程 | GitHub：`https://github.com/XeriChen/linux-dotfiles` |
| 镜像 | Gitee（国内加速）：`https://gitee.com/xeri_chen/linux-dotfiles` |
| 行尾 | 统一 LF（`.gitattributes` 强制） |
| 注释语言 | 中文 |
| 提交规范 | semantic commit（`feat:` / `fix:` / `docs:` / `refactor:` / `chore:`） |

---

## 二、个人偏好与约束（原教旨原则）

### 2.1 快捷键原则

- **不替换任何工具的默认快捷键**（vim/tmux/fish/ghostty/任何工具）
- **允许自定义新的快捷键**，但必须确保不与任何已有工具的快捷键冲突
- 所有新增绑定在使用前都需做冲突检查

### 2.2 主题与外观原则

- **不使用任何第三方颜色主题**，保持软件默认或软件自带主题
- 不安装 catppuccin/tokyonight/nord/onedark 等第三方配色方案
- 已从仓库中清除所有第三方主题配置（ghostty/starship/nvim/tmux 均已恢复默认）

### 2.3 配置管理原则

- **只用 GNU Stow**，不引入 chezmoi / yadm / dotbot / nix / home-manager 等
- **代理非侵入**：不修改全局 git 配置（不 `git config --global http.proxy`），只通过 `proxy-switch.sh` 的 `source` + 环境变量切换
- `upstream/` 目录是克隆开源配置的临时工作区，**永不提交**（已被 `.gitignore` 排除）
- 每次只 `git add` 对应 stow 包目录，不批量提交

### 2.4 安全与隐私

- **不提交私人项**：model 名称 / API Key / 供应商 / 账户名等只留注释示例，实际值留空
- **不在 Windows 上运行或测试任何配置**（source shell 脚本、执行 config.fish 等），一切验证在真实 Linux 上完成
- 操作个人文件（如 `$HOME` 目录）先只读扫描列清单，确认后再动手

### 2.5 代码风格

- 行尾统一 LF（`.gitattributes` 对 `.sh`/`.fish`/`.lua`/`.toml`/`.md`/`.json`/`.jsonc`/`.py` 强制 `eol=lf`）
- 注释与文档用中文；配置项本身保持工具官方语法
- 不引入构建步骤（Makefile/build.rs 等）、不写测试

---

## 三、当前 stow 包清单（13 个）

每个顶层目录是一个 stow 包，目录内路径 = 安装后在 `$HOME` 下的相对路径。

| # | 包名 | 目标路径 | 说明 |
|---|------|----------|------|
| 1 | **fish** | `~/.config/fish/` | fish shell 配置：config/alias/env/options/fish_plugins/install-deps/setup，含 vi 模式、atuin/zoxide/fzf/direnv 集成 |
| 2 | **starship** | `~/.config/starship.toml` | 提示符：默认配色 + OS 图标 + 用户名 + cmd_duration 通知 |
| 3 | **ghostty** | `~/.config/ghostty/config` | 终端：默认主题 + UbuntuSansMono NFM + Noto Sans Mono CJK SC 回退 + 窗口配置 |
| 4 | **git** | `~/.gitconfig` | git 全局配置：用户信息 + delta pager + alias + merge conflictStyle |
| 5 | **fonts** | `~/.local/share/fonts/` | UbuntuSansMono NFM（Nerd Font 图标体，8 个 ttf，随仓库走，无中文） |
| 6 | **nvim** | `~/.config/nvim/` | Neovim 配置：lazy.nvim 插件管理 + 22 个插件 spec + LSP/DAP/treesitter，要求 >= 0.11 |
| 7 | **codex** | `~/.codex/` | Codex CLI：config.toml（bypass 模式）+ rules/default.rules（安全命令放行） |
| 8 | **opencode** | `~/.config/opencode/` | OpenCode CLI：opencode.jsonc（provider 模板 + bypass 模式）+ AGENTS.md（编码偏好） |
| 9 | **claude** | `~/.claude/` | Claude Code 完整配置：settings.json + 41 hooks + 7 lib + 4 providers 模板 + 14 skills |
| 10 | **atuin** | `~/.config/atuin/config.toml` | shell 历史搜索：全注释默认模板，fish 中已集成 `--disable-up-arrow` |
| 11 | **fontconfig** | `~/.config/fontconfig/fonts.conf` | 中文字体优先级：sans-serif/serif/monospace → Noto CJK SC，解决中文显示为日文 glyphs |
| 12 | **tmux** | `~/.config/tmux/` | i3 风格 tmux 配置：保留默认 prefix Ctrl+b，Alt 增量绑定，含 TPM 插件 + 4 scripts |
| 13 | **clangd** | `~/.config/clangd/config.yaml` | C/C++ LSP 配置：清理 CUDA/ESP32 编译 flag + InlayHints |

---

## 四、关键配置细节

### 4.1 字体方案

- **主字体**：`UbuntuSansMono NFM`（Nerd Font 图标体，fonts/ 包随仓库提供）
  - ⚠️ 注册名无空格，不是 `Ubuntu Sans Mono NF`
- **中文回退**：`Noto Sans Mono CJK SC`（系统包 `fonts-noto-cjk`，不进仓库）
- **回退链**：ghostty 多行 `font-family` 实现（第一行主字体 + ASCII/图标，第二行遇中文回退）
- **fontconfig**：系统级 `fonts.conf` 确保所有程序优先 SC 字形而非日文 JP

### 4.2 Neovim

- **版本要求**：>= 0.11（Ubuntu 24 自带 0.9.5 不可用，bootstrap.sh 自动添加 `ppa:neovim-ppa/unstable`）
- **插件管理**：lazy.nvim，22 个插件 spec（lua/plugins/）
- **LSP**：Mason 自动安装 lua_ls/bashls/pyright/rust_analyzer/ts_ls/html/cssls/jsonls/yamlls/fish_lsp
- **AI 补全**：minuet（Ollama 本地模型），按需启用
- **快捷键**：保留所有 nvim 默认键位，只新增 `<leader>` 映射：
  - 窗口导航：保留 `<C-w>h/j/k/l`
  - 区块移动：`<A-j>/<A-k>`（不占用 J/K）
  - Smart close：`<leader>Q`
  - LSP：`<leader>gd` / `<leader>K`（不占用 gd/K）

### 4.3 fish shell

- **Vi 模式**：`fish_vi_key_bindings` + `<C-p>/<C-n>` 上下搜索 + `<C-a>/<C-e>` 行首尾 + `<C-f>/<C-b>` 按词移动 + `<C-t>` fzf 目录 + `<C-/>` undo
- **集成**：starship、atuin、zoxide、fzf、direnv、fnm
- **函数**：`y`（yazi cwd）、`mcd`（mkdir+cd）、`gethub`（clone → ~/Codes/github.com/）、`set-ssh-key`、docker sudo 包装
- **插件**（9 个）：autopair.fish、done、tmux.fish、fzf.fish、sponge、puffer-fish、fisher、bass、fzf-marks

### 4.4 tmux

- **原则**：保留默认 prefix `Ctrl+b`，在 `Alt` 键上增量添加 i3 风格绑定
- **已处理冲突**：去掉 `Alt+Tab`（系统窗口切换）→ 用 `Alt+u`（last window）；去掉 `Alt+Left/Right`（系统回退/前进）
- **插件**（6 个，不含 catppuccin）：tmux-tilish（i3 键位）、tmux-sessionx（fuzzy session）、tmux-resurrect + tmux-continuum（session 持久化，每 15 分钟自动保存）、tmux-better-mouse-mode、tmux-sensible
- **Scripts**：session-switcher.sh、zoxide-jump.sh、capture-edit.sh、session-preview.sh
- **注意**：首次使用需运行 `~/.config/tmux/install.sh` 安装 TPM，然后 `prefix+I` 装插件

### 4.5 Claude Code

- **settings.json**：7080 字节，含 hooks（PreToolUse 26 + PostToolUse 9 + Stop 1 + UserPromptSubmit 4 + PostCompact 1）、statusLine、skillOverrides、worktree.baseRef=head
- **hooks**：安全护栏（no-dangerous-ops/no-destructive-git/no-git-amend/no-devnull-redirect）、工具规范（no-head-read/no-cat-write/no-heredoc/no-sed-print/no-head-tail-pipe/no-background-ampersand）、流程规范（prefer-uv-run/python-unbuffered）、Agent 控制（no-worktree-team/explore-model-sonnet/verify-explore-results）、审计（audit-edits.py + drift-detect.py）、上下文注入（inject-git-status/inject-system-load/block-note-prompt）
- **providers**：4 个模板（glm/deepseek/qwen/ofox），API Key 留空
- **skills**：14 个通用 skill（grep-app/read-url/markitdown/pdf/memory-add/note/mini-prompt/onesent/grill-me/deslop/tldr/cache-hygiene/preflight-check/find-skills），约 204KB
- 上游来源：dotfiles-claude-main

### 4.6 其他

- **ghostty**：默认主题 + UbuntuSansMono NFM 13px + 窗口 padding 12x/8y + confirm-close false
- **starship**：默认配色 + OS 图标（33 种系统识别）+ 用户名显示 + cmd_duration 通知（>3s）
- **git**：delta pager（dark 模式）+ zdiff3 merge conflictStyle + 15 个 alias
- **proxy-switch.sh**：mihomo 默认端口 7897，可 `PROXY_PORT=xxxx proxy_on` 覆盖；`gh_clone owner/repo` 走 ghproxy.com 镜像

---

## 五、部署流程

### 一键部署（推荐）

```bash
git clone https://github.com/XeriChen/linux-dotfiles.git ~/linux配置文件
cd ~/linux配置文件
./bootstrap.sh            # 交互确认；--yes 跳过确认；--dry-run 预览
```

`bootstrap.sh` 自动完成：
1. 安装基础依赖（curl、p7zip-full、fontconfig、stow）
2. 安装系统包：fish、git、ghostty、starship、fonts-noto-cjk、fd-find、bat、fzf、ripgrep、eza、zoxide、git-delta、lazygit、yazi、tmux、atuin、fisher、exiftool、cargo
3. 安装 Neovim >= 0.11（ppa:neovim-ppa/unstable）
4. 安装 fish 插件（fisher + fish_plugins 列表）
5. 执行 `install.sh`（GNU Stow 软链 13 个包到 $HOME）
6. 检查中文字体回退链
7. 安装 OpenCode（+ Node>=22 & uv 提示）+ Claude Code（官方 installer）
8. 安装 tmux 插件管理器（TPM）

### 手动安装（仅 stow 软链）

```bash
sudo apt install stow
git clone <仓库> ~/linux配置文件
cd ~/linux配置文件
./install.sh
# 撤销某个包：stow -D -t "$HOME" fish
```

---

## 六、上游参考与决策记录

### 6.1 上游来源

本仓库配置参考了以下开源项目（克隆到 `upstream/`，不纳入 git）：

| 上游仓库 | 用途 |
|----------|------|
| **archibate-dotfiles** | fish/nvim/starship/ghostty/tmux/fontconfig/atuin/lazygit/yazi/clangd 等参考（主参考源） |
| **dotfiles-claude-main** | Claude Code 完整配置（settings.json + hooks + providers + skills） |
| **dotfiles-codex-main** | Codex CLI 配置（config.toml + rules） |
| **terminal-setup-main** | starship/ghostty/fish 终端参考 |

### 6.2 已采纳的上游配置

| 配置 | 来源 | 说明 |
|------|------|------|
| tmux（i3 风格） | archibate | 完整采纳，冲突修正后加入 |
| atuin | archibate | 全注释模板，按需取消注释 |
| fontconfig | archibate | 中文字体优先级，解决 CJK glyphs 问题 |
| clangd | archibate | CUDA/ESP32 flag 清理 + InlayHints |
| fish gethub 函数 | archibate | clone → ~/Codes/github.com/ |
| fish alias.fish 骨架 | archibate | 精选保留，剔除个人工作流 |
| opencode AGENTS.md 偏好 | archibate | 中文回复/ASCII 连字符/uv 优先/4 空格/PTY 后台任务 |
| claude 全套 | dotfiles-claude-main | settings.json + hooks + providers + skills |
| codex | dotfiles-codex-main | config.toml + rules |

### 6.3 评估后未采纳的配置

| 配置 | 原因 |
|------|------|
| **lazygit** | 纯 catppuccin 主题，违反原教旨主题原则。lazygit 工具本体仍通过系统包安装 |
| **yazi** | 纯 catppuccin-mocha 主题，syntect_theme 引用缺失。yazi 工具本体仍通过系统包安装 |
| alacritty | 158 个主题文件，用户用 ghostty |
| kitty | 116KB 全默认注释，用户用 ghostty |
| wezterm | 跨平台终端配置，用户用 ghostty |
| zellij | 与 tmux 功能重叠，已选 tmux |
| openmux | 与 tmux 功能重叠，生态太小 |
| paru | Arch Linux AUR 助手，Ubuntu 不需要 |
| nvimpager | 空目录（.gitkeep） |
| clash | Python curses TUI 代理切换，用户已有 proxy-switch.sh |
| starship 多调色板 | frappe/latte/macchiato 三套调色板跳过（违反原教旨主题原则） |
| tmux catppuccin 主题 | 已清除（2026-08-08 主题清理） |
| nvim tokyonight | 已清除，nvim 用内置默认高亮 |
| ghostty catppuccin-mocha | 已清除，使用 ghostty 默认主题 |
| starship catppuccin_mocha palette | 已清除，使用 starship 默认配色 |

### 6.4 tmux 快捷键冲突修正

| 上游快捷键 | 问题 | 修正 |
|-----------|------|------|
| `Alt+Tab` | 系统窗口切换 | 去掉，改为 `Alt+u`（last window） |
| `Alt+Left/Right` | 系统 back/forward | 去掉，不替代（`Alt+1-9` 足够） |
| `Alt+hjkl` | 无冲突（fish vi 模式不占用 Alt 字母） | 保留 |

---

## 七、文件与编码规范

- 所有文本文件：**UTF-8 无 BOM + LF 行尾**
- `.gitattributes` 已对 `.sh`/`.fish`/`.lua`/`.toml`/`.md`/`.json`/`.jsonc`/`.py` 强制 `eol=lf`
- `.ttf`/`.ttc`/`.otf` 标记为 binary
- 不要用 Windows 记事本编辑仓库文件（会写入 BOM + CRLF）

---

## 八、网络与代理（国内环境）

| 方式 | 命令 |
|------|------|
| 直连 GitHub | `git clone https://github.com/...`（当前可用） |
| Gitee 镜像 | `git clone https://gitee.com/xeri_chen/linux-dotfiles.git`（无需代理） |
| mihomo 代理 | `source proxy-switch.sh && proxy_on`（默认 7897 端口） |
| 镜像 clone | `gh_clone owner/repo`（ghproxy.com）或 `MIRROR=kgithub.com gh_clone owner/repo` |
