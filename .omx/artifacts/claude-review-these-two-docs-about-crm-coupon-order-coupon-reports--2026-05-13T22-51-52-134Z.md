# claude advisor artifact

- Provider: claude
- Exit code: 0
- Created at: 2026-05-13T22:51:52.136Z

## Original task

Review these two docs about crm_coupon_order coupon reports:
1) D:\mywork\techdoc\crm技术文档\会员报表\现有crm_coupon_order能实现哪些券报表-财务合规差距分析.md
2) D:\mywork\techdoc\crm技术文档\会员报表\会员券报表-基于crm_coupon_order的财务合规实施方案.md

Focus on whether the report query conditions need time filters, whether any report can legitimately omit them, and whether the design fits financial reporting habits. Point out design defects, especially where the document mixes event-time, snapshot, and cohort semantics. Return concise findings with severity.

## Final prompt

Review these two docs about crm_coupon_order coupon reports:
1) D:\mywork\techdoc\crm技术文档\会员报表\现有crm_coupon_order能实现哪些券报表-财务合规差距分析.md
2) D:\mywork\techdoc\crm技术文档\会员报表\会员券报表-基于crm_coupon_order的财务合规实施方案.md

Focus on whether the report query conditions need time filters, whether any report can legitimately omit them, and whether the design fits financial reporting habits. Point out design defects, especially where the document mixes event-time, snapshot, and cohort semantics. Return concise findings with severity.

## Raw output

```text


# 文档审查报告：`crm_coupon_order` 券报表设计缺陷

**审查人**: Claude
**审查日期**: 2026-05-14
**文件**: 2份（差距分析 + 实施方案 V2）

---

## 一、时间过滤规范缺陷总览

### 🔴 严重缺陷（Red）

#### R05 — GROUP BY 中混入 `ORDER BY COUNT(*) DESC`（SQL 错误）
**文件**: 实施方案 §5.3、差距分析 §4.1 报表5
**严重级别**: 严重 — SQL 不可执行

```sql
-- 差距分析版（无时间过滤 + SQL 错误）
GROUP BY shop_id, get_channel, type_
ORDER BY COUNT(*) DESC          -- ❌ SELECT 无此聚合列，ORDER BY 引用了 GROUP BY 外的表达式

-- 实施方案版
GROUP BY co.shop_id, co.get_channel, co.type_
ORDER BY co.shop_id, COUNT(*) DESC   -- ❌ 同上
```

差距分析版的 SQL 还有一个额外问题：**整个 `WHERE` 子句被写成了 `WHERE ... GROUP BY` 之间的注释形式**，`WHERE` 关键字丢失，查询从 `GROUP BY` 开始，实际无法运行。两份文档均未在 SQL 前声明 `WHERE company_id = :companyId` 前置条件。

---

#### R09 — 退款冲回明细表缺少时间过滤条件
**文件**: 实施方案 §5.5
**严重级别**: 严重 — 报表无边界，可无限返回数据

```sql
WHERE co.company_id = :companyId
-- 阶段一无独立退款字段，本SQL通过状态和时间组合推断...
-- 可选：AND co.refund_time BETWEEN :beginDate AND :endDate  -- 阶段二启用
```
- 退款推断逻辑依赖 `order_bill_id` + `coupon_status` 变化，但 SQL 中无任何时间或状态过滤条件
- 结果集以 `ORDER BY co.order_bill_id DESC, co.lmnid DESC` 收尾，但无边界限定，查询可返回全量数据
- 注释中的 `co.refund_time` 字段在阶段一根本不存在（表无此字段）

---

### 🟠 中等缺陷（Orange）

#### R03 — 券日均余额表 WHERE 子句缺少时间过滤
**文件**: 实施方案 §5.1
**严重级别**: 中等 — 数据范围不受控，性能风险

```sql
FROM crm_coupon_order co
WHERE co.company_id = :companyId
  AND co.shop_id = :shopId
  AND co.get_date <= :statDate  -- 仅限制了上界，未限制下界
