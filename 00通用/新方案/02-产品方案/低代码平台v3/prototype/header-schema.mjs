const HEADER_FIELDS = Object.freeze([
  ['orderNo', 'TextField', '订单编码', 'SalesOrder.orderNo', true, true, '系统按编码规则自动生成'],
  ['customer', 'ReferencePicker', '客户', 'SalesOrder.customerId', true, false, '选择已启用的客户档案'],
  ['orderDate', 'Date', '订单日期', 'SalesOrder.orderDate', true, false, '默认使用当前业务日期'],
  ['salesOrg', 'OrganizationPicker', '销售组织', 'SalesOrder.salesOrgId', false, false, '受当前用户组织权限约束'],
  ['amount', 'MoneyField', '含税金额', 'SalesOrder.totalAmount', false, true, '由分录价税合计汇总'],
]);

function createFieldNode([id, type, title, path, required, readonly, help]) {
  return {
    id,
    type,
    parentId: 'header-fields',
    children: [],
    props: {
      title,
      code: id,
      required,
      readonly,
      showLabel: true,
      width: '1/3',
      help,
    },
    binding: {
      entityId: 'sales-order',
      fieldId: id,
      path,
    },
  };
}

export function createSalesOrderDesignerSchema() {
  const fields = HEADER_FIELDS.map(createFieldNode);
  return {
    version: 1,
    pageType: 'bill',
    rootId: 'page',
    nodes: {
      page: {
        id: 'page',
        type: 'FormPage',
        parentId: null,
        children: ['header-fields', 'entries'],
        props: { title: '销售订单' },
      },
      'header-fields': {
        id: 'header-fields',
        type: 'FieldLayout',
        parentId: 'page',
        children: fields.map(({ id }) => id),
        props: { title: '基本信息', columns: 3 },
      },
      ...Object.fromEntries(fields.map((field) => [field.id, field])),
      entries: {
        id: 'entries',
        type: 'EntryGrid',
        parentId: 'page',
        children: [],
        props: {
          title: '销售订单分录',
          code: 'entries',
          required: true,
          readonly: false,
          width: 'full',
          help: '支持冻结列、批量录入和行列权限',
        },
        binding: {
          entityId: 'sales-order-entry',
          path: 'SalesOrder.entries',
        },
      },
    },
  };
}
