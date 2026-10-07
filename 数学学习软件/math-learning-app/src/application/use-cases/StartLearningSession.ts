import type { SessionRepository } from '../ports/SessionRepository';
import type { ContentRepository } from '../ports/ContentRepository';
import type { LearningSession } from '../../domain/types/learning-session';
import { Ability } from '../../domain/types/ability';

/**
 * 开始学习会话用例
 */
export class StartLearningSession {
  constructor(
    private sessionRepo: SessionRepository,
    private contentRepo: ContentRepository
  ) {}

  async execute(_userId: string, knowledgePointId: string): Promise<LearningSession> {
    // 1. 获取知识点信息
    const kp = await this.contentRepo.findKnowledgePoint(knowledgePointId);
    if (!kp) {
      throw new Error(`知识点 ${knowledgePointId} 不存在`);
    }

    // 2. 创建新会话
    const newSession = await this.sessionRepo.createSession(knowledgePointId);

    // 3. 更新会话状态为进行中
    await this.sessionRepo.updateSessionProgress(newSession.id, 0);

    // 4. 获取更新后的会话
    const updatedSession = await this.sessionRepo.getSession(newSession.id);

    // 返回会话（包含 ability 信息用于领域服务）
    return {
      ...updatedSession!,
      ability: kp.ability as Ability,
      startedAt: updatedSession!.startedAt,
    } as LearningSession;
  }
}
