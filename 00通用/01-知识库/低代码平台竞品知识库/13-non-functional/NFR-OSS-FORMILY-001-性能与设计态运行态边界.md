---
id: NFR-OSS-FORMILY-001
type: nfr
domain_object: FormilyRuntime
competitors: [Formily, Formily-Designable]
evidence: [E-OSS-FORM-FORMILY-001, E-OSS-FORM-DESIGNABLE-001, E-OSS-FORM-FORMILY-SRC-001, E-OSS-FORM-FORMILY-SRC-002]
strength: 源码初证
confidence: 0.6
status: active
collected_at: 2026-07-07
valid_until: 2026-10-07
links: [DM-OSS-FORMILY-001, UI-LOWCODE-FORM-OSS-001]
owner: AI
ai_generated: true
---

# 非功能：Formily 性能与设计态/运行态边界

## 性能启发

Formily README 明确指出受控表单整树渲染在数据联动场景下容易卡顿，因此采用字段级分布式状态管理。源码线索也显示 Field 会 makeObservable/makeReactive，批量状态更新按字段路径匹配。

对自研平台的启发：

```text
表单运行时性能瓶颈不在字段数量本身，而在联动、校验、整树重渲染和属性面板同步。
```

## 设计态/运行态边界

Designable README 说明后端使用 JSON Schema，前端使用 JSchema，两种范式可互转，并且副作用独立管理。

这说明表单设计器至少有三类 schema：

```text
设计态 schema：包含拖拽、选中、物料、属性面板、辅助线等信息。
发布态 schema：经过校验、裁剪、版本化的稳定定义。
运行态 schema：渲染器和校验器实际消费的结构。
```

## 自研平台非功能约束

1. 大表单字段数达到 100+ 时，字段输入不应触发整页重渲染。
2. 联动规则变更必须局部传播，并能看到影响字段。
3. 设计器属性面板编辑不应污染运行时提交数据。
4. 发布态 schema 必须可 diff、可回滚、可断链检测。
5. schema 中的表达式、HTML、组件名、远程数据源必须经过白名单和权限控制。

## 待验证

- Formily 字段级状态在 100/500/1000 字段下的性能表现。
- Designable schema transform 的真实输出结构。
- 复杂 x-reactions 的执行顺序和调试能力。
- 服务端复用 Formily validator 的可行性和边界。

