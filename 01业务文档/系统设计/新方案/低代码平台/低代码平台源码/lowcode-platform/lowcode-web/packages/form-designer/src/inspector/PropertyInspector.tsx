import React from 'react';
import { Input, Select, Switch, Button, Divider } from 'antd';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';
import { ELEMENT_LABELS } from '@lowcode/shared';

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

export const PropertyInspector = observer(() => {
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
      <Select
        size="small"
        value={node.id}
        style={{ width: '100%', marginBottom: 6, fontSize: 10 }}
        options={[{ value: node.id, label: `${node.label || node.type} : ${ELEMENT_LABELS[node.type as keyof typeof ELEMENT_LABELS] || node.type}` }]}
      />

      <PropGroup title="基础属性">
        <PropRow label="nodeId">
          <span style={{ fontFamily: 'Consolas', fontSize: 9 }}>{node.fieldId || node.id}</span>
        </PropRow>
        <PropRow label="组件类型">
          <span style={{ fontFamily: 'Consolas', fontSize: 9 }}>{ELEMENT_LABELS[node.type as keyof typeof ELEMENT_LABELS] || node.type}</span>
        </PropRow>
        <PropRow label="显示名称">
          <Input size="small" value={node.label} onChange={e => store.updateNode(node.id, { label: e.target.value })} style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="字段编码">
          <Input size="small" value={node.fieldId || ''} onChange={e => store.updateNode(node.id, { fieldId: e.target.value })} style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="占位文本">
          <Input size="small" value={node.placeholder || ''} onChange={e => store.updateNode(node.id, { placeholder: e.target.value })} style={{ fontSize: 9 }} />
        </PropRow>
      </PropGroup>

      <PropGroup title="数据绑定">
        <PropRow label="BO 绑定">
          <Input size="small" value={node.boField || ''} placeholder="如 header.customerId" onChange={e => store.updateNode(node.id, { boField: e.target.value })} style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="默认值">
          <Input size="small" value={(node.defaultValue as string) || ''} onChange={e => store.updateNode(node.id, { defaultValue: e.target.value })} style={{ fontSize: 9 }} />
        </PropRow>
      </PropGroup>

      <PropGroup title="状态控制">
        <PropRow label="必填">
          <Switch size="small" checked={node.required} onChange={v => store.updateNode(node.id, { required: v })} />
        </PropRow>
        <PropRow label="只读">
          <Switch size="small" checked={node.readonly} onChange={v => store.updateNode(node.id, { readonly: v })} />
        </PropRow>
        <PropRow label="禁用">
          <Switch size="small" checked={node.disabled} onChange={v => store.updateNode(node.id, { disabled: v })} />
        </PropRow>
        <PropRow label="隐藏">
          <Switch size="small" checked={node.hidden} onChange={v => store.updateNode(node.id, { hidden: v })} />
        </PropRow>
      </PropGroup>

      <PropGroup title="校验">
        <PropRow label="最小值">
          <Input size="small" type="number" value={(node.min as number) ?? ''} onChange={e => store.updateNode(node.id, { min: Number(e.target.value) })} style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="最大值">
          <Input size="small" type="number" value={(node.max as number) ?? ''} onChange={e => store.updateNode(node.id, { max: Number(e.target.value) })} style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="最大长度">
          <Input size="small" type="number" value={node.maxLength ?? ''} onChange={e => store.updateNode(node.id, { maxLength: Number(e.target.value) })} style={{ fontSize: 9 }} />
        </PropRow>
      </PropGroup>

      <PropGroup title="操作">
        <PropRow label="">
          <Button size="small" danger onClick={() => store.removeNode(node.id)} style={{ fontSize: 9 }}>删除节点</Button>
        </PropRow>
      </PropGroup>
    </div>
  );
});
