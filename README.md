# my-work-skill

AI 工程开发工作流 v5.3：契约内核 + 主线锚定 + 2026 frontier class 模型适配（能力下限 Opus 5），
对齐 OpenSpec 1.13。设计契约：`docs/specs/2026-08-14-v5-subtraction-design.md`（v5）、
`docs/specs/2026-09-08-v5.1-mainline-anchoring-design.md`（v5.1）；v5.2（WORKFLOW.md 退役）与
v5.3（版本戳）无独立 spec，记录见 `FIELD-LOG.md` 2026-09-11。

## 目录结构约定

```
my-work-skill/
├── README.md                # 本文件：结构与修改约定
├── GUIDE.md                 # 使用指南：设计原理、循环速查、决策记录、排查要点、版本对照、内容归属表
├── FIELD-LOG.md             # 实测日志（append-only）：RED/GREEN 证据链 + ablation 台账
├── LICENSE                  # MIT
├── VERSION                  # 发版版本（= tag）；bootstrap 写进项目 Toolkit 行与机器标记文件，Session Start 比对
├── docs/specs/              # 设计契约
├── docs/plans/              # 实现计划
├── hooks/                   # PreToolUse / PostToolUse 脚本源码 + README（原则、注册片段、heavy-test 三问、echo 用例）
├── skills/                  # 由 project-bootstrap 部署到 ~/.claude/skills/
│   ├── project-bootstrap/   # 部署 + 立项：装 skills、brainstorm、回填、hooks、迁移（含 backlog 瘦身）
│   ├── change-loop/         # 核心：风险路由 + 契约循环（含 dispatch-prompt.md：派发 / reviewer / spec critic）
│   └── value-review/        # 主线回顾：route check（航线校准）+ project review（工程复盘）
└── templates/
    ├── CLAUDE.md            # 项目模板（含 North Star 段、常设授权，~40 行常驻）
    ├── backlog.md           # 索引式 backlog：Now / 主线 / 支线 / Done，≤8KB
    └── openspec-config.yaml # OpenSpec 项目的 config.yaml：opsx 流程内约定（Loop Contract / Purpose / archive Decisions）
```

## 修改约定

- 改流程先改本仓库文档，再改各项目实践（约束先行）。
- skills 修改先有证据再改正文：证据落 `FIELD-LOG.md`（append-only）——运行时失败、
  使用投票、官方指导均为合法证据形态；改后补验证对照。
- 循环机制的数值与判据唯一权威在 `skills/change-loop` 与 `skills/value-review`；GUIDE 等处速查冲突以 skill 为准；
  `templates/openspec-config.yaml` 只复述 opsx 流程内需要的条目，不另立判据。
- 新经验进 GUIDE.md 与 skills，实测证据进 FIELD-LOG.md；hook 脚本只改 `hooks/`，改完跑其 README 的 echo 用例。
  WORKFLOW.md v3.6 已退役（v5.2），原文见 tag v5.1。
- 模型下限 Opus 5：不为更弱模型加约束，不为特定模型建特调层。
- 发版：改 `VERSION`、README 版本表、GUIDE §5 对照表，tag 同名；动到 GUIDE §5 接口表里的东西 = major。

## 部署

对项目说「立项」或「部署工作流」→ `project-bootstrap` 接管。
冷启动（机器无任何 skill）：clone 本仓库 → 让 AI 读 `skills/project-bootstrap/SKILL.md` 照做。

## 版本

| tag | 日期 | 内容 |
|---|---|---|
| v5.3 | 2026-09-11 | 版本戳：`VERSION` ↔ 项目 Toolkit 行 ↔ 机器标记文件，Session Start 比对触发迁移；迁移时机规则；接口兼容承诺 |
| v5.2 | 2026-09-11 | WORKFLOW.md 退役：hook 源码落 `hooks/`，archive 交回 OpenSpec CLI，opsx 约定下沉 config.yaml 模板；对齐 OpenSpec 1.13 |
| v5.1 | 2026-09-11 | 主线锚定：索引式 backlog、subagent 常设授权、spec critic、两层回顾 |
| v5.0 | 2026-08-14 | 减法重构：契约内核、两行路由、面向 2026 frontier class 模型（下限 Opus 5） |
| v4.1 | 2026-08-09 | v3 流程内核 + 四层工程模型；含首轮实测修正 |

版本间差异见 `GUIDE.md` §5 版本对照速查。

## License

MIT，见 `LICENSE`。
