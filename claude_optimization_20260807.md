# Claude 包优化记录

## 日期
2026-08-07

## 目标
参考上游 dotfiles-claude-main 仓库，优化 claude stow 包配置。

## 背景
- 仓库路径: `C:\Users\83501\WorkBuddy\linux配置文件`
- claude 包原始状态: 仅 4 行 settings.json（bypassPermissions + /tmp + cleanup + MCP）
- 上游源: `upstream/dotfiles-claude-main`（已 gitignored）

## 完成内容

### 第一层：直接加入（通用、无个人信息）

1. **settings.json 扩展**（4 行 → 7080 字节）
   - `env`: 9 个通用环境变量（BASH_MAX_OUTPUT_LENGTH、CLAUDE_AUTO_BACKGROUND_TASKS、CLAUDE_CODE_TMUX_TRUECOLOR 等）
   - `hooks`: 完整的 PreToolUse(21) + PostToolUse(6) + Stop(1) + UserPromptSubmit(3) + PostCompact(1) 配置
   - `skillOverrides`: 7 个内置 skill 降级为 user-invocable-only
   - `statusLine`: 自定义状态栏（model/ctx%/cwd/git/audit/idle 段）
   - `worktree.baseRef`: head
   - 去除私人项: model、AUDIT_*、ADVISOR_*、CAVEMAN_*、IS_DEMO

2. **hooks/ 目录**（28 个脚本 + 5 个 lib 共享库 + audit 相关）
   - 安全护栏: no-dangerous-ops.sh、no-destructive-git.sh、no-git-amend.sh、no-devnull-redirect.sh
   - 工具规范: no-head-read.sh、no-cat-write.sh、no-heredoc.sh、no-sed-print.sh、no-head-tail-pipe.sh
   - 流程规范: no-background-ampersand.sh、no-pip-npm.sh、prefer-uv-run.sh、python-unbuffered.sh
   - Agent 控制: no-worktree-team.sh、explore-model-sonnet.sh、verify-explore-results.sh
   - 上下文注入: inject-git-status.sh、inject-system-load.sh、block-note-prompt.sh
   - 审计: audit-edits.py（1380 行）+ drift-detect.py + audit-rules.md + audit-fresh-eye-*.md
   - 其他: compact-bump.sh、pep723-script.sh、reread-after-edit.sh、task-output-timeout-cap.sh 等
   - lib/: anchors.sh、bypass.sh、emit.sh、read_input.sh、check-python-unbuffered.sh、provider.sh、session_lock.sh

3. **providers/ 目录**（4 个模型 provider 模板）
   - glm.json: 智谱 GLM-5.2（open.bigmodel.cn）
   - deepseek.json: DeepSeek V4-Pro（api.deepseek.com）
   - qwen.json: Qwen3.6-35B（本地 127.0.0.1:8080）
   - ofox.json: DeepSeek via Ofox（api.ofox.ai）
   - 所有 API Key 留空字符串，本机填入即可

4. **statusline.sh**: 自定义状态栏渲染脚本（model + ctx% + cwd + git + audit + idle + drift + file 段）

5. **.gitattributes 更新**: 新增 *.json、*.py、*.jsonc 的 LF 行尾规则

### 第二层：选择加入

6. **skills/ 目录**（14 个通用 skill，共约 204KB）
   - grep-app: grep.app 代码搜索
   - read-url: URL 内容提取（支持 GitHub/知乎/HuggingFace/StackExchange 等）
   - markitdown: 文件转 Markdown（支持 PDF/Word/Excel/PPT 等）
   - pdf: PDF 操作（读取/表单/图片提取等）
   - memory-add: 记忆追加
   - note: 快速笔记
   - mini-prompt: 精简提示词
   - onesent: 一句话回复
   - grill-me: 审问式深挖
   - deslop: 去 AI 腔
   - tldr: 太长不看摘要
   - cache-hygiene: 缓存卫生
   - preflight-check: 飞行前检查（资源/任务成本）
   - find-skills: 技能发现

### 第三层：不加（按用户要求）

- hooks 中的 hint-* 系列（jina-ai/read-url/babysit/agent-browser 提示）
- plugins（codex/remember/playground 等）
- 私人项（model、AUDIT_*、ADVISOR_*、CAVEMAN_*、IS_DEMO）
- extraKnownMarketplaces
- tui/theme/voiceEnabled 等个人偏好

## 提交记录
- commit `129b0b5`: `feat(claude): 参考上游 dotfiles-claude-main 全面优化配置`
- 97 files changed, 9925 insertions(+), 2 deletions(-)

## 补丁提交 (6057988)
用户反馈 babysit 配套应全装，补全 10 个缺失 hook 脚本：
- hint-skill-babysit.sh + track-babysit-skill-load.sh（babysit 配套）
- hint-skill-jina-ai/read-url/agent-browser.sh（skill 提示系列）
- hint-fork-on-bloat.sh（累积输出超 50KB 提示 fork）
- hint-agent-claude-code-guide.sh（编辑 .claude/ 时提示查官方文档）
- cache-keepalive-hint.sh（后台任务缓存保活）
- websearch-followup-hint.sh（WebSearch 后提醒读链接）
- inject-time.sh（UserPromptSubmit 注入当前时间）
- settings.json 修正：删除重复 no-pip-npm.sh、inject-git-status 从 PostToolUse 移至 UserPromptSubmit、新增 SendUserFile -> track-sent-file.sh
- 最终 hooks 配置：PreToolUse 26 条(无重复) / PostToolUse 9 条 / Stop 1 条 / UserPromptSubmit 4 条 / PostCompact 1 条

## 遗留事项（2026-08-08 已处理）
- ~~bootstrap.sh 未新增 claude 预装步骤~~ → 已处理（commit f766d65）：新增 `ensure_claude()`，用官方原生安装器 `curl -fsSL https://claude.ai/install.sh | bash`（非 apt/npm，装到 `~/.local/bin/claude`，自动更新），仿 `ensure_opencode` 风格；cjk 字体检查顺延为第 8 步。
- ~~git master 分支上游 gitee 已消失的警告~~ → 已处理：将 `master` 上游从 `gitee/master` 改指 `origin/master`（GitHub 主远程），消除 `[gone]` 警告；`gitee` 远程保留，仍可手动 `git push gitee master`。（注：本地 `.git/config` 改动，不入库；新克隆默认即跟踪 origin。）