GROUP BY co.shop_id, co.type_
```

WHERE 条件只有 `get_date <= :statDate`，即上界无下界。文档注释说"后续用 deadline 和状态精细过滤"，但这个宽松的上界意味着**每次查询都要扫描该商户/门店从建表到统计日的全部历史数据**。虽然逻辑上正确（期初统计需要历史数据），但 SQL 层面缺少 `get_date <= :statDate` 的理由是"避免下界条件以容纳期初统计"，然而在 MySQL 执行计划中，无下界 + 无索引覆盖会导致全表扫描，应加 `AND co.get_date >= '1970-01-01'` 显式表达或建立合适的索引提示。

---

#### R04 — 券过期统计表时间语义混淆（snapshot vs. event-time）
**文件**: 实施方案 §5.2
**严重级别**: 中等 — 语义错误，误导财务口径

```sql
WHERE co.company_id = :companyId
  AND co.coupon_status = 'WHX'  -- 过滤条件一：当前状态
  AND co.deadline < :endDate    -- 过滤条件二：截止日期前到期（事件时间）
  AND co.deadline >= :beginDate -- 过滤条件三：截止日期起算（事件时间）
```

**缺陷**：`deadline` 是**快照字段**（券发放时写入的固定有效期截止日），不是事件时间。它没有"发生"的时间语义——它是券的一个属性。"在 `:beginDate` 至 `:endDate` 之间过期的券"这个表述本身就有问题：**过期是一个事件，它发生在 `deadline` 到来的那一天**，但统计口径应该问的是"截止到某日尚未核销且已过期的券（snapshot）"，而不是"deadline 落在某区间的券（错误地以属性当事件）"。

正确的语义应是：
```
截止期末时：coupon_status = 'YGQ' AND deadline <= :endDate   -- snapshot
或者：
本期新增过期（事件口径）：deadline < :statDate AND coupon_status = 'WHX'  -- 定时任务扫出 YGQ 前就捕捉
```
当前 SQL 把 `deadline` 当作事件时间来区间过滤，在财务口径上属于**语义偷换**。

---

### 🟡 轻微缺陷（Yellow）

#### R05 — 券发放渠道汇总表时间口径不一致（混合快照/事件/队列语义）
**文件**: 实施方案 §5.3、差距分析 §4.1 报表5
**严重级别**: 轻微 — 口径理解成本高，但逻辑可自洽

```sql
WHERE co.company_id = :companyId
  AND co.get_date BETWEEN :beginDate AND :endDate  -- 口径A：发行时间区间
  -- 但分母 SUM(face_value) 包含了期内发行+期内核销+期内未核销的所有券的 face_value
```

问题不在 SQL 本身，而在于文档描述：**标题是"券发放渠道汇总"，但核销率/已核销数量/未核销数量的分母是"该期间内发放的所有券"**。这在逻辑上可以接受（队组 Cohort 口径：追踪一批券的后续核销情况），但"未核销数量"和"未核销面值"列在发行截止日后仍会随时间变化，**同一期间重跑报表会得到不同结果**——这与 R03/R08（月末固定快照）的习惯不符。

财务人员若按"本期"理解，会误以为期末未核销是某日余额，但实为"发行期截止时点的累积未核销"。

---

#### R06 — 券作废统计表 GROUP BY 包含 `abandon_time`（高基群列进 GROUP BY）
**文件**: 实施方案 §5.4
**严重级别**: 轻微 — 聚合维度失控，结果集膨胀

```sql
GROUP BY co.shop_id, co.abandon_staff, co.coupon, co.type_, co.get_channel, co.abandon_time
                                                                       -- ↑ 高基群，精确到秒
