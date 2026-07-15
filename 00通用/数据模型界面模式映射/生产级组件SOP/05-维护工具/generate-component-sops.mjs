import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const sopRoot = resolve(scriptDir, "..");
const suiteRoot = resolve(sopRoot, "..");
const repositoryRoot = resolve(suiteRoot, "..", "..");
const catalogPath = join(suiteRoot, "prototype-suite", "catalog.browser.json");
const governanceSource = join(repositoryRoot, "docs", "superpowers", "specs", "2026-07-15-react-component-production-sop-design.md");
const catalog = JSON.parse(readFileSync(catalogPath, "utf8"));
const governanceContent = readFileSync(governanceSource, "utf8");

const categoryProfiles = {
  "01": {
    focus: "空间、阅读顺序与工作上下文",
    stateModel: "容器尺寸、断点、区域可见性、活动区域、用户布局偏好",
    failures: ["窄屏或缩放后关键操作不可达", "折叠、停靠或切换时未保存上下文丢失", "视觉顺序与 DOM 阅读顺序不一致"],
    performance: "在 1440x900、1024x768、390x844 及相邻断点执行布局切换；可见反馈 p95 不高于 100ms，组件自身不得产生持续超过 50ms 的长任务。",
    tests: ["验证所有断点的内容可达、滚动可达与操作目标尺寸", "验证 DOM 阅读顺序、Tab 顺序和视觉顺序一致", "验证折叠、切换、恢复后上下文与焦点不丢失"],
    upgrade: "若持久化个人布局、跨窗口同步、承载未保存业务编辑或影响权限可见性，至少升级为 R2。",
  },
  "02": {
    focus: "数据身份、版本、选择、编辑与汇总口径",
    stateModel: "查询条件、加载窗口、行主键、选择集、编辑草稿、版本、排序与汇总",
    failures: ["加载失败、空结果或分页游标失效", "排序过滤后选择集错位或行身份漂移", "并发版本冲突、部分提交或批量操作重复执行"],
    performance: "普通表格以 1,000 行基准，虚拟/无限/服务端表格以 100,000 行逻辑数据和当前可视窗口基准；滚动、选择和编辑反馈 p95 不高于 100ms。",
    tests: ["以稳定业务主键验证排序、过滤、分页和虚拟窗口后的行身份", "验证批量选择、部分成功、重复提交和版本冲突", "验证网格键盘导航、编辑模式、焦点保持和屏幕阅读语义"],
    upgrade: "若提交金额、库存、订单、权限或不可逆批量操作，升级为 R3。",
  },
  "03": {
    focus: "层级路径、父子关系、继承范围与循环约束",
    stateModel: "展开集、选中节点、焦点节点、加载状态、父子路径、继承与拖拽目标",
    failures: ["懒加载失败或目标父节点不可访问", "移动后形成自身或间接循环", "过滤、虚拟化或重载后焦点和路径丢失"],
    performance: "以 10,000 节点、10 层深度和 200 个展开节点为基准；展开、定位和键盘移动的可见反馈 p95 不高于 100ms。",
    tests: ["验证 aria tree 模式、方向键、Home/End、展开和焦点语义", "验证循环、无权父节点、懒加载失败与撤销", "验证过滤、移动和重载前后的稳定节点身份与路径"],
    upgrade: "若树结构直接修改组织、菜单权限、资源继承或生产依赖，至少 R2；越权或跨租户影响时为 R3。",
  },
  "04": {
    focus: "字段值、校验、草稿、提交与版本冲突",
    stateModel: "初始值、当前值、脏字段、校验结果、提交状态、草稿版本与服务端版本",
    failures: ["同步或异步校验失败且定位不准确", "提交失败、离开页面或切换步骤造成草稿丢失", "服务端版本变化导致静默覆盖"],
    performance: "包含 200 字段、20 个条件字段和 10 个异步校验的基准场景；单字段输入反馈 p95 不高于 100ms，非当前字段不得触发无界重渲染。",
    tests: ["验证标签、说明、错误关联、首错定位和读屏播报", "验证脏数据保护、草稿恢复、异步乱序与版本冲突", "验证提交中重复触发、取消、服务失败和服务端错误映射"],
    upgrade: "若提交签名、审批、金额、订单、权限或法律效力数据，升级为 R3。",
  },
  "05": {
    focus: "条件语义、逻辑组合、数据范围与结果可解释性",
    stateModel: "条件树、操作符、值、逻辑组、保存版本、执行状态与结果摘要",
    failures: ["无效操作符、空条件或类型不匹配", "条件组合扩大数据范围或保存视图版本冲突", "超时、结果为空或查询解释与实际执行不一致"],
    performance: "以 100 个条件、10 层嵌套和 100 个候选字段为设计基准；条件编辑反馈 p95 不高于 100ms，执行必须可取消。",
    tests: ["验证条件树序列化、反序列化和逻辑优先级不变", "验证空值、范围、时区、非法操作符和服务端拒绝", "验证键盘重排、错误定位、保存版本和清除/撤销"],
    upgrade: "若查询可绕过权限范围、执行原生 DSL/SQL、保存共享策略或导出敏感数据，升级为 R3。",
  },
  "06": {
    focus: "候选身份、选择约束、远程加载与结果回填",
    stateModel: "查询、候选集、选中集、顺序、加载游标、已失效项与确认状态",
    failures: ["远程加载失败、结果过期或已选项失效", "多选上限、级联约束或互斥规则冲突", "关闭弹层后焦点、查询或临时选择丢失"],
    performance: "以 10,000 个远程候选、200 个已选项为逻辑基准；输入反馈 p95 不高于 100ms，搜索请求必须防抖、可取消并防乱序。",
    tests: ["验证稳定候选 ID，不以显示文本作为业务身份", "验证请求乱序、失效项、分页去重、上限和取消", "验证组合框/列表框/树选择器语义、键盘选择与焦点返回"],
    upgrade: "若选择结果直接授予角色、资源权限、主数据关系或不可逆业务对象，至少 R2；跨租户或权限授予为 R3。",
  },
  "07": {
    focus: "文档模型、撤销历史、校验、版本和安全输出",
    stateModel: "文档值、选择区、撤销栈、脏状态、校验、预览、版本与协作修订",
    failures: ["解析或校验失败无法定位", "切换格式、预览或关闭时未保存内容丢失", "协作冲突、危险内容或不受信执行"],
    performance: "以 1 MB 文档或 10,000 个结构节点为复杂编辑基准；键入反馈 p95 不高于 100ms，解析和预览长任务必须可取消或移出主线程。",
    tests: ["验证输入、序列化、反序列化和撤销/重做保持语义", "验证解析失败、冲突合并、版本恢复和草稿保留", "验证不受信 HTML、模板、SQL、脚本或 URL 不被组件执行"],
    upgrade: "若内容可执行、可发布、可修改生产 Schema/SQL/规则或包含敏感协作数据，升级为 R3。",
  },
  "08": {
    focus: "设计态模型、运行态预览、版本、依赖与发布",
    stateModel: "设计树、选中节点、属性、撤销栈、校验、预览版本、发布版本与依赖",
    failures: ["设计模型无效、依赖缺失或循环引用", "预览与运行时语义不一致", "发布冲突、部分发布或回滚版本不可用"],
    performance: "以 500 个设计节点、50 层嵌套和 100 次撤销记录为基准；选中、移动和属性修改反馈 p95 不高于 100ms。",
    tests: ["验证设计模型版本化、迁移、撤销/重做和循环约束", "验证预览只读隔离、危险动作不真实执行", "验证发布前校验、版本差异、并发发布与可执行回滚"],
    upgrade: "数据源凭证、事件/动作执行、代码组件、Schema 或生产发布能力为 R3。",
  },
  "09": {
    focus: "图节点身份、连线语义、执行顺序、合法状态与发布版本",
    stateModel: "节点、边、端口、选择、视口、校验、模拟结果、执行版本与发布状态",
    failures: ["非法连线、循环或不可达节点", "并发编辑导致节点/边丢失或引用悬空", "模拟与生产执行不一致、发布失败或无法补偿"],
    performance: "以 1,000 节点、2,000 条边为图编辑基准；平移缩放与选择保持可操作，节点操作反馈 p95 不高于 100ms。",
    tests: ["验证稳定节点/边 ID、连线约束、循环和拓扑规则", "验证键盘创建、选择、移动、连接及非画布等价编辑入口", "验证模拟、发布版本、并发冲突、执行失败和补偿路径"],
    upgrade: "可驱动审批、状态、规则、作业、流水线或生产执行的编辑器为 R3；纯说明图可为 R1/R2。",
  },
  "15": {
    focus: "路由身份、工作区上下文、未保存状态与返回路径",
    stateModel: "当前位置、历史栈、活动工作区、打开项、脏状态、权限可见性与恢复位置",
    failures: ["目标失效或无权访问", "跳转造成未保存工作丢失", "历史返回、深链接或多工作区上下文错误"],
    performance: "以 500 个可发现入口和 20 个已打开工作项为基准；搜索、切换和返回反馈 p95 不高于 100ms。",
    tests: ["验证深链接、前进后退、刷新和权限变化后的路由一致性", "验证未保存拦截、关闭恢复和焦点返回", "验证菜单、标签、命令面板和搜索的键盘语义"],
    upgrade: "若持久化工作区、执行命令、暴露权限入口或跨窗口同步状态，至少 R2。",
  },
  "16": {
    focus: "租户、主体、资源、动作、数据范围、显式拒绝与审计",
    stateModel: "租户、主体、角色、策略版本、资源范围、允许/拒绝、继承、审批和审计记录",
    failures: ["跨租户或超组织范围操作", "策略冲突、继承误判或显式拒绝失效", "凭证泄露、审计缺失或并发覆盖策略"],
    performance: "以 1,000 个主体、10,000 个资源和 500 条策略为设计基准；预览必须清晰显示数据范围，性能优化不得跳过服务端裁决。",
    tests: ["验证租户、组织、资源、动作和字段范围全部进入请求契约", "验证显式拒绝、继承、冲突、版本、审批与审计", "验证前端隐藏/禁用不被当作授权，服务端拒绝可解释且不泄密"],
    upgrade: "本类别统一按 R3 起步，不得降级；审计只读查看器仍涉及敏感数据范围。",
  },
  "17": {
    focus: "消息身份、对象版本、离线队列、冲突、通知范围与审计",
    stateModel: "连接、会话、消息/批注 ID、发送状态、对象版本、离线队列、冲突与已读状态",
    failures: ["网络中断、重复发送或乱序到达", "对象版本冲突、草稿丢失或合并错误", "通知无权接收者、敏感内容泄露或审计链不完整"],
    performance: "以 10,000 条消息、100 个并发协作者和 1,000 个离线待重放动作的逻辑基准；输入反馈 p95 不高于 100ms。",
    tests: ["验证客户端生成稳定幂等 ID、乱序、重复和离线重放", "验证版本冲突、草稿恢复、权限变化和合并结果", "验证实时区域播报、焦点不被远端更新抢夺及敏感内容不泄露"],
    upgrade: "涉及凭证、安全审计、不可抵赖记录或跨租户协作时为 R3；其他协作默认至少 R2。",
  },
  "18": {
    focus: "跨对象业务不变量、职责边界、事件时间线与补偿",
    stateModel: "核心对象、关联对象、规则快照、审批、提交、下游状态、审计与补偿状态",
    failures: ["关联对象版本变化或跨模块规则冲突", "部分提交、重复提交或下游超时", "权限、金额、库存、排期、SLA 或审计不一致"],
    performance: "按组件契约登记真实数据规模和下游延迟；本地反馈 p95 不高于 100ms，长事务必须显示阶段、允许安全取消或进入可恢复后台状态。",
    tests: ["验证至少三个业务对象和双职责边界", "验证重复、并发、部分成功、下游失败与补偿", "验证金额/库存/排期/权限/SLA 影响和完整事件时间线"],
    upgrade: "命中权限、多租户、金额、库存、订单、支付、医疗隐私、安全告警或不可逆动作即 R3；其余跨系统流程至少 R2。",
  },
};

