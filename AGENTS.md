# AGENTS.md

本文件为 AI 编码代理（Claude Code / Cursor / Codex / Copilot 等）提供操作本仓库的规则与上下文。开始任何任务前请通读。

## 仓库是什么

个人 Linux dotfiles 配置仓库：

- 目标环境：**Ubuntu 24 + fish + starship + ghostty**（只在 Linux 上使用）
- 管理方式：**GNU Stow** —— 纯 git 仓库 + 符号链接，结构透明、零黑盒
- 开发机：**Windows**（当前这台机器）。本仓库只在这里**编写/整理**配置，**不运行、不测试**

> 当前仓库路径含中文：`C:\Users\83501\WorkBuddy\linux配置文件`。在 Windows 上处理路径时请全程加引号，避免空格/中文导致的命令解析问题。

## 铁律（违反会造成不可逆问题）

1. **不要在 Windows 上运行或测试任何配置**。本仓库内容只服务 Linux。禁止执行 `config.fish`、`starship.toml`、ghostty `config`、`.gitconfig`，禁止 source 本仓库的任何 shell 脚本。一切验证只能在真实 Linux（Ubuntu 24）机器上进行。
2. **不要引入新的配置管理工具**。坚持 GNU Stow + 符号链接，不引入 chezmoi、yadm、dotbot 等，保持结构透明。
3. **代理配置非侵入**。不修改全局 git 配置（不执行 `git config --global http.proxy ...`），只通过 `proxy-switch.sh` 的 source + 环境变量切换。
4. **`upstream/` 是克隆上游配置的临时工作区**，已被 `.gitignore` 排除，**永不提交**。可在其中克隆、阅读、研究，但不要把它当正式目录使用，也不要向其写入正式配置。当前仅保留 4 个被引用的参考源：`archibate-dotfiles`（opencode/fish/nvim 等参考）、`dotfiles-claude-main`（claude 包来源）、`dotfiles-codex-main`（codex 包来源）、`terminal-setup-main`（终端参考）；冗余克隆（如 `dotfiles-main`，与 archibate-dotfiles 同源且为子集、无独有文件）已删除。
5. **操作个人文件要谨慎**。本仓库任务只涉及仓库内文件；如需读取/修改 `$HOME`、桌面等个人目录，先只读扫描并列出清单，确认后再动手，不做批量删除。

## 目录布局（stow 包约定）

每个顶层目录是一个 **stow 包**，目录内的相对路径 = 安装后相对 `$HOME` 的路径。

```
.
├── bootstrap.sh          # Ubuntu 24 一键部署：系统依赖 + Neovim 0.11 + fish 插件 + stow
├── install.sh            # Linux 上执行：stow -t "$HOME" <pkg>（仅软链，已装依赖时用）
├── proxy-switch.sh       # 代理开关：source 后 proxy_on / gh_clone
├── upstream/             # 上游克隆临时区（gitignored，仅存 .gitkeep）
├── fish/                 # → ~/.config/fish/
├── starship/             # → ~/.config/starship.toml
├── ghostty/              # → ~/.config/ghostty/config
├── git/                  # → ~/.gitconfig
├── fonts/                # → ~/.local/share/fonts/（Nerd Font，含图标，无中文）
├── nvim/                 # → ~/.config/nvim/（lazy.nvim，依赖 Neovim >= 0.11）
├── codex/                # → ~/.codex/（Codex CLI：config.toml + rules/default.rules）
├── opencode/             # → ~/.config/opencode/（OpenCode：opencode.jsonc + AGENTS.md）
└── claude/               # → ~/.claude/（Claude Code：settings.json + hooks + providers + skills，参考上游 dotfiles-claude-main 收编）
```

新增配置遵循同样模式：新建顶层包目录（如 `tmux/`、`alacritty/`），内部保持相对 `$HOME` 的布局。安装包清单维护在 `install.sh` 的 `packages=(...)` 数组里，新增包时同步更新。

## 工作流：克隆上游 → 改写 → 收编

### 1. 拉取上游（网络策略见下节）

```bash
cd upstream
git clone https://github.com/<作者>/<仓库>  <短名>
# 拉取完成后在此阅读研究，不要向 upstream/ 写入正式配置
```

### 2. 挑选与改写

- 从 `upstream/<短名>/` 中挑选片段，整理进对应 stow 包。
- 只保留需要的部分；改写时保证目标工具的语法正确（见「各包语法要点」）。
- **尊重上游许可证**：若大段搬运，保留原作者署名与许可证信息（多数 dotfiles 为 MIT / Unlicense）。
- 文件树始终以「相对 `$HOME`」布局为准。

