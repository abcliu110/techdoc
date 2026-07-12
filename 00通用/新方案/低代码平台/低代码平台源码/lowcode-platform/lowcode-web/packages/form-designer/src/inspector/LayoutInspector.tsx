import React from 'react';
import { Input, Select } from 'antd';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';

function PropRow({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div style={{
      display: 'grid', gridTemplateColumns: '78px minmax(0, 1fr)',
      minHeight: 24, borderBottom: '1px solid #edf2f7', fontSize: 9,
    }}>
      <div style={{ padding: '0 5px', display: 'flex', alignItems: 'center', background: '#FAFCFE', color: '#66758A', borderRight: '1px solid #edf2f7' }}>{label}</div>
      <div style={{ padding: '0 5px', display: 'flex', alignItems: 'center', overflow: 'hidden' }}>{children}</div>
    </div>
  );
}

function PropGroup({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ border: '1px solid #D8DEE8', marginBottom: 6, background: '#fff' }}>
      <div style={{ height: 20, display: 'flex', alignItems: 'center', padding: '0 6px', background: '#F5F7FA', borderBottom: '1px solid #D8DEE8', fontSize: 10, fontWeight: 700, color: '#66758A' }}>{title}</div>
      {children}
    </div>
  );
}

export const LayoutInspector = observer(() => {
  const node = store.selectedNode;

  if (!node) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 120, color: '#94A3B8', fontSize: 11 }}>
        未选中节点
      </div>
    );
  }

  return (
    <div>
      <PropGroup title="显示布局">
        <PropRow label="display">
          <Select size="small" value={node.display || 'block'} onChange={v => store.updateNode(node.id, { display: v })} style={{ width: '100%', fontSize: 9 }}
            options={[
              { value: 'block', label: 'block' },
              { value: 'flex', label: 'flex' },
              { value: 'grid', label: 'grid' },
              { value: 'inline-block', label: 'inline-block' },
            ]}
          />
        </PropRow>
      </PropGroup>

      {node.display === 'grid' && (
        <PropGroup title="Grid 布局">
          <PropRow label="columns">
            <Input size="small" value={node.gridTemplateColumns || 'repeat(4, 1fr)'} onChange={e => store.updateNode(node.id, { gridTemplateColumns: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
          </PropRow>
          <PropRow label="行模板">
            <Input size="small" value={node.gridTemplateRows || ''} placeholder="如 auto 1fr auto" onChange={e => store.updateNode(node.id, { gridTemplateRows: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
          </PropRow>
          <PropRow label="间距">
            <Input size="small" value={node.gridGap || '6px 8px'} onChange={e => store.updateNode(node.id, { gridGap: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
          </PropRow>
        </PropGroup>
      )}

      {node.display === 'flex' && (
        <PropGroup title="Flex 布局">
          <PropRow label="direction">
            <Select size="small" value={node.flexDirection || 'row'} onChange={v => store.updateNode(node.id, { flexDirection: v })} style={{ width: '100%', fontSize: 9 }}
              options={[
                { value: 'row', label: 'row' },
                { value: 'column', label: 'column' },
                { value: 'row-reverse', label: 'row-reverse' },
                { value: 'column-reverse', label: 'column-reverse' },
              ]}
            />
          </PropRow>
          <PropRow label="justify">
            <Select size="small" value={node.justifyContent || 'flex-start'} onChange={v => store.updateNode(node.id, { justifyContent: v })} style={{ width: '100%', fontSize: 9 }}
              options={[
                { value: 'flex-start', label: 'flex-start' },
                { value: 'center', label: 'center' },
                { value: 'flex-end', label: 'flex-end' },
                { value: 'space-between', label: 'space-between' },
                { value: 'space-around', label: 'space-around' },
              ]}
            />
          </PropRow>
          <PropRow label="align">
            <Select size="small" value={node.alignItems || 'center'} onChange={v => store.updateNode(node.id, { alignItems: v })} style={{ width: '100%', fontSize: 9 }}
              options={[
                { value: 'center', label: 'center' },
                { value: 'flex-start', label: 'flex-start' },
                { value: 'flex-end', label: 'flex-end' },
                { value: 'stretch', label: 'stretch' },
              ]}
            />
          </PropRow>
          <PropRow label="换行">
            <Select size="small" value={node.flexWrap || 'nowrap'} onChange={v => store.updateNode(node.id, { flexWrap: v })} style={{ width: '100%', fontSize: 9 }}
              options={[
                { value: 'nowrap', label: 'nowrap' },
                { value: 'wrap', label: 'wrap' },
                { value: 'wrap-reverse', label: 'wrap-reverse' },
              ]}
            />
          </PropRow>
          <PropRow label="gap">
            <Input size="small" value={node.gap || '6px'} onChange={e => store.updateNode(node.id, { gap: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
          </PropRow>
        </PropGroup>
      )}

      <PropGroup title="尺寸">
        <PropRow label="宽度">
          <Input size="small" value={node.width || ''} placeholder="如 100% / 200px / auto" onChange={e => store.updateNode(node.id, { width: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
        </PropRow>
        <PropRow label="高度">
          <Input size="small" value={node.height || ''} placeholder="如 auto / 32px" onChange={e => store.updateNode(node.id, { height: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
        </PropRow>
        <PropRow label="最小宽度">
          <Input size="small" value={node.minWidth || ''} onChange={e => store.updateNode(node.id, { minWidth: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
        </PropRow>
        <PropRow label="最大宽度">
          <Input size="small" value={node.maxWidth || ''} onChange={e => store.updateNode(node.id, { maxWidth: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
        </PropRow>
      </PropGroup>

      <PropGroup title="间距">
        <PropRow label="内边距">
          <Input size="small" value={node.padding || ''} placeholder="如 12px 或 8px 12px" onChange={e => store.updateNode(node.id, { padding: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
        </PropRow>
        <PropRow label="外边距">
          <Input size="small" value={node.margin || ''} onChange={e => store.updateNode(node.id, { margin: e.target.value })} style={{ fontFamily: 'Consolas', fontSize: 9 }} />
        </PropRow>
      </PropGroup>
    </div>
  );
});
