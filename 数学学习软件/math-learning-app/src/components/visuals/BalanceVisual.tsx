import React, { useMemo } from 'react';
import './BalanceVisual.css';

interface BalanceItem {
  /** 物品标识 */
  id: string;
  /** 物品重量 */
  weight: number;
  /** 标签 */
  label?: string;
  /** 颜色（可选） */
  color?: string;
}

interface BalanceVisualConfig {
  /** 左侧物品 */
  leftItems?: BalanceItem[];
  /** 右侧物品 */
  rightItems?: BalanceItem[];
  /** 支点位置（0-1，0.5为平衡） */
  pivotPosition?: number;
  /** 是否显示天平状态提示 */
  showStatus?: boolean;
  /** 天平宽度 */
  width?: number;
  /** 天平高度 */
  height?: number;
}

interface BalanceVisualProps {
  /** 可视化配置 */
  config: BalanceVisualConfig;
  /** 完成回调 */
  onComplete?: () => void;
  /** 是否只读模式 */
  readOnly?: boolean;
}

/**
 * 天平可视化组件
 * 用于比较两边物体的重量关系
 */
export const BalanceVisual: React.FC<BalanceVisualProps> = ({
  config,
}) => {
  const {
    leftItems = [],
    rightItems = [],
    showStatus = true,
    width = 400,
    height = 200,
  } = config;

  // 计算两边总重量
  const totalLeftWeight = useMemo(
    () => leftItems.reduce((sum, item) => sum + item.weight, 0),
    [leftItems]
  );

  const totalRightWeight = useMemo(
    () => rightItems.reduce((sum, item) => sum + item.weight, 0),
    [rightItems]
  );

  // 计算倾斜角度
  const tiltAngle = useMemo(() => {
    const diff = totalLeftWeight - totalRightWeight;
    const maxTilt = 15; // 最大倾斜角度
    const maxDiff = 10; // 引起最大倾斜的重量差
    return Math.max(-maxTilt, Math.min(maxTilt, (diff / maxDiff) * maxTilt));
  }, [totalLeftWeight, totalRightWeight]);

  // 获取状态提示
  const statusText = useMemo(() => {
    if (totalLeftWeight > totalRightWeight) {
      return '左边更重';
    } else if (totalRightWeight > totalLeftWeight) {
      return '右边更重';
    }
    return '天平平衡';
  }, [totalLeftWeight, totalRightWeight]);

  return (
    <div className="balance-visual">
      {showStatus && (
        <div className={`balance-status status-${tiltAngle > 0 ? 'left' : tiltAngle < 0 ? 'right' : 'balanced'}`}>
          {statusText}
        </div>
      )}

      <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`}>
        {/* 支点 */}
        <polygon
          points={`${width / 2 - 15},${height - 20} ${width / 2 + 15},${height - 20} ${width / 2},${height - 40}`}
          fill="#6b7280"
          stroke="#4b5563"
          strokeWidth="2"
        />

        {/* 支架 */}
        <line
          x1={width / 2}
          y1={height - 40}
          x2={width / 2}
          y2={30}
          stroke="#6b7280"
          strokeWidth="4"
        />

        {/* 横杆（带倾斜） */}
        <g transform={`rotate(${tiltAngle}, ${width / 2}, ${40})`}>
          {/* 横杆本体 */}
          <line
            x1={40}
            y1={40}
            x2={width - 40}
            y2={40}
            stroke="#9ca3af"
            strokeWidth="6"
            strokeLinecap="round"
          />

          {/* 左托盘 */}
          <line x1={60} y1={40} x2={60} y2={80} stroke="#9ca3af" strokeWidth="2" />
          <rect
            x={30}
            y={80}
            width={60}
            height={8}
            fill="#d1d5db"
            stroke="#9ca3af"
            strokeWidth="1"
            rx="2"
          />

          {/* 右托盘 */}
          <line x1={width - 60} y1={40} x2={width - 60} y2={80} stroke="#9ca3af" strokeWidth="2" />
          <rect
            x={width - 90}
            y={80}
            width={60}
            height={8}
            fill="#d1d5db"
            stroke="#9ca3af"
            strokeWidth="1"
            rx="2"
          />
        </g>

        {/* 左托盘物品 */}
        <g transform={`rotate(${tiltAngle}, ${width / 2}, ${40})`}>
          {leftItems.map((item, index) => {
            const offsetX = 40 + index * 25;
            return (
              <g key={item.id || index} transform={`translate(${offsetX}, 70)`}>
                <rect
                  width={18}
                  height={18}
                  fill={item.color ?? '#3b82f6'}
                  rx="2"
                />
                <text x={9} y={13} textAnchor="middle" fontSize="10" fill="white">
                  {item.weight}
                </text>
              </g>
            );
          })}
        </g>

        {/* 右托盘物品 */}
        <g transform={`rotate(${tiltAngle}, ${width / 2}, ${40})`}>
          {rightItems.map((item, index) => {
            const offsetX = width - 80 - index * 25;
            return (
              <g key={item.id || index} transform={`translate(${offsetX}, 70)`}>
                <rect
                  width={18}
                  height={18}
                  fill={item.color ?? '#ef4444'}
                  rx="2"
                />
                <text x={9} y={13} textAnchor="middle" fontSize="10" fill="white">
                  {item.weight}
                </text>
              </g>
            );
          })}
        </g>
      </svg>

      {/* 重量显示 */}
      <div className="balance-weights">
        <div className="weight-side left">
          <span className="weight-label">左边</span>
          <span className="weight-value">{totalLeftWeight}</span>
        </div>
        <div className="weight-vs">vs</div>
        <div className="weight-side right">
          <span className="weight-label">右边</span>
          <span className="weight-value">{totalRightWeight}</span>
        </div>
      </div>
    </div>
  );
};

export default BalanceVisual;
