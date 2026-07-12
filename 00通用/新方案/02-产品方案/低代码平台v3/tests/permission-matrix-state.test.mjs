import test from 'node:test';
import assert from 'node:assert/strict';
import { createPermissionMatrixState, updateFieldPolicy, updateOperationPolicy, addRole, applyRolePolicy, permissionCoverage } from '../prototype/permission-matrix-state.mjs';

test('field and operation policies update immutably', () => {
  const state = createPermissionMatrixState();
  const next = updateFieldPolicy(state, { roleId: 'SalesManager', fieldId: 'customer', key: 'mask', value: true });
  const final = updateOperationPolicy(next, { roleId: 'SalesManager', operationId: 'submit', allow: false });
  assert.equal(state.fieldPolicies.SalesManager.customer.mask, false);
  assert.equal(final.fieldPolicies.SalesManager.customer.mask, true);
  assert.equal(final.operationPolicies.SalesManager.submit, false);
});

test('page policy cannot widen a denied server baseline', () => {
  const state = createPermissionMatrixState();
  const next = updateFieldPolicy(state, { roleId: 'SalesManager', fieldId: 'amount', key: 'export', value: true }, { SalesManager: { amount: { export: false } } });
  assert.match(next.message, /不能扩大/);
});

test('role policy crops fields and commands and coverage fails closed', () => {
  let state = addRole(createPermissionMatrixState(), '访客');
  state = updateFieldPolicy(state, { roleId: state.selectedRoleId, fieldId: 'customer', key: 'visible', value: false });
  state = updateOperationPolicy(state, { roleId: state.selectedRoleId, operationId: 'submit', allow: false });
  const result = applyRolePolicy(state, state.selectedRoleId, [{ id: 'customer' }, { id: 'amount' }], [{ id: 'save' }, { id: 'submit' }]);
  assert.deepEqual(result.fields.map((field) => field.id), ['amount']);
  assert.deepEqual(result.commands.map((command) => command.id), ['save']);
  assert.equal(permissionCoverage(state, ['customer', 'amount'], ['save', 'submit']).complete, false);
});
