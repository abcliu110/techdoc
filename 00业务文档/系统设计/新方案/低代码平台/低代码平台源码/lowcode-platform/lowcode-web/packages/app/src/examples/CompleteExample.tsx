import React from 'react';
import { FormModel, BusinessObject, FormDefinition } from '@lowcode/form-core';
import { FormRenderer } from '@lowcode/form-renderer';
import { FormDesigner } from '@lowcode/form-designer';

/**
 * 完整示例：销售订单表单
 */

// 1. 定义业务对象
const SalesOrderBO: BusinessObject = {
  boId: 'sales_order',
  boName: '销售订单',
  boType: 'entity',
  version: '1.0',
  entity: {
    tableName: 't_sales_order',
    primaryKey: 'order_id',
    displayField: 'order_no',
  },
  fields: [
    {
      fieldId: 'order_no',
      fieldName: '订单号',
      fieldType: 'string',
      dataType: 'varchar',
      length: 50,
      required: true,
      unique: true,
      defaultValue: '',
    },
    {
      fieldId: 'order_date',
      fieldName: '订单日期',
      fieldType: 'date',
      dataType: 'date',
      required: true,
      unique: false,
      defaultValue: '${TODAY()}',
    },
    {
      fieldId: 'customer_id',
      fieldName: '客户',
      fieldType: 'reference',
      dataType: 'bigint',
      required: true,
      unique: false,
      refBO: 'customer',
      refField: 'customer_id',
    },
    {
      fieldId: 'total_amount',
      fieldName: '订单总额',
      fieldType: 'calculated',
      dataType: 'decimal',
      precision: 2,
      required: false,
      unique: false,
      formula: '${SUM(items.*.amount)}',
    },
    {
      fieldId: 'items',
      fieldName: '订单明细',
      fieldType: 'reference',
      dataType: 'json',
      required: false,
      unique: false,
    },
  ],
  relations: [
    {
      relationId: 'order_items',
      relationType: 'one-to-many',
      sourceBO: 'sales_order',
      targetBO: 'order_item',
      sourceField: 'order_id',
      targetField: 'order_id',
      cascadeDelete: true,
    },
  ],
  rules: [],
};

// 2. 定义表单
const SalesOrderForm: FormDefinition = {
  formId: 'sales_order_form',
  formName: '销售订单表单',
  boId: 'sales_order',
  formType: 'edit',
  version: '1.0',
  layout: {
    type: 'horizontal',
    labelAlign: 'right',
    labelCol: { span: 6 },
    wrapperCol: { span: 18 },
  },
  fields: [
    {
      fieldId: 'order_no',
      boField: 'order_no',
      componentType: 'input',
      label: '订单号',
      placeholder: '请输入订单号',
    },
    {
      fieldId: 'order_date',
      boField: 'order_date',
      componentType: 'datePicker',
      label: '订单日期',
    },
    {
      fieldId: 'customer_id',
      boField: 'customer_id',
      componentType: 'select',
      label: '客户',
      componentProps: {
        options: [
          { label: '客户A', value: 1 },
          { label: '客户B', value: 2 },
        ],
      },
    },
    {
      fieldId: 'total_amount',
      boField: 'total_amount',
      componentType: 'inputNumber',
      label: '订单总额',
      disabled: true,
    },
    {
      fieldId: 'items',
      boField: 'items',
      componentType: 'subTable',
      label: '订单明细',
      componentProps: {
        subTable: {
          defaultRowCount: 1,
          columns: [
            { fieldId: 'product', label: '产品', componentType: 'input' },
            { fieldId: 'qty', label: '数量', componentType: 'inputNumber' },
            { fieldId: 'price', label: '单价', componentType: 'inputNumber' },
            { fieldId: 'amount', label: '金额', componentType: 'inputNumber', disabled: true },
          ],
        },
      },
    },
  ],
};

// 3. 使用示例

// 渲染器示例
export const RendererExample: React.FC = () => {
  const formModel = new FormModel(SalesOrderForm, SalesOrderBO);

  const handleSubmit = async (values: any) => {
    console.log('提交数据:', values);
    // 调用API保存
  };

  return (
    <div style={{ padding: '24px', maxWidth: '800px' }}>
      <h2>表单渲染器示例</h2>
      <FormRenderer
        formModel={formModel}
        mode="edit"
        onSubmit={handleSubmit}
      />
    </div>
  );
};

// 设计器示例
export const DesignerExample: React.FC = () => {
  const handleSave = (formDef: FormDefinition) => {
    console.log('保存表单定义:', formDef);
    // 调用API保存
  };

  return (
    <div style={{ height: '100vh' }}>
      <h2 style={{ padding: '16px' }}>表单设计器示例</h2>
      <FormDesigner
        bo={SalesOrderBO}
        initialForm={SalesOrderForm}
        onSave={handleSave}
      />
    </div>
  );
};

// 完整应用示例
export const CompleteExample: React.FC = () => {
  const [mode, setMode] = React.useState<'renderer' | 'designer'>('renderer');

  return (
    <div>
      <div style={{ padding: '16px', background: '#f0f0f0' }}>
        <button onClick={() => setMode('renderer')}>渲染器模式</button>
        <button onClick={() => setMode('designer')} style={{ marginLeft: '8px' }}>
          设计器模式
        </button>
      </div>

      {mode === 'renderer' ? <RendererExample /> : <DesignerExample />}
    </div>
  );
};

export default CompleteExample;
