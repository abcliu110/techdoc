---
id: BR-LOWCODE-FORM-001
type: rule
domain_object: FormDesigner
competitors: [Jotform, Typeform, Airtable, SurveyJS, Formstack, Form.io, Frappe, NocoBase]
evidence: [E-JOTFORM-FORM-001, E-TYPEFORM-FORM-001, E-AIRTABLE-FORM-001, E-SURVEYJS-FORM-001, E-FORMSTACK-FORM-001, E-FORMIO-FORM-001, E-FRAPPE-UI-005, E-NOCOBASE-UI-002]
strength: 高可信推断
confidence: 0.7
status: active
collected_at: 2026-07-07
valid_until: 2026-10-07
links: [UI-LOWCODE-FORM-001, DM-LOWCODE-FORM-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# 业务规则：表单设计器规则与安全边界

## 规则分类

| 规则类型 | 示例 | 运行时影响 |
|---|---|---|
| 可见性规则 | 显示/隐藏字段、分组、页面、选项 | 影响填写体验，不应作为安全边界 |
| 编辑性规则 | 只读、禁用、必填、遮罩 | 影响输入行为，需要服务端复核 |
| 路径规则 | 跳页、跳题、分支、Logic Map | 改变填写路径，需要顺序和冲突治理 |
| 计算规则 | 分数、价格、字段计算、默认值 | 影响提交数据，需要精度和回放能力 |
| 提交后规则 | Thank You、通知、邮件收件人、Webhook | 影响副作用，需要幂等和失败重试 |
| 流程规则 | 审批人、顺序、评论、批准/拒绝 | 影响提交状态，需要审计 |

## 安全边界

1. 字段隐藏不等于字段权限。Airtable 官方文档已明确提示视觉隐藏不应用于敏感字段。
2. 前端校验不等于服务端校验。所有必填、类型、范围、跨字段一致性都要在提交接口复核。
3. 条件逻辑不等于工作流。表单内规则只处理填写和提交前后行为；审批、退回、转交应进入流程模型。
4. PublishedForm 需要访问控制。内部表单、外部门户表单、匿名表单、嵌入表单不能共用同一默认权限。
5. 提交副作用要幂等。邮件、Webhook、审批启动、支付、文档生成都不能因重试重复执行。

## 失败模式

| 失败模式 | 触发条件 | 设计约束 |
|---|---|---|
| 规则遮蔽 | 多条分支规则顺序不清，先命中规则阻断后续路径 | 显示规则优先级，提供规则图和测试预览 |
| 隐藏字段泄露 | 只隐藏字段但未限制读取/提交 | 权限在服务端执行，隐藏仅作为 UI 状态 |
| 字段改名破坏规则 | 底层字段删除或改名，条件规则引用失效 | 发布前做断链检测，标记 invalid condition |
| 草稿污染发布 | 已发布表单直接读取编辑中配置 | 发布快照不可变，草稿独立保存 |
| 副作用重复执行 | 用户重复提交或网络重试 | Submission 幂等键和副作用 outbox |

## 设计启发

表单设计器的规则引擎首版要小而清楚：

```text
IF field/operator/value THEN target/action/value
target: field / section / page / submit / notification
action: show / hide / require / readonly / calculate / jump / notify
```

表达式、脚本和复杂图编辑器可以后置，但规则引用、优先级、预览、断链检测和服务端复核必须从首版纳入。

