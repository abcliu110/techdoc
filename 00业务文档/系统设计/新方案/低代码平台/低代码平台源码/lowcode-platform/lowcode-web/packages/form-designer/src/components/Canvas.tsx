/**
 * 表单设计器画布
 * 支持拖拽放置、排序、选中、预览
 * 提供完整的 AI 可控性抓手
 */

import React from 'react';
import { useDroppable } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { Card, Button, Tag, Space } from 'antd';
import { SaveOutlined } from '@ant-design/icons';
import { SortableFieldItem } from './SortableFieldItem';
import { FieldRenderer } from './FieldRenderer';
import type { FormDefinition } from '../types';

export interface CanvasProps {
  formDef: FormDefinition;
  selectedFieldId: string | null;
  viewMode: 'design' | 'preview' | 'code';
  onFieldSelect: (fieldId: string) => void;
  onFieldDelete: (fieldId: string) => void;
  onFieldReorder?: (oldIndex: number, newIndex: number) => void;
  onSave?: () => void;
}

export const Canvas: React.FC<CanvasProps> = ({
  formDef,
  selectedFieldId,
  viewMode,
  onFieldSelect,
  onFieldDelete,
  onSave,
}) => {
  const { setNodeRef, isOver } = useDroppable({
    id: 'canvas-droppable',
  });

  // 获取选中的字段
  const selectedField = selectedFieldId
    ? formDef.fields.find(f => f.id === selectedFieldId) || null
    : null;

  return (
    <div
      data-testid="canvas-root"
      role="application"
      aria-label="表单设计画布"
      onClick={(e) => {
        // 点击画布空白区域时取消选中
        const clickedOnNode = (e.target as HTMLElement).closest('[data-testid="canvas-node"]');
        if (!clickedOnNode) {
          onFieldSelect('');
        }
      }}
      style={{
        padding: '20px',
        height: '100vh',
        overflow: 'auto',
        background: '#f5f5f5',
      }}
    >
      {/* 工具栏 */}
      <div
        style={{
          marginBottom: '16px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <div>
          <h2 style={{ margin: 0 }}>🎨 设计画布</h2>
          <div style={{ fontSize: '12px', color: '#999', marginTop: '4px' }}>
            {formDef.formName} - {formDef.fields.length} 个字段
          </div>
        </div>
        <Space>
          <Tag color="blue">字段数: {formDef.fields.length}</Tag>
          {selectedField && (
            <Tag color="green">选中: {selectedField.label || selectedField.fieldId}</Tag>
          )}
          {onSave && (
            <Button
              type="primary"
              size="large"
              icon={<SaveOutlined />}
              onClick={onSave}
              data-testid="save-form-button"
            >
              保存表单
            </Button>
          )}
        </Space>
      </div>

      {/* 画布区域 */}
      <Card
        ref={setNodeRef}
        title={formDef.formName}
        style={{
          minHeight: 'calc(100vh - 160px)',
          background: isOver ? '#e6f7ff' : 'white',
          border: isOver ? '2px dashed #1890ff' : '1px solid #f0f0f0',
          transition: 'all 0.3s',
        }}
        bodyStyle={{
          padding: formDef.fields.length === 0 ? '0' : '16px',
        }}
      >
        {/* 空状态 */}
        {formDef.fields.length === 0 && (
          <div
            data-testid="canvas-empty"
            style={{
              padding: '80px 40px',
              textAlign: 'center',
              color: '#999',
              fontSize: '16px',
              userSelect: 'none',
            }}
          >
            <div style={{ fontSize: '48px', marginBottom: '16px' }}>📦</div>
            <div style={{ fontSize: '18px', fontWeight: 'bold', marginBottom: '8px' }}>
              从左侧拖动组件到这里
            </div>
            <div style={{ fontSize: '14px', color: '#ccc' }}>
              支持拖拽排序 • 所见即所得预览 • {formDef.fields.length}个组件
            </div>
          </div>
        )}

        {/* 预览模式 */}
        {viewMode === 'preview' && formDef.fields.length > 0 && (
          <div>
            <div
              data-testid="preview-mode-banner"
              style={{
                marginBottom: '16px',
                padding: '12px',
                background: '#e6f7ff',
                borderRadius: '4px',
                userSelect: 'none',
              }}
            >
              👁️ <strong>预览模式</strong> - 这是用户看到的实际效果
            </div>
            {formDef.fields.map((field) => (
              <FieldRenderer key={field.id} field={field} />
            ))}
          </div>
        )}

        {/* JSON 代码模式 */}
        {viewMode === 'code' && formDef.fields.length > 0 && (
          <div>
            <div
              data-testid="code-mode-banner"
              style={{
                marginBottom: '16px',
                padding: '12px',
                background: '#f5f5f5',
                borderRadius: '4px',
                userSelect: 'none',
              }}
            >
              💻 <strong>JSON 代码模式</strong>
            </div>
            <pre
              data-testid="form-json-output"
              style={{
                background: '#f5f5f5',
                padding: '16px',
                borderRadius: '4px',
                overflow: 'auto',
                maxHeight: '600px',
                userSelect: 'text',
                fontSize: '12px',
              }}
            >
              {JSON.stringify(formDef, null, 2)}
            </pre>
          </div>
        )}

        {/* 设计模式 - 可排序 */}
        {viewMode === 'design' && formDef.fields.length > 0 && (
          <SortableContext
            items={formDef.fields.map(f => f.id)}
            strategy={verticalListSortingStrategy}
          >
            {formDef.fields.map((field, index) => (
              <SortableFieldItem
                key={field.id}
                field={field}
                index={index}
                isSelected={selectedFieldId === field.id}
                onSelect={() => onFieldSelect(field.id)}
                onDelete={() => onFieldDelete(field.id)}
                selectedFieldIdFromParent={selectedFieldId}
                onFieldSelect={onFieldSelect}
                onFieldDelete={onFieldDelete}
              />
            ))}
          </SortableContext>
        )}
      </Card>
    </div>
  );
};
