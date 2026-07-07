import React from 'react';
import { useDroppable } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { SortableFieldItem } from './SortableFieldItem';
import { FieldNode, isContainerComponent } from './treeUtils';

interface NestedFieldsRendererProps {
  fields: FieldNode[];
  selectedIndex: number | null;
  onFieldSelect: (id: string) => void;
  onFieldDelete: (id: string) => void;
  parentId?: string | null;
  level?: number;
}

/**
 * 递归渲染嵌套字段
 */
export const NestedFieldsRenderer: React.FC<NestedFieldsRendererProps> = ({
  fields,
  selectedIndex,
  onFieldSelect,
  onFieldDelete,
  parentId = null,
  level = 0,
}) => {
  const droppableId = parentId || 'root';
  const { setNodeRef, isOver } = useDroppable({
    id: `droppable-${droppableId}`,
    data: { parentId, accepts: ['field'] },
  });

  if (fields.length === 0 && level > 0) {
    // 容器内的空状态
    return (
      <div
        ref={setNodeRef}
        style={{
          padding: '20px',
          textAlign: 'center',
          color: '#999',
          background: isOver ? '#e6f7ff' : 'white',
          border: '1px dashed #d9d9d9',
          borderRadius: '4px',
          minHeight: '60px',
          transition: 'all 0.3s',
        }}
      >
        📦 拖拽组件到这里
      </div>
    );
  }

  return (
    <div
      ref={setNodeRef}
      style={{
        background: isOver && level > 0 ? '#e6f7ff' : 'transparent',
        borderRadius: '4px',
        transition: 'all 0.3s',
        paddingLeft: level > 0 ? '16px' : '0',
      }}
    >
      <SortableContext items={fields.map(f => f.id)} strategy={verticalListSortingStrategy}>
        {fields.map((field) => {
          const isContainer = isContainerComponent(field.type);
          const isSelected = selectedIndex === field.id;

          return (
            <div key={field.id}>
              <SortableFieldItem
                field={field}
                index={field.id}
                isSelected={isSelected}
                onSelect={() => onFieldSelect(field.id)}
                onDelete={() => onFieldDelete(field.id)}
                isContainer={isContainer}
              >
                {/* 如果是容器组件且有子组件，递归渲染 */}
                {isContainer && field.children && field.children.length > 0 && (
                  <div style={{ paddingTop: '8px' }}>
                    <NestedFieldsRenderer
                      fields={field.children}
                      selectedIndex={selectedIndex}
                      onFieldSelect={onFieldSelect}
                      onFieldDelete={onFieldDelete}
                      parentId={field.id}
                      level={level + 1}
                    />
                  </div>
                )}
              </SortableFieldItem>
            </div>
          );
        })}
      </SortableContext>
    </div>
  );
};
