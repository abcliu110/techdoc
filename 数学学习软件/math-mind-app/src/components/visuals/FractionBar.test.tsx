import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { FractionBar } from './FractionBar';

/**
 * FractionBar 组件单元测试
 * @description 测试分数条形图可视化组件的渲染和交互
 */
describe('FractionBar', () => {
  describe('基础渲染', () => {
    it('应该正确渲染组件', () => {
      render(<FractionBar denominator={4} data-testid="test-bar" />);

      const bar = screen.getByTestId('test-bar');
      expect(bar).toBeInTheDocument();
    });

    it('应该渲染正确的段数', () => {
      render(<FractionBar denominator={4} data-testid="test-bar" />);

      const barContainer = screen.getByTestId('test-bar-bar');
      const segments = barContainer.querySelectorAll('.fraction-bar-segment');

      expect(segments).toHaveLength(4);
    });

    it('应该显示正确的分数标签', () => {
      render(<FractionBar denominator={4} highlighted={[0, 1, 2]} data-testid="test-bar" />);

      const label = screen.getByTestId('test-bar-label');
      expect(label).toHaveTextContent('3/4');
    });
  });

  describe('高亮状态', () => {
    it('应该正确显示初始高亮', () => {
      render(<FractionBar denominator={4} highlighted={[0, 2]} data-testid="test-bar" />);

      const barContainer = screen.getByTestId('test-bar-bar');
      const segments = barContainer.querySelectorAll('.fraction-bar-segment');

      expect(segments[0]).toHaveClass('highlighted');
      expect(segments[1]).not.toHaveClass('highlighted');
      expect(segments[2]).toHaveClass('highlighted');
      expect(segments[3]).not.toHaveClass('highlighted');
    });

    it('无高亮时应该全部为默认状态', () => {
      render(<FractionBar denominator={3} data-testid="test-bar" />);

      const barContainer = screen.getByTestId('test-bar-bar');
      const segments = barContainer.querySelectorAll('.fraction-bar-segment');

      segments.forEach(segment => {
        expect(segment).not.toHaveClass('highlighted');
      });
    });
  });

  describe('交互功能', () => {
    it('可交互模式下点击应该切换高亮状态', () => {
      render(
        <FractionBar
          denominator={4}
          highlighted={[]}
          data-testid="test-bar"
          interactive={true}
        />
      );

      const barContainer = screen.getByTestId('test-bar-bar');
      const segment0 = barContainer.querySelectorAll('.fraction-bar-segment')[0];

      // 点击第一个段，应该添加高亮
      fireEvent.click(segment0!);
      expect(segment0).toHaveClass('highlighted');

      // 再次点击，应该取消高亮
      fireEvent.click(segment0!);
      expect(segment0).not.toHaveClass('highlighted');
    });

    it('非交互模式下点击应该不改变状态', () => {
      render(
        <FractionBar
          denominator={4}
          highlighted={[]}
          data-testid="test-bar"
          interactive={false}
        />
      );

      const barContainer = screen.getByTestId('test-bar-bar');
      const segment0 = barContainer.querySelectorAll('.fraction-bar-segment')[0];

      fireEvent.click(segment0!);
      expect(segment0).not.toHaveClass('highlighted');
    });

    it('应该回调高亮变化', () => {
      const onHighlightChange = vi.fn();
      render(
        <FractionBar
          denominator={4}
          highlighted={[]}
          onHighlightChange={onHighlightChange}
          data-testid="test-bar"
          interactive={true}
        />
      );

      const barContainer = screen.getByTestId('test-bar-bar');
      const segment0 = barContainer.querySelectorAll('.fraction-bar-segment')[0];

      fireEvent.click(segment0!);
      expect(onHighlightChange).toHaveBeenCalledWith([0]);
    });

    it('完成回调应该正确触发', () => {
      const onComplete = vi.fn();
      render(
        <FractionBar
          denominator={3}
          highlighted={[]}
          onComplete={onComplete}
          data-testid="test-bar"
          interactive={true}
        />
      );

      const barContainer = screen.getByTestId('test-bar-bar');
      const segments = barContainer.querySelectorAll('.fraction-bar-segment');

      fireEvent.click(segments[0]!);
      fireEvent.click(segments[1]!);
      fireEvent.click(segments[2]!);

      expect(onComplete).toHaveBeenCalled();
    });

    it('完成时应该显示完成信息', () => {
      render(
        <FractionBar
          denominator={2}
          highlighted={[0]}
          data-testid="test-bar"
          interactive={true}
        />
      );

      const barContainer = screen.getByTestId('test-bar-bar');
      const segments = barContainer.querySelectorAll('.fraction-bar-segment');

      // segment0 已经是高亮的，点击会取消高亮
      fireEvent.click(segments[0]!);
      expect(segments[0]).not.toHaveClass('highlighted');

      // 重新点击使两个都高亮来触发完成
      fireEvent.click(segments[0]!);
      fireEvent.click(segments[1]!);

      const completeDiv = screen.getByTestId('test-bar-complete');
      expect(completeDiv).toBeInTheDocument();
      expect(completeDiv).toHaveTextContent('完成！');
    });

    it('自动填充按钮应该填充所有段', () => {
      const onHighlightChange = vi.fn();
      const onComplete = vi.fn();
      render(
        <FractionBar
          denominator={4}
          highlighted={[]}
          onHighlightChange={onHighlightChange}
          onComplete={onComplete}
          data-testid="test-bar"
          interactive={true}
        />
      );

      const autoBtn = screen.getByTestId('test-bar-auto-btn');
      fireEvent.click(autoBtn);

      expect(onHighlightChange).toHaveBeenCalledWith([0, 1, 2, 3]);
      expect(onComplete).toHaveBeenCalled();
    });

    it('完成后不应该显示自动填充按钮', () => {
      render(
        <FractionBar
          denominator={2}
          highlighted={[]}
          data-testid="test-bar"
          interactive={true}
        />
      );

      // 点击自动填充按钮触发完成状态
      const autoBtn = screen.getByTestId('test-bar-auto-btn');
      fireEvent.click(autoBtn);

      // 完成状态后自动填充按钮应该消失
      const autoBtnAfterComplete = screen.queryByTestId('test-bar-auto-btn');
      expect(autoBtnAfterComplete).not.toBeInTheDocument();
    });
  });

  describe('边界情况', () => {
    it('denominator为1时应该正常工作', () => {
      render(<FractionBar denominator={1} data-testid="test-bar" />);

      const barContainer = screen.getByTestId('test-bar-bar');
      const segments = barContainer.querySelectorAll('.fraction-bar-segment');

      expect(segments).toHaveLength(1);
    });

    it('denominator为0或负数时应该安全处理', () => {
      expect(() => {
        render(<FractionBar denominator={0} data-testid="test-bar" />);
      }).not.toThrow();
    });
  });

  describe('自定义配置', () => {
    it('应该支持自定义尺寸', () => {
      render(
        <FractionBar
          denominator={4}
          width={400}
          height={60}
          data-testid="test-bar"
        />
      );

      const barContainer = screen.getByTestId('test-bar-bar');
      expect(barContainer).toHaveStyle({ width: '400px', height: '60px' });
    });

    it('应该支持自定义颜色', () => {
      render(
        <FractionBar
          denominator={4}
          highlighted={[0]}
          color="#ff0000"
          data-testid="test-bar"
        />
      );

      const barContainer = screen.getByTestId('test-bar-bar');
      const highlightedSegment = barContainer.querySelector('.fraction-bar-segment.highlighted');

      expect(highlightedSegment).toHaveStyle({ backgroundColor: '#ff0000' });
    });

    it('应该支持自定义data-testid', () => {
      render(<FractionBar denominator={3} data-testid="custom-id" />);

      const bar = screen.getByTestId('custom-id');
      expect(bar).toBeInTheDocument();

      const label = screen.getByTestId('custom-id-label');
      expect(label).toBeInTheDocument();

      const barContainer = screen.getByTestId('custom-id-bar');
      expect(barContainer).toBeInTheDocument();
    });
  });
});
