import type { ProfileRepository } from '../ports/ProfileRepository';
import type { ProfileResult, AbilityState } from '../../domain/types/ability-profile';
import { AbilityProfileService } from '../../domain/services/AbilityProfileService';
import { AbilityLevel, Ability } from '../../domain/types/ability';

/**
 * 获取能力画像用例
 */
export class GetAbilityProfile {
  constructor(
    private profileRepo: ProfileRepository,
    private profileService: AbilityProfileService
  ) {}

  async execute(userId: string = 'default-user'): Promise<ProfileResult> {
    // 1. 获取或创建能力画像
    let profile = await this.profileRepo.getProfile(userId);
    if (!profile) {
      profile = this.profileService.createProfile(userId);
      await this.profileRepo.updateProfile(profile);
    }

    // 2. 构建雷达图数据
    const radarData = profile.states.map((state: AbilityState) => ({
      ability: state.ability,
      level: state.level,
      maxLevel: AbilityLevel.MASTERED,
      label: this.getAbilityLabel(state.ability),
    }));

    // 3. 构建成长趋势数据（简化版本）
    const trend: ProfileResult['trend'] = [];

    return {
      abilities: profile.states,
      radarData,
      trend,
    };
  }

  private getAbilityLabel(ability: Ability): string {
    const labels: Record<string, string> = {
      [Ability.NUMBER_SHAPE_INTEGRATION]: '数形结合',
      [Ability.UNIT_UNIFICATION]: '单位统一',
      [Ability.WHOLE_PART_THINKING]: '整体部分',
      [Ability.TRANSFORMATION]: '转化化归',
      [Ability.EQUATION_REASONING]: '等量关系',
    };
    return labels[ability] ?? ability;
  }
}
