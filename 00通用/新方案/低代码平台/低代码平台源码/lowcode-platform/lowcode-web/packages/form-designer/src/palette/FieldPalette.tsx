import React from 'react';
import { ELEMENT_LABELS, type ElementType } from '@lowcode/shared';

const BO_FIELDS: { fieldId: string; label: string; bo: string }[] = [
  { fieldId: 'customerId', label: '客户', bo: 'SalesOrder.header' },
  { fieldId: 'orgId', label: '销售组织', bo: 'SalesOrder.header' },
  { fieldId: 'billDate', label: '单据日期', bo: 'SalesOrder.header' },
  { fieldId: 'billNo', label: '单据编号', bo: 'SalesOrder.header' },
  { fieldId: 'status', label: '单据状态', bo: 'SalesOrder.header' },
  { fieldId: 'salesmanId', label: '业务员', bo: 'SalesOrder.header' },
  { fieldId: 'currencyId', label: '币种', bo: 'SalesOrder.header' },
  { fieldId: 'exchangeRate', label: '汇率', bo: 'SalesOrder.header' },
  { fieldId: 'materialId', label: '物料', bo: 'SalesOrder.entry' },
  { fieldId: 'qty', label: '数量', bo: 'SalesOrder.entry' },
  { fieldId: 'price', label: '单价', bo: 'SalesOrder.entry' },
  { id: 'amount', label: '金额', bo: 'SalesOrder.entry' } as unknown as { fieldId: string; label: string; bo: string },
  { fieldId: 'deliveryDate', label: '交付日期', bo: 'SalesOrder.entry' },
  { fieldId: 'discountRate', label: '折扣率', bo: 'SalesOrder.entry' },
];

export function FieldPalette({ search }: { search: string }) {
  const fields = BO_FIELDS.filter(f =>
    !search || f.label.includes(search) || f.fieldId.includes(search)
  );

  const headerFields = fields.filter(f => f.bo === 'SalesOrder.header');
  const entryFields = fields.filter(f => f.bo === 'SalesOrder.entry');

  const renderGroup = (title: string, groupFields: typeof fields) => (
    <div style={{ marginBottom: 6 }}>
      <div style={{
        height: 20, display: 'flex', alignItems: 'center', padding: '0 6px',
        background: '#F5F7FA', border: '1px solid #D8DEE8', borderBottom: 0,
        fontSize: 10, fontWeight: 700, color: '#66758A',
      }}>{title}</div>
      <div style={{ border: '1px solid #D8DEE8' }}>
        {groupFields.map(f => (
          <div
            key={f.fieldId}
            draggable
            onDragStart={e => {
              e.dataTransfer.setData('text/plain', f.fieldId);
            }}
            style={{
              display: 'grid', gridTemplateColumns: '16px minmax(0, 1fr) auto',
              alignItems: 'center', gap: 4, padding: '0 6px',
              height: 24, borderBottom: '1px solid #edf2f7',
              fontSize: 10, color: '#334155', cursor: 'grab',
            }}
          >
            <div style={{
              width: 15, height: 15, display: 'grid', placeItems: 'center',
              border: '1px solid #A7B4C5', borderRadius: 2, background: '#fff',
              color: '#526174', fontSize: 9, fontWeight: 700,
            }}>{f.label.charAt(0)}</div>
            <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{f.label}</span>
            <span style={{ color: '#94A3B8', fontSize: 9 }}>ref</span>
          </div>
        ))}
      </div>
    </div>
  );

  return (
    <div>
      {renderGroup('主表字段', headerFields)}
      {renderGroup('分录字段', entryFields)}
    </div>
  );
}
