# my-work-skill

AI 工程开发工作流 v5.1：契约内核 + 主线锚定 + 2026 frontier class 模型适配（能力下限 Opus 5）。
设计契约：`docs/specs/2026-08-14-v5-subtraction-design.md`（v5）、
`docs/specs/2026-09-08-v5.1-mainline-anchoring-design.md`（v5.1）。

## 目录结构约定

```
my-work-skill/
├── WORKFLOW.md              # v3.6 冻结参考；附录 G hooks / 5.4.1 R-revision / 5.8.1–5.8.4 archive 仍是权威
├── README.md                # 本文件：结构与修改约定
├── GUIDE.md                 # 使用指南：设计原理、循环速查、决策记录、排查要点、版本对照、内容归属表
├── FIELD-LOG.md             # 实测日志（append-only）：RED/GREEN 证据链 + ablation 台账
├── LICENSE                  # MIT
├── docs/specs/              # 设计契约
├── docs/plans/              # 实现计划
├── skills/                  # 由 project-bootstrap 部署到 ~/.claude/skills/
│   ├── project-bootstrap/   # 部署 + 立项：装 skills、brainstorm、回填、hooks、迁移（含 backlog 瘦身）
│   ├── change-loop/         # 核心：风险路由 + 契约循环（含 dispatch-prompt.md：派发 / reviewer / spec critic）
│   └── value-review/        # 主线回顾：route check（航线校准）+ project review（工程复盘）
└── templates/
    ├── CLAUDE.md            # 项目模板（含 North Star 段、常设授权，~40 行常驻）
    └── backlog.md           # 索引式 backlog：Now / 主线 / 支线 / Done，≤8KB
```

## 修改约定

- 改流程先改本仓库文档，再改各项目实践（约束先行）。
- skills 修改先有证据再改正文：证据落 `FIELD-LOG.md`（append-only）——运行时失败、
  使用投票、官方指导均为合法证据形态；改后补验证对照。
- 循环机制的数值与判据唯一权威在 `skills/change-loop` 与 `skills/value-review`；GUIDE 等处速查冲突以 skill 为准。
- WORKFLOW.md v3.6 不再增改；新经验进 GUIDE.md 与 skills，实测证据进 FIELD-LOG.md。
- 模型下限 Opus 5：不为更弱模型加约束，不为特定模型建特调层。

## 部署

对项目说「立项」或「部署工作流」→ `project-bootstrap` 接管。
冷启动（机器无任何 skill）：clone 本仓库 → 让 AI 读 `skills/project-bootstrap/SKILL.md` 照做。

## 版本

| tag | 日期 | 内容 |
|---|---|---|
| v5.1 | 2026-09-11 | 主线锚定：索引式 backlog、subagent 常设授权、spec critic、两层回顾 |
| v5.0 | 2026-08-14 | 减法重构：契约内核、两行路由、面向 2026 frontier class 模型（下限 Opus 5） |
| v4.1 | 2026-08-09 | v3 流程内核 + 四层工程模型；含首轮实测修正 |

版本间差异见 `GUIDE.md` §5 版本对照速查。

## License

MIT，见 `LICENSE`。
