---
id: BR-OSS-FORMILY-002
type: rule
domain_object: FormilyValidator
competitors: [Formily]
evidence: [E-OSS-FORM-FORMILY-SRC-005, E-OSS-FORM-FORMILY-SRC-003, E-OSS-FORM-FORMILY-001]
strength: 高可信推断
confidence: 0.55
status: active
collected_at: 2026-07-07
valid_until: 2026-10-07
links: [BR-OSS-FORMILY-001, BR-LOWCODE-FORM-001, DM-OSS-FORMILY-001]
owner: AI
ai_generated: true
---

# 业务规则：Formily Validator 与服务端校验边界

## 核心判断

低代码平台不能只依赖前端表单框架的校验结果。Formily 有独立 validator 包的线索，但是否适合服务端生产复用，需要单独验证。

## 校验分层

```text
前端即时校验：提升体验，提示必填、格式、长度、跨字段规则。
设计器校验：检查 schema 断链、组件缺失、规则循环、非法表达式。
发布前校验：冻结发布态 schema，阻断未授权组件和危险表达式。
服务端最终校验：提交入口强制执行类型、权限、必填、范围、业务不变量。
```

## 自研平台约束

1. 前端 validator 不能成为唯一数据安全边界。
2. schema 中的校验规则必须能被服务端识别或映射。
3. 服务端不支持的前端规则必须标记为“体验校验”，不能保护业务不变量。
4. 业务规则、权限规则和 UI 校验规则要分开存储。
5. 提交接口必须记录使用的 schema 版本，便于回放和审计。

## 待验证

- `@formily/validator` 是否可在 Node 服务端独立运行。
- validator 对 x-validator、x-reactions、异步校验的支持边界。
- 与 Java/Spring 后端复用 schema 的可行性。
- 错误消息、国际化和字段路径回传格式。

