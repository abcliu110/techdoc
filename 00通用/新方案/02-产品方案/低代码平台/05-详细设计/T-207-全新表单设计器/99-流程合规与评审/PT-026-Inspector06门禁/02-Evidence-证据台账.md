# PT-026 Inspector：02-Evidence-证据台账

版本：v1.0  
日期：2026-07-10  
范围：右侧 Inspector / 属性面板详细原型

## 1. 证据边界

本证据台账只证明 `PT-026 Inspector` 区域已经具备企业级表单设计器属性面板的本轮可交付能力：真实属性页签、属性编辑、SchemaPatch、搜索过滤、折叠/展开和自动化抓手。

本台账不证明整个表单设计器完成，也不证明已经超过金蝶、DevExpress 或 Visual Studio。

## 2. 原型证据

| 项 | 证据 |
|---|---|
| 原型文件 | `T-207-表单设计器-09原型.html` |
| 页面锚点 | `#pt-026` |
| 验证 URL | `http://127.0.0.1:8101/T-207-表单设计器-09原型.html?<cache-bust>#pt-026` |
| 根节点 | `data-testid=pt-026-inspector-prototype` |
| Inspector Shell | `data-testid=pt026-inspector-shell` |
| 当前节点 | `pt026-inspector-current-node-field-customer = field_customer` |
| schemaPath | `pt026-inspector-current-schema-path = components.field_customer` |
| fieldPath | `pt026-inspector-current-field-path = salesOrder.customerId` |

## 3. 竞品吸收点

| 参考对象 | 吸收点 | PT-026 落地 |
|---|---|---|
| Visual Studio Properties | 右侧属性窗口、按类别组织、选中对象上下文 | Inspector 固定在右侧，顶部显示当前 node/schemaPath/fieldPath |
| DevExpress Designer | 属性分组、复杂控件属性、运行时修改反馈 | 业务/布局/样式/规则/权限/事件六页签，属性行带 schemaPath |
| 金蝶低代码设计器 | 业务字段绑定与元数据约束 | 字段绑定、BO 必填、字段来源只读展示 |
| Retool / Power Apps | 属性搜索、状态反馈、可折叠侧栏 | 搜索属性并显示 hits；Inspector 支持 collapsed/expanded |

## 4. 不采用点

| 参考对象 | 不采用原因 | 本设计选择 |
|---|---|---|
| 过宽右侧说明面板 | 占用画布空间，不适合复杂 PC 单据设计 | 右侧保持紧凑属性面板，说明通过 tip 进入 |
| 只有静态文本属性 | 不能验证 Schema 修改链路 | 编辑属性必须写入 `pt026-patch-bar` |
| 只做业务属性 | 无法覆盖 Web 布局和权限/事件复杂性 | 六页签覆盖 business/layout/style/rule/permission/event |

## 5. 自动化证据摘要

- 六个 tab：`business/layout/style/rule/permission/event` 均可点击切换。
- 每次仅一个 `role=tabpanel` 可见。
- 标题字段改为 `客户名称` 后：`pt026-patch-bar[data-state=dirty]`，summary 为 `SchemaPatch: title = 客户名称`。
- layout span 点击 `+` 后：属性值 `3`，画布选中字段 `data-layout-span=3`。
- 搜索 `permission` 后：`hits=3`，18 行中 3 行可见、15 行隐藏。
- 点击收起/展开后：root/shell/rail 状态同步为 `collapsed` / `expanded`。
- 控制台 warn/error：0。