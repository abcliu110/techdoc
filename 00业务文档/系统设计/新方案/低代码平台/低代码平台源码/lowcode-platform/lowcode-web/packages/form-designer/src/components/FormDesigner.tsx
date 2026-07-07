import React, { useState } from 'react';
import { FormModel, BusinessObject, FormDefinition } from '@lowcode/form-core';
import { Layout } from 'antd';
import { ComponentPanel } from './ComponentPanel';
import { Canvas } from './Canvas';
import { PropertyPanel } from './PropertyPanel';

const { Sider, Content } = Layout;

export interface FormDesignerProps {
  bo: BusinessObject;
  initialForm?: FormDefinition;
  onSave?: (form: FormDefinition) => void;
}

/**
 * 表单设计器
 * 可视化表单设计工具
 */
export const FormDesigner: React.FC<FormDesignerProps> = ({
  bo,
  initialForm,
  onSave,
}) => {
  const [formDef, setFormDef] = useState<FormDefinition>(
    initialForm || {
      formId: 'new_form',
      formName: '新表单',
      boId: bo.boId,
      formType: 'edit',
      version: '1.0',
      layout: { type: 'horizontal' },
      fields: [],
    }
  );

  const [selectedFieldId, setSelectedFieldId] = useState<string | null>(null);

  const handleAddField = (fieldType: string) => {
    const newField = {
      fieldId: `field_${Date.now()}`,
      boField: '', // 需要绑定BO字段
      componentType: fieldType,
      label: '新字段',
    };

    setFormDef({
      ...formDef,
      fields: [...formDef.fields, newField],
    });
  };

  const handleFieldSelect = (fieldId: string) => {
    setSelectedFieldId(fieldId);
  };

  const handleFieldUpdate = (fieldId: string, updates: any) => {
    setFormDef({
      ...formDef,
      fields: formDef.fields.map(f =>
        f.fieldId === fieldId ? { ...f, ...updates } : f
      ),
    });
  };

  const handleSave = () => {
    onSave?.(formDef);
  };

  return (
    <Layout style={{ height: '100vh' }}>
      {/* 左侧组件面板 */}
      <Sider width={240} theme="light">
        <ComponentPanel onAddField={handleAddField} />
      </Sider>

      {/* 中间画布 */}
      <Content style={{ background: '#f0f0f0', padding: '20px' }}>
        <Canvas
          formDef={formDef}
          selectedFieldId={selectedFieldId}
          onFieldSelect={handleFieldSelect}
          onSave={handleSave}
        />
      </Content>

      {/* 右侧属性面板 */}
      <Sider width={300} theme="light">
        <PropertyPanel
          selectedFieldId={selectedFieldId}
          formDef={formDef}
          bo={bo}
          onFieldUpdate={handleFieldUpdate}
        />
      </Sider>
    </Layout>
  );
};
