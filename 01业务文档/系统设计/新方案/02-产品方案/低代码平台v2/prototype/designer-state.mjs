const WORKSPACE_PANELS = Object.freeze({
  model: ['object-tree', '已进入业务对象'],
  page: ['component-library', '已进入页面设计'],
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
    findings: [
      { id: 'F-PERM-001', severity: 'P0', open: true, message: '客户信用额度字段缺少导出权限策略' },
      { id: 'F-RULE-002', severity: 'P2', open: true, message: '折扣规则尚未覆盖空客户场景' },
    ],
    ...overrides,
  };
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

export function validateForPublish(state) {
  const blockers = state.findings.filter(
    (finding) => finding.open && (finding.severity === 'P0' || finding.severity === 'P1'),
  );

  if (blockers.length > 0) {
    return {
      allowed: false,
      status: 'blocked',
      message: `发布准备被阻断：仍有 ${blockers.length} 个阻断问题`,
      blockers,
    };
  }

  return {
    allowed: true,
    status: 'ready',
    message: '发布前校验通过，可以生成候选版本',
    blockers: [],
  };
}

export const designerCatalog = Object.freeze({
  workspaces: Object.keys(WORKSPACE_PANELS),
  fields: FIELD_CONTEXT,
});
