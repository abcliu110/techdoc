import { useState, useCallback, useRef } from 'react';
import type {
  StepRuntime,
  StepRuntimeState,
  InteractionEvent,
  InteractionResult,
  ValidationResult,
} from '../engine/step-runtime';
import { ConcreteRuntime } from '../engine/step-runtime';

/**
 * 步骤运行时 Hook
 */
export function useStepRuntime() {
  const [state, setState] = useState<StepRuntimeState | null>(null);
  const [isComplete, setIsComplete] = useState(false);
  const runtimeRef = useRef<StepRuntime | null>(null);

  /**
   * 初始化运行时
   */
  const initialize = useCallback((stepId: string) => {
    // 根据步骤类型创建对应的运行时
    runtimeRef.current = new ConcreteRuntime();
    setState({
      stepId,
      data: {},
      completed: false,
      hintsUsed: 0,
      attempts: 0,
    });
    setIsComplete(false);
  }, []);

  /**
   * 处理交互
   */
  const handleInteraction = useCallback(
    (interaction: InteractionEvent): InteractionResult => {
      if (!runtimeRef.current) {
        return { success: false, message: '运行时未初始化' };
      }

      const result = runtimeRef.current.handleInteraction(interaction);

      if (result.success) {
        const newState = runtimeRef.current.getState();
        setState(newState);
        setIsComplete(runtimeRef.current.isComplete());
      }

      return result;
    },
    []
  );

  /**
   * 使用提示
   */
  const useHint = useCallback(() => {
    if (!state) return;

    setState({
      ...state,
      hintsUsed: state.hintsUsed + 1,
    });
  }, [state]);

  /**
   * 验证
   */
  const validate = useCallback((): ValidationResult => {
    if (!runtimeRef.current) {
      return { valid: false, errors: ['运行时未初始化'] };
    }
    return runtimeRef.current.validate();
  }, []);

  /**
   * 重置
   */
  const reset = useCallback(() => {
    if (runtimeRef.current && state) {
      const currentState = runtimeRef.current.getState();
      runtimeRef.current.initialize({
        id: currentState.stepId,
        type: 'concrete',
        name: '',
        instruction: '',
        content: { type: 'concrete', scenario: { title: '', description: '' }, interaction: { kind: 'tap', target: '', visualType: '' } },
        completionCriteria: { type: 'interactive', config: {} },
        hintLevels: [],
        ability: 'number-shape-integration',
      } as any);
      setState(runtimeRef.current.getState());
      setIsComplete(false);
    }
  }, [state]);

  return {
    state,
    isComplete,
    initialize,
    handleInteraction,
    useHint,
    validate,
    reset,
  };
}
