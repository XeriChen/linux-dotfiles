# Claude Code 配置说明

本目录用于管理 Claude Code 配置，采用 GNU Stow 部署。

## 目录职责

- `settings.json`：Claude Code 主配置
- `hooks/`：工具调用前后检查、提示和安全护栏
- `hooks/lib/`：hook 共用函数
- `skills/`：可复用工作流能力

## 维护原则

1. hook 应保持单一职责，避免一个脚本承担过多逻辑。
2. 不提交 API Key、账号信息、私有 provider 配置。
3. 新增 hook 时记录用途和触发时机。
4. 修改安全相关 hook 前先确认不会阻断正常开发流程。

## 设计目标

- 提供稳定的开发辅助
- 减少危险操作
- 保持配置可迁移、可审计
