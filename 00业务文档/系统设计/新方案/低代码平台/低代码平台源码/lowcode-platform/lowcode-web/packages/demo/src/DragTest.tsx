import React, { useState } from 'react';
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Space, Tag, Button } from 'antd';
import { HolderOutlined, DeleteOutlined } from '@ant-design/icons';

interface FieldItem {
  id: string;
  label: string;
  type: string;
}

// 可排序项组件
const SortableItem: React.FC<{
  field: FieldItem;
  isSelected: boolean;
  onSelect: () => void;
  onDelete: () => void;
}> = ({ field, isSelected, onSelect, onDelete }) => {
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
    padding: '16px',
    margin: '12px 0',
    border: isSelected ? '2px solid #1890ff' : '1px solid #d9d9d9',
    borderRadius: '4px',
    cursor: 'pointer',
    background: isSelected ? '#e6f7ff' : 'white',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  };

  return (
    <div ref={setNodeRef} style={style} onClick={onSelect}>
      <Space>
        <div
          {...attributes}
          {...listeners}
          style={{
            cursor: 'grab',
            padding: '4px 8px',
            color: '#999',
            fontSize: '16px',
          }}
        >
          <HolderOutlined />
        </div>
        <strong>{field.label}</strong>
        <Tag color="blue">{field.type}</Tag>
      </Space>
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
  );
};

// 测试组件
export const DragTest: React.FC = () => {
  const [fields, setFields] = useState<FieldItem[]>([
    { id: '1', label: '字段1', type: 'input' },
    { id: '2', label: '字段2', type: 'select' },
    { id: '3', label: '字段3', type: 'date' },
  ]);
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      setFields((items) => {
        const oldIndex = items.findIndex((item) => item.id === active.id);
        const newIndex = items.findIndex((item) => item.id === over.id);
        return arrayMove(items, oldIndex, newIndex);
      });
    }
  };

  return (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <h2>拖拽测试</h2>
      <p style={{ color: '#666', marginBottom: '20px' }}>
        抓住左侧的 ≡ 图标拖动字段重新排序
      </p>

      <DndContext
        sensors={sensors}
        collisionDetection={closestCenter}
        onDragEnd={handleDragEnd}
      >
        <SortableContext items={fields} strategy={verticalListSortingStrategy}>
          {fields.map((field, index) => (
            <SortableItem
              key={field.id}
              field={field}
              isSelected={selectedIndex === index}
              onSelect={() => setSelectedIndex(index)}
              onDelete={() => {
                setFields(fields.filter((_, i) => i !== index));
                setSelectedIndex(null);
              }}
            />
          ))}
        </SortableContext>
      </DndContext>

      <div style={{ marginTop: '20px', padding: '12px', background: '#f0f0f0', borderRadius: '4px' }}>
        <strong>当前顺序：</strong>
        {fields.map((f, i) => (
          <span key={f.id}>
            {i > 0 && ' → '}
            {f.label}
          </span>
        ))}
      </div>
    </div>
  );
};
