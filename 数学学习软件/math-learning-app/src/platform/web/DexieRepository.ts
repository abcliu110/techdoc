import Dexie, { type Table } from 'dexie';
import type { SessionRepository, ProfileRepository } from '../../shared/interfaces';
import type { LearningSession, LearningEvidence, EvidenceType } from '../../domain/types/learning-session';
import type { AbilityProfile, AbilityState, TrendDataPoint } from '../../domain/types/ability-profile';
import { SessionStatus } from '../../domain/types/learning-session';
import { Ability } from '../../domain/types/ability';

/**
 * 带 sessionId 的证据存储类型（用于 Dexie 持久化）
 */
interface StoredLearningEvidence extends LearningEvidence {
  sessionId: string;
}

/**
 * Dexie 数据库定义
 */
class LearningDatabase extends Dexie {
  sessions!: Table<LearningSession>;
  evidence!: Table<StoredLearningEvidence>;
  profiles!: Table<AbilityProfile>;

  constructor() {
    super('LearningDB');
    this.version(1).stores({
      sessions: 'id, status, startedAt, [status+startedAt]',
      evidence: 'id, sessionId, timestamp, type, [timestamp+type]',
      profiles: 'userId',
    });
  }
}

const db = new LearningDatabase();

/**
 * Dexie 会话仓储实现
 */
export class DexieSessionRepository implements SessionRepository {
  async initialize(): Promise<void> {
    await db.open();
    console.log('[DexieSessionRepository] Database initialized');
  }

  async createSession(knowledgePointId: string): Promise<LearningSession> {
    const now = Date.now();
    const session: LearningSession = {
      id: `${now}-${Math.random().toString(36).substring(2, 11)}`,
      knowledgePointId,
      ability: Ability.NUMBER_SHAPE_INTEGRATION,
      status: SessionStatus.NOT_STARTED,
      currentStepIndex: 0,
      startedAt: now,
      evidence: [],
    };
    await db.sessions.add(session);
    console.log('[DexieSessionRepository] Session created:', session.id);
    return session;
  }

  async getSession(sessionId: string): Promise<LearningSession | null> {
    const session = await db.sessions.get(sessionId);
    if (!session) return null;

    const evidence = await this.getSessionEvidence(sessionId);
    return { ...session, evidence };
  }

  async updateSessionProgress(sessionId: string, stepIndex: number): Promise<void> {
    await db.sessions.update(sessionId, {
      currentStepIndex: stepIndex,
      status: SessionStatus.IN_PROGRESS,
      updatedAt: Date.now(),
    });
    console.log('[DexieSessionRepository] Progress updated:', sessionId, 'step:', stepIndex);
  }

  async recordEvidence(sessionId: string, evidence: LearningEvidence): Promise<void> {
    const storedEvidence: StoredLearningEvidence = {
      ...evidence,
      sessionId,
    };
    await db.evidence.add(storedEvidence);
    console.log('[DexieSessionRepository] Evidence recorded:', evidence.type, 'for session:', sessionId);
  }

  async getSessionEvidence(sessionId: string): Promise<LearningEvidence[]> {
    const storedEvidenceList = await db.evidence
      .where('sessionId')
      .equals(sessionId)
      .toArray();
    return storedEvidenceList.map(({ sessionId: _sessionId, ...evidence }) => evidence);
  }

  async delete(sessionId: string): Promise<void> {
    await db.evidence.where('sessionId').equals(sessionId).delete();
    await db.sessions.delete(sessionId);
    console.log('[DexieSessionRepository] Session deleted:', sessionId);
  }

  async completeSession(sessionId: string): Promise<void> {
    await db.sessions.update(sessionId, {
      status: SessionStatus.COMPLETED,
      completedAt: Date.now(),
      updatedAt: Date.now(),
    });
    console.log('[DexieSessionRepository] Session completed:', sessionId);
  }

  // ==================== 会话恢复功能 ====================

  /**
   * 恢复未完成的会话
   * 获取用户最近的未完成会话列表
   */
  async resumeSession(): Promise<LearningSession[]> {
    // 查询未完成状态的会话：NOT_STARTED, IN_PROGRESS, PAUSED
    const incompleteSessions = await db.sessions
      .where('status')
      .anyOf([SessionStatus.NOT_STARTED, SessionStatus.IN_PROGRESS, SessionStatus.PAUSED])
      .toArray();

    // 按最近更新时间倒序排序
    incompleteSessions.sort((a, b) => (b.updatedAt ?? b.startedAt) - (a.updatedAt ?? a.startedAt));

    // 加载每个会话的证据
    const sessionsWithEvidence: LearningSession[] = await Promise.all(
      incompleteSessions.map(async (session) => {
        const evidence = await this.getSessionEvidence(session.id);
        return { ...session, evidence };
      })
    );

    console.log('[DexieSessionRepository] Found', sessionsWithEvidence.length, 'incomplete sessions');
    return sessionsWithEvidence;
  }

