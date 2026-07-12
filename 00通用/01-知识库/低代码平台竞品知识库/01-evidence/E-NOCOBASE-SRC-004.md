---
id: E-NOCOBASE-SRC-004
type: evidence
competitor: NocoBase
module: workflow
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/plugins/%40nocobase/plugin-workflow/src/common/collections/workflows.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase Workflow Collection 源码

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/plugins/@nocobase/plugin-workflow/src/common/collections/workflows.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：raw 文件可复核；`name: 'workflows'` 在 L15，`repository: 'WorkflowRepository'` 在 L18，`enabled` 在 L55，`config` 在 L98，`nodes` 在 L104，`executions` 在 L110，`sync` 在 L128，`revisions` 在 L152。

## 原始观察

Workflow collection 配置中包含：

- `name: 'workflows'`
- `dataCategory: 'system'`
- `shared: true`
- `repository: 'WorkflowRepository'`
- `createdBy` / `updatedBy` / `createdAt` / `updatedAt`
- `fields` 数组

字段片段显示 workflow 具有 `id`、`key`、`title`、`enabled` 等字段，并通过 `uiSchema` 描述界面组件，例如 `InputNumber`、`Input`、`radioGroup` 等。

## 证据强度

直接事实。源码明确给出 workflow collection 的元数据结构和字段定义方式。
