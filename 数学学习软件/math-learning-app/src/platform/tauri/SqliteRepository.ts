import Database from '@tauri-apps/plugin-sql';
import type { SessionRepository, ProfileRepository } from '../../shared/interfaces';
import type { LearningSession, LearningEvidence } from '../../domain/types/learning-session';
import type { AbilityProfile, AbilityState, TrendDataPoint } from '../../domain/types/ability-profile';
import { Ability } from '../../domain/types/ability';
import { SessionStatus } from '../../domain/types/learning-session';

/**
 * 数据库实例类型
 */
type DbInstance = Awaited<ReturnType<typeof Database.load>>;

/**
 * 生成唯一 ID
 */
function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substring(2, 11)}`;
}

/**
 * 会话行数据（数据库映射）
 */
interface SessionRow {
  id: string;
  knowledge_point_id: string;
  ability: string;
  status: string;
  current_step_index: number;
  started_at: number;
  updated_at: number | null;
  paused_at: number | null;
  completed_at: number | null;
}

/**
 * 证据行数据（数据库映射）
 */
interface EvidenceRow {
  id: string;
  session_id: string;
  step_id: string;
  type: string;
  data: string;
  timestamp: number;
}

/**
 * 画像行数据（数据库映射）
 */
interface ProfileRow {
  user_id: string;
  states: string;
  total_evidence: string;
  last_updated: number;
}

/**
 * 带 sessionId 的证据存储类型（用于查询）
 */
type StoredEvidence = LearningEvidence & { sessionId: string };

/**
 * 将证据行映射为 LearningEvidence 对象
 */
function mapRowToEvidence(row: EvidenceRow): LearningEvidence {
  return {
    id: row.id,
    stepId: row.step_id,
    type: row.type as LearningEvidence['type'],
    data: JSON.parse(row.data),
    timestamp: row.timestamp,
  };
}

/**
 * Tauri SQLite 会话仓储实现
 */
export class TauriSqliteSessionRepository implements SessionRepository {
  private db: DbInstance | null = null;

  async initialize(): Promise<void> {
    try {
      this.db = await Database.load('sqlite:learning.db');
      await this.createTables();
      console.log('[TauriSqliteSessionRepository] Database initialized');
    } catch (error) {
      console.error('[TauriSqliteSessionRepository] Failed to initialize:', error);
      throw error;
    }
  }

  private async createTables(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    await this.db.execute(`
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        knowledge_point_id TEXT NOT NULL,
        ability TEXT NOT NULL,
        status TEXT NOT NULL,
        current_step_index INTEGER DEFAULT 0,
        started_at INTEGER NOT NULL,
        updated_at INTEGER,
        paused_at INTEGER,
        completed_at INTEGER
      )
    `);

    await this.db.execute(`
      CREATE TABLE IF NOT EXISTS evidence (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        step_id TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
      )
    `);

    await this.db.execute(`
      CREATE INDEX IF NOT EXISTS idx_evidence_session_id ON evidence(session_id)
    `);

    await this.db.execute(`
      CREATE INDEX IF NOT EXISTS idx_evidence_timestamp ON evidence(timestamp)
    `);

    await this.db.execute(`
      CREATE INDEX IF NOT EXISTS idx_evidence_type ON evidence(type)
    `);
  }

  private async ensureDb(): Promise<DbInstance> {
    if (!this.db) {
      await this.initialize();
    }
    return this.db!;
  }

  private mapToSession(row: SessionRow, evidence: LearningEvidence[] = []): LearningSession {
    return {
      id: row.id,
      knowledgePointId: row.knowledge_point_id,
      ability: (row.ability as Ability) || Ability.NUMBER_SHAPE_INTEGRATION,
      status: row.status as LearningSession['status'],
      currentStepIndex: row.current_step_index,
      startedAt: row.started_at,
      updatedAt: row.updated_at ?? undefined,
      pausedAt: row.paused_at ?? undefined,
      completedAt: row.completed_at ?? undefined,
      evidence,
    };
  }

  private mapToEvidence(row: EvidenceRow): LearningEvidence {
    return mapRowToEvidence(row);
  }

  async createSession(knowledgePointId: string): Promise<LearningSession> {
    const db = await this.ensureDb();
    const now = Date.now();
    const id = generateId();

    await db.execute(
      `INSERT INTO sessions (id, knowledge_point_id, ability, status, current_step_index, started_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [id, knowledgePointId, Ability.NUMBER_SHAPE_INTEGRATION, SessionStatus.NOT_STARTED, 0, now, now]
    );

    return {
      id,
      knowledgePointId,
      ability: Ability.NUMBER_SHAPE_INTEGRATION,
      status: SessionStatus.NOT_STARTED,
      currentStepIndex: 0,
      startedAt: now,
      evidence: [],
    };
  }

  async getSession(sessionId: string): Promise<LearningSession | null> {
    const db = await this.ensureDb();
    const rows = await db.select<SessionRow[]>('SELECT * FROM sessions WHERE id = ?', [sessionId]);
    const row = rows[0];
    if (!row) return null;

    const evidence = await this.getSessionEvidence(sessionId);
    return this.mapToSession(row, evidence);
  }

  async updateSessionProgress(sessionId: string, stepIndex: number): Promise<void> {
    const db = await this.ensureDb();
    await db.execute(
      `UPDATE sessions SET current_step_index = ?, status = ?, updated_at = ? WHERE id = ?`,
      [stepIndex, SessionStatus.IN_PROGRESS, Date.now(), sessionId]
    );
    console.log('[TauriSqliteSessionRepository] Progress updated:', sessionId, 'step:', stepIndex);
  }

  async recordEvidence(sessionId: string, evidence: LearningEvidence): Promise<void> {
    const db = await this.ensureDb();
    const now = Date.now();
    await db.execute(
      `INSERT INTO evidence (id, session_id, step_id, type, data, timestamp)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [evidence.id || generateId(), sessionId, evidence.stepId, evidence.type, JSON.stringify(evidence.data), evidence.timestamp || now]
    );
  }

  async getSessionEvidence(sessionId: string): Promise<LearningEvidence[]> {
    const db = await this.ensureDb();
    const rows = await db.select<EvidenceRow[]>(
      'SELECT * FROM evidence WHERE session_id = ? ORDER BY timestamp ASC',
      [sessionId]
    );
    return rows.map(row => this.mapToEvidence(row));
  }

  async delete(sessionId: string): Promise<void> {
    const db = await this.ensureDb();
    await db.execute('DELETE FROM evidence WHERE session_id = ?', [sessionId]);
    await db.execute('DELETE FROM sessions WHERE id = ?', [sessionId]);
  }

  async completeSession(sessionId: string): Promise<void> {
    const db = await this.ensureDb();
    await db.execute(
      `UPDATE sessions SET status = ?, completed_at = ?, updated_at = ? WHERE id = ?`,
      [SessionStatus.COMPLETED, Date.now(), Date.now(), sessionId]
    );
    console.log('[TauriSqliteSessionRepository] Session completed:', sessionId);
  }

  // ==================== 会话恢复功能 ====================

  /**
   * 恢复未完成的会话
   * 获取用户最近的未完成会话列表
   */
  async resumeSession(): Promise<LearningSession[]> {
    const db = await this.ensureDb();
    const rows = await db.select<SessionRow[]>(
      `SELECT * FROM sessions WHERE status IN (?, ?, ?) ORDER BY COALESCE(updated_at, paused_at, started_at) DESC`,
      [SessionStatus.NOT_STARTED, SessionStatus.IN_PROGRESS, SessionStatus.PAUSED]
    );

    const sessionsWithEvidence: LearningSession[] = await Promise.all(
      rows.map(async (row) => {
        const evidence = await this.getSessionEvidence(row.id);
        return this.mapToSession(row, evidence);
      })
    );

    console.log('[TauriSqliteSessionRepository] Found', sessionsWithEvidence.length, 'incomplete sessions');
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
    const db = await this.ensureDb();
    const rows = await db.select<SessionRow[]>(
      `SELECT * FROM sessions ORDER BY started_at DESC LIMIT ? OFFSET ?`,
      [limit, offset]
    );

    const sessionsWithEvidence: LearningSession[] = await Promise.all(
      rows.map(async (row) => {
        const evidence = await this.getSessionEvidence(row.id);
        return this.mapToSession(row, evidence);
      })
    );

    console.log('[TauriSqliteSessionRepository] Listed', sessionsWithEvidence.length, 'sessions');
    return sessionsWithEvidence;
  }

  // ==================== 证据历史查询功能 ====================

  /**
   * 按时间范围查询证据
   */
  async getEvidenceByTimeRange(startTime: number, endTime: number): Promise<LearningEvidence[]> {
    const db = await this.ensureDb();
    const rows = await db.select<EvidenceRow[]>(
      `SELECT * FROM evidence WHERE timestamp >= ? AND timestamp <= ? ORDER BY timestamp ASC`,
      [startTime, endTime]
    );

    console.log('[TauriSqliteSessionRepository] Found', rows.length, 'evidence in time range');
    return rows.map(row => this.mapToEvidence(row));
  }

  /**
   * 按证据类型查询
   */
  async getEvidenceByType(type: string): Promise<LearningEvidence[]> {
    const db = await this.ensureDb();
    const rows = await db.select<EvidenceRow[]>(
      `SELECT * FROM evidence WHERE type = ? ORDER BY timestamp ASC`,
      [type]
    );

    console.log('[TauriSqliteSessionRepository] Found', rows.length, 'evidence of type', type);
    return rows.map(row => this.mapToEvidence(row));
  }

  /**
   * 获取能力相关的证据统计
   */
  async getAbilityEvidenceStats(): Promise<Record<string, number>> {
    const db = await this.ensureDb();

    // 获取所有会话的能力映射
    const sessions = await db.select<SessionRow[]>('SELECT id, ability FROM sessions');
    const sessionAbilities = new Map<string, string>();
    sessions.forEach((session) => {
      sessionAbilities.set(session.id, session.ability);
    });

    // 获取所有证据
    const allEvidence = await db.select<EvidenceRow[]>('SELECT session_id FROM evidence');

    // 统计每个能力的证据数量
    const stats: Record<string, number> = {
      [Ability.NUMBER_SHAPE_INTEGRATION]: 0,
      [Ability.UNIT_UNIFICATION]: 0,
      [Ability.WHOLE_PART_THINKING]: 0,
      [Ability.TRANSFORMATION]: 0,
      [Ability.EQUATION_REASONING]: 0,
    };

    allEvidence.forEach((evidence) => {
      const ability = sessionAbilities.get(evidence.session_id);
      if (ability && stats[ability] !== undefined) {
        stats[ability]++;
      }
    });

    console.log('[TauriSqliteSessionRepository] Ability stats:', stats);
    return stats;
  }

  /**
   * 获取所有证据（用于统计）
   */
  async getAllEvidence(): Promise<LearningEvidence[]> {
    const db = await this.ensureDb();
    const rows = await db.select<EvidenceRow[]>('SELECT * FROM evidence ORDER BY timestamp ASC');
    return rows.map(row => this.mapToEvidence(row));
  }
}

/**
 * Tauri SQLite 能力画像仓储实现
 */
export class TauriSqliteProfileRepository implements ProfileRepository {
  private db: DbInstance | null = null;

  async initialize(): Promise<void> {
    try {
      this.db = await Database.load('sqlite:learning.db');
      await this.createTables();
      console.log('[TauriSqliteProfileRepository] Database initialized');
    } catch (error) {
      console.error('[TauriSqliteProfileRepository] Failed to initialize:', error);
      throw error;
    }
  }

  private async createTables(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');
    await this.db.execute(`
      CREATE TABLE IF NOT EXISTS profiles (
        user_id TEXT PRIMARY KEY,
        states TEXT NOT NULL,
        total_evidence TEXT NOT NULL,
        last_updated INTEGER NOT NULL
      )
    `);
  }

  private async ensureDb(): Promise<DbInstance> {
    if (!this.db) {
      await this.initialize();
    }
    return this.db!;
  }

  async getProfile(userId: string): Promise<AbilityProfile | null> {
    const db = await this.ensureDb();
    const rows = await db.select<ProfileRow[]>('SELECT * FROM profiles WHERE user_id = ?', [userId]);
    const row = rows[0];
    if (!row) return null;

    return {
      userId: row.user_id,
      states: JSON.parse(row.states),
      totalEvidence: JSON.parse(row.total_evidence),
      updatedAt: row.last_updated,
    };
  }

  async updateProfile(profile: AbilityProfile): Promise<void> {
    const db = await this.ensureDb();
    const now = Date.now();
    await db.execute(
      `INSERT OR REPLACE INTO profiles (user_id, states, total_evidence, last_updated)
       VALUES (?, ?, ?, ?)`,
      [profile.userId, JSON.stringify(profile.states), JSON.stringify(profile.totalEvidence), now]
    );
    console.log('[TauriSqliteProfileRepository] Profile updated for user:', profile.userId);
  }

  // ==================== 能力画像增强功能 ====================

  /**
   * 批量更新能力状态
   */
  async batchUpdateAbilities(userId: string, updates: Partial<AbilityState>[]): Promise<void> {
    const profile = await this.getProfile(userId);
    if (!profile) {
      console.warn('[TauriSqliteProfileRepository] Profile not found for batch update:', userId);
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
    console.log('[TauriSqliteProfileRepository] Batch updated', updates.length, 'abilities');
  }

  /**
   * 获取能力成长趋势
   * 根据历史证据数据计算每日的能力分布
   */
  async getAbilityTrend(userId: string, days: number = 7): Promise<TrendDataPoint[]> {
    const profile = await this.getProfile(userId);
    if (!profile) {
      console.warn('[TauriSqliteProfileRepository] Profile not found for trend:', userId);
      return [];
    }

    const db = await this.ensureDb();

    // 计算日期范围
    const now = Date.now();
    const dayMs = 24 * 60 * 60 * 1000;
    const startTime = now - (days - 1) * dayMs;

    // 从 evidence 表查询历史证据
    const evidence = await db.select<EvidenceRow[]>(
      `SELECT * FROM evidence WHERE timestamp >= ?`,
      [startTime]
    );

    // 获取会话的能力映射
    const sessionAbilities = new Map<string, Ability>();
    const sessions = await db.select<SessionRow[]>('SELECT id, ability FROM sessions');
    sessions.forEach((session) => {
      sessionAbilities.set(session.id, session.ability as Ability);
    });

    // 按日期分组
    const dailyEvidence = new Map<string, StoredEvidence[]>();
    for (let i = 0; i < days; i++) {
      const date = new Date(now - (days - 1 - i) * dayMs);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
      dailyEvidence.set(dateStr, []);
    }

    evidence.forEach((e) => {
      const date = new Date(e.timestamp);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
      const list = dailyEvidence.get(dateStr);
      if (list) {
        list.push({ ...mapRowToEvidence(e), sessionId: e.session_id });
      }
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
        const ability = sessionAbilities.get(e.sessionId);
        if (ability && ability in abilitiesCount) {
          abilitiesCount[ability] = (abilitiesCount[ability] ?? 0) + 1;
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
        abilities: abilitiesLevels as Record<Ability, number>,
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
        abilities: abilitiesLevels as Record<Ability, number>,
      });
    }

    console.log('[TauriSqliteProfileRepository] Generated trend with', trend.length, 'data points');
    return trend;
  }

  /**
   * 删除能力画像
   */
  async deleteProfile(userId: string): Promise<void> {
    const db = await this.ensureDb();
    await db.execute('DELETE FROM profiles WHERE user_id = ?', [userId]);
    console.log('[TauriSqliteProfileRepository] Profile deleted for user:', userId);
  }
}
