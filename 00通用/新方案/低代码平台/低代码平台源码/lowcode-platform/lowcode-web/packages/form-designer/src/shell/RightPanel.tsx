import React from 'react';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';
import { PropertyInspector } from '../inspector/PropertyInspector';
import { LayoutInspector } from '../inspector/LayoutInspector';
import { RuleInspector } from '../inspector/RuleInspector';

export const RightPanel = observer(() => {
  const { rightTab, selectedNode } = store;

  return (
    <aside style={{
      background: '#fff',
      borderLeft: '1px solid #D8DEE8',
      display: 'grid',
      gridTemplateRows: '27px minmax(0, 1fr)',
      overflow: 'hidden',
    }}>
      {/* Tab 栏 */}
      <div style={{ display: 'flex', alignItems: 'end', gap: 1, padding: '0 5px', background: '#EEF2F7', borderBottom: '1px solid #D8DEE8' }}>
        {(['property', 'layout', 'rule'] as const).map(tab => (
          <button
            key={tab}
            onClick={() => store.setRightTab(tab)}
            style={{
              height: 23, padding: '0 8px', border: '1px solid transparent', borderBottom: 0,
              borderRadius: '3px 3px 0 0', fontSize: 10, cursor: 'pointer',
              background: rightTab === tab ? '#fff' : 'transparent',
              color: rightTab === tab ? '#2563EB' : '#66758A',
              fontWeight: rightTab === tab ? 700 : 400,
            }}
          >
            {tab === 'property' ? '属性' : tab === 'layout' ? '布局' : '规则'}
          </button>
        ))}
      </div>

      {/* 面板内容 */}
      <div style={{ minHeight: 0, overflow: 'auto', padding: 6 }}>
        {rightTab === 'property' && <PropertyInspector />}
        {rightTab === 'layout' && <LayoutInspector />}
        {rightTab === 'rule' && <RuleInspector />}
      </div>
    </aside>
  );
});
