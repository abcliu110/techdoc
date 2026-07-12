/**
 * 布局控件渲染器
 * 根据 LayoutNode.type 渲染对应的布局控件 + 子节点插槽
 * 参考 T-207-Web布局控件原型库.html 的 16 种控件
 */
import React from 'react';
import { observer } from 'mobx-react-lite';
import { useDroppable } from '@dnd-kit/core';
import type { LayoutNode, LayoutControlType } from '@lowcode/shared';
import { LAYOUT_CONTROL_MAP } from '@lowcode/shared';

interface Props {
  node: LayoutNode;
  selected: boolean;
  onSelect: () => void;
}

/** 单个插槽的投放区 */
function SlotDropZone({
  nodeId,
  slotName,
  label,
  required,
  children,
}: {
  nodeId: string;
  slotName: string;
  label: string;
  required?: boolean;
  children?: React.ReactNode;
}) {
  const { setNodeRef, isOver } = useDroppable({
    id: `${nodeId}:${slotName}`,
    data: { nodeId, slot: slotName },
  });

  return (
    <div
      ref={setNodeRef}
      style={{
        minHeight: required ? 36 : 28,
        border: isOver
          ? '2px dashed #2563EB'
          : required
            ? '1px dashed #93c5fd'
            : '1px dashed #bfdbfe',
        background: isOver ? 'rgba(37,99,235,0.07)' : 'transparent',
        display: 'grid',
        placeItems: 'center',
        color: isOver ? '#2563EB' : '#94a3b8',
        fontSize: 10,
        borderRadius: 3,
        padding: '3px 6px',
        position: 'relative',
        transition: 'border-color 0.15s, background 0.15s',
      }}
    >
      {required && !children && (
        <span style={{ fontSize: 9 }}>{label}</span>
      )}
      {children}
    </div>
  );
}

/** GridLayout 网格布局 */
function GridLayoutRenderer({ node, selected, onSelect }: Props) {
  const { children } = node.slots ?? {};
  const meta = LAYOUT_CONTROL_MAP.get('gridContainer');
  const gap = node.props?.gap as string || '8px';
  const columns = node.props?.columns as string || 'repeat(24, 1fr)';

  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateColumns: columns,
        gap,
        ...node.style,
        position: 'relative',
        minHeight: 60,
        border: selected ? '2px solid #2563EB' : '1px dashed #d1d5db',
        borderRadius: 3,
        padding: 8,
        background: selected ? 'rgba(37,99,235,0.03)' : '#fafafa',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [{meta?.label}]
        </div>
      )}
      {/* 四角调整手柄 */}
      {selected && ['tl','tr','bl','br'].map(pos => (
        <div key={pos} style={{
          position: 'absolute',
          width: 6, height: 6,
          border: '1px solid #2563EB', background: '#fff',
          zIndex: 4,
          ...(pos === 'tl' ? { left: -3, top: -3 } : {}),
          ...(pos === 'tr' ? { right: -3, top: -3 } : {}),
          ...(pos === 'bl' ? { left: -3, bottom: -3 } : {}),
          ...(pos === 'br' ? { right: -3, bottom: -3 } : {}),
        }} />
      ))}

      {/* 主区域插槽 */}
      <div style={{ gridColumn: '1 / -1' }}>
        <SlotDropZone nodeId={node.id} slotName="default" label="主区域" required />
        {children?.length ? children.map(child => (
          <LayoutControlRenderer key={child.id} node={child} selected={false} onSelect={() => {}} />
        )) : null}
      </div>
    </div>
  );
}

