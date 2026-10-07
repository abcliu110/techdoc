import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';
import type {
  LearningSession,
  LearningStep,
  LearningEvidence,
  Ability,
} from '../domain/types';
import { SessionStatus, EvidenceType } from '../domain/types';

/**
 * 会话Store状态接口
 */
interface SessionState {
  /** 当前会话 */
  session: LearningSession | null;
  /** 当前步骤 */
  currentStep: LearningStep | null;
  /** 步骤列表 */
  steps: LearningStep[];
  /** 高亮片段索引列表 */
  highlightedSegments: number[];
  /** 加载状态 */
  isLoading: boolean;
  /** 错误信息 */
  error: string | null;
  /** 是否显示完成页 */
  showComplete: boolean;
  /** 提示层级索引 */
  hintLevelIndex: number;
  /** 反馈消息 */
  feedback: { type: 'success' | 'error' | 'hint' | 'info'; message: string } | null;
}

/**
 * 会话Store动作接口
 */
interface SessionActions {
  /** 开始会话 */
  startSession: (kpId: string, ability: Ability) => void;
  /** 加载步骤 */
  loadSteps: (steps: LearningStep[]) => void;
  /** 完成当前步骤 */
  completeStep: (data?: Record<string, unknown>) => void;
  /** 高亮片段 */
  highlightSegment: (index: number) => void;
  /** 取消高亮片段 */
  unhighlightSegment: (index: number) => void;
  /** 重置高亮 */
  resetHighlights: () => void;
  /** 请求提示 */
  useHint: () => string | null;
  /** 设置反馈 */
  setFeedback: (feedback: { type: 'success' | 'error' | 'hint' | 'info'; message: string } | null) => void;
  /** 暂停会话 */
  pauseSession: () => void;
  /** 恢复会话 */
  resumeSession: () => void;
  /** 放弃会话 */
  abandonSession: () => void;
  /** 重置状态 */
  reset: () => void;
}

/** 会话Store完整类型 */
type SessionStore = SessionState & SessionActions;

/** 初始状态 */
const initialState: SessionState = {
  session: null,
  currentStep: null,
  steps: [],
  highlightedSegments: [],
  isLoading: false,
  error: null,
  showComplete: false,
  hintLevelIndex: 0,
  feedback: null,
};

/**
 * 生成唯一ID
 */
function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
}

/**
 * 学习会话Store
 * @description 管理学习会话的状态，包括会话生命周期、步骤进度、证据收集等
 */
export const useSessionStore = create<SessionStore>()(
  subscribeWithSelector((set, get) => ({
    ...initialState,

    startSession: (kpId: string, ability: Ability) => {
      const now = Date.now();
      const session: LearningSession = {
        id: generateId(),
        knowledgePointId: kpId,
        ability,
        status: SessionStatus.IN_PROGRESS,
        currentStepIndex: 0,
        startedAt: now,
        evidence: [],
      };

      set({
        session,
        isLoading: false,
        error: null,
        showComplete: false,
        hintLevelIndex: 0,
        highlightedSegments: [],
        feedback: null,
      });
    },

    loadSteps: (steps: LearningStep[]) => {
      const { session } = get();
      const currentStep = steps[session?.currentStepIndex ?? 0] ?? null;

      set({
        steps,
        currentStep,
      });
    },

    completeStep: (data) => {
      const { session, steps, currentStep } = get();
      if (!session) return;

      const nextIndex = session.currentStepIndex + 1;
      const isLastStep = nextIndex >= steps.length;

      // 创建证据
      const evidence: LearningEvidence = {
        id: generateId(),
        stepId: currentStep?.id ?? 'unknown',
        type: EvidenceType.REPRESENTATION,
        data: {
          type: EvidenceType.REPRESENTATION,
          interactionKind: 'tap',
          result: data ?? {},
          attempts: 1,
        },
        timestamp: Date.now(),
      };

      if (isLastStep) {
        set({
          session: {
            ...session,
            currentStepIndex: nextIndex,
            status: SessionStatus.COMPLETED,
            completedAt: Date.now(),
            evidence: [...session.evidence, evidence],
          },
          showComplete: true,
          feedback: {
            type: 'success',
            message: '恭喜你完成了本次学习！',
          },
        });
      } else {
        set({
          session: {
            ...session,
            currentStepIndex: nextIndex,
            evidence: [...session.evidence, evidence],
          },
          currentStep: steps[nextIndex],
          hintLevelIndex: 0,
          highlightedSegments: [],
          feedback: null,
        });
      }
    },

    highlightSegment: (index: number) => {
      const { highlightedSegments } = get();
      if (!highlightedSegments.includes(index)) {
        set({
          highlightedSegments: [...highlightedSegments, index],
        });
      }
    },

    unhighlightSegment: (index: number) => {
      const { highlightedSegments } = get();
      set({
        highlightedSegments: highlightedSegments.filter(i => i !== index),
      });
    },

    resetHighlights: () => {
      set({ highlightedSegments: [] });
    },

    useHint: () => {
      const { currentStep, hintLevelIndex } = get();
      if (!currentStep) return null;

      const hints = currentStep.hintLevels;
      if (hintLevelIndex >= hints.length) {
        set({
          feedback: {
            type: 'info',
            message: '没有更多提示了',
          },
        });
        return null;
      }

      const hint = hints[hintLevelIndex];
      set({
        hintLevelIndex: hintLevelIndex + 1,
        feedback: {
          type: 'hint',
          message: hint,
        },
      });

      return hint;
    },

    setFeedback: (feedback) => {
      set({ feedback });
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
          completedAt: Date.now(),
        },
        showComplete: false,
      });
    },

    reset: () => {
      set(initialState);
    },
  }))
);

export default useSessionStore;
