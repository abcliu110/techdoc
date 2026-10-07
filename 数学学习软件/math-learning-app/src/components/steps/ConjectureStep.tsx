import React, { useState, useCallback } from 'react';
import { Button } from '../ui/Button';
import { StepHeader } from './StepHeader';
import { StepFeedback } from './StepFeedback';
import type { ConjectureContent, ObservationExample } from '../../domain/types/learning-step';
import './ConjectureStep.css';

interface ConjectureStepProps {
  /** 步骤内容 */
  content: ConjectureContent;
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
 * 猜想步骤组件
 * - 显示观察示例
 * - 让学生提出猜想
 * - 记录猜想内容
 * - 支持提示引导
 */
export const ConjectureStep: React.FC<ConjectureStepProps> = ({
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
  // 猜想内容状态
  const [conjecture, setConjecture] = useState('');
  // 内部提示使用计数
  const [internalHintsUsed, setInternalHintsUsed] = useState(0);
  // 反馈状态
  const [feedback, setFeedback] = useState<{ type: 'success' | 'hint'; message: string } | null>(null);
  // 内部完成状态
  const [internalIsComplete, setInternalIsComplete] = useState(false);
  // 记录已展示的示例索引
  const [shownExamples, setShownExamples] = useState<number[]>([]);

  // 使用外部或内部状态
  const hintsUsed = externalHintLevel ?? internalHintsUsed;
  const isComplete = externalIsCompleted ?? internalIsComplete;

  /**
   * 处理猜想输入变化
   */
  const handleConjectureChange = useCallback((e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setConjecture(e.target.value);
  }, []);

  /**
   * 处理示例点击（用于交互式展示）
   */
  const handleExampleClick = useCallback((index: number) => {
    if (!shownExamples.includes(index)) {
      setShownExamples((prev) => [...prev, index]);
    }
  }, [shownExamples]);

  /**
   * 提交猜想
   */
  const handleSubmit = useCallback(() => {
    if (!conjecture.trim()) {
      setFeedback({
        type: 'hint',
        message: '请先写出你的猜想',
      });
      return;
    }

    if (conjecture.trim().length < 10) {
      setFeedback({
        type: 'hint',
        message: '猜想太短了，请再详细一些',
      });
      return;
    }

    setInternalIsComplete(true);
    setFeedback({
      type: 'success',
      message: '猜想已记录！',
    });
  }, [conjecture]);

  /**
   * 处理完成按钮点击
   */
  const handleComplete = useCallback(() => {
    if (!isComplete) return;
    onComplete({
      completed: true,
      hintsUsed,
      conjecture: conjecture.trim(),
    });
  }, [isComplete, hintsUsed, conjecture, onComplete]);

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

  return (
    <div className="step conjecture-step">
      <StepHeader
        stepName={stepName}
        stepIndex={stepIndex}
        emoji="🤔"
        totalSteps={totalSteps}
      />

      <div className="step-content">
        <div className="observation-card">
          <h3>观察示例</h3>
          <p className="observation-prompt">{content.observationPrompt}</p>
          <div className="examples-list">
            {content.examples.map((example: ObservationExample, index: number) => (
              <div
                key={index}
                className={`example-item ${shownExamples.includes(index) ? 'shown' : ''}`}
                onClick={() => handleExampleClick(index)}
              >
                <div className="example-row">
                  <span className="example-label">输入:</span>
                  <span className="example-value">{example.input}</span>
                </div>
                <div className="example-row">
                  <span className="example-label">输出:</span>
                  <span className="example-value highlight">{example.output}</span>
                </div>
                {!shownExamples.includes(index) && (
                  <div className="example-mask">
                    <span>点击查看</span>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="conjecture-card">
          <h3>提出猜想</h3>
          <p className="conjecture-prompt">{content.conjecturePrompt}</p>
          <textarea
            className="conjecture-input"
            placeholder="根据观察到的规律，写下你的猜想..."
            value={conjecture}
            onChange={handleConjectureChange}
            disabled={isComplete}
            rows={4}
          />
          <div className="conjecture-hint">
            <span className="char-count">{conjecture.length} 字</span>
          </div>
        </div>

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
        {!isComplete && (
          <Button variant="secondary" onClick={handleSubmit}>
            提交猜想
          </Button>
        )}
        <Button
          variant="primary"
          onClick={handleComplete}
          disabled={!isComplete}
        >
          {isComplete ? '完成' : '先提交猜想'}
        </Button>
      </div>
    </div>
  );
};

export default ConjectureStep;
