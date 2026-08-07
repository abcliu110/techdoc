# Agent Rule System Simplification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove duplicated and contradictory agent instructions while preserving a short, non-overridable safety core and specialized rule files with one responsibility each.

**Architecture:** `D:/AGENTS.md` and `D:/CLAUDE.md` remain identical routing entry points. Specialized files own reasoning, debugging, verification, Windows, observability, and Java/CRM details; the legacy-system document is reduced to compatibility-specific rules instead of repeating the whole workspace policy.

**Tech Stack:** Markdown, PowerShell 7, Git diff inspection, SHA-256 and UTF-8 checks.

---

### Task 1: Capture the current contradictions as pre-change failures

**Files:**
- Inspect: `D:/AGENTS.md`
- Inspect: `D:/CLAUDE.md`
- Inspect: `D:/agent-rules/*.md`
- Inspect: `D:/mywork/techdoc/saas/既有系统安全修改代码AI执行规范.md`
- Inspect: `D:/mywork/techdoc/AI提示语/多Agent协作-页面深度分析通用版V9/code-style-crm.txt`

- [ ] **Step 1: Record the entry-file hash mismatch**

Run:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'D:\AGENTS.md','D:\CLAUDE.md' | Select-Object Path,Hash
```

Expected: hashes differ before normalization.

- [ ] **Step 2: Record exact conflicting patterns**

Run bounded searches for these current anti-patterns:

```powershell
rg -n -m 30 'UTF-8 中文文件必须增加 `-Encoding UTF8 -Raw`|高度怀疑|猜测|L4 事故/回归/测试平台' 'D:\AGENTS.md'
rg -n -m 30 '报告、结果文件或交付产物已经生成|修改.*断言|测试数据' 'D:\agent-rules\30-verification.md'
rg -n -m 30 'legacy=\{\}|shadow=\{\}|必须提供默认值|只要 AI 在既有代码库中做任意形式的修改建议' 'D:\mywork\techdoc\saas\既有系统安全修改代码AI执行规范.md'
rg -n -m 20 'Propagation.SUPPORTS' 'D:\mywork\techdoc\AI提示语\多Agent协作-页面深度分析通用版V9\code-style-crm.txt'
```

Expected: each search returns at least one match before editing.

### Task 2: Make routing additive and close the safety exceptions

**Files:**
- Modify: `D:/AGENTS.md`
- Modify: `D:/CLAUDE.md`

- [ ] **Step 1: Replace the single-axis L0-L4 table with additive routing**

Use this model in both entry files:

```text
第一轴：操作基线
- L0：只读问答、分析、阅读；复杂分析加载 10 和 60。
- L1：文档或非运行说明写入；加载 40。
- L2：代码、配置、测试或运行行为修改；加载 30 和 40，按任务追加其他规则。

第二轴：业务风险标签
- 涉及金额、库存、订单状态、权限、多租户、支付、POS 同步、CRM、数据库结构或对外契约：叠加 10、15、20、30、40；Java/CRM 叠加 50 和 60。

第三轴：场景标签
- 事故、线上异常、回归、测试平台或跨系统同步：叠加 20、30、知识.md 和 workspace-reference.md；涉及代码/数据写入继续保留操作基线与业务风险标签命中的全部规则。

