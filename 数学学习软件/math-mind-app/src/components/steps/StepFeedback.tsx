import React from 'react';
import './StepFeedback.css';

interface StepFeedbackProps {
  /** 反馈类型 */
  type: 'success' | 'error' | 'hint' | 'info';
  /** 反馈消息 */
  message: string;
}

/**
 * 步骤反馈组件
 * @description 显示操作结果的反馈信息
 */
export const StepFeedback: React.FC<StepFeedbackProps> = ({
  type,
  message,
}) => {
  const icons = {
    success: '🎉',
    error: '❌',
    hint: '💡',
    info: 'ℹ️',
  };

  return (
    <div
      className={`step-feedback step-feedback-${type}`}
      data-testid={`feedback-${type}`}
    >
      <span className="step-feedback-icon">{icons[type]}</span>
      <span className="step-feedback-message">{message}</span>
    </div>
  );
};

export default StepFeedback;
