import React from 'react';
import './StepContainer.css';

interface StepContainerProps {
  /** 步骤名称 */
  stepName: string;
  /** 步骤索引 */
  stepIndex: number;
  /** 步骤类型 */
  stepType: string;
  /** 步骤图标 */
  emoji?: string;
  /** 步骤内容 */
  children: React.ReactNode;
  /** 额外类名 */
  className?: string;
}

/**
 * 步骤容器组件
 * @description 统一包裹所有步骤类型的容器，提供统一的样式和布局
 */
export const StepContainer: React.FC<StepContainerProps> = (props) => {
  const {
    stepName,
    stepIndex,
    stepType,
    emoji,
    children,
    className = '',
  } = props;
  return (
    <div
      className={`step-container step-type-${stepType} ${className}`}
      data-testid={`step-${stepType}-${stepIndex}`}
    >
      <div className="step-header">
        <div className="step-badge">
          <span className="step-emoji">{emoji || '📚'}</span>
          <span className="step-label">{stepName}</span>
        </div>
        <div className="step-indicator">
          步骤 {stepIndex + 1}
        </div>
      </div>

      <div className="step-body" data-testid={`step-body-${stepIndex}`}>
        {children}
      </div>
    </div>
  );
};

export default StepContainer;
