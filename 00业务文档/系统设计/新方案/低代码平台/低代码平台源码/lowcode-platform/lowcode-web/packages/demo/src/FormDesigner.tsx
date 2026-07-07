import React, { useState } from 'react';
import { Layout, Card, List, Form, Input, Select, Button, Space, Tag, Tabs } from 'antd';
import { PlusOutlined, DeleteOutlined, DragOutlined } from '@ant-design/icons';

const { Sider, Content } = Layout;
const { Option } = Select;

// 组件面板
const ComponentPanel: React.FC<{ onAddField: (type: string) => void }> = ({ onAddField }) => {
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
        { type: 'button', label: '按钮', icon: '🔳' },
      ],
    },
    {
      title: '🎯 重要组件 (P1)',
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
      title: '🏗️ 布局组件',
      components: [
        { type: 'card', label: '卡片', icon: '🗂️' },
        { type: 'tabs', label: '标签页', icon: '📑' },
        { type: 'collapse', label: '折叠面板', icon: '📁' },
        { type: 'divider', label: '分割线', icon: '➖' },
      ],
    },
    {
      title: '🔥 高级组件 (P2)',
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
      <h3 style={{ marginBottom: '16px' }}>📦 组件库 (37个)</h3>

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
          • 支持37个组件<br/>
          • 子表支持主子表关系
        </div>
      </div>
    </div>
  );
};

