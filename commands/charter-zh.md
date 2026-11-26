---
description: "创建或更新项目章程（.memory/CHARTER.md，简体中文）。planning-with-memory-zh。"
---

使用 **planning-with-memory-zh**（或英文 `planning-with-memory`）处理章程。

## 解析技能脚本目录

优先使用第一个含有 `scripts/ensure-memory.sh` 的目录：

- `${CLAUDE_PLUGIN_ROOT}/skills/i18n/planning-with-memory-zh`
- `$HOME/.claude/skills/planning-with-memory-zh`
- `${CLAUDE_PLUGIN_ROOT}/skills/planning-with-memory`
- `$HOME/.claude/skills/planning-with-memory`

记为 `PWM_SKILL_DIR`。

## 步骤

1. `sh "$PWM_SKILL_DIR/scripts/ensure-memory.sh" --with-charter`（或 `init-charter.sh`）。
2. **新项目：** 与用户澄清目的 / 范围 / 硬约束 / 非目标，再填写 `.memory/CHARTER.md`。
3. **已有章程：** 禁止空白覆盖；修订并写入变更记录。
4. 确认路径并简要引用「目的 / Purpose」一节。
