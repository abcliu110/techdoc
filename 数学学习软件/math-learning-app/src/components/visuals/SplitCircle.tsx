import React, { useState, useCallback, useMemo, useEffect, useRef } from 'react';
import './SplitCircle.css';

interface CircleConfig {
  /** 分母（分割份数） */
  denominator: number;
  /** 高亮的份数索引数组 */
  highlighted: number[];
  /** 标签 */
  label?: string;
}

interface SplitCircleProps {
  /** 圆配置数组 */
  circles: CircleConfig[];
  /** 完成回调（所有要求的扇形都被高亮时触发） */
  onComplete?: () => void;
  /** 取消完成回调（从完成状态变为未完成状态时触发） */
  onUncomplete?: () => void;
  /** 状态变化回调（每次点击都会触发，传入当前是否完成） */
  onStateChange?: (isComplete: boolean) => void;
  /** 是否只读模式 */
  readOnly?: boolean;
  /** 圆的大小 */
  size?: number;
}

/**
 * 分割圆可视化组件
 * 用于显示分数的具象表示
 */
export const SplitCircle: React.FC<SplitCircleProps> = ({
  circles,
  onComplete,
  onUncomplete,
  onStateChange,
  readOnly = false,
  size = 120,
}) => {
  // 初始状态为空，不复制目标高亮状态
  // 用户需要自己点击扇形来添加高亮
  const [localHighlighted, setLocalHighlighted] = useState<CircleConfig[]>(
    circles.map((c) => ({
      denominator: c.denominator,
      highlighted: [], // 初始为空数组
      label: c.label
    }))
  );
  // 跟踪当前完成状态
  const [isCompleteState, setIsCompleteState] = useState(false);
  // 用于避免初始检查的重复触发
  const hasCheckedInitial = useRef(false);

  // 计算每个圆的目标高亮数量
  const targetHighlightCounts = useMemo(
    () => circles.map((c) => c.highlighted.length),
    [circles]
  );

  // 检查是否所有圆的高亮都与目标完全匹配
  const checkCompletion = useCallback(
    (highlighted: CircleConfig[]): boolean => {
      return circles.every((origCircle, idx) => {
        const localCircle = highlighted[idx];
        if (!localCircle || !origCircle) return false;

        // 数量必须完全相同
        if (localCircle.highlighted.length !== origCircle.highlighted.length) return false;

        // 内容必须完全一致（所有目标扇形都被高亮，且没有多余的）
        return origCircle.highlighted.every((i) => localCircle.highlighted.includes(i));
      });
    },
    [circles]
  );

  // 初始化时检查是否已经满足完成条件
  // 例如：页面加载时圆圈已显示目标高亮
  useEffect(() => {
    if (hasCheckedInitial.current) return;
    hasCheckedInitial.current = true;

    const allCirclesComplete = checkCompletion(localHighlighted);
    if (allCirclesComplete) {
      setIsCompleteState(true);
      onStateChange?.(true);
      onComplete?.();
    }
  }, [localHighlighted, checkCompletion, onComplete, onStateChange]);

  const handleSegmentClick = useCallback(
    (circleIndex: number, segmentIndex: number) => {
      if (readOnly) return;
      if (circleIndex >= localHighlighted.length) return;

      const circle = localHighlighted[circleIndex];
      if (!circle) return;

      const isHighlighted = circle.highlighted.includes(segmentIndex);

      const newHighlighted = isHighlighted
        ? circle.highlighted.filter((i) => i !== segmentIndex)
        : [...circle.highlighted, segmentIndex];

      const newCircles = [...localHighlighted];
      newCircles[circleIndex] = {
        ...circle,
        highlighted: newHighlighted.sort((a, b) => a - b),
      };
      setLocalHighlighted(newCircles);

      // 检查是否所有圆的高亮都与目标完全匹配
      const allCirclesComplete = checkCompletion(newCircles);

      // 状态变化处理
      if (allCirclesComplete && !isCompleteState) {
        // 从未完成变为完成
        setIsCompleteState(true);
        onStateChange?.(true);
        onComplete?.();
      } else if (!allCirclesComplete && isCompleteState) {
        // 从完成变为未完成
        setIsCompleteState(false);
        onStateChange?.(false);
        onUncomplete?.();
      } else {
        // 状态没变，只是通知当前状态
        onStateChange?.(allCirclesComplete);
      }
    },
    [readOnly, localHighlighted, checkCompletion, onComplete, onUncomplete, onStateChange, isCompleteState]
  );

  return (
    <div className="split-circles">
      {localHighlighted.map((config, circleIndex) => (
        <CircleItem
          key={circleIndex}
          config={config}
          circleIndex={circleIndex}
          size={size}
          readOnly={readOnly}
          targetHighlightCount={targetHighlightCounts[circleIndex]}
          onSegmentClick={handleSegmentClick}
        />
      ))}
    </div>
  );
};

