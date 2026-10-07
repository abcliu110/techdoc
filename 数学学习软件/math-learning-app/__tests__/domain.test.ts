import { describe, it, expect, beforeEach, vi } from 'vitest';
import { LearningSessionService } from '@/domain/services/LearningSessionService';
import { AbilityProfileService } from '@/domain/services/AbilityProfileService';
import { SessionStatus, LearningEvidence, EvidenceType } from '@/domain/types/learning-session';
import { Ability, AbilityLevel } from '@/domain/types/ability';

/**
 * 会话创建和保存测试
 */
describe('会话创建和保存', () => {
  let sessionService: LearningSessionService;
  let profileService: AbilityProfileService;

  beforeEach(() => {
    sessionService = new LearningSessionService();
    profileService = new AbilityProfileService();
  });

  describe('LearningSessionService', () => {
    it('应该创建一个新的学习会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );

      expect(session.id).toBe('session-1');
      expect(session.knowledgePointId).toBe('fraction-comparison');
      expect(session.ability).toBe(Ability.NUMBER_SHAPE_INTEGRATION);
      expect(session.status).toBe(SessionStatus.NOT_STARTED);
      expect(session.currentStepIndex).toBe(0);
      expect(session.evidence).toEqual([]);
    });

    it('应该开始一个未开始的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );

      const startedSession = sessionService.start(session);

      expect(startedSession.status).toBe(SessionStatus.IN_PROGRESS);
      expect(startedSession.startedAt).toBeDefined();
    });

    it('不应该启动非 NOT_STARTED 状态的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );
      const startedSession = sessionService.start(session);

      expect(() => sessionService.start(startedSession)).toThrow('会话已启动或已完成');
    });

    it('应该完成一个进行中的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );
      const startedSession = sessionService.start(session);
      const completedSession = sessionService.complete(startedSession);

      expect(completedSession.status).toBe(SessionStatus.COMPLETED);
      expect(completedSession.completedAt).toBeDefined();
    });

    it('不应该完成非进行中的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );

      expect(() => sessionService.complete(session)).toThrow('会话不在进行中，无法完成');
    });
  });
});

/**
 * 会话恢复逻辑测试
 */
describe('会话恢复逻辑', () => {
  let sessionService: LearningSessionService;

  beforeEach(() => {
    sessionService = new LearningSessionService();
  });

  describe('暂停和恢复', () => {
    it('应该正确暂停一个进行中的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );
      const startedSession = sessionService.start(session);
      const pausedSession = sessionService.pause(startedSession);

      expect(pausedSession.status).toBe(SessionStatus.PAUSED);
      expect(pausedSession.pausedAt).toBeDefined();
      expect(pausedSession.snapshot).toBeDefined();
      expect(pausedSession.snapshot?.stepIndex).toBe(0);
    });

    it('应该正确恢复一个暂停的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );
      const startedSession = sessionService.start(session);
      const pausedSession = sessionService.pause(startedSession);
      const resumedSession = sessionService.resume(pausedSession);

      expect(resumedSession.status).toBe(SessionStatus.IN_PROGRESS);
      expect(resumedSession.pausedAt).toBeUndefined();
      expect(resumedSession.snapshot).toBeUndefined();
    });

    it('不应该暂停非进行中的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );

      expect(() => sessionService.pause(session)).toThrow('会话不在进行中，无法暂停');
    });

    it('不应该恢复非暂停的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );
      sessionService.start(session);

      expect(() => sessionService.resume(session)).toThrow('会话不在暂停状态，无法恢复');
    });

    it('应该保存暂停时的快照数据', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );
      // 必须先启动会话才能暂停
      const startedSession = sessionService.start(session);
      const stepData = { circleCount: 2, splitCount: 4 };
      const pausedSession = sessionService.pause(startedSession, {
        stepIndex: 3,
        stepData,
        timestamp: Date.now(),
      });

      expect(pausedSession.snapshot?.stepIndex).toBe(3);
      expect(pausedSession.snapshot?.stepData).toEqual(stepData);
    });
  });

  describe('放弃会话', () => {
    it('应该正确放弃一个进行中的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );
      const startedSession = sessionService.start(session);
      const abandonedSession = sessionService.abandon(startedSession);

      expect(abandonedSession.status).toBe(SessionStatus.ABANDONED);
      expect(abandonedSession.completedAt).toBeDefined();
    });

    it('不应该放弃已完成的会话', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );
      const startedSession = sessionService.start(session);
      const completedSession = sessionService.complete(startedSession);

      expect(() => sessionService.abandon(completedSession)).toThrow('会话已完成或已放弃');
    });
  });
});

