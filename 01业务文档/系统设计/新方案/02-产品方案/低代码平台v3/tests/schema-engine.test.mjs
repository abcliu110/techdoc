import test from 'node:test';
import assert from 'node:assert/strict';

import {
  createSchema,
  insertMaterial,
  moveNode,
  removeNode,
  duplicateNode,
  validateSchema,
} from '../prototype/schema-engine.mjs';

function insert(schema, type, targetId, position = 'inside', id = type.toLowerCase()) {
  const result = insertMaterial(schema, { type, targetId, position, id });
  assert.equal(result.accepted, true, result.message);
  return result.nextSchema;
}

test('material insertion creates a normalized node without mutating the source schema', () => {
  const source = createSchema({ rootId: 'page' });
  const snapshot = structuredClone(source);
  const result = insertMaterial(source, {
    type: 'Section',
    targetId: 'page',
    position: 'inside',
    id: 'section-a',
    props: { title: '基本信息' },
  });

  assert.equal(result.accepted, true);
  assert.equal(result.selectedNodeId, 'section-a');
  assert.deepEqual(source, snapshot);
  assert.deepEqual(result.nextSchema.nodes.page.children, ['section-a']);
  assert.deepEqual(result.nextSchema.nodes['section-a'], {
    id: 'section-a',
    type: 'Section',
    parentId: 'page',
    children: [],
    props: { title: '基本信息' },
  });
});

test('before and after insertion preserve explicit sibling order', () => {
  let schema = createSchema({ rootId: 'page' });
  schema = insert(schema, 'Section', 'page', 'inside', 'middle');
  schema = insert(schema, 'Section', 'middle', 'before', 'first');
  schema = insert(schema, 'Section', 'middle', 'after', 'last');
  assert.deepEqual(schema.nodes.page.children, ['first', 'middle', 'last']);
});

test('moveNode supports sibling reorder and cross-container moves', () => {
  let schema = createSchema({ rootId: 'page' });
  schema = insert(schema, 'Section', 'page', 'inside', 'left');
  schema = insert(schema, 'Section', 'page', 'inside', 'right');
  schema = insert(schema, 'FieldLayout', 'left', 'inside', 'layout');
  schema = insert(schema, 'TextField', 'layout', 'inside', 'name');

  let result = moveNode(schema, { sourceId: 'right', targetId: 'left', position: 'before' });
  assert.equal(result.accepted, true, result.message);
  assert.deepEqual(result.nextSchema.nodes.page.children, ['right', 'left']);

  result = moveNode(result.nextSchema, { sourceId: 'layout', targetId: 'right', position: 'inside' });
  assert.equal(result.accepted, true, result.message);
  assert.deepEqual(result.nextSchema.nodes.left.children, []);
  assert.deepEqual(result.nextSchema.nodes.right.children, ['layout']);
  assert.equal(result.nextSchema.nodes.layout.parentId, 'right');
  assert.deepEqual(result.nextSchema.nodes.layout.children, ['name']);
});

test('moving a node into itself or its descendant rejects a cycle and preserves schema', () => {
  let schema = createSchema({ rootId: 'page' });
  schema = insert(schema, 'Section', 'page', 'inside', 'section');
  schema = insert(schema, 'Flex', 'section', 'inside', 'flex');
  const snapshot = structuredClone(schema);

  const result = moveNode(schema, { sourceId: 'section', targetId: 'flex', position: 'inside' });
  assert.equal(result.accepted, false);
  assert.equal(result.reasonCode, 'CYCLE_DETECTED');
  assert.equal(result.nextSchema, undefined);
  assert.deepEqual(schema, snapshot);
});

test('moving a node before or after itself is rejected instead of corrupting sibling order', () => {
  let schema = createSchema({ rootId: 'page' });
  schema = insert(schema, 'Section', 'page', 'inside', 'section');
  const snapshot = structuredClone(schema);
  const result = moveNode(schema, { sourceId: 'section', targetId: 'section', position: 'after' });
  assert.equal(result.accepted, false);
  assert.equal(result.reasonCode, 'SELF_TARGET');
  assert.deepEqual(schema, snapshot);
});

test('unknown component types are rejected without changing the source schema', () => {
  const schema = createSchema({ rootId: 'page' });
  const snapshot = structuredClone(schema);
  const result = insertMaterial(schema, {
    type: 'ImaginaryEnterpriseWidget',
    targetId: 'page',
    position: 'inside',
    id: 'unknown',
  });
  assert.equal(result.accepted, false);
  assert.equal(result.reasonCode, 'UNKNOWN_COMPONENT');
  assert.deepEqual(schema, snapshot);
});

