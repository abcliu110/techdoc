import React, { useState, useCallback } from 'react';
import './SplitCircle.css';

interface SplitCircleProps {
  /** 圆形分母（分割数） */
  denominator: number;
  /** 高亮显示的段索引列表 */
  highlighted?: number[];
  /** 高亮变化的回调 */
  onHighlightChange?: (indices: number[]) => void;
  /** 交互完成回调 */
  onComplete?: () => void;
  /** data-testid 前缀 */
  'data-testid'?: string;
  /** 是否可交互 */
  interactive?: boolean;
  /** 圆形半径 */
  radius?: number;
}

/**
 * 分割圆可视化组件
 * @description 用于展示分数概念的圆形分割可视化，支持点击切换高亮状态
 */
export const SplitCircle: React.FC<SplitCircleProps> = ({
  denominator,
  highlighted = [],
  onHighlightChange,
  onComplete,
  'data-testid': dataTestId = 'visual-split-circle',
  interactive = true,
  radius = 80,
}) => {
  const [localHighlighted, setLocalHighlighted] = useState<number[]>(highlighted);
  const [isComplete, setIsComplete] = useState(false);

  // 计算SVG路径
  const createArcPath = useCallback((startAngle: number, endAngle: number): string => {
    const centerX = radius + 10;
    const centerY = radius + 10;
    const startRad = (startAngle - 90) * (Math.PI / 180);
    const endRad = (endAngle - 90) * (Math.PI / 180);

    const x1 = centerX + radius * Math.cos(startRad);
    const y1 = centerY + radius * Math.sin(startRad);
    const x2 = centerX + radius * Math.cos(endRad);
    const y2 = centerY + radius * Math.sin(endRad);

    const largeArcFlag = endAngle - startAngle > 180 ? 1 : 0;

    return `M ${centerX} ${centerY} L ${x1} ${y1} A ${radius} ${radius} 0 ${largeArcFlag} 1 ${x2} ${y2} Z`;
  }, [radius]);

  // 计算每段的角度（安全处理 denominator 为 0 或过大的情况）
  const safeDenominator = Math.min(Math.max(denominator, 1), 360);
  const segmentAngle = 360 / safeDenominator;

  // 处理段点击
  const handleSegmentClick = useCallback((index: number) => {
    if (!interactive) return;

    const newHighlighted = localHighlighted.includes(index)
      ? localHighlighted.filter(i => i !== index)
      : [...localHighlighted, index];

    setLocalHighlighted(newHighlighted);
    onHighlightChange?.(newHighlighted);

    // 检查是否完成（所有段都被高亮）
    if (newHighlighted.length === denominator && !isComplete) {
      setIsComplete(true);
      onComplete?.();
    }
  }, [interactive, localHighlighted, denominator, onHighlightChange, onComplete, isComplete]);

  return (
    <div className="split-circle-container" data-testid={dataTestId}>
      <svg
        width={(radius + 10) * 2}
        height={(radius + 10) * 2}
        viewBox={`0 0 ${(radius + 10) * 2} ${(radius + 10) * 2}`}
        className="split-circle-svg"
      >
        {/* 背景圆 */}
        <circle
          cx={radius + 10}
          cy={radius + 10}
          r={radius}
          className="split-circle-bg"
        />

        {/* 分割段（使用 safeDenominator 防止循环边界异常） */}
        {Array.from({ length: safeDenominator }).map((_, index) => {
          const startAngle = index * segmentAngle;
          const endAngle = (index + 1) * segmentAngle;
          const isHighlighted = localHighlighted.includes(index);

          return (
            <path
              key={index}
              d={createArcPath(startAngle, endAngle)}
              className={`split-circle-segment ${isHighlighted ? 'highlighted' : ''}`}
              onClick={() => handleSegmentClick(index)}
              data-testid={`${dataTestId}-segment-${index}`}
              style={{ cursor: interactive ? 'pointer' : 'default' }}
            />
          );
        })}

        {/* 中心文字 */}
        <text
          x={radius + 10}
          y={radius + 10}
          textAnchor="middle"
          dominantBaseline="central"
          className="split-circle-text"
        >
          {localHighlighted.length}/{denominator}
        </text>
      </svg>

      {isComplete && (
        <div className="split-circle-complete" data-testid={`${dataTestId}-complete`}>
          分割完成！
        </div>
      )}
    </div>
  );
};

export default SplitCircle;