/**
 * 证据记录和查询测试
 */
describe('证据记录和查询', () => {
  let sessionService: LearningSessionService;

  beforeEach(() => {
    sessionService = new LearningSessionService();
  });

  describe('添加证据', () => {
    it('应该向会话添加证据', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );

      const evidence: LearningEvidence = {
        id: 'evidence-1',
        stepId: 'step-1',
        type: EvidenceType.OPERATION,
        data: {
          type: EvidenceType.OPERATION,
          interactionKind: 'tap',
          result: { success: true },
          attempts: 1,
        },
        timestamp: Date.now(),
      };

      const sessionWithEvidence = sessionService.addEvidence(session, evidence);

      expect(sessionWithEvidence.evidence).toHaveLength(1);
      expect(sessionWithEvidence.evidence[0].id).toBe('evidence-1');
    });

    it('应该保留原有的证据并添加新证据', () => {
      const session = sessionService.createSession(
        'session-1',
        'fraction-comparison',
        Ability.NUMBER_SHAPE_INTEGRATION
      );

      const evidence1: LearningEvidence = {
        id: 'evidence-1',
        stepId: 'step-1',
        type: EvidenceType.OPERATION,
        data: {
          type: EvidenceType.OPERATION,
          interactionKind: 'tap',
          result: {},
          attempts: 1,
        },
        timestamp: Date.now(),
      };

      const evidence2: LearningEvidence = {
        id: 'evidence-2',
        stepId: 'step-2',
        type: EvidenceType.ANSWER,
        data: {
          type: EvidenceType.ANSWER,
          answer: '2/4',
          isCorrect: true,
          attempts: 1,
        },
        timestamp: Date.now() + 1000,
      };

      let sessionWithEvidence = sessionService.addEvidence(session, evidence1);
      sessionWithEvidence = sessionService.addEvidence(sessionWithEvidence, evidence2);

      expect(sessionWithEvidence.evidence).toHaveLength(2);
      expect(sessionWithEvidence.evidence[0].id).toBe('evidence-1');
      expect(sessionWithEvidence.evidence[1].id).toBe('evidence-2');
    });
  });

  describe('证据类型', () => {
    it('应该支持操作证据', () => {
      const evidence: LearningEvidence = {
        id: 'evidence-1',
        stepId: 'step-1',
        type: EvidenceType.OPERATION,
        data: {
          type: EvidenceType.OPERATION,
          interactionKind: 'drag',
          result: { position: { x: 100, y: 200 } },
          attempts: 2,
        },
        timestamp: Date.now(),
      };

      expect(evidence.type).toBe(EvidenceType.OPERATION);
      expect(evidence.data.type).toBe(EvidenceType.OPERATION);
    });

    it('应该支持答案证据', () => {
      const evidence: LearningEvidence = {
        id: 'evidence-1',
        stepId: 'step-1',
        type: EvidenceType.ANSWER,
        data: {
          type: EvidenceType.ANSWER,
          answer: '1/2',
          isCorrect: true,
          attempts: 1,
        },
        timestamp: Date.now(),
      };

      expect(evidence.type).toBe(EvidenceType.ANSWER);
      expect(evidence.data.type).toBe(EvidenceType.ANSWER);
    });

    it('应该支持提示使用证据', () => {
      const evidence: LearningEvidence = {
        id: 'evidence-1',
        stepId: 'step-1',
        type: EvidenceType.HINT_USAGE,
        data: {
          type: EvidenceType.HINT_USAGE,
          hintsUsed: 2,
          hintLevels: ['level-1', 'level-2'],
        },
        timestamp: Date.now(),
      };

      expect(evidence.type).toBe(EvidenceType.HINT_USAGE);
      expect(evidence.data.type).toBe(EvidenceType.HINT_USAGE);
    });

    it('应该支持迁移表现证据', () => {
      const evidence: LearningEvidence = {
        id: 'evidence-1',
        stepId: 'step-1',
        type: EvidenceType.TRANSFER,
        data: {
          type: EvidenceType.TRANSFER,
          originalProblem: '比较 1/2 和 2/4',
          transferredProblem: '比较 3/6 和 4/8',
          success: true,
        },
        timestamp: Date.now(),
      };

      expect(evidence.type).toBe(EvidenceType.TRANSFER);
      expect(evidence.data.type).toBe(EvidenceType.TRANSFER);
    });
  });
});

/**
 * 能力画像更新测试
 */
