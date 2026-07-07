import React from 'react';
import { observer } from 'mobx-react-lite';
import { FormModel } from '@lowcode/form-core';
import { Form } from 'antd';
import { FieldRenderer } from './FieldRenderer';

export interface FormRendererProps {
  formModel: FormModel;
  mode?: 'edit' | 'view' | 'create';
  onSubmit?: (values: any) => void | Promise<void>;
  onCancel?: () => void;
}

/**
 * 表单渲染器
 * 基于Form Model渲染完整表单
 */
export const FormRenderer: React.FC<FormRendererProps> = observer(({
  formModel,
  mode = 'edit',
  onSubmit,
  onCancel,
}) => {
  const [form] = Form.useForm();

  const handleSubmit = async () => {
    const valid = await formModel.validate();
    if (valid) {
      const values = formModel.getValues();
      await onSubmit?.(values);
    }
  };

  const handleValuesChange = (changedValues: any, allValues: any) => {
    // 同步到FormModel
    Object.keys(changedValues).forEach(fieldId => {
      formModel.setFieldValue(fieldId, changedValues[fieldId]);
    });
  };

  return (
    <Form
      form={form}
      layout="horizontal"
      onFinish={handleSubmit}
      onValuesChange={handleValuesChange}
    >
      {Array.from(formModel.fields.values()).map(field => (
        <FieldRenderer
          key={field.fieldId}
          field={field}
          mode={mode}
        />
      ))}

      {mode !== 'view' && (
        <Form.Item>
          <button type="submit">提交</button>
          {onCancel && (
            <button type="button" onClick={onCancel}>取消</button>
          )}
        </Form.Item>
      )}
    </Form>
  );
});
