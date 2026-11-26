---
description: 启动或重置 task-plan（简体中文）。planning-with-memory-zh，不是 Cursor Plan 模式。
---

使用 **planning-with-memory-zh**（`skills/i18n/planning-with-memory-zh`）：

1. 运行 `scripts/ensure-memory.sh`（必要时创建 `.memory/`）。
2. 运行 `scripts/init-session.sh`，可选标题；并行工作用 slug / `--plan-dir`。
3. 若根目录已有未完成的 `task_plan.md`，先询问是否 `complete-task-plan.sh`（并沉淀知识），再 `--force` 覆盖或新建 slug。
4. 填写目标、下一步、各阶段。提醒：**task-plan ≠ Cursor Plan 模式**。
5. 确认路径与下一步动作。

状态标记保持英文：`pending` / `in_progress` / `complete`。
