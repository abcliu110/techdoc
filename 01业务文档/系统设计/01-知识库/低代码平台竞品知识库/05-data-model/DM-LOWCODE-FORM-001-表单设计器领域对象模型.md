---
id: DM-LOWCODE-FORM-001
type: data-model
domain_object: FormDesigner
competitors: [Frappe, NocoBase, Jotform, Typeform, Airtable, SurveyJS, Formstack, Form.io]
evidence: [E-FRAPPE-UI-001, E-NOCOBASE-UI-002, E-JOTFORM-FORM-001, E-TYPEFORM-FORM-001, E-AIRTABLE-FORM-001, E-SURVEYJS-FORM-001, E-FORMSTACK-FORM-001, E-FORMIO-FORM-001]
strength: 高可信推断
confidence: 0.7
status: active
collected_at: 2026-07-07
valid_until: 2026-10-07
links: [UI-LOWCODE-FORM-001, BR-LOWCODE-FORM-001, ADR-LOWCODE-DM-001]
owner: AI
ai_generated: true
---

# 数据模型：表单设计器领域对象模型

## 核心对象

| 对象 | 职责 | 证据来源 |
|---|---|---|
| FormDefinition | 表单定义、标题、描述、状态、版本、展示类型 | Frappe Web Form、Form.io Form Builder |
| FormField | 字段绑定、控件类型、默认值、校验、提示、只读/必填 | Frappe Field Types、NocoBase Form block、Airtable form fields |
| LayoutNode | section、column、tab、page、panel、group、wizard step | Frappe layout fields、SurveyJS panel/page、Airtable group |
| FormRule | 条件、目标、动作、优先级、启停状态 | Jotform Conditions、SurveyJS Logic tab、Typeform branching |
| FormPath | 对话式或多步骤表单的问题路径、跳转目标 | Typeform Logic Map、Jotform skip page |
| Submission | 提交记录、草稿、来源、提交人、附件、状态 | Formstack approval、Frappe Web Form |
| ApprovalInstance | 审批人、顺序、评论、批准/拒绝、退回/重提 | Formstack Approvals |
| FormTemplate | 字段模板、表单模板、复制/引用关系 | NocoBase 表单模板、Form.io copy JSON |
| PublishedForm | 发布渠道、访问范围、嵌入地址、版本快照 | Frappe Web Form、Form.io display type |

## 关系模型

```text
BusinessObject
  -> default FormDefinition
  -> FormField[] binds BusinessField
  -> LayoutNode[] organizes FormField
  -> FormRule[] targets Field / LayoutNode / Page / Submission / Notification
  -> PublishedForm[] snapshots FormDefinition
  -> Submission[] created by PublishedForm
  -> ApprovalInstance? attached after Submission
```

## 不变量

1. 已发布表单必须引用版本快照，不能直接读取草稿配置。
2. 删除或改名字段时，必须影响分析表单字段、规则、路径、审批和集成。
3. 条件显隐不改变字段权限；权限判定必须在提交和读取时再次执行。
4. 表单提交必须校验服务端规则，不能只依赖前端设计器配置。
5. 表单模板复制和引用要有明确语义，否则同对象多个表单会产生配置漂移。

## 首版建议

```text
MVP：FormDefinition + FormField + LayoutNode + FormRule + PublishedForm + Submission
暂缓：复杂 Logic Map 编辑器、PDF 表单、完整审批评论链、AI 自动生成表单
```

## 待验证

- 是否需要把 FormRule 独立为平台通用 Rule，而不是表单私有规则。
- PublishedForm 是否与应用发布版本统一，还是独立版本。
- 门户表单提交是否纳入同一 Submission 表，还是按匿名/外部渠道隔离。

