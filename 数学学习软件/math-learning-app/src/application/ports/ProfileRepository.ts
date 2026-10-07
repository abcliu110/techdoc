import type { AbilityProfile } from '../../domain/types/ability-profile';

/**
 * 能力画像仓储接口
 * 定义能力画像数据的持久化契约
 *
 * 注意：此接口已与 src/shared/interfaces.ts 保持一致
 */
export interface ProfileRepository {
  /**
   * 初始化数据库连接（可选）
   */
  initialize?(): Promise<void>;

  /**
   * 获取能力画像
   */
  getProfile(userId: string): Promise<AbilityProfile | null>;

  /**
   * 更新能力画像
   */
  updateProfile(profile: AbilityProfile): Promise<void>;
}
