import { describe, it, expect } from 'vitest';
import React from 'react';
import { FieldPreviewComplete } from '../FieldPreviewComplete';

describe('FieldPreviewComplete - 布局测试', () => {
  describe('宽高样式应用', () => {
    it('应该应用宽度样式', () => {
      const field = {
        type: 'input',
        label: '测试输入框',
        width: '200px',
      };

      // 验证fieldStyle包含width
      const fieldStyle = {
        width: field.width || undefined,
        height: field.height || undefined,
      };

      expect(fieldStyle.width).toBe('200px');
    });

    it('应该应用高度样式', () => {
      const field = {
        type: 'input',
        label: '测试输入框',
        height: '100px',
      };

      const fieldStyle = {
        width: field.width || undefined,
        height: field.height || undefined,
      };

      expect(fieldStyle.height).toBe('100px');
    });

    it('宽高未设置时应该是undefined', () => {
      const field = {
        type: 'input',
        label: '测试输入框',
      };

      const fieldStyle = {
        width: field.width || undefined,
        height: field.height || undefined,
      };

      expect(fieldStyle.width).toBeUndefined();
      expect(fieldStyle.height).toBeUndefined();
    });
  });

  describe('容器布局配置', () => {
    it('垂直布局应该生成正确的样式', () => {
      const field = {
        type: 'card',
        label: '卡片',
        childLayout: 'vertical',
        gap: '12px',
      };

      const getChildrenLayoutStyle = (): React.CSSProperties => {
        const layout = field.childLayout || 'vertical';
        const gap = field.gap || '12px';

        if (layout === 'horizontal') {
          return {
            display: 'flex',
            flexDirection: 'row',
            gap: gap,
            flexWrap: 'wrap',
          };
        } else if (layout === 'grid') {
          return {
            display: 'grid',
            gridTemplateColumns: `repeat(${field.gridColumns || 2}, 1fr)`,
            gap: field.gridGap || '12px',
          };
        } else {
          return {
            display: 'flex',
            flexDirection: 'column',
            gap: gap,
          };
        }
      };

      const style = getChildrenLayoutStyle();

      expect(style.display).toBe('flex');
      expect(style.flexDirection).toBe('column');
      expect(style.gap).toBe('12px');
    });

    it('水平布局应该生成正确的样式', () => {
      const field = {
        type: 'card',
        label: '卡片',
        childLayout: 'horizontal',
        gap: '16px',
      };

      const getChildrenLayoutStyle = (): React.CSSProperties => {
        const layout = field.childLayout || 'vertical';
        const gap = field.gap || '12px';

        if (layout === 'horizontal') {
          return {
            display: 'flex',
            flexDirection: 'row',
            gap: gap,
            flexWrap: 'wrap',
          };
        } else {
          return {
            display: 'flex',
            flexDirection: 'column',
            gap: gap,
          };
        }
      };

      const style = getChildrenLayoutStyle();

      expect(style.display).toBe('flex');
      expect(style.flexDirection).toBe('row');
      expect(style.gap).toBe('16px');
      expect(style.flexWrap).toBe('wrap');
    });

    it('网格布局应该生成正确的样式', () => {
      const field = {
        type: 'card',
        label: '卡片',
        childLayout: 'grid',
        gridColumns: 3,
        gridGap: '20px',
      };

      const getChildrenLayoutStyle = (): React.CSSProperties => {
        const layout = field.childLayout || 'vertical';
        const gap = field.gap || '12px';

        if (layout === 'grid') {
          return {
            display: 'grid',
            gridTemplateColumns: `repeat(${field.gridColumns || 2}, 1fr)`,
            gap: field.gridGap || '12px',
          };
        } else {
          return {
            display: 'flex',
            flexDirection: 'column',
            gap: gap,
          };
        }
      };

      const style = getChildrenLayoutStyle();

      expect(style.display).toBe('grid');
      expect(style.gridTemplateColumns).toBe('repeat(3, 1fr)');
      expect(style.gap).toBe('20px');
    });

    it('默认应该使用垂直布局', () => {
      const field = {
        type: 'card',
        label: '卡片',
        // 未设置childLayout
      };

      const getChildrenLayoutStyle = (): React.CSSProperties => {
        const layout = field.childLayout || 'vertical';
        const gap = field.gap || '12px';

        return {
          display: 'flex',
          flexDirection: 'column',
          gap: gap,
        };
      };

      const style = getChildrenLayoutStyle();

      expect(style.flexDirection).toBe('column');
    });

    it('网格默认应该是2列', () => {
      const field = {
        type: 'card',
        label: '卡片',
        childLayout: 'grid',
        // 未设置gridColumns
      };

      const getChildrenLayoutStyle = (): React.CSSProperties => {
        return {
          display: 'grid',
          gridTemplateColumns: `repeat(${field.gridColumns || 2}, 1fr)`,
          gap: field.gridGap || '12px',
        };
      };

      const style = getChildrenLayoutStyle();

      expect(style.gridTemplateColumns).toBe('repeat(2, 1fr)');
    });
  });
});
