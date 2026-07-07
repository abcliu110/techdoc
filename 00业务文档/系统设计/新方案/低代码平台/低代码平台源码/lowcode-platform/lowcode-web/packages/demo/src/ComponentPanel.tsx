import React from 'react';
import { List, Space, Tag } from 'antd';

export interface ComponentPanelProps {
  onAddField: (type: string) => void;
}

export const ComponentPanel: React.FC<ComponentPanelProps> = ({ onAddField }) => {
  const componentGroups = [
    {
      title: '📝 基础组件 (P0)',
      components: [
        { type: 'input', label: '输入框', icon: '📝' },
        { type: 'inputNumber', label: '数字输入', icon: '🔢' },
        { type: 'select', label: '下拉选择', icon: '📋' },
        { type: 'datePicker', label: '日期选择', icon: '📅' },
        { type: 'checkbox', label: '复选框', icon: '☑️' },
        { type: 'radio', label: '单选框', icon: '⭕' },
        { type: 'switch', label: '开关', icon: '🔘' },
      ],
    },
    {
      title: '🎯 高级组件',
      components: [
        { type: 'textarea', label: '多行文本', icon: '📄' },
        { type: 'upload', label: '文件上传', icon: '📤' },
        { type: 'subTable', label: '子表', icon: '📋', highlight: true },
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
          <List
            dataSource={group.components}
            renderItem={item => (
              <List.Item
                style={{
                  cursor: 'pointer',
                  padding: '10px 12px',
                  border: item.highlight ? '2px solid #ff4d4f' : '1px solid #d9d9d9',
                  marginBottom: '8px',
                  borderRadius: '4px',
                  background: item.highlight ? '#fff1f0' : 'white',
                  transition: 'all 0.3s',
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.background = item.highlight ? '#ffccc7' : '#e6f7ff';
                  e.currentTarget.style.borderColor = '#1890ff';
                  e.currentTarget.style.transform = 'translateX(4px)';
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.background = item.highlight ? '#fff1f0' : 'white';
                  e.currentTarget.style.borderColor = item.highlight ? '#ff4d4f' : '#d9d9d9';
                  e.currentTarget.style.transform = 'translateX(0)';
                }}
                onClick={() => onAddField(item.type)}
              >
                <Space>
                  <span style={{ fontSize: '18px' }}>{item.icon}</span>
                  <span style={{ fontSize: '13px' }}>
                    <strong>{item.label}</strong>
                  </span>
                  {item.highlight && (
                    <Tag color="red" style={{ fontSize: '10px', padding: '0 4px' }}>
                      高级
                    </Tag>
                  )}
                </Space>
              </List.Item>
            )}
          />
        </div>
      ))}

      <div style={{ marginTop: '24px', padding: '12px', background: '#fff7e6', borderRadius: '4px', fontSize: '12px' }}>
        <div><strong>💡 使用提示</strong></div>
        <div style={{ marginTop: '8px', color: '#666' }}>
          • 点击组件添加到画布<br/>
          • 支持拖拽排序<br/>
          • 子表支持主子表关系
        </div>
      </div>
    </div>
  );
};
