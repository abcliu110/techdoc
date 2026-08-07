import { components } from "../catalog.mjs";

const componentNames = new Map(components.map(({ key, name }) => [key, name]));

const actions = Object.freeze({
  "05:advanced-query-builder": "add-predicate", "05:condition-group": "toggle-group", "05:nested-logic-query": "nest-group",
  "05:filter-panel": "apply-filter", "05:quick-filter-bar": "quick-overdue", "05:faceted-filter": "facet-east",
  "05:saved-query": "save-query", "05:saved-view": "restore-view", "05:query-template": "resolve-template",
  "05:dynamic-query-form": "load-field", "05:query-dsl": "parse-dsl", "05:full-text-search": "search-text",
  "05:semantic-search": "semantic-run", "05:natural-language-query": "interpret-query", "05:date-range-filter": "date-preset",
  "05:numeric-range-filter": "numeric-range", "05:tag-filter": "toggle-tag", "05:cross-field-query": "compare-fields",
  "05:aggregate-condition": "aggregate-run", "05:query-history": "replay-query",

  "06:remote-selector": "remote-search", "06:async-selector": "async-load", "06:multi-select": "multi-add",
  "06:tree-selector": "tree-choose", "06:cascader": "cascade-next", "06:table-selector": "table-row",
  "06:dialog-selector": "dialog-open", "06:transfer-selector": "transfer-right", "06:ordered-transfer": "order-up",
  "06:person-selector": "person-pick", "06:organization-selector": "org-pick", "06:department-selector": "dept-scope",
  "06:role-selector": "role-pick", "06:resource-selector": "resource-pick", "06:relation-selector": "relation-link",
  "06:master-data-selector": "master-pick", "06:address-selector": "address-pick", "06:map-selector": "map-marker",
  "06:date-selector": "date-pick", "06:date-range-selector": "date-range", "06:time-slot-selector": "slot-pick",
  "06:color-selector": "color-pick", "06:icon-selector": "icon-pick", "06:file-selector": "file-pick",
  "06:composite-selector": "composite-pick",

  "07:rich-text-editor": "rich-bold", "07:markdown-editor": "markdown-preview", "07:code-editor": "code-run",
  "07:json-editor": "json-validate", "07:yaml-editor": "yaml-validate", "07:xml-editor": "xml-parse",
  "07:formula-editor": "formula-evaluate", "07:expression-editor": "expression-test", "07:sql-editor": "sql-run",
  "07:visual-query-editor": "visual-join", "07:template-editor": "template-preview", "07:email-template-editor": "email-preview",
  "07:document-editor": "document-section", "07:spreadsheet-editor": "sheet-recalc", "07:diff-editor": "diff-accept",
  "07:version-editor": "version-restore", "07:collaborative-editor": "collab-merge", "07:diagram-editor": "diagram-add",
  "07:image-annotation-editor": "image-annotate", "07:schema-editor": "schema-constraint",

  "08:page-designer": "page-place", "08:form-designer": "form-place", "08:report-designer": "report-dimension",
  "08:dashboard-designer": "dashboard-bind", "08:mobile-page-designer": "mobile-bar", "08:data-source-designer": "source-test",
  "08:event-designer": "event-add", "08:action-designer": "action-config", "08:expression-designer": "expression-run",
  "08:theme-designer": "theme-switch", "08:component-builder": "component-prop", "08:template-manager": "template-create",
  "08:page-tree": "page-reparent", "08:navigation-designer": "nav-route", "08:responsive-designer": "device-mobile",
  "08:runtime-preview": "runtime-submit", "08:schema-editor": "schema-validate", "08:version-manager": "version-create",
  "08:publish-console": "publish-run", "08:design-system-manager": "system-deprecate",

  "09:workflow-designer": "workflow-edge", "09:bpmn-designer": "bpmn-path", "09:approval-flow": "approval-branch",
  "09:state-machine": "state-transition", "09:rule-designer": "rule-run", "09:decision-table": "decision-run",
  "09:decision-tree": "tree-evaluate", "09:expression-graph": "expression-edge", "09:dag-designer": "dag-edge",
  "09:pipeline-designer": "pipeline-run", "09:job-orchestrator": "job-schedule", "09:dependency-graph": "dependency-impact",
  "09:service-topology": "service-retry", "09:network-topology": "network-health", "09:data-lineage": "lineage-expand",
  "09:er-designer": "er-relation", "09:class-diagram": "class-association", "09:sequence-diagram": "sequence-message",
  "09:use-case-diagram": "usecase-link", "09:activity-diagram": "activity-fork", "09:flowchart-editor": "flowchart-decision",
  "09:mind-map": "mindmap-branch", "09:concept-map": "concept-relation", "09:node-editor": "node-connect",
  "09:infinite-canvas": "canvas-transform",
});

