# v5 减法重构设计

> 2026-08-14。基于五段式评审定稿：总体架构 / change-loop 新形态 / CLAUDE.md 模板 /
> bootstrap+hooks / 验证计划，每段已经人工确认。
> 本文档是实现的唯一契约；实现与本文冲突时，先改本文再改实现（约束先行）。

## 1. 动机与证据基线

v4 体系是为 2026 年 4–5 月模型能力设计的「假肢体系」：用 skill 法条、格式仪式、
hook 看护补当时模型的短板。当前 frontier class（Fable 5 / Opus 5 / GPT-5.6 / Grok 4.6）
能力大幅提升，过度约束反噬输出质量。

三条证据源，冲突时以前两条为准：

1. **官方一手文档**。Anthropic《Prompting Claude Fable 5》原话：
   "Skills developed for prior models are often too prescriptive for Claude Fable 5
   and can degrade output quality. Review and consider removing older instructions
   if default performance is better." 同文档明确列出仍需外部支撑的四样：
   文件化持久记忆（实测 3x 提升）、fresh-context 验证 subagent（优于自我批评）、
   进度声明对照 tool result 审计（几乎消灭虚报）、意图上下文 + 短指令形式的范围纪律。
   OpenAI GPT-5.6 指南：砍逐步指令与路线规定，保留结果 / 成功判据 / 停止条件 / 硬约束
   ——恰为 Loop Contract 四字段；矛盾规则比缺失规则更伤；删减用 ablation 方法论。
2. **使用投票**（2026-08-14 全环节标注，43 项）。已死：双模型架构、toolchain-refresh
   常设化。走过场：spec 四件套人审、recitation、证据包格式、R-revision 仪式、
   NORTH_STAR 独立文件。真实人工触点仅两个：spec 前的 brainstorm 问答、收尾真机验收。
3. **修正原则**：体感与官方证据冲突时按官方裁决（例：证据纪律、spec 内容保留，
   仅砍仪式形式）。

## 2. 设计原则

1. **下限锚定 Opus 5**：保留的约束必须对 Opus 5 有效；切除的必须 Opus 5 也不需要。
   拿不准的保险机制按下限一句话化保留。用户永不使用低于 Opus 5 的会话模型。
2. **不做单一模型特调**：OPUS-SYSTEM 类「给特定模型补课」层永久退役，不为任何
   新模型重建。FIELD-LOG 记录回归时标注当时模型。
3. **内核 harness 中立**：契约格式、spec 文件、CLAUDE.md 约定是纯 markdown；
   skills/hooks 是 Claude Code 适配层。不为其他 harness 预写适配器。
4. **提示层做减法，harness 层按误伤率取舍**：文章警告的「约束反噬」全部指提示层
   （skill 正文、常驻文本）；hook 零上下文成本，去留只看误报率，不看「模型是否还需要看护」。

## 3. 总体架构

### 3.1 目录形态（v5）

```
my-work-skill/
├── README.md          # 结构约定 + 模型锚定原则
├── GUIDE.md           # v5 重写：~5KB，五节结构见本文 §10
├── WORKFLOW.md        # 冻结不动（附录 G hooks 源码、§5.8 archive 仍是被引权威）
├── FIELD-LOG.md       # append-only 保留；本次 ablation 台账写入
├── docs/specs/        # 本设计文档
├── skills/
│   ├── change-loop/       # SKILL.md ~5KB + dispatch-prompt.md ~1.5KB
│   ├── project-bootstrap/ # ~4KB
│   └── value-review/      # 触发表保留，五步流程压缩为占位
└── templates/
    └── CLAUDE.md      # 含 North Star 段
```

### 3.2 删除文件（git 历史即归档，不设 attic）

- `OPUS-SYSTEM.md`
- `templates/NORTH_STAR.md`（内容并入 CLAUDE.md 模板）
- `skills/toolchain-refresh/`（整目录）
- `quickstart.html`
- GUIDE 内容级删除：§5 双模型、§6 无人值守 recipe

### 3.3 版本与迁移

