const FIELD_KEYS = new Set(['visible', 'edit', 'export', 'mask']);
const BOOL = new Set([true, false]);

export function createPermissionMatrixState() {
  const roles = [
    { id: 'SalesManager', name: '销售主管' },
    { id: 'SalesRepresentative', name: '销售专员' },
    { id: 'FinanceAuditor', name: '财务审核员' },
    { id: 'WarehouseOperator', name: '仓储人员' },
  ];
  const fieldPolicies = Object.fromEntries(roles.map((role) => [role.id, {
    customer: { visible: true, edit: role.id !== 'FinanceAuditor', export: role.id !== 'SalesRepresentative', mask: false },
    amount: { visible: role.id !== 'WarehouseOperator', edit: role.id === 'SalesManager', export: role.id !== 'SalesRepresentative', mask: role.id === 'SalesRepresentative' },
  }]));
  const operationPolicies = Object.fromEntries(roles.map((role) => [role.id, { save: true, submit: role.id !== 'WarehouseOperator', export: role.id === 'SalesManager' }]));
  return { roles, selectedRoleId: roles[0].id, fieldPolicies, operationPolicies, nextRole: 1, message: '' };
}

export function updateFieldPolicy(state, { roleId, fieldId, key, value }, serverBaseline = null) {
  if (!state.roles.some((role) => role.id === roleId) || !fieldId || !FIELD_KEYS.has(key) || !BOOL.has(value)) return state;
  if (value === true && serverBaseline?.[roleId]?.[fieldId]?.[key] === false) return { ...state, message: '页面权限不能扩大服务端授权' };
  return {
    ...state,
    fieldPolicies: { ...state.fieldPolicies, [roleId]: { ...(state.fieldPolicies[roleId] || {}), [fieldId]: { visible: true, edit: false, export: false, mask: false, ...(state.fieldPolicies[roleId]?.[fieldId] || {}), [key]: value } } },
    message: '字段权限已更新',
  };
}

export function updateOperationPolicy(state, { roleId, operationId, allow }, serverBaseline = null) {
  if (!state.roles.some((role) => role.id === roleId) || !operationId || !BOOL.has(allow)) return state;
  if (allow && serverBaseline?.[roleId]?.[operationId] === false) return { ...state, message: '页面权限不能扩大服务端授权' };
  return { ...state, operationPolicies: { ...state.operationPolicies, [roleId]: { ...(state.operationPolicies[roleId] || {}), [operationId]: allow } }, message: '操作权限已更新' };
}

export function selectRole(state, roleId) {
  return state.roles.some((role) => role.id === roleId) ? { ...state, selectedRoleId: roleId } : state;
}

export function addRole(state, name = `新角色 ${state.nextRole}`) {
  const id = `Role-${state.nextRole}`;
  return { ...state, roles: [...state.roles, { id, name }], selectedRoleId: id, fieldPolicies: { ...state.fieldPolicies, [id]: {} }, operationPolicies: { ...state.operationPolicies, [id]: {} }, nextRole: state.nextRole + 1, message: '角色已新增' };
}

export function applyRolePolicy(state, roleId, fields, commands) {
  const policies = state.fieldPolicies[roleId] || {};
  return {
    fields: fields.filter((field) => policies[field.id]?.visible !== false).map((field) => ({ ...field, readonly: field.readonly || policies[field.id]?.edit === false, masked: policies[field.id]?.mask === true })),
    commands: commands.filter((command) => state.operationPolicies[roleId]?.[command.id] !== false),
  };
}

export function permissionCoverage(state, fieldIds, operationIds) {
  const missing = [];
  for (const role of state.roles) {
    for (const fieldId of fieldIds) if (!state.fieldPolicies[role.id]?.[fieldId]) missing.push(`${role.id}:${fieldId}`);
    for (const operationId of operationIds) if (typeof state.operationPolicies[role.id]?.[operationId] !== 'boolean') missing.push(`${role.id}:${operationId}`);
  }
  return { complete: missing.length === 0, missing };
}
