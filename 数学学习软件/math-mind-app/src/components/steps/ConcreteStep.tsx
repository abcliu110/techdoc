import React from 'react';
import { StepContainer } from './StepContainer';
import { StepFeedback } from './StepFeedback';
import './ConcreteStep.css';

interface ConcreteStepProps {
  /** 步骤索引 */
  stepIndex: number;
  /** 步骤标题 */
  title: string;
  /** 操作指令 */
  instruction: string;
  /** 子组件（可视化元素） */
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
 * 具象操作步骤组件
 * @description 对应数学思维启发六步法中的"具象操作"步骤
 * 学生通过动手操作实物或模型来感知数学概念
 */
export const ConcreteStep: React.FC<ConcreteStepProps> = ({
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
      stepType="concrete"
      emoji="🎯"
      className={`concrete-step ${isCompleted ? 'completed' : ''} ${className}`}
    >
      <div className="concrete-step-instruction" data-testid={`concrete-instruction-${stepIndex}`}>
        <span className="instruction-icon">📖</span>
        <span className="instruction-text">{instruction}</span>
      </div>

      <div className="concrete-step-content">
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
          message="操作完成！继续下一步。"
        />
      )}
    </StepContainer>
  );
};

export default ConcreteStep;
