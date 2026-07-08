import React from 'react';
import { useDroppable } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { SortableFieldItem } from './SortableFieldItem';
import { FieldNode, isContainerComponent } from './treeUtils';

interface ContainerDropZoneProps {
  containerId: string;
  containerType: string;
  children?: React.ReactNode;
  isEmpty: boolean;
}

/**
 * 容器内的可放置区域
 */
const ContainerDropZone: React.FC<ContainerDropZoneProps> = ({ containerId, containerType, children, isEmpty }) => {
  const { setNodeRef, isOver } = useDroppable({
    id: `container-${containerId}`,
    data: { containerId, type: 'container' },
  });

  if (isEmpty) {
    return (
      <div
        ref={setNodeRef}
        data-testid={`drop-zone-${containerType}`}
        data-container-id={containerId}
        style={{
          padding: '20px',
          textAlign: 'center',
          color: '#999',
          background: isOver ? '#e6f7ff' : 'white',
          border: isOver ? '2px dashed #1890ff' : '1px dashed #d9d9d9',
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
      data-testid={`drop-zone-${containerType}`}
      data-container-id={containerId}
      style={{
        background: isOver ? '#e6f7ff' : 'transparent',
        borderRadius: '4px',
        transition: 'all 0.3s',
        minHeight: '40px',
        padding: '4px',
      }}
    >
      {children}
    </div>
  );
};

interface RenderFieldsProps {
  fields: FieldNode[];
  selectedId: string | null;
  onFieldSelect: (id: string) => void;
  onFieldDelete: (id: string) => void;
  level?: number;
}

/**
 * 递归渲染字段组件
 */
export const RenderFields: React.FC<RenderFieldsProps> = ({
  fields,
  selectedId,
  onFieldSelect,
  onFieldDelete,
  level = 0,
}) => {
  return (
    <SortableContext items={fields.map(f => f.id)} strategy={verticalListSortingStrategy}>
      {fields.map((field) => {
        const isContainer = isContainerComponent(field.type);
        const isSelected = selectedId === field.id;
        const hasChildren = field.children && field.children.length > 0;

        return (
          <SortableFieldItem
            key={field.id}
            field={field}
            index={field.id}
            isSelected={isSelected}
            onSelect={() => onFieldSelect(field.id)}
            onDelete={() => onFieldDelete(field.id)}
            isContainer={isContainer}
          >
            {/* 如果是容器组件，显示子组件或空状态 */}
            {isContainer && (
              <ContainerDropZone
                containerId={field.id}
                containerType={field.type}
                isEmpty={!hasChildren}
              >
                {hasChildren && (
                  <RenderFields
                    fields={field.children!}
                    selectedId={selectedId}
                    onFieldSelect={onFieldSelect}
                    onFieldDelete={onFieldDelete}
                    level={level + 1}
                  />
                )}
              </ContainerDropZone>
            )}
          </SortableFieldItem>
        );
      })}
    </SortableContext>
  );
};
