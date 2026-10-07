/**
 * ProfileRepository 接口契约测试
 * 根据 src/shared/interfaces.ts 中定义的新接口
 */
import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { ProfileRepository } from '../../src/shared/interfaces';
import type { AbilityProfile, AbilityState } from '../../src/shared/interfaces';
import { Ability, AbilityLevel } from '../../src/shared/interfaces';

// 创建测试用的 Repository Mock（符合新接口）
const createMockProfileRepository = (): ProfileRepository => ({
  initialize: vi.fn().mockResolvedValue(undefined),
  getProfile: vi.fn().mockResolvedValue(null),
  updateProfile: vi.fn().mockResolvedValue(undefined),
});

describe('ProfileRepository 接口契约测试', () => {
  let repository: ProfileRepository;

  beforeEach(() => {
    repository = createMockProfileRepository();
  });

  describe('接口方法存在性', () => {
    it('应该实现 getProfile 方法', () => {
      expect(typeof repository.getProfile).toBe('function');
    });

    it('应该实现 updateProfile 方法', () => {
      expect(typeof repository.updateProfile).toBe('function');
    });
  });

  describe('getProfile', () => {
    it('当画像不存在时应返回 null', async () => {
      const profile = await repository.getProfile('non-existent-user');
      expect(profile).toBeNull();
    });
  });

  describe('updateProfile', () => {
    it('应该能够更新画像', async () => {
      const profile: AbilityProfile = {
        userId: 'user-1',
        states: [
          {
            ability: Ability.NUMBER_SHAPE_INTEGRATION,
            level: AbilityLevel.DEVELOPING,
            evidenceCount: 5,
            lastPracticedAt: Date.now(),
          },
        ],
        totalEvidence: [],
        updatedAt: Date.now(),
      };
      await expect(repository.updateProfile(profile)).resolves.not.toThrow();
    });
  });
});

describe('AbilityProfile 类型验证', () => {
  describe('类型结构（根据 domain/types/ability-profile.ts）', () => {
    it('AbilityProfile 应该有 userId', () => {
      const profile: AbilityProfile = {
        userId: 'user-1',
        states: [],
        totalEvidence: [],
        updatedAt: Date.now(),
      };
      expect(profile.userId).toBe('user-1');
    });

    it('AbilityProfile 应该有 states（能力状态数组）', () => {
      const state: AbilityState = {
        ability: Ability.NUMBER_SHAPE_INTEGRATION,
        level: AbilityLevel.AWARE,
        evidenceCount: 3,
        lastPracticedAt: Date.now(),
      };
      const profile: AbilityProfile = {
        userId: 'user-1',
        states: [state],
        totalEvidence: [],
        updatedAt: Date.now(),
      };
      expect(profile.states.length).toBe(1);
      expect(profile.states[0].ability).toBe(Ability.NUMBER_SHAPE_INTEGRATION);
    });

    it('AbilityProfile 应该有 totalEvidence', () => {
      const profile: AbilityProfile = {
        userId: 'user-1',
        states: [],
        totalEvidence: [],
        updatedAt: Date.now(),
      };
      expect(Array.isArray(profile.totalEvidence)).toBe(true);
    });

    it('AbilityProfile 应该有 updatedAt', () => {
      const now = Date.now();
      const profile: AbilityProfile = {
        userId: 'user-1',
        states: [],
        totalEvidence: [],
        updatedAt: now,
      };
      expect(profile.updatedAt).toBe(now);
    });

    it('AbilityState 应该有正确的能力等级枚举', () => {
      const state: AbilityState = {
        ability: Ability.TRANSFORMATION,
        level: AbilityLevel.MASTERED,
        evidenceCount: 10,
        lastPracticedAt: Date.now(),
      };
      expect(state.level).toBe(AbilityLevel.MASTERED);
      expect(state.ability).toBe(Ability.TRANSFORMATION);
    });
  });
});
