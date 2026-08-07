# 废弃候选登记

## 1. 废弃候选概览

| 候选 ID | 候选项 | 类型 | 发现日期 | 候选原因 | 状态 |
|---------|--------|------|----------|----------|------|
| DC001 | /boss/* 旧报表接口 | API | 2024-01 | 已由 pos11report 承担 | 待评估 |
| DC002 | pos3boot 中的打印相关代码 | 代码 | 2024-01 | 打印服务已迁移到 pos10printer | 待验证 |
| DC003 | 旧版会员积分计算逻辑 | 代码 | 2024-01 | 新版使用 nms4cloud-crm | 待验证 |

## 2. 候选详情

### 2.1 DC001: /boss/* 旧报表接口

**发现来源**：CLAUDE.md / project-relationships.md

**现状描述**：
- 原 `nms4cloud-bi` 服务提供 `/boss/*` 报表接口
- 新版 `nms4cloud-pos11report` 承担新实现，但服务名仍为 `nms4cloud-bi`

**候选理由**：
- 原 BI 服务代码可能已废弃
- 新旧实现共存可能导致混淆

**流量分析**：
```sql
-- 检查旧接口流量
SELECT COUNT(*) FROM access_log
WHERE path LIKE '/boss/%'
  AND access_time > DATE_SUB(NOW(), INTERVAL 30 DAY);
```

**影响评估**：
- 前端可能仍在调用旧接口
- 需确认前端路由配置

**建议行动**：
1. 检查前端调用情况
2. 确认旧接口是否有未迁移的功能
3. 制定废弃时间表

---

### 2.2 DC002: pos3boot 中的打印相关代码

**发现来源**：CLAUDE.md 矛盾记录 C001

**现状描述**：
- CLAUDE.md 描述打印服务在 pos10printer
- 但 pos3boot-biz 中也有部分打印实现

**候选理由**：
- 职责不清，可能存在代码冗余
- 影响系统维护

**验证步骤**：
```bash
# 检查 pos3boot 中的打印代码
grep -r "print" nms4cloud-pos3boot-biz/src/main/java/
grep -r "Printer" nms4cloud-pos3boot-biz/src/main/java/
```

**影响评估**：
- 可能影响打印功能
- 需验证是否仍在使用

**建议行动**：
1. 确认 pos3boot 中的打印代码是否被调用
2. 如果废弃，需要迁移到 pos10printer
3. 保持向后兼容一段时间

---

### 2.3 DC003: 旧版会员积分计算逻辑

**发现来源**：业务分析发现

**现状描述**：
- 旧版可能在 pos2plugin 中计算会员积分
- 新版使用 nms4cloud-crm 统一管理

**候选理由**：
- 功能重复
- 可能导致积分计算不一致

**验证步骤**：
```bash
# 检查 pos2plugin 中的积分计算
grep -r "integral" nms4cloud-pos2plugin-biz/src/main/java/
```

**影响评估**：
- 会员数据一致性
- 积分准确性

**建议行动**：
1. 确认积分计算的调用方
2. 统一使用 nms4cloud-crm 的积分服务
3. 迁移调用方

## 3. 废弃决策流程

```
发现候选
    │
    ▼
┌─────────────────────────────────────────┐
│ 候选评估                                   │
│ - 是否有流量？                            │
│ - 是否有调用方？                          │
│ - 是否被数据依赖？                        │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│ 决策                                       │
│ - 保留：记录兼容契约，继续维护             │
│ - 废弃：制定迁移计划                       │
└─────────────────────────────────────────┘
```

## 4. 废弃后向兼容策略

### 4.1 废弃标记

```java
/**
 * @deprecated 废弃原因：已迁移到 pos10printer
 * 废弃日期：2024-06-01
 * 计划删除日期：2025-01-01
 * 替代方案：PosPrinterService
 */
@Deprecated
public class OldPrinterService {
    // ...
}
```

### 4.2 流量切换

```yaml
# 流量切换配置
deprecated:
  - path: /boss/report/*
    redirect_to: /boss/v2/report/*
    switch_date: 2024-06-01
    final_date: 2025-01-01
```

## 5. 证据索引

| 候选 ID | 证据来源 | 证据类型 |
|---------|----------|----------|
| DC001 | CLAUDE.md, project-relationships.md | DOC |
| DC002 | CLAUDE.md 矛盾记录 C001 | DOC |
| DC003 | 业务分析推断 | - |

