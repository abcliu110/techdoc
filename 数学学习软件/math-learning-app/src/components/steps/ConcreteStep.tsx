import React, { useState, useCallback } from 'react';
import { Button } from '../ui/Button';
import { SplitCircle } from '../visuals/SplitCircle';
import { ShapesVisual } from '../visuals/ShapesVisual';
import { RulerVisual } from '../visuals/RulerVisual';
import { BalanceVisual } from '../visuals/BalanceVisual';
import { ApplesVisual } from '../visuals/ApplesVisual';
import { StepHeader } from './StepHeader';
import { StepFeedback } from './StepFeedback';
import type { ConcreteContent } from '../../domain/types/learning-step';
import './ConcreteStep.css';

interface ConcreteStepProps {
  /** 步骤内容 */
  content: ConcreteContent;
  /** 步骤名称 */
  stepName: string;
  /** 步骤索引 */
  stepIndex: number;
  /** 总步骤数 */
  totalSteps?: number;
  /** 提示层级 */
  hintLevels: string[];
  /** 完成回调 */
  onComplete: (data: Record<string, unknown>) => void;
  /** 请求提示回调 */
  onHint?: () => void;
  /** 步骤完成状态 */
  isCompleted?: boolean;
  /** 当前提示级别 */
  currentHintLevel?: number;
}

/**
 * 具象操作步骤组件
 * - 接收 props 中的数据和回调
 * - 不直接调用 store 或 service
 */