describe('能力画像更新', () => {
  let profileService: AbilityProfileService;

  beforeEach(() => {
    profileService = new AbilityProfileService();
  });

  describe('创建能力画像', () => {
    it('应该创建一个新的能力画像', () => {
      const profile = profileService.createProfile('user-1');

      expect(profile.userId).toBe('user-1');
      expect(profile.states).toHaveLength(5); // 5 种能力
      expect(profile.states.every((s) => s.level === AbilityLevel.NOT_STARTED)).toBe(true);
      expect(profile.states.every((s) => s.evidenceCount === 0)).toBe(true);
      expect(profile.totalEvidence).toEqual([]);
    });

    it('应该为所有能力类型创建初始状态', () => {
      const profile = profileService.createProfile('user-1');
      const abilities = profile.states.map((s) => s.ability);

      expect(abilities).toContain(Ability.NUMBER_SHAPE_INTEGRATION);
      expect(abilities).toContain(Ability.UNIT_UNIFICATION);
      expect(abilities).toContain(Ability.WHOLE_PART_THINKING);
      expect(abilities).toContain(Ability.TRANSFORMATION);
      expect(abilities).toContain(Ability.EQUATION_REASONING);
    });
  });

  describe('能力等级计算', () => {
    it('无证据时应为 NOT_STARTED', () => {
      const profile = profileService.createProfile('user-1');
      const updatedProfile = profileService.updateAbilityLevel(
        profile,
        Ability.NUMBER_SHAPE_INTEGRATION,
        []
      );

      const state = updatedProfile.states.find(
        (s) => s.ability === Ability.NUMBER_SHAPE_INTEGRATION
      );
      expect(state?.level).toBe(AbilityLevel.NOT_STARTED);
    });

    it('有操作证据时应为 AWARE', () => {
      const profile = profileService.createProfile('user-1');
      const evidence: LearningEvidence[] = [
        {
          id: 'e1',
          stepId: 's1',
          type: EvidenceType.OPERATION,
          data: { type: EvidenceType.OPERATION, interactionKind: 'tap', result: {}, attempts: 1 },
          timestamp: Date.now(),
        },
      ];

      const updatedProfile = profileService.updateAbilityLevel(
        profile,
        Ability.NUMBER_SHAPE_INTEGRATION,
        evidence
      );

      const state = updatedProfile.states.find(
        (s) => s.ability === Ability.NUMBER_SHAPE_INTEGRATION
      );
      expect(state?.level).toBe(AbilityLevel.AWARE);
      expect(state?.evidenceCount).toBe(1);
    });

    it('有答案证据且正确率 >= 50% 时应为 DEVELOPING', () => {
      const profile = profileService.createProfile('user-1');
      const evidence: LearningEvidence[] = [
        {
          id: 'e1',
          stepId: 's1',
          type: EvidenceType.ANSWER,
          data: { type: EvidenceType.ANSWER, answer: '1/2', isCorrect: true, attempts: 1 },
          timestamp: Date.now(),
        },
        {
          id: 'e2',
          stepId: 's1',
          type: EvidenceType.ANSWER,
          data: { type: EvidenceType.ANSWER, answer: '2/4', isCorrect: false, attempts: 1 },
          timestamp: Date.now(),
        },
      ];

      const updatedProfile = profileService.updateAbilityLevel(
        profile,
        Ability.NUMBER_SHAPE_INTEGRATION,
        evidence
      );

      const state = updatedProfile.states.find(
        (s) => s.ability === Ability.NUMBER_SHAPE_INTEGRATION
      );
      expect(state?.level).toBe(AbilityLevel.DEVELOPING);
    });

    it('有迁移证据且正确率 >= 80% 时应为 MASTERED', () => {
      const profile = profileService.createProfile('user-1');
      const evidence: LearningEvidence[] = [
        {
          id: 'e1',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
        {
          id: 'e2',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
        {
          id: 'e3',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
        {
          id: 'e4',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
        {
          id: 'e5',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: false,
          },
          timestamp: Date.now(),
        },
      ];

      const updatedProfile = profileService.updateAbilityLevel(
        profile,
        Ability.NUMBER_SHAPE_INTEGRATION,
        evidence
      );

      const state = updatedProfile.states.find(
        (s) => s.ability === Ability.NUMBER_SHAPE_INTEGRATION
      );
      expect(state?.level).toBe(AbilityLevel.MASTERED);
    });

    it('正确率低于 50% 时不应达到 DEVELOPING', () => {
      // 准备完整证据列表：先有操作证据达到 AWARE，然后低正确率答案
      const allEvidence: LearningEvidence[] = [
        // 操作证据
        {
          id: 'e0',
          stepId: 's0',
          type: EvidenceType.OPERATION,
          data: { type: EvidenceType.OPERATION, interactionKind: 'tap', result: {}, attempts: 1 },
          timestamp: Date.now(),
        },
        // 低正确率答案证据
        {
          id: 'e1',
          stepId: 's1',
          type: EvidenceType.ANSWER,
          data: { type: EvidenceType.ANSWER, answer: '1/2', isCorrect: false, attempts: 1 },
          timestamp: Date.now(),
        },
        {
          id: 'e2',
          stepId: 's1',
          type: EvidenceType.ANSWER,
          data: { type: EvidenceType.ANSWER, answer: '2/4', isCorrect: false, attempts: 1 },
          timestamp: Date.now(),
        },
      ];

      const profile = profileService.createProfile('user-1');
      const updatedProfile = profileService.updateAbilityLevel(
        profile,
        Ability.NUMBER_SHAPE_INTEGRATION,
        allEvidence
      );

      const state = updatedProfile.states.find(
        (s) => s.ability === Ability.NUMBER_SHAPE_INTEGRATION
      );
      // 正确率 0/2 = 0% < 50%，不应达到 DEVELOPING (2)
      // 但因为有操作证据，应该达到 AWARE (1)
      expect(state?.level).toBe(AbilityLevel.AWARE);
    });

    it('应该更新 lastPracticedAt', () => {
      const before = Date.now();
      const profile = profileService.createProfile('user-1');
      const evidence: LearningEvidence[] = [
        {
          id: 'e1',
          stepId: 's1',
          type: EvidenceType.OPERATION,
          data: { type: EvidenceType.OPERATION, interactionKind: 'tap', result: {}, attempts: 1 },
          timestamp: Date.now(),
        },
      ];

      const updatedProfile = profileService.updateAbilityLevel(
        profile,
        Ability.NUMBER_SHAPE_INTEGRATION,
        evidence
      );

      const state = updatedProfile.states.find(
        (s) => s.ability === Ability.NUMBER_SHAPE_INTEGRATION
      );
      expect(state?.lastPracticedAt).toBeGreaterThanOrEqual(before);
    });

    it('应该保留其他能力的等级', () => {
      // 创建只有一种能力证据的 profile
      const profile = profileService.createProfile('user-1');
      const numberShapeEvidence: LearningEvidence[] = [
        {
          id: 'e1',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
        {
          id: 'e2',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
        {
          id: 'e3',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
        {
          id: 'e4',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
        {
          id: 'e5',
          stepId: 's1',
          type: EvidenceType.TRANSFER,
          data: {
            type: EvidenceType.TRANSFER,
            originalProblem: 'a',
            transferredProblem: 'b',
            success: true,
          },
          timestamp: Date.now(),
        },
      ];

      // 先更新 NUMBER_SHAPE_INTEGRATION 能力到 MASTERED
      const profileAfterNumberShape = profileService.updateAbilityLevel(
        profile,
        Ability.NUMBER_SHAPE_INTEGRATION,
        numberShapeEvidence
      );

      // 验证 NUMBER_SHAPE_INTEGRATION 达到 MASTERED
      const numberShapeState = profileAfterNumberShape.states.find(
        (s) => s.ability === Ability.NUMBER_SHAPE_INTEGRATION
      );
      expect(numberShapeState?.level).toBe(AbilityLevel.MASTERED);

      // 验证 UNIT_UNIFICATION 保持 NOT_STARTED
      const unitUnificationState = profileAfterNumberShape.states.find(
        (s) => s.ability === Ability.UNIT_UNIFICATION
      );
      expect(unitUnificationState?.level).toBe(AbilityLevel.NOT_STARTED);

      // 再更新 UNIT_UNIFICATION 能力
      const unitUnificationEvidence: LearningEvidence[] = [
        {
          id: 'e6',
          stepId: 's1',
          type: EvidenceType.OPERATION,
          data: { type: EvidenceType.OPERATION, interactionKind: 'tap', result: {}, attempts: 1 },
          timestamp: Date.now(),
        },
      ];

      // 需要传入 NUMBER_SHAPE_INTEGRATION 的证据以保留其等级
      const finalProfile = profileService.updateAbilityLevel(
        profileAfterNumberShape,
        Ability.UNIT_UNIFICATION,
        unitUnificationEvidence
      );

      // 验证两个能力的状态都正确
      const finalNumberShape = finalProfile.states.find(
        (s) => s.ability === Ability.NUMBER_SHAPE_INTEGRATION
      );
      const finalUnitUnification = finalProfile.states.find(
        (s) => s.ability === Ability.UNIT_UNIFICATION
      );

      expect(finalNumberShape?.level).toBe(AbilityLevel.MASTERED);
      expect(finalUnitUnification?.level).toBe(AbilityLevel.AWARE);
    });
  });
});
