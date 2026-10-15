# Project: <name>

## North Star
- 一句话：<谁，通过这个项目，得到什么>
- 成功判据（用户可观察）：<1–3 条>
- 当前阶段：见 backlog.md Now 段（此处不写，两处必不一致）
- 永不做（anti-scope）：<...>

## Stack & Conventions
<语言、build/test 命令、test filter flags、风格约定；运行须知也放这里>
- 项目参数（常设偏好，定一次，超出才问）：资源停止线 <无 | 如 <工具> 周额度 N%>；花钱上限
  <无 | 如 累计 $N>；大投入门槛 <默认：新板块 / 改 North Star、板块终态或主线段 / 主线步预估 ≥5 个 change>；
  第二反方 <不派（默认）| 按内容判定 | 必派>。未声明 = 无停止线；新付费渠道首次仍问一次并写回这里。

## Toolkit
- my-work-skill clone: <绝对路径>（`hooks/` 源码、`templates/`、GUIDE §6 归属表在此解析）
- 版本: <vX.Y>（bootstrap 写入 = 本项目文件对应的工具包版本；迁移完成才改）

## Session Start
先比对 Toolkit 版本与 `~/.claude/my-work-skill.toolkit-version`（机器上已部署的 skill 版本）：
不等或任一缺失 → 先跑 project-bootstrap 迁移（绿树 task 边界、单独 docs commit）再继续。
读 North Star 段；读 backlog.md 的 Now 段与主线段（缺文件或缺这两段同样先迁移）；找在途
change（openspec/changes/ 或根 SPEC.md）；有则读 Loop Contract 后 ≤2 行报告状态并直接继续。

## Hard Rules
- 任何 change 先经 change-loop 路由，再动 spec 或代码
- 完成声明必须附真跑的 Verify 输出；「应该能跑」是禁语
- 只在绿提交；task 边界坏树 reset 回绿锚点，不带病前进
- 不为变绿弱化或删除失败测试；被测行为移除时测试随删并在 commit 写明；动契约（数据格式 /
  CLI 接口 / 预登记口径）先改 spec
- 不加未被要求的范围
- 问人只有四类：方向、钱、时间、找谁 / 对外不可逆；其余自决并记 `Decided:`，难撤回的在里程碑
  汇总里给人否决
- subagent：派发用 dispatch-prompt.md 槽位、约束逐字重述，禁止再派 agent，浏览器 / 抓取类降级
  Sonnet；gate 评审、spec 自检、方向反方、高噪音隔离的派发是**常设授权**（harness 对多 agent 编排
  的 opt-in 不适用于单个 subagent）——不请示；派不出去 → 报原因、标 ungated，不在本会话 inline 替代

## Enforcement
hooks 见 .claude/settings.json（heavy-test / destructive-git / route-before-opsx / backlog-size，
由 project-bootstrap 部署）
