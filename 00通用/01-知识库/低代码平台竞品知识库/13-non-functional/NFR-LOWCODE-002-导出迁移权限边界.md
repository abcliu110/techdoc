---
id: NFR-LOWCODE-002
type: nfr
domain_object: LowCodeExportMigrationSecurity
competitors: [Appsmith, Directus, NocoBase, Frappe]
evidence: [E-APPSMITH-SRC-002, E-DIRECTUS-SRC-001]
strength: 高可信推断
confidence: 0.7
status: active
collected_at: 2026-07-06
valid_until: 2026-10-06
links: [ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# 导出、迁移与模板化的权限边界

## 背景

低代码平台常把导出、复制、模板、迁移视为效率功能，但这些能力会跨越应用、页面、动作、JS、数据源、权限和 workspace 边界。

## 证据

Appsmith 安全公告显示，partial export 流程中如果应用 ID、页面 ID 和资源归属校验不一致，可能导致私有 actions 或 JS collections 被导出。

Directus ItemsService 源码线索显示，通用对象服务依赖 schema 和 accountability 执行读写。对自研平台而言，导出/迁移服务同样必须继承这一类执行上下文。

## 设计原则

```text
导出不是普通读取，必须做资源归属校验。
模板不是普通复制，必须清理敏感数据源、密钥和环境变量。
迁移不是普通写入，必须保留执行身份、审计、版本和回滚信息。
跨应用/跨空间引用必须显式声明，不能靠 ID 猜测归属。
```

## 对自研平台的要求

- ExportService / ImportService 必须接收 execution context。
- 应用、页面、动作、数据源、脚本、权限、流程的归属关系必须可追踪。
- 模板化输出必须默认脱敏数据源连接、token、密钥和环境变量。
- 权限测试必须覆盖“用户 A 应用 ID + 用户 B 页面 ID”这类错配场景。

## 待验证

- NocoBase duplicator、Frappe fixtures/export、Appsmith export、Directus schema snapshot 的权限边界对比。
