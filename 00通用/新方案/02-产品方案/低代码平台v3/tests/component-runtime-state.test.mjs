import test from 'node:test';
import assert from 'node:assert/strict';
import { createComponentRuntimeState, executeComponentRuntimeAction } from '../prototype/component-runtime-state.mjs';

const manifest = { type: 'TextField', title: '单行文本', category: 'input', status: 'ready' };

test('runtime state isolates component identity and updates values immutably', () => {
  const state = createComponentRuntimeState(manifest);
  const next = executeComponentRuntimeAction(state, 'set-value', { value: 'A-001' });
  assert.equal(state.value, '');
  assert.equal(next.value, 'A-001');
  assert.equal(next.componentType, 'TextField');
});

test('data, hierarchy, command, error and permission actions are executable', () => {
  let state = createComponentRuntimeState(manifest);
  state = executeComponentRuntimeAction(state, 'add-row');
  state = executeComponentRuntimeAction(state, 'expand', { key: 'root' });
  state = executeComponentRuntimeAction(state, 'trigger-command');
  state = executeComponentRuntimeAction(state, 'set-error', { error: 'load-failed' });
  state = executeComponentRuntimeAction(state, 'retry');
  state = executeComponentRuntimeAction(state, 'set-permission', { permission: 'readonly' });
  assert.equal(state.rows.length, 2);
  assert.deepEqual(state.expanded, ['root']);
  assert.equal(state.commandCount, 1);
  assert.equal(state.error, null);
  assert.equal(state.recovered, true);
  assert.equal(state.permission, 'readonly');
});

test('unknown actions and invalid permissions fail closed', () => {
  const state = createComponentRuntimeState(manifest);
  assert.equal(executeComponentRuntimeAction(state, 'unknown'), state);
  assert.equal(executeComponentRuntimeAction(state, 'set-permission', { permission: 'admin' }), state);
});

test('data components own an editable and reorderable column model', () => {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === 'EntryGrid');
  let state = createComponentRuntimeState(manifest);
  assert.deepEqual(state.columns.map(({ id, title }) => ({ id, title })), [
    { id: 'code', title: '编码' },
    { id: 'name', title: '名称' },
    { id: 'quantity', title: '数量' },
  ]);

  state = executeComponentRuntimeAction(state, 'add-column', { title: '金额', type: 'money' });
  const amount = state.columns.at(-1);
  assert.equal(amount.title, '金额');
  assert.equal(amount.type, 'money');

  state = executeComponentRuntimeAction(state, 'rename-column', { columnId: amount.id, title: '含税金额' });
  state = executeComponentRuntimeAction(state, 'set-column-type', { columnId: amount.id, type: 'number' });
  state = executeComponentRuntimeAction(state, 'move-column-left', { columnId: amount.id });
  assert.equal(state.columns.at(-2).title, '含税金额');
  assert.equal(state.columns.at(-2).type, 'number');

  state = executeComponentRuntimeAction(state, 'set-column-visible', { columnId: amount.id, visible: false });
  assert.equal(state.columns.find((column) => column.id === amount.id).visible, false);
  state = executeComponentRuntimeAction(state, 'move-column-right', { columnId: amount.id });
  assert.equal(state.columns.at(-1).id, amount.id);
  state = executeComponentRuntimeAction(state, 'remove-column', { columnId: amount.id });
  assert.equal(state.columns.some((column) => column.id === amount.id), false);
});

test('data components never remove their final column', () => {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === 'EntryGrid');
  let state = createComponentRuntimeState(manifest);
  for (const column of state.columns.slice(1)) {
    state = executeComponentRuntimeAction(state, 'remove-column', { columnId: column.id });
  }
  const unchanged = executeComponentRuntimeAction(state, 'remove-column', { columnId: state.columns[0].id });
  assert.equal(unchanged.columns.length, 1);
});

test('every declared runtime action has an observable state transition with valid payload', async () => {
  const { COMPONENT_MANIFESTS } = await import('../prototype/component-registry.mjs');
  const { getRuntimeContract } = await import('../prototype/component-runtime-contracts.mjs');
  const payloads = {
    'set-value': { value: 'sample' }, select: { value: 'A' }, toggle: {},
    'add-file': { file: { name: 'contract.pdf', size: 12 } }, 'remove-file': { name: 'seed.pdf' },
    'add-row': {}, 'remove-row': { rowId: 'ROW-1' }, expand: { key: 'root' }, 'select-node': { key: 'item-2' },
    'trigger-command': {}, 'next-page': {}, 'previous-page': {}, refresh: {}, 'toggle-play': {},
    'set-location': { value: '30,120' }, 'add-comment': { value: 'comment' },
  };
  for (const manifest of COMPONENT_MANIFESTS.filter((item) => item.status !== 'planned')) {
    const contract = getRuntimeContract(manifest);
    for (const action of contract.actions) {
      let state = createComponentRuntimeState(manifest);
      if (action === 'remove-file') state = { ...state, files: [{ name: 'seed.pdf', size: 1 }] };
      if (action === 'previous-page') state = { ...state, page: 2 };
      const next = executeComponentRuntimeAction(state, action, payloads[action] || {});
      assert.notEqual(next, state, `${manifest.type}:${action}`);
      assert.notDeepEqual(next, state, `${manifest.type}:${action}`);
    }
  }
});