const riskSets = {
  R3: new Set([
    "04:signature-form", "04:approval-form",
    "07:sql-editor", "07:schema-editor",
    "08:data-source-designer", "08:event-designer", "08:action-designer", "08:component-builder", "08:schema-editor", "08:publish-console",
    "09:workflow-designer", "09:bpmn-designer", "09:approval-flow", "09:state-machine", "09:rule-designer", "09:decision-table", "09:decision-tree", "09:pipeline-designer", "09:job-orchestrator",
    "16:permission-matrix", "16:role-permission", "16:menu-permission-tree", "16:data-permission", "16:field-permission", "16:row-policy", "16:org-editor", "16:user-role", "16:department-user", "16:resource-grant", "16:permission-inheritance", "16:permission-conflict", "16:approver-picker", "16:conditional-grant", "16:tenant-config", "16:data-scope", "16:policy-editor", "16:acl-editor", "16:credential-manager", "16:audit-viewer",
    "17:audit-trail",
    "18:sku-editor", "18:checkout", "18:stock-allocation", "18:warehouse-map", "18:price-rule", "18:promotion-rule", "18:contract-editor", "18:invoice-editor", "18:voucher-entry", "18:account-tree", "18:payroll-sheet", "18:medical-record", "18:bom-editor", "18:device-monitor", "18:alarm-rule",
  ]),
  R2: new Set([
    "01:configurable-page", "01:multi-window", "01:saved-workspace",
    "03:draggable-tree", "03:editable-tree", "03:file-tree", "03:org-tree", "03:menu-tree", "03:permission-tree", "03:dependency-tree",
    "05:saved-query", "05:saved-view", "05:query-template", "05:query-dsl", "05:query-history",
    "06:person-selector", "06:organization-selector", "06:department-selector", "06:role-selector", "06:resource-selector", "06:relation-selector", "06:master-data-selector", "06:file-selector", "06:composite-selector",
    "15:permission-menu", "15:tab-workspace", "15:command-palette", "15:configurable-toolbar", "15:shortcut-manager", "15:workspace-switcher",
  ]),
};

