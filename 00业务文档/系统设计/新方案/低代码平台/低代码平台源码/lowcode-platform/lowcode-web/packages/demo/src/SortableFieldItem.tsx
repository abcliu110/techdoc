import React from 'react';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Button } from 'antd';
import { HolderOutlined, DeleteOutlined } from '@ant-design/icons';
import { FieldPreviewComplete } from './FieldPreviewComplete';

export interface SortableFieldItemProps {
  field: any;
  index: string | number;
  isSelected: boolean;
  onSelect: () => void;
  onDelete: () => void;
  isContainer?: boolean;
  children?: React.ReactNode; // 支持嵌套子组件
}

export const SortableFieldItem: React.FC<SortableFieldItemProps> = ({
  field,
  index,
  isSelected,
  onSelect,
  onDelete,
  isContainer = false,
  children,
}) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: field.id });

  const style: React.CSSProperties = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div ref={setNodeRef} style={style}>
      <div
        data-testid="canvas-node"
        data-node-id={field.id}
        data-node-type={field.type}
        aria-label={`字段：${field.label}`}
        onClick={onSelect}
        style={{
          position: 'relative',
          margin: '12px 0',
          border: isSelected ? '2px solid #1890ff' : '2px solid transparent',
          borderRadius: '4px',
          background: isSelected ? '#e6f7ff' : isContainer ? '#fafafa' : 'transparent',
          transition: 'all 0.3s',
          cursor: 'pointer',
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
            opacity: isSelected ? 1 : 0,
            transition: 'opacity 0.3s',
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.opacity = '1';
          }}
          onMouseLeave={(e) => {
            if (!isSelected) {
              e.currentTarget.style.opacity = '0';
            }
          }}
        >
          <div
            {...attributes}
            {...listeners}
            data-testid="drag-handle"
            aria-label={`拖动字段：${field.label}`}
            style={{
              cursor: 'grab',
              padding: '4px 8px',
              color: '#1890ff',
              fontSize: '16px',
              userSelect: 'none',
              WebkitUserSelect: 'none',
              touchAction: 'none',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <HolderOutlined />
          </div>
          <Button
            data-testid="delete-node-button"
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

        {/* 实际组件预览 */}
        <div
          style={{
            pointerEvents: isContainer ? 'auto' : 'none', // 容器组件允许交互（切换Tab等）
            paddingTop: '8px',
          }}
          onClick={(e) => {
            // 如果是容器组件内部的交互（如Tab切换），阻止冒泡
            if (isContainer && e.target !== e.currentTarget) {
              e.stopPropagation();
            }
          }}
        >
          <FieldPreviewComplete field={field}>
            {/* 将children传递给组件，用于渲染嵌套内容 */}
            {children}
          </FieldPreviewComplete>
        </div>
      </div>
    </div>
  );
};
