import { describe, it, expect, beforeEach } from 'vitest';
import { ConcreteRuntime } from '../../src/engine/step-runtime/ConcreteRuntime';
import type { LearningStep, ConcreteContent } from '../../src/domain/types/learning-step';
import { StepType } from '../../src/domain/types/learning-step';

describe('ConcreteRuntime', () => {
  let runtime: ConcreteRuntime;

  const createMockStep = (overrides?: Partial<ConcreteContent>): LearningStep => ({
    id: 'step-1',
    type: StepType.CONCRETE,
    name: '具象操作',
    instruction: '请操作',
    content: {
      type: 'concrete',
      scenario: {
        title: '测试场景',
        description: '测试描述',
        emoji: '🎯',
      },
      interaction: {
        kind: 'split',
        target: '完成任务',
        visualType: 'SplitCircle',
        visualConfig: {
          circles: [
            { denominator: 2, highlighted: [0] },
          ],
        },
      },
      ...overrides,
    } as ConcreteContent,
    completionCriteria: {
      type: 'interactive' as any,
      config: { requiredInteraction: 'split' },
    },
    hintLevels: ['提示1', '提示2'],
    ability: 'visualization' as any,
  });

  beforeEach(() => {
    runtime = new ConcreteRuntime();
  });

  describe('initialize', () => {
    it('应该正确初始化运行时', () => {
      const step = createMockStep();
      runtime.initialize(step);
      const state = runtime.getState();
      expect(state.stepId).toBe('step-1');
      expect(state.completed).toBe(false);
      expect(state.hintsUsed).toBe(0);
      expect(state.attempts).toBe(0);
    });

    it('应该重置之前的状态', () => {
      const step1 = createMockStep();
      runtime.initialize(step1);
      runtime.handleInteraction({
        type: 'split',
        payload: { circleIndex: 0, segmentIndex: 0, highlighted: true },
        timestamp: Date.now(),
      });

      const step2 = createMockStep();
      runtime.initialize(step2);
      const state = runtime.getState();
      expect(state.attempts).toBe(0);
      expect(state.completed).toBe(false);
    });
  });

  describe('getState', () => {
    it('应该返回当前状态副本', () => {
      const step = createMockStep();
      runtime.initialize(step);
      const state1 = runtime.getState();
      const state2 = runtime.getState();
      expect(state1).toEqual(state2);
      expect(state1).not.toBe(state2);
    });
  });

  describe('handleInteraction', () => {
    it('当未初始化时应返回错误', () => {
      const result = runtime.handleInteraction({
        type: 'tap',
        payload: {},
        timestamp: Date.now(),
      });
      expect(result.success).toBe(false);
      expect(result.message).toContain('未初始化');
    });

    describe('tap 交互', () => {
      it('应该正确处理 tap 交互', () => {
        const step = createMockStep({
          interaction: { kind: 'tap', target: '点击', visualType: 'Tap', visualConfig: {} },
        });
        runtime.initialize(step);
        const result = runtime.handleInteraction({
          type: 'tap',
          payload: { x: 100, y: 200 },
          timestamp: Date.now(),
        });
        expect(result.success).toBe(true);
        const state = runtime.getState();
        expect(state.data.lastTap).toEqual({ x: 100, y: 200 });
      });

      it('当交互类型不匹配时应返回错误', () => {
        const step = createMockStep({
          interaction: { kind: 'tap', target: '点击', visualType: 'Tap', visualConfig: {} },
        });
        runtime.initialize(step);
        const result = runtime.handleInteraction({
          type: 'drag',
          payload: {},
          timestamp: Date.now(),
        });
        expect(result.success).toBe(false);
        expect(result.message).toContain('期望交互类型');
      });
    });

    describe('drag 交互', () => {
      it('应该正确处理 drag 交互', () => {
        const step = createMockStep({
          interaction: { kind: 'drag', target: '拖拽', visualType: 'Drag', visualConfig: {} },
        });
        runtime.initialize(step);
        const result = runtime.handleInteraction({
          type: 'drag',
          payload: { fromX: 0, fromY: 0, toX: 100, toY: 100 },
          timestamp: Date.now(),
        });
        expect(result.success).toBe(true);
        const state = runtime.getState();
        expect(state.data.dragResult).toEqual({ fromX: 0, fromY: 0, toX: 100, toY: 100 });
      });
    });

    describe('split 交互', () => {
      it('应该正确处理 split 交互并记录数据', () => {
        const step = createMockStep();
        runtime.initialize(step);
        const result = runtime.handleInteraction({
          type: 'split',
          payload: { circleIndex: 0, segmentIndex: 0, highlighted: true },
          timestamp: Date.now(),
        });
        expect(result.success).toBe(true);
        const state = runtime.getState();
        expect(state.data['circle_0_segment_0']).toBe(true);
      });

      it('当完成所有预期分割时应标记为完成', () => {
        const step = createMockStep();
        runtime.initialize(step);
        const result = runtime.handleInteraction({
          type: 'split',
          payload: { circleIndex: 0, segmentIndex: 0, highlighted: true },
          timestamp: Date.now(),
        });
        expect(result.success).toBe(true);
        expect(result.message).toBe('完成！');
        expect(result.data?.completed).toBe(true);
      });

      it('当未完成所有预期分割时不应标记为完成', () => {
        const step = createMockStep({
          interaction: {
            kind: 'split',
            target: '任务',
            visualType: 'SplitCircle',
            visualConfig: {
              circles: [
                { denominator: 2, highlighted: [0, 1] },
              ],
            },
          },
        });
        runtime.initialize(step);
        const result = runtime.handleInteraction({
          type: 'split',
          payload: { circleIndex: 0, segmentIndex: 0, highlighted: true },
          timestamp: Date.now(),
        });
        expect(result.success).toBe(true);
        expect(result.message).toBeUndefined();
      });
    });

    describe('select 交互', () => {
      it('应该正确处理 select 交互', () => {
        const step = createMockStep({
          interaction: { kind: 'select', target: '选择', visualType: 'Select', visualConfig: {} },
        });
        runtime.initialize(step);
        const result = runtime.handleInteraction({
          type: 'select',
          payload: { option: 'A' },
          timestamp: Date.now(),
        });
        expect(result.success).toBe(true);
        const state = runtime.getState();
        expect(state.data.selected).toEqual({ option: 'A' });
      });
    });

    describe('attempts 计数', () => {
      it('每次交互应增加 attempts', () => {
        const step = createMockStep({
          interaction: { kind: 'tap', target: '点击', visualType: 'Tap', visualConfig: {} },
        });
        runtime.initialize(step);
        expect(runtime.getState().attempts).toBe(0);
        runtime.handleInteraction({ type: 'tap', payload: {}, timestamp: Date.now() });
        expect(runtime.getState().attempts).toBe(1);
        runtime.handleInteraction({ type: 'tap', payload: {}, timestamp: Date.now() });
        expect(runtime.getState().attempts).toBe(2);
      });
    });

    describe('不支持的交互类型', () => {
      it('当遇到不支持的交互类型时应返回错误', () => {
        const step = createMockStep();
        runtime.initialize(step);
        const result = runtime.handleInteraction({
          type: 'draw' as any,
          payload: {},
          timestamp: Date.now(),
        });
        expect(result.success).toBe(false);
        expect(result.message).toBeDefined();
      });
    });
  });

  describe('isComplete', () => {
    it('当任务未完成时应返回 false', () => {
      const step = createMockStep();
      runtime.initialize(step);
      expect(runtime.isComplete()).toBe(false);
    });

    it('当任务完成时应返回 true', () => {
      const step = createMockStep();
      runtime.initialize(step);
      runtime.handleInteraction({
        type: 'split',
        payload: { circleIndex: 0, segmentIndex: 0, highlighted: true },
        timestamp: Date.now(),
      });
      expect(runtime.isComplete()).toBe(true);
    });
  });

  describe('validate', () => {
    it('当未初始化时应返回无效', () => {
      const result = runtime.validate();
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('运行时未初始化');
    });

    it('当任务未完成时应返回无效', () => {
      const step = createMockStep();
      runtime.initialize(step);
      const result = runtime.validate();
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('请完成交互操作');
    });

    it('当任务完成时应返回有效', () => {
      const step = createMockStep();
      runtime.initialize(step);
      runtime.handleInteraction({
        type: 'split',
        payload: { circleIndex: 0, segmentIndex: 0, highlighted: true },
        timestamp: Date.now(),
      });
      const result = runtime.validate();
      expect(result.valid).toBe(true);
    });
  });
});
