import { useState, useCallback } from 'react';
import type { ProfileResult } from '../domain/types/ability-profile';
import { useProfileStore } from '../stores/profileStore';
import { createWebPlatform } from '../platform';
import { GetAbilityProfile } from '../application/use-cases/GetAbilityProfile';
import { AbilityProfileService } from '../domain/services/AbilityProfileService';

const platform = createWebPlatform();
const getAbilityProfile = new GetAbilityProfile(
  platform.profileRepo,
  new AbilityProfileService()
);

/**
 * 能力画像 Hook
 */
export function useAbilityProfile() {
  const {
    profile,
    isLoading,
    error,
    loadProfile,
    setLoading,
    setError,
    reset,
  } = useProfileStore();

  const [profileResult, setProfileResult] = useState<ProfileResult | null>(null);

  /**
   * 加载能力画像
   */
  const load = useCallback(async (userId: string = 'default-user') => {
    setLoading(true);
    setError(null);
    try {
      const result = await getAbilityProfile.execute(userId);
      setProfileResult(result);
      if (result.abilities.length > 0) {
        loadProfile({
          userId,
          states: result.abilities,
          totalEvidence: [],
          updatedAt: Date.now(),
        });
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : '加载能力画像失败');
    } finally {
      setLoading(false);
    }
  }, [loadProfile, setLoading, setError]);

  /**
   * 获取能力等级标签
   */
  const getLevelLabel = useCallback((level: number): string => {
    const labels: Record<number, string> = {
      0: '未开始',
      1: '初步认识',
      2: '正在发展',
      3: '已掌握',
    };
    return labels[level] ?? '未知';
  }, []);

  /**
   * 获取能力名称
   */
  const getAbilityName = useCallback((ability: string): string => {
    const labels: Record<string, string> = {
      'number-shape-integration': '数形结合',
      'unit-unification': '单位统一',
      'whole-part-thinking': '整体部分思想',
      'transformation': '转化化归思想',
      'equation-reasoning': '等量关系与方程',
    };
    return labels[ability] ?? ability;
  }, []);

  return {
    profile,
    profileResult,
    isLoading,
    error,
    load,
    reset,
    getLevelLabel,
    getAbilityName,
  };
}