export const ConcreteStep: React.FC<ConcreteStepProps> = ({
  content,
  stepName,
  stepIndex,
  totalSteps,
  hintLevels,
  onComplete,
  onHint,
  isCompleted: externalIsCompleted,
  currentHintLevel: externalHintLevel,
}) => {
  // 内部提示使用计数
  const [internalHintsUsed, setInternalHintsUsed] = useState(0);
  // 反馈状态
  const [feedback, setFeedback] = useState<{ type: 'success' | 'hint'; message: string } | null>(null);
  // 内部完成状态
  const [internalIsComplete, setInternalIsComplete] = useState(false);

  // 使用外部或内部状态
  const hintsUsed = externalHintLevel ?? internalHintsUsed;
  const isComplete = externalIsCompleted ?? internalIsComplete;

  // 处理可视化交互完成
  const handleVisualComplete = useCallback(() => {
    setInternalIsComplete(true);
    setFeedback({
      type: 'success',
      message: content.interaction.target + ' 完成！',
    });
  }, [content]);

  // 处理可视化取消完成
  const handleVisualUncomplete = useCallback(() => {
    setInternalIsComplete(false);
    setFeedback(null);
  }, []);

  // 处理可视化状态变化
  const handleVisualStateChange = useCallback(
    (complete: boolean) => {
      if (complete) {
        setInternalIsComplete(true);
        setFeedback({
          type: 'success',
          message: content.interaction.target + ' 完成！',
        });
      } else {
        setInternalIsComplete(false);
        setFeedback(null);
      }
    },
    [content]
  );

  // 处理完成按钮点击
  const handleComplete = useCallback(() => {
    if (!isComplete) return;
    onComplete({ completed: true, hintsUsed });
  }, [isComplete, hintsUsed, onComplete]);

  // 处理提示请求
  const handleHint = useCallback(() => {
    const hintIndex = hintsUsed;
    if (hintIndex < hintLevels.length && hintLevels[hintIndex]) {
      setInternalHintsUsed((prev) => prev + 1);
      setFeedback({
        type: 'hint',
        message: hintLevels[hintIndex],
      });
      onHint?.();
    }
  }, [hintsUsed, hintLevels, onHint]);

  // 从内容中提取可视化配置
  const visualConfig = (content.interaction.visualConfig ?? {}) as {
    circles?: Array<{ denominator: number; highlighted: number[] }>;
    shapes?: Array<{
      type: 'circle' | 'square' | 'triangle' | 'rectangle';
      count: number;
      label?: string;
      color?: string;
      highlighted?: boolean;
    }>;
    itemsPerRow?: number;
    size?: number;
    marks?: Array<{ value: number; isMajor?: boolean; label?: string }>;
    minValue?: number;
    maxValue?: number;
    unit?: string;
    orientation?: 'horizontal' | 'vertical';
    highlightedRange?: {
      start: number;
      end: number;
      color?: string;
      label?: string;
    };
    highlightRange?: [number, number]; // JSON中使用highlightRange，数组格式 [start, end]
    leftItems?: Array<{ id: string; weight: number; label?: string; color?: string }>;
    rightItems?: Array<{ id: string; weight: number; label?: string; color?: string }>;
    showStatus?: boolean;
    totalApples?: number;
    appleColor?: string;
    badApples?: number[];
  };

  // 根据 visualType 渲染不同的可视化
  const renderVisual = () => {
    const visualType = content.interaction.visualType;

    switch (visualType) {
      case 'split-circle':
        return (
          <SplitCircle
            circles={visualConfig.circles ?? [{ denominator: 2, highlighted: [0] }]}
            onComplete={handleVisualComplete}
            onUncomplete={handleVisualUncomplete}
            onStateChange={handleVisualStateChange}
            size={140}
          />
        );

      case 'shapes':
        return (
          <ShapesVisual
            config={{
              shapes: visualConfig.shapes ?? [],
              itemsPerRow: visualConfig.itemsPerRow ?? 4,
              size: visualConfig.size ?? 40,
            }}
          />
        );

      case 'ruler':
      case 'number-line':
        return (
          <RulerVisual
            config={{
              marks: visualConfig.marks ?? [],
              minValue: visualConfig.minValue ?? 0,
              maxValue: visualConfig.maxValue ?? 10,
              unit: visualConfig.unit ?? '',
              orientation: visualConfig.orientation ?? 'horizontal',
              highlightedRange: visualConfig.highlightedRange,
            }}
          />
        );

      case 'balance':
        return (
          <BalanceVisual
            config={{
              leftItems: visualConfig.leftItems ?? [],
              rightItems: visualConfig.rightItems ?? [],
              showStatus: visualConfig.showStatus ?? true,
            }}
          />
        );

      case 'apples':
        // highlightRange 现在只接受数组格式 [start, end]
        return (
          <ApplesVisual
            config={{
              totalApples: visualConfig.totalApples ?? 5,
              highlightRange: visualConfig.highlightRange,
              size: visualConfig.size ?? 36,
              itemsPerRow: visualConfig.itemsPerRow ?? 5,
              appleColor: visualConfig.appleColor ?? '#ef4444',
              badApples: visualConfig.badApples ?? [],
            }}
            onComplete={handleVisualComplete}
          />
        );

      default:
        // 默认使用 split-circle
        return (
          <SplitCircle
            circles={visualConfig.circles ?? [{ denominator: 2, highlighted: [0] }]}
            onComplete={handleVisualComplete}
            onUncomplete={handleVisualUncomplete}
            onStateChange={handleVisualStateChange}
            size={140}
          />
        );
    }
  };

  return (
    <div className="step concrete-step">
      <StepHeader
        stepName={stepName}
        stepIndex={stepIndex}
        emoji={content.scenario.emoji}
        totalSteps={totalSteps}
      />

      <div className="step-content">
        <div className="scenario-card">
          <h3>{content.scenario.title}</h3>
          <p>{content.scenario.description}</p>
        </div>

        <div className="task-card">
          <span className="task-label">任务</span>
          <p>{content.interaction.target}</p>
        </div>

        <div className="visual-area">
          {renderVisual()}
        </div>

        {feedback && (
          <StepFeedback type={feedback.type} message={feedback.message} />
        )}
      </div>

      <div className="step-actions">
        {hintsUsed < hintLevels.length && (
          <Button variant="ghost" onClick={handleHint}>
            提示 ({hintLevels.length - hintsUsed})
          </Button>
        )}
        <Button
          variant="primary"
          onClick={handleComplete}
          disabled={!isComplete}
        >
          {isComplete ? '完成' : '先完成任务'}
        </Button>
      </div>
    </div>
  );
};

export default ConcreteStep;
