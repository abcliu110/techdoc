import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { SplitCircle } from './SplitCircle';

/**
 * SplitCircle 组件单元测试
 * @description 测试分割圆可视化组件的渲染和交互
 */
describe('SplitCircle', () => {
  describe('基础渲染', () => {
    it('应该正确渲染组件', () => {
      render(<SplitCircle denominator={4} data-testid="test-circle" />);

      const circle = screen.getByTestId('test-circle');
      expect(circle).toBeInTheDocument();
    });

    it('应该渲染正确的分母段数', () => {
      render(<SplitCircle denominator={4} data-testid="test-circle" />);

      // 检查是否有4个扇形
      for (let i = 0; i < 4; i++) {
        const segment = screen.getByTestId(`test-circle-segment-${i}`);
        expect(segment).toBeInTheDocument();
      }
    });

    it('应该渲染正确的中心文本', () => {
      render(<SplitCircle denominator={4} highlighted={[0, 1, 2]} data-testid="test-circle" />);

      // 中心文本应该显示 3/4
      const circle = screen.getByTestId('test-circle');
      const text = circle.querySelector('.split-circle-text');
      expect(text).toHaveTextContent('3/4');
    });
  });

  describe('高亮状态', () => {
    it('应该正确显示初始高亮', () => {
      render(<SplitCircle denominator={4} highlighted={[0, 2]} data-testid="test-circle" />);

      const segment0 = screen.getByTestId('test-circle-segment-0');
      const segment1 = screen.getByTestId('test-circle-segment-1');
      const segment2 = screen.getByTestId('test-circle-segment-2');

      expect(segment0).toHaveClass('highlighted');
      expect(segment1).not.toHaveClass('highlighted');
      expect(segment2).toHaveClass('highlighted');
    });

    it('无高亮时应该全部为默认状态', () => {
      render(<SplitCircle denominator={3} data-testid="test-circle" />);

      const segment0 = screen.getByTestId('test-circle-segment-0');
      const segment1 = screen.getByTestId('test-circle-segment-1');
      const segment2 = screen.getByTestId('test-circle-segment-2');

      expect(segment0).not.toHaveClass('highlighted');
      expect(segment1).not.toHaveClass('highlighted');
      expect(segment2).not.toHaveClass('highlighted');
    });
  });

  describe('交互功能', () => {
    it('可交互模式下点击应该切换高亮状态', () => {
      render(
        <SplitCircle
          denominator={4}
          highlighted={[]}
          data-testid="test-circle"
          interactive={true}
        />
      );

      const segment0 = screen.getByTestId('test-circle-segment-0');

      // 点击第一个扇形，应该添加高亮
      fireEvent.click(segment0);
      expect(segment0).toHaveClass('highlighted');

      // 再次点击，应该取消高亮
      fireEvent.click(segment0);
      expect(segment0).not.toHaveClass('highlighted');
    });

    it('非交互模式下点击应该不改变状态', () => {
      render(
        <SplitCircle
          denominator={4}
          highlighted={[]}
          data-testid="test-circle"
          interactive={false}
        />
      );

      const segment0 = screen.getByTestId('test-circle-segment-0');

      fireEvent.click(segment0);
      expect(segment0).not.toHaveClass('highlighted');
    });

    it('点击已高亮的扇形应该取消高亮（取消高亮测试）', () => {
      render(
        <SplitCircle
          denominator={4}
          highlighted={[0, 1]}
          data-testid="test-circle"
          interactive={true}
        />
      );

      const segment0 = screen.getByTestId('test-circle-segment-0');

      // 初始状态应该是高亮的
      expect(segment0).toHaveClass('highlighted');

      // 点击应该取消高亮
      fireEvent.click(segment0);
      expect(segment0).not.toHaveClass('highlighted');
    });

    it('应该回调高亮变化', () => {
      const onHighlightChange = vi.fn();
      render(
        <SplitCircle
          denominator={4}
          highlighted={[]}
          onHighlightChange={onHighlightChange}
          data-testid="test-circle"
          interactive={true}
        />
      );

      const segment0 = screen.getByTestId('test-circle-segment-0');
      fireEvent.click(segment0);

      expect(onHighlightChange).toHaveBeenCalledWith([0]);
    });

    it('完成回调应该正确触发', () => {
      const onComplete = vi.fn();
      render(
        <SplitCircle
          denominator={3}
          highlighted={[]}
          onComplete={onComplete}
          data-testid="test-circle"
          interactive={true}
        />
      );

      // 点击所有扇形
      const segment0 = screen.getByTestId('test-circle-segment-0');
      const segment1 = screen.getByTestId('test-circle-segment-1');
      const segment2 = screen.getByTestId('test-circle-segment-2');

      fireEvent.click(segment0);
      fireEvent.click(segment1);
      fireEvent.click(segment2);

      expect(onComplete).toHaveBeenCalled();
    });

    it('完成时应该显示完成信息', () => {
      render(
        <SplitCircle
          denominator={2}
          highlighted={[0]}
          data-testid="test-circle"
          interactive={true}
        />
      );

      // 通过点击所有扇形来触发完成状态
      const segment0 = screen.getByTestId('test-circle-segment-0');
      const segment1 = screen.getByTestId('test-circle-segment-1');

      // segment0 已经是高亮的，点击会取消高亮
      // 先取消一个高亮，然后再点击两个使它们都高亮
      fireEvent.click(segment0);
      expect(segment0).not.toHaveClass('highlighted');

      // 重新点击使两个都高亮
      fireEvent.click(segment0);
      fireEvent.click(segment1);

      // 现在两个扇形都是高亮的，应该触发完成
      const completeDiv = screen.getByTestId('test-circle-complete');
      expect(completeDiv).toBeInTheDocument();
      expect(completeDiv).toHaveTextContent('分割完成！');
    });
  });

  describe('边界情况', () => {
    it('denominator为1时应该正常工作', () => {
      render(<SplitCircle denominator={1} data-testid="test-circle" />);

      const segment0 = screen.getByTestId('test-circle-segment-0');
      expect(segment0).toBeInTheDocument();
    });

    it('denominator为0或负数时应该安全处理', () => {
      // 不应该崩溃
      expect(() => {
        render(<SplitCircle denominator={0} data-testid="test-circle" />);
      }).not.toThrow();
    });

    it('高亮索引超出范围时不应该崩溃', () => {
      expect(() => {
        render(<SplitCircle denominator={4} highlighted={[0, 1, 2, 3, 4, 5]} data-testid="test-circle" />);
      }).not.toThrow();
    });
  });

  describe('自定义配置', () => {
    it('应该支持自定义data-testid', () => {
      render(<SplitCircle denominator={3} data-testid="custom-id" />);

      const circle = screen.getByTestId('custom-id');
      expect(circle).toBeInTheDocument();

      const segment = screen.getByTestId('custom-id-segment-0');
      expect(segment).toBeInTheDocument();
    });

    it('应该支持自定义半径', () => {
      const { container } = render(
        <SplitCircle denominator={4} radius={100} data-testid="test-circle" />
      );

      const svg = container.querySelector('svg');
      expect(svg).toBeInTheDocument();
      // 半径100 + padding 10，所以应该是 220x220
      expect(svg).toHaveAttribute('width', '220');
      expect(svg).toHaveAttribute('height', '220');
    });
  });
});
