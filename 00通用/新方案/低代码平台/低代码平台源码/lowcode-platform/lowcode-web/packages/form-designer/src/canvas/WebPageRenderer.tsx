/**
 * 页面渲染器
 * 根据 Schema 动态渲染页面 — 支持 LayoutNode + DesignerFieldData 混合节点树
 * 参考 T-207 表单设计器原型 的 Web 单据页面结构
 */
import React from 'react';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';
import { LayoutControlRenderer } from './LayoutControlRenderer';
import type { DesignerFieldData, ColumnDef, SchemaNode, LayoutNode } from '@lowcode/shared';
import { ELEMENT_LABELS, isLayoutControl } from '@lowcode/shared';

// ================================ 字段渲染器 ================================

function FieldRenderer({ node }: { node: DesignerFieldData }) {
  const { selectedNodeId, selectNode, hoveredNodeId, hoverNode } = store;
  const isSelected = selectedNodeId === node.id;
  const isHovered = hoveredNodeId === node.id;

  const inputStyle: React.CSSProperties = {
    height: 20,
    display: 'flex',
    alignItems: 'center',
    padding: '0 4px',
    border: `1px solid ${isHovered ? '#2563EB' : '#cbd5e1'}`,
    borderRadius: 2,
    background: '#fff',
    color: node.readonly ? '#94A3B8' : '#334155',
    whiteSpace: 'nowrap',
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    fontSize: 9,
    cursor: 'pointer',
    ...(node.hidden ? { display: 'none' } : {}),
  };

  return (
    <div
      onClick={e => { e.stopPropagation(); selectNode(node.id); }}
      onMouseEnter={() => hoverNode(node.id)}
      onMouseLeave={() => hoverNode(null)}
      style={{
        display: 'grid',
        gridTemplateColumns: node.childLayout === 'grid' && node.gridColumns
          ? `repeat(${node.gridColumns}, minmax(0, 1fr))`
          : '44px minmax(0, 1fr)',
        alignItems: 'center',
        gap: 3,
        minWidth: 0,
        fontSize: 9,
        gridColumn: node.gridColumns ? `span ${node.gridColumns}` : undefined,
      }}
    >
      <label style={{
        color: '#66758A', textAlign: 'right',
        whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
      }}>
        {node.label || ELEMENT_LABELS[node.type] || node.type}
        {node.required && <span style={{ color: '#B91C1C', marginLeft: 2 }}>*</span>}
      </label>
      <div style={inputStyle}>
        {node.readonly || node.disabled ? (
          <span style={{ color: '#94A3B8', fontStyle: 'italic' }}>{node.placeholder || '—'}</span>
        ) : (
          <span>{node.placeholder || '请输入'}</span>
        )}
      </div>
    </div>
  );
}

// ================================ 子表格渲染器 ================================

