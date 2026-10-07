import React, { useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Button, ProgressBar } from '../components/ui';
import { AppLayout } from '../components/layout/AppLayout';
import { StepContainer } from '../components/steps';
import { useLearningSession } from '../hooks/useLearningSession';
import { useUIStore } from '../stores/uiStore';
import './Learn.css';

/**
 * 学习页面组件
 * 显示学习步骤和进度
 */
export const LearnPage: React.FC = () => {
  const { knowledgePointId } = useParams<{ knowledgePointId: string }>();
  const navigate = useNavigate();
  const {
    session,
    currentStep,
    steps,
    isLoading,
    error,
    showComplete,
    start,
    complete,
    reset,
    getProgress,
  } = useLearningSession();

  const { showToast } = useUIStore();

  useEffect(() => {
    if (knowledgePointId) {
      start(knowledgePointId);
    }
    return () => {
      reset();
    };
  }, [knowledgePointId, start, reset]);

  const handleStepComplete = useCallback(
    (data: Record<string, unknown>) => {
      complete(data);
      showToast('太棒了！继续加油！', 'success');
    },
    [complete, showToast]
  );

  const handleHint = useCallback(() => {
    showToast('使用提示不会影响你的表现哦', 'info');
  }, [showToast]);

  const handleBack = useCallback(() => {
    navigate('/');
  }, [navigate]);

  const handleRestart = useCallback(() => {
    reset();
    if (knowledgePointId) {
      start(knowledgePointId);
    }
  }, [reset, start, knowledgePointId]);

  if (isLoading) {
    return (
      <AppLayout title="加载中..." showBack onBack={handleBack}>
        <div className="learn-loading">
          <div className="loading-spinner"></div>
          <p>正在准备学习内容...</p>
        </div>
      </AppLayout>
    );
  }

  if (error) {
    return (
      <AppLayout title="出错了" showBack onBack={handleBack}>
        <div className="learn-error">
          <p>{error}</p>
          <Button variant="primary" onClick={handleBack}>
            返回首页
          </Button>
        </div>
      </AppLayout>
    );
  }

  if (showComplete || !currentStep) {
    return (
      <AppLayout title="学习完成" showBack onBack={handleBack}>
        <div className="learn-complete">
          <div className="complete-icon">🎉</div>
          <h2>恭喜完成学习！</h2>
          <p>你已经完成了本次学习内容</p>
          <div className="complete-stats">
            <div className="stat-item">
              <span className="stat-label">学习步骤</span>
              <span className="stat-value">{steps.length}</span>
            </div>
          </div>
          <div className="complete-actions">
            <Button variant="secondary" onClick={handleBack}>
              返回首页
            </Button>
            <Button variant="primary" onClick={handleRestart}>
              再学一次
            </Button>
          </div>
        </div>
      </AppLayout>
    );
  }

  const progress = getProgress();

  return (
    <AppLayout title="学习中" showBack onBack={handleBack}>
      <div className="learn-page">
        <div className="learn-progress">
          <ProgressBar value={progress} />
        </div>

        <StepContainer
          step={currentStep}
          stepIndex={session?.currentStepIndex ?? 0}
          totalSteps={steps.length}
          onComplete={handleStepComplete}
          onHint={handleHint}
        />
      </div>
    </AppLayout>
  );
};

export default LearnPage;
