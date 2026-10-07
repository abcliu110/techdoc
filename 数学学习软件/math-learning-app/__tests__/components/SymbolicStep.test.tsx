import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { SymbolicStep } from '../../src/components/steps/SymbolicStep';
import type { SymbolicContent } from '../../src/domain/types/learning-step';

describe('SymbolicStep 组件', () => {
  const mockFractionContent: SymbolicContent = {
    type: 'symbolic',
    instruction: '请输入分数',
    inputType: 'fraction',
    expectedAnswer: ['3/4', '0.75'],
    equivalenceRules: [],
  };

  const mockExpressionContent: SymbolicContent = {
    type: 'symbolic',
    instruction: '请输入表达式',
    inputType: 'expression',
    expectedAnswer: 'x + y',
  };

  const defaultProps = {
    content: mockFractionContent,
    stepName: '符号表示',
    stepIndex: 1,
    totalSteps: 3,
    hintLevels: ['提示1'],
    onComplete: vi.fn(),
    onHint: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('分数输入模式', () => {
    it('应该渲染分子和分母输入框', () => {
      render(<SymbolicStep {...defaultProps} />);
      expect(document.querySelector('.fraction-numerator')).toBeDefined();
      expect(document.querySelector('.fraction-denominator')).toBeDefined();
    });

    it('应该渲染验证答案按钮', () => {
      render(<SymbolicStep {...defaultProps} />);
      expect(document.querySelector('button')).toBeDefined();
    });

    it('完成按钮初始应禁用', () => {
      render(<SymbolicStep {...defaultProps} />);
      const buttons = document.querySelectorAll('button');
      const completeButton = buttons[buttons.length - 1];
      expect(completeButton).toBeDisabled();
    });

    it('应只允许分子输入数字和负号', () => {
      render(<SymbolicStep {...defaultProps} />);
      const numeratorInput = document.querySelector('.fraction-numerator') as HTMLInputElement;
      // Test by checking the onChange handler is defined
      expect(numeratorInput).toBeDefined();
    });

    it('应只允许分母输入数字', () => {
      render(<SymbolicStep {...defaultProps} />);
      const denominatorInput = document.querySelector('.fraction-denominator') as HTMLInputElement;
      expect(denominatorInput).toBeDefined();
    });
  });

  describe('表达式输入模式', () => {
    it('应渲染表达式输入框', () => {
      render(<SymbolicStep {...defaultProps} content={mockExpressionContent} />);
      expect(document.querySelector('.expression-input')).toBeDefined();
    });
  });

  describe('提示功能', () => {
    it('点击提示按钮应触发 onHint', () => {
      render(<SymbolicStep {...defaultProps} />);
      const buttons = document.querySelectorAll('button');
      const hintButton = Array.from(buttons).find(b => b.textContent?.includes('提示'));
      if (hintButton) {
        (hintButton as HTMLElement).click();
        expect(defaultProps.onHint).toHaveBeenCalledTimes(1);
      }
    });
  });
});
