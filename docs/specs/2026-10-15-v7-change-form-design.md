# v7.0 change 形态设计：脱离 OpenSpec（spec-in-place + 单文件 change）

> 2026-10-15。本文是 v7 实现的唯一契约；实现与本文冲突时先改本文。
> 证据与论证：`docs/evidence/2026-10-14-workflow-review/2026-10-15-v7-change-form-proposal.md`（三份独立设计 → 合成 →
> 两个反方 → 修订，含读数、守 / 放 / 真损失、对照路线为何不选）；FIELD-LOG 2026-10-15 v7.0 条。本文只写定稿。

## 1. 用户裁定

- 方向（2026-10-15 原话）：主 spec 是真的契约记忆，守住；OpenSpec 四件套只证明了「写下契约让 fresh-context critic 能打」
  有价值，证明不了四个文件比一页纸或流程图更好，绝非当前时代的最优解；像跳出 superpowers 那样跳出 OpenSpec 的形态限制。
- 四答（同日）：① 现在切，同时解除上午的分批裁定，其余四项目从 v5.5 累计一次迁到 v7.0；② 全局 OpenSpec CLI 整体卸载；
  ③ 接受主 spec 在途期写的是意图（并行时每 change 一个 worktree，进拍定 8 的前提）；④ finance_tool 醒来时累计迁。

## 2. 形态

- **目录不搬**：既有 OpenSpec 项目 `openspec/specs/`、`openspec/changes/`、`openspec/changes/archive/`、`openspec/retros/`
  原地；新中型项目 `docs/specs/`、`docs/changes/`、`docs/changes/archive/`、`docs/retros/`；小项目（无主 spec）根 `SPEC.md`
  → `docs/changes/<id>.md` 不变。Session Start 找在途 change 两句：`<changes dir>/*/change.md`，或根 `SPEC.md`。
- **一个 change 一个 `change.md`**（`templates/change.md`；R1 与 R2 同形；目录可放旁文件）：路由两行 / Loop Contract
  （+ Decided 可选 / Critic / Gate 行）/ Why / Non-goals / Spec 改动（清单，正文在主 spec）/ Decisions（可选，只写决定
  Fails when / Superseded 的决策与备选，★ 进主 spec）/ Scenarios（不动主 spec 时写 WHEN/THEN，否则只写端到端）/ 流程
  （可选，mermaid；是契约则画在主 spec）/ Tasks / 注记 / Close。接口只锁 `## Loop Contract`、`## Tasks`、`## Close` 与
  `Decided:` 行。
- **主 spec 就地改**：路由后直接改 Requirement / Scenario；新能力新建 spec.md（标题 / Purpose 不留占位 / Requirements /
  Architectural Decisions）；决策写进 Architectural Decisions，带 Fails when 与 `*Source: change <id> (<date>)*`，只写一次，
  不设在途 / 归档两态；被推翻的旧决策首行改 Superseded。在途性由 `ls <changes dir>/*/change.md` + 其「Spec 改动」清单承担。
- **diff 基线与范围**：路由时在 change.md 头部记 `BASE: <当时 HEAD 短 hash>`（SPLIT 子 change 抄父的；change 文件成文即
  docs-commit）；critic 与 gate 都读 `git diff <BASE> -- <Spec 改动列出的 spec 文件>`（范围限定到清单文件；含工作树）。
- **Close 五步一个 commit**：Close 段 append → 核主 spec（Source 齐、Superseded 改、Purpose 非占位）→ `git add` 旁文件、
  `git mv` 归档、`git add` 归档目录、`test ! -d` → backlog 更新 → 可选 lint `grep -L '#### Scenario' <specs dir>/*/spec.md`。
  BLOCKED 不归档（留在 changes dir 就是在途标记）。WITHDRAWN：先确认 `git log <BASE>.. -- <spec 文件>` 只有本 change 的 commit，
  再 `git diff <BASE> -- <spec 文件> | git apply -R`，否则 `git checkout -p`。SPLIT：子 change 抄父 BASE、继承「Spec 改动」行，
  Source 保留父 id。等待期：在途改过的主 spec 段算热存储，不碰；里程碑汇总 ⑤ 列出在途 Spec 改动。归档后复原：
  `git diff <BASE>..<archive commit> -- <清单文件>`。小项目：Spec 改动写「无」、Decisions 不打 ★、Close ②⑤ 跳过。
