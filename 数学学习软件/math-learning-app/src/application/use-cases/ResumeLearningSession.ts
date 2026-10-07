import type { SessionRepository } from '../ports/SessionRepository';
import type { LearningSession } from '../../domain/types/learning-session';

/**
 * 恢复学习会话用例
 *
 * 从 IndexedDB/SQLite 恢复未完成的会话，供用户选择继续学习
 *
 * 使用场景：
 * - 用户重新打开应用时，自动恢复中断的学习进度
 * - 用户主动选择继续之前的会话
 */
export class ResumeLearningSession {
  constructor(private sessionRepo: SessionRepository) {}

  /**
   * 获取所有未完成的会话
   * @returns 未完成状态的所有会话列表（按最近更新时间倒序）
   */
  async execute(): Promise<LearningSession[]> {
    if (this.sessionRepo.resumeSession) {
      return this.sessionRepo.resumeSession();
    }
    return [];
  }

  /**
   * 获取单个会话并恢复
   * @param sessionId 会话 ID
   * @returns 恢复的会话（包含所有证据）
   */
  async getSession(sessionId: string): Promise<LearningSession | null> {
    return this.sessionRepo.getSession(sessionId);
  }
}
