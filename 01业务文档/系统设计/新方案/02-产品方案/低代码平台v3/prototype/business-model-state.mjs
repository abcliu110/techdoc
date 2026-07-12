const seedObjects = [
  ['SalesOrder', '销售订单', [['orderNo', '订单编码', 'text'], ['customer', '客户', 'reference'], ['orderDate', '订单日期', 'date'], ['amount', '含税金额', 'money']]],
  ['SalesOrderEntry', '销售订单分录', [['material', '物料', 'reference'], ['qty', '数量', 'decimal'], ['price', '含税单价', 'money']]],
  ['Customer', '客户', [['code', '客户编码', 'text'], ['name', '客户名称', 'text']]],
  ['Material', '物料', [['code', '物料编码', 'text'], ['name', '物料名称', 'text']]],
  ['SalesOrganization', '销售组织', [['code', '组织编码', 'text'], ['name', '组织名称', 'text']]],
];

export function createBusinessModelState() {
  const objects = seedObjects.map(([id, name, fields]) => ({ id, name, fields: fields.map(([fieldId, fieldName, type]) => ({ id: fieldId, name: fieldName, type, referencedByPage: id === 'SalesOrder' })), relations: [], indexes: [] }));
  return { objects, selectedObjectId: 'SalesOrder', nextObject: 1, nextField: 1, message: '' };
}

export function selectBusinessObject(state, objectId) { return state.objects.some((item) => item.id === objectId) ? { ...state, selectedObjectId: objectId } : state; }

function updateSelected(state, updater, message) {
  return { ...state, objects: state.objects.map((item) => item.id === state.selectedObjectId ? updater(item) : item), message };
}

export function addBusinessObject(state, name = `新业务对象 ${state.nextObject}`) {
  const id = `BusinessObject${state.nextObject}`;
  return { ...state, objects: [...state.objects, { id, name, fields: [], relations: [], indexes: [] }], selectedObjectId: id, nextObject: state.nextObject + 1, message: '业务对象已新增' };
}

export function addBusinessField(state, values = {}) {
  const id = values.id || `field${state.nextField}`;
  const selected = state.objects.find((item) => item.id === state.selectedObjectId);
  if (!selected || selected.fields.some((field) => field.id === id)) return state;
  const next = updateSelected(state, (item) => ({ ...item, fields: [...item.fields, { id, name: values.name || `新字段 ${state.nextField}`, type: values.type || 'text', referencedByPage: false }] }), '字段已新增');
  return { ...next, nextField: state.nextField + 1 };
}

export function updateBusinessField(state, fieldId, patch) {
  if (!fieldId || !patch || typeof patch !== 'object') return state;
  return updateSelected(state, (item) => ({ ...item, fields: item.fields.map((field) => field.id === fieldId ? { ...field, ...patch, id: field.id } : field) }), '字段已更新');
}

export function removeBusinessField(state, fieldId) {
  const field = state.objects.find((item) => item.id === state.selectedObjectId)?.fields.find((item) => item.id === fieldId);
  if (!field) return state;
  if (field.referencedByPage) return { ...state, message: '字段已被页面引用，不能删除' };
  return updateSelected(state, (item) => ({ ...item, fields: item.fields.filter((value) => value.id !== fieldId) }), '字段已删除');
}

export function addBusinessRelation(state, targetId) {
  if (!state.objects.some((item) => item.id === targetId) || targetId === state.selectedObjectId) return state;
  return updateSelected(state, (item) => ({ ...item, relations: [...item.relations, { id: `REL-${item.relations.length + 1}`, kind: 'one-to-many', targetId }] }), '关系已新增');
}

export function addBusinessIndex(state, fieldId, unique = false) {
  const object = state.objects.find((item) => item.id === state.selectedObjectId);
  if (!object?.fields.some((field) => field.id === fieldId)) return state;
  return updateSelected(state, (item) => ({ ...item, indexes: [...item.indexes, { id: `IDX-${item.indexes.length + 1}`, fieldId, unique }] }), '索引已新增');
}

export function selectedBusinessObject(state) { return state.objects.find((item) => item.id === state.selectedObjectId) || null; }