- **退役**：项目内 openspec-* skill 与 opsx command、`openspec/schemas/`、`openspec/config.yaml`、`templates/openspec-config.yaml`、
  hook `warn-route-before-opsx`（3 → hooks 清单只剩 heavy-test / destructive-git / backlog-size）、bootstrap 的 OpenSpec 前置 /
  init / schema init / profile、「Requirement 正文保留英文 SHALL / MUST」要求、全局 OpenSpec CLI。

## 3. 守住 / 放掉 / 真损失

守：主 spec 文件与结构（Requirement + WHEN/THEN Scenario + AD 的 Source / Superseded / Fails when）；Loop Contract 四字段 +
Decided；一份 critic 可攻击的书面物（change.md + spec diff）；决策与备选的家；归档作冷存储、`Decided:` 可 grep、
`git log -- <archive dir>` 圈定一期；85 + 12 个归档与 24 份主 spec 一字不动，格式仍兼容 OpenSpec（可逆）。
放：四件套、delta、validate、archive 合并、opsx 分步引导与停等、config 注入、schema / skip_specs、SHALL / MUST 要求。
真损失（如实）：主 spec 在途期是意图（串行或 worktree-per-change 下可控）；丢 scenario 的机器保险换成 critic / gate 读同一
条 diff + 可选 grep；WITHDRAWN 要 `git apply -R`；新 spec 的 Purpose 无机器占位检查（Close ② 核一眼）。

## 4. 接口与迁移

- **major v7.0**：GUIDE §5 删 config.yaml 行、加能力主 spec 行；hooks 清单 4 → 3；Loop Contract 位置 = change.md 头部；
  归档文件名 change.md；change.md 接口段名三个 + Decided 行。
- **迁移（bootstrap v6.1 → v7.0 段；其余四项目从 v5.5 累计一次做）**：有 `openspec/` 的项目 `git rm -r` 生成 skill /
  command / schemas / config.yaml，settings.json 删 Skill matcher 块与 route hook 脚本；CLAUDE.md Session Start 两句、Stack
  归属行（归档 proposal.md → change.md）、Enforcement 行、Toolkit 行 v7.0；引用清扫 grep；在途 change 按旧形态收尾；
  backlog Now 加「v7.0 迁移 commit 待确认」；删除清单进首份里程碑汇总 ②。机器级：卸载 CLI；不再 `openspec update`。
- **文件**：VERSION；README；GUIDE §2 / §3 / §4 / §5 / §6；templates/CLAUDE.md、新增 templates/change.md、删
  templates/openspec-config.yaml；hooks 删 warn-route-before-opsx.ps1 + README；skills/change-loop（SKILL.md、dispatch-prompt.md）、
  value-review、project-bootstrap；FIELD-LOG 条目（ablation、v6 GREEN × v7 影响表）。

## 5. 不做

冻结能力主 spec 移冷（项目侧独立 R1，记支线）；归档目录卫生（.pyc、脚本）；并行调度（拍定 8；本次只写前提）；
给 change.md 设字节锁。

## 6. 验证与 GREEN

验证：陈旧锚点 grep（`opsx`、`openspec`、`proposal.md`、`spec-lite`、`.openspec.yaml`、`schema: lite`、`四件套`、`SHALL`）在
skills / templates / hooks 零命中（既有项目的目录名 `openspec/changes/`、`openspec/retros/`、bootstrap 迁移段作为删除对象、
GUIDE §3 / §5 作为历史除外）；hooks/README 注册片段 JSON
解析为 3 条；templates/change.md 段名与 change-loop §2 一致；尺寸 change-loop ≤11.5KB（它吸收了原由 opsx 生成 skill 承载的契约处理
文本，每个 R2 的加载量从 9.3 + 32.9KB 降到一份 skill）；fresh-context 评审（一致性 /
可执行性）[blocking] 修完再部署；部署副本 `diff -rq` 一致、标记 v7.0；new_review_create 迁移后 `grep` 清扫零前瞻命中、
`openspec validate --specs` 基线在卸载前记录。
GREEN（到期 2026-11-30 或注明次数）：首个 v7 R2 的 change.md 字节（>40KB = RED）与 Decisions 段使用；critic blocking 真缺陷
占比（基线约半数，明显下降 = RED）；每个 R2 Close 前后 `grep -c '#### Scenario'` 对比；并行前提是否被触犯；首个新项目
立项时 `docs/specs/` 的格式是否只靠 reviewer 守住。v6 GREEN × v7 影响见 FIELD-LOG v7.0 条表。
