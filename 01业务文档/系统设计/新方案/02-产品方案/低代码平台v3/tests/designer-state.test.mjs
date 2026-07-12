import test from 'node:test';
import assert from 'node:assert/strict';

import {
  applySchemaTransaction,
  createDesignerState,
  endSchemaTransaction,
  redo,
  selectNode,
  selectField,
  setBusinessState,
  setDevice,
  switchWorkspace,
  undo,
  validateForPublish,
} from '../prototype/designer-state.mjs';

test('switchWorkspace changes the active workspace and visible panel', () => {
  const state = createDesignerState();
  const next = switchWorkspace(state, 'rules');

  assert.equal(next.activeWorkspace, 'rules');
  assert.equal(next.visiblePanel, 'rule-list');
  assert.equal(next.statusMessage, '已进入规则编排');
});

test('selectField synchronizes canvas selection, inspector and breadcrumb', () => {
  const state = createDesignerState();
  const next = selectField(state, 'customer');

  assert.equal(next.selectedNodeId, 'customer');
  assert.equal(next.inspectorTitle, '客户');
  assert.deepEqual(next.breadcrumb, ['销售订单', '基本信息', '客户']);
});

test('validateForPublish blocks publishing when critical findings remain', () => {
  const state = createDesignerState({ findings: [{ id: 'F-001', severity: 'P0', open: true }] });
  const result = validateForPublish(state);

  assert.equal(result.allowed, false);
  assert.equal(result.status, 'blocked');
  assert.match(result.message, /1 个阻断问题/);
});

test('validateForPublish blocks when required checks have not run', () => {
  const state = createDesignerState({ findings: [{ id: 'F-001', severity: 'P0', open: false }] });
  const result = validateForPublish(state);

  assert.equal(result.allowed, false);
  assert.equal(result.status, 'blocked');
  assert.equal(result.checks.length, 4);
  assert.ok(result.checks.every((check) => check.status === 'not_run'));
});

test('validateForPublish allows preparation only with passing evidence for every required check', () => {
  const state = createDesignerState({ findings: [{ id: 'F-001', severity: 'P0', open: false }] });
  const result = validateForPublish(state, {
    schema: { status: 'passed', detail: '3 nodes, 0 broken references' },
    rules: { status: 'passed', detail: '2 rules, no cycles' },
    permissions: { status: 'passed', detail: '3 roles covered' },
    renderer: { status: 'passed', detail: 'All node types have verified renderers' },
  });

  assert.equal(result.allowed, true);
  assert.equal(result.status, 'ready');
  assert.ok(result.checks.every((check) => check.status === 'passed'));
});

test('validateForPublish preserves failed check evidence', () => {
  const state = createDesignerState({ findings: [] });
  const result = validateForPublish(state, {
    schema: { status: 'failed', detail: 'Broken parent link' },
  });

  assert.equal(result.allowed, false);
  assert.equal(result.checks[0].status, 'failed');
  assert.equal(result.checks[0].detail, 'Broken parent link');
});

test('selectNode synchronizes selected node, inspector and breadcrumb', () => {
  const state = createDesignerState();
  const next = selectNode(state, {
    id: 'section-basic',
    title: '基础信息',
    type: 'Section',
    path: ['采购申请', '主表单', '基础信息'],
  });

  assert.equal(next.selectedNodeId, 'section-basic');
  assert.equal(next.inspectorTitle, '基础信息');
  assert.equal(next.inspectorType, 'Section');
  assert.deepEqual(next.breadcrumb, ['采购申请', '主表单', '基础信息']);
});

test('schema transactions create immutable undo and redo history', () => {
  const initialSchema = { version: 1, rootId: 'root', nodes: { root: { id: 'root', children: [] } } };
  const changedSchema = {
    version: 1,
    rootId: 'root',
    nodes: { root: { id: 'root', children: ['field-1'] }, 'field-1': { id: 'field-1', children: [] } },
  };
  const state = createDesignerState({ schema: initialSchema, selectedNodeId: 'root' });
  const changed = applySchemaTransaction(state, changedSchema, 'field-1', '添加文本字段');

  assert.notEqual(changed.schema, initialSchema);
  assert.deepEqual(initialSchema.nodes.root.children, []);
  assert.equal(changed.selectedNodeId, 'field-1');
  assert.equal(changed.dirty, true);
  assert.equal(changed.past.length, 1);

  const undone = undo(changed);
  assert.deepEqual(undone.schema, initialSchema);
  assert.equal(undone.future.length, 1);

  const redone = redo(undone);
  assert.deepEqual(redone.schema, changedSchema);
  assert.equal(redone.selectedNodeId, 'field-1');
});

test('new transaction after undo clears redo history', () => {
  const a = { rootId: 'root', nodes: { root: { id: 'root', children: [] } } };
  const b = { rootId: 'root', nodes: { root: { id: 'root', children: ['b'] } } };
  const c = { rootId: 'root', nodes: { root: { id: 'root', children: ['c'] } } };
  const state = applySchemaTransaction(createDesignerState({ schema: a }), b, 'b', 'add b');
  const undone = undo(state);
  const branched = applySchemaTransaction(undone, c, 'c', 'add c');
  assert.equal(branched.future.length, 0);
});

test('continuous text editing coalesces into one undo transaction', () => {
  const a = { rootId: 'root', nodes: { root: { id: 'root', props: { help: '' }, children: [] } } };
  const b = { rootId: 'root', nodes: { root: { id: 'root', props: { help: 'A' }, children: [] } } };
  const c = { rootId: 'root', nodes: { root: { id: 'root', props: { help: 'AB' }, children: [] } } };
  const key = 'property:root:help';
  const first = applySchemaTransaction(createDesignerState({ schema: a }), b, 'root', 'edit help', key);
  const second = applySchemaTransaction(first, c, 'root', 'edit help', key);

  assert.equal(second.past.length, 1);
  assert.deepEqual(second.schema, c);
  assert.deepEqual(undo(second).schema, a);

  const ended = endSchemaTransaction(second);
  const d = { rootId: 'root', nodes: { root: { id: 'root', props: { help: 'ABC' }, children: [] } } };
  const third = applySchemaTransaction(ended, d, 'root', 'edit help again', key);
  assert.equal(third.past.length, 2);
});

test('device and business state context are explicit', () => {
  const state = createDesignerState();
  const mobile = setDevice(state, 'mobile');
  const approved = setBusinessState(mobile, 'approve');

  assert.equal(approved.device, 'mobile');
  assert.equal(approved.businessState, 'approve');
  assert.equal(setDevice(approved, 'watch'), approved);
  assert.equal(setBusinessState(approved, 'deleted'), approved);
});
