# Project: <name>

## North Star
- 一句话：<谁，通过这个项目，得到什么>
- 成功判据（用户可观察）：<1–3 条>
- 当前阶段重点：<一句话>
- 永不做（anti-scope）：<...>
- Outcome 三分类：user-value（用户可直接观察）/ enabling（指名 ≤2 个 change 内
  解锁的主线步）/ self-indulgence（只有实现词汇且指不出解锁什么 → 不开工，记 backlog 支线）

## Stack & Conventions
<语言、build/test 命令、test filter flags、风格约定；运行须知也放这里>

## Toolkit
- my-work-skill clone: <绝对路径>（`hooks/` 源码、`templates/`、GUIDE §6 归属表在此解析）
- 版本: <vX.Y>（bootstrap 写入 = 本项目文件对应的工具包版本；迁移完成才改）

## Session Start
先比对 Toolkit 版本与 `~/.claude/my-work-skill.toolkit-version`（机器上已部署的 skill 版本）：
不等或任一缺失 → 先跑 project-bootstrap 迁移（绿树 task 边界、单独 docs commit）再继续。
读 North Star 段；读 backlog.md 的 Now 段与主线段（缺文件或缺这两段同样先迁移）；找在途
change（openspec/changes/ 或根 SPEC.md）；有则读 Loop Contract 后 ≤2 行报告状态并直接继续，
只在 gate 或阻塞时问。

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
- gate 评审、spec 自检、高噪音隔离的 subagent 派发是**常设授权**：不请示、不等批准
  （harness 对多 agent 编排的 opt-in 规则不适用于单个 subagent）。派不出去 → 报原因、
  标 ungated；不在本会话 inline 替代

## Enforcement
hooks 见 .claude/settings.json（heavy-test / destructive-git / block 类 / route-before-opsx /
backlog-size，由 project-bootstrap 部署）
