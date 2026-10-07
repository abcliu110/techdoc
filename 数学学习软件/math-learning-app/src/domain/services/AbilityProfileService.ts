import type { AbilityProfile } from '../types/ability-profile';
import { Ability, AbilityLevel, type AbilityState } from '../types/ability';
import { LearningEvidence, EvidenceType, type AnswerEvidence, type TransferEvidence } from '../types/learning-session';

/**
 * 能力画像领域服务
 * 负责能力画像的创建和更新
 */
export class AbilityProfileService {
  /**
   * 创建新的能力画像
   */
  createProfile(userId: string): AbilityProfile {
    return {
      userId,
      states: Object.values(Ability).map((ability) => ({
        ability,
        level: AbilityLevel.NOT_STARTED,
        evidenceCount: 0,
        lastPracticedAt: 0,
      })),
      totalEvidence: [],
      updatedAt: Date.now(),
    };
  }

  /**
   * 根据证据更新能力等级
   */
  updateAbilityLevel(
    profile: AbilityProfile,
    ability: Ability,
    evidence: LearningEvidence[]
  ): AbilityProfile {
    const stateIndex = profile.states.findIndex((s) => s.ability === ability);
    if (stateIndex === -1) {
      return profile;
    }

    const newState = this.calculateLevel(ability, evidence);

    const newStates = [...profile.states];
    newStates[stateIndex] = {
      ability,
      ...newStates[stateIndex],
      level: newState.level,
      evidenceCount: evidence.length,
      lastPracticedAt: Date.now(),
    };

    return {
      ...profile,
      states: newStates,
      totalEvidence: [...profile.totalEvidence, ...evidence],
      updatedAt: Date.now(),
    };
  }

  /**
   * 计算能力等级
   * 能力等级计算规则：
   * NOT_STARTED (0): 无证据
   * AWARE (1): 有操作证据
   * DEVELOPING (2): 有答案证据且正确率 >= 50%
   * MASTERED (3): 有迁移证据且正确率 >= 80%
   */
  private calculateLevel(
    _ability: Ability,
    evidence: LearningEvidence[]
  ): AbilityState {
    const operationCount = evidence.filter(
      (e) => e.type === EvidenceType.OPERATION
    ).length;
    const answerEvidence = evidence.filter(
      (e) => e.type === EvidenceType.ANSWER
    );
    const correctCount = answerEvidence.filter(
      (e) => (e.data as AnswerEvidence).isCorrect
    ).length;
    const transferEvidence = evidence.filter(
      (e) => e.type === EvidenceType.TRANSFER
    );
    const successfulTransfer = transferEvidence.filter(
      (e) => (e.data as TransferEvidence).success
    ).length;

    let level = AbilityLevel.NOT_STARTED;

    if (operationCount > 0) {
      level = AbilityLevel.AWARE;
    }

    if (
      answerEvidence.length > 0 &&
      correctCount / answerEvidence.length >= 0.5
    ) {
      level = AbilityLevel.DEVELOPING;
    }

    if (
      transferEvidence.length > 0 &&
      successfulTransfer / transferEvidence.length >= 0.8
    ) {
      level = AbilityLevel.MASTERED;
    }

    return {
      ability: _ability,
      level,
      evidenceCount: evidence.length,
      lastPracticedAt: Date.now(),
    };
  }
}
