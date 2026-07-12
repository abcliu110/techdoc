import React, { useState } from 'react';
import { Input, Tooltip } from 'antd';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';
import { ComponentPalette } from '../palette/ComponentPalette';
import { FieldPalette } from '../palette/FieldPalette';
import { OutlineTree } from '../palette/OutlineTree';
import { PALETTE_CATEGORIES, ELEMENT_LABELS, type ElementType } from '@lowcode/shared';

export const LeftPanel = observer(() => {
  const [search, setSearch] = useState('');
  const { leftTab } = store;

  return (
    <aside style={{
      background: '#fff',
      borderRight: '1px solid #D8DEE8',
      display: 'grid',
      gridTemplateRows: '27px minmax(0, 1fr)',
      overflow: 'hidden',
    }}>
      {/* Tab 栏 */}
      <div style={{ display: 'flex', alignItems: 'end', gap: 1, padding: '0 5px', background: '#EEF2F7', borderBottom: '1px solid #D8DEE8' }}>
        {(['palette', 'field', 'outline'] as const).map(tab => (
          <button
            key={tab}
            onClick={() => store.setLeftTab(tab)}
            style={{
              height: 23, padding: '0 8px', border: '1px solid transparent', borderBottom: 0,
              borderRadius: '3px 3px 0 0', fontSize: 10, cursor: 'pointer',
              background: leftTab === tab ? '#fff' : 'transparent',
              color: leftTab === tab ? '#2563EB' : '#66758A',
              fontWeight: leftTab === tab ? 700 : 400,
            }}
          >
            {tab === 'palette' ? '控件' : tab === 'field' ? '字段' : '大纲'}
          </button>
        ))}
      </div>

      {/* 面板内容 */}
      <div style={{ minHeight: 0, overflow: 'auto', padding: 6 }}>
        <Input
          size="small"
          placeholder="搜索..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          style={{ marginBottom: 6, fontSize: 10 }}
        />

        {leftTab === 'palette' && <ComponentPalette search={search} />}
        {leftTab === 'field' && <FieldPalette search={search} />}
        {leftTab === 'outline' && <OutlineTree />}
      </div>
    </aside>
  );
});
