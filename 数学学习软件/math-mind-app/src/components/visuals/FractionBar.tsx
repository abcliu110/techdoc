import React, { useState, useCallback } from 'react';
import './FractionBar.css';

interface FractionBarProps {
  /** 条形图分母 */
  denominator: number;
  /** 高亮显示的段数 */
  highlighted?: number[];
  /** 高亮变化的回调 */
  onHighlightChange?: (indices: number[]) => void;
  /** 交互完成回调 */
  onComplete?: () => void;
  /** data-testid 前缀 */
  'data-testid'?: string;
  /** 是否可交互 */
  interactive?: boolean;
  /** 条形图宽度 */
  width?: number;
  /** 条形图高度 */
  height?: number;
  /** 颜色主题 */
  color?: string;
}

/**
 * 分数条形图可视化组件
 * @description 用于展示分数概念的条形图分割可视化
 */
export const FractionBar: React.FC<FractionBarProps> = ({
  denominator,
  highlighted = [],
  onHighlightChange,
  onComplete,
  'data-testid': dataTestId = 'visual-fraction-bar',
  interactive = true,
  width = 280,
  height = 40,
  color,
}) => {
  const [localHighlighted, setLocalHighlighted] = useState<number[]>(highlighted);
  const [isComplete, setIsComplete] = useState(false);

  const segmentWidth = denominator > 0 ? width / denominator : width;
  const fillColor = color || 'var(--color-primary, #4f46e5)';

  // 处理段点击
  const handleSegmentClick = useCallback((index: number) => {
    if (!interactive) return;

    const newHighlighted = localHighlighted.includes(index)
      ? localHighlighted.filter(i => i !== index)
      : [...localHighlighted, index];

    setLocalHighlighted(newHighlighted);
    onHighlightChange?.(newHighlighted);

    // 检查是否完成
    if (newHighlighted.length === denominator && !isComplete) {
      setIsComplete(true);
      onComplete?.();
    }
  }, [interactive, localHighlighted, denominator, onHighlightChange, onComplete, isComplete]);

  // 处理"自动填充"按钮
  const handleAutoFill = useCallback(() => {
    const allIndices = Array.from({ length: denominator }, (_, i) => i);
    setLocalHighlighted(allIndices);
    onHighlightChange?.(allIndices);
    setIsComplete(true);
    onComplete?.();
  }, [denominator, onHighlightChange, onComplete]);

  return (
    <div className="fraction-bar-container" data-testid={dataTestId}>
      <div className="fraction-bar-label" data-testid={`${dataTestId}-label`}>
        {localHighlighted.length}/{denominator}
      </div>

      <div
        className="fraction-bar"
        style={{ width, height }}
        data-testid={`${dataTestId}-bar`}
      >
        {Array.from({ length: denominator }).map((_, index) => {
          const isHighlighted = localHighlighted.includes(index);

          return (
            <div
              key={index}
              className={`fraction-bar-segment ${isHighlighted ? 'highlighted' : ''}`}
              style={{
                width: segmentWidth,
                height,
                backgroundColor: isHighlighted ? fillColor : undefined,
              }}
              onClick={() => handleSegmentClick(index)}
              data-testid={`${dataTestId}-segment-${index}`}
            />
          );
        })}
      </div>

      {interactive && !isComplete && (
        <button
          className="fraction-bar-auto-btn"
          onClick={handleAutoFill}
          data-testid={`${dataTestId}-auto-btn`}
        >
          自动填充
        </button>
      )}

      {isComplete && (
        <div className="fraction-bar-complete" data-testid={`${dataTestId}-complete`}>
          完成！
        </div>
      )}
    </div>
  );
};

export default FractionBar;
