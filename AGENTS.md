# AGENTS.md

本文件为 AI 编码代理（Claude Code / Cursor / Codex / Copilot 等）提供操作本仓库的规则与核心上下文。开始任何任务前请通读。

## 仓库是什么

个人 Linux dotfiles 配置仓库：
- 目标环境：**Ubuntu 24.04 + fish + starship + ghostty**
- 管理方式：**GNU Stow**（13 个 stow 包，纯 git + 符号链接）
- 开发机：**Windows**（只在上面编写/整理，不运行不测试）

## 用户核心原则（原教旨主义）

1. **快捷键**：不替换任何工具默认快捷键，只允许新增自定义键并确保不冲突
2. **主题**：不使用任何第三方颜色主题（catppuccin/tokyonight/nord/onedark 等均已清除），保持软件默认/自带主题
3. **配置管理**：只用 GNU Stow，不引入 chezmoi/yadm/dotbot/nix 等
4. **代理非侵入**：不修改全局 git 配置，只通过 `proxy-switch.sh` 的 `source` + 环境变量
5. **隐私**：不提交私人项（model/API Key/供应商/账户名），只留注释示例

## 铁律（违反会造成不可逆问题）

1. **不要在 Windows 上运行或测试任何配置**。禁止 `source`/执行任何 shell 脚本、config.fish 等。只在真实 Linux（Ubuntu 24）上运行。
2. **`upstream/` 永不提交**。已被 `.gitignore` 排除，是克隆上游配置的临时工作区。当前保留 4 个参考源：archibate-dotfiles、dotfiles-claude-main、dotfiles-codex-main、terminal-setup-main。
3. **操作个人文件要谨慎**。先只读扫描列清单，确认后再动手，不做批量删除。
4. **行尾统一 LF**。`.gitattributes` 已对所有文本文件强制 `eol=lf`（`.ttf` 为 binary）。禁止写入 CRLF。
5. **提交只加对应 stow 包目录**。不 `git add -A`，不批量提交未变更的包。用 semantic commit（`feat:`/`fix:`/`docs:`/`refactor:`/`chore:`）。
6. **新增 stow 包时同步更新** `install.sh` 的 `packages` 数组和 `README.md` / `DOCS.md`。

## 当前存仓包清单（13 个）

```
fish  starship  ghostty  git  fonts  nvim  codex  opencode  claude
atuin  fontconfig  tmux  clangd
```

| 包 | 目标路径 | 关键约束 |
|----|----------|----------|
| fish | `~/.config/fish/` | fish shell 语法：`set -gx` 非 `export`，`end` 非 `fi`，`(cmd)` 非 `$(cmd)` |
| starship | `~/.config/starship.toml` | TOML，已清除 catppuccin 调色板，默认配色 |
| ghostty | `~/.config/ghostty/config` | `key = value` 格式，已清除 `theme = catppuccin-mocha` |
| git | `~/.gitconfig` | git config 格式，delta pager |
| fonts | `~/.local/share/fonts/` | UbuntuSansMono NFM（8 .ttf），注册名无空格 |
| nvim | `~/.config/nvim/` | lazy.nvim，需 >= 0.11，已清除 tokyonight |
| codex | `~/.codex/` | TOML + rules DSL，模型/Key 留空 |
| opencode | `~/.config/opencode/` | JSONC，permission 已 bypass |
| claude | `~/.claude/` | 完整配置：settings.json + hooks(41) + lib(7) + providers(4) + skills(14) |
| atuin | `~/.config/atuin/config.toml` | 全注释模板，fish 中已集成 `--disable-up-arrow` |
| fontconfig | `~/.config/fontconfig/fonts.conf` | XML，中文字体优先级（优先 SC 而非 JP） |
| tmux | `~/.config/tmux/` | 保留默认 prefix Ctrl+b，Alt 增量绑定（已处理 Alt+Tab/←/→ 冲突） |
| clangd | `~/.config/clangd/config.yaml` | YAML，CUDA/ESP32 flag 清理 |

## 工作流：拉取上游 → 改写 → 收编

1. 克隆到 `upstream/` 后只读研究，不向其写入正式配置
2. 挑选片段整理进对应 stow 包，保持「相对 $HOME」布局
3. 向 `upstream/` 写入正式内容是**禁止**的
4. 新增包时：
   - 建顶层目录（如 `tmux/`），内部保持 `$HOME` 相对路径（如 `tmux/.config/tmux/tmux.conf`）
   - 在 `install.sh` 的 `packages=(...)` 数组中追加
   - 更新 `README.md` 目录树和 `DOCS.md` 包清单

## 网络与代理

- 直连 github.com 当前可用；抽风时：`source proxy-switch.sh && proxy_on`（mihomo 默认 7897）
- 镜像 clone：`gh_clone owner/repo`（ghproxy.com）
- 国内用户直接从 Gitee 镜像克隆

## 各包语法易错点

| 文件类型 | 易错 |
|----------|------|
| `*.fish` | 别用 bash 语法（`export`/`fi`/`$(cmd)` 都是错的） |
| `*.toml` | TOML 段 `[section]`，键值 `=`，字符串引号 |
| `*.lua` | Lua 注释 `--`，非 `#`，require 路径用 `.` 分隔 |
| `*.json` | 严格 JSON，无注释无尾逗号；`*.jsonc` 允许 `//` 注释和尾逗号 |
| ghostty config | 一行一个 `key = value` |

## 编码与行尾

- 所有文本文件：UTF-8 无 BOM + LF
- Windows PowerShell 写入 Linux 配置时用 `Write-Utf8NoBom`（见 PowerShell profile），避免 BOM 破坏 bash shebang
- `.gitattributes` 已强制：`*.sh` `*.fish` `*.lua` `*.toml` `*.md` `*.json` `*.jsonc` `*.py` → `eol=lf`
- 注释用中文，配置项保持工具官方语法

## 完成任务后自检

- [ ] 修改仅落在对应 stow 包目录内
- [ ] `upstream/` 未被修改或提交
- [ ] 无 CRLF 行尾
- [ ] 配置语法符合目标工具规范
- [ ] 无第三方颜色主题（catppuccin/tokyonight 等）
- [ ] 无未知快捷键冲突
- [ ] 若新增 stow 包，`install.sh` / `README.md` / `DOCS.md` 已同步
- [ ] 提交信息符合 semantic commit

## 更多信息

完整说明文档见 [DOCS.md](./DOCS.md)（个人偏好、配置细节、决策记录、上游对比、bootstrap 流程）。
