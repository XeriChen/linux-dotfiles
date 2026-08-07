# CLAUDE.md

本仓库的完整约定见 `@AGENTS.md`（已自动引入），以下仅补充 Claude Code 专属的说明。

## 常用指令速记

- 更新某个工具的配置 → 直接改对应 stow 包内的文件（如 `fish/.config/fish/config.fish`）
- 研究上游开源配置 → 克隆到 `upstream/` 后阅读，结论整理进正式包，不留在 `upstream/`
- 从 GitHub 拉取 → 先直连；失败按顺序用 `proxy_on`（本地 mihomo）或 `gh_clone`（镜像站）

## 特别提醒

1. 用户当前在 **Windows** 上整理这份仓库。如果任务涉及"运行 / 测试 / 验证 / 生效配置"，请主动提醒用户：这些配置只在 Linux（Ubuntu 24 + fish + starship + ghostty）上使用，本机不执行、不测试。
2. `proxy-switch.sh` 顶部的默认端口（`PROXY_PORT`）以用户实际 mihomo 配置为准，不要把脚本里的默认值当作写死的事实；不确定时提示用户确认。
3. 当用户要求"整理 / 合并 / 清理配置"这类大范围改动时，先给出改动清单与影响说明，确认后再写入，避免一次性大改。
4. 本仓库已 git init；每次有意义的改动（新增包、改写配置）后建议主动提交，提交信息用 semantic commit 格式。
