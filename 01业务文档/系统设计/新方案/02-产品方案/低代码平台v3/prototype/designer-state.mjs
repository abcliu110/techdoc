const WORKSPACE_PANELS = Object.freeze({
  model: ['object-tree', '已进入业务对象'],
  page: ['component-library', '已进入页面设计'],
  components: ['component-studio', '已进入组件设计'],
  rules: ['rule-list', '已进入规则编排'],
  permissions: ['role-matrix', '已进入权限设计'],
  preview: ['preview-settings', '已进入运行预览'],
});

const FIELD_CONTEXT = Object.freeze({
  orderNo: { title: '订单编码', group: '单据头' },
  customer: { title: '客户', group: '基本信息' },
  orderDate: { title: '订单日期', group: '基本信息' },
  salesOrg: { title: '销售组织', group: '组织信息' },
  amount: { title: '含税金额', group: '金额信息' },
  entries: { title: '销售订单分录', group: '分录明细' },
});

export function createDesignerState(overrides = {}) {
  return {
    activeWorkspace: 'page',
    visiblePanel: 'component-library',
    selectedNodeId: 'customer',
    inspectorTitle: '客户',
    breadcrumb: ['销售订单', '基本信息', '客户'],
    statusMessage: '草稿已自动保存',
    role: '销售主管',
    dirty: false,
    schema: null,
    past: [],
    future: [],
    transactionKey: null,
    device: 'desktop',
    businessState: 'create',
    inspectorType: 'ReferenceField',
    findings: [
      { id: 'F-PERM-001', severity: 'P0', open: true, message: '客户信用额度字段缺少导出权限策略' },
      { id: 'F-RULE-002', severity: 'P2', open: true, message: '折扣规则尚未覆盖空客户场景' },
    ],
    ...overrides,
  };
}

export function selectNode(state, node) {
  if (!node?.id || !node?.title || !node?.type) return state;
  return {
    ...state,
    selectedNodeId: node.id,
    inspectorTitle: node.title,
    inspectorType: node.type,
    breadcrumb: Array.isArray(node.path) ? [...node.path] : state.breadcrumb,
    statusMessage: `已选中：${node.title}`,
  };
}

export function applySchemaTransaction(state, schema, selectedNodeId, description = '更新页面', transactionKey = null) {
  if (!schema || schema === state.schema) return state;
  const continuesTransaction = transactionKey && transactionKey === state.transactionKey;
  return {
    ...state,
    schema,
    selectedNodeId: selectedNodeId ?? state.selectedNodeId,
    past: continuesTransaction ? state.past : [...state.past, { schema: state.schema, selectedNodeId: state.selectedNodeId }],
    future: [],
    transactionKey,
    dirty: true,
    statusMessage: description,
  };
}

export function endSchemaTransaction(state) {
  return state.transactionKey ? { ...state, transactionKey: null } : state;
}

export function undo(state) {
  if (state.past.length === 0) return state;
  const previous = state.past[state.past.length - 1];
  return {
    ...state,
    schema: previous.schema,
    selectedNodeId: previous.selectedNodeId,
    past: state.past.slice(0, -1),
    future: [{ schema: state.schema, selectedNodeId: state.selectedNodeId }, ...state.future],
    transactionKey: null,
    dirty: true,
    statusMessage: '已撤销',
  };
}

export function redo(state) {
  if (state.future.length === 0) return state;
  const next = state.future[0];
  return {
    ...state,
    schema: next.schema,
    selectedNodeId: next.selectedNodeId,
    past: [...state.past, { schema: state.schema, selectedNodeId: state.selectedNodeId }],
    future: state.future.slice(1),
    transactionKey: null,
    dirty: true,
    statusMessage: '已重做',
  };
}

const DEVICES = new Set(['desktop', 'tablet', 'mobile']);
const BUSINESS_STATES = new Set(['initial', 'create', 'edit', 'view', 'submit', 'approve']);

export function setDevice(state, device) {
  return DEVICES.has(device) ? { ...state, device } : state;
}

export function setBusinessState(state, businessState) {
  return BUSINESS_STATES.has(businessState) ? { ...state, businessState } : state;
}

export function switchWorkspace(state, workspace) {
  const target = WORKSPACE_PANELS[workspace];
  if (!target) return state;
  return {
    ...state,
    activeWorkspace: workspace,
    visiblePanel: target[0],
    statusMessage: target[1],
  };
}

export function selectField(state, fieldId) {
  const field = FIELD_CONTEXT[fieldId];
  if (!field) return state;
  return {
    ...state,
    selectedNodeId: fieldId,
    inspectorTitle: field.title,
    breadcrumb: ['销售订单', field.group, field.title],
    statusMessage: `已选中：${field.title}`,
  };
}

const PUBLISH_CHECKS = Object.freeze([
  ['schema', 'Schema 结构与字段引用'],
  ['rules', '规则依赖与循环检测'],
  ['permissions', '角色与字段权限覆盖'],
  ['renderer', '运行态兼容性'],
]);

export function validateForPublish(state, evidence = {}) {
  const blockers = state.findings.filter(
    (finding) => finding.open && (finding.severity === 'P0' || finding.severity === 'P1'),
  );
  const checks = PUBLISH_CHECKS.map(([id, label]) => {
    const supplied = evidence[id];
    const status = ['passed', 'failed'].includes(supplied?.status) ? supplied.status : 'not_run';
    return {
      id,
      label,
      status,
      detail: supplied?.detail || '尚未执行真实检查',
    };
  });
  const incompleteChecks = checks.filter((check) => check.status !== 'passed');

  if (blockers.length > 0 || incompleteChecks.length > 0) {
    const reasons = [];
    if (blockers.length > 0) reasons.push(`${blockers.length} 个阻断问题`);
    if (incompleteChecks.length > 0) reasons.push(`${incompleteChecks.length} 项检查未通过`);
    return {
      allowed: false,
      status: 'blocked',
      message: `发布准备被阻断：${reasons.join('，')}`,
      blockers,
      checks,
    };
  }

  return {
    allowed: true,
    status: 'ready',
    message: '发布前校验通过，可以生成候选版本',
    blockers: [],
    checks,
  };
}

export const designerCatalog = Object.freeze({
  workspaces: Object.keys(WORKSPACE_PANELS),
  fields: FIELD_CONTEXT,
});
