/**
 * 组件面板
 * 展示 29 个可拖拽组件，按优先级和类型分组
 * 每个组件都有 AI 可控性抓手（data-testid="palette-{type}"）
 */

import React from 'react';
import { useDraggable } from '@dnd-kit/core';
import { CSS } from '@dnd-kit/utilities';
import { Tag } from 'antd';
import { ELEMENT_TYPES, type ElementType } from '../elementCapabilities';
import { ELEMENT_LABELS, ELEMENT_CATEGORIES } from '../types';

/** 组件图标映射 */
const ELEMENT_ICONS: Record<ElementType, string> = {
  // 基础
  input: '📝',
  inputNumber: '🔢',
  select: '📋',
  datePicker: '📅',
  checkbox: '☑️',
  radio: '⭕',
  switch: '🔘',
  button: '🔳',
  textarea: '📄',
  // 高级
  upload: '📤',
  cascader: '🔗',
  timePicker: '⏰',
  rangePicker: '📊',
  autoComplete: '🔍',
  rate: '⭐',
  subTable: '📋',
  richText: '📝',
  tree: '🌲',
  transfer: '⇄',
  slider: '🎚️',
  colorPicker: '🎨',
  // 布局
  card: '🗂️',
  tabs: '📑',
  collapse: '📁',
  // 展示
  tag: '🏷️',
  divider: '➖',
  // 特殊
  calendar: '📆',
};

interface DraggableComponentProps {
  type: ElementType;
  label: string;
  icon: string;
  isAdvanced?: boolean;
  onAdd?: (type: ElementType) => void;
}

/**
 * 可拖拽的组件项
 * 支持：拖拽添加、点击添加（E2E 测试友好）
 */
const DraggableComponent: React.FC<DraggableComponentProps> = ({
  type,
  label,
  icon,
  isAdvanced = false,
  onAdd,
}) => {
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: `component-${type}`,
    data: { type, label },
  });

  const style: React.CSSProperties = {
    cursor: 'grab',
    padding: '4px 6px',
    border: isAdvanced ? '1px solid #ff4d4f' : '1px solid #d9d9d9',
    borderRadius: '4px',
    background: isAdvanced ? '#fff1f0' : 'white',
    transition: 'all 0.2s',
    opacity: isDragging ? 0.5 : 1,
    transform: CSS.Translate.toString(transform),
    userSelect: 'none',
    fontSize: '10px',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: '45px',
  };

  return (
    <div
      ref={setNodeRef}
      {...attributes}
      {...listeners}
      data-testid={`palette-${type}`}
      data-component-type={type}
      aria-label={`添加${label}`}
      draggable="true"
      style={style}
      onClick={() => onAdd?.(type)}
      onMouseEnter={(e) => {
        if (!isDragging) {
          e.currentTarget.style.background = isAdvanced ? '#ffccc7' : '#e6f7ff';
          e.currentTarget.style.borderColor = '#1890ff';
        }
      }}
      onMouseLeave={(e) => {
        if (!isDragging) {
          e.currentTarget.style.background = isAdvanced ? '#fff1f0' : 'white';
          e.currentTarget.style.borderColor = isAdvanced ? '#ff4d4f' : '#d9d9d9';
        }
      }}
    >
      <div style={{ fontSize: '14px', marginBottom: '2px' }}>{icon}</div>
      <div style={{ fontSize: '10px', textAlign: 'center', lineHeight: '1.2' }}>
        {label}
      </div>
      {isAdvanced && (
        <Tag
          color="red"
          style={{
            fontSize: '9px',
            padding: '0 2px',
            marginTop: '2px',
            lineHeight: '12px',
          }}
        >
          高级
        </Tag>
      )}
    </div>
  );
};

export interface ComponentPanelProps {
  onAddField?: (type: ElementType) => void;
}

