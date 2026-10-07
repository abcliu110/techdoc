import type { SessionRepository } from '../ports/SessionRepository';
import type { ProfileRepository } from '../ports/ProfileRepository';
import { AbilityProfileService } from '../../domain/services/AbilityProfileService';
import type { LearningEvidence } from '../../domain/types/learning-session';

/**
 * 记录学习证据用例
 */
export class RecordEvidence {
  constructor(
    private sessionRepo: SessionRepository,
    private profileRepo: ProfileRepository,
    private profileService: AbilityProfileService
  ) {}

  async execute(
    sessionId: string,
    evidence: LearningEvidence,
    userId: string = 'default-user'
  ): Promise<void> {
    // 1. 获取会话
    const session = await this.sessionRepo.getSession(sessionId);
    if (!session) {
      throw new Error(`会话 ${sessionId} 不存在`);
    }

    // 2. 记录证据
    await this.sessionRepo.recordEvidence(sessionId, evidence);

    // 3. 更新能力画像
    let profile = await this.profileRepo.getProfile(userId);
    if (!profile) {
      profile = this.profileService.createProfile(userId);
    }

    // 重新获取会话以获取最新证据
    const updatedSession = await this.sessionRepo.getSession(sessionId);
    const evidenceList = updatedSession?.evidence || session.evidence;

    const updatedProfile = this.profileService.updateAbilityLevel(
      profile,
      session.ability,
      evidenceList
    );
    await this.profileRepo.updateProfile(updatedProfile);
  }
}
