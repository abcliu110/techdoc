/**
 * 业务对象定义
 */
export interface BusinessObject {
  boId: string;
  boName: string;
  boType: 'entity' | 'view';
  version: string;

  entity: EntityDefinition;
  fields: BOField[];
  relations: BORelation[];
  rules: BusinessRule[];
  permissions?: PermissionRule[];
}

export interface BOField {
  fieldId: string;
  fieldName: string;
  fieldType: 'string' | 'number' | 'date' | 'boolean' | 'reference' | 'calculated';
  dataType: string;
  length?: number;
  precision?: number;
  required: boolean;
  unique: boolean;
  defaultValue?: any;
  formula?: string;
  refBO?: string;
  refField?: string;
  validations?: ValidationRule[];
}

export interface BORelation {
  relationId: string;
  relationType: 'one-to-one' | 'one-to-many' | 'many-to-many';
  sourceBO: string;
  targetBO: string;
  sourceField: string;
  targetField: string;
  cascadeDelete?: boolean;
}

export interface BusinessRule {
  ruleId: string;
  ruleName: string;
  ruleType: 'before-save' | 'after-save' | 'before-delete' | 'computed';
  condition?: string;
  action: string;
}

export interface EntityDefinition {
  tableName: string;
  primaryKey: string;
  displayField: string;
}

export interface ValidationRule {
  type: 'required' | 'range' | 'pattern' | 'custom';
  message: string;
  min?: number;
  max?: number;
  pattern?: string;
  validator?: (value: any, formData: any) => boolean | string;
}

export interface PermissionRule {
  roleId: string;
  permissions: ('read' | 'write' | 'delete')[];
}
