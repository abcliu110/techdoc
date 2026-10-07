import React, { useState, useCallback } from 'react';
import './RectangleGrid.css';

interface RectangleGridProps {
  /** 组件 ID */
  id: string;
  /** 行数 */
  rows: number;
  /** 列数 */
  columns: number;
  /** 高亮显示的单元格索引列表 */
  highlightedCells?: number[];
  /** 单元格被点击的回调 */
  onCellClick?: (row: number, col: number, index: number) => void;
  /** 交互完成回调 */
  onComplete?: () => void;
  /** 是否可交互 */
  interactive?: boolean;
  /** 单元格宽度 */
  cellWidth?: number;
  /** 单元格高度 */
  cellHeight?: number;
  /** 自定义颜色 */
  color?: string;
  /** data-testid 前缀 */
  'data-testid'?: string;
}

/**
 * 矩形网格可视化组件
 * @description 用于展示分数概念的矩形网格分割可视化
 */
export const RectangleGrid: React.FC<RectangleGridProps> = ({
  id,
  rows,
  columns,
  highlightedCells = [],
  onCellClick,
  onComplete,
  interactive = true,
  cellWidth = 40,
  cellHeight = 40,
  color,
  'data-testid': dataTestId = 'visual-rectangle-grid',
}) => {
  const [localHighlighted, setLocalHighlighted] = useState<number[]>(highlightedCells);
  const [isComplete, setIsComplete] = useState(false);

  const totalCells = rows * columns;
  const fillColor = color || 'var(--color-primary, #4f46e5)';

  // 计算单元格索引
  const getCellIndex = (row: number, col: number): number => row * columns + col;

  // 处理单元格点击
  const handleCellClick = useCallback((row: number, col: number) => {
    if (!interactive) return;

    const index = getCellIndex(row, col);
    const newHighlighted = localHighlighted.includes(index)
      ? localHighlighted.filter(i => i !== index)
      : [...localHighlighted, index];

    setLocalHighlighted(newHighlighted);
    onCellClick?.(row, col, index);

    // 检查是否完成（所有单元格都被高亮）
    if (newHighlighted.length === totalCells && !isComplete) {
      setIsComplete(true);
      onComplete?.();
    }
  }, [interactive, localHighlighted, totalCells, onCellClick, onComplete, isComplete]);

  // 处理"自动填充"按钮
  const handleAutoFill = useCallback(() => {
    const allIndices = Array.from({ length: totalCells }, (_, i) => i);
    setLocalHighlighted(allIndices);
    onCellClick?.(0, 0, -1); // -1 表示全选
    setIsComplete(true);
    onComplete?.();
  }, [totalCells, onCellClick, onComplete]);

  // 计算网格尺寸
  const gridWidth = columns * cellWidth;
  const gridHeight = rows * cellHeight;

  return (
    <div className="rectangle-grid-container" data-testid={`${dataTestId}-${id}`}>
      <div className="rectangle-grid-label" data-testid={`${dataTestId}-${id}-label`}>
        {localHighlighted.length}/{totalCells}
      </div>

      <div
        className="rectangle-grid"
        style={{
          width: gridWidth,
          height: gridHeight,
          gridTemplateColumns: `repeat(${columns}, ${cellWidth}px)`,
          gridTemplateRows: `repeat(${rows}, ${cellHeight}px)`,
        }}
        data-testid={`${dataTestId}-${id}-grid`}
      >
        {Array.from({ length: rows }).map((_, row) =>
          Array.from({ length: columns }).map((_, col) => {
            const index = getCellIndex(row, col);
            const isHighlighted = localHighlighted.includes(index);

            return (
              <div
                key={index}
                className={`rectangle-grid-cell ${isHighlighted ? 'highlighted' : ''}`}
                style={{
                  width: cellWidth,
                  height: cellHeight,
                  backgroundColor: isHighlighted ? fillColor : undefined,
                }}
                onClick={() => handleCellClick(row, col)}
                data-testid={`${dataTestId}-${id}-cell-${index}`}
              />
            );
          })
        )}
      </div>

      {interactive && !isComplete && (
        <button
          className="rectangle-grid-auto-btn"
          onClick={handleAutoFill}
          data-testid={`${dataTestId}-${id}-auto-btn`}
        >
          自动填充
        </button>
      )}

      {isComplete && (
        <div className="rectangle-grid-complete" data-testid={`${dataTestId}-${id}-complete`}>
          完成！
        </div>
      )}
    </div>
  );
};

export default RectangleGrid;
