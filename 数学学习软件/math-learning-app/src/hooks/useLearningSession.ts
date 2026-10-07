import { useCallback } from 'react';
import { useSessionStore } from '../stores/sessionStore';
import { createWebPlatform } from '../platform';
import { StartLearningSession } from '../application/use-cases/StartLearningSession';

const platform = createWebPlatform();
const startLearningSession = new StartLearningSession(
  platform.sessionRepo,
  platform.contentRepo
);

/**
 * 学习会话 Hook
 */
export function useLearningSession() {
  const {
    session,
    currentStep,
    steps,
    isLoading,
    error,
    showComplete,
    startSession,
    completeStep,
    requestHint,
    pauseSession,
    resumeSession,
    abandonSession,
    reset,
    setLoading,
    setError,
  } = useSessionStore();

  /**
   * 开始学习
   */
  const start = useCallback(async (knowledgePointId: string) => {
    setLoading(true);
    setError(null);
    try {
      const newSession = await startLearningSession.execute('default-user', knowledgePointId);
      const stepList = await platform.contentRepo.findSteps(knowledgePointId);
      startSession(newSession, stepList);
    } catch (err) {
      setError(err instanceof Error ? err.message : '启动学习失败');
    } finally {
      setLoading(false);
    }
  }, [startSession, startLearningSession, platform.contentRepo, setLoading, setError]);

  /**
   * 完成当前步骤
   */
  const complete = useCallback(async (data: Record<string, unknown> = {}) => {
    completeStep(data);
    // 持久化到 IndexedDB
    if (session?.id) {
      await platform.sessionRepo.updateSessionProgress(
        session.id,
        session.currentStepIndex + 1
      );
    }
  }, [completeStep, session, platform.sessionRepo]);

  /**
   * 暂停学习会话
   */
  const pause = useCallback(async () => {
    if (!session) return;
    pauseSession();
    // 持久化暂停状态到 IndexedDB
    if (platform.sessionRepo.updateSessionProgress) {
      await platform.sessionRepo.updateSessionProgress(
        session.id,
        session.currentStepIndex
      );
    }
  }, [pauseSession, session, platform.sessionRepo]);

  /**
   * 获取进度百分比
   */
  const getProgress = useCallback(() => {
    if (!session || steps.length === 0) return 0;
    // 完成 N 个步骤时，进度为 N/steps.length * 100%
    // currentStepIndex 是下一个要完成的步骤索引，所以 +1
    return Math.round(((session.currentStepIndex + 1) / steps.length) * 100);
  }, [session, steps]);

  return {
    session,
    currentStep,
    steps,
    isLoading,
    error,
    showComplete,
    start,
    complete,
    requestHint,
    pauseSession: pause,
    resumeSession,
    abandonSession,
    reset,
    getProgress,
  };
}
