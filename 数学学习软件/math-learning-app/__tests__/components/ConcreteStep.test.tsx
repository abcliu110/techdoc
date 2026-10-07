import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, act, waitFor } from '@testing-library/react';
import React from 'react';
import { ConcreteStep } from '../../src/components/steps/ConcreteStep';
import type { ConcreteContent } from '../../src/domain/types/learning-step';

describe('ConcreteStep 组件', () => {
  const mockContent: ConcreteContent = {
    type: 'concrete',
    scenario: {
      title: '分割圆形',
      description: '将圆形分成两等份并高亮其中一份',
      emoji: '🎯',
    },
    interaction: {
      kind: 'split',
      target: '高亮正确的一份',
      visualType: 'split-circle',
      visualConfig: {
        circles: [
          { denominator: 2, highlighted: [0] },
        ],
      },
    },
  };

  const defaultProps = {
    content: mockContent,
    stepName: '具象操作',
    stepIndex: 0,
    totalSteps: 3,
    hintLevels: ['提示1', '提示2'],
    onComplete: vi.fn(),
    onHint: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('渲染', () => {
    it('应该渲染步骤头部', () => {
      render(<ConcreteStep {...defaultProps} />);
      expect(screen.getByText('具象操作')).toBeDefined();
    });

    it('应该渲染场景标题', () => {
      render(<ConcreteStep {...defaultProps} />);
      expect(screen.getByText('分割圆形')).toBeDefined();
    });

    it('应该渲染场景描述', () => {
      render(<ConcreteStep {...defaultProps} />);
      expect(screen.getByText('将圆形分成两等份并高亮其中一份')).toBeDefined();
    });

    it('应该渲染任务目标', () => {
      render(<ConcreteStep {...defaultProps} />);
      expect(screen.getByText('高亮正确的一份')).toBeDefined();
    });

    it('应该渲染分割圆可视化', () => {
      render(<ConcreteStep {...defaultProps} />);
      expect(document.querySelector('.split-circles')).toBeDefined();
    });

    it('应该显示步骤索引', () => {
      render(<ConcreteStep {...defaultProps} />);
      expect(document.querySelector('.step-progress')?.textContent).toContain('1');
      expect(document.querySelector('.step-progress')?.textContent).toContain('3');
    });
  });

  describe('【核心】完成按钮状态管理', () => {
    it('任务未完成时按钮应显示"先完成任务"且禁用', () => {
      render(<ConcreteStep {...defaultProps} />);
      const completeButton = screen.getByRole('button', { name: /先完成任务/ });
      expect(completeButton).toBeDisabled();
    });

    it('任务未完成时点击按钮应无响应', () => {
      render(<ConcreteStep {...defaultProps} />);
      const completeButton = screen.getByRole('button', { name: /先完成任务/ });

      // 点击禁用按钮
      completeButton.click();

      // onComplete 不应被调用
      expect(defaultProps.onComplete).not.toHaveBeenCalled();
    });
  });

  describe('【核心】点击扇形添加高亮后按钮启用', () => {
    it('点击正确的扇形后按钮应变为"完成"且启用', async () => {
      render(<ConcreteStep {...defaultProps} />);

      // 初始状态：按钮禁用
      const completeButton = screen.getByRole('button', { name: /先完成任务/ });
      expect(completeButton).toBeDisabled();

      // 点击分割圆的第一个扇形（index 0）
      const segments = document.querySelectorAll('.segment-interactive');
      expect(segments.length).toBeGreaterThan(0);

      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 按钮应变为启用状态且显示"完成"
      await waitFor(() => {
        const enabledButton = screen.getByRole('button', { name: /完成/ });
        expect(enabledButton).toBeEnabled();
      });
    });

    it('点击错误的扇形按钮应保持禁用', async () => {
      const contentWithWrongFirst: ConcreteContent = {
        ...mockContent,
        interaction: {
          ...mockContent.interaction,
          visualConfig: {
            circles: [{ denominator: 4, highlighted: [2] }], // 要求高亮 index 2
          },
        },
      };

      render(
        <ConcreteStep
          {...defaultProps}
          content={contentWithWrongFirst}
        />
      );

      // 初始状态：按钮禁用
      const completeButton = screen.getByRole('button', { name: /先完成任务/ });
      expect(completeButton).toBeDisabled();

      // 点击第一个扇形（index 0，不是要求的 index 2）
      const segments = document.querySelectorAll('.segment-interactive');
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 按钮应保持禁用
      await waitFor(() => {
        expect(screen.getByRole('button', { name: /先完成任务/ })).toBeDisabled();
      });
    });

    it('点击正确的扇形后按钮变为启用，点击完成应触发回调', async () => {
      render(<ConcreteStep {...defaultProps} />);

      // 点击分割圆的第一个扇形（index 0）
      const segments = document.querySelectorAll('.segment-interactive');
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 等待按钮变为启用
      await waitFor(() => {
        const enabledButton = screen.getByRole('button', { name: /完成/ });
        expect(enabledButton).toBeEnabled();
      });

      // 点击完成按钮
      const completeButton = screen.getByRole('button', { name: /完成/ });
      await act(async () => {
        fireEvent.click(completeButton);
      });

      // onComplete 应被调用
      expect(defaultProps.onComplete).toHaveBeenCalledTimes(1);
      expect(defaultProps.onComplete).toHaveBeenCalledWith(
        expect.objectContaining({ completed: true })
      );
    });
  });

  describe('【核心】再次点击取消高亮后按钮禁用', () => {
    it('先添加高亮再取消高亮，按钮应恢复禁用', async () => {
      render(<ConcreteStep {...defaultProps} />);

      const segments = document.querySelectorAll('.segment-interactive');

      // 先点击添加高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 等待按钮变为启用
      await waitFor(() => {
        expect(screen.getByRole('button', { name: /完成/ })).toBeEnabled();
      });

      // 再次点击取消高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 按钮应恢复禁用
      await waitFor(() => {
        expect(screen.getByRole('button', { name: /先完成任务/ })).toBeDisabled();
      });
    });

    it('取消高亮后点击完成按钮应无响应', async () => {
      render(<ConcreteStep {...defaultProps} />);

      const segments = document.querySelectorAll('.segment-interactive');

      // 添加高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 等待按钮变为启用
      await waitFor(() => {
        expect(screen.getByRole('button', { name: /完成/ })).toBeEnabled();
      });

      // 取消高亮
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 按钮应禁用，尝试点击不会触发 onComplete
      await waitFor(() => {
        const disabledButton = screen.getByRole('button', { name: /先完成任务/ });
        expect(disabledButton).toBeDisabled();
      });

      // 点击禁用按钮
      const disabledButton = screen.getByRole('button', { name: /先完成任务/ });
      disabledButton.click();

      expect(defaultProps.onComplete).not.toHaveBeenCalled();
    });
  });

  describe('【核心】点击完成进入下一步', () => {
    it('点击完成应触发 onComplete 回调', async () => {
      render(<ConcreteStep {...defaultProps} />);

      // 先完成交互
      const segments = document.querySelectorAll('.segment-interactive');
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 等待按钮启用
      await waitFor(() => {
        expect(screen.getByRole('button', { name: /完成/ })).toBeEnabled();
      });

      // 点击完成
      const completeButton = screen.getByRole('button', { name: /完成/ });
      await act(async () => {
        fireEvent.click(completeButton);
      });

      expect(defaultProps.onComplete).toHaveBeenCalledWith(
        expect.objectContaining({
          completed: true,
          hintsUsed: expect.any(Number),
        })
      );
    });

    it('onComplete 回调应包含完成数据', async () => {
      const onComplete = vi.fn();
      render(<ConcreteStep {...defaultProps} onComplete={onComplete} />);

      // 完成交互
      const segments = document.querySelectorAll('.segment-interactive');
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      // 点击完成
      await waitFor(() => {
        expect(screen.getByRole('button', { name: /完成/ })).toBeEnabled();
      });

      const completeButton = screen.getByRole('button', { name: /完成/ });
      await act(async () => {
        fireEvent.click(completeButton);
      });

      // 验证回调参数
      expect(onComplete).toHaveBeenCalledTimes(1);
      const [data] = onComplete.mock.calls[0];
      expect(data.completed).toBe(true);
    });
  });

  describe('提示功能', () => {
    it('点击提示按钮应触发 onHint', () => {
      render(<ConcreteStep {...defaultProps} />);
      const hintButton = screen.getByRole('button', { name: /提示/ });
      fireEvent.click(hintButton);
      expect(defaultProps.onHint).toHaveBeenCalledTimes(1);
    });

    it('点击提示按钮应显示反馈', () => {
      render(<ConcreteStep {...defaultProps} />);
      const hintButton = screen.getByRole('button', { name: /提示/ });
      fireEvent.click(hintButton);
      expect(screen.getByText('提示1')).toBeDefined();
    });

    it('提示按钮应显示剩余次数', () => {
      render(<ConcreteStep {...defaultProps} />);
      expect(screen.getByText(/提示 \(2\)/)).toBeDefined();
    });

    it('当所有提示用完时不应显示提示按钮', () => {
      render(<ConcreteStep {...defaultProps} hintLevels={[]} />);
      expect(screen.queryByRole('button', { name: /提示/ })).toBeNull();
    });

    it('使用提示后仍可完成任务', async () => {
      render(<ConcreteStep {...defaultProps} />);

      // 先使用提示
      const hintButton = screen.getByRole('button', { name: /提示/ });
      await act(async () => {
        fireEvent.click(hintButton);
      });

      // 提示已使用，剩余次数变为 1
      await waitFor(() => {
        expect(screen.getByText(/提示 \(1\)/)).toBeDefined();
      });

      // 完成任务
      const segments = document.querySelectorAll('.segment-interactive');
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      await waitFor(() => {
        expect(screen.getByRole('button', { name: /完成/ })).toBeEnabled();
      });
    });
  });

  describe('反馈显示', () => {
    it('任务完成时应显示成功反馈', async () => {
      render(<ConcreteStep {...defaultProps} />);

      const segments = document.querySelectorAll('.segment-interactive');
      await act(async () => {
        fireEvent.click(segments[0]);
      });

      await waitFor(() => {
        const feedback = document.querySelector('.step-feedback-success');
        expect(feedback).toBeDefined();
      });
    });
  });
});
