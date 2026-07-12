import test from 'node:test';
import assert from 'node:assert/strict';

import {
  createDesignerState,
  selectField,
  switchWorkspace,
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

test('validateForPublish allows publish preparation after blockers are closed', () => {
  const state = createDesignerState({ findings: [{ id: 'F-001', severity: 'P0', open: false }] });
  const result = validateForPublish(state);

  assert.equal(result.allowed, true);
  assert.equal(result.status, 'ready');
});

