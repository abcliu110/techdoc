import test from 'node:test';
import assert from 'node:assert/strict';
import {
  DEFAULT_ENTRY_COLUMNS,
  createEntryView,
  updateColumnVisibility,
} from '../prototype/entry-runtime-view.mjs';

test('entry view projects rows, visible columns and numeric totals', () => {
  const view = createEntryView([
    { id: 'R-1', values: { materialCode: 'MAT-1', qty: 2, taxPrice: 10, amount: 20 } },
    { id: 'R-2', values: { materialCode: 'MAT-2', qty: 3, taxPrice: 12, amount: 36 } },
  ]);

  assert.equal(view.rows.length, 2);
  assert.equal(view.columns.length, DEFAULT_ENTRY_COLUMNS.length);
  assert.equal(view.rows[0].cells.materialCode, 'MAT-1');
  assert.equal(view.totals.qty, 5);
  assert.equal(view.totals.amount, 56);
});

test('entry view exposes the warehouse value written by batch fill', () => {
  const view = createEntryView([
    { id: 'R-1', values: { materialCode: 'MAT-1', warehouse: 'W-01' } },
  ]);

  assert.ok(view.columns.some((column) => column.id === 'warehouse'));
  assert.equal(view.rows[0].cells.warehouse, 'W-01');
});

test('entry view safely fills missing values and preserves zero', () => {
  const view = createEntryView([{ id: 'R-1', values: { qty: 0 } }]);
  assert.equal(view.rows[0].cells.qty, 0);
  assert.equal(view.rows[0].cells.materialCode, '');
  assert.equal(view.totals.qty, 0);
});

test('column visibility keeps the row number and at least one data column reachable', () => {
  const initial = DEFAULT_ENTRY_COLUMNS.map((column) => ({ ...column }));
  const hidden = updateColumnVisibility(initial, 'materialName', false);
  assert.equal(hidden.find((column) => column.id === 'materialName').visible, false);

  const attempted = hidden.reduce(
    (columns, column) => updateColumnVisibility(columns, column.id, false),
    hidden,
  );
  assert.ok(attempted.some((column) => column.visible));
});

test('unknown column updates return the same collection', () => {
  const columns = DEFAULT_ENTRY_COLUMNS.map((column) => ({ ...column }));
  assert.equal(updateColumnVisibility(columns, 'unknown', false), columns);
});