test('invalid parent-child combinations are rejected explicitly', () => {
  let schema = createSchema({ rootId: 'page', pageType: 'bill' });
  schema = insert(schema, 'FieldLayout', 'page', 'inside', 'layout');
  const result = insertMaterial(schema, {
    type: 'EntryGrid',
    targetId: 'layout',
    position: 'inside',
    id: 'entries',
  });
  assert.equal(result.accepted, false);
  assert.equal(result.reasonCode, 'INVALID_PARENT');
  assert.match(result.message, /字段布局/);
});

test('SubEntryGrid requires a parent entry and is accepted inside that parent', () => {
  let schema = createSchema({ rootId: 'page', pageType: 'bill' });
  let result = insertMaterial(schema, {
    type: 'SubEntryGrid', targetId: 'page', position: 'inside', id: 'orphan',
  });
  assert.equal(result.accepted, false);
  assert.equal(result.reasonCode, 'PARENT_ENTRY_REQUIRED');

  let parent = insertMaterial(schema, {
    type: 'EntryGrid', targetId: 'page', position: 'inside', id: 'entries',
    binding: { entityId: 'purchase-item' },
  });
  assert.equal(parent.accepted, true, parent.message);
  schema = parent.nextSchema;
  result = insertMaterial(schema, {
    type: 'SubEntryGrid', targetId: 'entries', position: 'inside', id: 'subentries',
    binding: { entityId: 'purchase-item-detail' },
    relation: { parentKey: 'id', foreignKey: 'parentItemId' },
  });
  assert.equal(result.accepted, true, result.message);
  assert.equal(result.nextSchema.nodes.subentries.parentId, 'entries');
});

test('SubEntryGrid rejects missing entity relation even under an EntryGrid', () => {
  let schema = createSchema({ rootId: 'page', pageType: 'bill' });
  const parent = insertMaterial(schema, {
    type: 'EntryGrid', targetId: 'page', position: 'inside', id: 'entries',
    binding: { entityId: 'purchase-item' },
  });
  schema = parent.nextSchema;
  const snapshot = structuredClone(schema);
  const result = insertMaterial(schema, {
    type: 'SubEntryGrid', targetId: 'entries', position: 'inside', id: 'subentries',
  });
  assert.equal(result.accepted, false);
  assert.equal(result.reasonCode, 'ENTITY_RELATION_REQUIRED');
  assert.deepEqual(schema, snapshot);
});

test('insertMaterial enforces page, device and maturity availability', () => {
  const dynamicForm = createSchema({ rootId: 'page', pageType: 'dynamicForm' });
  let result = insertMaterial(dynamicForm, {
    type: 'EntryGrid', targetId: 'page', position: 'inside', id: 'entries',
  });
  assert.equal(result.reasonCode, 'PAGE_TYPE_UNSUPPORTED');

  result = insertMaterial(dynamicForm, {
    type: 'SplitPane', targetId: 'page', position: 'inside', id: 'split', device: 'mobile',
  });
  assert.equal(result.reasonCode, 'DEVICE_UNSUPPORTED');

  result = insertMaterial(dynamicForm, {
    type: 'Spreadsheet', targetId: 'page', position: 'inside', id: 'sheet',
  });
  assert.equal(result.reasonCode, 'COMPONENT_PLANNED');
});

test('a ready registered component outside the original engine list can be inserted', () => {
  const schema = createSchema({ rootId: 'page', pageType: 'dynamicForm' });
  const result = insertMaterial(schema, {
    type: 'RichTextInput', targetId: 'page', position: 'inside', id: 'rich-text',
  });
  assert.equal(result.accepted, true, result.message);
  assert.equal(result.nextSchema.nodes['rich-text'].type, 'RichTextInput');
});

test('complex layout containers create valid default structural children atomically', () => {
  const cases = [
    ['Columns', 'columns', 'Column', 2],
    ['Tabs', 'tabs', 'TabPane', 2],
    ['Wizard', 'wizard', 'WizardStep', 2],
    ['SplitPane', 'split', 'SplitRegion', 2],
    ['DashboardGrid', 'dashboard', 'DashboardCard', 1],
  ];

  for (const [type, id, childType, childCount] of cases) {
    const schema = createSchema({ rootId: 'page' });
    const result = insertMaterial(schema, { type, targetId: 'page', id });
    assert.equal(result.accepted, true, result.message);
    const container = result.nextSchema.nodes[id];
    assert.equal(container.children.length, childCount, type);
    for (const childId of container.children) {
      assert.equal(result.nextSchema.nodes[childId].type, childType);
      assert.equal(result.nextSchema.nodes[childId].parentId, id);
    }
    assert.equal(validateSchema(result.nextSchema).valid, true);
  }
});

