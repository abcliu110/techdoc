/**
 * 容器内子组件拖放区域
 * 提供 droppable zone，支持从组件面板拖入子组件
 */

import React from 'react';
import { useDroppable } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { Button } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import { SortableFieldItem } from './SortableFieldItem';
import type { DesignerFieldData } from '../types';

export interface ContainerDropZoneProps {
  containerId: string;
  children: DesignerFieldData[];
  selectedFieldId: string | null;
  onFieldSelect: (id: string) => void;
  onFieldDelete: (id: string) => void;
  depth?: number;
}

export const ContainerDropZone: React.FC<ContainerDropZoneProps> = ({
  containerId,
  children,
  selectedFieldId,
  onFieldSelect,
  onFieldDelete,
  depth = 0,
}) => {
  const droppableId = `drop-zone-${containerId}`;
  const { setNodeRef, isOver } = useDroppable({ id: droppableId });

  return (
    <div
      ref={setNodeRef}
      data-testid="container-drop-zone"
      data-container-id={containerId}
      style={{
        paddingLeft: `${24 + depth * 16}px`,
        borderLeft: '2px dashed #d9d9d9',
        marginTop: '8px',
        minHeight: children.length === 0 ? '48px' : '0',
        background: isOver ? '#e6f7ff' : 'transparent',
        borderRadius: '4px',
        transition: 'background 0.2s',
      }}
    >
      {children.length === 0 ? (
        /* 空容器提示 */
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            height: '48px',
            color: '#bbb',
            fontSize: '12px',
            border: '1px dashed #d9d9d9',
            borderRadius: '4px',
            margin: '4px 0',
          }}
        >
          拖动组件到这里
        </div>
      ) : (
        /* 子组件列表 */
        <SortableContext
          items={children.map(c => c.id)}
          strategy={verticalListSortingStrategy}
        >
          {children.map((child, index) => (
            <SortableFieldItem
              key={child.id}
              field={child}
              index={index}
              isSelected={selectedFieldId === child.id}
              onSelect={() => onFieldSelect(child.id)}
              onDelete={() => onFieldDelete(child.id)}
              selectedFieldIdFromParent={selectedFieldId}
              onFieldSelect={onFieldSelect}
              onFieldDelete={onFieldDelete}
            />
          ))}
        </SortableContext>
      )}
    </div>
  );
};
