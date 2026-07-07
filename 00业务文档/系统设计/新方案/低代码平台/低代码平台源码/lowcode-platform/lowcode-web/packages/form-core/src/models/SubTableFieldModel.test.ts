import { describe, it, expect, beforeEach } from 'vitest';
import { SubTableFieldModel } from './SubTableFieldModel';
import type { FormField, BOField, BORelation } from '../types';

describe('SubTableFieldModel', () => {
  let formField: FormField;
  let boField: BOField;
  let relation: BORelation;
  let mockFormModel: any;

  beforeEach(() => {
    boField = {
      fieldId: 'items',
      fieldName: '订单明细',
      fieldType: 'reference',
      dataType: 'json',
      required: false,
      unique: false,
    };

    relation = {
      relationId: 'order_items',
      relationType: 'one-to-many',
      sourceBO: 'order',
      targetBO: 'order_item',
      sourceField: 'order_id',
      targetField: 'order_id',
    };

    formField = {
      fieldId: 'items',
      boField: 'items',
      componentType: 'subTable',
      label: '订单明细',
      componentProps: {
        subTable: {
          defaultRowCount: 0,
          columns: [
            { fieldId: 'product', label: '产品', componentType: 'input' },
            { fieldId: 'qty', label: '数量', componentType: 'inputNumber' },
            { fieldId: 'price', label: '单价', componentType: 'inputNumber' },
          ],
        },
      },
    };

    mockFormModel = {
      getValues: () => ({}),
      notifyFieldChange: () => {},
    };
  });

  describe('initialization', () => {
    it('should initialize with empty rows', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      expect(subTable.rowCount).toBe(0);
      expect(subTable.getRowIds()).toEqual([]);
    });

    it('should initialize with default rows', () => {
      formField.componentProps!.subTable.defaultRowCount = 2;
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      expect(subTable.rowCount).toBe(2);
    });
  });

  describe('row management', () => {
    it('should add row', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      const rowId = subTable.addRow();

      expect(subTable.rowCount).toBe(1);
      expect(rowId).toBeDefined();
      expect(subTable.getRowIds()).toContain(rowId);
    });

    it('should add row with initial data', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      const rowId = subTable.addRow({ product: 'Apple', qty: 10, price: 5.0 });
      const rowData = subTable.getRowData(rowId);

      expect(rowData.product).toBe('Apple');
      expect(rowData.qty).toBe(10);
      expect(rowData.price).toBe(5.0);
    });

    it('should delete row', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      const rowId = subTable.addRow();
      expect(subTable.rowCount).toBe(1);

      subTable.deleteRow(rowId);
      expect(subTable.rowCount).toBe(0);
    });

    it('should handle delete non-existent row', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      subTable.deleteRow('non-existent');
      expect(subTable.rowCount).toBe(0);
    });
  });

  describe('row data access', () => {
    it('should get and set row field value', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);
      const rowId = subTable.addRow();

      subTable.setRowFieldValue(rowId, 'product', 'Banana');
      const field = subTable.getRowField(rowId, 'product');

      expect(field?.getValue()).toBe('Banana');
    });

    it('should get row data', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);
      const rowId = subTable.addRow({ product: 'Cherry', qty: 20 });

      const rowData = subTable.getRowData(rowId);

      expect(rowData._rowId).toBe(rowId);
      expect(rowData.product).toBe('Cherry');
      expect(rowData.qty).toBe(20);
    });

    it('should return null for non-existent row', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      const rowData = subTable.getRowData('non-existent');

      expect(rowData).toBeNull();
    });
  });

  describe('getValue and setValue', () => {
    it('should get all rows data', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      subTable.addRow({ product: 'A', qty: 1, price: 10 });
      subTable.addRow({ product: 'B', qty: 2, price: 20 });

      const value = subTable.getValue();

      expect(value).toHaveLength(2);
      expect(value[0].product).toBe('A');
      expect(value[1].product).toBe('B');
    });

    it('should set all rows data', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      subTable.setValue([
        { product: 'X', qty: 5, price: 50 },
        { product: 'Y', qty: 10, price: 100 },
      ]);

      expect(subTable.rowCount).toBe(2);
      const value = subTable.getValue();
      expect(value[0].product).toBe('X');
      expect(value[1].product).toBe('Y');
    });

    it('should handle empty array setValue', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      subTable.addRow();
      expect(subTable.rowCount).toBe(1);

      subTable.setValue([]);
      expect(subTable.rowCount).toBe(0);
    });

    it('should preserve row IDs when setValue with _rowId', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      const customRowId = 'custom-row-id';
      subTable.setValue([
        { _rowId: customRowId, product: 'Test' },
      ]);

      const rowIds = subTable.getRowIds();
      expect(rowIds).toContain(customRowId);
    });
  });

  describe('validation', () => {
    it('should validate all rows', async () => {
      // 添加必填校验
      formField.componentProps!.subTable.columns[0].validations = [
        { type: 'required', message: '产品不能为空' }
      ];
      formField.componentProps!.subTable.columns[0].boField = {
        fieldId: 'product',
        fieldName: '产品',
        fieldType: 'string',
        dataType: 'varchar',
        required: true,
        unique: false,
        validations: [{ type: 'required', message: '产品不能为空' }]
      };

      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);
      subTable.addRow(); // 空行

      const valid = await subTable.validate();

      expect(valid).toBe(false);
      expect(subTable.hasErrors()).toBe(true);
    });

    it('should pass validation with valid data', async () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);
      subTable.addRow({ product: 'Valid Product', qty: 10, price: 100 });

      const valid = await subTable.validate();

      expect(valid).toBe(true);
      expect(subTable.hasErrors()).toBe(false);
    });
  });

  describe('utility methods', () => {
    it('should clear all rows', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      subTable.addRow();
      subTable.addRow();
      expect(subTable.rowCount).toBe(2);

      subTable.clear();
      expect(subTable.rowCount).toBe(0);
    });

    it('should reset all rows to initial state', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);
      const rowId = subTable.addRow();

      // 设置初始值后修改
      subTable.setRowFieldValue(rowId, 'product', 'Value1');
      const field = subTable.getRowField(rowId, 'product');
      if (field) {
        field.initialValue = 'Value1'; // 手动设置初始值
      }

      subTable.setRowFieldValue(rowId, 'product', 'Changed');
      expect(field?.getValue()).toBe('Changed');
      expect(field?.dirty).toBe(true);

      subTable.reset();
      expect(field?.getValue()).toBe('Value1');
      expect(field?.dirty).toBe(false);
    });

    it('should move row', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      subTable.addRow({ product: 'First' });
      subTable.addRow({ product: 'Second' });
      subTable.addRow({ product: 'Third' });

      const originalOrder = subTable.getValue().map(r => r.product);
      expect(originalOrder).toEqual(['First', 'Second', 'Third']);

      // Move first to last
      subTable.moveRow(0, 2);

      const newOrder = subTable.getValue().map(r => r.product);
      expect(newOrder).toEqual(['Second', 'Third', 'First']);
    });

    it('should handle invalid move indices', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);
      subTable.addRow({ product: 'Only' });

      const before = subTable.getValue();

      subTable.moveRow(-1, 0);
      subTable.moveRow(0, 10);

      const after = subTable.getValue();
      expect(after).toEqual(before);
    });

    it('should get row count', () => {
      const subTable = new SubTableFieldModel(formField, boField, relation, mockFormModel);

      expect(subTable.rowCount).toBe(0);

      subTable.addRow();
      expect(subTable.rowCount).toBe(1);

      subTable.addRow();
      expect(subTable.rowCount).toBe(2);
    });
  });
});