  /**
   * 获取用户最近的未完成会话
   */
  async getLatestIncompleteSession(): Promise<LearningSession | null> {
    const sessions = await this.resumeSession();
    return sessions.length > 0 ? (sessions[0] ?? null) : null;
  }

  /**
   * 获取用户所有会话列表（分页）
   */
  async listUserSessions(limit: number = 10, offset: number = 0): Promise<LearningSession[]> {
    const sessions = await db.sessions
      .orderBy('startedAt')
      .reverse()
      .offset(offset)
      .limit(limit)
      .toArray();

    // 加载每个会话的证据
    const sessionsWithEvidence: LearningSession[] = await Promise.all(
      sessions.map(async (session) => {
        const evidence = await this.getSessionEvidence(session.id);
        return { ...session, evidence };
      })
    );

    console.log('[DexieSessionRepository] Listed', sessionsWithEvidence.length, 'sessions');
    return sessionsWithEvidence;
  }

  // ==================== 证据历史查询功能 ====================

  /**
   * 按时间范围查询证据
   */
  async getEvidenceByTimeRange(startTime: number, endTime: number): Promise<LearningEvidence[]> {
    const storedEvidenceList = await db.evidence
      .where('timestamp')
      .between(startTime, endTime, true, true)
      .toArray();

    console.log('[DexieSessionRepository] Found', storedEvidenceList.length, 'evidence in time range');
    return storedEvidenceList.map(({ sessionId: _sessionId, ...evidence }) => evidence);
  }

  /**
   * 按证据类型查询
   */
  async getEvidenceByType(type: EvidenceType): Promise<LearningEvidence[]> {
    const storedEvidenceList = await db.evidence
      .where('type')
      .equals(type)
      .toArray();

    console.log('[DexieSessionRepository] Found', storedEvidenceList.length, 'evidence of type', type);
    return storedEvidenceList.map(({ sessionId: _sessionId, ...evidence }) => evidence);
  }

  /**
   * 获取能力相关的证据统计
   */
  async getAbilityEvidenceStats(): Promise<Record<Ability, number>> {
    const allEvidence = await db.evidence.toArray();

    // 按会话分组获取能力
    const sessionAbilities = new Map<string, Ability>();
    const allSessions = await db.sessions.toArray();
    allSessions.forEach((session) => {
      sessionAbilities.set(session.id, session.ability);
    });

    // 统计每个能力的证据数量
    const stats: Record<string, number> = {
      [Ability.NUMBER_SHAPE_INTEGRATION]: 0,
      [Ability.UNIT_UNIFICATION]: 0,
      [Ability.WHOLE_PART_THINKING]: 0,
      [Ability.TRANSFORMATION]: 0,
      [Ability.EQUATION_REASONING]: 0,
    };

    allEvidence.forEach((evidence) => {
      const ability = sessionAbilities.get(evidence.sessionId);
      if (ability && stats[ability] !== undefined) {
        stats[ability]++;
      }
    });

    console.log('[DexieSessionRepository] Ability stats:', stats);
    return stats as Record<Ability, number>;
  }

  /**
   * 获取所有证据（用于统计）
   */
  async getAllEvidence(): Promise<LearningEvidence[]> {
    const storedEvidenceList = await db.evidence.toArray();
    return storedEvidenceList.map(({ sessionId: _sessionId, ...evidence }) => evidence);
  }
}

/**
 * Dexie 能力画像仓储实现
 */
export class DexieProfileRepository implements ProfileRepository {
  async initialize(): Promise<void> {
    console.log('[DexieProfileRepository] Initialized');
  }

  async getProfile(userId: string): Promise<AbilityProfile | null> {
    return (await db.profiles.get(userId)) ?? null;
  }

  async updateProfile(profile: AbilityProfile): Promise<void> {
    await db.profiles.put(profile);
    console.log('[DexieProfileRepository] Profile updated for user:', profile.userId);
  }

  // ==================== 能力画像增强功能 ====================

