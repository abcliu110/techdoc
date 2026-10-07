import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { StepContainer } from '../../src/components/steps/StepContainer';
import type { LearningStep, ConcreteContent, SymbolicContent } from '../../src/domain/types/learning-step';
import { StepType } from '../../src/domain/types/learning-step';

describe('StepContainer 组件', () => {
  const concreteContent: ConcreteContent = {
    type: 'concrete',
    scenario: { title: '测试', description: '测试描述', emoji: '🎯' },
    interaction: { kind: 'split', target: '任务', visualType: 'Split', visualConfig: {} },
  };

  const symbolicContent: SymbolicContent = {
    type: 'symbolic',
    instruction: '输入答案',
    inputType: 'fraction',
    expectedAnswer: '3/4',
  };

  const createMockStep = (type: StepType, content: any): LearningStep => ({
    id: `step-${type}`,
    type,
    name: '测试步骤',
    instruction: '测试指令',
    content,
    completionCriteria: { type: 'interactive' as any, config: {} },
    hintLevels: ['提示'],
    ability: 'test' as any,
  });

  const defaultProps = {
    step: createMockStep(StepType.CONCRETE, concreteContent),
    stepIndex: 0,
    totalSteps: 5,
    onComplete: vi.fn(),
    onHint: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('步骤类型路由', () => {
    it('CONCRETE 类型应渲染 ConcreteStep', () => {
      render(<StepContainer {...defaultProps} />);
      expect(document.querySelector('.concrete-step')).toBeDefined();
    });

    it('SYMBOLIC 类型应渲染 SymbolicStep', () => {
      render(
        <StepContainer
          {...defaultProps}
          step={createMockStep(StepType.SYMBOLIC, symbolicContent)}
        />
      );
      expect(document.querySelector('.symbolic-step')).toBeDefined();
    });

    it('未实现的步骤类型应有占位符样式', () => {
      render(
        <StepContainer
          {...defaultProps}
          step={createMockStep(StepType.PICTORIAL, { type: 'pictorial' })}
        />
      );
      // 应该有 pictorial-step 样式类
      expect(document.querySelector('.pictorial-step')).toBeDefined();
    });
  });
});
