import type { LearningSession, LearningEvidence } from '../../domain/types/learning-session';

/**
 * 学习会话仓储接口
 * 定义学习会话数据的持久化契约
 *
 * 注意：此接口已与 src/shared/interfaces.ts 保持一致
 */
export interface SessionRepository {
  /**
   * 初始化数据库连接（可选）
   */
  initialize?(): Promise<void>;

  /**
   * 创建新会话
   */
  createSession(knowledgePointId: string): Promise<LearningSession>;

  /**
   * 获取会话
   */
  getSession(sessionId: string): Promise<LearningSession | null>;

  /**
   * 更新会话进度
   */
  updateSessionProgress(sessionId: string, stepIndex: number): Promise<void>;

  /**
   * 记录学习证据
   */
  recordEvidence(sessionId: string, evidence: LearningEvidence): Promise<void>;

  /**
   * 获取会话的所有证据
   */
  getSessionEvidence(sessionId: string): Promise<LearningEvidence[]>;

  /**
   * 删除会话
   */
  delete(sessionId: string): Promise<void>;

  /**
   * 完成会话（可选）
   */
  completeSession?(sessionId: string): Promise<void>;

  /**
   * 恢复未完成的会话
   * 用于从 IndexedDB/SQLite 恢复中断的学习会话
   * @returns 未完成状态的所有会话列表（按最近更新时间倒序）
   */
  resumeSession?(): Promise<LearningSession[]>;
}
