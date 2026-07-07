import React from 'react';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Space, Button } from 'antd';
import { HolderOutlined, DeleteOutlined } from '@ant-design/icons';
import { FieldPreviewComplete } from './FieldPreviewComplete';

export interface SortableFieldItemProps {
  field: any;
  index: number;
  isSelected: boolean;
  onSelect: () => void;
  onDelete: () => void;
}

export const SortableFieldItem: React.FC<SortableFieldItemProps> = ({
  field,
  index,
  isSelected,
  onSelect,
  onDelete,
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
        onClick={onSelect}
        style={{
          position: 'relative',
          margin: '12px 0',
          border: isSelected ? '2px solid #1890ff' : '2px solid transparent',
          borderRadius: '4px',
          background: isSelected ? '#e6f7ff' : 'transparent',
          transition: 'all 0.3s',
          cursor: 'pointer',
        }}
      >
        {/* 拖拽和删除控制栏 */}
        <div style={{
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
        <div style={{
          pointerEvents: 'none', // 禁用组件内部交互，只允许选择和拖拽
          paddingTop: '8px',
        }}>
          <FieldPreviewComplete field={field} />
        </div>
      </div>
    </div>
  );
};
