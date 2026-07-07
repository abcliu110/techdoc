import React from 'react';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Space, Tag, Button } from 'antd';
import { HolderOutlined, DeleteOutlined } from '@ant-design/icons';

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
    <div ref={setNodeRef} style={style} onClick={onSelect}>
      <div style={{
        padding: '16px',
        margin: '12px 0',
        border: isSelected ? '2px solid #1890ff' : '1px solid #d9d9d9',
        borderRadius: '4px',
        cursor: 'pointer',
        background: isSelected ? '#e6f7ff' : 'white',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        transition: 'all 0.3s',
      }}>
        <Space>
          <div
            {...attributes}
            {...listeners}
            style={{
              cursor: 'grab',
              padding: '4px 8px',
              color: '#999',
              fontSize: '16px',
              userSelect: 'none',
              WebkitUserSelect: 'none',
              touchAction: 'none',
            }}
          >
            <HolderOutlined />
          </div>
          <strong style={{ userSelect: 'none' }}>{field.label || '未命名字段'}</strong>
          <Tag color="blue">{field.type}</Tag>
          {field.required && <Tag color="red">必填</Tag>}
        </Space>
        <Button
          type="text"
          danger
          icon={<DeleteOutlined />}
          onClick={(e) => {
            e.stopPropagation();
            onDelete();
          }}
        >
          删除
        </Button>
      </div>
    </div>
  );
};
