---
id: E-APPIAN-DEVEXPRESS-SCREENSHOT-003
type: evidence
competitors: [Appian-25.2, DevExpress-DevExtreme-26.1]
module: official-screenshot-and-live-demo-evidence
source_channel: official-public-web
source_type: first-party-docs-and-live-demos
captured_at: 2026-07-11
valid_until: 2026-10-11
status: active
owner: AI
ai_generated: true
---

# Appian 与 DevExpress 本地截图深化证据

## 证据边界

Appian 截图来自官方文档，DevExpress 截图来自官方可交互 Demo。截图只证明画面中的可见内容。Appian 文档页不能冒充登录后的 Interface Designer 全景；DevExpress 是运行时组件套件，不是低代码业务建模平台。

## Appian 25.2

![Appian Interface Components](../00-assets/commercial/appian/01-interface-components.png)

- 来源：`https://docs.appian.com/suite/help/25.2/SAIL_Components.html`
- 页面标题：`Interface Components - Appian 25.2`
- 已确认：官方按布局、输入、选择、网格、浏览器、反馈等语义组织组件；Form、Section、Columns、Wizard、Editable Grid、Hierarchy Browser 属于不同任务构件。
- 视觉边界：证明组件目录的信息分类，不证明设计器画布和属性面板的当前像素结构。

![Appian Responsive Design](../00-assets/commercial/appian/03-responsive-design.png)

- 来源：`https://docs.appian.com/suite/help/25.2/responsive_design.html`
- 页面标题：`Responsive Design - Appian 25.2`
- 已确认：官方文档包含桌面/移动示例、声明式界面代码和条件布局说明；响应式行为属于界面定义，而不是截图缩放。

### 无效截图记录

- `00-assets/commercial/appian/02-design-mode.png` 捕获的是 `Page Not Found - Appian 26.6`。
- 旧入口 `https://docs.appian.com/suite/help/25.2/design_mode.html` 已失效，该图片不得用于产品能力或视觉结论。

### 结论边界

- 已确认：Appian 以业务语义组织组件，层级浏览、网格、向导和布局具有不同协议。
- 未知：当前登录态 Interface Designer 的完整分区、深层选择、拖放反馈和属性面板像素细节。

## DevExpress DevExtreme 26.1

![DevExpress TreeList Overview](../00-assets/commercial/devexpress/01-treelist-overview.png)

- 来源：`https://js.devexpress.com/React/Demos/WidgetsGallery/Demo/TreeList/Overview/`
- 页面标题：`React Tree List - Overview | React Example`
- 已确认：TreeList 同时呈现层级缩进、展开控件和二维列，属于 TreeGrid，不是单列树选择器。

![DevExpress TreeList Cell Editing](../00-assets/commercial/devexpress/02-treelist-editing.png)

- 来源：`https://js.devexpress.com/React/Demos/WidgetsGallery/Demo/TreeList/CellEditing/`
- 页面标题：`Cell Editing - React Tree List | React Example`
- 已确认：层级上下文、列、编辑态和校验需要同时存在；TreeGrid 编辑协议不能由 Tree Picker 替代。

![DevExpress TreeList Node Drag and Drop](../00-assets/commercial/devexpress/03-treelist-reordering.png)

- 来源：`https://js.devexpress.com/React/Demos/WidgetsGallery/Demo/TreeList/LocalReordering/`
- 页面标题：`Node Drag & Drop - React Tree List | React Example`
- 已确认：演示提供显式拖拽手柄、同级重排、拖入节点、配置开关和代码；官方说明要求阻止父节点被移动到自身子孙中。
- 视觉事实：拖拽手柄、展开图标和数据列各有稳定槽位，层级动作与行内容没有混成一个点击目标。
- 限制：截图中 cookie 弹窗遮挡局部区域，不用于像素级间距测量。

## 对自研设计器的约束

1. Tree、Tree Picker、Tree Browser 和 TreeGrid 分类型建模，不以一个控件的模式开关替代全部协议。
2. TreeGrid 将展开、焦点、选择、编辑、加载和拖拽拆为独立状态。
3. 拖拽落点至少区分前、内、后，并在客户端预检循环、类型和权限，在服务端再次校验。
4. 官方 Demo 画面证明可见交互，代码和文档证明配置及边界；两类证据不可互相替代。

