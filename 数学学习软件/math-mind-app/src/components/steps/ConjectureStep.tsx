import React from 'react';
import { StepContainer } from './StepContainer';
import { StepFeedback } from './StepFeedback';
import './ConjectureStep.css';

interface ConjectureStepProps {
  /** 步骤索引 */
  stepIndex: number;
  /** 步骤标题 */
  title: string;
  /** 引导说明 */
  instruction: string;
  /** 学生输入的猜想 */
  studentConjecture?: string;
  /** 设置学生猜想的回调 */
  onConjectureChange?: (value: string) => void;
  /** 反馈信息 */
  feedback?: {
    type: 'success' | 'error' | 'hint';
    message: string;
  } | null;
  /** 步骤完成状态 */
  isCompleted?: boolean;
  /** 是否显示验证区域 */
  showVerification?: boolean;
  /** 验证内容 */
  verificationContent?: React.ReactNode;
  /** 额外类名 */
  className?: string;
}

/**
 * 猜想步骤组件
 * @description 对应数学思维启发六步法中的"猜想"步骤
 * 包括猜想和验证两个子阶段
 */
export const ConjectureStep: React.FC<ConjectureStepProps> = ({
  stepIndex,
  title,
  instruction,
  studentConjecture,
  onConjectureChange,
  feedback,
  isCompleted = false,
  showVerification = false,
  verificationContent,
  className = '',
}) => {
  return (
    <StepContainer
      stepName={title}
      stepIndex={stepIndex}
      stepType="conjecture"
      emoji="💡"
      className={`conjecture-step ${isCompleted ? 'completed' : ''} ${className}`}
    >
      <div className="conjecture-step-instruction" data-testid={`conjecture-instruction-${stepIndex}`}>
        <span className="instruction-icon">🤔</span>
        <span className="instruction-text">{instruction}</span>
      </div>

      <div className="conjecture-step-content">
        <div className="conjecture-input-area" data-testid={`conjecture-input-${stepIndex}`}>
          <label className="conjecture-label">你的猜想：</label>
          <textarea
            className="conjecture-textarea"
            value={studentConjecture || ''}
            onChange={(e) => onConjectureChange?.(e.target.value)}
            placeholder="请输入你的猜想..."
            rows={3}
            data-testid={`conjecture-textarea-${stepIndex}`}
          />
        </div>

        {showVerification && (
          <div className="verification-area" data-testid={`verification-area-${stepIndex}`}>
            <h4 className="verification-title">验证过程</h4>
            {verificationContent || (
              <div className="verification-placeholder">
                在这里展示验证过程...
              </div>
            )}
          </div>
        )}
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
          message="猜想完成！继续下一步。"
        />
      )}
    </StepContainer>
  );
};

export default ConjectureStep;
