import React from 'react';
import { Input, Button } from 'antd';
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

export const RuleInspector = observer(() => {
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
      <PropGroup title="显隐规则">
        <PropRow label="可见条件">
          <Input size="small" placeholder="表达式，如: data.status === 'active'" style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="隐藏时行为">
          <span style={{ color: '#94A3B8', fontSize: 9 }}>保留布局 / 不占位</span>
        </PropRow>
      </PropGroup>

      <PropGroup title="只读规则">
        <PropRow label="只读条件">
          <Input size="small" placeholder="表达式" style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="只读原因">
          <Input size="small" placeholder="如: 审批中不可编辑" style={{ fontSize: 9 }} />
        </PropRow>
      </PropGroup>

      <PropGroup title="计算规则">
        <PropRow label="计算公式">
          <Input size="small" value={(node as any).formula || ''} placeholder="如: data.qty * data.price" onChange={e => store.updateNode(node.id, { formula: e.target.value } as any)} style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="依赖字段">
          <span style={{ color: '#94A3B8', fontSize: 9 }}>自动解析</span>
        </PropRow>
      </PropGroup>

      <PropGroup title="联动规则">
        <PropRow label="联动条件">
          <Input size="small" placeholder="如: field === 'customerId'" style={{ fontSize: 9 }} />
        </PropRow>
        <PropRow label="联动动作">
          <Input size="small" placeholder="如: reset(['price', 'amount'])" style={{ fontSize: 9 }} />
        </PropRow>
      </PropGroup>

      <PropGroup title="操作">
        <PropRow label="">
          <Button size="small" style={{ fontSize: 9 }}>+ 添加规则</Button>
        </PropRow>
      </PropGroup>
    </div>
  );
});
