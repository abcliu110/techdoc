import React, { useState, useCallback } from 'react';
import './ApplesVisual.css';

interface ApplesVisualConfig {
  /** 总苹果数 */
  totalApples?: number;
  /** 高亮区间（支持数组 [start, end] 或对象 {start, end}） */
  highlightRange?: [number, number] | { start: number; end: number; label?: string };
  /** 苹果大小 */
  size?: number;
  /** 每行数量 */
  itemsPerRow?: number;
  /** 苹果颜色 */
  appleColor?: string;
  /** 坏苹果标记（可选） */
  badApples?: number[];
}

interface ApplesVisualProps {
  /** 可视化配置 */
  config: ApplesVisualConfig;
  /** 完成回调 */
  onComplete?: () => void;
  /** 是否只读模式 */
  readOnly?: boolean;
  /** 点击苹果的回调（用于交互模式） */
  onAppleClick?: (index: number) => void;
}

/**
 * 苹果可视化组件
 * 用于展示分苹果的场景，帮助理解整体与部分的关系
 */
export const ApplesVisual: React.FC<ApplesVisualProps> = ({
  config,
  onComplete,
  readOnly = false,
  onAppleClick,
}) => {
  const {
    totalApples = 5,
    highlightRange,
    size = 36,
    itemsPerRow = 5,
    appleColor = '#ef4444',
    badApples = [],
  } = config;

  // 处理高亮范围格式：支持数组 [start, end] 或对象 {start, end, label}
  const resolvedRange = highlightRange
    ? (Array.isArray(highlightRange)
        ? { start: highlightRange[0], end: highlightRange[1] }
        : highlightRange)
    : undefined;

  // 高亮范围的起始和结束索引
  const highlightStart = resolvedRange?.start;
  const highlightEnd = resolvedRange?.end;

  // 选中的苹果索引
  const [selectedApples, setSelectedApples] = useState<number[]>([]);

  // 处理苹果点击
  const handleAppleClick = useCallback((index: number) => {
    if (readOnly) return;

    setSelectedApples((prev) => {
      const isSelected = prev.includes(index);
      const newSelected = isSelected
        ? prev.filter((i) => i !== index)
        : [...prev, index];

      // 如果有完成条件，检查是否完成
      if (highlightStart !== undefined && highlightEnd !== undefined && newSelected.length >= highlightEnd - highlightStart) {
        onComplete?.();
      }

      // 回调外部
      onAppleClick?.(index);

      return newSelected;
    });
  }, [readOnly, highlightStart, highlightEnd, onComplete, onAppleClick]);

  // 判断苹果是否在高亮区间内
  const isHighlighted = (index: number): boolean => {
    if (highlightStart === undefined || highlightEnd === undefined) return false;
    return index >= highlightStart && index < highlightEnd;
  };

  // 判断苹果是否是坏的
  const isBadApple = (index: number): boolean => {
    return badApples.includes(index);
  };

  // 生成苹果数组
  const apples = Array.from({ length: totalApples }, (_, i) => i);

  // 分行显示
  const rows: number[][] = [];
  for (let i = 0; i < apples.length; i += itemsPerRow) {
    rows.push(apples.slice(i, i + itemsPerRow));
  }

  return (
    <div className="apples-visual">
      {/* 图例 */}
      <div className="apples-legend">
        <div className="legend-item">
          <span className="legend-apple normal" />
          <span>好苹果</span>
        </div>
        {badApples.length > 0 && (
          <div className="legend-item">
            <span className="legend-apple bad" />
            <span>坏苹果</span>
          </div>
        )}
        {resolvedRange && (
          <div className="legend-item">
            <span className="legend-apple highlighted" />
            <span>{resolvedRange.label ?? '选中的'}</span>
          </div>
        )}
      </div>

      {/* 苹果显示区域 */}
      <div className="apples-container">
        {rows.map((row, rowIndex) => (
          <div key={rowIndex} className="apples-row">
            {row.map((appleIndex) => {
              const highlighted = isHighlighted(appleIndex);
              const isBad = isBadApple(appleIndex);
              const isSelected = selectedApples.includes(appleIndex);

              return (
                <div
                  key={appleIndex}
                  className={`apple-item ${highlighted ? 'highlighted' : ''} ${isBad ? 'bad' : ''} ${isSelected ? 'selected' : ''}`}
                  onClick={() => handleAppleClick(appleIndex)}
                  style={{ '--apple-color': appleColor } as React.CSSProperties}
                >
                  <svg
                    width={size}
                    height={size}
                    viewBox={`0 0 ${size} ${size}`}
                    className="apple-svg"
                  >
                    {/* 苹果主体 */}
                    <ellipse
                      cx={size / 2}
                      cy={size / 2 + 2}
                      rx={size / 2 - 4}
                      ry={size / 2 - 2}
                      fill={isBad ? '#9ca3af' : appleColor}
                      className="apple-body"
                    />
                    {/* 苹果顶部凹陷 */}
                    <ellipse
                      cx={size / 2}
                      cy={size / 2 - 4}
                      rx={size / 4}
                      ry={size / 6}
                      fill={isBad ? '#d1d5db' : '#fca5a5'}
                      className="apple-top"
                    />
                    {/* 苹果柄 */}
                    <line
                      x1={size / 2}
                      y1={size / 2 - 6}
                      x2={size / 2 + 3}
                      y2={size / 2 - 12}
                      stroke="#8b5a2b"
                      strokeWidth="2"
                      strokeLinecap="round"
                    />
                    {/* 叶子 */}
                    <ellipse
                      cx={size / 2 + 5}
                      cy={size / 2 - 10}
                      rx="6"
                      ry="3"
                      fill="#22c55e"
                      transform={`rotate(-30, ${size / 2 + 5}, ${size / 2 - 10})`}
                    />
                  </svg>
                  <span className="apple-index">{appleIndex + 1}</span>
                </div>
              );
            })}
          </div>
        ))}
      </div>

      {/* 统计信息 */}
      <div className="apples-stats">
        <div className="stat-item">
          <span className="stat-value">{totalApples}</span>
          <span className="stat-label">总数</span>
        </div>
        {resolvedRange && (
          <>
            <div className="stat-item">
              <span className="stat-value">
                {resolvedRange.end - resolvedRange.start}
              </span>
              <span className="stat-label">{resolvedRange.label ?? '选中的'}</span>
            </div>
            <div className="stat-item">
              <span className="stat-value">
                {totalApples - (resolvedRange.end - resolvedRange.start)}
              </span>
              <span className="stat-label">剩余</span>
            </div>
          </>
        )}
        {badApples.length > 0 && (
          <div className="stat-item bad">
            <span className="stat-value">{badApples.length}</span>
            <span className="stat-label">坏的</span>
          </div>
        )}
      </div>
    </div>
  );
};

export default ApplesVisual;
