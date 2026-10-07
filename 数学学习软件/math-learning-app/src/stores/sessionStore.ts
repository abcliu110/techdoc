import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';
import type { LearningSession } from '../domain/types/learning-session';
import type { LearningStep } from '../domain/types/learning-step';
import { SessionStatus } from '../domain/types/learning-session';

interface SessionState {
  /** 当前会话 */
  session: LearningSession | null;
  /** 当前步骤 */
  currentStep: LearningStep | null;
  /** 步骤列表 */
  steps: LearningStep[];
  /** 加载状态 */
  isLoading: boolean;
  /** 错误信息 */
  error: string | null;
  /** 是否显示完成页 */
  showComplete: boolean;
}

interface SessionActions {
  /** 开始学习会话 */
  startSession: (session: LearningSession, steps: LearningStep[]) => void;
  /** 完成当前步骤 */
  completeStep: (data: Record<string, unknown>) => void;
  /** 请求提示 */
  requestHint: () => void;
  /** 暂停会话 */
  pauseSession: () => void;
  /** 恢复会话 */
  resumeSession: () => void;
  /** 放弃会话 */
  abandonSession: () => void;
  /** 重置状态 */
  reset: () => void;
  /** 清除错误 */
  clearError: () => void;
  /** 设置加载状态 */
  setLoading: (loading: boolean) => void;
  /** 设置错误 */
  setError: (error: string | null) => void;
}

type SessionStore = SessionState & SessionActions;

const initialState: SessionState = {
  session: null,
  currentStep: null,
  steps: [],
  isLoading: false,
  error: null,
  showComplete: false,
};

export const useSessionStore = create<SessionStore>()(
  subscribeWithSelector((set, get) => ({
    ...initialState,

    startSession: (session, steps) => {
      set({
        session,
        steps,
        currentStep: steps[0] ?? null,
        isLoading: false,
        error: null,
        showComplete: false,
      });
    },

    completeStep: (_data) => {
      const { session, steps } = get();
      if (!session) return;

      const nextIndex = session.currentStepIndex + 1;
      const isLastStep = nextIndex >= steps.length;

      if (isLastStep) {
        set({
          session: {
            ...session,
            currentStepIndex: nextIndex,
            status: SessionStatus.COMPLETED,
            completedAt: Date.now(),
          },
          currentStep: null,
          showComplete: true,
        });
      } else {
        set({
          session: {
            ...session,
            currentStepIndex: nextIndex,
          },
          currentStep: steps[nextIndex],
        });
      }
    },

    requestHint: () => {
      // 提示逻辑由步骤组件处理
    },

    pauseSession: () => {
      const { session } = get();
      if (!session) return;

      set({
        session: {
          ...session,
          status: SessionStatus.PAUSED,
          pausedAt: Date.now(),
        },
      });
    },

    resumeSession: () => {
      const { session } = get();
      if (!session) return;

      set({
        session: {
          ...session,
          status: SessionStatus.IN_PROGRESS,
          pausedAt: undefined,
        },
      });
    },

    abandonSession: () => {
      const { session } = get();
      if (!session) return;

      set({
        session: {
          ...session,
          status: SessionStatus.ABANDONED,
          abandonedAt: Date.now(),
        },
      });
    },

    reset: () => {
      set(initialState);
    },

    clearError: () => {
      set({ error: null });
    },

    setLoading: (loading) => {
      set({ isLoading: loading });
    },

    setError: (error) => {
      set({ error });
    },
  }))
);
