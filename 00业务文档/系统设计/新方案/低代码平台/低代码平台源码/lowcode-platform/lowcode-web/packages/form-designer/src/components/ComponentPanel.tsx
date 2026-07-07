import React from 'react';
import { Card, List } from 'antd';

const COMPONENTS = [
  { type: 'input', label: '输入框', icon: '📝' },
  { type: 'inputNumber', label: '数字输入', icon: '🔢' },
  { type: 'select', label: '下拉选择', icon: '📋' },
  { type: 'datePicker', label: '日期选择', icon: '📅' },
  { type: 'checkbox', label: '复选框', icon: '☑️' },
  { type: 'radio', label: '单选框', icon: '⭕' },
  { type: 'switch', label: '开关', icon: '🔘' },
  { type: 'upload', label: '文件上传', icon: '📤' },
];

export interface ComponentPanelProps {
  onAddField: (fieldType: string) => void;
}

export const ComponentPanel: React.FC<ComponentPanelProps> = ({ onAddField }) => {
  return (
    <div style={{ padding: '16px' }}>
      <h3>组件库</h3>
      <List
        dataSource={COMPONENTS}
        renderItem={item => (
          <List.Item
            style={{ cursor: 'pointer', padding: '8px' }}
            onClick={() => onAddField(item.type)}
          >
            <span>{item.icon}</span>
            <span style={{ marginLeft: '8px' }}>{item.label}</span>
          </List.Item>
        )}
      />
    </div>
  );
};
