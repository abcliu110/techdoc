import React from 'react';
import { StepContainer } from './StepContainer';
import { StepFeedback } from './StepFeedback';
import './SymbolicStep.css';

interface SymbolicStepProps {
  /** 步骤索引 */
  stepIndex: number;
  /** 步骤标题 */
  title: string;
  /** 引导说明 */
  instruction: string;
  /** 子组件（输入元素） */
  children?: React.ReactNode;
  /** 反馈信息 */
  feedback?: {
    type: 'success' | 'error' | 'hint';
    message: string;
  } | null;
  /** 步骤完成状态 */
  isCompleted?: boolean;
  /** 额外类名 */
  className?: string;
}

/**
 * 符号表示步骤组件
 * @description 对应数学思维启发六步法中的"符号表示"步骤
 * 学生通过数学符号、算式等抽象化的方式表达数学概念
 */
export const SymbolicStep: React.FC<SymbolicStepProps> = ({
  stepIndex,
  title,
  instruction,
  children,
  feedback,
  isCompleted = false,
  className = '',
}) => {
  return (
    <StepContainer
      stepName={title}
      stepIndex={stepIndex}
      stepType="symbolic"
      emoji="📝"
      className={`symbolic-step ${isCompleted ? 'completed' : ''} ${className}`}
    >
      <div className="symbolic-step-instruction" data-testid={`symbolic-instruction-${stepIndex}`}>
        <span className="instruction-icon">🧮</span>
        <span className="instruction-text">{instruction}</span>
      </div>

      <div className="symbolic-step-content">
        {children}
      </div>

      {feedback && (
        <StepFeedback
          type={feedback.type}
          message={feedback.message}
        />
      )}

      {isCompleted && !feedback && (
        <StepFeedback
          type="success"
          message="符号表达完成！继续下一步。"
        />
      )}
    </StepContainer>
  );
};

export default SymbolicStep;
