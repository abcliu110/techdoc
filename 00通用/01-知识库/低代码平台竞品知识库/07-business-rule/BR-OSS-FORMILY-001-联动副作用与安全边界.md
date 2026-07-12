---
id: BR-OSS-FORMILY-001
type: rule
domain_object: FormilyReaction
competitors: [Formily, Formily-Designable]
evidence: [E-OSS-FORM-FORMILY-SRC-002, E-OSS-FORM-FORMILY-SRC-004, E-OSS-FORM-DESIGNABLE-001]
strength: 源码初证
confidence: 0.6
status: active
collected_at: 2026-07-07
valid_until: 2026-10-07
links: [DM-OSS-FORMILY-001, BR-LOWCODE-FORM-001]
owner: AI
ai_generated: true
---

# 业务规则：Formily 联动副作用与安全边界

## 核心判断

Formily 的价值不只在 schema 渲染，而在字段状态、路径查询和联动副作用可以组合出复杂动态表单。对低代码平台而言，这类能力必须治理，否则会变成不可解释的规则网络。

## 可借鉴规则模型

```text
source path -> condition -> target path -> state patch / value patch / component props patch
```

可借鉴点：

- 用字段路径而不是组件实例作为规则目标。
- 支持批量匹配和通配路径。
- 允许字段状态被规则修改，而不仅是值被修改。
- 将副作用独立于组件渲染，使联动可复用。

## 风险边界

| 风险 | 触发条件 | 自研约束 |
|---|---|---|
| 联动不可解释 | x-reactions 分散在多个 schema 节点中 | 提供规则总览、依赖图和执行日志 |
| 组件协议不一致 | 自定义组件不支持预期 value/onChange/error 协议 | 建立组件适配器测试和物料准入 |
| 路径失效 | 字段重命名、数组移动、模板复用 | 发布前做路径引用校验和影响分析 |
| 设计态污染运行态 | 拖拽、选中、物料配置进入运行 schema | schema transform 剥离设计态字段 |
| 前端规则绕过 | 服务端不复核必填、范围、权限 | 服务端校验和权限判断独立执行 |

## 自研平台落点

1. 首版不直接开放任意 JS reaction。
2. 先做声明式规则：source、operator、target、action。
3. 高级 reaction 进入插件或脚本沙箱，并要求审计。
4. 所有规则引用必须进入知识图谱/影响分析。
5. 发布态 schema 必须通过断链检测、循环依赖检测和权限边界检查。

## 待验证

- Formily reactions 的完整类型与执行时机。
- effects 与 validator 的边界。
- Designable 设计态如何编辑、展示和导出 reactions。
- 用户自定义组件对 reaction 的协议要求。

