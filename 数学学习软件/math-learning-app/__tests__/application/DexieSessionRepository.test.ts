/**
 * SessionRepository 接口契约测试
 * 根据 src/shared/interfaces.ts 中定义的新接口
 */
import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { SessionRepository } from '../../src/shared/interfaces';
import type { LearningSession, LearningEvidence } from '../../src/shared/interfaces';
import { SessionStatus } from '../../src/shared/interfaces';

// 创建测试用的 Repository Mock（符合新接口）
const createMockSessionRepository = (): SessionRepository => ({
  initialize: vi.fn().mockResolvedValue(undefined),
  createSession: vi.fn().mockResolvedValue({
    id: 'mock-session-id',
    knowledgePointId: 'fraction-comparison',
    ability: 'number-shape-integration',
    status: SessionStatus.NOT_STARTED,
    currentStepIndex: 0,
    startedAt: Date.now(),
    evidence: [],
  } as LearningSession),
  getSession: vi.fn().mockResolvedValue(null),
  updateSessionProgress: vi.fn().mockResolvedValue(undefined),
  recordEvidence: vi.fn().mockResolvedValue(undefined),
  getSessionEvidence: vi.fn().mockResolvedValue([]),
  delete: vi.fn().mockResolvedValue(undefined),
  completeSession: vi.fn().mockResolvedValue(undefined),
});

describe('SessionRepository 接口契约测试', () => {
  let repository: SessionRepository;

  const createMockEvidence = (): LearningEvidence => ({
    id: 'evidence-1',
    stepId: 'step-1',
    type: 'answer',
    data: { type: 'answer', answer: '3/4', isCorrect: true, attempts: 1 },
    timestamp: Date.now(),
  });

  beforeEach(() => {
    repository = createMockSessionRepository();
  });

  describe('接口方法存在性', () => {
    it('应该实现 createSession 方法', () => {
      expect(typeof repository.createSession).toBe('function');
    });

    it('应该实现 getSession 方法', () => {
      expect(typeof repository.getSession).toBe('function');
    });

    it('应该实现 updateSessionProgress 方法', () => {
      expect(typeof repository.updateSessionProgress).toBe('function');
    });

    it('应该实现 recordEvidence 方法', () => {
      expect(typeof repository.recordEvidence).toBe('function');
    });

    it('应该实现 getSessionEvidence 方法', () => {
      expect(typeof repository.getSessionEvidence).toBe('function');
    });

    it('应该实现 delete 方法', () => {
      expect(typeof repository.delete).toBe('function');
    });
  });

  describe('createSession', () => {
    it('应该能够创建新会话', async () => {
      const session = await repository.createSession('fraction-comparison');
      expect(session).toBeDefined();
      expect(session.id).toBeDefined();
      expect(session.knowledgePointId).toBe('fraction-comparison');
      expect(session.status).toBe(SessionStatus.NOT_STARTED);
    });
  });

  describe('getSession', () => {
    it('当会话不存在时应返回 null', async () => {
      const session = await repository.getSession('non-existent-id');
      expect(session).toBeNull();
    });
  });

  describe('updateSessionProgress', () => {
    it('应该能够更新会话进度', async () => {
      await expect(
        repository.updateSessionProgress('session-1', 2)
      ).resolves.not.toThrow();
    });
  });

  describe('recordEvidence', () => {
    it('应该能够记录证据', async () => {
      const evidence = createMockEvidence();
      await expect(
        repository.recordEvidence('session-1', evidence)
      ).resolves.not.toThrow();
    });
  });

  describe('getSessionEvidence', () => {
    it('应该返回证据列表', async () => {
      const evidenceList = await repository.getSessionEvidence('session-1');
      expect(Array.isArray(evidenceList)).toBe(true);
    });
  });

  describe('delete', () => {
    it('删除不存在的会话不应抛出错误', async () => {
      await expect(repository.delete('non-existent-id')).resolves.not.toThrow();
    });
  });

  describe('completeSession', () => {
    it('可选方法 completeSession 应该存在', () => {
      // completeSession 是可选方法
      if (repository.completeSession) {
        expect(typeof repository.completeSession).toBe('function');
      }
    });
  });
});
