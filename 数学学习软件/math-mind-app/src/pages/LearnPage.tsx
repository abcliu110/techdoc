import React, { useEffect, useCallback, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Button, ProgressBar } from '../components/ui';
import { StepContainer, StepFeedback } from '../components/steps';
import { SplitCircle, FractionBar } from '../components/visuals';
import { useSessionStore } from '../stores';
import { Ability, LearningStep, StepType, ConcreteContent, CompletionType } from '../domain/types';
import './LearnPage.css';

/** 示例学习步骤数据 */
const SAMPLE_STEPS: LearningStep[] = [
  {
    id: 'step-concrete-1',
    type: StepType.CONCRETE,
    name: '分割操作',
    instruction: '通过分割圆形来表示分数',
    ability: Ability.NUMBER_SHAPE_INTEGRATION,
    content: {
      type: 'concrete',
      scenario: {
        title: '分蛋糕游戏',
        description: '小明和小红各有一个蛋糕，小明把蛋糕分成4份吃了3份，小红把蛋糕分成3份吃了2份。谁吃的多？',
        emoji: '🎂',
      },
      interaction: {
        kind: 'split',
        target: '在两个圆上分别表示出 3/4 和 2/3',
        visualType: 'split-circle',
        visualConfig: {
          circles: [
            { denominator: 4, highlighted: [0, 1, 2] },
            { denominator: 3, highlighted: [0, 1] },
          ],
        },
      },
    },
    completionCriteria: {
      type: CompletionType.INTERACTIVE,
      config: { type: CompletionType.INTERACTIVE, requiredInteraction: 'split-complete' },
    },
    hintLevels: [
      '提示：数一数每个圆被分成了几份？',
      '提示：数一数每个圆被涂色了几份？',
      '提示：3/4 表示分成4份取3份',
    ],
  },
  {
    id: 'step-pictorial-1',
    type: StepType.PICTORIAL,
    name: '图示表达',
    instruction: '用条形图表示分数',
    ability: Ability.NUMBER_SHAPE_INTEGRATION,
    content: {
      type: 'pictorial',
      task: '使用条形图表示 3/4 和 2/3',
      visualType: 'fraction-bar',
      visualConfig: {},
      outputFormat: 'select',
    },
    completionCriteria: {
      type: CompletionType.INTERACTIVE,
      config: { type: CompletionType.INTERACTIVE, requiredInteraction: 'bar-complete' },
    },
    hintLevels: [
      '提示：条形图的每一格代表整体的一部分',
      '提示：3/4 需要涂色3个格子',
    ],
  },
  {
    id: 'step-symbolic-1',
    type: StepType.SYMBOLIC,
    name: '符号表示',
    instruction: '用数学符号比较分数大小',
    ability: Ability.NUMBER_SHAPE_INTEGRATION,
    content: {
      type: 'symbolic',
      instruction: '比较 3/4 和 2/3 的大小，用 > 或 < 表示',
      inputType: 'expression',
      expectedAnswer: ['>', '3/4 > 2/3'],
    },
    completionCriteria: {
      type: CompletionType.INPUT,
      config: { type: CompletionType.INPUT, expectedAnswers: ['>', '3/4>2/3', '3/4 > 2/3'] },
    },
    hintLevels: [
      '提示：分母相同，分子大的分数更大',
      '提示：可以通分后比较',
    ],
  },
];

/**
 * 学习页面组件
 * @description 展示当前学习步骤，提供交互操作
 */
