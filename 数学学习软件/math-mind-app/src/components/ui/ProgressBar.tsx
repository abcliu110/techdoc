import React from 'react';
import './ProgressBar.css';

interface ProgressBarProps {
  /** 当前进度值 */
  value: number;
  /** 最大值 */
  max?: number;
  /** data-testid */
  'data-testid'?: string;
  /** 进度条变体 */
  variant?: 'primary' | 'success' | 'warning';
  /** 是否显示百分比文字 */
  showText?: boolean;
  /** 高度 */
  height?: number;
  /** 额外类名 */
  className?: string;
}

/**
 * 进度条组件
 * @description 展示任务/步骤完成的进度
 */
export const ProgressBar: React.FC<ProgressBarProps> = ({
  value,
  max = 100,
  'data-testid': dataTestId,
  variant = 'primary',
  showText = true,
  height = 8,
  className = '',
}) => {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));

  return (
    <div
      className={`progress-bar-container ${className}`}
      data-testid={dataTestId}
      role="progressbar"
      aria-valuenow={value}
      aria-valuemin={0}
      aria-valuemax={max}
    >
      <div
        className={`progress-bar progress-bar-${variant}`}
        style={{ height: `${height}px` }}
      >
        <div
          className="progress-bar-fill"
          style={{ width: `${percentage}%` }}
        />
      </div>
      {showText && (
        <span className="progress-bar-text" data-testid={`${dataTestId || 'progress-bar'}-text`}>
          {Math.round(percentage)}%
        </span>
      )}
    </div>
  );
};

export default ProgressBar;
