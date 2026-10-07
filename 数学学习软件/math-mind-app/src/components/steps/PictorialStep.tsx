import React from 'react';
import { StepContainer } from './StepContainer';
import { StepFeedback } from './StepFeedback';
import './PictorialStep.css';

interface PictorialStepProps {
  /** 步骤索引 */
  stepIndex: number;
  /** 步骤标题 */
  title: string;
  /** 引导说明 */
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
 * 图示表达步骤组件
 * @description 对应数学思维启发六步法中的"图示表达"步骤
 * 学生通过图形、图表等形象化的方式表达数学概念
 */
export const PictorialStep: React.FC<PictorialStepProps> = ({
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
      stepType="pictorial"
      emoji="🎨"
      className={`pictorial-step ${isCompleted ? 'completed' : ''} ${className}`}
    >
      <div className="pictorial-step-instruction" data-testid={`pictorial-instruction-${stepIndex}`}>
        <span className="instruction-icon">📊</span>
        <span className="instruction-text">{instruction}</span>
      </div>

      <div className="pictorial-step-content">
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
          message="图示表达完成！继续下一步。"
        />
      )}
    </StepContainer>
  );
};

export default PictorialStep;
