import React from 'react';
import type { DragItem } from '@lowcode/shared';

interface Props {
  item: DragItem;
}

export function DragPreview({ item }: Props) {
  return (
    <div style={{
      position: 'fixed', padding: '5px 10px',
      background: item.isLayout ? '#059669' : '#2563EB',
      color: '#fff', borderRadius: 3, fontSize: 10,
      pointerEvents: 'none', zIndex: 9999,
      boxShadow: '0 4px 8px rgba(0,0,0,0.15)', opacity: 0.9,
      display: 'flex', alignItems: 'center', gap: 4,
    }}>
      {item.isLayout ? '⬜' : '📝'} {item.label}
    </div>
  );
}