### 3. 提交

- 提交信息用 semantic commit：`feat:` `fix:` `docs:` `refactor:` `chore:`。
- 只 `git add` 对应 stow 包，**永不 `git add upstream`**。
- 提交前检查无意外文件（`.gitignore` 已排除 `upstream/*`，仅保留 `.gitkeep`）。

## 网络与代理（GitHub 访问，国内环境）

直连 `github.com` 当前可用；抽风时按顺序尝试：

1. **本地 mihomo 代理**（推荐，需 mihomo 已启动）：
   ```bash
   source ./proxy-switch.sh
   proxy_on      # 设置 http_proxy/https_proxy/socks，仅当前 shell 生效
   git clone https://github.com/...
   proxy_off     # 恢复直连
   ```
   默认端口见 `proxy-switch.sh` 顶部（`PROXY_PORT`，mihomo 实际端口以用户本机配置为准，可用环境变量覆盖：`PROXY_PORT=7890 proxy_on`）。
2. **镜像站 clone**（无需本地代理）：
   ```bash
   source ./proxy-switch.sh
   gh_clone owner/repo                     # 默认 ghproxy.com
   MIRROR=kgithub.com gh_clone owner/repo  # 或换 kgithub.com
   ```
3. 下载 release 资产（如 starship/ghostty 二进制）时同理可拼镜像前缀。

## 各包语法要点（AI 检查清单）

AI 最常犯的错误是把一种 shell/格式的语法套到另一种上。改写或生成以下文件时注意：

| 文件 | 语言/格式 | 易错点 |
|---|---|---|
| `fish/.config/fish/config.fish` | fish shell | 用 `set -gx` 而非 `export`；`if ... end` 而非 `if ... fi`；命令替换用 `(cmd)` 而非 `$(cmd)`；别名用 `alias` / `abbr`；环境变量用 `$VAR` |
| `starship/.config/starship.toml` | TOML | 配置段为 `[character]` `[directory]` 等；键值用 `=`；注意字符串引号与注释规则 |
| `ghostty/.config/ghostty/config` | ghostty 自定义格式 | `key = value` 一行一条，注释 `#`；例：`theme = catppuccin-mocha`、`font-family = ...` |
| `git/.gitconfig` | git config 格式 | `[user]` `[alias]` 段落；键值 `name = value`；别名 `!` 前缀表示 shell 命令 |
| `codex/.codex/config.toml` | TOML | 同 starship.toml 规则；`[projects."<path>"]` 的 `trust_level = "trusted"` 实现 bypass；**私人 model / API Key / 供应商不要提交**，只留注释示例 |
| `codex/.codex/rules/default.rules` | Codex rules DSL | `prefix_rule(pattern=[...], decision="allow")` 放行安全命令，逐行一条，非标准 TOML |
| `opencode/.config/opencode/opencode.jsonc` | JSONC | 允许 `//` 注释与尾逗号；`permission.external_directory."*" = "allow"` 即 yolo；**model / provider 私人，留注释** |
| `claude/.claude/settings.json` | JSON（严格，无注释） | `permissions.defaultMode = "bypassPermissions"` 即 bypass/yolo（等价于 Codex `trust_level=trusted`、opencode `"*"="allow"`）；本包为**完整 Claude Code 配置**（settings.json + `hooks/` + `providers/` + `skills/`），参考上游 `dotfiles-claude-main` 收编，**私人项（model / API Key）留空或注释不提交** |

允许静态检查（如用 `python -c "import tomllib; ..."` 校验 TOML），但**禁止运行**任何配置本身。

## 编码规范

- **行尾统一 LF**（仓库含大量 shell 脚本，CRLF 会破坏 Linux 上的执行；Windows 编辑器易写成 CRLF，提交前检查）。
- 注释与说明用中文（与仓库现有风格一致）；配置项本身保持工具官方语法。
- 不引入构建步骤、不写测试（本仓库无运行环境）。

## 完成任务后的自检

- [ ] 修改仅落在对应 stow 包目录内
- [ ] `upstream/` 未被提交
- [ ] 无 CRLF 行尾
- [ ] 配置语法符合目标工具规范（仅静态检查）
- [ ] 提交信息符合 semantic commit
- [ ] 若新增 stow 包，已同步更新 `install.sh` 的 `packages` 数组与 `README.md`
