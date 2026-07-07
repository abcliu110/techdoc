import React from 'react';
import { FormDefinition } from '@lowcode/form-core';
import { Card, Button } from 'antd';

export interface CanvasProps {
  formDef: FormDefinition;
  selectedFieldId: string | null;
  onFieldSelect: (fieldId: string) => void;
  onSave: () => void;
}

export const Canvas: React.FC<CanvasProps> = ({
  formDef,
  selectedFieldId,
  onFieldSelect,
  onSave,
}) => {
  return (
    <div>
      <div style={{ marginBottom: '16px', textAlign: 'right' }}>
        <Button type="primary" onClick={onSave}>保存表单</Button>
      </div>

      <Card title={formDef.formName} style={{ background: 'white' }}>
        {formDef.fields.length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: '#999' }}>
            从左侧拖入组件开始设计
          </div>
        ) : (
          formDef.fields.map(field => (
            <div
              key={field.fieldId}
              onClick={() => onFieldSelect(field.fieldId)}
              style={{
                padding: '12px',
                margin: '8px 0',
                border: selectedFieldId === field.fieldId ? '2px solid #1890ff' : '1px solid #d9d9d9',
                borderRadius: '4px',
                cursor: 'pointer',
              }}
            >
              <strong>{field.label || '未命名字段'}</strong>
              <span style={{ marginLeft: '8px', color: '#999' }}>
                ({field.componentType})
              </span>
            </div>
          ))
        )}
      </Card>
    </div>
  );
};