function provisionalRisk(component) {
  if (riskSets.R3.has(component.key) || component.key.startsWith("16:")) {
    return { level: "R3", basis: "组件契约命中权限、关键业务数据、可执行发布或不可逆影响，按最高后果定级。" };
  }
  if (riskSets.R2.has(component.key) || ["02", "04", "07", "08", "17", "18"].includes(component.key.slice(0, 2))) {
    return { level: "R2", basis: "组件包含持久化、复杂草稿、异步数据、协作冲突或可补偿的业务状态影响。" };
  }
  if (component.key.startsWith("09:")) {
    return { level: "R2", basis: "图形编排至少涉及结构化模型和版本；只有明确接入生产执行时才升级 R3。" };
  }
  return { level: "R1", basis: "当前原型事实只证明局部、可逆交互；若实施接入持久化或敏感业务，必须按升级触发条件重新定级。" };
}

function ensureDir(path) {
  mkdirSync(path, { recursive: true });
}

function write(path, content) {
  ensureDir(dirname(path));
  writeFileSync(path, content.replace(/\r?\n/g, "\n"), "utf8");
}

function json(value) {
  return JSON.stringify(value, null, 2);
}

function q(value) {
  return String(value).replaceAll("|", "\\|").replaceAll("\n", " ");
}

