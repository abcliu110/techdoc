import { components } from "../catalog.mjs";

const componentNames = new Map(components.map(({ key, name }) => [key, name]));

const actions = {
  "01:grid-layout":"[data-columns]","01:row-column":"[data-direction]","01:flex-layout":"[data-grow-toggle]","01:multi-column":"[data-column-count]","01:split-pane":"[data-divider]","01:resizable-panel":"[data-resize]","01:dock-layout":"[data-dock-action]","01:tabs-layout":"[data-tab='history']","01:accordion":"[data-section]","01:card-layout":"[data-density]","01:masonry":"[data-balance]","01:dashboard":"[data-widget-add]","01:drag-grid":"[data-move]","01:free-canvas":"[data-move-node]","01:responsive-layout":"[data-device]","01:adaptive-breakpoint":"[data-breakpoint-toggle]","01:nested-container":"[data-nest]","01:configurable-page":"[data-slot-toggle]","01:multi-column-editor":"[data-pane]","01:immersive":"[data-focus-mode]","01:master-detail":"[data-record='A']","01:sidebar":"[data-collapse]","01:drawer-workspace":"[data-open]","01:multi-window":"[data-window='customer']","01:saved-workspace":"[data-save]",
  "02:data-grid":"[data-add]","02:editable-grid":"[data-commit]","02:batch-edit-grid":"[data-patch]","02:tree-grid":"[data-expand]","02:master-detail-grid":"[data-order='SO-01']","02:grouped-grid":"[data-group]","02:pivot-grid":"[data-drill]","02:cross-tab":"[data-swap]","02:olap-grid":"[data-level]","02:virtual-grid":"[data-scroll]","02:infinite-grid":"[data-load]","02:server-grid":"[data-next]","02:fixed-grid":"[data-scroll-x]","02:multi-header-grid":"[data-head-toggle]","02:column-group-grid":"[data-group-toggle]","02:column-manager":"[data-column]","02:resizable-grid":"[data-widen]","02:reorderable-grid":"[data-reorder]","02:row-sort-grid":"[data-row-move]","02:expandable-grid":"[data-expand-row]","02:inline-detail-grid":"[data-inline]","02:selection-grid":"[data-all]","02:cell-selection-grid":"[data-cell='A1']","02:clipboard-grid":"[data-copy-action]","02:filter-grid":"[data-apply]","02:sort-grid":"[data-sort='amount']","02:summary-grid":"[data-sum]","02:frozen-grid":"[data-freeze]","02:spreadsheet-grid":"[data-calc]","02:property-grid":"[data-property-save]","02:key-value-grid":"[data-pair-add]","02:comparison-grid":"[data-compare]","02:matrix-grid":"[data-matrix='write']","02:diff-grid":"[data-apply-diff]",
  "03:tree-view":"[data-node='crm']","03:checkbox-tree":"[data-parent]","03:radio-tree":"[data-radio='hardware']","03:lazy-tree":"[data-load]","03:virtual-tree":"[data-next-window]","03:search-tree":"[data-find]","03:draggable-tree":"[data-reparent]","03:editable-tree":"[data-edit]","03:context-tree":"[data-target]","03:file-tree":"[data-new-file]","03:org-tree":"[data-org-move]","03:category-tree":"[data-category='office']","03:region-tree":"[data-region='shanghai']","03:menu-tree":"[data-menu='admin']","03:permission-tree":"[data-override]","03:dependency-tree":"[data-impact]","03:relationship-tree":"[data-direction]","03:outline-tree":"[data-heading='intro']","03:mindmap-tree":"[data-branch]","03:genealogy-tree":"[data-person='child']",
  "04:standard-form":"[data-submit]","04:dense-form":"[data-density]","04:dynamic-form":"[data-add-field]","04:schema-form":"[data-validate]","04:nested-form":"[data-path-save]","04:repeatable-form":"[data-add-line]","04:master-detail-form":"[data-total]","04:wizard-form":"[data-next]","04:step-form":"[data-step-next]","04:tab-form":"[data-tab='finance']","04:accordion-form":"[data-section]","04:conditional-form":"[data-company]","04:linked-form":"[data-linked-toggle]","04:calculated-form":"[data-calc-next]","04:validation-form":"[data-check]","04:async-validation-form":"[data-async-check]","04:realtime-validation-form":"[data-strong-password]","04:draft-form":"[data-edit-draft]","04:multi-page-form":"[data-page-next]","04:survey-form":"input[value='5']","04:conversational-form":"[data-answer-next]","04:matrix-question-form":"[data-matrix-check]","04:upload-form":"[data-mock-upload]","04:signature-form":"[data-stroke]","04:date-range-form":"[data-range]","04:address-form":"[data-address-next]","04:approval-form":"[data-approve]","04:version-form":"[data-version-next]","04:form-designer":"[data-field='email']","04:runtime-form":"[data-preview]",
};

