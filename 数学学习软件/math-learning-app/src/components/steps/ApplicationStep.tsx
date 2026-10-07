import React, { useState, useCallback, useMemo } from 'react';
import { Button } from '../ui/Button';
import { StepHeader } from './StepHeader';
import { StepFeedback } from './StepFeedback';
import type { ApplicationContent, VariantItem } from '../../domain/types/learning-step';
import './ApplicationStep.css';

interface ApplicationStepProps {
  /** 步骤内容 */
  content: ApplicationContent;
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

/** 单个题目的答题状态 */
interface QuestionState {
  selectedAnswer: string | null;
  isCorrect: boolean | null;
  isSubmitted: boolean;
}

interface ApplicationStepComponentProps extends ApplicationStepProps {
  /** 是否使用填空模式（默认选择题） */
  isFillBlank?: boolean;
}

/**
 * 迁移应用步骤组件
 * - 显示变式题目
 * - 支持选择题和填空题
 * - 计算正确率
 * - 判断是否通过
 */
export const ApplicationStep: React.FC<ApplicationStepComponentProps> = ({
  content,
  stepName,
  stepIndex,
  totalSteps,
  hintLevels,
  onComplete,
  onHint,
  isFillBlank = false,
  isCompleted: externalIsCompleted,
  currentHintLevel: externalHintLevel,
}) => {
  // 各题答题状态
  const [questionStates, setQuestionStates] = useState<Record<string, QuestionState>>(() => {
    const initial: Record<string, QuestionState> = {};
    content.variants.forEach((q: VariantItem) => {
      initial[q.id] = { selectedAnswer: null, isCorrect: null, isSubmitted: false };
    });
    return initial;
  });

  // 当前显示的题目索引
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  // 填空题输入值
  const [fillBlankAnswer, setFillBlankAnswer] = useState('');
  // 内部提示使用计数
  const [internalHintsUsed, setInternalHintsUsed] = useState(0);
  // 内部完成状态
  const [internalIsComplete, setInternalIsComplete] = useState(false);
  // 最终反馈
  const [finalFeedback, setFinalFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // 使用外部或内部状态
  const hintsUsed = externalHintLevel ?? internalHintsUsed;
  const isComplete = externalIsCompleted ?? internalIsComplete;

  // 计算正确率
  const stats = useMemo(() => {
    const total = content.variants.length;
    const correct = Object.values(questionStates).filter((s) => s.isCorrect === true).length;
    const accuracy = total > 0 ? Math.round((correct / total) * 100) : 0;
    const passed = correct >= content.minCorrect;
    return { total, correct, accuracy, passed };
  }, [questionStates, content.variants.length, content.minCorrect]);

  // 当前题目（安全获取）
  const currentQuestion: VariantItem | undefined = content.variants[currentQuestionIndex];
  const currentState: QuestionState | undefined = currentQuestion ? questionStates[currentQuestion.id] : undefined;

  /**
   * 处理选项选择
   */
  const handleOptionSelect = useCallback((option: string) => {
    if (!currentQuestion || currentState?.isSubmitted) return;

    setQuestionStates((prev) => {
      const existingState = prev[currentQuestion.id];
      if (!existingState) return prev;
      return {
        ...prev,
        [currentQuestion.id]: {
          selectedAnswer: option,
          isCorrect: existingState.isCorrect,
          isSubmitted: existingState.isSubmitted,
        },
      };
    });
  }, [currentState, currentQuestion]);

  /**
   * 处理填空答案变化
   */
  const handleFillBlankChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setFillBlankAnswer(e.target.value);
  }, []);

  /**
   * 提交当前题目答案
   */
  const handleSubmitQuestion = useCallback(() => {
    if (!currentQuestion) return;

    const answer = isFillBlank ? fillBlankAnswer.trim() : currentState?.selectedAnswer;
    if (!answer) return;

    const isCorrect = answer === currentQuestion.correctAnswer;

    setQuestionStates((prev) => ({
      ...prev,
      [currentQuestion.id]: {
        selectedAnswer: answer,
        isCorrect,
        isSubmitted: true,
      },
    }));

    setFillBlankAnswer('');
  }, [isFillBlank, fillBlankAnswer, currentState, currentQuestion]);

  /**
   * 下一题
   */
  const handleNextQuestion = useCallback(() => {
    if (currentQuestionIndex < content.variants.length - 1) {
      setCurrentQuestionIndex((prev) => prev + 1);
    }
  }, [currentQuestionIndex, content.variants.length]);

  /**
   * 完成答题
   */
  const handleComplete = useCallback(() => {
    setInternalIsComplete(true);
    if (stats.passed) {
      setFinalFeedback({
        type: 'success',
        message: `太棒了！你答对了 ${stats.correct}/${stats.total} 题，正确率 ${stats.accuracy}%，通过了测试！`,
      });
    } else {
      setFinalFeedback({
        type: 'error',
        message: `你答对了 ${stats.correct}/${stats.total} 题，正确率 ${stats.accuracy}%，需要至少答对 ${content.minCorrect} 题。`,
      });
    }
  }, [stats, content.minCorrect]);

  /**
   * 处理提示请求
   */
  const handleHint = useCallback(() => {
    const hintIndex = hintsUsed;
    if (hintIndex < hintLevels.length && hintLevels[hintIndex]) {
      setInternalHintsUsed((prev) => prev + 1);
      onHint?.();
    }
  }, [hintsUsed, hintLevels, onHint]);

