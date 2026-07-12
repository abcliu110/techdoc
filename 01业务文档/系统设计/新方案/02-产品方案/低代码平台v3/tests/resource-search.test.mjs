import test from 'node:test';
import assert from 'node:assert/strict';
import { filterResourceItems } from '../prototype/resource-search.mjs';

const items = [
  { id: 'salesOrder', title: '销售订单', terms: ['orderNo', '客户'] },
  { id: 'customer', title: '客户资料', terms: ['customerCode'] },
];

test('resource search matches ids, titles and workspace-specific terms', () => {
  assert.deepEqual(filterResourceItems(items, '订单').map((item) => item.id), ['salesOrder']);
  assert.deepEqual(filterResourceItems(items, 'customerCode').map((item) => item.id), ['customer']);
  assert.deepEqual(filterResourceItems(items, '').map((item) => item.id), ['salesOrder', 'customer']);
});

test('resource search is locale-insensitive and handles missing terms', () => {
  assert.deepEqual(filterResourceItems([{ id: 'R-001', title: 'Credit Check' }], 'credit').map((item) => item.id), ['R-001']);
  assert.deepEqual(filterResourceItems(items, 'not-found'), []);
});

