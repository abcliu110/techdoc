import React, { useState } from 'react';
import { DndContext, closestCenter, KeyboardSensor, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import { arrayMove, SortableContext, sortableKeyboardCoordinates, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Layout, Card, Button, Space, Tag, Form, Input, InputNumber, Select, DatePicker, Checkbox, Radio, Switch, Upload, Tabs } from 'antd';
import { DeleteOutlined, DragOutlined, EyeOutlined, CodeOutlined, PlusOutlined, SaveOutlined } from '@ant-design/icons';
import { ComponentPanel } from './ComponentPanel';
import { PropertyPanel } from './PropertyPanel';

const { Sider, Content } = Layout;
const { TabPane } = Tabs;

// 可拖拽的字段项
const SortableFieldItem: React.FC<{
  field: any;
  index: number;
  isSelected: boolean;
  onSelect: () => void;
  onDelete: () => void;
}> = ({ field, index, isSelected, onSelect, onDelete }) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: field.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      onClick={onSelect}
      className={`field-item ${isSelected ? 'selected' : ''}`}
    >
      <div style={{
        padding: '16px',
        margin: '12px 0',
        border: isSelected ? '2px solid #1890ff' : '1px solid #d9d9d9',
        borderRadius: '4px',
        cursor: 'pointer',
        background: isSelected ? '#e6f7ff' : 'white',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        transition: 'all 0.3s',
      }}>
        <Space>
          <div {...attributes} {...listeners} style={{ cursor: 'move', color: '#999' }}>
            <DragOutlined />
          </div>
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
            onDelete();
          }}
        >
          删除
        </Button>
      </div>
    </div>
  );
};

// 字段预览渲染
const FieldPreview: React.FC<{ field: any }> = ({ field }) => {
  const renderField = () => {
    const commonProps = {
      placeholder: field.placeholder || `请输入${field.label}`,
      disabled: field.disabled,
    };

    switch (field.type) {
      case 'input':
        return <Input {...commonProps} />;
      case 'inputNumber':
        return <InputNumber style={{ width: '100%' }} {...commonProps} />;
      case 'select':
        return (
          <Select {...commonProps}>
            <Select.Option value="1">选项1</Select.Option>
            <Select.Option value="2">选项2</Select.Option>
          </Select>
        );
      case 'datePicker':
        return <DatePicker style={{ width: '100%' }} {...commonProps} />;
      case 'checkbox':
        return <Checkbox>{field.label}</Checkbox>;
      case 'radio':
        return (
          <Radio.Group>
            <Radio value="1">选项1</Radio>
            <Radio value="2">选项2</Radio>
          </Radio.Group>
        );
      case 'switch':
        return <Switch />;
      case 'textarea':
        return <Input.TextArea rows={3} {...commonProps} />;
      case 'upload':
        return (
          <Upload>
            <Button icon={<PlusOutlined />}>点击上传</Button>
          </Upload>
        );
      case 'subTable':
        return (
          <div style={{ border: '1px dashed #d9d9d9', padding: '12px', borderRadius: '4px', background: '#fafafa' }}>
            <div style={{ marginBottom: '8px', color: '#666' }}>
              📋 子表组件（主子表关系）
            </div>
            <Button size="small" type="dashed" icon={<PlusOutlined />}>
              添加行
            </Button>
          </div>
        );
      default:
        return <Input {...commonProps} />;
    }
  };

  return (
    <Form.Item
      label={field.label}
      required={field.required}
      help={field.helpText}
    >
      {renderField()}
    </Form.Item>
  );
};

