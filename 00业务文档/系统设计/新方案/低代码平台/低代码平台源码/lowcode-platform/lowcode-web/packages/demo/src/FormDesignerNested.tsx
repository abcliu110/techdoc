import React, { useState } from 'react';
import { DndContext, DragOverlay, closestCenter, PointerSensor, useSensor, useSensors, DragStartEvent, DragEndEvent, useDroppable } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { Layout, Card, Button, Space, Tag, Tabs } from 'antd';
import { SaveOutlined, DragOutlined, EyeOutlined, CodeOutlined } from '@ant-design/icons';
import { ComponentPanelEnhanced } from './ComponentPanelEnhanced';
import { PropertyPanel } from './PropertyPanel';
import { SortableFieldItem } from './SortableFieldItem';
import { FieldNode, arrayToTree, isContainerComponent } from './treeUtils';
import { FieldPreviewComplete } from './FieldPreviewComplete';

const { Sider, Content } = Layout;
const { TabPane } = Tabs;

// 递归渲染字段（简化版）
const RenderFields: React.FC<{
  fields: FieldNode[];
  selectedId: string | null;
  onFieldSelect: (id: string) => void;
  onFieldDelete: (id: string) => void;
  level?: number;
}> = ({ fields, selectedId, onFieldSelect, onFieldDelete, level = 0 }) => {
  return (
    <SortableContext items={fields.map(f => f.id)} strategy={verticalListSortingStrategy}>
      {fields.map((field) => {
        const isContainer = isContainerComponent(field.type);
        const isSelected = selectedId === field.id;

        return (
          <SortableFieldItem
            key={field.id}
            field={field}
            index={field.id}
            isSelected={isSelected}
            onSelect={() => onFieldSelect(field.id)}
            onDelete={() => onFieldDelete(field.id)}
            isContainer={isContainer}
          >
            {/* 如果有子组件，递归渲染 */}
            {isContainer && field.children && field.children.length > 0 && (
              <div style={{ paddingTop: '8px' }}>
                <RenderFields
                  fields={field.children}
                  selectedId={selectedId}
                  onFieldSelect={onFieldSelect}
                  onFieldDelete={onFieldDelete}
                  level={level + 1}
                />
              </div>
            )}
          </SortableFieldItem>
        );
      })}
    </SortableContext>
  );
};

// 可放置区域的画布
const DroppableCanvas: React.FC<{
  fieldTree: FieldNode[];
  selectedId: string | null;
  previewMode: boolean;
  onFieldSelect: (id: string) => void;
  onFieldDelete: (id: string) => void;
  onSave: () => void;
}> = ({ fieldTree, selectedId, previewMode, onFieldSelect, onFieldDelete, onSave }) => {
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
        {fieldTree.length === 0 ? (
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
              支持拖拽排序 • 容器嵌套 • 27+组件
            </div>
          </div>
        ) : (
          <RenderFields
            fields={fieldTree}
            selectedId={selectedId}
            onFieldSelect={onFieldSelect}
            onFieldDelete={onFieldDelete}
          />
        )}
      </Card>
    </div>
  );
};

// 主设计器
export const FormDesignerNested: React.FC = () => {
  const [fields, setFields] = useState<any[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'design' | 'preview' | 'code'>('design');
  const [activeId, setActiveId] = useState<string | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    })
  );

  // 将扁平数组转为树形结构
  const fieldTree = arrayToTree(fields);

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
        parentId: null,
      };

      // 判断是否拖到容器内
      const overId = over.id.toString();
      if (overId.startsWith('droppable-')) {
        const parentId = overId.replace('droppable-', '');
        if (parentId !== 'root') {
          newField.parentId = parentId;
        }
      }

      setFields([...fields, newField]);
      setSelectedId(newField.id);
      return;
    }

    // 画布内拖拽排序（暂时简化，不支持跨容器移动）
    if (over.id !== active.id && !over.id.toString().startsWith('droppable-')) {
      const oldIndex = fields.findIndex((f) => f.id === active.id);
      const newIndex = fields.findIndex((f) => f.id === over.id);

      if (oldIndex !== -1 && newIndex !== -1) {
        const newFields = [...fields];
        const [movedItem] = newFields.splice(oldIndex, 1);
        newFields.splice(newIndex, 0, movedItem);
        setFields(newFields);
      }
    }
  };

  const handleFieldUpdate = (updates: any) => {
    if (selectedId !== null) {
      const newFields = fields.map(f =>
        f.id === selectedId ? { ...f, ...updates } : f
      );
      setFields(newFields);
    }
  };

  const handleFieldDelete = (id: string) => {
    const newFields = fields.filter((f) => f.id !== id);
    setFields(newFields);
    setSelectedId(null);
  };

  const handleSave = () => {
    const formDef = {
      formId: 'custom_form',
      formName: '自定义表单',
      version: '1.0',
      fields: fields,
      fieldTree: fieldTree,
      fieldCount: fields.length,
    };
    alert('✅ 表单定义已保存！\n\n' + JSON.stringify(formDef, null, 2));
    console.log('表单定义:', formDef);
  };

  const selectedField = selectedId ? fields.find(f => f.id === selectedId) : null;

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
                fieldTree={fieldTree}
                selectedId={selectedId}
                previewMode={false}
                onFieldSelect={setSelectedId}
                onFieldDelete={handleFieldDelete}
                onSave={handleSave}
              />
            </TabPane>
            <TabPane tab={<span><EyeOutlined /> 预览模式</span>} key="preview">
              <DroppableCanvas
                fieldTree={fieldTree}
                selectedId={selectedId}
                previewMode={true}
                onFieldSelect={setSelectedId}
                onFieldDelete={handleFieldDelete}
                onSave={handleSave}
              />
            </TabPane>
            <TabPane tab={<span><CodeOutlined /> JSON代码</span>} key="code">
              <div style={{ padding: '20px' }}>
                <Card title="表单JSON定义（树形结构）">
                  <pre style={{
                    background: '#f5f5f5',
                    padding: '16px',
                    borderRadius: '4px',
                    overflow: 'auto',
                    maxHeight: '600px',
                    userSelect: 'text',
                  }}>
                    {JSON.stringify({ formId: 'custom_form', fieldTree }, null, 2)}
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
