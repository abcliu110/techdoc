import { describe, it, expect, beforeEach, vi } from 'vitest';
import { StartLearningSession } from '@/application/use-cases/StartLearningSession';
import { RecordEvidence } from '@/application/use-cases/RecordEvidence';
import { CompleteStep } from '@/application/use-cases/CompleteStep';
import { GetAbilityProfile } from '@/application/use-cases/GetAbilityProfile';
import { AbilityProfileService } from '@/domain/services/AbilityProfileService';
import { SessionStatus, EvidenceType, type LearningEvidence } from '@/domain/types/learning-session';
import { Ability } from '@/domain/types/ability';

/**
 * Mock Session Repository
 */
const createMockSessionRepo = () => ({
  initialize: vi.fn().mockResolvedValue(undefined),
  createSession: vi.fn().mockImplementation(async (kpId: string) => ({
    id: `session-${Date.now()}`,
    knowledgePointId: kpId,
    ability: Ability.NUMBER_SHAPE_INTEGRATION,
    status: SessionStatus.NOT_STARTED,
    currentStepIndex: 0,
    startedAt: Date.now(),
    evidence: [],
  })),
  getSession: vi.fn().mockResolvedValue(null),
  updateSessionProgress: vi.fn().mockResolvedValue(undefined),
  recordEvidence: vi.fn().mockResolvedValue(undefined),
  getSessionEvidence: vi.fn().mockResolvedValue([]),
  delete: vi.fn().mockResolvedValue(undefined),
  completeSession: vi.fn().mockResolvedValue(undefined),
});

/**
 * Mock Profile Repository
 */
const createMockProfileRepo = () => ({
  initialize: vi.fn().mockResolvedValue(undefined),
  getProfile: vi.fn().mockResolvedValue(null),
  updateProfile: vi.fn().mockResolvedValue(undefined),
});

/**
 * Mock Content Repository
 */
const createMockContentRepo = () => ({
  listKnowledgePoints: vi.fn().mockResolvedValue([]),
  findKnowledgePoint: vi.fn().mockImplementation(async (id: string) => ({
    id,
    name: '分数比较',
    description: '学习分数比较',
    ability: Ability.NUMBER_SHAPE_INTEGRATION,
    grade: 3,
    level: 1,
    prerequisites: [],
    stepCount: 3,
  })),
  findSteps: vi.fn().mockResolvedValue([
    { id: 'step-1', content: 'Step 1' },
    { id: 'step-2', content: 'Step 2' },
    { id: 'step-3', content: 'Step 3' },
  ]),
  findStep: vi.fn().mockResolvedValue(null),
});

/**
 * StartLearningSession 用例测试
 */
describe('StartLearningSession 用例', () => {
  let sessionRepo: ReturnType<typeof createMockSessionRepo>;
  let contentRepo: ReturnType<typeof createMockContentRepo>;
  let useCase: StartLearningSession;

  beforeEach(() => {
    sessionRepo = createMockSessionRepo();
    contentRepo = createMockContentRepo();
    useCase = new StartLearningSession(sessionRepo, contentRepo);

    // 设置默认的会话返回 - getSession 应该返回更新后的会话
    sessionRepo.getSession = vi.fn().mockImplementation(async (sessionId: string) => ({
      id: sessionId,
      knowledgePointId: 'fraction-comparison',
      ability: Ability.NUMBER_SHAPE_INTEGRATION,
      status: SessionStatus.IN_PROGRESS,
      currentStepIndex: 0,
      startedAt: Date.now(),
      evidence: [],
    }));
  });

  it('应该成功创建学习会话', async () => {
    const session = await useCase.execute('user-1', 'fraction-comparison');

    expect(session).toBeDefined();
    expect(session.knowledgePointId).toBe('fraction-comparison');
    expect(session.ability).toBe(Ability.NUMBER_SHAPE_INTEGRATION);
    expect(session.status).toBe(SessionStatus.IN_PROGRESS);
    expect(session.currentStepIndex).toBe(0);
    expect(session.startedAt).toBeDefined();
  });

  it('知识点不存在时应抛出错误', async () => {
    contentRepo.findKnowledgePoint = vi.fn().mockResolvedValue(null);

    await expect(useCase.execute('user-1', 'non-existent')).rejects.toThrow(
      '知识点 non-existent 不存在'
    );
  });

  it('应该调用会话仓储创建会话', async () => {
    await useCase.execute('user-1', 'fraction-comparison');

    expect(sessionRepo.createSession).toHaveBeenCalledWith('fraction-comparison');
    expect(sessionRepo.updateSessionProgress).toHaveBeenCalled();
  });
});

