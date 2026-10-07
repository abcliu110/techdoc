import React from 'react';
import './StepFeedback.css';

interface StepFeedbackProps {
  /** 反馈类型 */
  type: 'success' | 'hint' | 'error';
  /** 反馈消息 */
  message: string;
}

/**
 * 步骤反馈组件
 * 显示成功、提示或错误信息
 */
export const StepFeedback: React.FC<StepFeedbackProps> = ({
  type,
  message,
}) => {
  const getIcon = () => {
    switch (type) {
      case 'success':
        return '✓';
      case 'hint':
        return '💡';
      case 'error':
        return '✗';
    }
  };

  return (
    <div className={`step-feedback step-feedback-${type}`}>
      <span className="feedback-icon">{getIcon()}</span>
      <span className="feedback-message">{message}</span>
    </div>
  );
};

export default StepFeedback;
