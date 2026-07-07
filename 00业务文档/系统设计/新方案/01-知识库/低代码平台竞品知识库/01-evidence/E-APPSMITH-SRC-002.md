---
id: E-APPSMITH-SRC-002
type: evidence
competitor: Appsmith
module: export-permission
source_channel: github-security-advisory
source_type: security-advisory
source_url: https://github.com/appsmithorg/appsmith/security/advisories/GHSA-9xfc-9f97-x524
source_owner: project-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-advisory
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Appsmith 部分导出权限边界风险

## 原始观察

Appsmith GitHub 安全公告披露了 partial application export 流程中的 BOLA/IDOR 风险。公告指向的相关组件包含 ApplicationController、PartialExportService、NewPageService、NewActionService、ActionCollectionService 等。

问题核心是导出请求同时包含应用 ID 和页面 ID，授权检查与资源归属校验之间出现错配，可能导致跨应用或跨 workspace 导出私有 actions 和 JS collections。

## 证据强度

直接事实：官方安全公告明确披露风险、影响端点和相关组件。该证据证明低代码“导出/迁移”能力存在权限边界风险，不证明当前版本仍受影响。

## 可抽取知识

- 低代码平台的导出、迁移、复制、模板化不是纯工具功能，而是高风险权限边界。
- 页面、action、JS collection、application、workspace 之间必须做一致的归属校验。
- 自研平台的模型导出能力需要纳入权限矩阵和安全测试，而不是只做功能验收。
