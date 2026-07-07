import { makeObservable, observable, action, computed } from 'mobx';
import type { FormField, BOField, ValidationRule } from '../types';

export class FieldModel {
  fieldId: string;
  boFieldId: string;

  @observable accessor value: any;
  @observable accessor initialValue: any;
  @observable accessor errors: string[] = [];

  @observable accessor visible: boolean = true;
  @observable accessor disabled: boolean = false;
  @observable accessor readonly: boolean = false;
  @observable accessor touched: boolean = false;

  definition: FormField;
  boField: BOField;
  formModel: any; // FormModel类型，避免循环依赖

  constructor(definition: FormField, boField: BOField, formModel: any) {
    this.fieldId = definition.fieldId;
    this.boFieldId = definition.boField;
    this.definition = definition;
    this.boField = boField;
    this.formModel = formModel;

    // 初始化默认值
    this.initialValue = boField.defaultValue;
    this.value = this.initialValue;

    makeObservable(this);
  }

  @computed
  get dirty(): boolean {
    return this.value !== this.initialValue;
  }

  @computed
  get valid(): boolean {
    return this.errors.length === 0;
  }

  @action
  setValue(value: any, options?: { silent?: boolean }): void {
    const oldValue = this.value;
    this.value = value;
    this.touched = true;

    if (!options?.silent) {
      // 通知FormModel字段变化
      this.formModel?.notifyFieldChange?.(this.fieldId, oldValue, value);
    }

    // 清除之前的错误
    this.errors = [];
  }

  getValue(): any {
    return this.value;
  }

  @action
  async validate(): Promise<boolean> {
    this.errors = [];

    const formData = this.formModel?.getValues?.() || {};

    // BO级校验
    if (this.boField.validations) {
      for (const rule of this.boField.validations) {
        const result = await this.executeValidationRule(rule, formData);
        if (result !== true) {
          this.errors.push(result as string);
        }
      }
    }

    // Form级校验
    if (this.definition.validations) {
      for (const rule of this.definition.validations) {
        const result = await this.executeValidationRule(rule, formData);
        if (result !== true) {
          this.errors.push(result as string);
        }
      }
    }

    return this.errors.length === 0;
  }

  private async executeValidationRule(
    rule: ValidationRule,
    formData: any
  ): Promise<boolean | string> {
    switch (rule.type) {
      case 'required':
        if (this.value === null || this.value === undefined || this.value === '') {
          return rule.message || '此字段为必填项';
        }
        break;

      case 'range':
        const numValue = Number(this.value);
        if (rule.min !== undefined && numValue < rule.min) {
          return rule.message || `值不能小于${rule.min}`;
        }
        if (rule.max !== undefined && numValue > rule.max) {
          return rule.message || `值不能大于${rule.max}`;
        }
        break;

      case 'pattern':
        if (rule.pattern && !new RegExp(rule.pattern).test(String(this.value))) {
          return rule.message || '格式不正确';
        }
        break;

      case 'custom':
        if (rule.validator) {
          const result = rule.validator(this.value, formData);
          if (result !== true) {
            return typeof result === 'string' ? result : rule.message || '校验失败';
          }
        }
        break;
    }

    return true;
  }

  @action
  reset(): void {
    this.value = this.initialValue;
    this.errors = [];
    this.touched = false;
  }

  @action
  setVisible(visible: boolean): void {
    this.visible = visible;
  }

  @action
  setDisabled(disabled: boolean): void {
    this.disabled = disabled;
  }

  @action
  setReadonly(readonly: boolean): void {
    this.readonly = readonly;
  }

  @action
  setErrors(errors: string[]): void {
    this.errors = errors;
  }

  @action
  clearErrors(): void {
    this.errors = [];
  }
}