- README 声明 v5；GUIDE 附「v4 → v5 对照速查」（接替现 §9 职能）。
- 存量项目迁移由 project-bootstrap 幂等完成（见 §7），触碰时迁移，不强制。
- §7 融合决策记录压缩进 GUIDE 的同时 `kb_deposit` 入知识库。

## 4. change-loop v5 规格（16KB → ~5KB）

frontmatter description 保持现触发语义（触发率已被实测验证），文字可微调不扩容。

六节结构：

1. **Overview**（3 行）：契约中心；每迭代一 task、绿进绿出、逐 task commit；
   人工触点 = brainstorm + 真机验收。
2. **Route**：四级名称保留（驱动评审深度与 spec 形态），判据每级一句话。声明两行：
   `Route: R<n> — 一行理由（novelty × reversibility × blast radius）` + `Next: …`。
   三条一行规则：没读过要动的代码不路由；默认先 brainstorm——仅当手上已有具体证据
   工件（bug 复现 / verify 输出 / 评审发现）或用户明说跳过时直接写 spec，跳过前
   ≤3 句复述意图边界；拿不准取高一级，中途升级要声明。
3. **Loop Contract**（近原样）：Outcome（用户可见词汇；只剩实现词汇 → value-review）/
   Verify（具名命令 + 期望输出，"测试通过"无效）/ Budget（天数 + 每 task 5 迭代上限）/
   Exit（DONE / BLOCKED / SPLIT）。R1 = SPEC-lite 单文件；R2+ = OpenSpec propose。
   保留「根目录 SPEC.md 属于一个 change 不属于项目」一行。
4. **Inner loop**（~10 行）：迭代不变量；有运行时行为先写失败测试；失败注记
   （task id + tried/observed/hypothesis）append 进契约 + docs-commit；坏树 reset
   回绿锚点，fix-forward 仅限迭代内；stuck 判据三条（空 diff / 同错误签名连续 2 次 /
   修 A 坏 B 往返一圈）+ 5 次上限 → systematic-debugging → 复合任务 SPLIT、其余
   BLOCKED；语义模糊问人、实现模糊自决注记。
5. **Subagents**（~6 行）：subagent 看不到主循环上下文——硬规则与契约逐字重述；
   按 dispatch-prompt.md 槽位派发；高噪音工作隔离；gate 评审 fresh-context，
   分级：R0 inline / R1 单 reviewer / R2 双视角 / R3 三视角+人；[blocking]（违反
   spec/契约或真实缺陷）必修，[nit] 记录不追。
6. **Close + Session**（~8 行）：Verify 真输出粘贴 + Outcome 一行 + 出口态；按
   WORKFLOW §5.8 archive；archive 后查 value-review 节奏（retros/ 最新文件日期 +
   其后 archive 计数，≥5 archive 或 ≥4 周 → 触发）；land the plane（tasks.md +
   2–3 行 next-session brief）；恢复 = git status → 契约 → ≤2 行报告 → 继续。

整体删除：Rationalizations 表、Red flags 清单、Mode B 白名单谓词与 tripwire 法条、
R0 纪律整段（缩为「R0 也先一句 verify 命令」）、Pre-spec Explore 声明格式、
训诫语、40% 上下文教条（文件交接实践保留于第 6 节，不带数字）。

## 5. dispatch-prompt v5 规格（4KB → ~1.5KB）

- 六槽位保留：Model / Objective / Context / Constraints / Output format / Boundaries。
- Model 槽规则：默认继承会话模型；**例外：浏览器自动化 / 网页抓取类派发必须降级
  Sonnet 或更低**（实测多次 token 失控）；裁判永不弱于产出方。
- Boundaries 槽标准行新增：**禁止 subagent 再派 agent**。
- Reviewer 变体要点保留（fresh-context 只看 diff+标准；[blocking]/[nit]；R2 双视角
  分开派发；结论冲突不自行仲裁、原话并列交人裁）。
- 删除：降级白名单、cheap-model 行动规范整块（模型下限 Opus 5 后失去适用对象）。

## 6. CLAUDE.md 模板全文（~40 行）

（第③段已逐行确认的版本，实现时原样落盘）

