import React from 'react';
import './StepHeader.css';

interface StepHeaderProps {
  /** 步骤名称 */
  stepName: string;
  /** 步骤索引 */
  stepIndex: number;
  /** 步骤图标（emoji） */
  emoji?: string;
  /** data-testid */
  'data-testid'?: string;
}

/**
 * 步骤头部组件
 * @description 显示步骤的名称、图标和索引信息
 */
export const StepHeader: React.FC<StepHeaderProps> = ({
  stepName,
  stepIndex,
  emoji = '📚',
  'data-testid': dataTestId = 'step-header',
}) => {
  return (
    <div className="step-header-component" data-testid={dataTestId}>
      <span className="step-header-emoji">{emoji}</span>
      <div className="step-header-info">
        <h2 className="step-header-name">{stepName}</h2>
        <span className="step-header-index">第 {stepIndex + 1} 步</span>
      </div>
    </div>
  );
};

export default StepHeader;
