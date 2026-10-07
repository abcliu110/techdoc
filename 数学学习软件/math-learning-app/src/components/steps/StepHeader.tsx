import React from 'react';
import './StepHeader.css';

interface StepHeaderProps {
  /** 步骤名称 */
  stepName: string;
  /** 步骤索引 */
  stepIndex: number;
  /** 表情符号 */
  emoji?: string;
  /** 总步骤数 */
  totalSteps?: number;
}

/**
 * 步骤头部组件
 * 显示步骤名称、索引和进度
 */
export const StepHeader: React.FC<StepHeaderProps> = ({
  stepName,
  stepIndex,
  emoji,
  totalSteps,
}) => {
  return (
    <div className="step-header">
      <div className="step-info">
        {emoji && <span className="step-emoji">{emoji}</span>}
        <span className="step-name">{stepName}</span>
      </div>
      {totalSteps !== undefined && (
        <div className="step-progress">
          {stepIndex + 1} / {totalSteps}
        </div>
      )}
    </div>
  );
};

export default StepHeader;
