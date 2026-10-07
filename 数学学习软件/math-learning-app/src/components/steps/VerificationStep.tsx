import React, { useState, useCallback, useMemo } from 'react';
import { Button } from '../ui/Button';
import { StepHeader } from './StepHeader';
import { StepFeedback } from './StepFeedback';
import type { VerificationContent, VerificationTestCase } from '../../domain/types/learning-step';
import './VerificationStep.css';

interface VerificationStepProps {
  /** 步骤内容 */
  content: VerificationContent;
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

/** 单个测试用例的验证状态 */
interface TestCaseState {
  userAnswer: string;
  isCorrect: boolean | null;
  isSubmitted: boolean;
}

/**
 * 验证步骤组件
 * - 验证猜想是否正确
 * - 通过测试用例检验假设
 * - 显示验证结果统计
 */
export const VerificationStep: React.FC<VerificationStepProps> = ({
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

  // 各测试用例的验证状态
  const [testCaseStates, setTestCaseStates] = useState<Record<string, TestCaseState>>(() => {
    const initial: Record<string, TestCaseState> = {};
    content.testCases.forEach((tc: VerificationTestCase, index: number) => {
      const testId = tc.id ?? `test-case-${index}`;
      initial[testId] = { userAnswer: '', isCorrect: null, isSubmitted: false };
    });
    return initial;
  });

  // 当前显示的测试用例索引
  const [currentTestIndex, setCurrentTestIndex] = useState(0);
  // 反馈状态
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error' | 'hint'; message: string } | null>(null);
  // 最终验证结论
  const [finalConclusion, setFinalConclusion] = useState<'supported' | 'refuted' | null>(null);

  // 计算验证统计
  const stats = useMemo(() => {
    const total = content.testCases.length;
    const passed = Object.values(testCaseStates).filter((s) => s.isCorrect === true).length;
    const failed = Object.values(testCaseStates).filter((s) => s.isCorrect === false).length;
    const allSubmitted = Object.values(testCaseStates).every((s) => s.isSubmitted);

    // 如果所有用例都通过，假设被支持；否则被否定
    const hypothesisSupported = passed === total && total > 0;

    return { total, passed, failed, allSubmitted, hypothesisSupported };
  }, [testCaseStates, content.testCases.length]);

  // 当前测试用例
  const currentTestCase: VerificationTestCase | undefined = content.testCases[currentTestIndex];
  const currentTestId: string = currentTestCase?.id ?? `test-case-${currentTestIndex}`;
  const currentState: TestCaseState | undefined = currentTestCase
    ? testCaseStates[currentTestId]
    : undefined;

  /**
   * 处理答案输入变化
   */
  const handleAnswerChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    if (!currentTestCase || !currentTestId) return;

    setTestCaseStates((prev) => {
      const existing = prev[currentTestId] ?? { userAnswer: '', isCorrect: null, isSubmitted: false };
      return {
        ...prev,
        [currentTestId]: {
          ...existing,
          userAnswer: e.target.value,
        },
      };
    });
  }, [currentTestCase, currentTestId]);

  /**
   * 提交当前测试用例答案
   */
  const handleSubmitTestCase = useCallback(() => {
    if (!currentTestCase || !currentState || !currentTestId) return;

    const userAnswer = currentState.userAnswer.trim();
    if (!userAnswer) {
      setFeedback({
        type: 'hint',
        message: '请输入答案',
      });
      return;
    }

    // 检查答案是否正确（支持多种正确答案格式）
    const expectedOutputs = currentTestCase.expectedOutput.split('|');
    const isCorrect = expectedOutputs.some(
      (expected) =>
        expected.trim().toLowerCase() === userAnswer.toLowerCase() ||
        expected.trim() === userAnswer
    );

    setTestCaseStates((prev) => {
      const existing = prev[currentTestId] ?? { userAnswer: '', isCorrect: null, isSubmitted: false };
      return {
        ...prev,
        [currentTestId]: {
          ...existing,
          isCorrect,
          isSubmitted: true,
        },
      };
    });

    setFeedback({
      type: isCorrect ? 'success' : 'error',
      message: isCorrect
        ? '正确！'
        : `正确答案是: ${currentTestCase.expectedOutput.split('|')[0]}`,
    });
  }, [currentTestCase, currentState]);

  /**
   * 下一题
   */
  const handleNextTest = useCallback(() => {
    if (currentTestIndex < content.testCases.length - 1) {
      setCurrentTestIndex((prev) => prev + 1);
      setFeedback(null);
    }
  }, [currentTestIndex, content.testCases.length]);

  /**
   * 完成验证
   */
  const handleComplete = useCallback(() => {
    const hypothesisSupported = stats.hypothesisSupported;

    setInternalIsComplete(true);
    setFinalConclusion(hypothesisSupported ? 'supported' : 'refuted');

    if (hypothesisSupported) {
      setFeedback({
        type: 'success',
        message: '恭喜！你的猜想被验证支持了！',
      });
    } else {
      setFeedback({
        type: 'error',
        message: '你的猜想被部分或全部测试用例否定，需要修正。',
      });
    }
  }, [stats.hypothesisSupported]);