function SubTableRenderer({ node }: { node: DesignerFieldData }) {
  const { selectedNodeId, selectNode, hoveredNodeId, hoverNode } = store;
  const isSelected = selectedNodeId === node.id;
  const isHovered = hoveredNodeId === node.id;
  const columns = node.columns || [];

  return (
    <div
      style={{
        border: `1px solid ${isSelected ? '#2563EB' : isHovered ? 'rgba(37,99,235,0.5)' : '#D8DEE8'}`,
        background: '#fff', position: 'relative', minWidth: 0, overflow: 'hidden',
        boxShadow: isSelected ? '0 0 0 1px #2563EB' : 'none',
      }}
      onClick={e => { e.stopPropagation(); selectNode(node.id); }}
      onMouseEnter={() => hoverNode(node.id)}
      onMouseLeave={() => hoverNode(null)}
    >
      {isSelected && (
        <>
          <div style={{
            position: 'absolute', top: -1, left: -1, height: 16,
            display: 'inline-flex', alignItems: 'center',
            padding: '0 5px', background: '#2563EB', color: '#fff',
            fontSize: 9, zIndex: 3, borderRadius: '0 0 2px 0',
          }}>
            {node.label || '子表格'} [EntryTable]
          </div>
          {(['tl', 'tr', 'bl', 'br'] as const).map(pos => (
            <div key={pos} style={{
              position: 'absolute', width: 6, height: 6,
              border: '1px solid #2563EB', background: '#fff', zIndex: 4,
              cursor: 'pointer',
              ...(pos === 'tl' ? { left: -3, top: -3 } : pos === 'tr' ? { right: -3, top: -3 } : pos === 'bl' ? { left: -3, bottom: -3 } : { right: -3, bottom: -3 }),
            }} />
          ))}
        </>
      )}

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 8px', background: '#f8fafc', borderBottom: '1px solid #D8DEE8' }}>
        <span style={{ fontSize: 10, fontWeight: 700 }}>{node.label || '子表格'}</span>
        <div style={{ display: 'flex', gap: 3 }}>
          {['+ 新增行', '复制行', '批量填充', '批次'].map(label => (
            <div key={label} style={{
              height: 16, display: 'flex', alignItems: 'center',
              padding: '0 6px', border: '1px solid #D8DEE8', borderRadius: 3,
              background: '#fff', color: '#66758A', fontSize: 8, cursor: 'pointer',
            }}>{label}</div>
          ))}
        </div>
      </div>

      <div style={{ overflow: 'auto' }}>
        <table style={{ width: '100%', minWidth: 400, borderCollapse: 'collapse', tableLayout: 'fixed', fontSize: 9 }}>
          <thead>
            <tr>
              {columns.map((col: ColumnDef, i: number) => (
                <th key={i} style={{
                  height: 24, padding: '0 5px', borderRight: '1px solid #D8DEE8', borderBottom: '1px solid #D8DEE8',
                  textAlign: 'left', background: '#f5f7fa', fontWeight: 700,
                  whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
                  position: col.frozen ? 'sticky' : undefined,
                  left: col.frozen === 'left' ? 0 : undefined,
                  zIndex: col.frozen ? 2 : 0,
                }}>{col.title}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            <tr>
              {columns.map((col: ColumnDef, i: number) => (
                <td key={i} style={{
                  height: 24, padding: '0 5px', borderRight: '1px solid #D8DEE8', borderBottom: '1px solid #D8DEE8',
                  whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', color: '#334155',
                }}>
                  {col.editable ? <span style={{ color: '#94A3B8' }}>— 可编辑 —</span> : `列${i + 1}`}
                </td>
              ))}
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ================================ 统一节点渲染器 ================================

function renderSchemaNode(node: SchemaNode): React.ReactNode {
  // 布局控件节点
  if (isLayoutControl(node.type)) {
    return (
      <LayoutControlRenderer
        key={node.id}
        node={node as LayoutNode}
        selected={store.selectedNodeId === node.id}
        onSelect={() => store.selectNode(node.id)}
      />
    );
  }

  // 业务字段节点
  const field = node as DesignerFieldData;

  // 子表格特殊处理
  if (field.type === 'subTable') {
    return <SubTableRenderer key={field.id} node={field} />;
  }

  // 有子节点
  if (field.children && field.children.length > 0) {
    return (
      <div
        key={field.id}
        onClick={e => { e.stopPropagation(); store.selectNode(field.id); }}
        style={{
          border: store.selectedNodeId === field.id ? '2px solid #2563EB' : '1px solid #D8DEE8',
          background: '#fff',
          position: 'relative',
          minWidth: 0,
          overflow: 'hidden',
          borderRadius: 3,
        }}
      >
        {store.selectedNodeId === field.id && (
          <div style={{
            position: 'absolute', top: -1, left: -1, height: 16,
            padding: '0 5px', background: '#2563EB', color: '#fff',
            fontSize: 9, zIndex: 3, borderRadius: '0 0 2px 0',
          }}>
            {field.label} [{field.type}]
          </div>
        )}
        <div style={{
          display: 'grid',
          gridTemplateColumns: field.gridColumns ? `repeat(${field.gridColumns}, minmax(0, 1fr))` : 'repeat(4, minmax(0, 1fr))',
          gap: '5px 6px',
          padding: '22px 8px 8px',
        }}>
          {field.children.map(child => renderSchemaNode(child as SchemaNode))}
        </div>
      </div>
    );
  }

  // 简单字段
  return <FieldRenderer key={field.id} node={field} />;
}

// ================================ 页面工具条 ================================

function ToolbarStrip({ items }: { items: string[] }) {
  return (
    <div style={{
      height: 30, display: 'flex', alignItems: 'center', gap: 3, padding: '0 8px',
    }}>
      {items.map((label, i) => (
        <div key={label} style={{
          height: 20, display: 'flex', alignItems: 'center', padding: '0 7px',
          border: '1px solid #D8DEE8', borderRadius: 3,
          background: i === 0 ? '#F3F7FF' : '#fff',
          color: i === 0 ? '#2563EB' : '#66758A',
          fontWeight: i === 0 ? 700 : 400, fontSize: 9, cursor: 'pointer',
        }}>{label}</div>
      ))}
    </div>
  );
}

// ================================ 右侧信息面板 ================================

function AsideInfo() {
  return (
    <aside style={{ borderLeft: '1px solid #D8DEE8', background: '#f8fafc', display: 'grid', gridTemplateRows: '26px minmax(0, 1fr)', overflow: 'hidden' }}>
      <div style={{ height: 26, display: 'flex', alignItems: 'center', padding: '0 7px', background: '#fff', borderBottom: '1px solid #D8DEE8', fontSize: 10, fontWeight: 700, color: '#66758A' }}>右侧信息</div>
      <div style={{ padding: 5, display: 'grid', gap: 5, alignContent: 'start', overflow: 'auto' }}>
        {[
          { title: '审批轨迹', body: '创建草稿，等待提交审批。\n预计审核节点：3级' },
          { title: '风险提示', body: '客户信用额度需校验\n超出账期 15 天' },
          { title: '业务规则', body: '客户变更 → 重新算价格\n数量 > 100 → 需主管审批' },
          { title: '快捷操作', body: 'F2 编辑 | F8 保存\nCtrl+Z 撤销 | Ctrl+Y 重做' },
        ].map(item => (
          <div key={item.title} style={{ border: '1px solid #D8DEE8', background: '#fff' }}>
            <div style={{ height: 18, display: 'flex', alignItems: 'center', padding: '0 5px', borderBottom: '1px solid #D8DEE8', background: '#f5f7fa', fontSize: 9, fontWeight: 700 }}>{item.title}</div>
            <div style={{ padding: '4px 5px', color: '#66758A', fontSize: 9, lineHeight: 1.4, whiteSpace: 'pre-line' }}>{item.body}</div>
          </div>
        ))}
      </div>
    </aside>
  );
}

// ================================ 主页面渲染器 ================================

export function WebPageRenderer() {
  const { formDef } = store;
  const schemaChildren = formDef.schema.children || [];
  const isRootSchema = formDef.schema.nodeId === 'root' || formDef.schema.nodeId === 'pageRoot';

  return (
    <div style={{
      width: 1100,
      minHeight: 700,
      background: '#fff',
      border: '1px solid #A7B4C5',
      boxShadow: '0 10px 18px rgba(15, 23, 42, 0.12)',
      display: 'grid',
      gridTemplateRows: '34px 30px minmax(0, 1fr) 34px',
      position: 'relative',
    }}>
      {/* 页面顶部 */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8, padding: '0 10px', background: '#fff', borderBottom: '1px solid #D8DEE8' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, minWidth: 0, fontSize: 12, fontWeight: 700 }}>
          <div style={{ width: 7, height: 7, borderRadius: '50%', background: '#047857' }} />
          {formDef.name}
        </div>
        <div style={{ display: 'flex', gap: 4 }}>
          {['保存', '提交', '审核', '下推采购'].map(label => (
            <div key={label} style={{ height: 21, display: 'flex', alignItems: 'center', padding: '0 8px', border: '1px solid #D8DEE8', borderRadius: 3, background: '#fff', color: '#66758A', fontSize: 10, cursor: 'pointer' }}>{label}</div>
          ))}
          <div style={{ height: 21, display: 'flex', alignItems: 'center', padding: '0 8px', border: '1px solid #2563EB', borderRadius: 3, background: '#2563EB', color: '#fff', fontSize: 10, cursor: 'pointer' }}>预览</div>
        </div>
      </div>

      {/* 页签导航 */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 3, padding: '0 9px', background: '#f8fafc', borderBottom: '1px solid #D8DEE8', overflow: 'hidden' }}>
        {['基本信息', '订单明细', '交付计划', '审批记录', '附件'].map((label, i) => (
          <div key={label} style={{
            height: 21, display: 'flex', alignItems: 'center', padding: '0 8px', borderRadius: 3,
            border: '1px solid', borderColor: i === 0 ? '#D8DEE8' : 'transparent',
            background: i === 0 ? '#fff' : 'transparent', color: i === 0 ? '#2563EB' : '#66758A',
            fontSize: 10, fontWeight: i === 0 ? 700 : 400, cursor: 'pointer', whiteSpace: 'nowrap',
          }}>{label}</div>
        ))}
      </div>

      {/* 主内容区 */}
      <div style={{ display: 'grid', gridTemplateColumns: '110px minmax(0, 1fr) 140px', overflow: 'hidden' }}>
        {/* 左侧导航 */}
        <nav style={{ borderRight: '1px solid #D8DEE8', background: '#f7f9fc', display: 'grid', gridTemplateRows: '26px minmax(0, 1fr)', overflow: 'hidden' }}>
          <div style={{ height: 26, display: 'flex', alignItems: 'center', padding: '0 7px', background: '#fff', borderBottom: '1px solid #D8DEE8', fontSize: 10, fontWeight: 700, color: '#66758A' }}>业务导航</div>
          <div style={{ padding: 5, display: 'grid', gap: 2, alignContent: 'start' }}>
            {['基本信息', '分录表格', '批次明细', '合同附件', '关联单据', '日志'].map((label, i) => (
              <div key={label} style={{
                height: 22, display: 'flex', alignItems: 'center', padding: '0 6px', borderRadius: 3,
                background: i === 0 ? '#F3F7FF' : undefined, color: i === 0 ? '#2563EB' : '#66758A',
                fontWeight: i === 0 ? 700 : 400, fontSize: 10, cursor: 'pointer',
              }}>{label}</div>
            ))}
          </div>
        </nav>

        {/* 表单主体 — 渲染 Schema */}
        <main style={{ minWidth: 0, minHeight: 0, padding: 6, display: 'grid', gridTemplateRows: 'auto auto minmax(150px, 1fr) auto', gap: 6, overflow: 'auto', background: '#fbfcfe' }}>
          {isRootSchema ? schemaChildren.map(node => renderSchemaNode(node)) : (
            <div style={{ display: 'grid', placeItems: 'center', color: '#94a3b8', fontSize: 11 }}>
              拖入布局控件开始设计
            </div>
          )}

          {/* 工具条 */}
          <ToolbarStrip items={['保存', '提交审批', '审核', '下推采购', '下推出库', '打印', '复制', '删除']} />

          {/* 标签页区 */}
          <ToolbarStrip items={['分录', '批次', '序列号', '附件', '关联']} />
        </main>

        {/* 右侧信息 */}
        <AsideInfo />
      </div>

      {/* 底部动作 */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: 4, padding: '0 8px', borderTop: '1px solid #D8DEE8', background: '#fff' }}>
        {['关闭', '保存草稿'].map(label => (
          <div key={label} style={{ height: 21, display: 'flex', alignItems: 'center', padding: '0 8px', border: '1px solid #D8DEE8', borderRadius: 3, background: '#fff', color: '#66758A', fontSize: 10, cursor: 'pointer' }}>{label}</div>
        ))}
        <div style={{ height: 21, display: 'flex', alignItems: 'center', padding: '0 8px', border: '1px solid #2563EB', borderRadius: 3, background: '#2563EB', color: '#fff', fontSize: 10, cursor: 'pointer' }}>提交审批</div>
      </div>
    </div>
  );
}
