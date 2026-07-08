/**
 * 可排序字段项组件
 * 支持拖拽排序、选中、删除，提供完整的 AI 可控性抓手（data-testid）
 */

import React from 'react';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Button } from 'antd';
import { HolderOutlined, DeleteOutlined } from '@ant-design/icons';
import { FieldRenderer } from './FieldRenderer';
import { ContainerDropZone } from './ContainerDropZone';
import type { DesignerFieldData } from '../types';
import { CONTAINER_TYPES } from '../types';

export interface SortableFieldItemProps {
  field: DesignerFieldData;
  index: number;
  isSelected: boolean;
  onSelect: () => void;
  onDelete: () => void;
  selectedFieldIdFromParent?: string | null;
  onFieldSelect?: (id: string) => void;
  onFieldDelete?: (id: string) => void;
}

export const SortableFieldItem: React.FC<SortableFieldItemProps> = ({
  field,
  index,
  isSelected,
  onSelect,
  onDelete,
  selectedFieldIdFromParent,
  onFieldSelect,
  onFieldDelete,
}) => {
  const isContainer = CONTAINER_TYPES.has(field.type as never);
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: field.id });

  const sizeStyle: React.CSSProperties = {};
  if (field.width !== undefined && field.width !== '') sizeStyle.width = field.width;
  if (field.height !== undefined && field.height !== '') sizeStyle.height = field.height;
  if (field.minWidth !== undefined && field.minWidth !== '') sizeStyle.minWidth = field.minWidth;
  if (field.maxWidth !== undefined && field.maxWidth !== '') sizeStyle.maxWidth = field.maxWidth;
  if (field.minHeight !== undefined && field.minHeight !== '') sizeStyle.minHeight = field.minHeight;
  if (field.maxHeight !== undefined && field.maxHeight !== '') sizeStyle.maxHeight = field.maxHeight;

  const dragStyle: React.CSSProperties = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div ref={setNodeRef} style={dragStyle}>
      <div
        data-testid="canvas-node"
        data-node-id={field.id}
        data-node-type={field.type}
        data-node-index={index}
        aria-label={`字段：${field.label}`}
        style={{
          position: 'relative',
          margin: '12px 0',
          border: isSelected ? '2px solid #1890ff' : '2px solid transparent',
          borderRadius: '4px',
          background: isSelected ? '#e6f7ff' : isContainer ? '#fafafa' : 'transparent',
          transition: 'all 0.3s',
          ...sizeStyle,
        }}
        onClick={(e) => {
          // 阻止冒泡到 canvas-root，避免 canvas-root 的 onClick 重新选中字段
          e.stopPropagation();
          onSelect();
        }}
      >
        {/* 拖拽和删除控制栏 */}
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            height: '32px',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '0 8px',
            background: isSelected ? 'rgba(24, 144, 255, 0.1)' : 'transparent',
            zIndex: 10,
            opacity: isSelected ? 1 : 0.6,
            transition: 'opacity 0.3s',
            cursor: 'pointer',
          }}
          onMouseEnter={(e) => {
            if (isSelected) {
              e.currentTarget.style.opacity = '1';
            }
          }}
          onMouseLeave={(e) => {
            if (!isSelected) {
              e.currentTarget.style.opacity = '0.6';
            }
          }}
          onClick={(e) => {
            e.stopPropagation();
            onSelect();
          }}
        >
          {/* 拖拽手柄 */}
          <div
            {...attributes}
            {...listeners}
            data-testid="drag-handle"
            data-node-id={field.id}
            aria-label={`拖动字段：${field.label}`}
            style={{
              cursor: 'grab',
              padding: '4px 8px',
              color: '#1890ff',
              fontSize: '16px',
              userSelect: 'none',
              WebkitUserSelect: 'none',
              touchAction: 'none',
              opacity: 1, // 打破父级控制栏 opacity 继承，始终完全可见
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <HolderOutlined />
          </div>

          {/* 字段索引和类型标签 */}
          <div
            style={{
              fontSize: '11px',
              color: '#999',
              flex: 1,
              textAlign: 'center',
            }}
          >
            {field.label || field.type}
          </div>

          {/* 删除按钮 */}
          <Button
            data-testid="delete-node-button"
            data-node-id={field.id}
            aria-label={`删除字段：${field.label}`}
            type="text"
            danger
            size="small"
            icon={<DeleteOutlined />}
            onClick={(e) => {
              e.stopPropagation();
              onDelete();
            }}
          />
        </div>

        {/* 组件预览内容 */}
        <div
          style={{
            pointerEvents: 'auto',
            paddingTop: '8px',
          }}
        >
          <FieldRenderer field={field} />
        </div>

        {/* 容器子组件 droppable 区域 */}
        {isContainer && field.children && onFieldSelect && onFieldDelete && (
          <ContainerDropZone
            containerId={field.id}
            children={field.children}
            selectedFieldId={selectedFieldIdFromParent}
            onFieldSelect={onFieldSelect}
            onFieldDelete={onFieldDelete}
          />
        )}

        {/* 透明选择区域：点击组件区域空白处选中，点击交互元素正常交互 */}
        <div
          style={{
            position: 'absolute',
            top: '32px',
            left: 0,
            right: 0,
            bottom: 0,
            cursor: 'pointer',
            zIndex: 5,
          }}
        />
      </div>
    </div>
  );
};
