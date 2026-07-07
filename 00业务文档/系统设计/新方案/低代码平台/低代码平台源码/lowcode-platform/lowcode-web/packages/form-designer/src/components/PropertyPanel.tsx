import React from 'react';
import { FormDefinition, BusinessObject } from '@lowcode/form-core';
import { Form, Input, Select } from 'antd';

export interface PropertyPanelProps {
  selectedFieldId: string | null;
  formDef: FormDefinition;
  bo: BusinessObject;
  onFieldUpdate: (fieldId: string, updates: any) => void;
}

export const PropertyPanel: React.FC<PropertyPanelProps> = ({
  selectedFieldId,
  formDef,
  bo,
  onFieldUpdate,
}) => {
  if (!selectedFieldId) {
    return (
      <div style={{ padding: '16px' }}>
        <h3>属性面板</h3>
        <p style={{ color: '#999' }}>请选择一个字段</p>
      </div>
    );
  }

  const field = formDef.fields.find(f => f.fieldId === selectedFieldId);
  if (!field) return null;

  return (
    <div style={{ padding: '16px' }}>
      <h3>字段属性</h3>
      <Form layout="vertical">
        <Form.Item label="字段标签">
          <Input
            value={field.label}
            onChange={e => onFieldUpdate(selectedFieldId, { label: e.target.value })}
          />
        </Form.Item>

        <Form.Item label="绑定BO字段">
          <Select
            value={field.boField}
            onChange={val => onFieldUpdate(selectedFieldId, { boField: val })}
          >
            {bo.fields.map(f => (
              <Select.Option key={f.fieldId} value={f.fieldId}>
                {f.fieldName}
              </Select.Option>
            ))}
          </Select>
        </Form.Item>

        <Form.Item label="占位符">
          <Input
            value={field.placeholder}
            onChange={e => onFieldUpdate(selectedFieldId, { placeholder: e.target.value })}
          />
        </Form.Item>
      </Form>
    </div>
  );
};
