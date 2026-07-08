/**
 * 表单设计器
 * 集成拖拽排序、三视图切换、完整 AI 可控性
 * 支持 design / preview / code 三种模式
 */

import React, { useState, useCallback, useMemo, useEffect } from 'react';
import {
  DndContext,
  DragOverlay,
  closestCenter,
  PointerSensor,
  KeyboardSensor,
  useSensor,
  useSensors,
  type DragStartEvent,
  type DragEndEvent,
  type DragOverEvent,
} from '@dnd-kit/core';
import {
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { Layout, Tabs, message } from 'antd';
import { ComponentPanel } from './ComponentPanel';
import { Canvas } from './Canvas';
import { PropertyPanel } from './PropertyPanel';
import type { FormDefinition, DesignerFieldData, ElementType, ViewMode } from '../types';
import { CONTAINER_TYPES } from '../types';

const { Sider, Content } = Layout;

export interface FormDesignerProps {
  initialForm?: FormDefinition;
  onSave?: (form: FormDefinition) => void;
}

/** 生成唯一 ID */
function generateId(): string {
  return `field_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
}

/** 根据类型生成默认字段 */
function createDefaultField(type: ElementType, label?: string): DesignerFieldData {
  const id = generateId();
  const fieldId = `${type}_${Date.now()}`;

  const base: DesignerFieldData = {
    id,
    fieldId,
    type,
    label: label || type,
    placeholder: `请输入${label || type}`,
    required: false,
    disabled: false,
    readonly: false,
    hidden: false,
  };

  // 根据组件类型设置默认宽度，各组件有各自适合的默认尺寸
  switch (type) {
    // 行内/自适应组件：默认 auto
    case 'button':
    case 'checkbox':
    case 'radio':
    case 'switch':
    case 'rate':
    case 'tag':
    case 'divider':
    case 'colorPicker':
      base.width = 'auto';
      break;
    // 表单输入类：默认 240px，适合单行输入
    case 'input':
    case 'inputNumber':
    case 'textarea':
    case 'select':
    case 'cascader':
    case 'tree':
    case 'autoComplete':
    case 'datePicker':
    case 'timePicker':
    case 'rangePicker':
    case 'upload':
    case 'slider':
    case 'transfer':
    case 'richText':
    case 'subTable':
    case 'calendar':
      base.width = '240px';
      break;
    // 容器组件默认 flex 布局 + 初始化子组件数组
    case 'card':
      base.display = 'flex';
      base.flexDirection = 'column';
      base.padding = '12px';
      base.margin = '0';
      base.children = [];
      base.width = '100%';
      base.label = label || '卡片容器';
      break;
    case 'tabs':
      base.display = 'flex';
      base.flexDirection = 'column';
      base.padding = '12px';
      base.margin = '0';
      base.children = [];
      base.width = '100%';
      base.label = label || '标签页';
      break;
    case 'collapse':
      base.display = 'flex';
      base.flexDirection = 'column';
      base.padding = '12px';
      base.margin = '0';
      base.children = [];
      base.width = '100%';
      base.label = label || '折叠面板';
      break;
    default:
      break;
  }

  return base;
}

export const FormDesigner: React.FC<FormDesignerProps> = ({
  initialForm,
  onSave,
}) => {
  const [formDef, setFormDef] = useState<FormDefinition>(
    initialForm || {
      formId: 'new_form',
      formName: '新表单',
      formType: 'edit',
      version: '1.0',
      layout: { type: 'vertical' },
      fields: [],
    }
  );

  const [selectedFieldId, setSelectedFieldId] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<ViewMode>('design');
  const [activeId, setActiveId] = useState<string | null>(null);

  // DnD 传感器
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8, // 拖拽距离阈值，防止误触
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  // 键盘 Escape 取消选中
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && selectedFieldId) {
        setSelectedFieldId(null);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selectedFieldId]);

  // 选中的字段
  const selectedField = useMemo(
    () => formDef.fields.find(f => f.id === selectedFieldId) || null,
    [formDef.fields, selectedFieldId]
  );

  // === DnD 事件 ===

  /** 递归查找嵌套容器并添加子字段 */
  function addToContainerRecursive(
    fields: DesignerFieldData[],
    containerId: string,
    newField: DesignerFieldData
  ): DesignerFieldData[] {
    return fields.map(f => {
      if (f.id === containerId) {
        return { ...f, children: [...(f.children || []), newField] };
      }
      if (f.children) {
        const updatedChildren = addToContainerRecursive(f.children, containerId, newField);
        if (updatedChildren !== f.children) {
          return { ...f, children: updatedChildren };
        }
      }
      return f;
    });
  }

  /** 递归将字段从原位置移除并添加到目标容器 */
  function moveFieldToContainer(
    fields: DesignerFieldData[],
    fieldId: string,
    containerId: string
  ): { fields: DesignerFieldData[]; movedField: DesignerFieldData | null } {
    // 在根级和嵌套中查找该字段
    let movedField: DesignerFieldData | null = null;
    const withoutMoved = fields.filter(f => {
      if (f.id === fieldId) {
        movedField = f;
        return false;
      }
      return true;
    });

    if (movedField) {
      return {
        fields: addToContainerRecursive(withoutMoved, containerId, movedField),
        movedField,
      };
    }

    // 递归在子级中查找
    const result = withoutMoved.map(f => {
      if (f.children) {
        const { fields: updatedChildren, movedField: found } = moveFieldToContainer(f.children, fieldId, containerId);
        if (found) movedField = found;
        if (updatedChildren !== f.children) {
          return { ...f, children: updatedChildren };
        }
      }
      return f;
    });

    return { fields: result, movedField };
  }

  const handleDragStart = useCallback((event: DragStartEvent) => {
    setActiveId(event.active.id as string);
  }, []);

  const handleDragOver = useCallback((event: DragOverEvent) => {
    // 拖拽经过时更新 visual feedback
  }, []);

  const handleDragEnd = useCallback((event: DragEndEvent) => {
    const { active, over } = event;
    setActiveId(null);

    if (!over) return;

    const activeId = active.id as string;
    const overId = over.id as string;

    // 情况1：从组件面板拖入画布（activeId 格式为 component-{type}）
    if (activeId.startsWith('component-')) {
      const type = activeId.replace('component-', '') as ElementType;
      const newField = createDefaultField(type);

      // 情况1a：拖到容器 drop-zone 内（overId 格式为 drop-zone-{containerId}）
      if (overId.startsWith('drop-zone-')) {
        const containerId = overId.replace('drop-zone-', '');
        setFormDef(prev => ({
          ...prev,
          fields: addToContainerRecursive(prev.fields, containerId, newField),
        }));
        setSelectedFieldId(newField.id);
        message.success(`已添加到容器`);
        return;
      }

      // 情况1b：拖到某个字段上方，插入到根级
      if (overId !== 'canvas-droppable') {
        setFormDef(prev => {
          const overIndex = prev.fields.findIndex(f => f.id === overId);
          if (overIndex >= 0) {
            const newFields = [...prev.fields];
            newFields.splice(overIndex, 0, newField);
            return { ...prev, fields: newFields };
          }
          return { ...prev, fields: [...prev.fields, newField] };
        });
      } else {
        setFormDef(prev => ({ ...prev, fields: [...prev.fields, newField] }));
      }

      setSelectedFieldId(newField.id);
      message.success(`已添加：${type}`);
      return;
    }

    // 情况2：从画布字段移入容器 drop-zone
    if (overId.startsWith('drop-zone-')) {
      const containerId = overId.replace('drop-zone-', '');
      setFormDef(prev => {
        const { fields: newFields, movedField } = moveFieldToContainer(prev.fields, activeId, containerId);
        if (movedField) {
          setSelectedFieldId(movedField.id);
          message.success(`已移入容器`);
        }
        return { ...prev, fields: newFields };
      });
      return;
    }

    // 情况3：画布内根级排序
    if (activeId !== overId && overId !== 'canvas-droppable') {
      setFormDef(prev => {
        const oldIndex = prev.fields.findIndex(f => f.id === activeId);
        const newIndex = prev.fields.findIndex(f => f.id === overId);
        if (oldIndex !== -1 && newIndex !== -1) {
          const newFields = [...prev.fields];
          const [removed] = newFields.splice(oldIndex, 1);
          newFields.splice(newIndex, 0, removed);
          return { ...prev, fields: newFields };
        }
        return prev;
      });
    }
  }, []);

  // === 字段操作 ===

  const handleAddField = useCallback((type: ElementType) => {
    const newField = createDefaultField(type);
    setFormDef(prev => ({ ...prev, fields: [...prev.fields, newField] }));
    setSelectedFieldId(newField.id);
    message.success(`已添加：${type}`);
  }, []);

  const handleFieldSelect = useCallback((fieldId: string) => {
    setSelectedFieldId(fieldId);
  }, []);

  /** 递归删除指定 ID 的字段（包括嵌套子组件） */
  function removeFieldRecursively(fields: DesignerFieldData[], fieldId: string): DesignerFieldData[] {
    return fields
      .filter(f => f.id !== fieldId)
      .map(f => ({
        ...f,
        children: f.children ? removeFieldRecursively(f.children, fieldId) : f.children,
      }));
  }

  const handleFieldDelete = useCallback((fieldId: string) => {
    setFormDef(prev => ({
      ...prev,
      fields: removeFieldRecursively(prev.fields, fieldId),
    }));
    if (selectedFieldId === fieldId) {
      setSelectedFieldId(null);
    }
    message.success('已删除');
  }, [selectedFieldId]);

  /** 递归更新嵌套字段 */
  function updateFieldRecursively(
    fields: DesignerFieldData[],
    fieldId: string,
    updates: Partial<DesignerFieldData>
  ): DesignerFieldData[] {
    return fields.map(f => {
      if (f.id === fieldId) {
        return { ...f, ...updates };
      }
      if (f.children) {
        return { ...f, children: updateFieldRecursively(f.children, fieldId, updates) };
      }
      return f;
    });
  }

  const handleFieldUpdate = useCallback((updates: Partial<DesignerFieldData>) => {
    if (!selectedFieldId) return;
    setFormDef(prev => ({
      ...prev,
      fields: updateFieldRecursively(prev.fields, selectedFieldId, updates),
    }));
  }, [selectedFieldId]);

  const handleFieldDuplicate = useCallback(() => {
    if (!selectedField) return;
    const newField: DesignerFieldData = {
      ...selectedField,
      id: generateId(),
      fieldId: `${selectedField.fieldId}_copy`,
      label: `${selectedField.label} (副本)`,
    };
    const index = formDef.fields.findIndex(f => f.id === selectedField.id);
    const newFields = [...formDef.fields];
    newFields.splice(index + 1, 0, newField);
    setFormDef(prev => ({ ...prev, fields: newFields }));
    setSelectedFieldId(newField.id);
    message.success('已复制');
  }, [selectedField, formDef.fields]);

  const handleSave = useCallback(() => {
    onSave?.(formDef);
    message.success('表单已保存');
  }, [formDef, onSave]);

  // === 视图切换 ===

  const handleViewModeChange = useCallback((mode: string) => {
    setViewMode(mode as ViewMode);
  }, []);

  // 拖拽中的字段
  const activeField = useMemo(
    () => {
      if (!activeId) return null;
      // 来自组件面板
      if (activeId.startsWith('component-')) {
        const type = activeId.replace('component-', '') as ElementType;
        return createDefaultField(type);
      }
      // 来自画布
      return formDef.fields.find(f => f.id === activeId) || null;
    },
    [activeId, formDef.fields]
  );

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragStart={handleDragStart}
      onDragOver={handleDragOver}
      onDragEnd={handleDragEnd}
    >
      <Layout style={{ height: '100vh' }}>
        {/* 左侧组件面板 */}
        <Sider
          width={260}
          theme="light"
          style={{
            overflow: 'auto',
            borderRight: '1px solid #f0f0f0',
          }}
        >
          <ComponentPanel onAddField={handleAddField} />
        </Sider>

        {/* 中间画布 */}
        <Content style={{ display: 'flex', flexDirection: 'column' }}>
          {/* 视图切换 Tab */}
          <div
            data-testid="designer-view-tabs"
            style={{
              background: 'white',
              borderBottom: '1px solid #f0f0f0',
              padding: '0 16px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <Tabs
              activeKey={viewMode}
              onChange={handleViewModeChange}
              items={[
                { key: 'design', label: '🎨 设计' },
                { key: 'preview', label: '👁️ 预览' },
                { key: 'code', label: '💻 JSON' },
              ]}
              style={{ marginBottom: 0 }}
            />
          </div>

          {/* 画布区域 */}
          <div style={{ flex: 1, overflow: 'hidden' }}>
            <Canvas
              formDef={formDef}
              selectedFieldId={selectedFieldId}
              viewMode={viewMode}
              onFieldSelect={handleFieldSelect}
              onFieldDelete={handleFieldDelete}
              onSave={handleSave}
            />
          </div>
        </Content>

        {/* 右侧属性面板 */}
        <Sider
          width={320}
          theme="light"
          style={{
            overflow: 'auto',
            borderLeft: '1px solid #f0f0f0',
          }}
        >
          <PropertyPanel
            selectedField={selectedField}
            onFieldUpdate={handleFieldUpdate}
            onFieldDelete={selectedField ? () => handleFieldDelete(selectedField.id) : undefined}
            onFieldDuplicate={selectedField ? handleFieldDuplicate : undefined}
            onFieldSelect={setSelectedFieldId}
          />
        </Sider>
      </Layout>

      {/* 拖拽覆盖层 */}
      <DragOverlay>
        {activeField && (
          <div
            style={{
              padding: '8px 16px',
              background: 'white',
              border: '2px solid #1890ff',
              borderRadius: '4px',
              boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
              opacity: 0.9,
              fontSize: '12px',
              color: '#333',
              maxWidth: '200px',
            }}
          >
            {activeField.label || activeField.type}
          </div>
        )}
      </DragOverlay>
    </DndContext>
  );
};
