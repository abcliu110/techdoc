import React, { useMemo } from 'react';
import './ShapesVisual.css';

interface ShapeConfig {
  /** 形状类型 */
  type: 'circle' | 'square' | 'triangle' | 'rectangle';
  /** 数量 */
  count: number;
  /** 标签（可选） */
  label?: string;
  /** 颜色（可选） */
  color?: string;
  /** 是否高亮（可选） */
  highlighted?: boolean;
}

interface ShapesVisualConfig {
  /** 形状配置数组 */
  shapes?: ShapeConfig[];
  /** 每行数量 */
  itemsPerRow?: number;
  /** 形状大小 */
  size?: number;
}

interface ShapesVisualProps {
  /** 可视化配置 */
  config: ShapesVisualConfig;
  /** 完成回调 */
  onComplete?: () => void;
  /** 是否只读模式 */
  readOnly?: boolean;
}

/**
 * 形状可视化组件
 * 用于显示各种形状的集合
 */
export const ShapesVisual: React.FC<ShapesVisualProps> = ({
  config,
}) => {
  const shapes = config.shapes ?? [];
  const itemsPerRow = config.itemsPerRow ?? 4;
  const size = config.size ?? 40;

  // 渲染单个形状
  const renderShape = (shape: ShapeConfig, index: number) => {
    const color = shape.color ?? '#3b82f6';
    const isHighlighted = shape.highlighted ?? false;

    switch (shape.type) {
      case 'circle':
        return (
          <svg key={index} width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
            <circle
              cx={size / 2}
              cy={size / 2}
              r={size / 2 - 2}
              fill={isHighlighted ? color : `${color}40`}
              stroke={color}
              strokeWidth="2"
            />
            {shape.label && (
              <text x={size / 2} y={size / 2 + 4} textAnchor="middle" fontSize="12" fill="#374151">
                {shape.label}
              </text>
            )}
          </svg>
        );

      case 'square':
        return (
          <svg key={index} width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
            <rect
              x="2"
              y="2"
              width={size - 4}
              height={size - 4}
              fill={isHighlighted ? color : `${color}40`}
              stroke={color}
              strokeWidth="2"
            />
            {shape.label && (
              <text x={size / 2} y={size / 2 + 4} textAnchor="middle" fontSize="12" fill="#374151">
                {shape.label}
              </text>
            )}
          </svg>
        );

      case 'triangle':
        return (
          <svg key={index} width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
            <polygon
              points={`${size / 2},2 ${size - 2},${size - 2} 2,${size - 2}`}
              fill={isHighlighted ? color : `${color}40`}
              stroke={color}
              strokeWidth="2"
            />
            {shape.label && (
              <text x={size / 2} y={size / 2 + 4} textAnchor="middle" fontSize="12" fill="#374151">
                {shape.label}
              </text>
            )}
          </svg>
        );

      case 'rectangle':
        return (
          <svg key={index} width={size * 1.5} height={size} viewBox={`0 0 ${size * 1.5} ${size}`}>
            <rect
              x="2"
              y="2"
              width={size * 1.5 - 4}
              height={size - 4}
              fill={isHighlighted ? color : `${color}40`}
              stroke={color}
              strokeWidth="2"
            />
            {shape.label && (
              <text x={size * 0.75} y={size / 2 + 4} textAnchor="middle" fontSize="12" fill="#374151">
                {shape.label}
              </text>
            )}
          </svg>
        );

      default:
        return null;
    }
  };

  // 将形状平铺展开
  const flatShapes = useMemo(() => {
    const result: Array<ShapeConfig & { key: string }> = [];
    shapes.forEach((shape, shapeIndex) => {
      for (let i = 0; i < shape.count; i++) {
        result.push({
          ...shape,
          key: `shape-${shapeIndex}-${i}`,
        });
      }
    });
    return result;
  }, [shapes]);

  // 分行显示
  const rows = useMemo(() => {
    const result: Array<Array<ShapeConfig & { key: string }>> = [];
    for (let i = 0; i < flatShapes.length; i += itemsPerRow) {
      result.push(flatShapes.slice(i, i + itemsPerRow));
    }
    return result;
  }, [flatShapes, itemsPerRow]);

  return (
    <div className="shapes-visual">
      {rows.map((row, rowIndex) => (
        <div key={rowIndex} className="shapes-row">
          {row.map((shape) => renderShape(shape, 0))}
        </div>
      ))}
    </div>
  );
};

export default ShapesVisual;
