import type { ValidationRule } from './bo';

/**
 * 表单定义
 */
export interface FormDefinition {
  formId: string;
  formName: string;
  boId: string;
  formType: 'create' | 'edit' | 'view' | 'query';
  version: string;

  layout: FormLayout;
  fields: FormField[];
  toolbar?: ToolbarConfig;
  permissions?: FormPermission;
}

export interface FormField {
  fieldId: string;
  boField: string;
  componentType: string;

  label?: string;
  placeholder?: string;
  helpText?: string;

  componentProps?: Record<string, any>;

  visible?: boolean | string;
  disabled?: boolean | string;
  readonly?: boolean | string;

  validations?: ValidationRule[];
  reactions?: Reaction[];
}

export interface FormLayout {
  type: 'horizontal' | 'vertical' | 'inline' | 'grid';
  columns?: number;
  gutter?: number;
  labelAlign?: 'left' | 'right';
  labelCol?: { span: number };
  wrapperCol?: { span: number };
}

export interface Reaction {
  condition?: string;
  target: string;
  action: 'set-value' | 'set-visible' | 'set-disabled' | 'set-options';
  value?: any;
}

export interface ToolbarConfig {
  buttons: ToolbarButton[];
}

export interface ToolbarButton {
  id: string;
  label: string;
  type: 'primary' | 'default' | 'dashed' | 'link';
  action: string;
  visible?: string;
}

export interface FormPermission {
  roleId: string;
  fieldPermissions: Record<string, 'readonly' | 'hidden'>;
}
