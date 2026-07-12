---
id: E-POWERAPPS-RETOOL-DEEP-003
type: evidence
competitors: [Microsoft-Power-Apps, Retool]
module: current-builder-visual-layout-data-debug
source_channel: official-public-web
source_type: first-party-docs-and-product-pages
captured_at: 2026-07-11
valid_until: 2026-10-11
status: active
owner: AI
ai_generated: true
---

# Power Apps 与 Retool 当前设计器深化证据

## 研究边界

本卡只记录 2026-07-11 可访问的官方公开资料。截图是厂商官方文档或当前产品页的本地留存，不等于登录态逐项实测。事实、设计推导和未知项分开记录。

## Microsoft Power Apps Studio

### 已确认事实

- 官方将 Studio 明确拆为现代命令栏、属性列表、公式栏、应用创作菜单、Tree view、画布/屏幕、属性窗格、屏幕选择器与画布尺寸切换等区域。
- 现代命令栏是上下文相关的：选中控件后只显示该控件适用的命令；多选不同类型控件时显示其公共命令。
- 控件可从顶部 Insert 或应用创作菜单插入，支持拖放到画布或直接选择插入。
- Tree view、画布选中对象、属性窗格与公式栏共同表达同一个当前编辑上下文。
- Power Fx 不是隐藏在独立脚本页中的附属功能，而是与可视属性并列的核心编辑面。

### 视觉观察

- 工作台采用稳定多区布局：顶部命令与公式、左侧创作导航/结构、中央画布、右侧属性。区域职责比装饰更重要。
- 上下文命令栏减少持续显示的无关操作，但控件切换会引起命令集合变化；自研产品需要保留稳定的核心命令位置，降低视觉跳动。
- 画布仍是主要空间，但结构、属性和公式同时可见，使复杂应用的定位和调试不必频繁离开页面。
- 官方图像中的具体色值、尺寸和图标会随版本变化，本卡不把像素值写成设计令牌。

### 对企业表单设计器的可吸收原则

1. 画布选中、组件大纲、属性和表达式编辑必须共享统一 selection context。
2. 命令栏采用“稳定全局命令 + 上下文命令”两段式，避免整个工具栏随选中对象重排。
3. 公式或规则编辑应保留当前控件、属性名、数据类型和求值结果，不能只给通用代码框。
4. 插入面板必须同时提供类别、搜索、最近使用和合法落点反馈。

### 本地截图证据

- `assets/screenshots/power-apps/studio-options-official.png`：官方 Studio 区域与命令示意。
- `assets/screenshots/power-apps/studio-command-bar-official.png`：上下文命令栏官方图像。
- `assets/screenshots/power-apps/insert-controls-official.png`：双入口插入控件官方图像。

### 官方来源

- `https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/power-apps-studio`
- 页面元数据最后更新日期：2025-11-28；本地抓取日期：2026-07-11。

## Retool

### 已确认事实

- 当前官方产品页把新 App Builder 描述为提示、可视化编辑和代码的统一环境，并明确其目标是从原型到生产的企业应用。
- 官方公开说明当前 Builder 可在一个面板中查看资源、函数、查询、运行历史和返回数据。
- Retool 明确支持在大量位置编写 SQL 或 JavaScript，并允许编写、调试 React；支持自定义 React 组件及 JavaScript/Python 库。
- 官方称提供 100+ UI 组件，并覆盖 SQL/GraphQL、AWS、数据湖、LLM 与 SaaS 集成。
- 治理能力包括 SSO、角色映射、RBAC、数据级权限、云托管和自托管。
- 当前文档仍把 classic apps 与新 Builder 分开组织，研究时不能把两代编辑器的截图和行为混写成一个版本。

### 视觉观察

- 当前产品叙事从经典“组件画布 + 查询底栏”升级为“提示 + 可视编辑 + 代码 + 可观测性”的统一工作台。
- 产品页视觉使用黑白高对比、粗边框和模块化卡片表达工程工具感；这是营销页面视觉，不能直接等同于编辑器内部主题。
- 信息架构把生成、检查数据、理解执行、优化代码排列为连续工作流，说明调试和可观测性被提升到一等入口，而不是发布后补充能力。
- 对自研产品真正有价值的是稳定的查询/状态/运行历史上下文，不是照搬 Retool 的品牌视觉。

### 对企业表单设计器的可吸收原则

1. 数据查询、规则函数、返回数据、运行历史和依赖关系应在同一调试上下文中互相跳转。
2. AI 生成必须保留结构化元数据和可编辑代码/规则，不能生成不可解释的静态页面。
3. 自定义组件需要明确输入、输出、事件、权限和隔离边界，不能让任意代码绕过平台运行时。
4. 高密度后台页面应把数据状态和操作状态贴近组件呈现，同时避免让查询编辑区永久挤压主画布。

### 本地截图证据

- `assets/screenshots/retool/official-app-builder-page-2026-07-11.png`：当前官方 App Builder 产品页全页抓取。
- `assets/screenshots/retool/official-app-builder-annotated-2026-07-11.png`：带交互元素标注的官方产品页抓取。

### 官方来源

- `https://retool.com/build-enterprise-apps/apps`
- `https://docs.retool.com/apps/guides/layout-structure`
- 抓取日期：2026-07-11。

## 跨产品对照

| 维度 | Power Apps | Retool | 自研结论 |
|---|---|---|---|
| 核心编辑范式 | 画布 + 属性 + Power Fx | 提示 + 可视编辑 + 查询/代码 | 可视模型与表达式/代码双向可追踪 |
| 当前上下文 | 控件 selection 驱动命令、属性和公式 | 资源、函数、查询、历史和返回值关联 | 建立统一调试上下文和可跳转依赖图 |
| 信息密度 | 多区 IDE，画布居中 | 企业后台与工程调试高密度 | 设计器高密度，运行页按任务选择密度 |
| 扩展性 | PCF 与组件模型 | React 组件及 JS/Python 库 | 沙箱化扩展协议 + 权限和版本治理 |
| 响应式 | 容器和公式驱动 | 桌面/移动布局与组件组合 | 共享业务语义，设备布局允许覆盖 |

## 未知项

- 未登录实测 Power Apps 当前租户中的新旧控件差异、深层嵌套选择效率和公式调试完整行为。
- 未登录实测 Retool 新 Builder 的全部面板位置、组件树行为、断点布局和性能边界。
- Retool 产品页截图属于官方营销展示，不能作为编辑器内部像素级还原依据。
- 两款产品均未在同一复杂单据、同一数据规模、同一设备上完成可比任务测试。