const LearnPage: React.FC = () => {
  const { kpId } = useParams<{ kpId: string }>();
  const navigate = useNavigate();

  const {
    session,
    currentStep,
    steps,
    showComplete,
    feedback,
    startSession,
    loadSteps,
    completeStep,
    useHint,
    setFeedback,
    reset,
  } = useSessionStore();

  const [userAnswer, setUserAnswer] = useState('');

  // 初始化会话
  useEffect(() => {
    if (kpId && !session) {
      startSession(kpId, kpId as Ability);
      loadSteps(SAMPLE_STEPS);
    }

    return () => {
      // 组件卸载时重置状态（可选）
    };
  }, [kpId, session, startSession, loadSteps]);

  // 计算进度（从0%开始，每步增加1/steps.length*100%）
  const progress = session && steps.length > 0 ? (session.currentStepIndex / steps.length) * 100 : 0;

  // 处理完成按钮
  const handleComplete = useCallback(() => {
    if (currentStep?.type === StepType.SYMBOLIC) {
      const expectedAnswers = (currentStep.completionCriteria.config as any).expectedAnswers ?? [];
      const isCorrect = expectedAnswers.some(
        (ans: string) => ans.toLowerCase().replace(/\s/g, '') === userAnswer.toLowerCase().replace(/\s/g, '')
      );

      if (isCorrect) {
        setFeedback({ type: 'success', message: '回答正确！' });
        completeStep({ answer: userAnswer, isCorrect: true });
      } else {
        setFeedback({ type: 'error', message: '回答错误，请再试一次' });
      }
    } else {
      completeStep({ completed: true });
    }
  }, [currentStep, userAnswer, setFeedback, completeStep]);

  // 处理提示按钮
  const handleHint = useCallback(() => {
    useHint();
  }, [useHint]);

  // 处理返回首页
  const handleGoHome = useCallback(() => {
    reset();
    navigate('/');
  }, [reset, navigate]);

  // 渲染步骤内容
  const renderStepContent = () => {
    if (!currentStep) {
      return <div className="loading">加载中...</div>;
    }

    switch (currentStep.type) {
      case StepType.CONCRETE: {
        const content = currentStep.content as ConcreteContent;
        return (
          <div className="step-content-visual">
            <div className="scenario-box">
              <span className="scenario-emoji">{content.scenario.emoji}</span>
              <div className="scenario-text">
                <h3>{content.scenario.title}</h3>
                <p>{content.scenario.description}</p>
              </div>
            </div>

            <div className="task-box">
              <h4>任务</h4>
              <p>{content.interaction.target}</p>
            </div>

            <div className="visual-comparison">
              <div className="visual-item">
                <span className="visual-label">蛋糕A</span>
                <SplitCircle
                  denominator={4}
                  highlighted={[0, 1, 2]}
                  data-testid="visual-split-circle-a"
                  interactive={false}
                />
              </div>
              <div className="visual-item">
                <span className="visual-label">蛋糕B</span>
                <SplitCircle
                  denominator={3}
                  highlighted={[0, 1]}
                  data-testid="visual-split-circle-b"
                  interactive={false}
                />
              </div>
            </div>
          </div>
        );
      }

      case StepType.PICTORIAL: {
        return (
          <div className="step-content-visual">
            <div className="task-box">
              <h4>任务</h4>
              <p>使用条形图表示并比较分数</p>
            </div>

            <div className="visual-comparison">
              <div className="visual-item">
                <span className="visual-label">3/4</span>
                <FractionBar
                  denominator={4}
                  highlighted={[0, 1, 2]}
                  data-testid="visual-fraction-bar-a"
                  interactive={false}
                />
              </div>
              <div className="visual-item">
                <span className="visual-label">2/3</span>
                <FractionBar
                  denominator={3}
                  highlighted={[0, 1]}
                  data-testid="visual-fraction-bar-b"
                  interactive={false}
                />
              </div>
            </div>
          </div>
        );
      }

      case StepType.SYMBOLIC: {
        return (
          <div className="step-content-input">
            <div className="task-box">
              <h4>任务</h4>
              <p>比较 3/4 和 2/3 的大小</p>
            </div>

            <div className="symbolic-input-area">
              <div className="symbolic-expression">
                <span className="fraction">3/4</span>
                <input
                  type="text"
                  className="comparison-input"
                  placeholder=">"
                  value={userAnswer}
                  onChange={(e) => setUserAnswer(e.target.value)}
                  data-testid="input-comparison"
                />
                <span className="fraction">2/3</span>
              </div>
            </div>
          </div>
        );
      }

      default:
        return <div className="unsupported-step">该步骤类型暂不支持</div>;
    }
  };

  // 渲染完成页
  if (showComplete) {
    return (
      <div className="learn-page" data-testid="page-learn-complete">
        <div className="complete-container">
          <div className="complete-celebration">
            <span className="complete-emoji">🎉</span>
            <h1>恭喜完成！</h1>
            <p>你已经完成了本次学习任务</p>
          </div>

          <div className="complete-stats">
            <div className="stat-item">
              <span className="stat-value">{steps.length}</span>
              <span className="stat-label">完成步骤</span>
            </div>
            <div className="stat-item">
              <span className="stat-value">{session?.evidence.length ?? 0}</span>
              <span className="stat-label">收集证据</span>
            </div>
          </div>

          <div data-testid="feedback-success" className="complete-feedback">
            学习完成！
          </div>

          <div className="complete-actions">
            <Button variant="primary" size="lg" onClick={handleGoHome}>
              返回首页
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="learn-page" data-testid="page-learn">
      <header className="learn-header">
        <button
          className="back-button"
          onClick={handleGoHome}
          data-testid="btn-back"
        >
          ← 返回
        </button>
        <div className="header-progress">
          <ProgressBar
            value={progress}
            data-testid="progress-bar"
            showText
          />
        </div>
        <span className="step-counter">
          {(session?.currentStepIndex ?? 0) + 1} / {steps.length}
        </span>
      </header>

      <main className="learn-content">
        {currentStep && (
          <StepContainer
            stepName={currentStep.name}
            stepIndex={session?.currentStepIndex ?? 0}
            stepType={currentStep.type}
            emoji={currentStep.type === StepType.CONCRETE ? '🎯' :
                   currentStep.type === StepType.PICTORIAL ? '🎨' :
                   currentStep.type === StepType.SYMBOLIC ? '📝' : '📚'}
            data-testid={`step-${currentStep.type}-${session?.currentStepIndex ?? 0}`}
          >
            {renderStepContent()}

            {feedback && (
              <StepFeedback
                type={feedback.type}
                message={feedback.message}
                data-testid={`feedback-${feedback.type}`}
              />
            )}

            <div className="step-actions">
              <Button
                variant="ghost"
                onClick={handleHint}
                data-testid="btn-hint"
                disabled={currentStep.hintLevels.length === 0}
              >
                💡 提示
              </Button>

              <Button
                variant="primary"
                onClick={handleComplete}
                data-testid="btn-complete"
                disabled={
                  currentStep.type === StepType.SYMBOLIC
                    ? userAnswer.trim() === ''
                    : false
                }
              >
                完成
              </Button>
            </div>
          </StepContainer>
        )}
      </main>
    </div>
  );
};

export default LearnPage;
