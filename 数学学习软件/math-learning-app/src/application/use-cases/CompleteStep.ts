import type { SessionRepository } from '../ports/SessionRepository';
import type { ContentRepository } from '../ports/ContentRepository';
import { generateId } from '../../shared/utils';
import { LearningSession, LearningEvidence, EvidenceType, type OperationEvidence } from '../../domain/types/learning-session';
import { SessionError } from '../../domain/errors';

/**
 * 完成步骤用例
 */
export class CompleteStep {
  constructor(
    private sessionRepo: SessionRepository,
    private contentRepo: ContentRepository
  ) {}

  async execute(
    sessionId: string,
    stepData: Record<string, unknown>,
    interactionKind: 'drag' | 'tap' | 'draw' | 'split' | 'select' = 'tap'
  ): Promise<{
    isLastStep: boolean;
    session: LearningSession;
  }> {
    // 1. 获取会话
    const session = await this.sessionRepo.getSession(sessionId);
    if (!session) {
      throw new SessionError(`会话 ${sessionId} 不存在`);
    }

    // 2. 获取步骤信息
    const steps = await this.contentRepo.findSteps(session.knowledgePointId);
    const currentStep = steps[session.currentStepIndex];

    if (!currentStep) {
      throw new SessionError(`步骤 ${session.currentStepIndex} 不存在`);
    }

    // 3. 记录操作证据
    const evidence: LearningEvidence = {
      id: generateId(),
      sessionId: sessionId,
      stepId: currentStep.id,
      type: EvidenceType.OPERATION,
      data: {
        type: EvidenceType.OPERATION,
        interactionKind,
        result: stepData,
        attempts: 1,
      } as OperationEvidence,
      timestamp: Date.now(),
    };
    await this.sessionRepo.recordEvidence(sessionId, evidence);

    // 4. 判断是否是最后一步
    const isLastStep = session.currentStepIndex >= steps.length - 1;

    // 5. 更新会话进度
    const nextStepIndex = isLastStep ? session.currentStepIndex : session.currentStepIndex + 1;
    await this.sessionRepo.updateSessionProgress(sessionId, nextStepIndex);

    // 6. 如果是最后一步，标记会话完成
    if (isLastStep && this.sessionRepo.completeSession) {
      await this.sessionRepo.completeSession(sessionId);
    }

    // 7. 返回更新后的会话（手动同步新证据）
    const updatedSession = await this.sessionRepo.getSession(sessionId);
    const sessionWithNewEvidence: LearningSession = updatedSession
      ? { ...updatedSession, evidence: [...updatedSession.evidence, evidence] }
      : { ...session, evidence: [...session.evidence, evidence] };

    return {
      isLastStep,
      session: sessionWithNewEvidence,
    };
  }
}