```markdown
# Project: <name>

## North Star
- 一句话：<谁，通过这个项目，得到什么>
- 成功判据（用户可观察）：<1–3 条>
- 当前阶段重点：<一句话>
- 永不做（anti-scope）：<...>
- Outcome 三分类：user-value（用户可直接观察）/ enabling（指名 ≤2 个 change 内
  解锁的 user-value）/ self-indulgence（只有实现词汇且指不出解锁什么 → value-review）

## Stack & Conventions
<语言、build/test 命令、test filter flags、风格约定>

## Toolkit
- my-work-skill clone: <绝对路径>（archive §5.8、hooks 源码在此解析）

## Session Start
读 North Star 段和 backlog.md；找在途 change（openspec/changes/ 或根 SPEC.md）；
有则读 Loop Contract 后 ≤2 行报告状态并直接继续，只在 gate 或阻塞时问。

## Hard Rules
- 任何 change 先经 change-loop 路由，再动 spec 或代码
- 完成声明必须附真跑的 Verify 输出；「应该能跑」是禁语
- 只在绿提交；task 边界坏树 reset 回绿锚点，不带病前进
- 测试是承重墙：不删除、不弱化失败测试换绿；改预期行为先改 spec
- 外部库/API 先验证存在再使用，训练记忆不算验证
- 不加未被要求的范围
- 语义模糊停下问；实现模糊自决并注记一行
- subagent 派发用 dispatch-prompt.md 槽位、约束逐字重述；subagent 禁止再派 agent；
  浏览器/网页抓取类派发降级 Sonnet 或更低

## Enforcement
hooks 见 .claude/settings.json（heavy-test / destructive-git / block 类，
由 project-bootstrap 部署）
```

Review Log 表废除；value-review 节奏锚改为 `retros/` 最新文件日期（无文件 = 项目
启动态）+ 其后 archive 计数。

## 7. project-bootstrap v5 规格（8.3KB → ~4KB，四步）

- **Step 0 装机**：不变（toolkit-path、pull + 复制 3 个 skill、前置检查
  superpowers / openspec）。
- **Step 1 立项 brainstorm**：不变（强制 superpowers:brainstorming）；产出槽位
  对应新 CLAUDE.md North Star 段 + 规模 + stack + heavy-test 三问。
- **Step 2 回填**：CLAUDE.md 单文件；中型加 openspec init + ARCHITECTURE.md +
  backlog.md；人逐行确认后 commit；无 placeholder 存活。
- **Step 3 hooks**：按 §8 终版部署；每个 hook echo 用例验证，粘贴输出。
- **Step 4 收尾**：装机级 OpenSpec 命令面 break-check 一次（toolchain-refresh 遗产）；
  commit；声明「第一个 change 从 change-loop 路由开始」。

**存量项目迁移**（幂等）：NORTH_STAR.md 并入 CLAUDE.md 后删除；移除 `$PROFILE`
claude wrapper 函数；注销 warn-toolchain-stale、warn-apply-phase；删
`.claude/last-toolchain-refresh`；openspec/ 与其余 hooks 不动。

## 8. hooks 终版（7 → 5）

| 去留 | Hook | 理由 |
|---|---|---|
| 留 | block-unsafe-test-commands | 机器安全（炸机事故防线），模型无关 |
| 留 | block-replaced-skills | superpowers 在装则冲突源在；官方「冲突规则最伤」 |
| 留 | block-superpowers-specs-dir | 同上，brainstorming 默认路径仍错 |
| 留 | warn-destructive-git | 数据安全，模型无关 |
| 留 | warn-route-before-opsx | 声明降为两行后的零上下文兜底 |
| 删 | warn-apply-phase | 启发式误报风险最高、守护纪律已一句话化 |
| 删 | warn-toolchain-stale | 常设保鲜降级为症状触发后失去意义 |

hook 源码权威位置不变（WORKFLOW.md 附录 G）；附录 G 中被删 hook 的源码段落保留
（冻结文档不改），bootstrap 不再部署即可。

## 9. value-review 处置（本次只定位）

