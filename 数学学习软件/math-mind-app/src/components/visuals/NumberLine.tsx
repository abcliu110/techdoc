import React, { useState, useCallback, useMemo } from 'react';
import './NumberLine.css';

interface NumberLinePoint {
  /** 点在数轴上的位置（数值） */
  value: number;
  /** 标签文本（可选，默认显示数值） */
  label?: string;
  /** 是否是整数点 */
  isInteger?: boolean;
}

interface NumberLineProps {
  /** 组件 ID */
  id: string;
  /** 数轴起点 */
  min: number;
  /** 数轴终点 */
  max: number;
  /** 刻度步长 */
  step?: number;
  /** 要显示的点 */
  points?: NumberLinePoint[];
  /** 高亮显示的点索引 */
  highlightedPoints?: number[];
  /** 点被点击的回调 */
  onPointClick?: (point: NumberLinePoint, index: number) => void;
  /** 是否可交互 */
  interactive?: boolean;
  /** 数轴宽度 */
  width?: number;
  /** 数轴高度 */
  height?: number;
  /** 自定义颜色 */
  color?: string;
  /** data-testid 前缀 */
  'data-testid'?: string;
}

/**
 * 数轴可视化组件
 * @description 用于展示数轴、标记数值点，支持点击选择
 */
export const NumberLine: React.FC<NumberLineProps> = ({
  id,
  min,
  max,
  step = 1,
  points = [],
  highlightedPoints = [],
  onPointClick,
  interactive = true,
  width = 400,
  height = 120,
  color,
  'data-testid': dataTestId = 'visual-number-line',
}) => {
  const [localHighlighted, setLocalHighlighted] = useState<number[]>(highlightedPoints);
  const [selectedPoint, setSelectedPoint] = useState<number | null>(null);

  const lineColor = color || 'var(--color-primary, #4f46e5)';

  // 计算刻度位置
  const ticks = useMemo(() => {
    const result: number[] = [];
    for (let i = min; i <= max; i += step) {
      result.push(i);
    }
    return result;
  }, [min, max, step]);

  // 计算点的像素位置
  const getPosition = useCallback((value: number): number => {
    const padding = 30;
    const lineWidth = width - padding * 2;
    return padding + ((value - min) / (max - min)) * lineWidth;
  }, [min, max, width]);

  // 处理点点击
  const handlePointClick = useCallback((point: NumberLinePoint, index: number) => {
    if (!interactive) return;

    setSelectedPoint(point.value);

    const newHighlighted = localHighlighted.includes(index)
      ? localHighlighted.filter(i => i !== index)
      : [...localHighlighted, index];

    setLocalHighlighted(newHighlighted);
    onPointClick?.(point, index);
  }, [interactive, localHighlighted, onPointClick]);

  // 处理清空选择
  const handleClearSelection = useCallback(() => {
    setSelectedPoint(null);
    setLocalHighlighted([]);
  }, []);

  return (
    <div className="number-line-container" data-testid={`${dataTestId}-${id}`}>
      <svg
        width={width}
        height={height}
        viewBox={`0 0 ${width} ${height}`}
        className="number-line-svg"
      >
        {/* 数轴主线 */}
        <line
          x1={20}
          y1={height / 2}
          x2={width - 20}
          y2={height / 2}
          className="number-line-axis"
          stroke={lineColor}
          strokeWidth={3}
        />

        {/* 箭头 */}
        <polygon
          points={`${width - 15},${height / 2 - 6} ${width - 15},${height / 2 + 6} ${width - 5},${height / 2}`}
          fill={lineColor}
        />

        {/* 刻度和标签 */}
        {ticks.map((tick) => {
          const x = getPosition(tick);
          return (
            <g key={tick}>
              <line
                x1={x}
                y1={height / 2 - 8}
                x2={x}
                y2={height / 2 + 8}
                className="number-line-tick"
                stroke={lineColor}
                strokeWidth={2}
              />
              <text
                x={x}
                y={height / 2 + 24}
                textAnchor="middle"
                className="number-line-label"
                fill="var(--color-text, #1f2937)"
              >
                {tick}
              </text>
            </g>
          );
        })}

        {/* 自定义点标记 */}
        {points.map((point, index) => {
          const x = getPosition(point.value);
          const isHighlighted = localHighlighted.includes(index);
          const isSelected = selectedPoint === point.value;

          return (
            <g key={`point-${index}`}>
              {/* 点的标记线 */}
              <line
                x1={x}
                y1={height / 2 - 25}
                x2={x}
                y2={height / 2 - 35}
                className="number-line-point-line"
                stroke={lineColor}
                strokeWidth={2}
              />
              {/* 点的圆圈 */}
              <circle
                cx={x}
                cy={height / 2 - 40}
                r={isHighlighted ? 12 : 10}
                className={`number-line-point ${isHighlighted ? 'highlighted' : ''} ${isSelected ? 'selected' : ''}`}
                fill={isHighlighted ? lineColor : 'white'}
                stroke={lineColor}
                strokeWidth={2}
                onClick={() => handlePointClick(point, index)}
                data-testid={`${dataTestId}-point-${index}`}
                style={{ cursor: interactive ? 'pointer' : 'default' }}
              />
              {/* 点标签 */}
              <text
                x={x}
                y={height / 2 - 58}
                textAnchor="middle"
                className="number-line-point-label"
                fill={isHighlighted ? lineColor : 'var(--color-text, #1f2937)'}
                fontWeight={isHighlighted ? '600' : '400'}
              >
                {point.label || point.value}
              </text>
            </g>
          );
        })}
      </svg>

      {interactive && (selectedPoint !== null || localHighlighted.length > 0) && (
        <button
          className="number-line-clear-btn"
          onClick={handleClearSelection}
          data-testid={`${dataTestId}-${id}-clear-btn`}
        >
          清空选择
        </button>
      )}
    </div>
  );
};

export default NumberLine;