function list(items) {
  return items.map((item) => `- ${item}`).join("\n");
}

function categoryFolder(category) {
  return `${category.number}-${category.name}`;
}

function componentSopPath(category, component) {
  return join("02-组件SOP", categoryFolder(category), `${category.number}-${component.id}.md`).replaceAll("\\", "/");
}

function componentMetadata(category, component, risk) {
  return {
    schemaVersion: 1,
    componentKey: component.key,
    legacyId: component.id,
    category: category.number,
    prototypeComplexity: component.contract.business.level,
    provisionalRisk: risk.level,
    lifecycle: "Draft",
    certification: "not-certified",
    source: "prototype-suite/catalog.browser.json",
  };
}

function componentSpecificAssertions(component) {
  const b = component.contract.business;
  const r = component.contract.readiness;
  return [
    `主路径必须实际完成“${b.task}”，不能只改变状态文案或调用统一壳层动作。`,
    `不变量断言：${component.invariant}`,
    `异常断言：真实触发“${b.exception}”，并验证业务动作被正确阻断。`,
    `恢复断言：执行“${r.recovery}”后，输入、对象身份、焦点和可继续操作性符合契约。`,
    `结果断言：主体区域明确呈现“${b.effect}”，并能关联到 ${b.objects.join("、")}。`,
    `边界断言：${component.boundary}`,
    `键盘断言：${r.keyboard}`,
  ];
}

function primaryFlow(component) {
  const b = component.contract.business;
  return [
    `载入并核对 ${b.objects.join("、")} 的身份、版本和当前状态；此动作属于组件业务前置，不得用统一“开始”按钮代替。`,
    `通过组件自身控件完成核心操作：${component.hint || component.summary}`,
    `按“${b.rule}”校验；校验通过后才产生“${b.effect}”。`,
  ];
}

