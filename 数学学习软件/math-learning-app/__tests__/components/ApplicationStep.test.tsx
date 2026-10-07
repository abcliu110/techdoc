import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { ApplicationStep } from '../../src/components/steps/ApplicationStep';
import type { ApplicationContent, VariantItem } from '../../src/domain/types/learning-step';

describe('ApplicationStep 组件', () => {
  const mockVariants: VariantItem[] = [
    { id: 'q1', question: '1/2 等于多少？', options: ['0.5', '0.25', '0.75', '1'], correctAnswer: '0.5' },
    { id: 'q2', question: '1/4 等于多少？', options: ['0.5', '0.25', '0.75', '1'], correctAnswer: '0.25' },
    { id: 'q3', question: '3/4 等于多少？', options: ['0.5', '0.25', '0.75', '1'], correctAnswer: '0.75' },
  ];

  const mockContent: ApplicationContent = {
    type: 'application',
    instruction: '完成下面的变式练习',
    variants: mockVariants,
    minCorrect: 2,
  };

  const defaultProps = {
    content: mockContent,
    stepName: '迁移应用',
    stepIndex: 3,
    totalSteps: 4,
    hintLevels: ['提示1'],
    onComplete: vi.fn(),
    onHint: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('渲染', () => {
    it('应该渲染题目数量', () => {
      render(<ApplicationStep {...defaultProps} />);
      expect(document.querySelector('.progress-text')?.textContent).toContain('1');
      expect(document.querySelector('.progress-text')?.textContent).toContain('3');
    });

    it('应该渲染进度条', () => {
      render(<ApplicationStep {...defaultProps} />);
      expect(document.querySelector('.progress-indicator')).toBeDefined();
    });

    it('应该渲染统计信息', () => {
      render(<ApplicationStep {...defaultProps} />);
      expect(document.querySelector('.stats-card')).toBeDefined();
      expect(document.querySelector('.stat-label')?.textContent).toContain('正确');
    });

    it('应该渲染第一道题目', () => {
      render(<ApplicationStep {...defaultProps} />);
      expect(document.querySelector('.question-text')?.textContent).toContain('1/2');
    });

    it('应该渲染选项', () => {
      render(<ApplicationStep {...defaultProps} />);
      const options = document.querySelectorAll('.option-item');
      expect(options.length).toBe(4);
    });
  });

  describe('基本属性', () => {
    it('应该显示步骤名称', () => {
      render(<ApplicationStep {...defaultProps} />);
      expect(document.querySelector('.step-name')?.textContent).toContain('迁移应用');
    });

    it('应该显示迁移应用标题', () => {
      render(<ApplicationStep {...defaultProps} />);
      const instructionCards = document.querySelectorAll('.instruction-card h3');
      expect(instructionCards[0]?.textContent).toContain('迁移应用');
    });
  });
});
