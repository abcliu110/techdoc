import { makeObservable, observable, action, computed } from 'mobx';
import { EventEmitter } from 'events';
import { FieldModel } from './FieldModel';
import type { FormDefinition, BusinessObject } from '../types';

// 临时内联path工具，避免跨包依赖问题
function getIn(obj: any, path: string): any {
  if (!obj) return undefined;
  const keys = path.split('.');
  let current = obj;
  for (const key of keys) {
    if (current === null || current === undefined) return undefined;
    current = current[key];
  }
  return current;
}

function setIn(obj: any, path: string, value: any): void {
  if (!obj) return;
  const keys = path.split('.');
  const lastKey = keys[keys.length - 1];
  let current = obj;
  for (let i = 0; i < keys.length - 1; i++) {
    const key = keys[i];
    if (!(key in current)) {
      current[key] = {};
    }
    current = current[key];
  }
  current[lastKey] = value;
}

export class FormModel {
  formId: string;
  boId: string;

  @observable accessor fields: Map<string, FieldModel> = new Map();

  eventBus: EventEmitter;

  private definition: FormDefinition;
  private bo: BusinessObject;

  constructor(definition: FormDefinition, bo: BusinessObject) {
    this.formId = definition.formId;
    this.boId = definition.boId;
    this.definition = definition;
    this.bo = bo;
    this.eventBus = new EventEmitter();

    // 初始化字段
    this.initializeFields();

    makeObservable(this);
  }

  private initializeFields(): void {
    this.definition.fields.forEach(fieldDef => {
      const boField = this.bo.fields.find(f => f.fieldId === fieldDef.boField);
      if (boField) {
        const fieldModel = new FieldModel(fieldDef, boField, this);
        this.fields.set(fieldDef.fieldId, fieldModel);
      }
    });
  }

  getField(path: string): FieldModel | undefined {
    return this.fields.get(path);
  }

  @action
  setFieldValue(path: string, value: any): void {
    const field = this.getField(path);
    if (field) {
      field.setValue(value);
    }
  }

  getFieldValue(path: string): any {
    const field = this.getField(path);
    return field?.getValue();
  }

  getValues(): any {
    const values: any = {};
    this.fields.forEach((field, path) => {
      setIn(values, path, field.getValue());
    });
    return values;
  }

  @action
  setValues(values: any): void {
    this.fields.forEach((field, path) => {
      const value = getIn(values, path);
      if (value !== undefined) {
        field.setValue(value, { silent: true });
      }
    });
  }

  async validate(): Promise<boolean> {
    const results = await Promise.all(
      Array.from(this.fields.values()).map(field => field.validate())
    );
    return results.every(r => r);
  }

  async validateField(path: string): Promise<boolean> {
    const field = this.getField(path);
    if (field) {
      return await field.validate();
    }
    return true;
  }

  getAllErrors(): Record<string, string[]> {
    const errors: Record<string, string[]> = {};
    this.fields.forEach((field, path) => {
      if (field.errors.length > 0) {
        errors[path] = field.errors;
      }
    });
    return errors;
  }

  @action
  reset(): void {
    this.fields.forEach(field => field.reset());
  }

  @action
  resetField(path: string): void {
    const field = this.getField(path);
    if (field) {
      field.reset();
    }
  }

  @computed
  get isDirty(): boolean {
    return Array.from(this.fields.values()).some(f => f.dirty);
  }

  @computed
  get isValid(): boolean {
    return Array.from(this.fields.values()).every(f => f.valid);
  }

  @computed
  get isTouched(): boolean {
    return Array.from(this.fields.values()).some(f => f.touched);
  }

  getChangedValues(): any {
    const changes: any = {};
    this.fields.forEach((field, path) => {
      if (field.dirty) {
        setIn(changes, path, field.getValue());
      }
    });
    return changes;
  }

  notifyFieldChange(fieldId: string, oldValue: any, newValue: any): void {
    this.eventBus.emit('field:change', {
      fieldId,
      oldValue,
      newValue,
    });

    // 触发依赖字段的更新
    this.updateDependentFields(fieldId);
  }

  private updateDependentFields(changedFieldId: string): void {
    // TODO: 实现依赖追踪
    // 目前简化处理，后续Week 2-3实现完整的依赖追踪系统
  }

  @action
  clearErrors(): void {
    this.fields.forEach(field => field.clearErrors());
  }

  @action
  setFieldVisible(path: string, visible: boolean): void {
    const field = this.getField(path);
    if (field) {
      field.setVisible(visible);
    }
  }

  @action
  setFieldDisabled(path: string, disabled: boolean): void {
    const field = this.getField(path);
    if (field) {
      field.setDisabled(disabled);
    }
  }

  @action
  setFieldReadonly(path: string, readonly: boolean): void {
    const field = this.getField(path);
    if (field) {
      field.setReadonly(readonly);
    }
  }

  getFieldErrors(path: string): string[] {
    const field = this.getField(path);
    return field?.errors || [];
  }

  hasErrors(): boolean {
    return Array.from(this.fields.values()).some(f => f.errors.length > 0);
  }

  getFieldCount(): number {
    return this.fields.size;
  }

  getFieldPaths(): string[] {
    return Array.from(this.fields.keys());
  }

  toJSON(): any {
    return {
      formId: this.formId,
      boId: this.boId,
      values: this.getValues(),
      isDirty: this.isDirty,
      isValid: this.isValid,
      errors: this.getAllErrors(),
    };
  }
}
