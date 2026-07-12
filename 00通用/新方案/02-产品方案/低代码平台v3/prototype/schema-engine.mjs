import {
  acceptsChild,
  getAvailability,
  getManifest,
  getNodeLabel,
  isKnownNodeType,
  isRegisteredComponent,
} from './component-registry.mjs';

function reject(reasonCode, message) {
  return { accepted: false, reasonCode, message };
}

function cloneSchema(schema) {
  return structuredClone(schema);
}

const DEFAULT_STRUCTURES = Object.freeze({
  Columns: { type: 'Column', count: 2, label: '列' },
  Tabs: { type: 'TabPane', count: 2, label: '页签' },
  Wizard: { type: 'WizardStep', count: 2, label: '步骤' },
  SplitPane: { type: 'SplitRegion', count: 2, label: '区域' },
  DashboardGrid: { type: 'DashboardCard', count: 1, label: '卡片' },
});

function uniqueNodeId(schema, preferredId) {
  if (!schema.nodes[preferredId]) return preferredId;
  let suffix = 2;
  while (schema.nodes[`${preferredId}-${suffix}`]) suffix += 1;
  return `${preferredId}-${suffix}`;
}

function appendDefaultStructure(schema, container) {
  const contract = DEFAULT_STRUCTURES[container.type];
  if (!contract) return;
  for (let index = 1; index <= contract.count; index += 1) {
    const childId = uniqueNodeId(schema, `${container.id}-${contract.type.toLowerCase()}-${index}`);
    schema.nodes[childId] = {
      id: childId,
      type: contract.type,
      parentId: container.id,
      children: [],
      props: { title: `${contract.label} ${index}` },
    };
    container.children.push(childId);
  }
}

function requiredParentError(type, parentType) {
  const requiredParents = getManifest(type)?.requiresParent || [];
  if (requiredParents.length === 0 || requiredParents.includes(parentType)) return null;
  return reject(
    'PARENT_ENTRY_REQUIRED',
    `${getNodeLabel(type)}必须放入${requiredParents.map(getNodeLabel).join('或')}`,
  );
}

function findPlacement(schema, targetId, position) {
  const target = schema.nodes[targetId];
  if (!target) return { error: reject('TARGET_NOT_FOUND', `找不到落点节点：${targetId}`) };
  if (position === 'inside') return { parent: target, index: target.children.length };
  if (position !== 'before' && position !== 'after') {
    return { error: reject('INVALID_POSITION', `未知落点位置：${position}`) };
  }
  if (!target.parentId) return { error: reject('ROOT_MOVE_FORBIDDEN', '不能在页面根节点前后插入') };
  const parent = schema.nodes[target.parentId];
  const targetIndex = parent.children.indexOf(targetId);
  return { parent, index: targetIndex + (position === 'after' ? 1 : 0) };
}

function isDescendant(schema, candidateId, ancestorId) {
  let current = schema.nodes[candidateId];
  while (current?.parentId) {
    if (current.parentId === ancestorId) return true;
    current = schema.nodes[current.parentId];
  }
  return false;
}

export function createSchema(options = {}) {
  const rootId = options.rootId || 'page';
  return {
    version: 1,
    pageType: options.pageType || 'dynamicForm',
    rootId,
    nodes: {
      [rootId]: { id: rootId, type: 'FormPage', parentId: null, children: [], props: options.props || {} },
    },
  };
}

export function insertMaterial(schema, intent) {
  if (!isRegisteredComponent(intent.type)) {
    return reject('UNKNOWN_COMPONENT', `未知组件类型：${intent.type}`);
  }
  if (!intent.id) return reject('NODE_ID_REQUIRED', '新增组件必须提供节点 ID');
  if (schema.nodes[intent.id]) return reject('DUPLICATE_NODE_ID', `节点 ID 已存在：${intent.id}`);
  const availability = getAvailability(intent.type, {
    pageType: schema.pageType,
    device: intent.device || 'desktop',
    schemaNodeTypes: Object.values(schema.nodes).map(({ type }) => type),
  });
  if (!availability.available) return reject(availability.reasonCode, availability.message);
  const placement = findPlacement(schema, intent.targetId, intent.position || 'inside');
  if (placement.error) return placement.error;
  const { parent, index } = placement;

  const parentError = requiredParentError(intent.type, parent.type);
  if (parentError) return parentError;
  if (!acceptsChild(parent.type, intent.type)) {
    return reject('INVALID_PARENT', `${getNodeLabel(parent.type)}不能容纳${getNodeLabel(intent.type)}`);
  }
  if (['SubEntryGrid', 'TreeSubEntryGrid', 'SubCardEntry'].includes(intent.type)) {
    const relation = intent.relation;
    if (!parent.binding?.entityId || !intent.binding?.entityId || !relation?.parentKey || !relation?.foreignKey) {
      return reject('ENTITY_RELATION_REQUIRED', `${getNodeLabel(intent.type)}必须绑定父实体、子实体及主外键关系`);
    }
  }

  const nextSchema = cloneSchema(schema);
  nextSchema.nodes[intent.id] = {
    id: intent.id,
    type: intent.type,
    parentId: parent.id,
    children: [],
    props: structuredClone(intent.props || {}),
    ...(intent.binding ? { binding: structuredClone(intent.binding) } : {}),
    ...(intent.relation ? { relation: structuredClone(intent.relation) } : {}),
  };
  appendDefaultStructure(nextSchema, nextSchema.nodes[intent.id]);
  nextSchema.nodes[parent.id].children.splice(index, 0, intent.id);
  const validation = validateSchema(nextSchema);
  if (!validation.valid) return reject(validation.errors[0].reasonCode, validation.errors[0].message);
  return { accepted: true, nextSchema, selectedNodeId: intent.id };
}

