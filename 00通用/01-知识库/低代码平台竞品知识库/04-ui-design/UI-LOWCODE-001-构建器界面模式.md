---
id: UI-LOWCODE-001
type: ui
domain_object: AppBuilder
competitors: [Appsmith, ToolJet, Budibase, Lowcoder, NocoBase]
evidence: [E-APPSMITH-001, E-TOOLJET-001, E-BUDIBASE-001, E-LOWCODER-001, E-NOCOBASE-001]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# UI 设计：低代码构建器通用界面模式

成熟度说明：本卡基于公开文档形成，尚未通过本地试用逐屏验证；当前只作为 L0 方向级 UI 模式判断。

## 页面目标

低代码构建器界面的目标是让用户在一个工作台内完成“选择组件、配置属性、绑定数据、预览运行、发布应用”。

## 常见布局

```text
左侧：页面/组件树/数据源/资源面板
中间：画布或表单预览区
右侧：属性配置、事件配置、样式配置
底部或弹层：查询编辑器、脚本编辑器、调试输出
顶部：保存、预览、发布、环境切换、版本控制
```

## 竞品模式

- Appsmith / ToolJet / Lowcoder：典型 UI Builder 工作台，强调组件拖拽、数据源、查询和 JS/表达式绑定。
- Budibase：在 screens、components、data bindings、automations 间切换，强调数据和自动化协同。
- NocoBase：更强调围绕 collection 生成 block / page，而不是从空画布纯拖拽开始。

## 适用边界

这种 UI 很适合开发者或高阶业务人员，但对普通业务用户仍有门槛。企业业务低代码如果直接复制内部工具 builder，会把业务人员暴露在“数据源、查询、脚本、绑定”复杂度里。

## 设计启发

自研平台应采用双层 UI：

```text
业务建模 UI：对象、字段、状态、动作、流程、权限
页面编排 UI：列表、表单、详情、看板、报表、操作按钮
```

业务建模 UI 的优先级高于自由画布。
