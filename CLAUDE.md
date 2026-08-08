# CLAUDE.md

本仓库的完整约定见 `@AGENTS.md`（已自动引入），以下仅补充 Claude Code 在操作本仓库时的快速参考。

## 常用指令速记

- 更新某个工具配置 → 改对应 stow 包内的文件（如 `fish/.config/fish/config.fish`）
- 研究上游开源配置 → 克隆到 `upstream/` 后阅读，结论整理进正式包，不留在 `upstream/`
- 从 GitHub 拉取 → 先直连；失败按顺序用 `proxy_on`（mihomo）或 `gh_clone`（镜像）
- 新增 stow 包 → 建顶层目录 + 更新 `install.sh` packages 数组 + 更新 `README.md`/`DOCS.md`

## 特别提醒

1. 用户当前在 **Windows** 上整理这份仓库。如果任务涉及"运行/测试/验证/生效配置"，请主动提醒：这些配置只在 Linux（Ubuntu 24 + fish + starship + ghostty）上使用，本机不执行不测试。
2. 原教旨原则：不替换默认快捷键（只能新增且不冲突）、不用第三方颜色主题（catppuccin/tokyonight 等均已清除）。
3. 所有 linux 配置文件必须 UTF-8 无 BOM + LF 行尾。Windows 下用 `Write-Utf8NoBom` 写入。
4. `proxy-switch.sh` 顶部的默认端口以用户实际 mihomo 配置为准，不要把脚本里的默认值当作写死的事实。
5. 当用户要求"整理/合并/清理配置"这类大范围改动时，先给出改动清单与影响说明，确认后再写入。
6. 每次有意义的改动建议主动提交，提交信息用 semantic commit 格式。

## 核心文件索引

| 文件 | 用途 |
|------|------|
| `DOCS.md` | 完整说明文档（个人偏好、配置细节、全部决策记录） |
| `AGENTS.md` | AI 代理使用手册（铁律 + 包清单 + 语法要点） |
| `README.md` | 人类可读的仓库简介 |
| `bootstrap.sh` | Ubuntu 24 一键部署脚本 |
| `install.sh` | stow 软链脚本 |
| `proxy-switch.sh` | 代理开关 |

## 文档与说明文件

- **`DOCS.md`**：完整说明文档（这是主文档，所有细节都在这里）
- **`AGENTS.md`**：AI 代理规则与上下文
- **`README.md`**：面向人类的仓库简介
- 其他所有 `.md` 和 `.txt` 说明文件已删除并整合到 `DOCS.md` 中
