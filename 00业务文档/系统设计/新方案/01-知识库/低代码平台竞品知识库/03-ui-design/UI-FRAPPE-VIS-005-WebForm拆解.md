---
id: UI-FRAPPE-VIS-005
type: ui
domain_object: WebForm
competitors: [Frappe]
evidence: [E-FRAPPE-UI-005, E-FRAPPE-UI-006]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-FRAPPE-VIS-001, DM-FRAPPE-SRC-002]
owner: AI
ai_generated: true
---

# Frappe Web Form 拆解

## 页面目标

把 DocType 字段暴露成网站表单，支持公开填写、登录填写或私有链接填写。

## 页面分区

```text
Web Form 基础配置
字段选择
布局：section / column / page break
访问控制：public / login / private request link
提交按钮与成功状态
```

## 设计启发

自研平台应把内部表单和外部门户表单分离：二者共享对象字段，但访问控制、提交状态、匿名用户、反垃圾和审计要求不同。

## 边界

尚未验证外部提交后的数据写入、校验、权限和审批触发。
