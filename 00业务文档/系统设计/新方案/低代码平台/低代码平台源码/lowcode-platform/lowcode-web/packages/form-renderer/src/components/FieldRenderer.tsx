import React from 'react';
import { observer } from 'mobx-react-lite';
import { FieldModel } from '@lowcode/form-core';
import { Form, Input, InputNumber, Select, DatePicker, Checkbox, Radio } from 'antd';

export interface FieldRendererProps {
  field: FieldModel;
  mode?: 'edit' | 'view' | 'create';
}

/**
 * 字段渲染器
 * 根据字段类型渲染对应的UI组件
 */
export const FieldRenderer: React.FC<FieldRendererProps> = observer(({
  field,
  mode = 'edit',
}) => {
  if (!field.visible) return null;

  const isReadonly = mode === 'view' || field.readonly;
  const isDisabled = field.disabled;

  const renderComponent = () => {
    const componentType = field.definition.componentType;

    switch (componentType) {
      case 'input':
        return (
          <Input
            value={field.value}
            onChange={(e) => field.setValue(e.target.value)}
            disabled={isDisabled}
            readOnly={isReadonly}
            placeholder={field.definition.placeholder}
          />
        );

      case 'inputNumber':
        return (
          <InputNumber
            value={field.value}
            onChange={(val) => field.setValue(val)}
            disabled={isDisabled}
            readOnly={isReadonly}
          />
        );

      case 'select':
        return (
          <Select
            value={field.value}
            onChange={(val) => field.setValue(val)}
            disabled={isDisabled}
            options={field.definition.componentProps?.options || []}
          />
        );

      case 'datePicker':
        return (
          <DatePicker
            value={field.value}
            onChange={(date) => field.setValue(date)}
            disabled={isDisabled}
          />
        );

      case 'checkbox':
        return (
          <Checkbox
            checked={field.value}
            onChange={(e) => field.setValue(e.target.checked)}
            disabled={isDisabled}
          >
            {field.definition.label}
          </Checkbox>
        );

      case 'radio':
        return (
          <Radio.Group
            value={field.value}
            onChange={(e) => field.setValue(e.target.value)}
            disabled={isDisabled}
            options={field.definition.componentProps?.options || []}
          />
        );

      default:
        return <div>Unknown component: {componentType}</div>;
    }
  };

  return (
    <Form.Item
      label={field.definition.label}
      help={field.errors.length > 0 ? field.errors[0] : field.definition.helpText}
      validateStatus={field.errors.length > 0 ? 'error' : undefined}
      required={field.boField.required}
    >
      {renderComponent()}
    </Form.Item>
  );
});