function renderComponentSop(category, component) {
  const profile = categoryProfiles[category.number];
  const risk = provisionalRisk(component);
  const b = component.contract.business;
  const r = component.contract.readiness;
  const metadata = componentMetadata(category, component, risk);
  const categoryLink = `../../01-类别SOP/${category.number}-${category.name}SOP.md`;
  const governanceLink = "../../00-治理总纲/组件SOP治理与认证规则.md";
  const evidencePath = `quality/evidence/${component.key.replace(":", "-")}/<component-version>/`;
  const responsibilities = b.responsibilities?.length ? list(b.responsibilities) : `- ${b.role}：完成当前任务并核验结果。`;
  const timeline = b.timeline?.length ? list(b.timeline) : list(primaryFlow(component));
  const compensation = b.compensation || r.recovery;

  return `<!-- component-sop-metadata
${json(metadata)}
-->

# ${component.name}生产级组件 SOP

> 组件键：\`${component.key}\`
>
> 原型复杂度：${b.level}
>
> 暂定生产风险：${risk.level}
>
> 生命周期：\`Draft\`
>
> 认证状态：\`not-certified\`

继承：[组件 SOP 治理与认证规则](${governanceLink})、[${category.name}类别 SOP](${categoryLink})。

> 现有 HTML 仅是需求与特征化基线，不是生产认证证据。当前原型的统一壳层动作、异常按钮和历史 PASS 报告不得替代本组件自己的 RED、真实异常、恢复和发布证据。

## 1. 身份与认证状态

| 字段 | 值 |
|---|---|
| 旧组件 ID | \`${component.id}\` |
| 中文名 / 英文名 | ${q(component.name)} / ${q(component.en)} |
| 类别 / 分组 | ${category.number} ${category.name} / ${q(component.group || "业务复合")} |
| 原型来源 | \`prototype-suite/catalog.browser.json#${component.key}\` |
| React 导出名 / 包路径 | Gate 2 冻结；当前不得推断 |
| Owner / 备份 Owner | Gate 1 指派；未指派前不得进入 Alpha |
| 生命周期 / 认证 | Draft / 未认证 |

## 2. 原型直接事实

### 2.1 定义与模型

- 摘要：${component.summary}
- 模型：\`${component.model}\`
- 原型状态：\`${component.state}\`
- 不变量：${component.invariant}
- 适用边界：${component.boundary}

### 2.2 业务上下文

- 角色：${b.role}
- 任务：${b.task}
- 对象：${b.objects.join("；")}
- 规则：${b.rule}
- 原型异常：${b.exception}
- 预期影响：${b.effect}

职责：

${responsibilities}

事件/操作时间线：

${timeline}

## 3. 生产风险基线

- 暂定等级：**${risk.level}**。
- 判定依据：${risk.basis}
- 类别升级条件：${profile.upgrade}
- 最高后果复核：Gate 1 必须检查权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作和跨系统一致性；命中任一 R3 条件即升级，禁止降级绕过门禁。
- 冻结规则：最终等级、理由和批准人写入契约卡与机器索引后，才能进入 Gate 2。

## 4. 生产交互契约

### 4.1 核心状态

类别状态模型：${profile.stateModel}

本组件至少覆盖：

- 初始：对象身份、权限、版本和当前 ${component.state} 可解释。
- 编辑/操作中：每个用户动作产生可观察但未误报成功的状态。
- 校验/提交中：防重复触发，可取消的操作提供取消能力。
- 成功：结果关联原业务对象并说明下游影响。
- 异常：真实触发组件自身失败，不调用统一壳层伪造。
- 已恢复：${r.recovery}
- 只读、禁用、无权限、数据过期和冲突：适用性在 Gate 2 逐项冻结，不适用项必须说明理由。

### 4.2 主路径

${primaryFlow(component).map((step, index) => `${index + 1}. ${step}`).join("\n")}

### 4.3 异常与恢复路径

1. 使用可重复夹具真实触发：${b.exception}
2. 组件显示原因、影响对象和可执行恢复动作；不得清空未提交输入或把失败写成成功。
3. 执行恢复：${r.recovery}
4. 恢复后验证焦点、对象版本、草稿和重复副作用；补偿语义为：${compensation}

### 4.4 键盘与辅助技术

- 原型要求：${r.keyboard}
- React 契约必须在 Gate 2 细化每个键、焦点入口、焦点返回和读屏播报文本。
- 主路径、异常路径和恢复路径均须只用键盘完成；远端状态更新不得抢夺用户焦点。

## 5. 组件专属验证

### 5.1 必须断言

${list(componentSpecificAssertions(component))}

### 5.2 类别附加测试

${list(profile.tests)}

### 5.3 失败模式

${list(profile.failures)}

### 5.4 性能基线

${profile.performance}

Gate 2 必须记录设备档位、数据规模、运行次数、p95 口径和公共子路径 gzip 增量预算；未登记预算不得进入 PR Gate。

### 5.5 旧原型特征化

- 旧观察点：\`${component.contract.observe}\`
- 旧变化指纹：\`${component.contract.changed}\`
- 旧重置指纹：\`${component.contract.reset}\`
- 使用规则：这些值只锁定旧原型行为。React 测试必须转为用户可见结果、公开事件和业务对象断言，不能继续把状态字符串变化作为唯一通过条件。

## 6. 七道 Gate 执行卡

| Gate | 本组件必须产出 | 当前状态 |
|---|---|---|
| G1 登记定级 | 最终 R 等级、最高后果、Owner、备份 Owner、目标批次 | 未开始 |
| G2 契约冻结 | React API、状态机、键盘/焦点、错误、主题、i18n、性能预算 | 未开始 |
| G3 RED | 主路径、真实异常、恢复、不变量的最小失败测试与原始输出 | 未开始 |
| G4 GREEN | 满足冻结契约的最小实现及受影响回归 | 未开始 |
| G5 风险加固 | ${risk.level} 门禁、类别测试、失败注入、性能、A11y、视觉与安全边界 | 未开始 |
| G6 规范迁移 | 真实 Story、状态矩阵、旧 ID 差异、限制和迁移示例 | 未开始 |
| G7 候选发布 | 不可变产物、隔离安装、兼容报告、签署和回滚 | 未开始 |

任何 Gate 只有证据路径和批准记录写入机器索引后才能标记完成。代码完成或 Story 可点击不等于组件完成。

## 7. 证据包与发布条件

证据目录：\`${evidencePath}\`

必须包含：

- \`manifest.json\`：组件键、契约版本、源码修订、产物版本、完整性和 SOP 版本。
- \`test-results/\`：RED 原始失败、GREEN、回归、浏览器和失败注入结果。
- \`accessibility/\`：自动扫描，以及主/异常/恢复路径的键盘和读屏人工记录。
- \`visual/\`：桌面、移动、相邻断点、默认/暗色/密度和关键状态矩阵。
- \`performance/\`：登记场景的原始测量与 p95 结果。
- \`package/\`：ESM、类型、CSS、SSR、子路径、Tree Shaking 和隔离安装结果。
- \`approvals.json\`：与最终风险等级匹配的独立批准。
- \`rollback.md\`：撤回、降级、消费方通知和数据/草稿兼容说明。

晋级条件：所有 Gate 通过、零绝对红线、候选产物与证据绑定；R2 还需代表性消费项目完整验收，R3 还需受控灰度和回滚演练。

## 8. 未冻结实施决策

以下不是占位符，而是尚未进入实施批次的显式决策队列；不得擅自填写：

1. React 导出名、包子路径和组合 API。
2. Owner、备份 Owner、评审人和支持期限。
3. 最终生产风险等级及领域/安全批准人。
4. 受控/非受控边界、事件载荷和错误类型。
5. 精确浏览器/读屏支持矩阵。
6. 具体依赖及其许可证、安全和维护审查。
7. 性能设备档位、最终数据规模和 gzip 增量预算。
8. 目标版本、预发布消费方、灰度和回滚责任人。

这些决策必须分别在 Gate 1、Gate 2 或发布候选阶段冻结；冻结后修改会使受影响认证失效。
`;
}