// 设计画布（支持拖拽和预览）
const DesignCanvas: React.FC<{
  fields: any[];
  selectedIndex: number | null;
  previewMode: boolean;
  onFieldsReorder: (newFields: any[]) => void;
  onFieldSelect: (index: number) => void;
  onFieldDelete: (index: number) => void;
  onSave: () => void;
}> = ({ fields, selectedIndex, previewMode, onFieldsReorder, onFieldSelect, onFieldDelete, onSave }) => {
  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const handleDragEnd = (event: any) => {
    const { active, over } = event;

    if (active.id !== over.id) {
      const oldIndex = fields.findIndex((f) => f.id === active.id);
      const newIndex = fields.findIndex((f) => f.id === over.id);
      const newFields = arrayMove(fields, oldIndex, newIndex);
      onFieldsReorder(newFields);
    }
  };

  return (
    <div style={{ padding: '20px', height: '100vh', overflow: 'auto', background: '#f5f5f5' }}>
      <div style={{ marginBottom: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2>🎨 设计画布</h2>
        <Button type="primary" size="large" icon={<SaveOutlined />} onClick={onSave}>
          保存表单
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
            <div style={{ fontSize: '14px', marginTop: '8px', color: '#ccc' }}>
              支持拖拽排序 • 所见即所得预览 • 37个组件
            </div>
          </div>
        ) : (
          <div>
            {previewMode ? (
              // 预览模式 - 所见即所得
              <Form layout="horizontal" labelCol={{ span: 6 }} wrapperCol={{ span: 18 }}>
                <div style={{ marginBottom: '16px', padding: '12px', background: '#e6f7ff', borderRadius: '4px' }}>
                  👁️ <strong>预览模式</strong> - 这是用户看到的实际效果
                </div>
                {fields.map((field) => (
                  <FieldPreview key={field.id} field={field} />
                ))}
                <Form.Item wrapperCol={{ offset: 6 }}>
                  <Space>
                    <Button type="primary">提交</Button>
                    <Button>取消</Button>
                  </Space>
                </Form.Item>
              </Form>
            ) : (
              // 编辑模式 - 可拖拽
              <DndContext
                sensors={sensors}
                collisionDetection={closestCenter}
                onDragEnd={handleDragEnd}
              >
                <SortableContext
                  items={fields.map(f => f.id)}
                  strategy={verticalListSortingStrategy}
                >
                  {fields.map((field, index) => (
                    <SortableFieldItem
                      key={field.id}
                      field={field}
                      index={index}
                      isSelected={selectedIndex === index}
                      onSelect={() => onFieldSelect(index)}
                      onDelete={() => onFieldDelete(index)}
                    />
                  ))}
                </SortableContext>
              </DndContext>
            )}
          </div>
        )}
      </Card>
    </div>
  );
};

// 主设计器组件
export const FormDesignerEnhanced: React.FC = () => {
  const [fields, setFields] = useState<any[]>([]);
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [previewMode, setPreviewMode] = useState(false);
  const [viewMode, setViewMode] = useState<'design' | 'preview' | 'code'>('design');

  const handleAddField = (type: string) => {
    const newField = {
      id: `field_${Date.now()}_${Math.random()}`,
      fieldId: `field_${Date.now()}`,
      label: `新${type}字段`,
      type,
      placeholder: '',
      required: false,
      helpText: '',
      disabled: false,
    };
    setFields([...fields, newField]);
    setSelectedIndex(fields.length);
  };

  const handleFieldsReorder = (newFields: any[]) => {
    setFields(newFields);
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
      version: '1.0',
      fields: fields,
      fieldCount: fields.length,
    };
    alert('✅ 表单定义已保存！\n\n' + JSON.stringify(formDef, null, 2));
    console.log('表单定义:', formDef);
  };

  const selectedField = selectedIndex !== null ? fields[selectedIndex] : null;

  return (
    <Layout style={{ height: '100vh' }}>
      {/* 左侧组件库 */}
      <Sider width={240} theme="light" style={{ borderRight: '1px solid #f0f0f0' }}>
        <ComponentPanel onAddField={handleAddField} />
      </Sider>

      {/* 中间画布 */}
      <Content>
        <Tabs
          activeKey={viewMode}
          onChange={(key) => setViewMode(key as any)}
          style={{ padding: '0 16px', background: 'white' }}
          tabBarExtraContent={
            <Space style={{ padding: '8px 16px' }}>
              <Tag color="green">字段数: {fields.length}</Tag>
            </Space>
          }
        >
          <TabPane tab={<span><DragOutlined /> 设计模式</span>} key="design">
            <DesignCanvas
              fields={fields}
              selectedIndex={selectedIndex}
              previewMode={false}
              onFieldsReorder={handleFieldsReorder}
              onFieldSelect={handleFieldSelect}
              onFieldDelete={handleFieldDelete}
              onSave={handleSave}
            />
          </TabPane>
          <TabPane tab={<span><EyeOutlined /> 预览模式</span>} key="preview">
            <DesignCanvas
              fields={fields}
              selectedIndex={selectedIndex}
              previewMode={true}
              onFieldsReorder={handleFieldsReorder}
              onFieldSelect={handleFieldSelect}
              onFieldDelete={handleFieldDelete}
              onSave={handleSave}
            />
          </TabPane>
          <TabPane tab={<span><CodeOutlined /> JSON代码</span>} key="code">
            <div style={{ padding: '20px' }}>
              <Card title="表单JSON定义">
                <pre style={{
                  background: '#f5f5f5',
                  padding: '16px',
                  borderRadius: '4px',
                  overflow: 'auto',
                  maxHeight: '600px',
                }}>
                  {JSON.stringify({ formId: 'custom_form', fields }, null, 2)}
                </pre>
              </Card>
            </div>
          </TabPane>
        </Tabs>
      </Content>

      {/* 右侧属性面板 */}
      <Sider width={300} theme="light" style={{ borderLeft: '1px solid #f0f0f0' }}>
        <PropertyPanel
          selectedField={selectedField}
          onFieldUpdate={handleFieldUpdate}
        />
      </Sider>
    </Layout>
  );
};