/**
 * 单个圆组件
 */
interface CircleItemProps {
  config: CircleConfig;
  circleIndex: number;
  size: number;
  readOnly: boolean;
  targetHighlightCount: number;
  onSegmentClick: (circleIndex: number, segmentIndex: number) => void;
}

const CircleItem: React.FC<CircleItemProps> = ({
  config,
  circleIndex,
  size,
  readOnly,
  targetHighlightCount,
  onSegmentClick,
}) => {
  const { denominator, highlighted, label } = config;

  // 边界校验：denominator <= 0 时返回空
  if (denominator <= 0) {
    return (
      <div className="split-circle-container">
        {label && <div className="circle-label">{label}</div>}
        <div className="fraction-label">无效数据</div>
      </div>
    );
  }

  // 预计算所有扇形角度
  const segments = useMemo(() => {
    const result = [];
    const anglePerSegment = 360 / denominator;
    for (let i = 0; i < denominator; i++) {
      const startAngle = anglePerSegment * i - 90;
      result.push({
        index: i,
        startAngle,
        endAngle: startAngle + anglePerSegment,
      });
    }
    return result;
  }, [denominator]);

  return (
    <div className="split-circle-container">
      {label && <div className="circle-label">{label}</div>}
      <svg
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
        className="split-circle-svg"
      >
        {/* 背景圆 */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={size / 2 - 4}
          fill="#f3f4f6"
          stroke="#d1d5db"
          strokeWidth="2"
        />
        {/* 分割线和扇形 */}
        {segments.map((seg) => {
          const isHighlighted = highlighted.includes(seg.index);
          const path = createArcPath(
            size / 2,
            size / 2,
            size / 2 - 4,
            seg.startAngle,
            360 / denominator
          );

          // 跳过无效路径
          if (!path) return null;

          // 计算分割线终点坐标
          const lineEndX = size / 2 + (size / 2 - 4) * Math.cos((seg.startAngle * Math.PI) / 180);
          const lineEndY = size / 2 + (size / 2 - 4) * Math.sin((seg.startAngle * Math.PI) / 180);

          return (
            <g key={`segment-${seg.index}`}>
              {/* 扇形（先渲染，在下方） */}
              <path
                d={path}
                fill={isHighlighted ? "#3b82f6" : "transparent"}
                className={`segment ${!readOnly ? 'segment-interactive' : ''}`}
                onClick={() => !readOnly && onSegmentClick(circleIndex, seg.index)}
                style={{ cursor: readOnly ? 'default' : 'pointer' }}
                stroke={isHighlighted ? "#2563eb" : "transparent"}
                strokeWidth="2"
              />
              {/* 分割线（后渲染，在上方） */}
              <line
                x1={size / 2}
                y1={size / 2}
                x2={lineEndX}
                y2={lineEndY}
                stroke="#9ca3af"
                strokeWidth="1"
                pointerEvents="none"
              />
            </g>
          );
        })}
        {/* 中心点 */}
        <circle cx={size / 2} cy={size / 2} r="4" fill="#6b7280" />
      </svg>
      <div className="fraction-label">
        {highlighted.length}/{denominator}
      </div>
    </div>
  );
};

/**
 * 创建扇形路径
 * @param cx 圆心X坐标
 * @param cy 圆心Y坐标
 * @param r 半径
 * @param startAngle 起始角度（度）
 * @param sweepAngle 扫过角度（度）
 * @returns SVG路径字符串
 */
function createArcPath(
  cx: number,
  cy: number,
  r: number,
  startAngle: number,
  sweepAngle: number
): string {
  // 边界校验：sweepAngle <= 0 时返回无效路径
  if (sweepAngle <= 0) {
    return '';
  }

  const startRad = (startAngle * Math.PI) / 180;
  const endRad = ((startAngle + sweepAngle) * Math.PI) / 180;

  const x1 = cx + r * Math.cos(startRad);
  const y1 = cy + r * Math.sin(startRad);
  const x2 = cx + r * Math.cos(endRad);
  const y2 = cy + r * Math.sin(endRad);

  // largeArc 边界处理：sweepAngle >= 180 时使用大圆弧
  const largeArc = sweepAngle >= 180 ? 1 : 0;

  return [
    `M ${cx} ${cy}`,
    `L ${x1} ${y1}`,
    `A ${r} ${r} 0 ${largeArc} 1 ${x2} ${y2}`,
    'Z',
  ].join(' ');
}

export default SplitCircle;
