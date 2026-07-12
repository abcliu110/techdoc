---
id: DM-OSS-FORMILY-001
type: data-model
domain_object: FormilyFieldState
competitors: [Formily, Formily-Designable]
evidence: [E-OSS-FORM-FORMILY-001, E-OSS-FORM-DESIGNABLE-001, E-OSS-FORM-FORMILY-SRC-001, E-OSS-FORM-FORMILY-SRC-002, E-OSS-FORM-FORMILY-SRC-003]
strength: 源码初证
confidence: 0.65
status: active
collected_at: 2026-07-07
valid_until: 2026-10-07
links: [UI-LOWCODE-FORM-OSS-001, DM-LOWCODE-FORM-001, BR-OSS-FORMILY-001]
owner: AI
ai_generated: true
---

# 数据模型：Formily 字段状态与 Schema 模型

## 证据边界

本卡基于 Formily README、Designable README 和公开源码入口文件形成源码初证。当前没有完整 clone 仓库执行测试，也没有逐行阅读全部 core/json-schema 包，因此不能作为完整源码审计结论。

## 本质模型

Formily 不是单纯 JSON Schema 渲染器，而是“字段状态引擎 + schema 渲染协议 + 联动副作用机制”的组合。

```text
Form
  -> Field / ArrayField / ObjectField / VoidField
  -> FieldState
  -> Schema Node
  -> Component / Decorator
  -> Validator / Reaction / Effect
```

## 关键对象

| 对象 | 职责 | 证据 |
|---|---|---|
| Form | 字段容器、查询、生命周期通知、值管理 | internals.ts 的 form.query / notify 线索 |
| Field | 字段状态单元，包含初始化、响应式和生命周期 | Field.ts 源码线索 |
| FormPath | 字段路径与通配匹配 | createBatchStateSetter 路径匹配线索 |
| Schema | 后端/运行时描述协议 | README 与 json-schema transformer |
| x-component | 运行时控件映射 | x-reactions discussion schema 片段 |
| x-decorator | 外层装饰器/表单项布局 | x-reactions discussion schema 片段 |
| x-reactions | 字段联动和副作用规则 | discussions/3176 等风险线索 |
| Designable Schema | 设计态 schema，与运行态 schema 可转换 | designable-vue README |

## 设计启发

1. 低代码表单不能只保存字段数组；字段需要有独立状态和生命周期。
2. 字段地址/路径必须稳定，才能支持批量状态更新、联动规则和影响分析。
3. data schema、ui schema、component mapping、reaction/effect 应分层。
4. schema transform 是设计器和运行时之间的关口，必须可测试、可版本化。
5. 设计态字段与运行态字段不应完全同构；设计态需要选中、拖拽、物料、属性面板等信息，运行态需要渲染、校验、提交和权限。

## 对自研平台的约束

```text
字段状态模型：必须独立于 React/Vue 组件实例。
Schema 协议：必须能表达控件、布局、校验、联动、只读/隐藏/必填。
路径协议：必须稳定支持数组、对象、通配和重命名影响分析。
转换协议：设计态 schema -> 发布态 schema -> 运行态 schema 必须可追踪。
```

## 待补源码

- `packages/core/src/models/Form.ts`
- `packages/core/src/models/BaseField.ts`
- `packages/core/src/models/ArrayField.ts`
- `packages/core/src/models/ObjectField.ts`
- `packages/json-schema/src/transformer.ts`
- `packages/validator`