export function moveNode(schema, intent) {
  const source = schema.nodes[intent.sourceId];
  if (!source) return reject('SOURCE_NOT_FOUND', `找不到待移动节点：${intent.sourceId}`);
  if (!source.parentId) return reject('ROOT_MOVE_FORBIDDEN', '不能移动页面根节点');
  if (intent.sourceId === intent.targetId) return reject('SELF_TARGET', '不能以节点自身作为移动落点');
  const placement = findPlacement(schema, intent.targetId, intent.position || 'inside');
  if (placement.error) return placement.error;
  const { parent } = placement;
  if (parent.id === source.id || isDescendant(schema, parent.id, source.id)) {
    return reject('CYCLE_DETECTED', '不能把节点移动到自身或其后代中');
  }
  const parentError = requiredParentError(source.type, parent.type);
  if (parentError) return parentError;
  if (!acceptsChild(parent.type, source.type)) {
    return reject('INVALID_PARENT', `${getNodeLabel(parent.type)}不能容纳${getNodeLabel(source.type)}`);
  }

  const nextSchema = cloneSchema(schema);
  const oldParent = nextSchema.nodes[source.parentId];
  oldParent.children.splice(oldParent.children.indexOf(source.id), 1);
  const nextParent = nextSchema.nodes[parent.id];
  const target = nextSchema.nodes[intent.targetId];
  const index = intent.position === 'inside'
    ? nextParent.children.length
    : nextParent.children.indexOf(target.id) + (intent.position === 'after' ? 1 : 0);
  nextParent.children.splice(index, 0, source.id);
  nextSchema.nodes[source.id].parentId = nextParent.id;
  const validation = validateSchema(nextSchema);
  if (!validation.valid) return reject(validation.errors[0].reasonCode, validation.errors[0].message);
  return { accepted: true, nextSchema, selectedNodeId: source.id };
}

export function removeNode(schema, nodeId) {
  const node = schema.nodes?.[nodeId];
  if (!node) return reject('SOURCE_NOT_FOUND', `找不到待删除节点：${nodeId}`);
  if (!node.parentId) return reject('ROOT_DELETE_FORBIDDEN', '不能删除页面根节点');
  const nextSchema = cloneSchema(schema);
  const removeIds = [];
  const collect = (id) => { removeIds.push(id); for (const childId of nextSchema.nodes[id]?.children || []) collect(childId); };
  collect(nodeId);
  const parent = nextSchema.nodes[node.parentId];
  parent.children = parent.children.filter((id) => id !== nodeId);
  for (const id of removeIds) delete nextSchema.nodes[id];
  const validation = validateSchema(nextSchema);
  if (!validation.valid) return reject(validation.errors[0].reasonCode, validation.errors[0].message);
  return { accepted: true, nextSchema, selectedNodeId: parent.id };
}

