/**
 * 数学思维启发学习系统 - 学习步骤Schema
 * @description 定义学习步骤的运行时状态、交互状态和步骤执行逻辑
 */

import { z } from 'zod';

// ==================== 步骤状态枚举 ====================

/** 步骤状态枚举 */
export const StepStatusEnum = z.enum([
  'locked',       // 锁定（前置条件未满足）
  'available',    // 可用（可以进入）
  'active',       // 激活（正在进行）
  'completed',    // 完成
  'skipped',      // 跳过
  'failed'        // 失败（超时或无法完成）
]);
export type StepStatus = z.infer<typeof StepStatusEnum>;

/** 交互状态枚举 */
export const InteractionStateEnum = z.enum([
  'idle',         // 空闲（等待用户操作）
  'pending',      // 待确认（有输入未提交）
  'validating',   // 验证中
  'correct',      // 正确
  'incorrect',    // 错误
  'hint_requested' // 请求提示
]);
export type InteractionState = z.infer<typeof InteractionStateEnum>;

/** 输入类型枚举 */
export const InputTypeEnum = z.enum([
  'number',       // 数值输入
  'text',         // 文本输入
  'choice',       // 选项选择
  'order',        // 排序输入
  'drag',         // 拖拽输入
  'none'          // 无输入（仅展示）
]);
export type InputType = z.infer<typeof InputTypeEnum>;

// ==================== 交互记录 ====================

/** 单次交互记录 */
export const InteractionAttemptSchema = z.object({
  /** 尝试ID */
  attemptId: z.string(),
  /** 尝试序号（1-based） */
  attemptNumber: z.number().int().min(1),
  /** 用户输入值 */
  userInput: z.unknown(),
  /** 是否正确 */
  isCorrect: z.boolean(),
  /** 正确值（用于展示） */
  correctValue: z.unknown().optional(),
  /** 用时（毫秒） */
  duration: z.number().int().min(0),
  /** 时间戳 */
  timestamp: z.string().datetime(),
  /** 是否使用了提示 */
  usedHint: z.boolean().default(false),
  /** 错误类型（如果有） */
  errorType: z.string().optional()
});
export type InteractionAttempt = z.infer<typeof InteractionAttemptSchema>;

// ==================== 步骤运行时 ====================

/** 步骤运行时状态 */
export const StepRuntimeStateSchema = z.object({
  /** 运行时ID */
  runtimeId: z.string(),
  /** 会话ID */
  sessionId: z.string(),
  /** 步骤ID（内容定义） */
  stepId: z.string(),
  /** 步骤状态 */
  status: StepStatusEnum,
  /** 交互状态 */
  interactionState: InteractionStateEnum,
  /** 输入类型 */
  inputType: InputTypeEnum,

  /** 进入时间 */
  enteredAt: z.string().datetime(),
  /** 开始交互时间 */
  interactionStartedAt: z.string().datetime().optional(),
  /** 提交时间 */
  submittedAt: z.string().datetime().optional(),
  /** 完成时间 */
  completedAt: z.string().datetime().optional(),

  /** 当前尝试序号 */
  currentAttemptNumber: z.number().int().min(1).default(1),
  /** 最大尝试次数 */
  maxAttempts: z.number().int().min(1).default(3),
  /** 剩余尝试次数 */
  remainingAttempts: z.number().int().min(0),

  /** 用户输入 */
  userInput: z.unknown().optional(),
  /** 当前答案是否正确 */
  currentIsCorrect: z.boolean().optional(),
  /** 是否请求了提示 */
  hintRequested: z.boolean().default(false),
  /** 当前提示级别 */
  currentHintLevel: z.number().int().min(0).default(0),

  /** 历史尝试记录 */
  attemptHistory: z.array(InteractionAttemptSchema).default([]),

  /** 该步骤总用时（毫秒） */
  totalDuration: z.number().int().min(0).default(0),
  /** 该步骤正确次数 */
  correctCount: z.number().int().min(0).default(0),
  /** 该步骤错误次数 */
  incorrectCount: z.number().int().min(0).default(0),

  /** 步骤特定数据（可视化状态等） */
  stepData: z.record(z.unknown()).default({}),

  /** 自动进入下一步的计时器（毫秒） */
  autoAdvanceTimer: z.number().int().min(0).default(0),
  /** 是否已触发自动进入 */
  autoAdvanceTriggered: z.boolean().default(false),

  /** 暂停时间（毫秒） */
  pausedDuration: z.number().int().min(0).default(0)
});
export type StepRuntimeState = z.infer<typeof StepRuntimeStateSchema>;

// ==================== 步骤执行上下文 ====================

/** 步骤执行上下文 */
export const StepExecutionContextSchema = z.object({
  /** 会话ID */
  sessionId: z.string(),
  /** 用户ID */
  userId: z.string(),
  /** 内容包ID */
  packageId: z.string(),
  /** 知识点ID */
  kpId: z.string(),

  /** 当前步骤 */
  currentStep: z.object({
    stepId: z.string(),
    stepType: z.string(),
    title: z.string()
  }),
  /** 上一步（如果有） */
  previousStep: z.object({
    stepId: z.string(),
    wasCompleted: z.boolean(),
    wasSkipped: z.boolean()
  }).optional(),
  /** 下一步（如果有） */
  nextStep: z.object({
    stepId: z.string(),
    isAvailable: z.boolean()
  }).optional(),

  /** 步骤完成历史 */
  completedSteps: z.array(z.string()),
  /** 步骤跳过历史 */
  skippedSteps: z.array(z.string()),

  /** 用户答题表现统计 */
  performance: z.object({
    totalAttempts: z.number().int().min(0),
    correctAttempts: z.number().int().min(0),
    firstAttemptAccuracy: z.number().min(0).max(1)
  }),

  /** 剩余时间（毫秒），0表示不限制 */
  remainingTime: z.number().int().min(0).default(0),
  /** 是否超时 */
  isTimedOut: z.boolean().default(false),

  /** 步骤特定变量（用于条件逻辑） */
  stepVariables: z.record(z.unknown()).default({})
});
export type StepExecutionContext = z.infer<typeof StepExecutionContextSchema>;

// ==================== 步骤转换 ====================

/** 步骤转换规则 */
export const StepTransitionSchema = z.object({
  /** 从步骤ID */
  fromStepId: z.string(),
  /** 到步骤ID */
  toStepId: z.string(),
  /** 转换条件类型 */
  conditionType: z.enum([
    'always',           // 总是转换
    'on_completion',    // 完成时转换
    'on_correct',       // 正确时转换
    'on_incorrect',     // 错误时转换
    'on_time',          // 特定时间后转换
    'on_attempts',      // 特定尝试次数后转换
    'on_variable'       // 变量满足条件时转换
  ]),
  /** 条件参数 */
  conditionParams: z.record(z.unknown()).optional(),
  /** 转换动画类型 */
  transitionAnimation: z.enum([
    'none',
    'slide_left',
    'slide_right',
    'fade',
    'zoom'
  ]).default('none'),
  /** 延迟时间（毫秒） */
  delayMs: z.number().int().min(0).default(0)
});
export type StepTransition = z.infer<typeof StepTransitionSchema>;

