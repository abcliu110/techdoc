import React from 'react';
import { Form, Input, InputNumber, Select, DatePicker, Checkbox, Radio, Switch, Upload, Button } from 'antd';
import { PlusOutlined } from '@ant-design/icons';

export const FieldPreview: React.FC<{ field: any }> = ({ field }) => {
  const renderField = () => {
    const commonProps = {
      placeholder: field.placeholder || `请输入${field.label}`,
      disabled: field.disabled,
    };

    switch (field.type) {
      case 'input':
        return <Input {...commonProps} />;
      case 'inputNumber':
        return <InputNumber style={{ width: '100%' }} {...commonProps} />;
      case 'select':
        return (
          <Select {...commonProps}>
            <Select.Option value="1">选项1</Select.Option>
            <Select.Option value="2">选项2</Select.Option>
          </Select>
        );
      case 'datePicker':
        return <DatePicker style={{ width: '100%' }} {...commonProps} />;
      case 'checkbox':
        return <Checkbox>{field.label}</Checkbox>;
      case 'radio':
        return (
          <Radio.Group>
            <Radio value="1">选项1</Radio>
            <Radio value="2">选项2</Radio>
          </Radio.Group>
        );
      case 'switch':
        return <Switch />;
      case 'textarea':
        return <Input.TextArea rows={3} {...commonProps} />;
      case 'upload':
        return (
          <Upload>
            <Button icon={<PlusOutlined />}>点击上传</Button>
          </Upload>
        );
      case 'subTable':
        return (
          <div style={{ border: '1px dashed #d9d9d9', padding: '12px', borderRadius: '4px', background: '#fafafa' }}>
            <div style={{ marginBottom: '8px', color: '#666' }}>
              📋 子表组件（主子表关系）
            </div>
            <Button size="small" type="dashed" icon={<PlusOutlined />}>
              添加行
            </Button>
          </div>
        );
      default:
        return <Input {...commonProps} />;
    }
  };

  return (
    <Form.Item
      label={field.label}
      required={field.required}
      help={field.helpText}
    >
      {renderField()}
    </Form.Item>
  );
};
