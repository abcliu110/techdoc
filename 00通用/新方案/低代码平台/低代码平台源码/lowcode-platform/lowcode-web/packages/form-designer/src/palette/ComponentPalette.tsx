import React from 'react';
import { useDraggable } from '@dnd-kit/core';
import { CSS } from '@dnd-kit/utilities';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';
import {
  PALETTE_CATEGORIES, ELEMENT_LABELS, LAYOUT_CONTROLS, LAYOUT_CONTROL_ICONS,
  type ElementType, type LayoutControlType, type DragItem,
} from '@lowcode/shared';

// ================================ 布局控件拖拽项 ================================

function DraggableLayoutItem({ type, label, icon, priority, description }: {
  type: LayoutControlType;
  label: string;
  icon: string;
  priority: string;
  description: string;
}) {
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: `palette-layout-${type}`,
    data: {
      item: { type, label, isLayout: true } as DragItem,
    } as Parameters<typeof useDraggable>[0]['data'],
  });

  return (
    <div
      ref={setNodeRef}
      {...listeners}
      {...attributes}
      style={{
        display: 'grid',
        gridTemplateColumns: '16px minmax(0, 1fr) auto',
        alignItems: 'center',
        gap: 4,
        padding: '0 6px',
        height: 26,
        borderBottom: '1px solid #edf2f7',
        fontSize: 10,
        color: '#334155',
        cursor: 'grab',
        background: isDragging ? '#F3F7FF' : undefined,
        opacity: isDragging ? 0.5 : 1,
      }}
    >
      <div style={{
        width: 15, height: 15,
        display: 'grid', placeItems: 'center',
        border: '1px solid #A7B4C5',
        borderRadius: 2,
        background: '#fff',
        color: priority === 'P0' ? '#b42318' : '#64748b',
        fontSize: 9, fontWeight: 700,
      }}>{icon}</div>
      <div style={{ overflow: 'hidden' }}>
        <div style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontWeight: 500 }}>{label}</div>
        <div style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', color: '#94a3b8', fontSize: 9 }}>{description}</div>
      </div>
      <span style={{
        color: priority === 'P0' ? '#b42318' : '#94a3b8',
        fontSize: 9, fontWeight: 700,
      }}>{priority}</span>
    </div>
  );
}

// ================================ 业务字段拖拽项 ================================

function DraggableFieldItem({ type, label }: { type: ElementType; label: string }) {
  const { attributes, listeners, setNodeRef, isDragging } = useDraggable({
    id: `palette-field-${type}`,
    data: {
      item: { type, label, isLayout: false } as DragItem,
    } as Parameters<typeof useDraggable>[0]['data'],
  });

  return (
    <div
      ref={setNodeRef}
      {...listeners}
      {...attributes}
      style={{
        display: 'grid',
        gridTemplateColumns: '16px minmax(0, 1fr)',
        alignItems: 'center',
        gap: 4,
        padding: '0 6px',
        height: 24,
        borderBottom: '1px solid #edf2f7',
        fontSize: 10,
        color: '#334155',
        cursor: 'grab',
        background: isDragging ? '#F3F7FF' : undefined,
        opacity: isDragging ? 0.5 : 1,
      }}
    >
      <div style={{
        width: 15, height: 15,
        display: 'grid', placeItems: 'center',
        border: '1px solid #A7B4C5',
        borderRadius: 2,
        background: '#fff',
        color: '#526174',
        fontSize: 9, fontWeight: 700,
      }}>{ELEMENT_LABELS[type]?.charAt(0)}</div>
      <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{label}</span>
    </div>
  );
}

// ================================ 布局控件工具箱（新增） ================================

function LayoutToolbox() {
  return (
    <div style={{ marginBottom: 6 }}>
      <div style={{
        height: 20,
        display: 'flex', alignItems: 'center',
        padding: '0 6px',
        background: '#F5F7FA',
        border: '1px solid #D8DEE8',
        borderBottom: 0,
        fontSize: 10, fontWeight: 700, color: '#66758A',
      }}>
        Web 布局容器
      </div>
      <div style={{ border: '1px solid #D8DEE8', background: '#fff' }}>
        {LAYOUT_CONTROLS.map(ctrl => (
          <DraggableLayoutItem
            key={ctrl.type}
            type={ctrl.type}
            label={ctrl.label}
            icon={ctrl.icon}
            priority={ctrl.priority}
            description={ctrl.description}
          />
        ))}
      </div>
    </div>
  );
}

// ================================ 业务字段工具箱 ================================

function FieldToolbox({ search }: { search: string }) {
  const categories = PALETTE_CATEGORIES.filter(cat => {
    if (!search) return true;
    return cat.types.some(t => ELEMENT_LABELS[t].includes(search));
  });

  return (
    <div>
      {categories.map(cat => {
        const types = cat.types.filter(t => !search || ELEMENT_LABELS[t].includes(search));
        if (types.length === 0) return null;
        return (
          <div key={cat.key} style={{ marginBottom: 6 }}>
            <div style={{
              height: 20,
              display: 'flex', alignItems: 'center',
              padding: '0 6px',
              background: '#F5F7FA',
              border: '1px solid #D8DEE8',
              borderBottom: 0,
              fontSize: 10, fontWeight: 700, color: '#66758A',
            }}>{cat.label}</div>
            <div style={{ border: '1px solid #D8DEE8' }}>
              {types.map(type => (
                <DraggableFieldItem key={type} type={type} label={ELEMENT_LABELS[type]} />
              ))}
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ================================ 主组件 ================================

export function ComponentPalette({ search }: { search: string }) {
  return (
    <div>
      {/* 布局控件 — 放在最上面 */}
      <LayoutToolbox />
      {/* 业务字段 */}
      <FieldToolbox search={search} />
    </div>
  );
}

