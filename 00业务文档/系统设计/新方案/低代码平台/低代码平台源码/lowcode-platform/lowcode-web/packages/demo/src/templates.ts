/**
 * 表单模板库
 * 提供常用业务场景的表单模板
 */

export interface FormTemplate {
  id: string;
  name: string;
  description: string;
  category: string;
  icon: string;
  fields: any[];
}

export const FORM_TEMPLATES: FormTemplate[] = [
  {
    id: 'sales_order',
    name: '销售订单表单',
    description: '包含客户信息、订单明细、金额计算的完整销售订单',
    category: '业务表单',
    icon: '📦',
    fields: [
      {
        id: 'order_no',
        fieldId: 'order_no',
        label: '订单号',
        type: 'input',
        placeholder: 'SO-YYYYMMDD-XXX',
        required: true,
        boField: 'order_no',
        helpText: '系统自动生成或手动输入',
      },
      {
        id: 'order_date',
        fieldId: 'order_date',
        label: '订单日期',
        type: 'datePicker',
        required: true,
        boField: 'order_date',
        defaultValue: '${TODAY()}',
      },
      {
        id: 'customer_name',
        fieldId: 'customer_name',
        label: '客户名称',
        type: 'select',
        placeholder: '请选择客户',
        required: true,
        boField: 'customer_name',
      },
      {
        id: 'customer_phone',
        fieldId: 'customer_phone',
        label: '客户电话',
        type: 'input',
        placeholder: '请输入电话号码',
        pattern: '^1[3-9]\\d{9}$',
        errorMessage: '请输入正确的手机号码',
        boField: 'customer_phone',
      },
      {
        id: 'customer_address',
        fieldId: 'customer_address',
        label: '收货地址',
        type: 'textarea',
        placeholder: '请输入详细地址',
        required: true,
        boField: 'customer_address',
      },
      {
        id: 'items',
        fieldId: 'items',
        label: '订单明细',
        type: 'subTable',
        required: true,
        boField: 'items',
        helpText: '至少添加一条明细',
      },
      {
        id: 'total_amount',
        fieldId: 'total_amount',
        label: '订单总额',
        type: 'inputNumber',
        disabled: true,
        boField: 'total_amount',
        formula: '${SUM(items.*.amount)}',
        helpText: '自动计算：明细金额之和',
      },
      {
        id: 'remark',
        fieldId: 'remark',
        label: '备注',
        type: 'textarea',
        placeholder: '请输入备注信息',
        boField: 'remark',
        maxLength: 500,
      },
    ],
  },
  {
    id: 'employee_onboard',
    name: '员工入职表单',
    description: '员工入职信息登记，包含个人信息、联系方式、附件上传',
    category: '人事表单',
    icon: '👤',
    fields: [
      {
        id: 'emp_name',
        fieldId: 'emp_name',
        label: '姓名',
        type: 'input',
        required: true,
        placeholder: '请输入姓名',
      },
      {
        id: 'emp_id_card',
        fieldId: 'emp_id_card',
        label: '身份证号',
        type: 'input',
        required: true,
        pattern: '^\\d{17}[\\dXx]$',
        errorMessage: '请输入正确的身份证号',
      },
      {
        id: 'emp_phone',
        fieldId: 'emp_phone',
        label: '手机号',
        type: 'input',
        required: true,
        pattern: '^1[3-9]\\d{9}$',
        errorMessage: '请输入正确的手机号',
      },
      {
        id: 'emp_email',
        fieldId: 'emp_email',
        label: '邮箱',
        type: 'input',
        required: true,
        pattern: '^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$',
        errorMessage: '请输入正确的邮箱地址',
      },
      {
        id: 'onboard_date',
        fieldId: 'onboard_date',
        label: '入职日期',
        type: 'datePicker',
        required: true,
        defaultValue: '${TODAY()}',
      },
      {
        id: 'department',
        fieldId: 'department',
        label: '部门',
        type: 'select',
        required: true,
      },
      {
        id: 'position',
        fieldId: 'position',
        label: '职位',
        type: 'select',
        required: true,
      },
      {
        id: 'attachments',
        fieldId: 'attachments',
        label: '附件上传',
        type: 'upload',
        helpText: '请上传简历、学历证明等',
      },
    ],
  },
  {
    id: 'leave_request',
    name: '请假申请表单',
    description: '员工请假申请，包含请假类型、时间范围、审批流程',
    category: '流程表单',
    icon: '📝',
    fields: [
      {
        id: 'leave_type',
        fieldId: 'leave_type',
        label: '请假类型',
        type: 'select',
        required: true,
      },
      {
        id: 'start_date',
        fieldId: 'start_date',
        label: '开始日期',
        type: 'datePicker',
        required: true,
      },
      {
        id: 'end_date',
        fieldId: 'end_date',
        label: '结束日期',
        type: 'datePicker',
        required: true,
      },
      {
        id: 'days',
        fieldId: 'days',
        label: '请假天数',
        type: 'inputNumber',
        disabled: true,
        formula: '${DAYS_BETWEEN(start_date, end_date)}',
      },
      {
        id: 'reason',
        fieldId: 'reason',
        label: '请假事由',
        type: 'textarea',
        required: true,
        minLength: 10,
        maxLength: 200,
      },
    ],
  },
];

export const getTemplateById = (id: string): FormTemplate | undefined => {
  return FORM_TEMPLATES.find(t => t.id === id);
};

export const getTemplatesByCategory = (category: string): FormTemplate[] => {
  return FORM_TEMPLATES.filter(t => t.category === category);
};
