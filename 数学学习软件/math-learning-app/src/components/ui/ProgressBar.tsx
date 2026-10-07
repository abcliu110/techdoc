import React from 'react';
import './ProgressBar.css';

interface ProgressBarProps {
  /** 当前进度值 (0-100) */
  value: number;
  /** 进度条高度 */
  height?: number;
  /** 是否显示进度文字 */
  showLabel?: boolean;
  /** 额外类名 */
  className?: string;
}

/**
 * 通用进度条组件
 * - 显示学习进度
 * - 支持自定义高度和标签显示
 */
export const ProgressBar: React.FC<ProgressBarProps> = ({
  value,
  height = 8,
  showLabel = true,
  className = '',
}) => {
  const clampedValue = Math.min(100, Math.max(0, value));

  return (
    <div className={`progress-container ${className}`}>
      <div
        className="progress-bar"
        style={{ height: `${height}px` }}
      >
        <div
          className="progress-fill"
          style={{ width: `${clampedValue}%` }}
        />
      </div>
      {showLabel && (
        <span className="progress-label">{Math.round(clampedValue)}%</span>
      )}
    </div>
  );
};

export default ProgressBar;
