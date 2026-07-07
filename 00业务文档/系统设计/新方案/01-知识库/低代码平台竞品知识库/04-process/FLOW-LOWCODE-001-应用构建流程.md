---
id: FLOW-LOWCODE-001
type: process
domain_object: LowCodeApp
competitors: [Kingdee-Cosmic, Appsmith, ToolJet, Budibase, NocoBase, Frappe, Directus]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-002, E-KINGDEE-COSMIC-004, E-KINGDEE-COSMIC-006, E-APPSMITH-001, E-APPSMITH-DOC-002, E-APPSMITH-DOC-003, E-TOOLJET-001, E-BUDIBASE-001, E-NOCOBASE-001, E-FRAPPE-001, E-DIRECTUS-DOC-004]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [FLOW-KINGDEE-001, FLOW-DIRECTUS-001, ADR-LOWCODE-FLOW-001]
owner: AI
ai_generated: true
---

# 流程：低代码应用构建主流程

成熟度说明：本卡基于公开文档和产品描述抽象，尚未通过同一“客户-订单-审批”样例实测验证；当前只作为 L0 方向级流程判断。

## 内部工具构建器流程

```text
创建应用
→ 连接数据源/API
→ 编写查询或动作
→ 拖拽 UI 组件
→ 绑定查询结果和事件
→ 配置权限
→ 预览/调试
→ 发布
```

## 业务元模型平台流程

```text
定义业务对象
→ 定义字段、关系、分录/子表
→ 定义状态、动作、规则
→ 定义流程、审批、通知
→ 自动生成或配置列表/表单/详情
→ 配置权限、组织、数据范围
→ 发布模型和页面
→ 运行业务数据
→ 版本升级和模型扩展
```

## 关键差异

内部工具构建器把“页面”放在中心；业务元模型平台把“业务对象”放在中心。

## 设计启发

自研平台应优先支持第二种流程，并把第一种流程作为页面层能力补充。

## 本轮补充

- 金蝶流程服务云公开资料显示，企业级流程需要覆盖设计、建模、运行监控、安全审计和移动处理，并与动态模型元数据相连。
- Directus Flows 官方文档显示，自动化流程至少包含 trigger、operation、data chain 和 execution accountability。
- Appsmith 文档显示，内部工具流程以 widgets、datasources、queries、JavaScript bindings 为核心，适合页面层快速构建，但不应替代业务对象和流程治理。