export function duplicateNode(schema, nodeId) {
  const source = schema.nodes?.[nodeId];
  if (!source) return reject('SOURCE_NOT_FOUND', `找不到待复制节点：${nodeId}`);
  if (!source.parentId) return reject('ROOT_DUPLICATE_FORBIDDEN', '不能复制页面根节点');
  const nextSchema = cloneSchema(schema);
  const parent = nextSchema.nodes[source.parentId];
  const idMap = new Map();
  const allocate = (id) => { const nextId = uniqueNodeId(nextSchema, `${id}-copy`); idMap.set(id, nextId); nextSchema.nodes[nextId] = null; for (const childId of schema.nodes[id].children || []) allocate(childId); };
  allocate(nodeId);
  const copy = (id, parentId) => {
    const nextId = idMap.get(id);
    const original = schema.nodes[id];
    nextSchema.nodes[nextId] = { ...structuredClone(original), id: nextId, parentId, children: original.children.map((childId) => idMap.get(childId)), props: { ...structuredClone(original.props || {}), title: `${original.props?.title || getNodeLabel(original.type)} 副本` } };
    for (const childId of original.children || []) copy(childId, nextId);
  };
  copy(nodeId, parent.id);
  parent.children.splice(parent.children.indexOf(nodeId) + 1, 0, idMap.get(nodeId));
  const validation = validateSchema(nextSchema);
  if (!validation.valid) return reject(validation.errors[0].reasonCode, validation.errors[0].message);
  return { accepted: true, nextSchema, selectedNodeId: idMap.get(nodeId) };
}

export function validateSchema(schema) {
  const errors = [];
  const root = schema.nodes?.[schema.rootId];
  if (!root) {
    errors.push({ reasonCode: 'ROOT_NOT_FOUND', message: 'Schema 根节点不存在' });
  } else {
    if (root.type !== 'FormPage') errors.push({ reasonCode: 'INVALID_ROOT_TYPE', message: 'Schema 根节点必须是 FormPage' });
    if (root.parentId !== null) errors.push({ reasonCode: 'ROOT_HAS_PARENT', message: 'Schema 根节点不能引用父节点' });
  }
  const referenced = new Map();
  for (const node of Object.values(schema.nodes || {})) {
    if (!isKnownNodeType(node.type)) errors.push({ reasonCode: 'UNKNOWN_COMPONENT', message: `未知组件类型：${node.type}` });
    const unique = new Set(node.children || []);
    if (unique.size !== (node.children || []).length) {
      errors.push({ reasonCode: 'DUPLICATE_CHILD', message: `节点 ${node.id} 存在重复子节点引用` });
    }
    for (const childId of node.children || []) {
      const child = schema.nodes[childId];
      if (!child) {
        errors.push({ reasonCode: 'NODE_NOT_FOUND', message: `找不到子节点：${childId}` });
        continue;
      }
      referenced.set(childId, (referenced.get(childId) || 0) + 1);
      if (child.parentId !== node.id) errors.push({ reasonCode: 'BROKEN_PARENT_LINK', message: `节点 ${childId} 的父引用不一致` });
      if (!acceptsChild(node.type, child.type)) errors.push({ reasonCode: 'INVALID_PARENT', message: `${getNodeLabel(node.type)}不能容纳${getNodeLabel(child.type)}` });
    }
  }
  for (const node of Object.values(schema.nodes || {})) {
    if (node.id !== schema.rootId && referenced.get(node.id) !== 1) {
      errors.push({ reasonCode: 'ORPHAN_OR_MULTIPLE_PARENTS', message: `节点 ${node.id} 必须且只能被一个父节点引用` });
    }
  }

  const reachable = new Set();
  const visitReachable = (nodeId) => {
    if (reachable.has(nodeId)) return;
    const node = schema.nodes?.[nodeId];
    if (!node) return;
    reachable.add(nodeId);
    for (const childId of node.children || []) visitReachable(childId);
  };
  if (root) visitReachable(schema.rootId);

  const colors = new Map();
  const cyclicNodes = new Set();
  const visitForCycles = (nodeId, path = []) => {
    const color = colors.get(nodeId);
    if (color === 'gray') {
      const cycleStart = path.indexOf(nodeId);
      for (const id of path.slice(cycleStart)) cyclicNodes.add(id);
      return;
    }
    if (color === 'black') return;
    const node = schema.nodes?.[nodeId];
    if (!node) return;
    colors.set(nodeId, 'gray');
    for (const childId of node.children || []) visitForCycles(childId, [...path, nodeId]);
    colors.set(nodeId, 'black');
  };
  for (const nodeId of Object.keys(schema.nodes || {})) visitForCycles(nodeId);
  if (cyclicNodes.size > 0) {
    errors.push({ reasonCode: 'CYCLE_DETECTED', message: `Schema 存在节点闭环：${[...cyclicNodes].join(', ')}` });
  }
  for (const nodeId of Object.keys(schema.nodes || {})) {
    if (!reachable.has(nodeId)) {
      errors.push({ reasonCode: 'UNREACHABLE_NODE', message: `节点 ${nodeId} 无法从根节点访问` });
    }
  }
  return { valid: errors.length === 0, errors };
}