- 触发表原样保留（信号 + 节奏兜底，节奏锚见 §6）。
- 五步流程压缩为简短占位：核销上轮承诺 → 对照 North Star 段逐 change 一行分类 →
  写 retro 交人决策。
- 「设计真正有价值的工程复盘」为 v5 落地后的第一个独立 change（已拍板不揉进本次）。

## 10. GUIDE v5 结构（~5KB）

1. 一页设计原理：四层模型速览 + 约束下沉原则 + 本文 §2 四原则。
2. 循环速查表（终止/回退/粒度/验证，权威在 change-loop）。
3. 融合决策记录（现 §7 压缩：每行「候选 → 采纳/拒绝 → 一句话理由」；同步 kb_deposit）。
4. 工具链排查要点（~5 行：命令突变 → 查版本 → break-check → 改文档再改实践）。
5. v4 → v5 对照速查。

删除：§1 痛点表（历史，git 可查）、§5 双模型、§6 无人值守、§8 验证计划
（由 FIELD-LOG ablation 台账接替）。

## 11. 验证计划

### 11.1 Ablation 台账（实现时写入 FIELD-LOG.md）

每刀一行：切除项 → 守护的失败模式 → 复发观察信号 → 定点回装方式。首批条目：

| 切除项 | 守护的失败模式 | 复发信号 | 回装方式 |
|---|---|---|---|
| 四行声明块→两行 | 跳过路由/模式判断 | 无声明出现 opsx/代码（warn-route-before-opsx 报）| 恢复格式块 |
| Mode B 白名单法条 | 未审视意图直奔 spec | spec 返工 / R-revision 上升 | 恢复谓词清单 |
| recitation | 长会话目标漂移 | 产出偏离 Outcome | 恢复每 task 复述 |
| Rationalization/Red flags 表 | 借口式绕规则 | 借口原话再现 | 定点恢复对应条目 |
| warn-apply-phase | apply 中途重跑 propose | 契约失效无法归因 | 重新注册 hook |
| toolchain-refresh 常设 | 工具静默腐烂 | 命令突然失效/文档漂移 | 恢复 skill 或例行 |
| 40% 教条 | 上下文过载质量跳水 | 长会话遵循度衰减 | 恢复阈值纪律 |
| NORTH_STAR 独立文件 | 价值锚稀释 | self-indulgence 未被拦截 | 恢复独立文件 |
| cheap-model 规范块 | 降级派发质量事故 | 降级 subagent 产出胡编 | 恢复规范块 |

复发处理：FIELD-LOG 记录（含当时模型）→ 只定点回装，不整体回滚。

### 11.2 GREEN 观察清单（下个真实项目 / 首个迁移项目）

1. 无格式强制下 brainstorm 是否仍默认先行（头号观察位）
2. 两行路由声明出现率；spec 返工 / R-revision 频次
3. stuck 判据是否仍截住无效重试
4. token 对比：change-loop 注入量（16KB→5KB）、CLAUDE.md 常驻量
5. 主观基线对比：用户「模型是否变聪明」体感（改造前基线：无明显变强感）

### 11.3 验收定义

1 个中型 change 全闭环 + 1 个 R0/R1：绿提交 / 测试承重墙 / 证据纪律零违反 = GREEN。
体感与 token 数据作趋势参考，不作硬验收线。

## 12. 范围外

- value-review 复盘质量重设计（v5 后第一个独立 change）
- 其他 harness（GPT-5.6 / Grok CLI 等）适配器
- WORKFLOW.md v3.6 任何修改（含附录 G 死 hook 源码段落）
- 各存量项目的主动批量迁移（触碰时迁移）

## 13. 实现顺序建议

1. GUIDE.md v5 重写 + README 更新（约束先行：文档先落）
2. change-loop SKILL.md + dispatch-prompt.md 重写
3. templates/CLAUDE.md 重写；删 NORTH_STAR.md / OPUS-SYSTEM.md / quickstart.html
4. project-bootstrap 重写；删 toolchain-refresh/
5. FIELD-LOG.md 记 ablation 台账 + 本次改造条目；kb_deposit（§7 决策记录 + 本次
   重构决策）
6. 部署到本机 ~/.claude/skills/（覆盖复制）