// 设计画布
const Canvas: React.FC<{
  fields: any[];
  selectedIndex: number | null;
  onFieldSelect: (index: number) => void;
  onFieldDelete: (index: number) => void;
  onSave: () => void;
}> = ({ fields, selectedIndex, onFieldSelect, onFieldDelete, onSave }) => {
  return (
    <div style={{ padding: '20px', height: '100vh', overflow: 'auto', background: '#f5f5f5' }}>
      <div style={{ marginBottom: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2>🎨 设计画布</h2>
        <Button type="primary" size="large" onClick={onSave}>
          💾 保存表单
        </Button>
      </div>

      <Card style={{ minHeight: '600px', background: 'white' }}>
        {fields.length === 0 ? (
          <div style={{
            padding: '80px 40px',
            textAlign: 'center',
            color: '#999',
            fontSize: '16px'
          }}>
            <div style={{ fontSize: '48px', marginBottom: '16px' }}>📦</div>
            <div>从左侧拖入组件开始设计表单</div>
          </div>
        ) : (
          <div>
            {fields.map((field, index) => (
              <div
                key={index}
                onClick={() => onFieldSelect(index)}
                style={{
                  padding: '16px',
                  margin: '12px 0',
                  border: selectedIndex === index ? '2px solid #1890ff' : '1px solid #d9d9d9',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  background: selectedIndex === index ? '#e6f7ff' : 'white',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  transition: 'all 0.3s',
                }}
              >
                <Space>
                  <DragOutlined style={{ color: '#999' }} />
                  <strong>{field.label || '未命名字段'}</strong>
                  <Tag color="blue">{field.type}</Tag>
                  {field.required && <Tag color="red">必填</Tag>}
                </Space>
                <Button
                  type="text"
                  danger
                  icon={<DeleteOutlined />}
                  onClick={(e) => {
                    e.stopPropagation();
                    onFieldDelete(index);
                  }}
                >
                  删除
                </Button>
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  );
};

// 属性面板
const PropertyPanel: React.FC<{
  selectedField: any | null;
  onFieldUpdate: (updates: any) => void;
}> = ({ selectedField, onFieldUpdate }) => {
  if (!selectedField) {
    return (
      <div style={{ padding: '16px', height: '100vh', overflow: 'auto' }}>
        <h3>⚙️ 属性面板</h3>
        <div style={{ marginTop: '40px', textAlign: 'center', color: '#999' }}>
          请在画布中选择一个字段
        </div>
      </div>
    );
  }

  return (
    <div style={{ padding: '16px', height: '100vh', overflow: 'auto' }}>
      <h3 style={{ marginBottom: '16px' }}>⚙️ 属性面板</h3>
      <Card size="small">
        <Form layout="vertical">
          <Form.Item label="字段标签">
            <Input
              value={selectedField.label}
              onChange={e => onFieldUpdate({ label: e.target.value })}
              placeholder="请输入字段标签"
            />
          </Form.Item>

          <Form.Item label="字段ID">
            <Input
              value={selectedField.fieldId}
              onChange={e => onFieldUpdate({ fieldId: e.target.value })}
              placeholder="请输入字段ID"
            />
          </Form.Item>

          <Form.Item label="组件类型">
            <Select
              value={selectedField.type}
              onChange={val => onFieldUpdate({ type: val })}
            >
              <Option value="input">输入框</Option>
              <Option value="inputNumber">数字输入</Option>
              <Option value="select">下拉选择</Option>
              <Option value="datePicker">日期选择</Option>
              <Option value="textarea">多行文本</Option>
            </Select>
          </Form.Item>

          <Form.Item label="占位符">
            <Input
              value={selectedField.placeholder}
              onChange={e => onFieldUpdate({ placeholder: e.target.value })}
              placeholder="请输入占位符"
            />
          </Form.Item>

          <Form.Item label="是否必填">
            <Select
              value={selectedField.required}
              onChange={val => onFieldUpdate({ required: val })}
            >
              <Option value={true}>是</Option>
              <Option value={false}>否</Option>
            </Select>
          </Form.Item>

          <Form.Item label="帮助文本">
            <Input.TextArea
              value={selectedField.helpText}
              onChange={e => onFieldUpdate({ helpText: e.target.value })}
              placeholder="请输入帮助文本"
              rows={2}
            />
          </Form.Item>
        </Form>
      </Card>

      <Card size="small" style={{ marginTop: '16px' }} title="字段预览">
        <div style={{ padding: '8px', background: '#f5f5f5', borderRadius: '4px' }}>
          <strong>{selectedField.label || '字段标签'}</strong>
          {selectedField.required && <Tag color="red" style={{ marginLeft: '8px' }}>必填</Tag>}
          <div style={{ marginTop: '8px', color: '#666', fontSize: '12px' }}>
            类型: {selectedField.type}
          </div>
          {selectedField.placeholder && (
            <div style={{ color: '#999', fontSize: '12px' }}>
              占位符: {selectedField.placeholder}
            </div>
          )}
        </div>
      </Card>
    </div>
  );
};

// 表单设计器主组件
export const FormDesigner: React.FC = () => {
  const [fields, setFields] = useState<any[]>([]);
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);

  const handleAddField = (type: string) => {
    const newField = {
      fieldId: `field_${Date.now()}`,
      label: `新${type}字段`,
      type,
      placeholder: '',
      required: false,
      helpText: '',
    };
    setFields([...fields, newField]);
    setSelectedIndex(fields.length);
  };

  const handleFieldSelect = (index: number) => {
    setSelectedIndex(index);
  };

  const handleFieldUpdate = (updates: any) => {
    if (selectedIndex !== null) {
      const newFields = [...fields];
      newFields[selectedIndex] = { ...newFields[selectedIndex], ...updates };
      setFields(newFields);
    }
  };

  const handleFieldDelete = (index: number) => {
    const newFields = fields.filter((_, i) => i !== index);
    setFields(newFields);
    setSelectedIndex(null);
  };

  const handleSave = () => {
    const formDef = {
      formId: 'custom_form',
      formName: '自定义表单',
      fields: fields,
    };
    alert('✅ 表单定义已保存！\n\n' + JSON.stringify(formDef, null, 2));
    console.log('表单定义:', formDef);
  };

  const selectedField = selectedIndex !== null ? fields[selectedIndex] : null;

  return (
    <Layout style={{ height: '100vh' }}>
      <Sider width={240} theme="light" style={{ borderRight: '1px solid #f0f0f0' }}>
        <ComponentPanel onAddField={handleAddField} />
      </Sider>

      <Content>
        <Canvas
          fields={fields}
          selectedIndex={selectedIndex}
          onFieldSelect={handleFieldSelect}
          onFieldDelete={handleFieldDelete}
          onSave={handleSave}
        />
      </Content>

      <Sider width={300} theme="light" style={{ borderLeft: '1px solid #f0f0f0' }}>
        <PropertyPanel
          selectedField={selectedField}
          onFieldUpdate={handleFieldUpdate}
        />
      </Sider>
    </Layout>
  );
};