const profiles = Object.freeze({
  "05": Object.freeze({
    role: "陈敏｜财务经理", object: "订单、库存与应收查询集", capability: "data-integrity",
    task: "构造并执行业务查询，核对筛选口径和结果", rule: "查询条件、字段口径和数据范围必须可解释且绑定当前租户",
    exception: "查询服务失败、结果为空或条件互相冲突", effect: "生成可复用的查询结果并保留条件与执行记录",
    recovery: "保留有效条件，移除冲突条件后重试查询", keyboard: "Tab 到条件与操作，Enter 执行，Esc 关闭建议或回到条件编辑",
  }),
  "06": Object.freeze({
    role: "林晓｜销售代表", object: "客户、商品、人员与组织主数据", capability: "navigation-context",
    task: "在业务范围内定位并确认关联对象", rule: "候选项必须满足租户、组织、有效期和数据权限范围",
    exception: "远程加载失败、无匹配结果或候选对象无访问权限", effect: "建立可解释的业务关联并保留来源上下文",
    recovery: "清除无效选择，恢复搜索条件并重新加载候选项", keyboard: "Tab 进入选择器，方向键浏览，Enter 选择，Esc 关闭并返回触发点",
  }),
  "07": Object.freeze({
    role: "李明｜实施顾问", object: "合同、规则、SQL 与设备配置草稿", capability: "authoring-recovery",
    task: "编辑、校验并预览业务内容", rule: "解析、引用和发布前校验必须通过，未保存版本不得静默丢失",
    exception: "语法解析失败、引用失效或内容版本发生冲突", effect: "形成可预览、可回滚且带版本记录的编辑结果",
    recovery: "定位错误并恢复最近有效草稿或撤销最后一次编辑", keyboard: "Tab 到工具栏，编辑区使用标准快捷键，Esc 退出浮层并保留草稿",
  }),
  "08": Object.freeze({
    role: "李明｜实施顾问", object: "订单应用与工单应用版本", capability: "authoring-recovery",
    task: "配置应用结构、数据源、事件并完成预览或发布", rule: "发布前依赖、权限、数据源和版本差异必须全部通过校验",
    exception: "组件依赖缺失、数据源不可用或发布版本冲突", effect: "生成可审计的应用版本并通知受影响岗位",
    recovery: "保留当前设计，修复校验项或回滚到最近已发布版本", keyboard: "Tab 在画布与属性区切换，Enter 执行，Esc 取消拖放或关闭面板",
  }),
  "09": Object.freeze({
    role: "周宁｜销售经理", object: "销售审批、信用与库存调拨流程", capability: "authoring-recovery",
    task: "编排并验证流程、规则与图形关系", rule: "连接、条件和状态转换必须合法，循环和冲突规则必须在发布前阻断",
    exception: "非法连接、规则冲突、循环依赖或流程发布失败", effect: "生成可执行的流程版本、影响说明和审计记录",
    recovery: "撤销非法变更，定位冲突节点并恢复最近有效流程版本", keyboard: "Tab 到节点与工具，方向键移动，Enter 连接或确认，Esc 取消当前编排",
  }),
});

function contract(componentKey, action) {
  const category = componentKey.slice(0, 2);
  const name = componentNames.get(componentKey) || componentKey.slice(3);
  const profile = profiles[category];
  return Object.freeze({
    componentKey,
    hash: componentKey.slice(3),
    steps: Object.freeze([
      Object.freeze({ action: "click", selector: "[data-readiness-start]", path: "primary" }),
      Object.freeze({ action: "click", selector: `[data-action="${action}"]`, path: "primary" }),
      Object.freeze({ action: "click", selector: "[data-readiness-exception]", path: "exception" }),
      Object.freeze({ action: "click", selector: "[data-readiness-exception]", path: "recovery" }),
      Object.freeze({ action: "click", selector: "[data-readiness-recovery]", path: "recovery" }),
    ]),
    observe: "#prototypeState",
    changed: "not:initial",
    reset: "initial",
    business: Object.freeze({
      level: "B", role: profile.role, task: `使用${name}${profile.task}`, objects: Object.freeze([name, profile.object]),
      rule: profile.rule, exception: `${name}：${profile.exception}`, effect: `${name}：${profile.effect}`,
    }),
    readiness: Object.freeze({
      states: Object.freeze(["initial", "primary", "exception", "recovered"]), recovery: profile.recovery,
      keyboard: profile.keyboard, riskCapabilities: Object.freeze([profile.capability]),
    }),
  });
}

export const middleInteractionContracts = Object.freeze(Object.fromEntries(
  Object.entries(actions).map(([componentKey, action]) => [componentKey, contract(componentKey, action)]),
));
