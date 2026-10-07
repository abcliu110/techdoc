import React, { useState, useCallback } from 'react';
import { Button } from '../ui/Button';
import { StepHeader } from './StepHeader';
import { StepFeedback } from './StepFeedback';
import type { SymbolicContent } from '../../domain/types/learning-step';
import { EquivalenceChecker } from '../../engine/math/EquivalenceChecker';
import './SymbolicStep.css';

interface SymbolicStepProps {
  /** 步骤内容 */
  content: SymbolicContent;
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
 * 符号表示步骤组件
 * - 显示数学表达式输入
 * - 支持分数输入（分子/分母形式）
 * - 支持验证答案
 * - 支持提示系统
 */
export const SymbolicStep: React.FC<SymbolicStepProps> = ({
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
  // 分子输入状态（分数输入模式）
  const [numerator, setNumerator] = useState('');
  // 分母输入状态（分数输入模式）
  const [denominator, setDenominator] = useState('');
  // 表达式输入状态（非分数输入模式）
  const [expression, setExpression] = useState('');
  // 内部提示使用计数
  const [internalHintsUsed, setInternalHintsUsed] = useState(0);
  // 反馈状态
  const [feedback, setFeedback] = useState<{ type: 'success' | 'hint' | 'error'; message: string } | null>(null);
  // 内部完成状态
  const [internalIsComplete, setInternalIsComplete] = useState(false);

  // 使用外部或内部状态
  const hintsUsed = externalHintLevel ?? internalHintsUsed;
  const isComplete = externalIsCompleted ?? internalIsComplete;

  // 等价性检查器
  const checker = new EquivalenceChecker(content.equivalenceRules);

  // 判断是否为分数输入模式
  const isFractionMode = content.inputType === 'fraction';

  /**
   * 验证答案
   */
  const verifyAnswer = useCallback(() => {
    let userAnswer: string;
    let expectedAnswers: string[];

    if (isFractionMode) {
      // 分数模式：组装分子/分母
      if (!numerator.trim() || !denominator.trim()) {
        setFeedback({
          type: 'error',
          message: '请输入完整的分子和分母',
        });
        return;
      }
      userAnswer = `${numerator.trim()}/${denominator.trim()}`;
      expectedAnswers = Array.isArray(content.expectedAnswer)
        ? content.expectedAnswer
        : [content.expectedAnswer];
    } else {
      // 表达式或方程模式
      if (!expression.trim()) {
        setFeedback({
          type: 'error',
          message: '请输入表达式',
        });
        return;
      }
      userAnswer = expression.trim();
      expectedAnswers = Array.isArray(content.expectedAnswer)
        ? content.expectedAnswer
        : [content.expectedAnswer];
    }

    // 使用等价性检查器验证
    const isCorrect = checker.checkAnswer(userAnswer, expectedAnswers);

    if (isCorrect) {
      setInternalIsComplete(true);
      setFeedback({
        type: 'success',
        message: '回答正确！',
      });
    } else {
      setFeedback({
        type: 'error',
        message: '答案不正确，请再试一次',
      });
    }
  }, [isFractionMode, numerator, denominator, expression, content.expectedAnswer, checker]);

  /**
   * 处理完成按钮点击
   */
  const handleComplete = useCallback(() => {
    if (!isComplete) return;
    onComplete({
      completed: true,
      hintsUsed,
      userAnswer: isFractionMode
        ? `${numerator}/${denominator}`
        : expression,
    });
  }, [isComplete, hintsUsed, isFractionMode, numerator, denominator, expression, onComplete]);

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
   * 处理分数输入框的变化
   */
  const handleNumeratorChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/[^0-9-]/g, '');
    setNumerator(value);
  }, []);

  const handleDenominatorChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/[^0-9]/g, '');
    setDenominator(value);
  }, []);

  /**
   * 处理表达式输入框的变化
   */
  const handleExpressionChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setExpression(e.target.value);
  }, []);

  return (
    <div className="step symbolic-step">
      <StepHeader
        stepName={stepName}
        stepIndex={stepIndex}
        emoji="📝"
        totalSteps={totalSteps}
      />

      <div className="step-content">
        <div className="instruction-card">
          <h3>指令</h3>
          <p>{content.instruction}</p>
        </div>

        <div className="input-card">
          <span className="input-label">你的答案</span>
          {isFractionMode ? (
            <div className="fraction-input">
              <input
                type="text"
                className="fraction-numerator"
                placeholder="分子"
                value={numerator}
                onChange={handleNumeratorChange}
                disabled={isComplete}
              />
              <span className="fraction-line">—</span>
              <input
                type="text"
                className="fraction-denominator"
                placeholder="分母"
                value={denominator}
                onChange={handleDenominatorChange}
                disabled={isComplete}
              />
            </div>
          ) : (
            <input
              type="text"
              className="expression-input"
              placeholder={content.inputType === 'equation' ? '例如: x = 3/4' : '例如: 3/4 + 1/2'}
              value={expression}
              onChange={handleExpressionChange}
              disabled={isComplete}
            />
          )}
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
          <Button variant="secondary" onClick={verifyAnswer}>
            验证答案
          </Button>
        )}
        <Button
          variant="primary"
          onClick={handleComplete}
          disabled={!isComplete}
        >
          {isComplete ? '完成' : '先验证答案'}
        </Button>
      </div>
    </div>
  );
};

export default SymbolicStep;
