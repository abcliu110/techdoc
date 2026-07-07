import { describe, it, expect, beforeEach } from 'vitest';
import { FieldModel } from './FieldModel';
import type { FormField, BOField } from '../types';

describe('FieldModel', () => {
  let boField: BOField;
  let formField: FormField;
  let mockFormModel: any;

  beforeEach(() => {
    boField = {
      fieldId: 'username',
      fieldName: '用户名',
      fieldType: 'string',
      dataType: 'varchar',
      required: true,
      unique: false,
      defaultValue: '',
    };

    formField = {
      fieldId: 'username',
      boField: 'username',
      componentType: 'input',
      label: '用户名',
    };

    mockFormModel = {
      getValues: () => ({}),
      notifyFieldChange: () => {},
    };
  });

  describe('initialization', () => {
    it('should initialize with default value', () => {
      const field = new FieldModel(formField, boField, mockFormModel);

      expect(field.fieldId).toBe('username');
      expect(field.value).toBe('');
      expect(field.initialValue).toBe('');
      expect(field.errors).toEqual([]);
      expect(field.visible).toBe(true);
      expect(field.disabled).toBe(false);
      expect(field.touched).toBe(false);
    });

    it('should use BO default value', () => {
      boField.defaultValue = 'John';
      const field = new FieldModel(formField, boField, mockFormModel);

      expect(field.value).toBe('John');
      expect(field.initialValue).toBe('John');
    });
  });

  describe('setValue', () => {
    it('should set value and mark as touched', () => {
      const field = new FieldModel(formField, boField, mockFormModel);

      field.setValue('Alice');

      expect(field.value).toBe('Alice');
      expect(field.touched).toBe(true);
    });

    it('should notify form model on change', () => {
      let notified = false;
      mockFormModel.notifyFieldChange = () => { notified = true; };

      const field = new FieldModel(formField, boField, mockFormModel);
      field.setValue('Bob');

      expect(notified).toBe(true);
    });

    it('should not notify when silent option is true', () => {
      let notified = false;
      mockFormModel.notifyFieldChange = () => { notified = true; };

      const field = new FieldModel(formField, boField, mockFormModel);
      field.setValue('Charlie', { silent: true });

      expect(notified).toBe(false);
    });

    it('should clear errors on setValue', () => {
      const field = new FieldModel(formField, boField, mockFormModel);
      field.setErrors(['Error 1', 'Error 2']);

      field.setValue('Valid');

      expect(field.errors).toEqual([]);
    });
  });

  describe('computed properties', () => {
    it('should compute dirty state', () => {
      const field = new FieldModel(formField, boField, mockFormModel);

      expect(field.dirty).toBe(false);

      field.setValue('Changed');
      expect(field.dirty).toBe(true);

      field.reset();
      expect(field.dirty).toBe(false);
    });

    it('should compute valid state', () => {
      const field = new FieldModel(formField, boField, mockFormModel);

      expect(field.valid).toBe(true);

      field.setErrors(['Error']);
      expect(field.valid).toBe(false);

      field.clearErrors();
      expect(field.valid).toBe(true);
    });
  });

  describe('validation', () => {
    it('should validate required field', async () => {
      boField.validations = [
        { type: 'required', message: '用户名不能为空' }
      ];

      const field = new FieldModel(formField, boField, mockFormModel);

      const valid = await field.validate();

      expect(valid).toBe(false);
      expect(field.errors).toContain('用户名不能为空');
    });

    it('should pass required validation with value', async () => {
      boField.validations = [
        { type: 'required', message: '用户名不能为空' }
      ];

      const field = new FieldModel(formField, boField, mockFormModel);
      field.setValue('John');

      const valid = await field.validate();

      expect(valid).toBe(true);
      expect(field.errors).toEqual([]);
    });

    it('should validate range', async () => {
      boField.validations = [
        { type: 'range', min: 1, max: 100, message: '值必须在1-100之间' }
      ];

      const field = new FieldModel(formField, boField, mockFormModel);

      field.setValue(0);
      expect(await field.validate()).toBe(false);
      expect(field.errors.length).toBeGreaterThan(0);

      field.setValue(50);
      expect(await field.validate()).toBe(true);

      field.setValue(101);
      expect(await field.validate()).toBe(false);
    });

    it('should validate pattern', async () => {
      boField.validations = [
        { type: 'pattern', pattern: '^[a-zA-Z]+$', message: '只能包含字母' }
      ];

      const field = new FieldModel(formField, boField, mockFormModel);

      field.setValue('abc123');
      expect(await field.validate()).toBe(false);

      field.setValue('abc');
      expect(await field.validate()).toBe(true);
    });

    it('should validate custom validator', async () => {
      boField.validations = [
        {
          type: 'custom',
          message: '验证失败',
          validator: (value: any) => {
            return value.length >= 3 || '长度必须>=3';
          }
        }
      ];

      const field = new FieldModel(formField, boField, mockFormModel);

      field.setValue('ab');
      expect(await field.validate()).toBe(false);
      expect(field.errors).toContain('长度必须>=3');

      field.setValue('abc');
      expect(await field.validate()).toBe(true);
    });

    it('should combine BO and Form validations', async () => {
      boField.validations = [
        { type: 'required', message: 'BO: 必填' }
      ];

      formField.validations = [
        { type: 'pattern', pattern: '^[a-z]+$', message: 'Form: 只能小写' }
      ];

      const field = new FieldModel(formField, boField, mockFormModel);

      // 空值，只触发BO校验
      const valid1 = await field.validate();
      expect(valid1).toBe(false);
      expect(field.errors).toContain('BO: 必填');

      // 大写字母，触发Form校验
      field.setValue('ABC');
      const valid2 = await field.validate();
      expect(valid2).toBe(false);
      expect(field.errors).toContain('Form: 只能小写');

      // 小写字母，全部通过
      field.setValue('abc');
      const valid3 = await field.validate();
      expect(valid3).toBe(true);
      expect(field.errors).toEqual([]);
    });
  });

  describe('state management', () => {
    it('should reset to initial state', () => {
      const field = new FieldModel(formField, boField, mockFormModel);

      field.setValue('Changed');
      field.setErrors(['Error']);

      field.reset();

      expect(field.value).toBe('');
      expect(field.errors).toEqual([]);
      expect(field.touched).toBe(false);
    });

    it('should manage visibility', () => {
      const field = new FieldModel(formField, boField, mockFormModel);

      expect(field.visible).toBe(true);

      field.setVisible(false);
      expect(field.visible).toBe(false);
    });

    it('should manage disabled state', () => {
      const field = new FieldModel(formField, boField, mockFormModel);

      expect(field.disabled).toBe(false);

      field.setDisabled(true);
      expect(field.disabled).toBe(true);
    });

    it('should manage readonly state', () => {
      const field = new FieldModel(formField, boField, mockFormModel);

      expect(field.readonly).toBe(false);

      field.setReadonly(true);
      expect(field.readonly).toBe(true);
    });
  });
});
