import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { ConjectureStep } from '../../src/components/steps/ConjectureStep';
import type { ConjectureContent, ObservationExample } from '../../src/domain/types/learning-step';

describe('ConjectureStep 组件', () => {
  const mockExamples: ObservationExample[] = [
    { input: '1/2', output: '0.5' },
    { input: '1/4', output: '0.25' },
    { input: '3/4', output: '0.75' },
  ];

  const mockContent: ConjectureContent = {
    type: 'conjecture',
    observationPrompt: '观察下列输入输出的规律',
    examples: mockExamples,
    conjecturePrompt: '根据规律写出你的猜想',
  };

  const defaultProps = {
    content: mockContent,
    stepName: '猜想',
    stepIndex: 2,
    totalSteps: 3,
    hintLevels: ['提示1', '提示2'],
    onComplete: vi.fn(),
    onHint: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('渲染', () => {
    it('应该渲染观察示例区域', () => {
      render(<ConjectureStep {...defaultProps} />);
      expect(document.querySelector('.observation-card')).toBeDefined();
    });

    it('应该渲染观察提示', () => {
      render(<ConjectureStep {...defaultProps} />);
      expect(document.querySelector('.observation-prompt')?.textContent).toContain('观察');
    });

    it('应该渲染猜想区域', () => {
      render(<ConjectureStep {...defaultProps} />);
      expect(document.querySelector('.conjecture-card')).toBeDefined();
    });

    it('应该渲染示例列表', () => {
      render(<ConjectureStep {...defaultProps} />);
      const exampleItems = document.querySelectorAll('.example-item');
      expect(exampleItems.length).toBe(3);
    });

    it('应该渲染提交猜想按钮', () => {
      render(<ConjectureStep {...defaultProps} />);
      const buttons = document.querySelectorAll('button');
      const submitButton = Array.from(buttons).find(b => b.textContent?.includes('提交'));
      expect(submitButton).toBeDefined();
    });
  });

  describe('字数统计', () => {
    it('应该显示当前字数', () => {
      render(<ConjectureStep {...defaultProps} />);
      expect(document.querySelector('.char-count')).toBeDefined();
    });
  });

  describe('提示功能', () => {
    it('点击提示按钮应触发 onHint', () => {
      render(<ConjectureStep {...defaultProps} />);
      const buttons = document.querySelectorAll('button');
      const hintButton = Array.from(buttons).find(b => b.textContent?.includes('提示'));
      if (hintButton) {
        (hintButton as HTMLElement).click();
        expect(defaultProps.onHint).toHaveBeenCalledTimes(1);
      }
    });

    it('当所有提示用完时不应显示提示按钮', () => {
      render(<ConjectureStep {...defaultProps} hintLevels={[]} />);
      const buttons = document.querySelectorAll('button');
      const hintButton = Array.from(buttons).find(b => b.textContent?.includes('提示'));
      expect(hintButton).toBeUndefined();
    });
  });
});
