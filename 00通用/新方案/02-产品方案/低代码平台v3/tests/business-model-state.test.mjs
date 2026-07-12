import test from 'node:test';
import assert from 'node:assert/strict';
import { createBusinessModelState, addBusinessObject, addBusinessField, removeBusinessField, addBusinessRelation, addBusinessIndex, selectedBusinessObject } from '../prototype/business-model-state.mjs';

test('business objects and fields are editable with stable ids', () => {
  let state = addBusinessObject(createBusinessModelState(), '合同');
  state = addBusinessField(state, { id: 'contractNo', name: '合同编码', type: 'text' });
  assert.equal(selectedBusinessObject(state).id, 'BusinessObject1');
  assert.equal(selectedBusinessObject(state).fields[0].id, 'contractNo');
});

test('relations and indexes enter authoritative model state', () => {
  let state = createBusinessModelState();
  state = addBusinessRelation(state, 'SalesOrderEntry');
  state = addBusinessIndex(state, 'orderNo', true);
  assert.equal(selectedBusinessObject(state).relations[0].targetId, 'SalesOrderEntry');
  assert.equal(selectedBusinessObject(state).indexes[0].unique, true);
});

test('page referenced fields cannot be deleted', () => {
  const state = createBusinessModelState();
  const next = removeBusinessField(state, 'customer');
  assert.equal(selectedBusinessObject(next).fields.some((field) => field.id === 'customer'), true);
  assert.match(next.message, /不能删除/);
});