最终必读集合 = 操作基线 ∪ 业务风险标签 ∪ 场景标签 ∪ 项目级规则。
```

State explicitly that a later label never removes an earlier requirement.

- [ ] **Step 2: Unify legacy characterization and TDD order**

Replace the current TDD paragraph with:

```text
既有系统新增功能、修复 Bug、重构或改变行为时，顺序统一为：
旧行为特征化测试 PASS → 新需求/缺陷用例 RED → 最小实现 → 新旧回归。
全新代码没有旧行为时，从新需求用例 RED 开始。
无法自动化时，先形成可重复且在修复前失败的验证用例。
```

- [ ] **Step 3: Add narrow exceptions to legacy preservation**

Use this safety exception:

```text
已确认的越权、跨租户访问、凭据泄露、注入、任意代码/文件访问、支付或财务完整性错误，不作为必须保留的兼容契约。修复前仍要识别调用方、历史数据和迁移影响；无法一次修复时先采取可逆止损，不得以兼容为由继续暴露漏洞。
```

- [ ] **Step 4: Correct PowerShell reading guidance**

Replace the unconditional `-Raw` sentence with the authoritative Windows rule:

```text
读取 UTF-8 中文文件时使用 `Get-Content -LiteralPath ... -Encoding UTF8`；只有需要把整个文件作为单个字符串处理时才加 `-Raw`，逐行处理不要加。
```

- [ ] **Step 5: Separate evidence type from diagnostic state**

The entry file must refer to the five evidence types already defined by the analysis method:

```text
直接事实 / 主流共识 / 经验判断 / 推断 / 假设
```

For bug diagnosis, use separate state labels:

```text
已复现根因 / 有证据候选 / 待验证假设
```

Remove the competing `已确认 / 高度怀疑 / 猜测` global taxonomy.

### Task 3: Clarify debugging and verification terminal states

**Files:**
- Modify: `D:/agent-rules/20-debugging.md`
- Modify: `D:/agent-rules/30-verification.md`

- [ ] **Step 1: Make debugging depth proportional**

Keep reproduction, evidence tracing and a falsifiable hypothesis mandatory. State:

```text
普通 L2 问题使用最短充分因果链；L3/L4 复杂故障、数据不一致或跨系统事故才要求完整 5 Why + 5 How。可以并列记录候选假设，但一次只运行一个能区分候选项的实验。
```

Replace the old confidence labels with the five evidence types plus the three diagnostic states from Task 2.

- [ ] **Step 2: Split verification into three terminal states**

Define:

```text
业务成功：固定验收标准通过，证据完整。
执行完成但业务失败：命令或报告生成成功，但断言、用例或业务结果未通过。
阻塞：外部权限、凭据、环境或不可逆决策阻止继续，且已穷尽安全路径。
```

Remove “report generated” as an independent success condition.

- [ ] **Step 3: Protect the validator from being weakened**

Add:

```text
固定业务验收标准、原始复现路径和测试断言不得为了通过而修改。只有证据证明验收标准本身错误并获得用户/负责人确认后，才能修改标准；测试平台脚本修复后必须回到原始业务用例继续执行。
```

Require exit code, report body, artifact readability, failure count and cleanup errors to be inspected.

### Task 4: Make observability privacy-safe and testable

**Files:**
- Modify: `D:/agent-rules/15-evolution-and-observability.md`
- Modify: `D:/AGENTS.md`
- Modify: `D:/CLAUDE.md`

- [ ] **Step 1: Replace mandatory raw identifiers with a safe-field policy**

Use this rule:

```text
日志采用安全字段白名单。允许记录 traceId、事件类型、结果码、耗时、数量和经过脱敏/哈希的业务键；禁止序列化请求、响应、消息、事件、Entity、DTO、VO 或结果对象。手机号、证件、地址、邮箱、token、支付数据和业务正文不得直接进入日志。
```

- [ ] **Step 2: Constrain metrics and evidence artifacts**

Add:

```text
指标标签禁止使用订单号、用户、租户、门店、traceId 等敏感或高基数字段。告警必须给窗口、阈值、级别、责任人/渠道和处置说明。日志、响应、截图和差异样本落盘前必须脱敏，并定义存储位置、访问边界和保留期限。
```

### Task 5: Correct Java/CRM transaction and tenant rules

**Files:**
- Modify: `D:/agent-rules/50-domain-java-crm.md`
- Modify without overwriting the user's HTTP-method edits: `D:/mywork/techdoc/AI提示语/多Agent协作-页面深度分析通用版V9/code-style-crm.txt`

- [ ] **Step 1: Add authoritative transaction guidance to `50-domain-java-crm.md`**

```text
写操作默认使用 `@Transactional(rollbackFor = Exception.class)` 和 `Propagation.REQUIRED`；只读查询才可使用 `readOnly = true` 或 `Propagation.SUPPORTS`。事务边界内不执行不可控的远程调用；需要跨事务副作用时使用项目现有的 after-commit/outbox 模式。
```

Also state that UPDATE and DELETE conditions must include the project's actual tenant keys plus the business key; `pid` is never a tenant field.

- [ ] **Step 2: Fix the CRM comparison table only**

Change the CRM row from unconditional `Propagation.SUPPORTS` to:

```text
写操作 REQUIRED；只读查询可 SUPPORTS/readOnly
```

Preserve the user's existing changes that limit POST-only guidance to new endpoints.

### Task 6: Reduce the legacy-system document to its unique responsibilities

**Files:**
- Modify: `D:/mywork/techdoc/saas/既有系统安全修改代码AI执行规范.md`

- [ ] **Step 1: Keep the compatibility core**

Retain concise sections for:

```text
scope and safety exceptions
legacy contract definition
pre-change dependency inventory
characterization PASS → new RED → minimal implementation → regression
conditional compatibility strategies
API/config/schema/message compatibility
rollback and final delivery template
review-only responsibilities
```

- [ ] **Step 2: Remove duplicated workspace rules**

Delete repeated copies of Git status checks, Java encoding, generic TDD, generic verification loops, multiple pre/post checklists and duplicate delivery templates. Replace them with short references to `D:/AGENTS.md`, `30-verification.md`, `40-windows-encoding.md` and project rules.

- [ ] **Step 3: Make compatibility mechanisms conditional**

Replace “must choose wrapper/switch/shadow/extension/version” with:

```text
Use the smallest mechanism justified by risk. A local condition is sufficient for one proven branch; use a feature switch for staged rollout or fast rollback; use Shadow Mode only for side-effect-free comparable calculations; introduce strategies only when multiple real rules already exist.
```

- [ ] **Step 4: Replace the unsafe Shadow Mode example**

Use only safe summaries:

```java
if (!sameBusinessResult(legacyResult, shadowResult)) {
  log.warn(
      "shadow diff, bizKeyHash={}, fields={}, legacyDigest={}, shadowDigest={}",
      hashBizKey(request), changedFieldNames(legacyResult, shadowResult),
      safeDigest(legacyResult), safeDigest(shadowResult));
}
```

State that request/result objects and business payloads must never be serialized into the log.

- [ ] **Step 5: Replace the `NOT NULL` default rule**

Use expand/contract:

```text
Prefer nullable expansion, deploy compatible writers, backfill real business values idempotently, verify completeness, then add NOT NULL. A default is allowed only when it is a true domain value for historical and future writes; a fabricated placeholder is forbidden.
```

- [ ] **Step 6: Limit review requirements to review work**

Reviewers must detect missing characterization, compatibility and rollback evidence, but do not inherit implementation-only duties such as writing tests or adding switches unless the user asks them to implement the fix.

### Task 7: Add PowerShell edge cases and synchronize entry files

**Files:**
- Modify: `D:/agent-rules/40-windows-encoding.md`
- Modify: `D:/AGENTS.md`
- Modify: `D:/CLAUDE.md`

- [ ] **Step 1: Add two Windows-specific safeguards**

```text
Windows PowerShell 5.1 写 UTF-8 默认可能带 BOM；Java/JSON/脚本文件不要用其默认重定向写入。
测试输出含 ANSI 颜色时不要通过文本重定向结果判断成功；以进程退出码和原始报告为准。
```

- [ ] **Step 2: Apply identical entry-file patches**

Use the same `apply_patch` hunks on both files. Do not use PowerShell string replacement to rewrite Chinese content.

- [ ] **Step 3: Verify rule consistency**

Run the Task 1 searches again. Expected: obsolete patterns return no matches and replacement text is present.

- [ ] **Step 4: Verify byte identity and encoding**

Run:

```powershell
$hashes = Get-FileHash -Algorithm SHA256 -LiteralPath 'D:\AGENTS.md','D:\CLAUDE.md'
if ($hashes[0].Hash -ne $hashes[1].Hash) { throw 'entry files differ' }
```

Then scan every modified text file for UTF-8 decoding errors, BOM, replacement characters, consecutive question marks and common mojibake. Expected: no unexpected hit.

### Task 8: Final diff review without mixing user changes

**Files:** All files in this plan.

- [ ] **Step 1: Re-read every exact diff**

Use `git diff -- <path>` inside `D:/mywork/techdoc` and direct file comparison for `D:/agent-rules` and the two root entry files.

- [ ] **Step 2: Preserve known user changes**

Confirm that these existing edits remain intact:

```text
code-style-crm.txt: POST-only applies only to new endpoints.
No unrelated techdoc deletions, generated files or untracked artifacts are staged.
```

- [ ] **Step 3: Do not auto-commit overlapping implementation files**

Because `code-style-crm.txt` already contains user changes, leave implementation changes uncommitted unless the index can prove that only agent-owned hunks are staged. Report the exact remaining diff.

