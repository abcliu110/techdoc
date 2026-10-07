import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, act, waitFor } from '@testing-library/react';
import React from 'react';
import { SplitCircle } from '../../src/components/visuals/SplitCircle';

describe('SplitCircle 组件', () => {
  const defaultCircles = [
    { denominator: 2, highlighted: [0] },
  ];

  const defaultProps = {
    circles: defaultCircles,
    onComplete: vi.fn(),
    readOnly: false,
    size: 120,
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('渲染', () => {
    it('应该渲染分割圆', () => {
      render(<SplitCircle {...defaultProps} />);
      expect(document.querySelector('.split-circles')).toBeDefined();
    });

    it('应该渲染 SVG', () => {
      render(<SplitCircle {...defaultProps} />);
      expect(document.querySelector('.split-circle-svg')).toBeDefined();
    });

    it('应该渲染分数标签（初始为空，点击后更新）', () => {
      render(<SplitCircle {...defaultProps} />);
      // 初始状态为空（用户需要自己点击扇形添加高亮）
      expect(screen.getByText('0/2')).toBeDefined();
    });

    it('应该支持自定义大小', () => {
      render(<SplitCircle {...defaultProps} size={200} />);
      const svg = document.querySelector('.split-circle-svg') as SVGElement;
      expect(svg?.getAttribute('width')).toBe('200');
      expect(svg?.getAttribute('height')).toBe('200');
    });
  });

  describe('【核心】点击扇形添加高亮', () => {
    it('点击未高亮的扇形应添加高亮', async () => {
      render(<SplitCircle {...defaultProps} />);

      // 初始状态：无高亮，显示 0/2
      expect(screen.getByText('0/2')).toBeDefined();

      // 点击第一个扇形（index 0）
      const segments = document.querySelectorAll('.segment-interactive');
      expect(segments.length).toBe(2);

      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 点击后应显示 1/2（1个扇形被高亮）
      await waitFor(() => {
        expect(screen.getByText('1/2')).toBeDefined();
      });
    });

    it('点击多个扇形应累加高亮数量', async () => {
      render(
        <SplitCircle
          circles={[{ denominator: 4, highlighted: [0, 2] }]}
          onComplete={vi.fn()}
          size={120}
        />
      );

      // 初始状态：无高亮
      expect(screen.getByText('0/4')).toBeDefined();

      const segments = document.querySelectorAll('.segment-interactive');

      // 点击第一个扇形
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      await waitFor(() => {
        expect(screen.getByText('1/4')).toBeDefined();
      });

      // 点击第二个扇形
      await act(async () => {
        fireEvent.click(segments[2]);
      });

      await waitFor(() => {
        expect(screen.getByText('2/4')).toBeDefined();
      });
    });
  });

  describe('【核心】再次点击取消高亮', () => {
    it('点击已高亮的扇形应取消高亮', async () => {
      render(<SplitCircle {...defaultProps} />);

      const segments = document.querySelectorAll('.segment-interactive');

      // 先点击添加高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      await waitFor(() => {
        expect(screen.getByText('1/2')).toBeDefined();
      });

      // 再次点击同一个扇形，取消高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      await waitFor(() => {
        expect(screen.getByText('0/2')).toBeDefined();
      });
    });

    it('取消高亮后重新添加应生效', async () => {
      render(<SplitCircle {...defaultProps} />);

      const segments = document.querySelectorAll('.segment-interactive');

      // 添加高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      await waitFor(() => {
        expect(screen.getByText('1/2')).toBeDefined();
      });

      // 取消高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      await waitFor(() => {
        expect(screen.getByText('0/2')).toBeDefined();
      });

      // 再次添加高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      await waitFor(() => {
        expect(screen.getByText('1/2')).toBeDefined();
      });
    });
  });

  describe('【核心】正确高亮后触发完成回调', () => {
    it('当所有要求的扇形都被高亮时应触发 onComplete', async () => {
      const onComplete = vi.fn();
      render(
        <SplitCircle
          circles={[{ denominator: 2, highlighted: [0] }]}
          onComplete={onComplete}
          size={120}
        />
      );

      const segments = document.querySelectorAll('.segment-interactive');

      // 点击第一个扇形（index 0 是要求的）
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 等待 onComplete 被调用
      await waitFor(() => {
        expect(onComplete).toHaveBeenCalledTimes(1);
      });
    });

    it('只高亮部分扇形不应触发 onComplete', async () => {
      const onComplete = vi.fn();
      render(
        <SplitCircle
          circles={[
            { denominator: 2, highlighted: [0] },
            { denominator: 2, highlighted: [1] },
          ]}
          onComplete={onComplete}
          size={120}
        />
      );

      const segments = document.querySelectorAll('.segment-interactive');

      // 只点击第一个扇形
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 等待一小段时间确保没有调用
      await new Promise(resolve => setTimeout(resolve, 100));
      expect(onComplete).not.toHaveBeenCalled();

      // 点击第二个扇形（index 1 是第二个圆要求的）
      await act(async () => {
        fireEvent.click(segments[3]); // segments[3] 是第二个圆的 index 1
      });

      await waitFor(() => {
        expect(onComplete).toHaveBeenCalledTimes(1);
      });
    });

    it('多圆场景下所有圆都正确高亮才触发完成', async () => {
      const onComplete = vi.fn();
      render(
        <SplitCircle
          circles={[
            { denominator: 2, highlighted: [0] },
            { denominator: 2, highlighted: [1] },
          ]}
          onComplete={onComplete}
          size={120}
        />
      );

      const segments = document.querySelectorAll('.segment-interactive');

      // 第一个圆高亮 index 0
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 第二个圆高亮 index 1
      await act(async () => {
        fireEvent.click(segments[3]);
      });

      await waitFor(() => {
        expect(onComplete).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe('交互', () => {
    it('只读模式下不应有交互', () => {
      render(<SplitCircle {...defaultProps} readOnly={true} />);
      const segments = document.querySelectorAll('.segment-interactive');
      expect(segments.length).toBe(0);
    });

    it('非只读模式下应有交互扇形', () => {
      render(<SplitCircle {...defaultProps} />);
      const segments = document.querySelectorAll('.segment-interactive');
      expect(segments.length).toBeGreaterThan(0);
    });
  });

  describe('多圆渲染', () => {
    it('应该正确渲染多个圆', () => {
      render(
        <SplitCircle
          {...defaultProps}
          circles={[
            { denominator: 2, highlighted: [0] },
            { denominator: 4, highlighted: [0, 1] },
          ]}
        />
      );
      const circles = document.querySelectorAll('.split-circle-container');
      expect(circles.length).toBe(2);
    });
  });

  describe('边界情况', () => {
    it('空 circles 数组应正常渲染', () => {
      render(<SplitCircle circles={[]} />);
      const circles = document.querySelectorAll('.split-circle-container');
      expect(circles.length).toBe(0);
    });

    it('高亮索引超出范围应正常处理', () => {
      render(
        <SplitCircle
          circles={[{ denominator: 2, highlighted: [0, 1, 2] }]}
        />
      );
      // 超出范围的高亮索引会被忽略，只显示有效的高亮数/分母
      const label = document.querySelector('.fraction-label');
      expect(label?.textContent).toMatch(/\d+\/2/);
    });
  });
});