  /**
   * 处理完成按钮点击
   */
  const handleConfirmComplete = useCallback(() => {
    if (!isComplete) return;

    onComplete({
      completed: true,
      hintsUsed,
      hypothesisSupported: stats.hypothesisSupported,
      testResults: Object.entries(testCaseStates).map(([id, state]) => ({
        testCaseId: id,
        userAnswer: state.userAnswer,
        isCorrect: state.isCorrect,
      })),
      conclusion: finalConclusion,
    });
  }, [isComplete, hintsUsed, stats.hypothesisSupported, testCaseStates, finalConclusion, onComplete]);

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
   * 重新开始
   */
  const handleRestart = useCallback(() => {
    setTestCaseStates(() => {
      const initial: Record<string, TestCaseState> = {};
      content.testCases.forEach((tc: VerificationTestCase, index: number) => {
        const testId = tc.id ?? `test-case-${index}`;
        initial[testId] = { userAnswer: '', isCorrect: null, isSubmitted: false };
      });
      return initial;
    });
    setCurrentTestIndex(0);
    setFeedback(null);
    setInternalIsComplete(false);
    setFinalConclusion(null);
  }, [content.testCases]);

  return (
    <div className="step verification-step">
      <StepHeader
        stepName={stepName}
        stepIndex={stepIndex}
        emoji="🔬"
        totalSteps={totalSteps}
      />

      <div className="step-content">
        <div className="instruction-card">
          <h3>验证猜想</h3>
          <p>{content.instruction}</p>
        </div>

        <div className="hypothesis-card">
          <h4>你的猜想</h4>
          <p className="hypothesis-text">{content.hypothesis}</p>
        </div>

        {/* 进度指示器 */}
        <div className="progress-indicator">
          <div className="progress-text">
            测试用例 {currentTestIndex + 1} / {content.testCases.length}
          </div>
          <div className="progress-bar">
            <div
              className="progress-fill"
              style={{
                width: `${((currentTestIndex + 1) / content.testCases.length) * 100}%`,
              }}
            />
          </div>
        </div>

        {/* 验证统计 */}
        <div className="stats-card">
          <div className="stat-item passed">
            <span className="stat-value">{stats.passed}</span>
            <span className="stat-label">通过</span>
          </div>
          <div className="stat-item failed">
            <span className="stat-value">{stats.failed}</span>
            <span className="stat-label">失败</span>
          </div>
          <div className="stat-item remaining">
            <span className="stat-value">
              {stats.total - stats.passed - stats.failed}
            </span>
            <span className="stat-label">待验证</span>
          </div>
        </div>

        {/* 测试用例卡片 */}
        {!isComplete && currentTestCase && (
          <div className="test-case-card">
            <div className="test-case-header">
              <span className="test-case-label">测试输入</span>
            </div>
            <div className="test-case-input">{currentTestCase.input}</div>

            <div className="test-case-question">请给出预期输出：</div>

            <div className="answer-input-area">
              <input
                type="text"
                className="answer-input"
                placeholder="输入你的答案"
                value={currentState?.userAnswer ?? ''}
                onChange={handleAnswerChange}
                disabled={currentState?.isSubmitted}
              />
            </div>

            {feedback && !currentState?.isSubmitted && (
              <StepFeedback type={feedback.type} message={feedback.message} />
            )}

            {currentState?.isSubmitted && (
              <StepFeedback
                type={currentState.isCorrect ? 'success' : 'error'}
                message={
                  currentState.isCorrect
                    ? '回答正确！'
                    : `正确答案是: ${currentTestCase.expectedOutput.split('|')[0]}`
                }
              />
            )}
          </div>
        )}

        {/* 最终结论 */}
        {isComplete && finalConclusion && (
          <div className={`conclusion-card ${finalConclusion}`}>
            <h4>
              {finalConclusion === 'supported' ? '猜想被支持' : '猜想被否定'}
            </h4>
            <p>
              {finalConclusion === 'supported'
                ? '所有测试用例都通过，你的猜想是正确的！'
                : '部分或全部测试用例未通过，请修正你的猜想。'}
            </p>
            <div className="conclusion-stats">
              <span>通过: {stats.passed}</span>
              <span>失败: {stats.failed}</span>
            </div>
          </div>
        )}
      </div>

      <div className="step-actions">
        {!isComplete ? (
          <>
            {hintsUsed < hintLevels.length && (
              <Button variant="ghost" onClick={handleHint}>
                提示 ({hintLevels.length - hintsUsed})
              </Button>
            )}
            {!currentState?.isSubmitted ? (
              <Button
                variant="secondary"
                onClick={handleSubmitTestCase}
                disabled={!currentState?.userAnswer.trim()}
              >
                提交答案
              </Button>
            ) : currentTestIndex < content.testCases.length - 1 ? (
              <Button variant="secondary" onClick={handleNextTest}>
                下一题
              </Button>
            ) : stats.allSubmitted ? (
              <Button variant="primary" onClick={handleComplete}>
                查看结论
              </Button>
            ) : (
              <Button variant="primary" disabled>
                完成验证
              </Button>
            )}
          </>
        ) : (
          <>
            {finalConclusion === 'refuted' && (
              <Button variant="secondary" onClick={handleRestart}>
                重新验证
              </Button>
            )}
            <Button variant="primary" onClick={handleConfirmComplete}>
              完成
            </Button>
          </>
        )}
      </div>
    </div>
  );
};

export default VerificationStep;
