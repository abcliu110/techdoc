import test from 'node:test';
import assert from 'node:assert/strict';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import { buildRuntimeContracts, getRuntimeContract } from '../prototype/component-runtime-contracts.mjs';

test('every registered component has one explicit runtime contract', () => {
  const contracts = buildRuntimeContracts(COMPONENT_MANIFESTS);
  assert.equal(contracts.length, COMPONENT_MANIFESTS.length);
  assert.equal(new Set(contracts.map((item) => item.componentType)).size, COMPONENT_MANIFESTS.length);
  assert.ok(contracts.every((item) => item.controlKind && item.permissionModes.length === 3 && item.failureModes.length === 3));
});

test('complex controls retain distinct interaction contracts', () => {
  const byType = Object.fromEntries(COMPONENT_MANIFESTS.map((manifest) => [manifest.type, getRuntimeContract(manifest)]));
  assert.equal(byType.Attachment.controlKind, 'file');
  assert.deepEqual(byType.Attachment.actions, ['add-file', 'remove-file']);
  assert.equal(byType.TreeGrid.controlKind, 'tree-grid');
  assert.ok(byType.TreeGrid.actions.includes('add-row'));
  for (const action of ['add-column', 'remove-column', 'rename-column', 'set-column-type', 'move-column-left', 'move-column-right', 'set-column-visible']) {
    assert.ok(byType.EntryGrid.actions.includes(action), `EntryGrid must declare ${action}`);
  }
  assert.equal(byType.PivotTable.controlKind, 'pivot');
  assert.equal(byType.Map.controlKind, 'map');
  assert.equal(byType.Qrcode.controlKind, 'qrcode');
  assert.notEqual(byType.RichTextInput.controlKind, byType.TextField.controlKind);
});

test('planned components are disabled with no executable actions', () => {
  for (const manifest of COMPONENT_MANIFESTS.filter((item) => item.status === 'planned')) {
    const contract = getRuntimeContract(manifest);
    assert.equal(contract.disabled, true);
    assert.deepEqual(contract.actions, []);
  }
});
