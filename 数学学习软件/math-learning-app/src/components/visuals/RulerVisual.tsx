import React, { useMemo } from 'react';
import './RulerVisual.css';

interface RulerMark {
  /** 刻度值 */
  value: number;
  /** 是否为主刻度 */
  isMajor?: boolean;
  /** 标签（可选） */
  label?: string;
}

interface RulerVisualConfig {
  /** 刻度配置 */
  marks?: RulerMark[];
  /** 最小值 */
  minValue?: number;
  /** 最大值 */
  maxValue?: number;
  /** 刻度单位 */
  unit?: string;
  /** 刻度长度 */
  length?: number;
  /** 方向：horizontal | vertical */
  orientation?: 'horizontal' | 'vertical';
  /** 高亮区间（可选） */
  highlightedRange?: {
    start: number;
    end: number;
    color?: string;
  };
}

interface RulerVisualProps {
  /** 可视化配置 */
  config: RulerVisualConfig;
  /** 完成回调 */
  onComplete?: () => void;
  /** 是否只读模式 */
  readOnly?: boolean;
}

/**
 * 尺子可视化组件
 * 用于显示数轴或刻度尺
 */
export const RulerVisual: React.FC<RulerVisualProps> = ({
  config,
}) => {
  const {
    marks = [],
    minValue = 0,
    maxValue = 10,
    unit = '',
    length = 400,
    orientation = 'horizontal',
    highlightedRange,
  } = config;

  // 生成刻度线
  const tickMarks = useMemo(() => {
    const result = [];
    const step = maxValue / 10;

    for (let i = 0; i <= 10; i++) {
      const value = minValue + step * i;
      const isMajor = i % 2 === 0;
      const position = (i / 10) * 100;

      // 检查是否在高亮区间内
      const isInHighlight =
        highlightedRange &&
        value >= highlightedRange.start &&
        value <= highlightedRange.end;

      result.push({
        value,
        position,
        isMajor,
        isInHighlight,
        label: isMajor ? `${value}${unit}` : undefined,
      });
    }
    return result;
  }, [marks, minValue, maxValue, unit, highlightedRange]);

  const isHorizontal = orientation === 'horizontal';
  const rulerLength = isHorizontal ? length : length * 0.6;

  return (
    <div className={`ruler-visual ruler-${orientation}`}>
      <svg
        width={isHorizontal ? rulerLength : 60}
        height={isHorizontal ? 80 : rulerLength}
        viewBox={isHorizontal ? `0 0 ${rulerLength} 80` : `0 0 60 ${rulerLength}`}
      >
        {/* 尺子主体 */}
        <rect
          x="10"
          y={isHorizontal ? 30 : 10}
          width={isHorizontal ? rulerLength - 20 : 40}
          height={isHorizontal ? 40 : rulerLength - 20}
          fill="#f3f4f6"
          stroke="#6b7280"
          strokeWidth="2"
          rx="4"
        />

        {/* 刻度线和标签 */}
        {tickMarks.map((tick, index) => {
          const x = isHorizontal ? tick.position * (rulerLength - 20) / 100 + 10 : 30;
          const y = isHorizontal ? 30 : tick.position * (rulerLength - 20) / 100 + 10;
          const tickHeight = tick.isMajor ? 20 : 10;

          return (
            <g key={index}>
              {/* 高亮背景 */}
              {tick.isInHighlight && (
                <rect
                  x={isHorizontal ? tick.position * (rulerLength - 20) / 100 + 10 : 10}
                  y={isHorizontal ? 30 : tick.position * (rulerLength - 20) / 100 + 10}
                  width={isHorizontal ? rulerLength / 10 : 40}
                  height={isHorizontal ? 40 : rulerLength / 10}
                  fill={highlightedRange?.color ?? '#fbbf24'}
                  opacity={0.3}
                />
              )}

              {/* 刻度线 */}
              <line
                x1={x}
                y1={y}
                x2={isHorizontal ? x : x + (tick.isMajor ? 20 : 10)}
                y2={isHorizontal ? y + (tick.isMajor ? tickHeight : tickHeight / 2) : y}
                stroke="#374151"
                strokeWidth={tick.isMajor ? 2 : 1}
              />

              {/* 标签 */}
              {tick.label && (
                <text
                  x={x}
                  y={isHorizontal ? y - 5 : y + 15}
                  textAnchor="middle"
                  fontSize="11"
                  fill="#374151"
                >
                  {tick.label}
                </text>
              )}
            </g>
          );
        })}
      </svg>

      {/* 数值范围标签 */}
      <div className="ruler-labels">
        <span className="ruler-min-label">{minValue}{unit}</span>
        <span className="ruler-max-label">{maxValue}{unit}</span>
      </div>
    </div>
  );
};

export default RulerVisual;