test('default structural child ids avoid existing schema node ids', () => {
  let schema = createSchema({ rootId: 'page' });
  schema = insert(schema, 'Section', 'page', 'inside', 'tabs-tab-1');
  const result = insertMaterial(schema, { type: 'Tabs', targetId: 'page', id: 'tabs' });
  assert.equal(result.accepted, true, result.message);
  assert.equal(result.nextSchema.nodes['tabs-tab-1'].type, 'Section');
  assert.ok(result.nextSchema.nodes.tabs.children.every((id) => id !== 'tabs-tab-1'));
});

test('full-tree validation detects broken parent links and duplicate child references', () => {
  const broken = createSchema({ rootId: 'page' });
  broken.nodes.page.children = ['missing', 'missing'];
  const result = validateSchema(broken);
  assert.equal(result.valid, false);
  assert.ok(result.errors.some(({ reasonCode }) => reasonCode === 'DUPLICATE_CHILD'));
  assert.ok(result.errors.some(({ reasonCode }) => reasonCode === 'NODE_NOT_FOUND'));
});

test('full-tree validation rejects an invalid root contract', () => {
  const wrongType = createSchema({ rootId: 'page' });
  wrongType.nodes.page.type = 'Section';
  let result = validateSchema(wrongType);
  assert.equal(result.valid, false);
  assert.ok(result.errors.some(({ reasonCode }) => reasonCode === 'INVALID_ROOT_TYPE'));

  const parentedRoot = createSchema({ rootId: 'page' });
  parentedRoot.nodes.page.parentId = 'another-page';
  result = validateSchema(parentedRoot);
  assert.equal(result.valid, false);
  assert.ok(result.errors.some(({ reasonCode }) => reasonCode === 'ROOT_HAS_PARENT'));
});

test('full-tree validation rejects disconnected cycles even when every node has one parent', () => {
  const schema = createSchema({ rootId: 'page' });
  schema.nodes.a = { id: 'a', type: 'Section', parentId: 'b', children: ['b'], props: {} };
  schema.nodes.b = { id: 'b', type: 'Section', parentId: 'a', children: ['a'], props: {} };

  const result = validateSchema(schema);
  assert.equal(result.valid, false);
  assert.ok(result.errors.some(({ reasonCode }) => reasonCode === 'CYCLE_DETECTED'));
  assert.ok(result.errors.some(({ reasonCode }) => reasonCode === 'UNREACHABLE_NODE'));
});

test('TreeSubEntryGrid cannot be moved out of its parent entry', () => {
  let schema = createSchema({ rootId: 'page', pageType: 'bill' });
  let result = insertMaterial(schema, {
    type: 'TreeEntryGrid', targetId: 'page', position: 'inside', id: 'entries',
    binding: { entityId: 'tree-item' },
  });
  assert.equal(result.accepted, true, result.message);
  schema = result.nextSchema;
  result = insertMaterial(schema, {
    type: 'TreeSubEntryGrid', targetId: 'entries', position: 'inside', id: 'tree-subentries',
    binding: { entityId: 'tree-detail' },
    relation: { parentKey: 'id', foreignKey: 'parentItemId' },
  });
  assert.equal(result.accepted, true, result.message);
  schema = result.nextSchema;
  schema = insert(schema, 'Section', 'page', 'inside', 'section');
  const snapshot = structuredClone(schema);

  result = moveNode(schema, {
    sourceId: 'tree-subentries', targetId: 'section', position: 'inside',
  });
  assert.equal(result.accepted, false);
  assert.equal(result.reasonCode, 'PARENT_ENTRY_REQUIRED');
  assert.deepEqual(schema, snapshot);
});

test('duplicate and delete preserve the schema tree and nested descendants', () => {
  let schema = createSchema({ rootId: 'page', pageType: 'bill' });
  schema = insert(schema, 'Tabs', 'page', 'inside', 'tabs');
  const duplicate = duplicateNode(schema, 'tabs');
  assert.equal(duplicate.accepted, true);
  assert.equal(validateSchema(duplicate.nextSchema).valid, true);
  assert.equal(duplicate.nextSchema.nodes.page.children.length, 2);
  assert.equal(duplicate.nextSchema.nodes[duplicate.selectedNodeId].children.length, 2);
  const removed = removeNode(duplicate.nextSchema, duplicate.selectedNodeId);
  assert.equal(removed.accepted, true);
  assert.equal(validateSchema(removed.nextSchema).valid, true);
  assert.equal(removed.nextSchema.nodes.page.children.length, 1);
});
