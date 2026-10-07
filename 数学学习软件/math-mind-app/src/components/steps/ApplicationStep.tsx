import React from 'react';
import { StepContainer } from './StepContainer';
import { StepFeedback } from './StepFeedback';
import './ApplicationStep.css';

interface ApplicationStepProps {
  /** 步骤索引 */
  stepIndex: number;
  /** 步骤标题 */
  title: string;
  /** 引导说明 */
  instruction: string;
  /** 子组件（应用场景元素） */
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
 * 迁移应用步骤组件
 * @description 对应数学思维启发六步法中的"迁移应用"步骤
 * 学生将学到的数学概念应用到新的问题情境中
 */
export const ApplicationStep: React.FC<ApplicationStepProps> = ({
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
      stepType="application"
      emoji="🚀"
      className={`application-step ${isCompleted ? 'completed' : ''} ${className}`}
    >
      <div className="application-step-instruction" data-testid={`application-instruction-${stepIndex}`}>
        <span className="instruction-icon">🌟</span>
        <span className="instruction-text">{instruction}</span>
      </div>

      <div className="application-step-content">
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
          message="应用完成！恭喜你完成了这个知识点的学习。"
        />
      )}
    </StepContainer>
  );
};

export default ApplicationStep;