/** FormGridContainer 表单网格 — 24 列栅格 + label + editor */
function FormGridRenderer({ node, selected, onSelect }: Props) {
  const { children } = node.slots ?? {};
  const columns = (node.props?.columns as number) || 24;
  const labelWidth = (node.props?.labelWidth as string) || '78px';
  const gap = node.props?.gap as string || '6px 8px';
  const [rowGap, colGap] = gap.split(' ');

  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))`,
        gap: `${rowGap || gap} ${colGap || gap}`,
        padding: '22px 8px 8px',
        ...node.style,
        position: 'relative',
        minHeight: 44,
        border: selected ? '2px solid #2563EB' : '1px solid #e5e7eb',
        borderRadius: 3,
        background: '#fff',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [FormGridContainer]
        </div>
      )}
      {selected && ['tl','tr','bl','br'].map(pos => (
        <div key={pos} style={{
          position: 'absolute',
          width: 6, height: 6,
          border: '1px solid #2563EB', background: '#fff',
          zIndex: 4,
          ...(pos === 'tl' ? { left: -3, top: -3 } : {}),
          ...(pos === 'tr' ? { right: -3, top: -3 } : {}),
          ...(pos === 'bl' ? { left: -3, bottom: -3 } : {}),
          ...(pos === 'br' ? { right: -3, bottom: -3 } : {}),
        }} />
      ))}

      {/* 字段插槽 */}
      <SlotDropZone nodeId={node.id} slotName="default" label={`${columns} 列字段区域`} required />
    </div>
  );
}

/** FlexLayout 弹性布局 */
function FlexLayoutRenderer({ node, selected, onSelect }: Props) {
  const { children } = node.slots ?? {};
  const direction = node.props?.direction as string || 'row';
  const wrap = node.props?.wrap !== false;
  const gap = node.props?.gap as string || '8px';

  return (
    <div
      onClick={onSelect}
      style={{
        display: 'flex',
        flexDirection: direction as 'row' | 'column',
        flexWrap: wrap ? 'wrap' : 'nowrap',
        gap,
        padding: 4,
        ...node.style,
        position: 'relative',
        minHeight: 32,
        border: selected ? '2px solid #2563EB' : '1px dashed #93c5fd',
        borderRadius: 3,
        background: selected ? 'rgba(37,99,235,0.04)' : 'rgba(37,99,235,0.02)',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [FlexLayout]
        </div>
      )}
      <SlotDropZone nodeId={node.id} slotName="default" label="流式投放按钮/工具条" />
    </div>
  );
}

/** DockLayout 停靠布局 */
function DockLayoutRenderer({ node, selected, onSelect }: Props) {
  const slots = node.slots ?? {};
  const leftSize = (node.props?.leftSize as string) || '110px';
  const rightSize = (node.props?.rightSize as string) || '140px';

  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateColumns: `${leftSize} 1fr ${rightSize}`,
        height: '100%',
        ...node.style,
        position: 'relative',
        border: selected ? '2px solid #2563EB' : '1px solid #e5e7eb',
        borderRadius: 3,
        overflow: 'hidden',
        background: '#fff',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [DockLayout]
        </div>
      )}
      <SlotDropZone nodeId={node.id} slotName="left" label="左侧导航" />
      <SlotDropZone nodeId={node.id} slotName="fill" label="主体内容" required />
      <SlotDropZone nodeId={node.id} slotName="right" label="右侧信息" />
    </div>
  );
}

/** SplitPane 分割布局 */
function SplitLayoutRenderer({ node, selected, onSelect }: Props) {
  const direction = (node.props?.direction as string) || 'horizontal';
  const primaryRatio = (node.props?.primary as string) || '34%';

  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateColumns: direction === 'horizontal'
          ? `${primaryRatio} 8px 1fr`
          : '1fr',
        gridTemplateRows: direction === 'vertical'
          ? `${primaryRatio} 8px 1fr`
          : '1fr',
        minHeight: 120,
        ...node.style,
        position: 'relative',
        border: selected ? '2px solid #2563EB' : '1px dashed #93c5fd',
        borderRadius: 3,
        background: '#fafafa',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [SplitPane]
        </div>
      )}
      <SlotDropZone nodeId={node.id} slotName="primary" label="主面板" />
      {direction === 'horizontal' && (
        <div style={{
          background: '#e2e8f0',
          borderTop: '1px solid #cbd5e1',
          borderBottom: '1px solid #cbd5e1',
          display: 'grid',
          placeItems: 'center',
          cursor: 'col-resize',
        }}>
          <div style={{ width: 3, height: 28, background: '#94a3b8', borderRadius: 2 }} />
        </div>
      )}
      <SlotDropZone nodeId={node.id} slotName="secondary" label="次面板" />
    </div>
  );
}

/** ScrollContainer 滚动布局 */
function ScrollLayoutRenderer({ node, selected, onSelect }: Props) {
  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateRows: '32px 1fr',
        minHeight: 150,
        ...node.style,
        position: 'relative',
        border: selected ? '2px solid #2563EB' : '1px solid #e5e7eb',
        borderRadius: 3,
        overflow: 'hidden',
        background: '#fff',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [ScrollContainer]
        </div>
      )}
      <SlotDropZone nodeId={node.id} slotName="header" label="吸顶头部（可选）" />
      <div style={{ overflow: 'auto', padding: 8 }}>
        <SlotDropZone nodeId={node.id} slotName="default" label="滚动内容区域" required />
      </div>
    </div>
  );
}

/** StickyRegion 固定布局 */
function StickyLayoutRenderer({ node, selected, onSelect }: Props) {
  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateRows: 'auto 1fr auto',
        minHeight: 100,
        ...node.style,
        position: 'relative',
        border: selected ? '2px solid #2563EB' : '1px dashed #93c5fd',
        borderRadius: 3,
        background: '#fafafa',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [StickyRegion]
        </div>
      )}
      <SlotDropZone nodeId={node.id} slotName="stickyTop" label="顶部固定" />
      <SlotDropZone nodeId={node.id} slotName="body" label="滚动内容" required />
      <SlotDropZone nodeId={node.id} slotName="stickyBottom" label="底部固定" />
    </div>
  );
}

/** TabsContainer 页签布局 */
function TabsLayoutRenderer({ node, selected, onSelect }: Props) {
  const tabLabels = (node.props?.tabLabels as string[]) || ['Tab 1', 'Tab 2', 'Tab 3'];
  const activeTab = (node.props?.activeTab as number) || 0;

  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateRows: '34px 1fr',
        minHeight: 150,
        ...node.style,
        position: 'relative',
        border: selected ? '2px solid #2563EB' : '1px solid #e5e7eb',
        borderRadius: 3,
        overflow: 'hidden',
        background: '#fff',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [TabsContainer]
        </div>
      )}
      {/* Tab 标签栏 */}
      <div style={{
        display: 'flex', alignItems: 'end', gap: 2,
        padding: '0 8px',
        borderBottom: '1px solid #e5e7eb',
        background: '#f8fafc',
        overflow: 'hidden',
      }}>
        {tabLabels.map((label, i) => (
          <div key={i} style={{
            height: 28,
            padding: '0 10px',
            display: 'flex', alignItems: 'center',
            border: '1px solid',
            borderColor: i === activeTab ? '#d1d5db' : 'transparent',
            borderBottom: 0,
            borderRadius: '3px 3px 0 0',
            background: i === activeTab ? '#fff' : 'transparent',
            color: i === activeTab ? '#2563EB' : '#64748b',
            fontSize: 10,
            fontWeight: i === activeTab ? 700 : 400,
            cursor: 'pointer',
          }}>
            {label}
          </div>
        ))}
      </div>
      {/* Tab 内容插槽 */}
      <div style={{ padding: 8 }}>
        <SlotDropZone nodeId={node.id} slotName="panels" label="TabPanel 内容（懒加载）" required />
      </div>
    </div>
  );
}

/** PortalContainer 浮层布局 */
function PortalLayoutRenderer({ node, selected, onSelect }: Props) {
  return (
    <div
      onClick={onSelect}
      style={{
        position: 'relative',
        minHeight: 80,
        ...node.style,
        border: selected ? '2px solid #2563EB' : '1px dashed #93c5fd',
        borderRadius: 3,
        background: '#fafafa',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [PortalContainer]
        </div>
      )}
      <SlotDropZone nodeId={node.id} slotName="root" label="根页面" required />
      {/* 浮层模拟 */}
      <div style={{
        position: 'absolute', right: 24, top: 16,
        width: 180, height: 80,
        border: '1px solid #d1d5db',
        background: '#fff',
        boxShadow: '0 8px 16px rgba(0,0,0,0.12)',
        zIndex: 5,
        borderRadius: 3,
        display: 'grid',
        gridTemplateRows: '24px 1fr',
        overflow: 'hidden',
        fontSize: 10,
      }}>
        <div style={{
          padding: '0 8px',
          borderBottom: '1px solid #e5e7eb',
          background: '#f8fafc',
          display: 'flex', alignItems: 'center',
          color: '#334155', fontWeight: 700,
        }}>
          参照浮层
        </div>
        <div style={{ padding: 6 }}>
          <SlotDropZone nodeId={node.id} slotName="overlay" label="浮层内容" />
        </div>
      </div>
    </div>
  );
}

/** ResponsiveContainer 响应式布局 — 显示 3 个断点预览 */
function ResponsiveLayoutRenderer({ node, selected, onSelect }: Props) {
  const breakpoints = (node.props?.breakpoints as string[]) || ['1280', '1440', '1600'];

  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(3, 1fr)',
        gap: 8,
        minHeight: 120,
        ...node.style,
        position: 'relative',
        border: selected ? '2px solid #2563EB' : '1px solid #e5e7eb',
        borderRadius: 3,
        padding: 8,
        background: '#fafafa',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [ResponsiveContainer]
        </div>
      )}
      {breakpoints.map(bp => (
        <div key={bp} style={{
          border: '1px solid #e5e7eb',
          background: '#fff',
          borderRadius: 3,
          overflow: 'hidden',
          display: 'grid',
          gridTemplateRows: '24px 1fr',
        }}>
          <div style={{
            display: 'grid', placeItems: 'center',
            borderBottom: '1px solid #e5e7eb',
            background: '#f8fafc',
            color: '#64748b', fontSize: 9, fontWeight: 700,
          }}>
            {bp}px
          </div>
          <div style={{ padding: 6 }}>
            <SlotDropZone nodeId={node.id} slotName={`bp-${bp}`} label={`${bp} 布局`} />
          </div>
        </div>
      ))}
    </div>
  );
}

/** MasterDetailContainer 主从布局 */
function MasterDetailRenderer({ node, selected, onSelect }: Props) {
  return (
    <div
      onClick={onSelect}
      style={{
        display: 'grid',
        gridTemplateColumns: 'minmax(140px, 36%) 8px 1fr',
        minHeight: 180,
        ...node.style,
        position: 'relative',
        border: selected ? '2px solid #2563EB' : '1px solid #e5e7eb',
        borderRadius: 3,
        overflow: 'hidden',
        background: '#fff',
        cursor: 'pointer',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', top: -1, left: -1,
          height: 16, padding: '0 5px',
          background: '#2563EB', color: '#fff',
          fontSize: 9, display: 'flex', alignItems: 'center',
          borderRadius: '0 0 3px 0', zIndex: 3,
        }}>
          {node.label} [MasterDetail]
        </div>
      )}
      <div style={{ borderRight: '1px solid #e5e7eb', display: 'grid', gridTemplateRows: '28px 1fr' }}>
        <div style={{
          display: 'flex', alignItems: 'center', padding: '0 8px',
          borderBottom: '1px solid #e5e7eb',
          background: '#f8fafc', fontSize: 9, fontWeight: 700,
        }}>主表/列表</div>
        <div style={{ padding: 6 }}>
          <SlotDropZone nodeId={node.id} slotName="master" label="主表插槽" />
        </div>
      </div>
      <div style={{
        background: '#e2e8f0',
        display: 'grid', placeItems: 'center',
        cursor: 'col-resize',
      }}>
        <div style={{ width: 3, height: 28, background: '#94a3b8', borderRadius: 2 }} />
      </div>
      <div style={{ display: 'grid', gridTemplateRows: '28px 1fr' }}>
        <div style={{
          display: 'flex', alignItems: 'center', padding: '0 8px',
          borderBottom: '1px solid #e5e7eb',
          background: '#f8fafc', fontSize: 9, fontWeight: 700,
        }}>明细/详情</div>
        <div style={{ padding: 6 }}>
          <SlotDropZone nodeId={node.id} slotName="detail" label="明细插槽" />
        </div>
      </div>
    </div>
  );
}

/** 根据 LayoutNode.type 分派渲染器 */
const RENDERER_MAP: Record<LayoutControlType, React.FC<Props>> = {
  gridContainer: GridLayoutRenderer,
  formGridContainer: FormGridRenderer,
  flexContainer: FlexLayoutRenderer,
  dockContainer: DockLayoutRenderer,
  splitContainer: SplitLayoutRenderer,
  scrollContainer: ScrollLayoutRenderer,
  stickyContainer: StickyLayoutRenderer,
  tabsContainer: TabsLayoutRenderer,
  portalContainer: PortalLayoutRenderer,
  responsiveContainer: ResponsiveLayoutRenderer,
  masterDetailContainer: MasterDetailRenderer,
  stackContainer: GridLayoutRenderer,    // 复用网格布局（纵向堆叠）
  accordionContainer: GridLayoutRenderer, // 复用网格布局（折叠）
  cardGridContainer: GridLayoutRenderer,  // 复用网格布局（卡片网格）
  drawerContainer: PortalLayoutRenderer,  // 复用浮层布局
  dialogContainer: PortalLayoutRenderer,  // 复用浮层布局
};

/** 统一布局控件渲染入口 */
export const LayoutControlRenderer = observer(({ node, selected, onSelect }: Props) => {
  const Renderer = RENDERER_MAP[node.type] || GridLayoutRenderer;
  return <Renderer node={node} selected={selected} onSelect={onSelect} />;
});
