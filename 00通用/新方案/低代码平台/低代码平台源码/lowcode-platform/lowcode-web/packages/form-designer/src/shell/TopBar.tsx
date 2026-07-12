import React from 'react';
import { Button, Space, Tooltip, Select, Tag, Badge } from 'antd';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';

export const TopBar = observer(() => {
  const { formDef, dirty, problems } = store;
  const errorCount = problems.filter(p => p.severity === 'error').length;
  const warnCount = problems.filter(p => p.severity === 'warning').length;

  return (
    <header style={{
      display: 'grid',
      gridTemplateColumns: '280px minmax(0, 1fr) 300px',
      alignItems: 'center',
      background: '#fff',
      borderBottom: '1px solid #D8DEE8',
      height: '100%',
    }}>
      {/* 品牌区 */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '0 12px', borderRight: '1px solid #D8DEE8', height: '100%' }}>
        <div style={{
          width: 26, height: 26, background: '#2563EB', borderRadius: 4,
          display: 'grid', placeItems: 'center', color: '#fff', fontWeight: 700, fontSize: 14,
        }}>T</div>
        <div style={{ minWidth: 0 }}>
          <div style={{ fontSize: 12, fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
            企业单据页面设计器
          </div>
          <div style={{ fontSize: 10, color: '#64748B', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {dirty ? '● 未保存' : '✓ 已保存'} · {formDef.name} · Rev {formDef.revision}
          </div>
        </div>
      </div>

      {/* 命令区 */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '0 12px' }}>
        <Space.Compact size="small">
          <Tooltip title="撤销 (Ctrl+Z)">
            <Button size="small" onClick={() => store.undo()} disabled={store.undoStack.length === 0}>↩</Button>
          </Tooltip>
          <Tooltip title="重做 (Ctrl+Y)">
            <Button size="small" onClick={() => store.redo()} disabled={store.redoStack.length === 0}>↪</Button>
          </Tooltip>
        </Space.Compact>
        <div style={{ width: 1, height: 20, background: '#D8DEE8', margin: '0 4px' }} />
        <Space.Compact size="small">
          <Button size="small" onClick={() => store.save()}>保存</Button>
          <Button
            size="small"
            danger={errorCount > 0}
            style={errorCount === 0 ? { color: '#B45309', borderColor: '#f0c987', background: '#fffbeb' } : {}}
          >
            校验 {errorCount > 0 && <Badge count={errorCount + warnCount} size="small" style={{ marginLeft: 4 }} />}
          </Button>
          <Button size="small" type="primary" onClick={() => alert('发布功能待实现')}>发布</Button>
        </Space.Compact>
        <div style={{ width: 1, height: 20, background: '#D8DEE8', margin: '0 4px' }} />
        <Space.Compact size="small">
          <Button size="small" onClick={() => store.setViewMode('preview')}>预览</Button>
          <Button size="small" onClick={() => store.setViewMode('code')}>JSON</Button>
        </Space.Compact>
      </div>

      {/* 右侧状态 */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: 6, padding: '0 12px', borderLeft: '1px solid #D8DEE8', height: '100%' }}>
        <Tag color={formDef.draft ? 'warning' : 'success'} style={{ margin: 0, fontSize: 10 }}>
          {formDef.draft ? '草稿' : '已发布'}
        </Tag>
        <Tag style={{ margin: 0, fontSize: 10 }}>Rev {formDef.revision}</Tag>
        <Select
          size="small"
          defaultValue="1440"
          style={{ width: 80, fontSize: 10 }}
          options={[
            { value: '1280', label: '1280' },
            { value: '1440', label: '1440' },
            { value: '1600', label: '1600' },
            { value: '1920', label: '1920' },
          ]}
        />
      </div>
    </header>
  );
});
