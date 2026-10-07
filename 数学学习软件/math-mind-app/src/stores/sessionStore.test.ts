import { describe, it, expect, beforeEach } from 'vitest';
import { useSessionStore } from './sessionStore';
import { Ability, StepType, SessionStatus, EvidenceType } from '../domain/types';

/**
 * sessionStore 单元测试
 * @description 测试会话状态管理的核心功能
 */
describe('sessionStore', () => {
  beforeEach(() => {
    // 每个测试前重置状态
    useSessionStore.getState().reset();
  });

  describe('初始状态', () => {
    it('应该有正确的初始状态', () => {
      const state = useSessionStore.getState();
      expect(state.session).toBeNull();
      expect(state.currentStep).toBeNull();
      expect(state.steps).toEqual([]);
      expect(state.highlightedSegments).toEqual([]);
      expect(state.isLoading).toBe(false);
      expect(state.error).toBeNull();
      expect(state.showComplete).toBe(false);
      expect(state.hintLevelIndex).toBe(0);
      expect(state.feedback).toBeNull();
    });
  });

  describe('startSession', () => {
    it('应该创建新的会话', () => {
      const { startSession } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);

      const state = useSessionStore.getState();
      expect(state.session).not.toBeNull();
      expect(state.session?.knowledgePointId).toBe('test-kp-id');
      expect(state.session?.ability).toBe(Ability.NUMBER_SHAPE_INTEGRATION);
      expect(state.session?.status).toBe(SessionStatus.IN_PROGRESS);
      expect(state.session?.currentStepIndex).toBe(0);
      expect(state.session?.startedAt).toBeDefined();
      expect(state.session?.evidence).toEqual([]);
      expect(state.showComplete).toBe(false);
    });

    it('重置后应该清除会话', () => {
      const { startSession, reset } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);
      reset();

      const state = useSessionStore.getState();
      expect(state.session).toBeNull();
      expect(state.showComplete).toBe(false);
    });
  });

  describe('loadSteps', () => {
    it('应该加载步骤并设置当前步骤', () => {
      const { startSession, loadSteps } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);

      const mockSteps = [
        {
          id: 'step-1',
          type: StepType.CONCRETE,
          name: '第一步',
          instruction: '测试',
          ability: Ability.NUMBER_SHAPE_INTEGRATION,
          content: { type: 'concrete' as const, scenario: { title: 't', description: 'd', emoji: '🎂' }, interaction: { kind: 'tap' as const, target: 't', visualType: 'split-circle' as const, visualConfig: {} } },
          completionCriteria: { type: 'interactive' as const, config: { type: 'interactive' as const, requiredInteraction: 'tap-complete' } },
          hintLevels: [],
        },
        {
          id: 'step-2',
          type: StepType.PICTORIAL,
          name: '第二步',
          instruction: '测试',
          ability: Ability.NUMBER_SHAPE_INTEGRATION,
          content: { type: 'pictorial' as const, task: '测试', visualType: 'fraction-bar' as const, visualConfig: {}, outputFormat: 'select' as const },
          completionCriteria: { type: 'interactive' as const, config: { type: 'interactive' as const, requiredInteraction: 'bar-complete' } },
          hintLevels: [],
        },
      ];

      loadSteps(mockSteps);

      const state = useSessionStore.getState();
      expect(state.steps).toHaveLength(2);
      expect(state.currentStep).not.toBeNull();
      expect(state.currentStep?.id).toBe('step-1');
    });

    it('空步骤应该设置当前步骤为null', () => {
      const { startSession, loadSteps } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);
      loadSteps([]);

      const state = useSessionStore.getState();
      expect(state.steps).toEqual([]);
      expect(state.currentStep).toBeNull();
    });
  });

  describe('completeStep', () => {
    it('完成当前步骤后应进入下一步', () => {
      const { startSession, loadSteps, completeStep } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);

      const mockSteps = [
        {
          id: 'step-1',
          type: StepType.CONCRETE,
          name: '第一步',
          instruction: '测试',
          ability: Ability.NUMBER_SHAPE_INTEGRATION,
          content: { type: 'concrete' as const, scenario: { title: 't', description: 'd', emoji: '🎂' }, interaction: { kind: 'tap' as const, target: 't', visualType: 'split-circle' as const, visualConfig: {} } },
          completionCriteria: { type: 'interactive' as const, config: { type: 'interactive' as const, requiredInteraction: 'tap-complete' } },
          hintLevels: [],
        },
        {
          id: 'step-2',
          type: StepType.PICTORIAL,
          name: '第二步',
          instruction: '测试',
          ability: Ability.NUMBER_SHAPE_INTEGRATION,
          content: { type: 'pictorial' as const, task: '测试', visualType: 'fraction-bar' as const, visualConfig: {}, outputFormat: 'select' as const },
          completionCriteria: { type: 'interactive' as const, config: { type: 'interactive' as const, requiredInteraction: 'bar-complete' } },
          hintLevels: [],
        },
      ];

      loadSteps(mockSteps);
      completeStep();

      const state = useSessionStore.getState();
      expect(state.session?.currentStepIndex).toBe(1);
      expect(state.currentStep?.id).toBe('step-2');
      expect(state.session?.evidence).toHaveLength(1);
      expect(state.feedback).toBeNull();
    });

    it('完成最后一步后应显示完成页', () => {
      const { startSession, loadSteps, completeStep } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);

      const mockSteps = [
        {
          id: 'step-1',
          type: StepType.CONCRETE,
          name: '第一步',
          instruction: '测试',
          ability: Ability.NUMBER_SHAPE_INTEGRATION,
          content: { type: 'concrete' as const, scenario: { title: 't', description: 'd', emoji: '🎂' }, interaction: { kind: 'tap' as const, target: 't', visualType: 'split-circle' as const, visualConfig: {} } },
          completionCriteria: { type: 'interactive' as const, config: { type: 'interactive' as const, requiredInteraction: 'tap-complete' } },
          hintLevels: [],
        },
      ];

      loadSteps(mockSteps);
      completeStep();

      const state = useSessionStore.getState();
      expect(state.showComplete).toBe(true);
      expect(state.session?.status).toBe(SessionStatus.COMPLETED);
      expect(state.feedback?.type).toBe('success');
      expect(state.feedback?.message).toBe('恭喜你完成了本次学习！');
    });
  });

  describe('highlightSegment / unhighlightSegment / resetHighlights', () => {
    it('应该正确添加高亮', () => {
      const { highlightSegment } = useSessionStore.getState();
      highlightSegment(0);

      const state = useSessionStore.getState();
      expect(state.highlightedSegments).toContain(0);
    });

    it('应该正确移除高亮', () => {
      const { highlightSegment, unhighlightSegment } = useSessionStore.getState();
      highlightSegment(0);
      highlightSegment(1);
      unhighlightSegment(0);

      const state = useSessionStore.getState();
      expect(state.highlightedSegments).not.toContain(0);
      expect(state.highlightedSegments).toContain(1);
    });

    it('应该重置所有高亮', () => {
      const { highlightSegment, resetHighlights } = useSessionStore.getState();
      highlightSegment(0);
      highlightSegment(1);
      highlightSegment(2);
      resetHighlights();

      const state = useSessionStore.getState();
      expect(state.highlightedSegments).toEqual([]);
    });

    it('不应添加重复高亮', () => {
      const { highlightSegment } = useSessionStore.getState();
      highlightSegment(0);
      highlightSegment(0);

      const state = useSessionStore.getState();
      expect(state.highlightedSegments.filter(i => i === 0)).toHaveLength(1);
    });
  });

  describe('useHint', () => {
    it('应该返回并显示提示', () => {
      const { startSession, loadSteps, useHint } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);

      const mockSteps = [
        {
          id: 'step-1',
          type: StepType.CONCRETE,
          name: '第一步',
          instruction: '测试',
          ability: Ability.NUMBER_SHAPE_INTEGRATION,
          content: { type: 'concrete' as const, scenario: { title: 't', description: 'd', emoji: '🎂' }, interaction: { kind: 'tap' as const, target: 't', visualType: 'split-circle' as const, visualConfig: {} } },
          completionCriteria: { type: 'interactive' as const, config: { type: 'interactive' as const, requiredInteraction: 'tap-complete' } },
          hintLevels: ['这是提示1', '这是提示2'],
        },
      ];

      loadSteps(mockSteps);
      const hint = useHint();

      expect(hint).toBe('这是提示1');
      const state = useSessionStore.getState();
      expect(state.feedback?.type).toBe('hint');
      expect(state.feedback?.message).toBe('这是提示1');
      expect(state.hintLevelIndex).toBe(1);
    });

    it('提示用完后应显示信息反馈', () => {
      const { startSession, loadSteps, useHint } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);

      const mockSteps = [
        {
          id: 'step-1',
          type: StepType.CONCRETE,
          name: '第一步',
          instruction: '测试',
          ability: Ability.NUMBER_SHAPE_INTEGRATION,
          content: { type: 'concrete' as const, scenario: { title: 't', description: 'd', emoji: '🎂' }, interaction: { kind: 'tap' as const, target: 't', visualType: 'split-circle' as const, visualConfig: {} } },
          completionCriteria: { type: 'interactive' as const, config: { type: 'interactive' as const, requiredInteraction: 'tap-complete' } },
          hintLevels: ['提示1'],
        },
      ];

      loadSteps(mockSteps);
      useHint(); // 使用唯一的提示
      const hint = useHint(); // 应该返回null

      expect(hint).toBeNull();
      const state = useSessionStore.getState();
      expect(state.feedback?.type).toBe('info');
      expect(state.feedback?.message).toBe('没有更多提示了');
    });
  });

  describe('setFeedback', () => {
    it('应该设置反馈信息', () => {
      const { setFeedback } = useSessionStore.getState();
      setFeedback({ type: 'success', message: '测试成功' });

      const state = useSessionStore.getState();
      expect(state.feedback?.type).toBe('success');
      expect(state.feedback?.message).toBe('测试成功');
    });

    it('应该能够清除反馈', () => {
      const { setFeedback } = useSessionStore.getState();
      setFeedback({ type: 'success', message: '测试成功' });
      setFeedback(null);

      const state = useSessionStore.getState();
      expect(state.feedback).toBeNull();
    });
  });

  describe('pauseSession / resumeSession', () => {
    it('应该正确暂停会话', () => {
      const { startSession, pauseSession } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);
      pauseSession();

      const state = useSessionStore.getState();
      expect(state.session?.status).toBe(SessionStatus.PAUSED);
      expect(state.session?.pausedAt).toBeDefined();
    });

    it('应该正确恢复会话', () => {
      const { startSession, pauseSession, resumeSession } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);
      pauseSession();
      resumeSession();

      const state = useSessionStore.getState();
      expect(state.session?.status).toBe(SessionStatus.IN_PROGRESS);
      expect(state.session?.pausedAt).toBeUndefined();
    });
  });

  describe('abandonSession', () => {
    it('应该放弃会话并关闭完成页', () => {
      const { startSession, abandonSession } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);
      // 模拟设置showComplete
      useSessionStore.setState({ showComplete: true });
      abandonSession();

      const state = useSessionStore.getState();
      expect(state.session?.status).toBe(SessionStatus.ABANDONED);
      expect(state.showComplete).toBe(false);
    });
  });

  describe('步骤计数器行为', () => {
    it('第一步的currentStepIndex应为0，但显示时应+1', () => {
      const { startSession, loadSteps } = useSessionStore.getState();
      startSession('test-kp-id', Ability.NUMBER_SHAPE_INTEGRATION);

      const mockSteps = [
        {
          id: 'step-1',
          type: StepType.CONCRETE,
          name: '第一步',
          instruction: '测试',
          ability: Ability.NUMBER_SHAPE_INTEGRATION,
          content: { type: 'concrete' as const, scenario: { title: 't', description: 'd', emoji: '🎂' }, interaction: { kind: 'tap' as const, target: 't', visualType: 'split-circle' as const, visualConfig: {} } },
          completionCriteria: { type: 'interactive' as const, config: { type: 'interactive' as const, requiredInteraction: 'tap-complete' } },
          hintLevels: [],
        },
      ];

      loadSteps(mockSteps);

      const state = useSessionStore.getState();
      // 内部索引为0（程序员视角）
      expect(state.session?.currentStepIndex).toBe(0);
      // 显示时应该是 currentStepIndex + 1 = 1（用户视角的第一步）
      expect((state.session?.currentStepIndex ?? 0) + 1).toBe(1);
    });
  });
});
