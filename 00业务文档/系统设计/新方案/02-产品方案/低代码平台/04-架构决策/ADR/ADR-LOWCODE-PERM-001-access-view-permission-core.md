# ADR-LOWCODE-PERM-001: AccessView 权限判定内核

Status: proposed

Date: 2026-07-06

## Context

低代码平台权限必须同时影响 `/meta`、list、get、add、update、del、action、suggest、link 展开、导入导出和级联写。若各入口分别读取权限元数据并自行裁剪，字段权限、对象权限和数据范围会发生漂移，最终形成越权。

PRD 已确认组织数据范围时间语义：对象级配置，默认 `OWNER_SNAPSHOT`。

## Decision

请求内每个对象只允许通过 `AccessDecider` 计算一次不可变 `AccessView`：

```text
AccessView:
  objectPerms: read/create/update/delete/actions[]
  fieldView: fieldCode -> NONE | READ | WRITE
  scopeAst: data_scope 折算出的 filters AST
  metaHash: 本次判定依据的元数据摘要
  permVersion: 用户/角色/组织树/字段权限/数据范围版本组合
```

所有权限消费点只读取 `AccessView`：

```text
/meta, list, get, add, update, del, action, suggest,
link 展开, 导出, 导入, 级联写
```

`data_scope` 必须在 AST 层合并为 `RootAnd(scopeAst, userFilters)`，不得字符串拼接。权限拒绝必须写 `PlatformEvent(PERMISSION_DENY)`，包含 `metaHash`、`permVersion`、`traceId` 和拒绝原因。

## Consequences

- T-103 必须先交付 `AccessDecider`、`AccessView` 和权限解释接口。
- suggest/link 展开必须对目标对象重新计算或读取目标对象 `AccessView`。
- 组织变更历史范围默认按 `OWNER_SNAPSHOT`，对象显式声明 `CURRENT_ORG` 时才使用当前组织关系。
- 权限缓存失效以 `permVersion` 为边界；角色、用户、组织树和权限配置变化都必须推动版本变化。

## Rejected

Rejected: `/meta`、查询和写入各自裁剪权限 | 短期实现快，但字段权限和数据范围无法证明一致。

Rejected: 只在 SQL 层拼接 data_scope 字符串 | OR 短路和括号优先级容易造成越权。

## Verification

- 无 read 权限字段在 `/meta/list/get/export` 中一致不可见。
- 无 write 权限字段在 `add/update/import/级联写` 中一致拒绝。
- 构造顶层 OR filter 不得绕过 `scopeAst`。
- 调岗、部门删除、部门合并、组织树移动测试覆盖默认 `OWNER_SNAPSHOT` 和对象级 `CURRENT_ORG` 覆盖。

