import { describe, it, expect, beforeEach } from 'vitest';
import { useSessionStore } from '../../src/stores/sessionStore';
import type { LearningSession } from '../../src/domain/types/learning-session';
import { SessionStatus } from '../../src/domain/types/learning-session';
import type { LearningStep } from '../../src/domain/types/learning-step';
import { StepType } from '../../src/domain/types/learning-step';

// 创建模拟步骤
const createMockStep = (id: string, type: StepType = StepType.CONCRETE): LearningStep => ({
  id,
  type,
  name: `Step ${id}`,
  instruction: `Instruction for ${id}`,
  content: {
    type: 'concrete',
    scenario: { title: 'Test', description: 'Test', emoji: '📝' },
    interaction: { kind: 'split', target: 'Test', visualType: 'split-circle', visualConfig: {} },
  },
  completionCriteria: { type: 'interactive', config: { requiredInteraction: 'test' } },
  hintLevels: ['Hint 1'],
  ability: 'number-shape-integration',
});

// 创建模拟会话
const createMockSession = (currentStepIndex = 0): LearningSession => ({
  id: 'test-session',
  knowledgePointId: 'fraction-comparison',
  currentStepIndex,
  status: SessionStatus.IN_PROGRESS,
  startedAt: Date.now(),
  ability: 'number-shape-integration',
});

describe('SessionStore', () => {
  beforeEach(() => {
    // 重置 store
    useSessionStore.getState().reset();
  });

  it('应该正确初始化', () => {
    const state = useSessionStore.getState();
    expect(state.session).toBeNull();
    expect(state.currentStep).toBeNull();
    expect(state.steps).toEqual([]);
    expect(state.showComplete).toBe(false);
  });

  it('应该正确启动会话并设置第一步', () => {
    const steps = [
      createMockStep('step-1'),
      createMockStep('step-2'),
      createMockStep('step-3'),
    ];
    const session = createMockSession(0);

    useSessionStore.getState().startSession(session, steps);

    const state = useSessionStore.getState();
    expect(state.session).toEqual(session);
    expect(state.currentStep).toEqual(steps[0]);
    expect(state.steps).toEqual(steps);
    expect(state.showComplete).toBe(false);
  });

  it('应该正确完成第一步并进入第二步', () => {
    const steps = [
      createMockStep('step-1'),
      createMockStep('step-2'),
      createMockStep('step-3'),
    ];
    const session = createMockSession(0);

    useSessionStore.getState().startSession(session, steps);

    // 完成第一步
    useSessionStore.getState().completeStep({});

    const state = useSessionStore.getState();
    expect(state.session?.currentStepIndex).toBe(1);
    expect(state.currentStep).toEqual(steps[1]);
    expect(state.showComplete).toBe(false);
  });

  it('应该正确完成第二步并进入第三步', () => {
    const steps = [
      createMockStep('step-1'),
      createMockStep('step-2'),
      createMockStep('step-3'),
    ];
    const session = createMockSession(0);

    useSessionStore.getState().startSession(session, steps);
    useSessionStore.getState().completeStep({});
    useSessionStore.getState().completeStep({});

    const state = useSessionStore.getState();
    expect(state.session?.currentStepIndex).toBe(2);
    expect(state.currentStep).toEqual(steps[2]);
    expect(state.showComplete).toBe(false);
  });

  it('应该正确完成最后一步并显示完成页', () => {
    const steps = [
      createMockStep('step-1'),
      createMockStep('step-2'),
      createMockStep('step-3'),
    ];
    const session = createMockSession(0);

    useSessionStore.getState().startSession(session, steps);
    useSessionStore.getState().completeStep({}); // step 1 -> step 2
    useSessionStore.getState().completeStep({}); // step 2 -> step 3
    useSessionStore.getState().completeStep({}); // step 3 -> complete

    const state = useSessionStore.getState();
    expect(state.session?.currentStepIndex).toBe(3);
    expect(state.session?.status).toBe(SessionStatus.COMPLETED);
    expect(state.currentStep).toBeNull();
    expect(state.showComplete).toBe(true);
  });

  it('应该正确处理单步骤知识点', () => {
    const steps = [createMockStep('step-1')];
    const session = createMockSession(0);

    useSessionStore.getState().startSession(session, steps);

    // 完成唯一步骤
    useSessionStore.getState().completeStep({});

    const state = useSessionStore.getState();
    expect(state.session?.currentStepIndex).toBe(1);
    expect(state.session?.status).toBe(SessionStatus.COMPLETED);
    expect(state.showComplete).toBe(true);
  });

  it('应该正确重置状态', () => {
    const steps = [createMockStep('step-1')];
    const session = createMockSession(0);

    useSessionStore.getState().startSession(session, steps);
    useSessionStore.getState().completeStep({});

    // 重置
    useSessionStore.getState().reset();

    const state = useSessionStore.getState();
    expect(state.session).toBeNull();
    expect(state.currentStep).toBeNull();
    expect(state.steps).toEqual([]);
    expect(state.showComplete).toBe(false);
  });
});
