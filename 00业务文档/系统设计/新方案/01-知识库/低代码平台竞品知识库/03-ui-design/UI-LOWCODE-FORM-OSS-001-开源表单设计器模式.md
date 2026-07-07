---
id: UI-LOWCODE-FORM-OSS-001
type: ui
domain_object: OpenSourceFormDesigner
competitors: [Formily, Formily-Designable, SurveyJS, Form.io, react-jsonschema-form, JSON-Forms, react-json-schema-form-builder, ngx-formly, uniforms, Vueform, FormKit]
evidence: [E-OSS-FORM-FORMILY-001, E-OSS-FORM-DESIGNABLE-001, E-SURVEYJS-FORM-001, E-FORMIO-FORM-001, E-OSS-FORM-RJSF-001, E-OSS-FORM-JSONFORMS-001, E-OSS-FORM-BUILDER-001, E-OSS-FORM-FORMLY-001, E-OSS-FORM-UNIFORMS-001, E-OSS-FORM-VUEFORM-001, E-OSS-FORM-FORMKIT-001]
strength: 高可信推断
confidence: 0.7
status: active
collected_at: 2026-07-07
valid_until: 2026-10-07
links: [UI-LOWCODE-FORM-001, DM-LOWCODE-FORM-001, BR-LOWCODE-FORM-001]
owner: AI
ai_generated: true
---

# UI 设计：开源表单设计器与 schema 表单模式

## 横向模式

| 模式 | 代表项目 | 核心价值 | 主要边界 |
|---|---|---|---|
| JSON Schema 渲染器 | react-jsonschema-form、JSON Forms | 用标准 schema 生成表单，便于后端驱动和跨系统交换 | 通常不是完整可视化设计器，缺少企业发布/权限/流程 |
| Schema + UI Schema 分离 | JSON Forms、rjsf、Form.io | 把数据结构和 UI 表现拆开，降低表单布局污染数据模型 | 规则、权限、提交动作仍需额外建模 |
| 可视化 JSON Builder | react-json-schema-form-builder、Form.io、SurveyJS Creator | 让业务或运营用户通过拖拽生成 schema | 容易停留在字段拖拽，缺少业务对象语义 |
| 字段状态/联动引擎 | Formily、ngx-formly、FormKit、Vueform | 管理字段状态、校验、联动、副作用和性能 | 与具体前端框架绑定，需要抽象平台协议 |
| 多 schema adapter | uniforms | 通过 bridge 支持 JSON Schema、SimpleSchema、Zod 等 | 适合作运行时，不天然提供设计器治理 |
| 设计器生态 | Formily Designable、SurveyJS Creator、Vueform Builder | 提供设计态物料、属性面板、预览和 schema 导出 | License、商业边界和源码可控性需复核 |

## 对低代码平台的架构启发

开源生态显示，表单设计器至少应拆成六层：

```text
Data Schema：业务字段、类型、校验、关系
UI Schema：布局、控件、容器、步骤、主题
Rule Schema：显隐、只读、必填、计算、联动、副作用
Renderer Registry：组件映射、主题、平台端适配
Validator：前端即时校验 + 服务端最终校验
Publish Snapshot：发布版本、回滚、引用影响分析
```

## 不宜照搬

1. 不把 JSON Schema 当成完整业务元模型；它不能表达企业权限、流程和单据状态的全部语义。
2. 不把前端 field config 直接作为后端契约；需要版本、校验和迁移。
3. 不把用户可配置 schema 直接执行；需要组件白名单、表达式限制和 XSS 防护。
4. 不把可视化 Builder 等同低代码平台；企业低代码还需要权限、审计、发布、流程和数据治理。

## 下一轮源码深挖优先级

```text
A 级：Formily + Designable、SurveyJS Creator、Form.io
B 级：JSON Forms、rjsf、react-json-schema-form-builder、ngx-formly、uniforms、Vueform、FormKit
```

## 待验证

- 各项目 License 与商业使用边界。
- 设计态 schema 到运行态 schema 的转换机制。
- 字段联动、表达式和用户自定义 schema 的安全边界。
- 服务端校验和前端渲染是否能复用同一 schema。

