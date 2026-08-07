# OpenCode 全局指令（经 GNU Stow 软链到 ~/.config/opencode/AGENTS.md）

> 本文件是 OpenCode 的**全局**指令，对所有项目生效。
> 项目级约定见各仓库根目录的 `AGENTS.md`（本 dotfiles 仓库已含）。

## 语言

- 始终用**中文**回复。
- 代码注释和文档用**英文**。
- 禁止使用 Unicode 连字符 `‑`（U+2011），始终用 ASCII 连字符 `-`（U+002D）。

## 默认模式：bypass + yolo

- 不逐条弹审批：`opencode.jsonc` 中 `permission.external_directory."*" = "allow"`。
- 自主决策、跑到完成：像项目 owner 一样推进，不中途停下来问琐碎问题；
  不可逆操作（删除、force push、卸载包）仍先确认。
- 家目录内所有操作默认信任。

## 编码规范

- 新项目：默认 4 空格缩进。
- 已有项目：先检测 `.editorconfig` / `pyproject.toml` / `.stylua.json` / `.clang-format` 等风格配置文件 + 已有代码缩进模式，然后遵循检测到的风格。

## 项目结构

- 一次性分析脚本写到 `/tmp`，不污染项目目录。
- 确保 `git status` 干净，及时更新 `.gitignore`。

## 后台任务

- 预计超过 2 分钟的任务（包安装、大量测试等）：用 PTY 后台执行。
- 需要长期运行的服务（web server、端口转发等）：用 PTY 后台。
- `bash` 工具超时（120s）时：改用 PTY。
- PTY 工具通过 `opencode-pty` 插件提供（`pty_spawn` / `pty_send`）。

## Python

- 优先用 `uv`；未安装时退回到 `python` 和 `pip`。

## 通用规则（与仓库 AGENTS.md 一致）

- 编辑前先读相关代码/文档，不凭记忆下结论。
- 提交信息用 semantic commit（`feat:` / `fix:` / `docs:` / `refactor:` / `chore:`）。
- 不引入新的配置管理工具，保持 GNU Stow + 符号链接。
