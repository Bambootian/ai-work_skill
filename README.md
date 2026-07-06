# my-work-skill

AI 工程开发工作流 v4：v3（WORKFLOW.md）的流程内核 + 四层工程模型重构。

## 目录结构约定

```
my-work-skill/
├── WORKFLOW.md              # v3.6 完整流程（保留为参考;附录 G hooks / 5.4.1 R-revision / 5.8 archive 仍是权威）
├── README.md                # 本文件:结构约定
├── GUIDE.md                 # v4 使用指南:四层模型、循环设计、部署、与 v3 的关系
├── OPUS-SYSTEM.md           # 给 Opus 的系统指令(移植 Fable 级校准与纪律)
├── skills/                  # 部署到 ~/.claude/skills/ 或项目 .claude/skills/
│   ├── change-loop/         # 核心:风险路由 + 变更闭环
│   ├── value-review/        # 中期价值回顾(防技术自嗨 / 架构过时)
│   └── toolchain-refresh/   # 工具链保鲜(插件/skill 更新)
└── templates/               # 新项目复制后按项目填充
    ├── CLAUDE.md            # v4 项目模板(≤40 行)
    ├── NORTH_STAR.md        # 价值锚(人写人改,AI 只读)
    └── dispatch-prompt.md   # subagent 派发必填槽位模板
```

## 修改约定

- 改流程先改本仓库文档，再改各项目实践（约束先行）。
- skills 的修改遵循 superpowers:writing-skills 的 TDD 纪律：先有失败证据（实战踩坑记录），再改 skill 正文。
- 循环机制的数值与判据（迭代上限、stuck 判据、exit states）**唯一权威定义在 `skills/change-loop`**；GUIDE 等处的表格是速查引用，冲突以 skill 为准。
- WORKFLOW.md v3.6 不再增改，作为历史与附录权威冻结；新经验进 GUIDE.md 与 skills。

## 部署

见 GUIDE.md 第 4 节。