/**
 * RecordEvidence 用例测试
 */
describe('RecordEvidence 用例', () => {
  let sessionRepo: ReturnType<typeof createMockSessionRepo>;
  let profileRepo: ReturnType<typeof createMockProfileRepo>;
  let profileService: AbilityProfileService;
  let useCase: RecordEvidence;

  beforeEach(() => {
    sessionRepo = createMockSessionRepo();
    profileRepo = createMockProfileRepo();
    profileService = new AbilityProfileService();
    useCase = new RecordEvidence(sessionRepo, profileRepo, profileService);

    // 设置默认的会话返回
    sessionRepo.getSession = vi.fn().mockResolvedValue({
      id: 'session-1',
      knowledgePointId: 'fraction-comparison',
      ability: Ability.NUMBER_SHAPE_INTEGRATION,
      status: SessionStatus.IN_PROGRESS,
      currentStepIndex: 0,
      startedAt: Date.now(),
      evidence: [],
    });
  });

  it('应该记录证据并更新能力画像', async () => {
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

    await useCase.execute('session-1', evidence, 'user-1');

    expect(sessionRepo.recordEvidence).toHaveBeenCalledWith('session-1', evidence);
    expect(profileRepo.updateProfile).toHaveBeenCalled();
  });

  it('会话不存在时应抛出错误', async () => {
    sessionRepo.getSession = vi.fn().mockResolvedValue(null);

    await expect(
      useCase.execute('non-existent', {} as LearningEvidence, 'user-1')
    ).rejects.toThrow('会话 non-existent 不存在');
  });

  it('如果画像不存在应先创建', async () => {
    profileRepo.getProfile = vi.fn().mockResolvedValue(null);

    const evidence: LearningEvidence = {
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

    await useCase.execute('session-1', evidence, 'user-1');

    expect(profileRepo.getProfile).toHaveBeenCalledWith('user-1');
    expect(profileRepo.updateProfile).toHaveBeenCalled();
  });

  it('应该使用默认用户 ID', async () => {
    const evidence: LearningEvidence = {
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

    await useCase.execute('session-1', evidence);

    expect(profileRepo.getProfile).toHaveBeenCalledWith('default-user');
  });
});

/**
 * CompleteStep 用例测试
 */
describe('CompleteStep 用例', () => {
  let sessionRepo: ReturnType<typeof createMockSessionRepo>;
  let contentRepo: ReturnType<typeof createMockContentRepo>;
  let useCase: CompleteStep;

  beforeEach(() => {
    sessionRepo = createMockSessionRepo();
    contentRepo = createMockContentRepo();
    useCase = new CompleteStep(sessionRepo, contentRepo);

    // 设置默认的会话返回
    sessionRepo.getSession = vi.fn().mockResolvedValue({
      id: 'session-1',
      knowledgePointId: 'fraction-comparison',
      ability: Ability.NUMBER_SHAPE_INTEGRATION,
      status: SessionStatus.IN_PROGRESS,
      currentStepIndex: 0,
      startedAt: Date.now(),
      evidence: [],
    });
  });

  it('应该完成当前步骤并前进到下一步', async () => {
    const result = await useCase.execute('session-1', { success: true }, 'tap');

    expect(result.isLastStep).toBe(false);
    expect(result.session).toBeDefined();
    expect(sessionRepo.updateSessionProgress).toHaveBeenCalledWith('session-1', 1);
  });

  it('会话不存在时应抛出错误', async () => {
    sessionRepo.getSession = vi.fn().mockResolvedValue(null);

    await expect(useCase.execute('non-existent', {})).rejects.toThrow(
      '会话 non-existent 不存在'
    );
  });

  it('最后一步完成后应标记为最后一步', async () => {
    sessionRepo.getSession = vi.fn().mockResolvedValue({
      id: 'session-1',
      knowledgePointId: 'fraction-comparison',
      ability: Ability.NUMBER_SHAPE_INTEGRATION,
      status: SessionStatus.IN_PROGRESS,
      currentStepIndex: 2, // 最后一步
      startedAt: Date.now(),
      evidence: [],
    });

    const result = await useCase.execute('session-1', { success: true }, 'tap');

    expect(result.isLastStep).toBe(true);
    expect(sessionRepo.completeSession).toHaveBeenCalledWith('session-1');
  });

  it('应该记录操作证据', async () => {
    await useCase.execute('session-1', { dragPosition: { x: 100, y: 200 } }, 'drag');

    expect(sessionRepo.recordEvidence).toHaveBeenCalled();
    const calledEvidence = (sessionRepo.recordEvidence as ReturnType<typeof vi.fn>).mock.calls[0][1];
    expect(calledEvidence.type).toBe(EvidenceType.OPERATION);
    expect(calledEvidence.data.interactionKind).toBe('drag');
  });

  it('应该支持不同的交互类型', async () => {
    const interactionTypes = ['drag', 'tap', 'draw', 'split', 'select'] as const;

    for (const kind of interactionTypes) {
      sessionRepo.recordEvidence = vi.fn();
      sessionRepo.updateSessionProgress = vi.fn();
      sessionRepo.getSession = vi.fn().mockResolvedValue({
        id: 'session-1',
        knowledgePointId: 'fraction-comparison',
        ability: Ability.NUMBER_SHAPE_INTEGRATION,
        status: SessionStatus.IN_PROGRESS,
        currentStepIndex: 0,
        startedAt: Date.now(),
        evidence: [],
      });

      await useCase.execute('session-1', { result: true }, kind);

      const calledEvidence = (sessionRepo.recordEvidence as ReturnType<typeof vi.fn>).mock.calls[0][1];
      expect(calledEvidence.data.interactionKind).toBe(kind);
    }
  });
});

/**
 * GetAbilityProfile 用例测试
 */
describe('GetAbilityProfile 用例', () => {
  let profileRepo: ReturnType<typeof createMockProfileRepo>;
  let profileService: AbilityProfileService;
  let useCase: GetAbilityProfile;

  beforeEach(() => {
    profileRepo = createMockProfileRepo();
    profileService = new AbilityProfileService();
    useCase = new GetAbilityProfile(profileRepo, profileService);
  });

  it('应该返回能力画像结果', async () => {
    const profile = profileService.createProfile('user-1');
    profileRepo.getProfile = vi.fn().mockResolvedValue(profile);

    const result = await useCase.execute('user-1');

    expect(result.abilities).toHaveLength(5);
    expect(result.radarData).toHaveLength(5);
    expect(result.trend).toBeDefined();
  });

  it('画像不存在时应创建新画像', async () => {
    profileRepo.getProfile = vi.fn().mockResolvedValue(null);

    const result = await useCase.execute('user-1');

    expect(profileRepo.updateProfile).toHaveBeenCalled();
    expect(result.abilities).toHaveLength(5);
  });

  it('应该返回正确的雷达图数据格式', async () => {
    const profile = profileService.createProfile('user-1');
    profileRepo.getProfile = vi.fn().mockResolvedValue(profile);

    const result = await useCase.execute('user-1');

    result.radarData.forEach((point) => {
      expect(point).toHaveProperty('ability');
      expect(point).toHaveProperty('level');
      expect(point).toHaveProperty('maxLevel');
      expect(point).toHaveProperty('label');
    });
  });

  it('应该返回中文标签', async () => {
    const profile = profileService.createProfile('user-1');
    profileRepo.getProfile = vi.fn().mockResolvedValue(profile);

    const result = await useCase.execute('user-1');

    const labels = result.radarData.map((p) => p.label);
    expect(labels).toContain('数形结合');
    expect(labels).toContain('单位统一');
    expect(labels).toContain('整体部分');
    expect(labels).toContain('转化化归');
    expect(labels).toContain('等量关系');
  });

  it('应该使用默认用户 ID', async () => {
    profileRepo.getProfile = vi.fn().mockResolvedValue(null);

    await useCase.execute();

    expect(profileRepo.getProfile).toHaveBeenCalledWith('default-user');
  });
});
