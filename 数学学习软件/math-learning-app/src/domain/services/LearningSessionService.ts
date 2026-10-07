import {
  LearningSession,
  SessionStatus,
  LearningEvidence,
  SessionSnapshot,
} from '../types/learning-session';
import { Ability } from '../types/ability';
import { DomainError } from '../errors';

/**
 * 学习会话领域服务
 * 负责学习会话的生命周期管理和状态转换
 */
export class LearningSessionService {
  /**
   * 创建新的学习会话
   */
  createSession(
    id: string,
    knowledgePointId: string,
    ability: Ability
  ): LearningSession {
    return {
      id,
      knowledgePointId,
      ability,
      status: SessionStatus.NOT_STARTED,
      currentStepIndex: 0,
      startedAt: Date.now(),
      evidence: [],
    };
  }

  /**
   * 开始会话
   */
  start(session: LearningSession): LearningSession {
    if (session.status !== SessionStatus.NOT_STARTED) {
      throw new DomainError('会话已启动或已完成');
    }
    return {
      ...session,
      status: SessionStatus.IN_PROGRESS,
      startedAt: Date.now(),
    };
  }

  /**
   * 暂停会话
   */
  pause(session: LearningSession, snapshot?: SessionSnapshot): LearningSession {
    if (session.status !== SessionStatus.IN_PROGRESS) {
      throw new DomainError('会话不在进行中，无法暂停');
    }
    return {
      ...session,
      status: SessionStatus.PAUSED,
      pausedAt: Date.now(),
      snapshot: snapshot ?? {
        stepIndex: session.currentStepIndex,
        stepData: {},
        timestamp: Date.now(),
      },
    };
  }

  /**
   * 恢复会话
   */
  resume(session: LearningSession): LearningSession {
    if (session.status !== SessionStatus.PAUSED) {
      throw new DomainError('会话不在暂停状态，无法恢复');
    }
    return {
      ...session,
      status: SessionStatus.IN_PROGRESS,
      pausedAt: undefined,
      snapshot: undefined,
    };
  }

  /**
   * 完成会话
   */
  complete(session: LearningSession): LearningSession {
    if (session.status !== SessionStatus.IN_PROGRESS) {
      throw new DomainError('会话不在进行中，无法完成');
    }
    return {
      ...session,
      status: SessionStatus.COMPLETED,
      completedAt: Date.now(),
    };
  }

  /**
   * 放弃会话
   */
  abandon(session: LearningSession): LearningSession {
    if (
      session.status === SessionStatus.COMPLETED ||
      session.status === SessionStatus.ABANDONED
    ) {
      throw new DomainError('会话已完成或已放弃');
    }
    return {
      ...session,
      status: SessionStatus.ABANDONED,
      completedAt: Date.now(),
    };
  }

  /**
   * 添加证据
   */
  addEvidence(session: LearningSession, evidence: LearningEvidence): LearningSession {
    return {
      ...session,
      evidence: [...session.evidence, evidence],
    };
  }

  /**
   * 前进到下一步
   */
  advanceStep(session: LearningSession): LearningSession {
    return {
      ...session,
      currentStepIndex: session.currentStepIndex + 1,
    };
  }
}
