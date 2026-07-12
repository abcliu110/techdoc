# 低代码平台 V2 设计器实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 生成一套证据可追踪、可独立运行、可浏览器验证的企业级低代码设计器原型及其完整方法产物。

**Architecture:** 采用独立静态 Web 原型，不修改现有低代码平台生产代码。状态逻辑放在纯 JavaScript 状态模块中，界面由语义化 HTML、CSS 与无依赖交互脚本组成；方法产物按 `prototype-method` 目录保存，浏览器证据和评审报告保存在 `reports`。

**Tech Stack:** HTML5、CSS、ES Modules、Node.js 内置测试、agent-browser。

---

### Task 1: 冻结阶段 0-2 输入

**Files:**
- Create: `README.md`
- Create: `prototype-method/run.yaml`
- Create: `prototype-method/charter.yaml`
- Create: `prototype-method/sources/index.yaml`
- Create: `prototype-method/evidence/evidence.yaml`
- Create: `prototype-method/tasks/tasks.yaml`
- Create: `prototype-method/capabilities/capabilities.yaml`

- [ ] 记录六个重点竞品的官方来源、访问结果和证据新鲜度。
- [ ] 将 Appian 的 406/403 记录为失败证据，不推断具体能力。
- [ ] 冻结核心用户任务、范围、非目标和限制条件。
- [ ] 将阶段 0-2 标为通过，后续阶段保持未开始。

### Task 2: 冻结阶段 3-5 设计输入

**Files:**
- Create: `prototype-method/advantages/advantages.yaml`
- Create: `prototype-method/benchmarks/benchmarks.yaml`
- Create: `prototype-method/requirements/requirements.yaml`
- Create: `prototype-method/decisions/decisions.yaml`
- Create: `prototype-method/traceability/traceability.yaml`
- Create: `design/product-design.md`
- Create: `design/information-architecture.md`
- Create: `design/flows.yaml`
- Create: `design/state-models.yaml`
- Create: `design/visual-contract.yaml`
- Create: `design/tokens.json`

- [ ] 将金蝶云·苍穹冻结为主标杆，其他五家冻结为重点对标。
- [ ] 定义销售订单从业务对象到发布准备的完整任务。
- [ ] 冻结五区工作台、对象优先、规则权限一体化和发布分析器决策。
- [ ] 冻结桌面视口、面板尺寸、文本压力和交互状态合同。

### Task 3: 先写状态行为测试

**Files:**
- Create: `tests/designer-state.test.mjs`
- Create: `tests/prototype-contract.test.mjs`
- Test: `node --test tests/*.test.mjs`

- [ ] 写导航切换状态测试并确认因模块缺失失败。
- [ ] 写字段选中同步测试并确认因模块缺失失败。
- [ ] 写发布阻断测试并确认因模块缺失失败。
- [ ] 写静态原型合同测试并确认因原型文件缺失失败。

### Task 4: 实现状态模型和设计器界面

**Files:**
- Create: `prototype/designer-state.mjs`
- Create: `prototype/index.html`
- Create: `prototype/styles.css`
- Create: `prototype/app.js`

- [ ] 实现纯状态模块，使状态测试通过。
- [ ] 实现顶部命令栏、模块导航、资源面板、设计画布、属性面板和底部分析器。
- [ ] 实现业务对象、页面设计、规则、权限、预览和发布准备视图。
- [ ] 实现字段选择、面板切换、属性修改、角色模拟、规则启停、预览和发布校验交互。

### Task 5: 浏览器门禁和交付

**Files:**
- Create: `reports/mechanical-report.md`
- Create: `reports/interaction-report.md`
- Create: `reports/competitive-assessment.md`
- Create: `reports/reviews/final-review.md`
- Create: `reports/screenshots/*.png`

- [ ] 运行 Node 测试并要求零失败。
- [ ] 启动本地静态服务器并检查控制台错误。
- [ ] 在 1440x900、1920x1080、1280x800 截图并检查溢出、遮挡和裁切。
- [ ] 执行字段选中、规则切换、角色模拟、预览和发布阻断主交互。
- [ ] 更新追踪矩阵和运行清单，按真实证据派生最终状态。

