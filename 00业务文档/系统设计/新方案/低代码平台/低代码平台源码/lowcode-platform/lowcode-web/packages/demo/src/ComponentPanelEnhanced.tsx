import React from 'react';
import { useDraggable } from '@dnd-kit/core';
import { CSS } from '@dnd-kit/utilities';
import { List, Space, Tag } from 'antd';

interface DraggableComponentProps {
  type: string;
  label: string;
  icon: string;
  highlight?: boolean;
}

// 可拖拽的组件项
const DraggableComponent: React.FC<DraggableComponentProps> = ({ type, label, icon, highlight }) => {
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: `component-${type}`,
    data: { type, label },
  });

  const style: React.CSSProperties = {
    cursor: 'grab',
    padding: '10px 12px',
    border: highlight ? '2px solid #ff4d4f' : '1px solid #d9d9d9',
    marginBottom: '8px',
    borderRadius: '4px',
    background: highlight ? '#fff1f0' : 'white',
    transition: 'all 0.3s',
    opacity: isDragging ? 0.5 : 1,
    transform: CSS.Translate.toString(transform),
    userSelect: 'none',
  };

  return (
    <div
      ref={setNodeRef}
      {...attributes}
      {...listeners}
      style={style}
      onMouseEnter={(e) => {
        if (!isDragging) {
          e.currentTarget.style.background = highlight ? '#ffccc7' : '#e6f7ff';
          e.currentTarget.style.borderColor = '#1890ff';
          e.currentTarget.style.transform = 'translateX(4px)';
        }
      }}
      onMouseLeave={(e) => {
        if (!isDragging) {
          e.currentTarget.style.background = highlight ? '#fff1f0' : 'white';
          e.currentTarget.style.borderColor = highlight ? '#ff4d4f' : '#d9d9d9';
          e.currentTarget.style.transform = 'translateX(0)';
        }
      }}
    >
      <Space>
        <span style={{ fontSize: '18px' }}>{icon}</span>
        <span style={{ fontSize: '13px' }}>
          <strong>{label}</strong>
        </span>
        {highlight && (
          <Tag color="red" style={{ fontSize: '10px', padding: '0 4px' }}>
            高级
          </Tag>
        )}
      </Space>
    </div>
  );
};

export interface ComponentPanelEnhancedProps {
  onAddField?: (type: string) => void;
}

export const ComponentPanelEnhanced: React.FC<ComponentPanelEnhancedProps> = ({ onAddField }) => {
  const componentGroups = [
    {
      title: '📝 基础组件 (P0) - 8个',
      components: [
        { type: 'input', label: '输入框', icon: '📝' },
        { type: 'inputNumber', label: '数字输入', icon: '🔢' },
        { type: 'select', label: '下拉选择', icon: '📋' },
        { type: 'datePicker', label: '日期选择', icon: '📅' },
        { type: 'checkbox', label: '复选框', icon: '☑️' },
        { type: 'radio', label: '单选框', icon: '⭕' },
        { type: 'switch', label: '开关', icon: '🔘' },
        { type: 'button', label: '按钮', icon: '🔳' },
      ],
    },
    {
      title: '🎯 重要组件 (P1) - 8个',
      components: [
        { type: 'textarea', label: '多行文本', icon: '📄' },
        { type: 'upload', label: '文件上传', icon: '📤' },
        { type: 'cascader', label: '级联选择', icon: '🔗' },
        { type: 'timePicker', label: '时间选择', icon: '⏰' },
        { type: 'rangePicker', label: '范围选择', icon: '📊' },
        { type: 'autoComplete', label: '自动完成', icon: '🔍' },
        { type: 'rate', label: '评分', icon: '⭐' },
        { type: 'tag', label: '标签', icon: '🏷️' },
      ],
    },
    {
      title: '🏗️ 布局组件 - 4个',
      components: [
        { type: 'card', label: '卡片', icon: '🗂️' },
        { type: 'tabs', label: '标签页', icon: '📑' },
        { type: 'collapse', label: '折叠面板', icon: '📁' },
        { type: 'divider', label: '分割线', icon: '➖' },
      ],
    },
    {
      title: '🔥 高级组件 (P2) - 7个',
      components: [
        { type: 'subTable', label: '子表', icon: '📋', highlight: true },
        { type: 'richText', label: '富文本', icon: '📝' },
        { type: 'tree', label: '树形控件', icon: '🌲' },
        { type: 'transfer', label: '穿梭框', icon: '⇄' },
        { type: 'slider', label: '滑块', icon: '🎚️' },
        { type: 'colorPicker', label: '颜色选择', icon: '🎨' },
        { type: 'calendar', label: '日历', icon: '📆' },
      ],
    },
  ];

  return (
    <div style={{ padding: '16px', height: '100vh', overflow: 'auto' }}>
      <h3 style={{ marginBottom: '16px' }}>📦 组件库</h3>

      {componentGroups.map((group, groupIndex) => (
        <div key={groupIndex} style={{ marginBottom: '24px' }}>
          <h4 style={{
            fontSize: '13px',
            color: '#666',
            marginBottom: '12px',
            fontWeight: 'bold'
          }}>
            {group.title}
          </h4>
          <div>
            {group.components.map(item => (
              <DraggableComponent
                key={item.type}
                type={item.type}
                label={item.label}
                icon={item.icon}
                highlight={item.highlight}
              />
            ))}
          </div>
        </div>
      ))}

      <div style={{ marginTop: '24px', padding: '12px', background: '#fff7e6', borderRadius: '4px', fontSize: '12px' }}>
        <div><strong>💡 使用提示</strong></div>
        <div style={{ marginTop: '8px', color: '#666' }}>
          • 拖动组件到画布添加<br/>
          • 画布内拖动排序<br/>
          • <strong>共27个组件</strong>完整支持
        </div>
      </div>
    </div>
  );
};
