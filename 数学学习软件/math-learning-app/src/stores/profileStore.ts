import { create } from 'zustand';
import type { AbilityProfile } from '../domain/types/ability-profile';
import type { AbilityState } from '../domain/types/ability';

interface ProfileState {
  /** 能力画像 */
  profile: AbilityProfile | null;
  /** 加载状态 */
  isLoading: boolean;
  /** 错误信息 */
  error: string | null;
}

interface ProfileActions {
  /** 加载能力画像 */
  loadProfile: (profile: AbilityProfile) => void;
  /** 更新能力状态 */
  updateAbilityState: (states: AbilityState[]) => void;
  /** 重置状态 */
  reset: () => void;
  /** 设置加载状态 */
  setLoading: (loading: boolean) => void;
  /** 设置错误 */
  setError: (error: string | null) => void;
}

type ProfileStore = ProfileState & ProfileActions;

const initialState: ProfileState = {
  profile: null,
  isLoading: false,
  error: null,
};

export const useProfileStore = create<ProfileStore>()((set) => ({
  ...initialState,

  loadProfile: (profile) => {
    set({ profile, isLoading: false, error: null });
  },

  updateAbilityState: (states) => {
    set((state) => ({
      profile: state.profile
        ? { ...state.profile, states, updatedAt: Date.now() }
        : null,
    }));
  },

  reset: () => {
    set(initialState);
  },

  setLoading: (loading) => {
    set({ isLoading: loading });
  },

  setError: (error) => {
    set({ error });
  },
}));