  /**
   * 重新开始
   */
  const handleRestart = useCallback(() => {
    setQuestionStates(() => {
      const initial: Record<string, QuestionState> = {};
      content.variants.forEach((q: VariantItem) => {
        initial[q.id] = { selectedAnswer: null, isCorrect: null, isSubmitted: false };
      });
      return initial;
    });
    setCurrentQuestionIndex(0);
    setFillBlankAnswer('');
    setInternalIsComplete(false);
    setFinalFeedback(null);
  }, [content.variants]);

  // 渲染题目内容
  const renderQuestionContent = () => {
    if (!currentQuestion) return null;

    if (isFillBlank) {
      return (
        <div className="fill-blank-area">
          <input
            type="text"
            className="fill-blank-input"
            placeholder="输入你的答案"
            value={fillBlankAnswer}
            onChange={handleFillBlankChange}
            disabled={currentState?.isSubmitted}
          />
        </div>
      );
    }

    return (
      <div className="options-list">
        {currentQuestion.options?.map((option: string, optIndex: number) => {
          const isSelected = currentState?.selectedAnswer === option;
          const isCorrectAnswer = option === currentQuestion.correctAnswer;
          const showResult = currentState?.isSubmitted;

          let optionClass = 'option-item';
          if (showResult) {
            if (isCorrectAnswer) {
              optionClass += ' correct';
            } else if (isSelected) {
              optionClass += ' incorrect';
            }
          } else if (isSelected) {
            optionClass += ' selected';
          }

          return (
            <div
              key={optIndex}
              className={optionClass}
              onClick={() => handleOptionSelect(option)}
            >
              <span className="option-label">{String.fromCharCode(65 + optIndex)}</span>
              <span className="option-text">{option}</span>
              {showResult && isCorrectAnswer && <span className="option-icon">✓</span>}
              {showResult && isSelected && !isCorrectAnswer && <span className="option-icon">✗</span>}
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="step application-step">
      <StepHeader
        stepName={stepName}
        stepIndex={stepIndex}
        emoji="🎯"
        totalSteps={totalSteps}
      />

      <div className="step-content">
        <div className="instruction-card">
          <h3>迁移应用</h3>
          <p>{content.instruction}</p>
        </div>

        {/* 进度指示器 */}
        <div className="progress-indicator">
          <div className="progress-text">
            题目 {currentQuestionIndex + 1} / {content.variants.length}
          </div>
          <div className="progress-bar">
            <div
              className="progress-fill"
              style={{ width: `${((currentQuestionIndex + 1) / content.variants.length) * 100}%` }}
            />
          </div>
        </div>

        {/* 正确率显示 */}
        <div className="stats-card">
          <div className="stat-item">
            <span className="stat-value">{stats.correct}</span>
            <span className="stat-label">正确</span>
          </div>
          <div className="stat-item">
            <span className="stat-value">{stats.total - stats.correct}</span>
            <span className="stat-label">错误</span>
          </div>
          <div className="stat-item">
            <span className="stat-value">{stats.accuracy}%</span>
            <span className="stat-label">正确率</span>
          </div>
        </div>

        {/* 题目卡片 */}
        {!isComplete && currentQuestion && (
          <div className="question-card">
            <div className="question-text">{currentQuestion.question}</div>
            {renderQuestionContent()}

            {/* 题目的反馈 */}
            {currentState?.isSubmitted && (
              <StepFeedback
                type={currentState.isCorrect ? 'success' : 'error'}
                message={currentState.isCorrect ? '回答正确！' : `正确答案是: ${currentQuestion.correctAnswer}`}
              />
            )}
          </div>
        )}

        {/* 最终反馈 */}
        {isComplete && finalFeedback && (
          <StepFeedback type={finalFeedback.type} message={finalFeedback.message} />
        )}

        {/* 按钮区域 */}
        {!isComplete && (
          <div className="question-actions">
            {!currentState?.isSubmitted ? (
              <Button
                variant="primary"
                onClick={handleSubmitQuestion}
                disabled={isFillBlank ? !fillBlankAnswer.trim() : !currentState?.selectedAnswer}
              >
                提交答案
              </Button>
            ) : currentQuestionIndex < content.variants.length - 1 ? (
              <Button variant="primary" onClick={handleNextQuestion}>
                下一题
              </Button>
            ) : (
              <Button variant="primary" onClick={handleComplete}>
                查看结果
              </Button>
            )}
          </div>
        )}

        {isComplete && (
          <div className="complete-actions">
            {hintsUsed < hintLevels.length && (
              <Button variant="ghost" onClick={handleHint}>
                提示 ({hintLevels.length - hintsUsed})
              </Button>
            )}
            {!stats.passed && (
              <Button variant="secondary" onClick={handleRestart}>
                重新开始
              </Button>
            )}
            <Button
              variant="primary"
              onClick={() => onComplete({
                completed: true,
                hintsUsed,
                correct: stats.correct,
                total: stats.total,
                accuracy: stats.accuracy,
                passed: stats.passed,
              })}
              disabled={!stats.passed}
            >
              {stats.passed ? '完成' : '需要更高正确率'}
            </Button>
          </div>
        )}
      </div>
    </div>
  );
};

export default ApplicationStep;
