/**
 * 持久化服务
 * 封装会话恢复、证据历史、能力画像更新等持久化功能
 *
 * 版本：v1.0.0
 * 更新日期：2026-10-06
 */

import type { SessionRepository, ProfileRepository } from '../../shared/interfaces';
import type { LearningSession, LearningEvidence } from '../../shared/interfaces';
import type { AbilityProfile, AbilityState } from '../../shared/interfaces';
import { Ability, AbilityLevel } from '../../shared/interfaces';
import { SessionStatus } from '../../shared/interfaces';

/**
 * 持久化服务接口
 */
export interface PersistenceService {
  /**
   * 获取未完成的会话（用于会话恢复）
   */
  getIncompleteSessions(): Promise<LearningSession[]>;

  /**
   * 根据会话 ID 获取会话
   */
  getSession(sessionId: string): Promise<LearningSession | null>;

  /**
   * 获取会话的所有证据（证据历史）
   */
  getSessionEvidence(sessionId: string): Promise<LearningEvidence[]>;

  /**
   * 获取能力画像
   */
  getAbilityProfile(userId: string): Promise<AbilityProfile | null>;

  /**
   * 更新能力画像（学习后的能力变化）
   * @param userId 用户 ID
   * @param evidenceList 学习过程中收集的证据
   * @returns 更新后的能力画像
   */
  updateAbilityProfile(userId: string, evidenceList: LearningEvidence[]): Promise<AbilityProfile>;

  /**
   * 保存会话进度
   */
  saveSessionProgress(sessionId: string, stepIndex: number): Promise<void>;

  /**
   * 暂停会话
   */
  pauseSession(sessionId: string, snapshot?: LearningSession['snapshot']): Promise<void>;

  /**
   * 完成会话
   */
  finishSession(sessionId: string): Promise<void>;
}

/**
 * 持久化服务实现
 */
export class PersistenceServiceImpl implements PersistenceService {
  constructor(
    private sessionRepo: SessionRepository,
    private profileRepo: ProfileRepository
  ) {}

  /**
   * 获取未完成的会话
   * 用于从 IndexedDB/SQLite 恢复中断的学习会话
   */
  async getIncompleteSessions(): Promise<LearningSession[]> {
    if (this.sessionRepo.resumeSession) {
      return this.sessionRepo.resumeSession();
    }
    // 如果没有实现 resumeSession，回退到查询所有会话并过滤
    return [];
  }

  /**
   * 根据会话 ID 获取会话
   */
  async getSession(sessionId: string): Promise<LearningSession | null> {
    return this.sessionRepo.getSession(sessionId);
  }

  /**
   * 获取会话的所有证据
   */
  async getSessionEvidence(sessionId: string): Promise<LearningEvidence[]> {
    return this.sessionRepo.getSessionEvidence(sessionId);
  }

  /**
   * 获取能力画像
   */
  async getAbilityProfile(userId: string): Promise<AbilityProfile | null> {
    return this.profileRepo.getProfile(userId);
  }

  /**
   * 更新能力画像
   * 根据学习过程中收集的证据，计算能力等级变化
   */
  async updateAbilityProfile(
    userId: string,
    evidenceList: LearningEvidence[]
  ): Promise<AbilityProfile> {
    // 获取现有画像或创建新画像
    let profile = await this.profileRepo.getProfile(userId);

    if (!profile) {
      profile = this.createInitialProfile(userId);
    }

    // 计算能力状态变化
    const updatedStates = this.calculateAbilityStates(profile.states, evidenceList);

    // 更新画像
    const updatedProfile: AbilityProfile = {
      ...profile,
      states: updatedStates,
      totalEvidence: [...profile.totalEvidence, ...evidenceList],
      updatedAt: Date.now(),
    };

    await this.profileRepo.updateProfile(updatedProfile);
    return updatedProfile;
  }

  /**
   * 保存会话进度
   */
  async saveSessionProgress(sessionId: string, stepIndex: number): Promise<void> {
    await this.sessionRepo.updateSessionProgress(sessionId, stepIndex);
  }

  /**
   * 暂停会话
   */
  async pauseSession(
    sessionId: string,
    snapshot?: LearningSession['snapshot']
  ): Promise<void> {
    const session = await this.sessionRepo.getSession(sessionId);
    if (session) {
      session.status = SessionStatus.PAUSED;
      session.pausedAt = Date.now();
      if (snapshot) {
        session.snapshot = snapshot;
      }
      // 更新会话状态（需要扩展 updateSessionProgress 以支持状态变更）
      await this.sessionRepo.updateSessionProgress(sessionId, session.currentStepIndex);
    }
  }

  /**
   * 完成会话
   */
  async finishSession(sessionId: string): Promise<void> {
    if (this.sessionRepo.completeSession) {
      await this.sessionRepo.completeSession(sessionId);
    }
  }

  /**
   * 创建初始能力画像
   */
  private createInitialProfile(userId: string): AbilityProfile {
    const states: AbilityState[] = Object.values(Ability).map((ability) => ({
      ability,
      level: AbilityLevel.NOT_STARTED,
      evidenceCount: 0,
      lastPracticedAt: 0,
    }));

    return {
      userId,
      states,
      totalEvidence: [],
      updatedAt: Date.now(),
    };
  }

  /**
   * 根据证据计算能力状态变化
   * 基于证据数量和类型推断能力提升
   */
  private calculateAbilityStates(
    currentStates: AbilityState[],
    newEvidenceList: LearningEvidence[]
  ): AbilityState[] {
    // 按能力分组统计证据
    const evidenceByAbility = new Map<Ability, LearningEvidence[]>();

    for (const evidence of newEvidenceList) {
      // 从证据数据中提取能力信息（这里简化处理，实际需要根据业务逻辑）
      const ability = this.inferAbilityFromEvidence(evidence);
      const list = evidenceByAbility.get(ability) || [];
      list.push(evidence);
      evidenceByAbility.set(ability, list);
    }

    // 更新每个能力的状态
    return currentStates.map((state) => {
      const newEvidence = evidenceByAbility.get(state.ability) || [];

      if (newEvidence.length === 0) {
        return state;
      }

      // 计算新的证据数量
      const newCount = state.evidenceCount + newEvidence.length;

      // 根据证据数量计算新等级
      const newLevel = this.calculateLevel(newCount, state.level);

      return {
        ...state,
        level: newLevel,
        evidenceCount: newCount,
        lastPracticedAt: Date.now(),
      };
    });
  }

  /**
   * 从证据推断能力类型
   * 实际实现需要根据证据的具体类型和上下文来确定
   */
  private inferAbilityFromEvidence(_evidence: LearningEvidence): Ability {
    // 默认返回数形结合能力
    // 实际实现应该根据证据的 stepId、data 等信息推断
    return Ability.NUMBER_SHAPE_INTEGRATION;
  }

  /**
   * 根据证据数量计算能力等级
   * - 0: 未开始
   * - 1-3: 感知
   * - 4-7: 发展中
   * - 8+: 掌握
   */
  private calculateLevel(totalCount: number, _currentLevel: AbilityLevel): AbilityLevel {
    if (totalCount >= 8) {
      return AbilityLevel.MASTERED;
    }
    if (totalCount >= 4) {
      return AbilityLevel.DEVELOPING;
    }
    if (totalCount >= 1) {
      return AbilityLevel.AWARE;
    }
    return AbilityLevel.NOT_STARTED;
  }
}
