import React from 'react';
import { StepContainer } from './StepContainer';
import { StepFeedback } from './StepFeedback';
import './VerificationStep.css';

interface VerificationStepProps {
  /** 步骤索引 */
  stepIndex: number;
  /** 步骤标题 */
  title: string;
  /** 引导说明 */
  instruction: string;
  /** 验证内容 */
  children?: React.ReactNode;
  /** 反馈信息 */
  feedback?: {
    type: 'success' | 'error' | 'hint';
    message: string;
  } | null;
  /** 步骤完成状态 */
  isCompleted?: boolean;
  /** 验证结果 */
  result?: {
    passed: boolean;
    message?: string;
  } | null;
  /** 额外类名 */
  className?: string;
}

/**
 * 验证步骤组件
 * @description 对应数学思维启发六步法中的"验证"步骤
 * 学生验证自己猜想的正确性
 */
export const VerificationStep: React.FC<VerificationStepProps> = ({
  stepIndex,
  title,
  instruction,
  children,
  feedback,
  isCompleted = false,
  result,
  className = '',
}) => {
  return (
    <StepContainer
      stepName={title}
      stepIndex={stepIndex}
      stepType="verification"
      emoji="✅"
      className={`verification-step ${isCompleted ? 'completed' : ''} ${result?.passed ? 'passed' : ''} ${result && !result.passed ? 'failed' : ''} ${className}`}
    >
      <div className="verification-step-instruction" data-testid={`verification-instruction-${stepIndex}`}>
        <span className="instruction-icon">🔍</span>
        <span className="instruction-text">{instruction}</span>
      </div>

      <div className="verification-step-content">
        {children}
      </div>

      {result && (
        <div
          className={`verification-result ${result.passed ? 'passed' : 'failed'}`}
          data-testid={`verification-result-${stepIndex}`}
        >
          <span className="result-icon">{result.passed ? '✅' : '❌'}</span>
          <span className="result-message">{result.message || (result.passed ? '验证通过！' : '验证未通过')}</span>
        </div>
      )}

      {feedback && (
        <StepFeedback
          type={feedback.type}
          message={feedback.message}
        />
      )}

      {isCompleted && !feedback && (
        <StepFeedback
          type="success"
          message="验证完成！继续下一步。"
        />
      )}
    </StepContainer>
  );
};

export default VerificationStep;