  /**
   * 批量更新能力状态
   */
  async batchUpdateAbilities(userId: string, updates: Partial<AbilityState>[]): Promise<void> {
    const profile = await this.getProfile(userId);
    if (!profile) {
      console.warn('[DexieProfileRepository] Profile not found for batch update:', userId);
      return;
    }

    const newStates = profile.states.map((state) => {
      const update = updates.find((u) => u.ability === state.ability);
      if (update) {
        return { ...state, ...update };
      }
      return state;
    });

    const updatedProfile: AbilityProfile = {
      ...profile,
      states: newStates,
      updatedAt: Date.now(),
    };

    await this.updateProfile(updatedProfile);
    console.log('[DexieProfileRepository] Batch updated', updates.length, 'abilities');
  }

  /**
   * 获取能力成长趋势
   * 根据历史证据数据计算每日的能力分布
   */
  async getAbilityTrend(userId: string, days: number = 7): Promise<TrendDataPoint[]> {
    const profile = await this.getProfile(userId);
    if (!profile) {
      console.warn('[DexieProfileRepository] Profile not found for trend:', userId);
      return [];
    }

    // 计算日期范围
    const now = Date.now();
    const dayMs = 24 * 60 * 60 * 1000;
    const startTime = now - (days - 1) * dayMs;

    // 从 evidence 表查询历史证据
    const evidence = await db.evidence
      .where('timestamp')
      .aboveOrEqual(startTime)
      .toArray();

    // 按日期分组
    const dailyEvidence = new Map<string, LearningEvidence[]>();
    for (let i = 0; i < days; i++) {
      const date = new Date(now - (days - 1 - i) * dayMs);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
      dailyEvidence.set(dateStr, []);
    }

    evidence.forEach((e) => {
      const storedE = e as StoredLearningEvidence;
      const date = new Date(storedE.timestamp);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
      const list = dailyEvidence.get(dateStr);
      if (list) {
        list.push(e);
      }
    });

    // 获取会话的能力映射
    const sessionAbilities = new Map<string, Ability>();
    const allSessions = await db.sessions.toArray();
    allSessions.forEach((session) => {
      sessionAbilities.set(session.id, session.ability);
    });

    // 生成趋势数据
    const trend: TrendDataPoint[] = [];
    const abilities = Object.values(Ability);

    dailyEvidence.forEach((evidenceList, date) => {
      const abilitiesCount: Record<string, number> = {};
      abilities.forEach((a) => {
        abilitiesCount[a] = 0;
      });

      evidenceList.forEach((e) => {
        const storedE = e as StoredLearningEvidence;
        const sessionId = storedE.sessionId;
        if (sessionId) {
          const ability = sessionAbilities.get(sessionId);
          if (ability && ability in abilitiesCount) {
            abilitiesCount[ability] = (abilitiesCount[ability] ?? 0) + 1;
          }
        }
      });

      // 将计数转换为等级（0-3）
      const abilitiesLevels: Record<string, number> = {};
      Object.entries(abilitiesCount).forEach(([ability, count]) => {
        if (count === 0) {
          abilitiesLevels[ability] = 0;
        } else if (count <= 2) {
          abilitiesLevels[ability] = 1;
        } else if (count <= 5) {
          abilitiesLevels[ability] = 2;
        } else {
          abilitiesLevels[ability] = 3;
        }
      });

      // 如果当天没有证据，使用前一天的数据
      const lastTrend = trend[trend.length - 1];
      if (evidenceList.length === 0 && lastTrend) {
        Object.keys(abilitiesLevels).forEach((key) => {
          abilitiesLevels[key] = lastTrend.abilities[key as Ability] ?? 0;
        });
      }

      trend.push({
        date,
        abilities: abilitiesLevels as TrendDataPoint['abilities'],
      });
    });

    // 补充初始状态
    if (trend.length === 0 && profile.states.length > 0) {
      const now = new Date();
      const dateStr = `${now.getMonth() + 1}/${now.getDate()}`;
      const abilitiesLevels: Record<string, number> = {};
      profile.states.forEach((state) => {
        abilitiesLevels[state.ability] = state.level;
      });
      trend.push({
        date: dateStr,
        abilities: abilitiesLevels as TrendDataPoint['abilities'],
      });
    }

    console.log('[DexieProfileRepository] Generated trend with', trend.length, 'data points');
    return trend;
  }

  /**
   * 删除能力画像
   */
  async deleteProfile(userId: string): Promise<void> {
    await db.profiles.delete(userId);
    console.log('[DexieProfileRepository] Profile deleted for user:', userId);
  }
}
