import React from 'react';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';

const severityColors: Record<string, string> = {
  error: '#B91C1C',
  warning: '#B45309',
  info: '#2563EB',
};

export const BottomBar = observer(() => {
  const { problems, selectedNode, formDef } = store;
  const errorCount = problems.filter(p => p.severity === 'error').length;
  const warnCount = problems.filter(p => p.severity === 'warning').length;

  return (
    <div style={{
      display: 'grid',
      gridTemplateColumns: 'minmax(0, 1fr) 220px',
      background: '#fff',
      borderTop: '1px solid #D8DEE8',
      fontSize: 10,
      overflow: 'hidden',
    }}>
      {/* 错误列表 */}
      <div style={{ display: 'grid', gridTemplateRows: '22px minmax(0, 1fr)', borderRight: '1px solid #D8DEE8', overflow: 'hidden' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '0 8px', background: '#EEF2F7', borderBottom: '1px solid #D8DEE8' }}>
          <span style={{ fontWeight: 700, color: '#66758A' }}>错误列表 / 设计分析器</span>
          {errorCount > 0 && (
            <span style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', minWidth: 16, height: 14, padding: '0 4px', borderRadius: 7, fontSize: 9, background: '#fef2f2', color: '#B91C1C' }}>
              {errorCount}
            </span>
          )}
          {warnCount > 0 && (
            <span style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', minWidth: 16, height: 14, padding: '0 4px', borderRadius: 7, fontSize: 9, background: '#fffbeb', color: '#B45309' }}>
              {warnCount}
            </span>
          )}
        </div>
        <div style={{ overflow: 'auto' }}>
          {problems.map(p => (
            <div
              key={p.id}
              style={{
                display: 'grid', gridTemplateColumns: '50px 60px minmax(0, 1fr) 80px',
                alignItems: 'center', padding: '0 7px', gap: 5,
                height: 20, borderBottom: '1px solid #edf2f7', color: '#66758A',
                cursor: 'pointer',
              }}
            >
              <span style={{ fontWeight: 700, color: severityColors[p.severity] }}>{p.severity}</span>
              <span style={{ fontFamily: 'Consolas, monospace', fontSize: 9 }}>{p.code}</span>
              <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{p.message}</span>
              <span style={{ color: '#94A3B8', fontSize: 9 }}>{p.category}</span>
            </div>
          ))}
          {problems.length === 0 && (
            <div style={{ padding: '6px 8px', color: '#94A3B8' }}>暂无问题</div>
          )}
        </div>
      </div>

      {/* Schema 预览 */}
      <div style={{ overflow: 'auto', padding: 5, fontFamily: 'Consolas, "Courier New", monospace', fontSize: 9, lineHeight: 1.5, color: '#66758A', background: '#FAFCFE', whiteSpace: 'pre' }}>
        {JSON.stringify(formDef.schema, null, 2).substring(0, 800)}
      </div>
    </div>
  );
});
