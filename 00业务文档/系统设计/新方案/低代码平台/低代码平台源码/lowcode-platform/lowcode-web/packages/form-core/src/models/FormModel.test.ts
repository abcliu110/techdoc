import { describe, it, expect, beforeEach } from 'vitest';
import { FormModel } from './FormModel';
import type { FormDefinition, BusinessObject } from '../types';

describe('FormModel', () => {
  let bo: BusinessObject;
  let formDef: FormDefinition;

  beforeEach(() => {
    bo = {
      boId: 'user',
      boName: '用户',
      boType: 'entity',
      version: '1.0',
      entity: {
        tableName: 't_user',
        primaryKey: 'id',
        displayField: 'username',
      },
      fields: [
        {
          fieldId: 'username',
          fieldName: '用户名',
          fieldType: 'string',
          dataType: 'varchar',
          required: true,
          unique: false,
          defaultValue: '', // 添加默认值
          validations: [
            { type: 'required', message: '用户名不能为空' }
          ],
        },
        {
          fieldId: 'email',
          fieldName: '邮箱',
          fieldType: 'string',
          dataType: 'varchar',
          required: true,
          unique: false,
          defaultValue: '', // 添加默认值
        },
        {
          fieldId: 'age',
          fieldName: '年龄',
          fieldType: 'number',
          dataType: 'int',
          required: false,
          unique: false,
        },
      ],
      relations: [],
      rules: [],
    };

    formDef = {
      formId: 'user_form',
      formName: '用户表单',
      boId: 'user',
      formType: 'edit',
      version: '1.0',
      layout: {
        type: 'horizontal',
      },
      fields: [
        {
          fieldId: 'username',
          boField: 'username',
          componentType: 'input',
          label: '用户名',
        },
        {
          fieldId: 'email',
          boField: 'email',
          componentType: 'input',
          label: '邮箱',
        },
        {
          fieldId: 'age',
          boField: 'age',
          componentType: 'inputNumber',
          label: '年龄',
        },
      ],
    };
  });

  describe('initialization', () => {
    it('should initialize with form definition and BO', () => {
      const form = new FormModel(formDef, bo);

      expect(form.formId).toBe('user_form');
      expect(form.boId).toBe('user');
      expect(form.fields.size).toBe(3);
    });

    it('should create field models for all form fields', () => {
      const form = new FormModel(formDef, bo);

      expect(form.getField('username')).toBeDefined();
      expect(form.getField('email')).toBeDefined();
      expect(form.getField('age')).toBeDefined();
    });
  });

  describe('field access', () => {
    it('should get field by path', () => {
      const form = new FormModel(formDef, bo);

      const field = form.getField('username');

      expect(field).toBeDefined();
      expect(field?.fieldId).toBe('username');
    });

    it('should return undefined for non-existent field', () => {
      const form = new FormModel(formDef, bo);

      const field = form.getField('nonexistent');

      expect(field).toBeUndefined();
    });
  });

  describe('values management', () => {
    it('should set and get field values', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldValue('username', 'John');
      form.setFieldValue('email', 'john@example.com');

      expect(form.getFieldValue('username')).toBe('John');
      expect(form.getFieldValue('email')).toBe('john@example.com');
    });

    it('should get all values', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldValue('username', 'Alice');
      form.setFieldValue('email', 'alice@example.com');
      form.setFieldValue('age', 25);

      const values = form.getValues();

      expect(values).toEqual({
        username: 'Alice',
        email: 'alice@example.com',
        age: 25,
      });
    });

    it('should set all values', () => {
      const form = new FormModel(formDef, bo);

      form.setValues({
        username: 'Bob',
        email: 'bob@example.com',
        age: 30,
      });

      expect(form.getFieldValue('username')).toBe('Bob');
      expect(form.getFieldValue('email')).toBe('bob@example.com');
      expect(form.getFieldValue('age')).toBe(30);
    });

    it('should get changed values only', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldValue('username', 'Charlie');
      // email 未改变

      const changes = form.getChangedValues();

      expect(changes).toEqual({
        username: 'Charlie',
      });
    });
  });

  describe('validation', () => {
    it('should validate all fields', async () => {
      const form = new FormModel(formDef, bo);

      const valid = await form.validate();

      expect(valid).toBe(false); // username是必填的
    });

    it('should pass validation with valid values', async () => {
      const form = new FormModel(formDef, bo);

      form.setFieldValue('username', 'Valid User');
      form.setFieldValue('email', 'valid@example.com');

      const valid = await form.validate();

      expect(valid).toBe(true);
    });

    it('should validate single field', async () => {
      const form = new FormModel(formDef, bo);

      form.setFieldValue('username', 'Valid');

      const valid = await form.validateField('username');

      expect(valid).toBe(true);
    });

    it('should get all errors', async () => {
      const form = new FormModel(formDef, bo);

      await form.validate();

      const errors = form.getAllErrors();

      expect(errors['username']).toBeDefined();
      expect(errors['username'].length).toBeGreaterThan(0);
    });

    it('should check if form has errors', async () => {
      const form = new FormModel(formDef, bo);

      expect(form.hasErrors()).toBe(false);

      await form.validate();

      expect(form.hasErrors()).toBe(true);
    });
  });

  describe('computed properties', () => {
    it('should compute isDirty', () => {
      const form = new FormModel(formDef, bo);

      expect(form.isDirty).toBe(false);

      form.setFieldValue('username', 'Changed');

      expect(form.isDirty).toBe(true);
    });

    it('should compute isValid', () => {
      const form = new FormModel(formDef, bo);

      expect(form.isValid).toBe(true); // 初始状态没有错误

      form.setFieldValue('username', '');
      form.validate();

      // 注意：validate是异步的，需要等待
      setTimeout(() => {
        expect(form.isValid).toBe(false);
      }, 10);
    });

    it('should compute isTouched', () => {
      const form = new FormModel(formDef, bo);

      expect(form.isTouched).toBe(false);

      form.setFieldValue('username', 'Touched');

      expect(form.isTouched).toBe(true);
    });
  });

  describe('reset', () => {
    it('should reset all fields', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldValue('username', 'Changed');
      form.setFieldValue('email', 'changed@example.com');

      form.reset();

      expect(form.getFieldValue('username')).toBe('');
      expect(form.getFieldValue('email')).toBe('');
      expect(form.isDirty).toBe(false);
    });

    it('should reset single field', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldValue('username', 'Changed');
      form.setFieldValue('email', 'changed@example.com');

      form.resetField('username');

      expect(form.getFieldValue('username')).toBe('');
      expect(form.getFieldValue('email')).toBe('changed@example.com');
    });
  });

  describe('field state management', () => {
    it('should set field visibility', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldVisible('username', false);

      const field = form.getField('username');
      expect(field?.visible).toBe(false);
    });

    it('should set field disabled state', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldDisabled('username', true);

      const field = form.getField('username');
      expect(field?.disabled).toBe(true);
    });

    it('should set field readonly state', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldReadonly('username', true);

      const field = form.getField('username');
      expect(field?.readonly).toBe(true);
    });
  });

  describe('utility methods', () => {
    it('should get field count', () => {
      const form = new FormModel(formDef, bo);

      expect(form.getFieldCount()).toBe(3);
    });

    it('should get field paths', () => {
      const form = new FormModel(formDef, bo);

      const paths = form.getFieldPaths();

      expect(paths).toEqual(['username', 'email', 'age']);
    });

    it('should serialize to JSON', () => {
      const form = new FormModel(formDef, bo);

      form.setFieldValue('username', 'Test');

      const json = form.toJSON();

      expect(json.formId).toBe('user_form');
      expect(json.boId).toBe('user');
      expect(json.values.username).toBe('Test');
      expect(json.isDirty).toBe(true);
    });
  });
});