function renderCategorySop(category) {
  const profile = categoryProfiles[category.number];
  const risks = category.components.reduce((counts, component) => {
    const risk = provisionalRisk(component).level;
    counts[risk] = (counts[risk] || 0) + 1;
    return counts;
  }, {});
  const components = category.components.map((component) => {
    const risk = provisionalRisk(component).level;
    const path = `../02-组件SOP/${categoryFolder(category)}/${category.number}-${component.id}.md`;
    return `| [${component.name}](${path}) | \`${component.key}\` | ${component.contract.business.level} | ${risk} | Draft / 未认证 |`;
  }).join("\n");
  return `# ${category.number} ${category.name}生产级组件类别 SOP

> 组件数：${category.components.length}
>
> 关注域：${profile.focus}
>
> 风险初始分布：R1 ${risks.R1 || 0} / R2 ${risks.R2 || 0} / R3 ${risks.R3 || 0}

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：${profile.focus}。
- 类别状态模型：${profile.stateModel}。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

${list(profile.failures)}

## 3. 强制验证

${list(profile.tests)}

## 4. 性能与规模基线

${profile.performance}

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

${profile.upgrade}

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
${components}
`;
}

function renderReadme(indexEntries) {
  const counts = Object.fromEntries(catalog.map((category) => [category.number, category.components.length]));
  const risks = indexEntries.reduce((acc, entry) => {
    acc[entry.provisionalRisk] = (acc[entry.provisionalRisk] || 0) + 1;
    return acc;
  }, {});
  return `# 生产级组件 SOP

本目录集中管理现有 309 项复杂 UI 规范迁移为 React + TypeScript 生产组件时使用的治理规则、类别门禁、单组件 SOP 和机器索引。

## 当前事实

- 范围：13 类、309 个组件，类别为 01-09、15-18。
- 原型复杂度：B 级 279 个，C 级 30 个。
- 单组件 SOP：309 份。
- 认证状态：全部为 \`Draft / not-certified\`。
- 暂定风险：R1 ${risks.R1 || 0}、R2 ${risks.R2 || 0}、R3 ${risks.R3 || 0}；最终风险在 Gate 1 冻结。
- 原型基线存在已复现缺口：统一壳层动作被计入主路径，且 \`middle-renderers.test.mjs\` 当前失败。因此旧 PASS 报告不能作为生产认证证据。

## 目录

\`\`\`text
生产级组件SOP/
├─ README.md
├─ 00-治理总纲/
├─ 01-类别SOP/              # 13 份
├─ 02-组件SOP/              # 309 份，按 13 类分目录
├─ 03-机器索引/
├─ 04-模板与证据规范/
└─ 05-维护工具/
\`\`\`

实际运行证据不存放在本目录，仍按版本进入：

\`quality/evidence/<component-id>/<component-version>/\`

## 使用顺序

1. 阅读[治理与认证规则](00-治理总纲/组件SOP治理与认证规则.md)。
2. 从[机器索引](03-机器索引/component-sops.json)定位组件 SOP。
3. Gate 1 冻结最终风险和责任人，Gate 2 冻结 React 公开契约。
4. 严格执行 RED、GREEN、风险加固、规范迁移和候选发布。
5. 证据写入版本化证据包，再更新索引状态。

## 完整性验证

\`\`\`powershell
node .\\生产级组件SOP\\05-维护工具\\verify-component-sops.mjs
\`\`\`

生成器只用于从结构化 catalog 重建文档。修改模板或风险规则后，应先更新校验器，再运行生成器：

\`\`\`powershell
node .\\生产级组件SOP\\05-维护工具\\generate-component-sops.mjs
node .\\生产级组件SOP\\05-维护工具\\verify-component-sops.mjs
\`\`\`

类别计数：\`${JSON.stringify(counts)}\`。
`;
}