export const ComponentPanel: React.FC<ComponentPanelProps> = ({ onAddField }) => {
  // 按分类分组
  const basicTypes = ELEMENT_TYPES.filter(t => ELEMENT_CATEGORIES[t] === 'basic');
  const advancedTypes = ELEMENT_TYPES.filter(t => ELEMENT_CATEGORIES[t] === 'advanced');
  const layoutTypes = ELEMENT_TYPES.filter(t => ELEMENT_CATEGORIES[t] === 'layout');
  const displayTypes = ELEMENT_TYPES.filter(t => ELEMENT_CATEGORIES[t] === 'display');

  return (
    <div
      data-testid="component-panel"
      style={{ padding: '16px', height: '100vh', overflow: 'auto' }}
    >
      <h3 style={{ marginBottom: '16px', fontSize: '14px' }}>
        📦 组件库 ({ELEMENT_TYPES.length}个)
      </h3>

      {/* 基础组件 */}
      <div style={{ marginBottom: '20px' }}>
        <h4
          style={{
            fontSize: '12px',
            color: '#666',
            marginBottom: '8px',
            fontWeight: 'bold',
            borderBottom: '1px solid #f0f0f0',
            paddingBottom: '4px',
          }}
        >
          📝 基础组件 ({basicTypes.length}个)
        </h4>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(5, 1fr)',
            gap: '4px',
          }}
        >
          {basicTypes.map(type => (
            <DraggableComponent
              key={type}
              type={type}
              label={ELEMENT_LABELS[type]}
              icon={ELEMENT_ICONS[type]}
              onAdd={onAddField}
            />
          ))}
        </div>
      </div>

      {/* 高级组件 */}
      <div style={{ marginBottom: '20px' }}>
        <h4
          style={{
            fontSize: '12px',
            color: '#666',
            marginBottom: '8px',
            fontWeight: 'bold',
            borderBottom: '1px solid #f0f0f0',
            paddingBottom: '4px',
          }}
        >
          🎯 高级组件 ({advancedTypes.length}个)
        </h4>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(5, 1fr)',
            gap: '4px',
          }}
        >
          {advancedTypes.map(type => (
            <DraggableComponent
              key={type}
              type={type}
              label={ELEMENT_LABELS[type]}
              icon={ELEMENT_ICONS[type]}
              isAdvanced
              onAdd={onAddField}
            />
          ))}
        </div>
      </div>

      {/* 布局组件 */}
      <div style={{ marginBottom: '20px' }}>
        <h4
          style={{
            fontSize: '12px',
            color: '#666',
            marginBottom: '8px',
            fontWeight: 'bold',
            borderBottom: '1px solid #f0f0f0',
            paddingBottom: '4px',
          }}
        >
          🏗️ 布局组件 ({layoutTypes.length}个)
        </h4>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(5, 1fr)',
            gap: '4px',
          }}
        >
          {layoutTypes.map(type => (
            <DraggableComponent
              key={type}
              type={type}
              label={ELEMENT_LABELS[type]}
              icon={ELEMENT_ICONS[type]}
              onAdd={onAddField}
            />
          ))}
        </div>
      </div>

      {/* 展示组件 */}
      <div style={{ marginBottom: '20px' }}>
        <h4
          style={{
            fontSize: '12px',
            color: '#666',
            marginBottom: '8px',
            fontWeight: 'bold',
            borderBottom: '1px solid #f0f0f0',
            paddingBottom: '4px',
          }}
        >
          👁️ 展示组件 ({displayTypes.length}个)
        </h4>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(5, 1fr)',
            gap: '4px',
          }}
        >
          {displayTypes.map(type => (
            <DraggableComponent
              key={type}
              type={type}
              label={ELEMENT_LABELS[type]}
              icon={ELEMENT_ICONS[type]}
              onAdd={onAddField}
            />
          ))}
        </div>
      </div>

      {/* 使用提示 */}
      <div
        style={{
          marginTop: '16px',
          padding: '8px',
          background: '#fff7e6',
          borderRadius: '4px',
          fontSize: '11px',
        }}
      >
        <div><strong>💡 使用提示</strong></div>
        <div style={{ marginTop: '6px', color: '#666', lineHeight: '1.4' }}>
          • 拖动到画布添加<br />
          • 拖到容器内嵌套<br />
          • 共{ELEMENT_TYPES.length}个组件
        </div>
      </div>
    </div>
  );
};
