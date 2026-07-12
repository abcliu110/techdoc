import test from 'node:test';
import assert from 'node:assert/strict';

import { decodeDesignerSnapshot, encodeDesignerSnapshot, decodeWorkspaceSnapshot, encodeWorkspaceSnapshot, createWorkspaceSnapshotValue } from '../prototype/designer-storage.mjs';
import { readFieldProperties, updateFieldProperty } from '../prototype/designer-properties.mjs';

test('versioned designer snapshot round trips without sharing references', () => {
  const state = {
    schema: { version: 1, rootId: 'page', nodes: { page: { id: 'page', children: [] } } },
    device: 'mobile',
    businessState: 'approve',
  };
  const encoded = encodeDesignerSnapshot(state);
  const decoded = decodeDesignerSnapshot(encoded);
  assert.equal(decoded.storageVersion, 1);
  assert.deepEqual(decoded.schema, state.schema);
  assert.equal(decoded.device, 'mobile');
  assert.equal(decoded.businessState, 'approve');
  decoded.schema.nodes.page.children.push('x');
  assert.deepEqual(state.schema.nodes.page.children, []);
});

test('workspace models persist independently from the compatible page snapshot', () => {
  const value = { businessModelState: { selectedObjectId: 'Customer' }, componentRuntimeStates: [['TextField', { value: 'ABC' }]] };
  const decoded = decodeWorkspaceSnapshot(encodeWorkspaceSnapshot(value));
  assert.deepEqual(decoded, value);
  decoded.componentRuntimeStates[0][1].value = 'changed';
  assert.equal(value.componentRuntimeStates[0][1].value, 'ABC');
});

test('invalid or future snapshots are rejected explicitly', () => {
  assert.throws(() => decodeDesignerSnapshot('{'), /无法解析/);
  assert.throws(() => decodeDesignerSnapshot(JSON.stringify({ storageVersion: 99 })), /不支持的设计器快照版本/);
});

test('field property edits are immutable schema data and survive snapshots', () => {
  const schema = { version: 1, rootId: 'page', nodes: { page: { id: 'page', children: [] } } };
  const changed = updateFieldProperty(schema, 'customer', 'required', false);
  const withHelp = updateFieldProperty(changed, 'customer', 'help', 'Choose an active customer');

  assert.equal(schema.fieldProperties, undefined);
  assert.equal(readFieldProperties(withHelp, 'customer').required, false);
  assert.equal(readFieldProperties(withHelp, 'customer').help, 'Choose an active customer');

  const decoded = decodeDesignerSnapshot(encodeDesignerSnapshot({
    schema: withHelp,
    device: 'desktop',
    businessState: 'create',
  }));
  assert.deepEqual(readFieldProperties(decoded.schema, 'customer'), {
    required: false,
    help: 'Choose an active customer',
  });
});

test('permission and rule inspector properties are accepted by the schema property engine', () => {
  const schema = { rootId: 'page', nodes: { page: { id: 'page' }, customer: { id: 'customer', props: {} } } };
  let next = updateFieldProperty(schema, 'customer', 'masked', true);
  next = updateFieldProperty(next, 'customer', 'auditLogged', false);
  next = updateFieldProperty(next, 'customer', 'changeRule', '不执行规则');
  next = updateFieldProperty(next, 'customer', 'validationFailure', '阻止提交');
  assert.deepEqual(readFieldProperties(next, 'customer'), {
    masked: true,
    auditLogged: false,
    changeRule: '不执行规则',
    validationFailure: '阻止提交',
  });
});

test('workspace snapshot builder keeps every independently editable designer surface', () => {
  const value = createWorkspaceSnapshotValue({
    businessModelState: { selectedObjectId: 'SalesOrder' },
    ruleBuilderState: { selectedRuleId: 'R-001' },
    permissionMatrixState: { selectedRoleId: 'sales' },
    commandState: { activePageTab: 'attachments' },
    entryColumns: [{ id: 'warehouse', visible: true }],
    selectedComponentType: 'TreeGrid',
    componentRuntimeStates: new Map([['TreeGrid', { expanded: ['root'] }]]),
    previewData: { contractFile: 'SO-0018.pdf' },
    previewSample: 'long',
    previewDevice: 'tablet',
  });
  assert.deepEqual(value.componentRuntimeStates, [['TreeGrid', { expanded: ['root'] }]]);
  assert.equal(value.previewData.contractFile, 'SO-0018.pdf');
  assert.equal(value.commandState.activePageTab, 'attachments');
  assert.equal(value.previewDevice, 'tablet');
});