function renderGovernance() {
  return `# 组件 SOP 治理与认证规则

本目录执行的完整治理标准来自仓库设计记录：

- [React 企业级组件库生产交付与认证 SOP](../../../../docs/superpowers/specs/2026-07-15-react-component-production-sop-design.md)
- [专用目录内的权威副本](React企业级组件库生产交付与认证SOP.md)

本文件定义 309 份单组件 SOP 的额外治理要求。

## 1. 三级体系

1. 全库总纲：统一底线、B/C + R1/R2/R3、七道 Gate、四级机器门禁、版本与撤回。
2. 类别 SOP：13 类各自的状态模型、失败模式、性能规模和风险升级规则。
3. 单组件 SOP：309 个组件各自的事实、不变量、主/异常/恢复路径、暂定风险、验证与证据条件。

下层只能增加要求，不能降低上层底线。

## 2. 事实与决策分离

- 直接事实来自 \`prototype-suite/catalog.browser.json\`，包括组件身份、定义、模型、不变量、边界和现有业务契约。
- React 导出名、包路径、Owner、最终风险、依赖和性能预算属于未来实施决策，必须在对应 Gate 冻结。
- 生成器可以给出暂定风险和升级触发条件，但不得把暂定值写成最终批准。

## 3. 认证状态

全部组件初始为 \`Draft / not-certified\`。只有七道 Gate、风险附加门禁、证据包和生命周期晋级全部完成，才能标记为 \`Stable / certified\`。

现有 HTML 原型只作为需求与特征化基线。统一壳层动作、模拟异常和旧交付报告不得作为 React 组件生产认证证据。

## 4. 变更规则

- 修改 catalog 后必须重新生成并验证 309 对 309 映射。
- 修改单组件事实应先修改事实来源；实施阶段新增决策写入契约卡和机器索引，不反写为原型事实。
- 不允许手工复制一份 SOP 形成重复组件键。
- 不允许用空模板、TBD 或 TODO 宣称组件 SOP 已完成。
- 候选产物变化会使受影响认证失效。

## 5. 当前基线缺口

已复现：\`node prototype-suite/categories/middle-renderers.test.mjs\` 因首个主路径选择器为 \`[data-readiness-start]\` 而失败。旧原型的两步主路径实际上包含统一载入上下文动作，异常与恢复也主要由壳层模拟。

处理原则：保留旧原型不作隐式重写；每个 React 组件在 Gate 3 建立自己的 RED，用组件真实动作、真实失败和恢复替代壳层模拟。
`;
}

function renderTemplate() {
  return `# 单组件 SOP 模板说明

309 份文档由 \`generate-component-sops.mjs\` 从结构化 catalog 生成。每份必须包含以下八节：

1. 身份与认证状态。
2. 原型直接事实。
3. 生产风险基线。
4. 生产交互契约。
5. 组件专属验证。
6. 七道 Gate 执行卡。
7. 证据包与发布条件。
8. 未冻结实施决策。

每份顶部必须有 \`component-sop-metadata\` JSON 注释块，供零依赖校验器读取。

禁止：

- 把未来 React API、Owner 或最终风险伪装成已确认事实。
- 只替换组件名称而复用空泛测试文字。
- 把旧状态字符串变化作为唯一断言。
- 把统一异常按钮当成组件真实异常。
- 使用 TBD、TODO、FIXME 或“后续补充”。
`;
}

