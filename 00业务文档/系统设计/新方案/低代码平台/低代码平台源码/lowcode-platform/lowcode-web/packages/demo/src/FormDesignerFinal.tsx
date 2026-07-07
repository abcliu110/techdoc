import React, { useState } from 'react';
import { DndContext, DragOverlay, closestCenter, KeyboardSensor, PointerSensor, useSensor, useSensors, DragStartEvent, DragEndEvent, useDroppable } from '@dnd-kit/core';
import { arrayMove, SortableContext, sortableKeyboardCoordinates, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { Layout, Card, Button, Space, Tag, Tabs } from 'antd';
import { SaveOutlined, DragOutlined, EyeOutlined, CodeOutlined } from '@ant-design/icons';
import { ComponentPanelEnhanced } from './ComponentPanelEnhanced';
import { PropertyPanel } from './PropertyPanel';
import { SortableFieldItem } from './SortableFieldItem';
import { FieldPreviewComplete } from './FieldPreviewComplete';

const { Sider, Content } = Layout;
const { TabPane } = Tabs;

// 可放置区域的画布
const DroppableCanvas: React.FC<{
  fields: any[];
  selectedIndex: number | null;
  previewMode: boolean;
  onFieldSelect: (index: number) => void;
  onFieldDelete: (index: number) => void;
  onSave: () => void;
}> = ({ fields, selectedIndex, previewMode, onFieldSelect, onFieldDelete, onSave }) => {
  const { setNodeRef, isOver } = useDroppable({
    id: 'canvas-droppable',
  });

  return (
    <div style={{ padding: '20px', height: '100vh', overflow: 'auto', background: '#f5f5f5' }}>
      <div style={{ marginBottom: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2>🎨 设计画布</h2>
        <Button type="primary" size="large" icon={<SaveOutlined />} onClick={onSave}>
          保存表单
        </Button>
      </div>

      <Card
        ref={setNodeRef}
        style={{
          minHeight: '600px',
          background: isOver ? '#e6f7ff' : 'white',
          border: isOver ? '2px dashed #1890ff' : '1px solid #f0f0f0',
          transition: 'all 0.3s',
        }}
      >
        {fields.length === 0 ? (
          <div style={{
            padding: '80px 40px',
            textAlign: 'center',
            color: '#999',
            fontSize: '16px',
            userSelect: 'none',
          }}>
            <div style={{ fontSize: '48px', marginBottom: '16px' }}>📦</div>
            <div style={{ fontSize: '18px', fontWeight: 'bold', marginBottom: '8px' }}>
              从左侧拖动组件到这里
            </div>
            <div style={{ fontSize: '14px', color: '#ccc' }}>
              支持拖拽排序 • 所见即所得预览 • 10+组件
            </div>
          </div>
        ) : (
          <div>
            {previewMode ? (
              // 预览模式
              <div>
                <div style={{ marginBottom: '16px', padding: '12px', background: '#e6f7ff', borderRadius: '4px', userSelect: 'none' }}>
                  👁️ <strong>预览模式</strong> - 这是用户看到的实际效果
                </div>
                {fields.map((field) => (
                  <FieldPreviewComplete key={field.id} field={field} />
                ))}
              </div>
            ) : (
              // 编辑模式 - 可排序
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
            )}
          </div>
        )}
      </Card>
    </div>
  );
};

// 主设计器
export const FormDesignerFinal: React.FC = () => {
  const [fields, setFields] = useState<any[]>([]);
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [viewMode, setViewMode] = useState<'design' | 'preview' | 'code'>('design');
  const [activeId, setActiveId] = useState<string | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const handleDragStart = (event: DragStartEvent) => {
    setActiveId(event.active.id as string);
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    setActiveId(null);

    if (!over) return;

    // 从组件面板拖到画布
    if (active.id.toString().startsWith('component-')) {
      const componentType = active.id.toString().replace('component-', '');
      const newField = {
        id: `field_${Date.now()}_${Math.random()}`,
        fieldId: `field_${Date.now()}`,
        label: `新${active.data.current?.label || componentType}`,
        type: componentType,
        placeholder: '',
        required: false,
        helpText: '',
        disabled: false,
      };
      setFields([...fields, newField]);
      setSelectedIndex(fields.length);
      return;
    }

    // 画布内拖拽排序
    if (over.id !== active.id) {
      const oldIndex = fields.findIndex((f) => f.id === active.id);
      const newIndex = fields.findIndex((f) => f.id === over.id);
      if (oldIndex !== -1 && newIndex !== -1) {
        setFields(arrayMove(fields, oldIndex, newIndex));
      }
    }
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
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragStart={handleDragStart}
      onDragEnd={handleDragEnd}
    >
      <Layout style={{ height: '100vh', userSelect: 'none' }}>
        {/* 左侧组件库 */}
        <Sider width={240} theme="light" style={{ borderRight: '1px solid #f0f0f0' }}>
          <ComponentPanelEnhanced />
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
              <DroppableCanvas
                fields={fields}
                selectedIndex={selectedIndex}
                previewMode={false}
                onFieldSelect={setSelectedIndex}
                onFieldDelete={handleFieldDelete}
                onSave={handleSave}
              />
            </TabPane>
            <TabPane tab={<span><EyeOutlined /> 预览模式</span>} key="preview">
              <DroppableCanvas
                fields={fields}
                selectedIndex={selectedIndex}
                previewMode={true}
                onFieldSelect={setSelectedIndex}
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
                    userSelect: 'text',
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

      <DragOverlay>
        {activeId ? (
          <div style={{
            padding: '12px',
            background: 'white',
            border: '2px solid #1890ff',
            borderRadius: '4px',
            boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
          }}>
            正在拖拽...
          </div>
        ) : null}
      </DragOverlay>
    </DndContext>
  );
};
