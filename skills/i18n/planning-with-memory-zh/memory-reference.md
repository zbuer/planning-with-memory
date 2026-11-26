# planning-with-memory 参考（简体中文）

## 消费方项目文件图

```text
.memory/                 # 建议纳入 git
  CHARTER.md?            # 可选章程
  KNOWLEDGE.md           # 知识（只追加）
  TASK_INDEX.md          # 任务索引（注入 / 开场用）
  TASK_LOG.md            # 任务详情日志
task_plan.md             # 当前 task-plan（或 .planning/<slug>/）
findings.md
progress.md
.planning/
  .active_plan           # 可选活动 slug
  <slug>/                # 并行 task-plan
```

## Token 策略

- sessionStart / 开场：CHARTER 目的一句 + TASK_INDEX 近况 + task_plan 头部
- 永不整文件注入 KNOWLEDGE.md 或 TASK_LOG.md
- 按锚点或搜索按需读取 LOG / KNOWLEDGE

## 宿主支持

| | 说明 |
|--|------|
| 任意 Agent Skills 宿主 | 加载 `skills/i18n/planning-with-memory-zh`，执行 scripts |
| Cursor | 可选 hooks + `/task-plan-zh` `/charter-zh` |
| 其它 IDE | 不强制专用插件；能跑 skill 即可 |

## 环境变量

| 变量 | 含义 |
|------|------|
| `PM_PLAN_ROOT` | 计划 / 记忆所在项目根的绝对路径 |
| `PLAN_ID` | `.planning/` 下的活动 slug |
| `PM_SKILL_DIR` | 覆盖 skill 安装路径 |

若设置了 `PWF_PLAN_ROOT`，可作 `PM_PLAN_ROOT` 的别名（兼容上游变量名）。无需另装 planning-with-files。

状态标记 `pending` / `in_progress` / `complete` **保持英文**（完成门禁依赖字面匹配）。
