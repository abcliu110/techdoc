import React, { useState, useCallback } from 'react';
import { Button } from '../ui/Button';
import { StepHeader } from './StepHeader';
import { StepFeedback } from './StepFeedback';
import { ShapesVisual } from '../visuals/ShapesVisual';
import { RulerVisual } from '../visuals/RulerVisual';
import { ApplesVisual } from '../visuals/ApplesVisual';
import type { PictorialContent } from '../../domain/types/learning-step';
import './PictorialStep.css';

interface PictorialStepProps {
  /** 步骤内容 */
  content: PictorialContent;
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
 * 图示表达步骤组件
 * - 使用图形表达数学关系
 * - 支持绘制、选择、排列三种输出格式
 * - 支持提示系统
 */
export const PictorialStep: React.FC<PictorialStepProps> = ({
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
  // 内部状态（如果外部未传入则使用内部状态）
  const [internalHintsUsed, setInternalHintsUsed] = useState(0);
  const [internalIsComplete, setInternalIsComplete] = useState(false);

  // 使用外部或内部状态
  const hintsUsed = externalHintLevel ?? internalHintsUsed;
  const isComplete = externalIsCompleted ?? internalIsComplete;

  // 反馈状态
  const [feedback, setFeedback] = useState<{ type: 'success' | 'hint' | 'error'; message: string } | null>(null);
  // 绘制内容（用于绘制模式）
  const [drawContent, setDrawContent] = useState<string[]>([]);
  // 选择内容（用于选择模式）
  const [selectedItems, setSelectedItems] = useState<string[]>([]);
  // 排列内容（用于排列模式）
  const [arrangedItems, setArrangedItems] = useState<string[]>([]);

  /**
   * 处理绘制项添加
   */
  const handleAddDrawItem = useCallback((item: string) => {
    setDrawContent((prev) => [...prev, item]);
    setInternalIsComplete(true);
    setFeedback({
      type: 'success',
      message: '绘制完成！',
    });
  }, []);

  /**
   * 处理绘制项移除
   */
  const handleRemoveDrawItem = useCallback((index: number) => {
    setDrawContent((prev) => prev.filter((_, i) => i !== index));
    if (drawContent.length <= 1) {
      setInternalIsComplete(false);
    }
  }, [drawContent.length]);

  /**
   * 处理选择项切换
   */
  const handleToggleSelect = useCallback((item: string) => {
    setSelectedItems((prev) => {
      if (prev.includes(item)) {
        return prev.filter((i) => i !== item);
      } else {
        const newSelected = [...prev, item];
        // 选择完成条件：选择了至少一个项目
        setInternalIsComplete(true);
        return newSelected;
      }
    });
  }, []);

  /**
   * 处理排列项移动
   */
  const handleMoveArrangedItem = useCallback((fromIndex: number, direction: 'left' | 'right') => {
    setArrangedItems((prev) => {
      const newItems = [...prev];
      const toIndex = direction === 'left' ? fromIndex - 1 : fromIndex + 1;
      if (toIndex >= 0 && toIndex < newItems.length) {
        const fromItem = newItems[fromIndex]!;
        const toItem = newItems[toIndex]!;
        newItems[fromIndex] = toItem;
        newItems[toIndex] = fromItem;
      }
      return newItems;
    });
  }, []);

  /**
   * 确认排列完成
   */
  const handleConfirmArrange = useCallback(() => {
    if (arrangedItems.length > 0) {
      setInternalIsComplete(true);
      setFeedback({
        type: 'success',
        message: '排列完成！',
      });
    }
  }, [arrangedItems.length]);

  /**
   * 处理完成按钮点击
   */
  const handleComplete = useCallback(() => {
    if (!isComplete) return;

    let outputData: Record<string, unknown> = {
      completed: true,
      hintsUsed,
    };

    switch (content.outputFormat) {
      case 'draw':
        outputData.drawContent = drawContent;
        break;
      case 'select':
        outputData.selectedItems = selectedItems;
        break;
      case 'arrange':
        outputData.arrangedItems = arrangedItems;
        break;
    }

    onComplete(outputData);
  }, [isComplete, hintsUsed, content.outputFormat, drawContent, selectedItems, arrangedItems, onComplete]);

  /**
   * 处理提示请求
   */
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

  /**
   * 渲染可视化区域
   */
  const renderVisualArea = () => {
    const visualConfig = (content.visualConfig ?? {}) as {
      availableItems?: string[];
      itemCount?: number;
      fractions?: Array<{
        id: string;
        numerator: number;
        denominator: number;
        label?: string;
        color?: string;
      }>;
      showUnit?: boolean;
      alignment?: 'bottom' | 'top' | 'center';
      shapes?: Array<{
        type: 'circle' | 'square' | 'triangle' | 'rectangle';
        count: number;
        label?: string;
        color?: string;
        highlighted?: boolean;
      }>;
      itemsPerRow?: number;
      size?: number;
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
      highlightRange?: [number, number]; // 数组格式 [start, end]
      totalApples?: number;
      appleColor?: string;
      badApples?: number[];
    };

    // 根据 visualType 渲染不同的可视化
    switch (content.visualType) {
      case 'fraction-bar':
        // 渲染分数条形图 - 可点击选择
        return (
          <div className="fraction-bar-area">
            <p className="visual-instruction">观察分数条的长度比较，点击选择更大的分数</p>
            <div className="fraction-bar-container">
              {visualConfig.fractions?.map((fraction) => {
                const fractionId = fraction.id || `${fraction.numerator}-${fraction.denominator}`;
                const isSelected = selectedItems.includes(fractionId);
                return (
                  <div
                    key={fractionId}
                    className={`fraction-bar-item ${isSelected ? 'selected' : ''}`}
                    onClick={() => {
                      if (isSelected) {
                        setSelectedItems([]);
                        setInternalIsComplete(false);
                      } else {
                        setSelectedItems([fractionId]);
                        setInternalIsComplete(true);
                      }
                    }}
                    style={{
                      '--fraction-ratio': fraction.numerator / fraction.denominator,
                      '--fraction-color': fraction.color ?? '#3b82f6',
                    } as React.CSSProperties}
                  >
                    <div className="fraction-bar-track">
                      <div className="fraction-bar-fill" />
                    </div>
                    <span className="fraction-bar-label">
                      {fraction.label ?? `${fraction.numerator}/${fraction.denominator}`}
                    </span>
                    {isSelected && <span className="selected-marker">✓</span>}
                  </div>
                );
              })}
            </div>
          </div>
        );

      case 'number-line':
        // 渲染数轴
        return (
          <div className="number-line-area">
            <p className="visual-instruction">观察数轴上的刻度</p>
            <RulerVisual
              config={{
                marks: [],
                minValue: visualConfig.minValue ?? 0,
                maxValue: visualConfig.maxValue ?? 1,
                unit: visualConfig.unit ?? '',
                orientation: visualConfig.orientation ?? 'horizontal',
                highlightedRange: visualConfig.highlightedRange,
              }}
            />
          </div>
        );

      case 'shapes':
        // 渲染形状
        return (
          <div className="shapes-area">
            <p className="visual-instruction">观察形状的数量</p>
            <ShapesVisual
              config={{
                shapes: visualConfig.shapes ?? [],
                itemsPerRow: visualConfig.itemsPerRow ?? 4,
                size: visualConfig.size ?? 40,
              }}
            />
          </div>
        );

      case 'apples':
        // 渲染苹果，highlightRange 只接受数组格式 [start, end]
        return (
          <div className="apples-area">
            <p className="visual-instruction">观察苹果的分法</p>
            <ApplesVisual
              config={{
                totalApples: visualConfig.totalApples ?? 5,
                highlightRange: visualConfig.highlightRange, // 使用统一的 highlightRange
                size: visualConfig.size ?? 36,
                itemsPerRow: visualConfig.itemsPerRow ?? 5,
                appleColor: visualConfig.appleColor ?? '#ef4444',
                badApples: visualConfig.badApples ?? [],
              }}
            />
          </div>
        );

      case 'fraction-circle':
      case 'area-model':
        // 使用默认的 draw/select/arrange 渲染逻辑
        return renderDefaultOutputFormat(visualConfig);

      default:
        // 其他 visualType 或默认情况，渲染 draw/select/arrange
        return renderDefaultOutputFormat(visualConfig);
    }
  };

  /**
   * 渲染默认的输出格式（draw/select/arrange）
   */
  const renderDefaultOutputFormat = (visualConfig: {
    availableItems?: string[];
  }) => {
    switch (content.outputFormat) {
      case 'draw':
        return (
          <div className="draw-area">
            <p className="draw-instruction">点击下方选项添加到画布</p>
            <div className="draw-palette">
              {visualConfig.availableItems?.map((item, index) => (
                <button
                  key={index}
                  className="draw-item-button"
                  onClick={() => handleAddDrawItem(item)}
                  disabled={isComplete}
                >
                  {item}
                </button>
              ))}
            </div>
            <div className="draw-canvas">
              {drawContent.length === 0 ? (
                <p className="canvas-placeholder">画布为空，请选择元素添加</p>
              ) : (
                drawContent.map((item, index) => (
                  <div key={index} className="draw-item">
                    <span>{item}</span>
                    {!isComplete && (
                      <button
                        className="remove-button"
                        onClick={() => handleRemoveDrawItem(index)}
                      >
                        x
                      </button>
                    )}
                  </div>
                ))
              )}
            </div>
          </div>
        );

      case 'select':
        return (
          <div className="select-area">
            <p className="select-instruction">选择符合要求的图形</p>
            <div className="select-options">
              {visualConfig.availableItems?.map((item, index) => {
                const isSelected = selectedItems.includes(item);
                return (
                  <div
                    key={index}
                    className={`select-option ${isSelected ? 'selected' : ''}`}
                    onClick={() => handleToggleSelect(item)}
                  >
                    <span className="option-marker">{isSelected ? '✓' : ''}</span>
                    <span className="option-content">{item}</span>
                  </div>
                );
              })}
            </div>
          </div>
        );

      case 'arrange':
        // 初始化排列项
        if (arrangedItems.length === 0 && visualConfig.availableItems) {
          setArrangedItems([...visualConfig.availableItems]);
        }
        return (
          <div className="arrange-area">
            <p className="arrange-instruction">拖动或点击箭头调整顺序</p>
            <div className="arrange-sequence">
              {arrangedItems.map((item, index) => (
                <div key={index} className="arrange-item">
                  <button
                    className="move-button left"
                    onClick={() => handleMoveArrangedItem(index, 'left')}
                    disabled={index === 0 || isComplete}
                  >
                    &lt;
                  </button>
                  <span className="arrange-item-content">{item}</span>
                  <button
                    className="move-button right"
                    onClick={() => handleMoveArrangedItem(index, 'right')}
                    disabled={index === arrangedItems.length - 1 || isComplete}
                  >
                    &gt;
                  </button>
                </div>
              ))}
            </div>
            {!isComplete && arrangedItems.length > 0 && (
              <Button variant="secondary" onClick={handleConfirmArrange}>
                确认排列
              </Button>
            )}
          </div>
        );

      default:
        return <p>不支持的输出格式</p>;
    }
  };

  return (
    <div className="step pictorial-step">
      <StepHeader
        stepName={stepName}
        stepIndex={stepIndex}
        emoji="🎨"
        totalSteps={totalSteps}
      />

      <div className="step-content">
        <div className="task-card">
          <h3>图示任务</h3>
          <p>{content.task}</p>
        </div>

        {renderVisualArea()}

        {feedback && (
          <StepFeedback type={feedback.type} message={feedback.message} />
        )}
      </div>

      <div className="step-actions">
        {hintsUsed < hintLevels.length && !isComplete && (
          <Button variant="ghost" onClick={handleHint}>
            提示 ({hintLevels.length - hintsUsed})
          </Button>
        )}
        <Button
          variant="primary"
          onClick={handleComplete}
          disabled={!isComplete}
        >
          {isComplete ? '完成' : '请先完成任务'}
        </Button>
      </div>
    </div>
  );
};

export default PictorialStep;