function renderEvidenceSpec() {
  return `# 单组件证据规范

实际证据使用 \`quality/evidence/<component-id>/<component-version>/\`，不与 SOP 文档混放。

## 必需结构

\`\`\`text
manifest.json
contract.json
test-results/
accessibility/
visual/
performance/
package/
approvals.json
rollback.md
\`\`\`

## 硬规则

- 证据绑定源码修订、候选产物版本和完整性。
- RED 原始失败不能被 GREEN 覆盖或删除。
- 截图不能替代原始测试输出。
- 人工键盘/读屏记录必须包含执行人、环境、步骤和结论。
- R2 记录代表性消费项目完整验收；R3 记录受控灰度和回滚演练。
- 修改候选产物后重新执行受影响认证。
`;
}

const indexEntries = [];
for (const category of catalog) {
  write(join(sopRoot, "01-类别SOP", `${category.number}-${category.name}SOP.md`), renderCategorySop(category));
  for (const component of category.components) {
    const risk = provisionalRisk(component);
    const sopPath = componentSopPath(category, component);
    write(join(sopRoot, ...sopPath.split("/")), renderComponentSop(category, component));
    indexEntries.push({
      componentKey: component.key,
      legacyId: component.id,
      name: component.name,
      englishName: component.en,
      category: category.number,
      categoryName: category.name,
      prototypeComplexity: component.contract.business.level,
      provisionalRisk: risk.level,
      riskBasis: risk.basis,
      lifecycle: "Draft",
      certification: "not-certified",
      sopPath,
      source: `prototype-suite/catalog.browser.json#${component.key}`,
      evidenceRoot: `quality/evidence/${component.key.replace(":", "-")}/<component-version>/`,
      frozenDecisions: [],
    });
  }
}

const index = {
  schemaVersion: 1,
  generatedFrom: "prototype-suite/catalog.browser.json",
  certificationPolicy: "draft-is-not-certified",
  categoryCounts: Object.fromEntries(catalog.map((category) => [category.number, category.components.length])),
  components: indexEntries,
};

const schema = {
  $schema: "https://json-schema.org/draft/2020-12/schema",
  $id: "component-sops.schema.json",
  title: "Component SOP Index",
  type: "object",
  required: ["schemaVersion", "generatedFrom", "certificationPolicy", "categoryCounts", "components"],
  properties: {
    schemaVersion: { const: 1 },
    generatedFrom: { type: "string" },
    certificationPolicy: { const: "draft-is-not-certified" },
    categoryCounts: { type: "object" },
    components: {
      type: "array",
      minItems: 309,
      maxItems: 309,
      items: {
        type: "object",
        required: ["componentKey", "legacyId", "name", "category", "prototypeComplexity", "provisionalRisk", "lifecycle", "certification", "sopPath", "source", "evidenceRoot", "frozenDecisions"],
        properties: {
          componentKey: { type: "string", pattern: "^(0[1-9]|1[5-8]):[a-z0-9-]+$" },
          prototypeComplexity: { enum: ["B", "C"] },
          provisionalRisk: { enum: ["R1", "R2", "R3"] },
          lifecycle: { const: "Draft" },
          certification: { const: "not-certified" },
          sopPath: { type: "string" },
          frozenDecisions: { type: "array" },
        },
      },
    },
  },
};

write(join(sopRoot, "README.md"), renderReadme(indexEntries));
write(join(sopRoot, "00-治理总纲", "React企业级组件库生产交付与认证SOP.md"), governanceContent);
write(join(sopRoot, "00-治理总纲", "组件SOP治理与认证规则.md"), renderGovernance());
write(join(sopRoot, "04-模板与证据规范", "单组件SOP模板说明.md"), renderTemplate());
write(join(sopRoot, "04-模板与证据规范", "单组件证据规范.md"), renderEvidenceSpec());
write(join(sopRoot, "03-机器索引", "component-sops.json"), `${json(index)}\n`);
write(join(sopRoot, "03-机器索引", "component-sops.schema.json"), `${json(schema)}\n`);

console.log(JSON.stringify({
  status: "GENERATED",
  categories: catalog.length,
  componentSops: indexEntries.length,
  output: relative(suiteRoot, sopRoot),
}, null, 2));
