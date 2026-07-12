/**
 * 设计画布 — 拖放目标区域
 * 包含 DndContext、DndOverlay、布局控件渲染区
 */
import React, { useState, useCallback } from 'react';
import {
  DndContext, DragEndEvent, DragOverlay, useSensor, useSensors,
  PointerSensor, DragStartEvent,
} from '@dnd-kit/core';
import { useDroppable } from '@dnd-kit/core';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';
import { WebPageRenderer } from './WebPageRenderer';
import type { DragItem } from '@lowcode/shared';

/** 画布背景区（可拖入布局控件） */
function CanvasDropZone() {
  const { setNodeRef, isOver } = useDroppable({ id: 'canvas-drop', data: { slot: 'canvas' } });

  return (
    <div
      ref={setNodeRef}
      style={{ flex: 1, background: isOver ? 'rgba(37,99,235,0.05)' : '#E8EDF4', transition: 'background 0.15s', overflow: 'auto' }}
    >
      <div style={{
        minHeight: '100%',
        padding: 12,
        background: 'repeating-linear-gradient(#EDF2F7 0px, #EDF2F7 1px, transparent 1px, transparent 22px), repeating-linear-gradient(90deg, #EDF2F7 0px, #EDF2F7 1px, transparent 1px, transparent 22px), #DFE7F0',
        backgroundSize: '22px 22px',
        position: 'relative',
      }}>
        {isOver && (
          <div style={{
            position: 'absolute', inset: 0, display: 'grid', placeItems: 'center',
            border: '2px dashed #2563EB', background: 'rgba(37,99,235,0.06)',
            color: '#2563EB', fontSize: 12, borderRadius: 4, zIndex: 10, pointerEvents: 'none',
          }}>
            可投放布局控件到页面
          </div>
        )}
        <WebPageRenderer />
      </div>
    </div>
  );
}

export const DesignerCanvas = observer(() => {
  const [activeItem, setActiveItem] = useState<DragItem | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 5 } }),
  );

  const handleDragStart = useCallback((event: DragStartEvent) => {
    const item = event.active.data.current?.item as DragItem | undefined;
    if (item) setActiveItem(item);
  }, []);

  const handleDragEnd = useCallback((event: DragEndEvent) => {
    setActiveItem(null);
    const { active, over } = event;
    if (!over) return;

    const item = active.data.current?.item as DragItem | undefined;
    if (!item) return;

    // 投放目标：布局控件插槽 或 空白画布
    const target = over.data.current as { nodeId?: string; slot?: string } | undefined;
    if (target?.nodeId && target?.slot) {
      store.addFromDrag(target.nodeId, item, target.slot);
      return;
    }

    // 空白画布 — 仅布局控件可投放到根
    if (over.id === 'canvas-drop' && item.isLayout) {
      const rootId = (store.formDef.schema as unknown as { id?: string }).id
        || store.formDef.schema.nodeId;
      store.addFromDrag(rootId, item, 'default');
    }
  }, []);

  return (
    <DndContext sensors={sensors} onDragStart={handleDragStart} onDragEnd={handleDragEnd}>
      <div style={{ display: 'flex', flex: 1, minHeight: 0, overflow: 'hidden' }}>
        <CanvasDropZone />
      </div>

      <DragOverlay>
        {activeItem ? (
          <div style={{
            padding: '4px 10px',
            background: '#2563EB', color: '#fff', borderRadius: 3,
            fontSize: 10, boxShadow: '0 4px 8px rgba(0,0,0,0.15)', opacity: 0.9,
          }}>
            {activeItem.isLayout && '⬜ '}{activeItem.label}
          </div>
        ) : null}
      </DragOverlay>
    </DndContext>
  );
});
