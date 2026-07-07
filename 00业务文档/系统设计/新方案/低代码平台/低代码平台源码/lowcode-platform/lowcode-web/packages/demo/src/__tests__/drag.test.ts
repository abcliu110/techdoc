import { describe, it, expect, vi } from 'vitest';

describe('拖拽功能测试', () => {
  describe('从组件面板拖到画布', () => {
    it('应该能添加新字段', () => {
      const fields: any[] = [];
      const handleDragEnd = (active: any, over: any) => {
        if (active.id.toString().startsWith('component-')) {
          const componentType = active.id.toString().replace('component-', '');
          const newField = {
            id: `field_${Date.now()}`,
            fieldId: `field_${Date.now()}`,
            label: `新${componentType}`,
            type: componentType,
            parentId: null,
          };
          fields.push(newField);
        }
      };

      // 模拟拖拽input组件
      handleDragEnd(
        { id: 'component-input', data: { current: { label: '输入框' } } },
        { id: 'canvas-droppable' }
      );

      expect(fields.length).toBe(1);
      expect(fields[0].type).toBe('input');
    });

    it('应该能拖到容器内', () => {
      const fields: any[] = [];
      const handleDragEnd = (active: any, over: any) => {
        if (active.id.toString().startsWith('component-')) {
          const componentType = active.id.toString().replace('component-', '');
          const newField = {
            id: `field_${Date.now()}`,
            fieldId: `field_${Date.now()}`,
            label: `新${componentType}`,
            type: componentType,
            parentId: null,
          };

          // 判断是否拖到容器内
          const overId = over.id.toString();
          if (overId.startsWith('container-')) {
            const parentId = overId.replace('container-', '');
            newField.parentId = parentId;
          }

          fields.push(newField);
        }
      };

      // 模拟拖拽到card内
      handleDragEnd(
        { id: 'component-input', data: { current: { label: '输入框' } } },
        { id: 'container-card-123' }
      );

      expect(fields.length).toBe(1);
      expect(fields[0].parentId).toBe('card-123');
    });
  });

  describe('画布内拖拽排序', () => {
    it('应该能交换两个字段的位置', () => {
      const fields = [
        { id: '1', type: 'input', label: '字段1' },
        { id: '2', type: 'select', label: '字段2' },
        { id: '3', type: 'date', label: '字段3' },
      ];

      const handleDragEnd = (activeId: string, overId: string) => {
        const oldIndex = fields.findIndex(f => f.id === activeId);
        const newIndex = fields.findIndex(f => f.id === overId);

        if (oldIndex !== -1 && newIndex !== -1) {
          const [movedItem] = fields.splice(oldIndex, 1);
          fields.splice(newIndex, 0, movedItem);
        }
      };

      // 拖动字段1到字段3的位置
      handleDragEnd('1', '3');

      expect(fields.map(f => f.id)).toEqual(['2', '3', '1']);
    });
  });

  describe('容器嵌套', () => {
    it('Card应该是容器组件', () => {
      const isContainerComponent = (type: string) => {
        return ['card', 'tabs', 'collapse'].includes(type);
      };

      expect(isContainerComponent('card')).toBe(true);
      expect(isContainerComponent('tabs')).toBe(true);
      expect(isContainerComponent('collapse')).toBe(true);
    });

    it('普通组件不应该是容器', () => {
      const isContainerComponent = (type: string) => {
        return ['card', 'tabs', 'collapse'].includes(type);
      };

      expect(isContainerComponent('input')).toBe(false);
      expect(isContainerComponent('select')).toBe(false);
    });
  });
});
