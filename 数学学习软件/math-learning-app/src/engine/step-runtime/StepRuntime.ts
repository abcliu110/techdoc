import type { LearningStep } from '../../domain/types/learning-step';

/**
 * 步骤运行时接口
 */
export interface StepRuntime {
  /**
   * 初始化运行时
   */
  initialize(step: LearningStep): void;

  /**
   * 获取当前状态
   */
  getState(): StepRuntimeState;

  /**
   * 处理用户交互
   */
  handleInteraction(interaction: InteractionEvent): InteractionResult;

  /**
   * 检查是否完成
   */
  isComplete(): boolean;

  /**
   * 获取验证结果
   */
  validate(): ValidationResult;
}

/**
 * 步骤运行时状态
 */
export interface StepRuntimeState {
  stepId: string;
  data: Record<string, unknown>;
  completed: boolean;
  hintsUsed: number;
  attempts: number;
}

/**
 * 交互事件
 */
export interface InteractionEvent {
  type: 'tap' | 'drag' | 'draw' | 'split' | 'select' | 'input';
  payload: Record<string, unknown>;
  timestamp: number;
}

/**
 * 交互结果
 */
export interface InteractionResult {
  success: boolean;
  message?: string;
  data?: Record<string, unknown>;
}

/**
 * 验证结果
 */
export interface ValidationResult {
  valid: boolean;
  errors?: string[];
}