```
`abandon_time`（精确到秒）进入 GROUP BY，导致每条作废记录都是独立的分组，行数等于记录数，**聚合完全无效**。正确做法是 `DATE(co.abandon_time)` 入 GROUP BY，或将作废时间作为 SELECT 列而非 GROUP BY 元素。

---

## 二、时间语义混用矩阵

| 时间字段 | 语义 | 所属报表 | 使用是否正确 |
|---------|------|---------|------------|
| `get_date` | 事件时间（发行） | R01 ✅ R05 ✅ R03 ✅（间接） R08 ✅ | R04 ❌ 误用 |
| `write_off_time` | 事件时间（核销） | R02 ✅ R07 ✅ R03 ✅ | — |
| `abandon_time` | 事件时间（作废） | R06 ❌ GROUP BY 高基群 | 应 DATE() 后入 GROUP BY |
| `deadline` | 快照属性（有效期截止） | R03 ✅ R04 ❌ 当事件时间区间过滤 | R03 用作边界条件正确；R04 当区间端点错误 |
| `coupon_status` | 快照状态 | R04 ❌ 与 deadline 混用 | — |
| 无时间过滤 | — | R09 ❌ | 数据无边界 |

---

## 三、财务报告习惯冲突

### 3.1 缺口 1：月结报表的"期末截止"与"期初起算"不对称
R08 月结试算表的"期末未核销"条件是：
```sql
AND get_date <= :endDate
AND deadline > :endDate
```
而"期初未核销"条件是：
```sql
AND get_date < :startDate
AND deadline > :startDate
```
**问题**：`deadline > :startDate` 和 `deadline > :endDate` 都在边界条件上，但"期初"和"期末"对 deadline 的下界判断逻辑相同，只是起止时间不同。**这个设计是对的**，但文档对此没有给出任何解释，财务人员阅读时容易产生"为什么期初不也过滤 deadline？"的疑问。

### 3.2 缺口 2：勾稽公式与 R03 的"日余额"不对等
R03 日均余额表标注的勾稽公式为（实施方案 §5.1）：
```
期初 + 本期新增 - 本期核销 - 本期作废 - 本期过期 + 本期退款冲回 = 期末
```
R08 月结试算表的勾稽公式为（实施方案 §6.2，已修正版）：
```
期初 + 本期新增 - 本期核销 - 本期过期 = 期末
```
**差异**：R08 勾稽公式**没有"作废"和"退款冲回"维度**。虽然 R08 SQL 中有"本期作废"和"本期退款冲回"两个 UNION ALL 分支，但最终汇总 SQL 根本没有包含它们。文档注释说"退款冲回以独立行预留"，但**勾稽公式里作废和退款冲回凭空消失了**。

这在财务上构成**勾稽失联**：若月内存在作废券，R08 期末余额 ≠ R03 日均余额的期末数，两表无法互相对账。

---

## 四、缺陷汇总评分

| 报告 | 缺陷编号 | 严重程度 | 类型 | 修复优先级 |
|------|---------|---------|------|----------|
| R05 | D1-1 | 🔴严重 | SQL 语法错误（ORDER BY COUNT(*)） | P0 — 立即修复 |
| R05 | D1-2 | 🔴严重 | WHERE 子句不完整，缺 company_id/shopId | P0 — 立即修复 |
| R09 | D2 | 🔴严重 | 完全无时间过滤条件，数据无边界 | P0 — 立即修复 |
| R04 | D3 | 🟠中等 | deadline 属性当事件时间用，语义偷换 | P1 |
| R03 | D4 | 🟠中等 | 无下界时间条件，全表扫描风险 | P1 |
| R08 | D5 | 🟠中等 | 勾稽公式缺少作废和退款冲回维度，与 R03 不对等 | P1 |
| R06 | D6 | 🟡轻微 | GROUP BY 含 `abandon_time` 高基群列 | P2 |
| R05 | D7 | 🟡轻微 | Cohort 口径未明确说明，与快照习惯冲突 | P2 |

---

## 五、核心结论

1. **R05（R06）有不可执行的 SQL**，需立即修正才能作为开发依据。
2. **R09 报表设计缺少时间边界**，在生产环境执行会导致全表扫描和数据泄露风险。
3. **时间语义混用**是贯穿两份文档的主要设计缺陷：`deadline`（快照属性）被当作事件时间使用；`coupon_status`（当前快照）与事件时间混在同一 WHERE 条件中；R03 日余额和 R08 月结勾稽公式的内涵口径不对等。
4. **最小修复建议**：先修 P0（三处 SQL 错误/漏洞），再修 R04 的 deadline 语义定义，最后统一 R03/R08 的勾稽口径。

```

## Concise summary

Provider completed successfully. Review the raw output for details.

## Action items

- Review the response and extract decisions you want to apply.
- Capture follow-up implementation tasks if needed.
