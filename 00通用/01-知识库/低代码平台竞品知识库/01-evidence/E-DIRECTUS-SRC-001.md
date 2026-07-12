---
id: E-DIRECTUS-SRC-001
type: evidence
competitor: Directus
module: items-service
source_channel: github
source_type: source
source_url: https://github.com/directus/directus/blob/main/api/src/services/items.ts
source_owner: project-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-repository
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Directus ItemsService

## 原始观察

Directus GitHub 源码中的 `api/src/services/items.ts` 显示 ItemsService 围绕 collection、schema、accountability、knex 等上下文执行 item 读写，并在更新等路径中调用访问校验、payload 处理、事务、快照和活动记录相关逻辑。

## 证据强度

源码初证：已阅读公开源码页面，但未本地运行和调试。

## 可抽取知识

- Directus 把 collection 作为 ItemsService 的服务边界，服务执行依赖 schema 与 accountability。
- 低代码平台的通用 CRUD 服务必须把权限上下文、schema、事务和审计作为基础参数，而不是在控制器里临时拼接。
- 自研平台如果实现通用对象服务，应显式传递执行身份和元模型快照，避免绕过权限或审计。
