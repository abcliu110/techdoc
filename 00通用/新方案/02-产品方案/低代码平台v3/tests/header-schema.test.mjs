import test from 'node:test';
import assert from 'node:assert/strict';

import { createSalesOrderDesignerSchema } from '../prototype/header-schema.mjs';
import { validateSchema } from '../prototype/schema-engine.mjs';

test('creates one authoritative schema for the sales order header and entries', () => {
  const schema = createSalesOrderDesignerSchema();

  assert.deepEqual(schema.nodes.page.children, ['header-fields', 'entries']);
  assert.deepEqual(schema.nodes['header-fields'].children, [
    'orderNo',
    'customer',
    'orderDate',
    'salesOrg',
    'amount',
  ]);
  assert.equal(Object.keys(schema.nodes).length, 8);
  assert.deepEqual(validateSchema(schema), { valid: true, errors: [] });
});

test('stores field presentation, behavior and binding on each schema node', () => {
  const schema = createSalesOrderDesignerSchema();

  assert.deepEqual(schema.nodes.orderNo.binding, {
    entityId: 'sales-order',
    fieldId: 'orderNo',
    path: 'SalesOrder.orderNo',
  });
  assert.equal(schema.nodes.orderNo.props.required, true);
  assert.equal(schema.nodes.orderNo.props.readonly, true);
  assert.equal(schema.nodes.customer.type, 'ReferencePicker');
  assert.equal(schema.nodes.orderDate.type, 'Date');
  assert.equal(schema.nodes.salesOrg.type, 'OrganizationPicker');
  assert.equal(schema.nodes.amount.type, 'MoneyField');
  assert.equal(schema.nodes.amount.props.width, '1/3');
  assert.equal(schema.nodes.entries.binding.entityId, 'sales-order-entry');
});

test('returns independent schema instances', () => {
  const first = createSalesOrderDesignerSchema();
  const second = createSalesOrderDesignerSchema();

  first.nodes.orderNo.props.title = 'Changed';
  assert.equal(second.nodes.orderNo.props.title, '订单编码');
});
