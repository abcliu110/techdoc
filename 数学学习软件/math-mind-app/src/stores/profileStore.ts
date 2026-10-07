import { create } from 'zustand';
import type { AbilityProfile, Ability, AbilityLevel } from '../domain/types';

/**
 * 能力画像Store状态接口
 */
interface ProfileState {
  /** 能力画像 */
  profile: AbilityProfile | null;
  /** 加载状态 */
  isLoading: boolean;
  /** 错误信息 */
  error: string | null;
}

/**
 * 能力画像Store动作接口
 */
interface ProfileActions {
  /** 加载画像 */
  loadProfile: (profile: AbilityProfile) => void;
  /** 更新能力状态 */
  updateAbilityState: (ability: Ability, level: AbilityLevel, evidenceCount: number) => void;
  /** 重置状态 */
  reset: () => void;
}

/** 能力画像Store完整类型 */
type ProfileStore = ProfileState & ProfileActions;

/** 初始状态 */
const initialState: ProfileState = {
  profile: null,
  isLoading: false,
  error: null,
};

/**
 * 能力画像Store
 * @description 管理用户在各能力维度上的发展状态
 */
export const useProfileStore = create<ProfileStore>()((set) => ({
  ...initialState,

  loadProfile: (profile: AbilityProfile) => {
    set({ profile, isLoading: false, error: null });
  },

  updateAbilityState: (ability: Ability, level: AbilityLevel, evidenceCount: number) => {
    set((state) => {
      if (!state.profile) return state;

      const states = state.profile.states.map((s) => {
        if (s.ability === ability) {
          return {
            ...s,
            level,
            evidenceCount,
            lastPracticedAt: Date.now(),
          };
        }
        return s;
      });

      return {
        profile: {
          ...state.profile,
          states,
          updatedAt: Date.now(),
        },
      };
    });
  },

  reset: () => {
    set(initialState);
  },
}));

export default useProfileStore;