const profiles = Object.freeze({
  "01": Object.freeze({
    role: "周宁｜销售经理", object: "销售订单 SO-20260714-018 工作区", capability: "navigation-context",
    task: "组织订单处理信息并保持岗位工作上下文", rule: "关键订单信息必须可达，布局变化不得改变阅读顺序或丢失未保存上下文",
    exception: "窄屏、面板收起或空间不足导致关键订单操作不可达", effect: "保留订单上下文并恢复可操作的工作区布局",
    recovery: "恢复上一个可用布局并把焦点送回触发控件", keyboard: "Tab 到达布局控件，Enter 执行，Esc 返回当前工作区",
  }),
  "02": Object.freeze({
    role: "王蕾｜仓库主管", object: "销售订单与库存批次 DATA-20260714", capability: "data-integrity",
    task: "处理订单、库存与应收明细并核对结果", rule: "批量、排序、过滤和编辑必须保持业务主键、版本与汇总口径一致",
    exception: "数据加载失败、结果为空或记录版本冲突时禁止静默覆盖", effect: "更新可追溯的数据视图并保留批次与版本审计",
    recovery: "保留当前条件并重新加载最新数据版本", keyboard: "Tab 进入表格工具，方向键移动，Enter 确认，Esc 取消未提交操作",
  }),
  "03": Object.freeze({
    role: "赵峰｜系统管理员", object: "组织与资源层级 HC-INDUSTRY", capability: "navigation-context",
    task: "核验组织、产品、仓位或权限层级关系", rule: "父子关系不得形成循环，移动节点后范围、路径和继承关系必须可解释",
    exception: "目标父节点无权访问、尚未加载或移动后形成循环依赖", effect: "更新层级路径并保留原位置用于撤销和审计",
    recovery: "撤销层级变更并恢复原展开路径与焦点", keyboard: "Tab 进入树，方向键导航，Enter 展开或执行，Esc 取消上下文操作",
  }),
  "04": Object.freeze({
    role: "林晓｜销售代表", object: "客户星河科技与订单 SO-20260714-018", capability: "data-integrity",
    task: "录入客户、合同、订单或工单数据并完成提交校验", rule: "必填、金额、日期和关联对象必须通过校验；脏数据不得在离开时静默丢失",
    exception: "字段校验失败、提交服务失败或记录版本已更新", effect: "保存业务草稿或生成可追踪的提交结果与后续待办",
    recovery: "定位首个错误并保留草稿，重新加载冲突字段后重试", keyboard: "Tab 按业务顺序移动，Enter 提交，Esc 关闭浮层并保留未保存内容",
  }),
});

function contract(componentKey, selector) {
  const category = componentKey.slice(0, 2);
  const name = componentNames.get(componentKey) || componentKey.slice(3);
  const profile = profiles[category];
  return Object.freeze({
    componentKey,
    hash: componentKey.slice(3),
    steps: Object.freeze([
      Object.freeze({ action: "click", selector: "[data-readiness-start]", path: "primary" }),
      Object.freeze({ action: componentKey === "03:context-tree" ? "contextmenu" : "click", selector, path: "primary" }),
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

export const interactionContractsCore = Object.freeze(Object.fromEntries(
  Object.entries(actions).map(([componentKey, selector]) => [componentKey, contract(componentKey, selector)]),
));
