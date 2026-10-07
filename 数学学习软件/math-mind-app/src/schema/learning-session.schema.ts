/**
 * 数学思维启发学习系统 - 学习会话Schema
 * @description 定义完整学习会话的状态、进度追踪和会话管理
 */

import { z } from 'zod';

// ==================== 会话状态枚举 ====================

/** 会话状态枚举 */
export const SessionStatusEnum = z.enum([
  'created',      // 已创建，未开始
  'in_progress',  // 进行中
  'paused',       // 已暂停
  'completed',   // 已完成
  'abandoned'     // 已放弃/超时
]);
export type SessionStatus = z.infer<typeof SessionStatusEnum>;

/** 学习阶段枚举 */
export const LearningPhaseEnum = z.enum([
  'exploration',  // 探索阶段
  'guided',       // 引导阶段
  'practice',     // 练习阶段
  'assessment',   // 评估阶段
  'reflection'    // 反思阶段
]);
export type LearningPhase = z.infer<typeof LearningPhaseEnum>;

/** 暂停原因枚举 */
export const PauseReasonEnum = z.enum([
  'user_action',      // 用户主动暂停
  'app_background',   // 应用进入后台
  'interruption',     // 被打断
  'network_issue',    // 网络问题
  'low_battery'       // 电量不足
]);
export type PauseReason = z.infer<typeof PauseReasonEnum>;

// ==================== 时间相关 ====================

/** 时间戳记录 */
export const TimestampSchema = z.object({
  /** ISO 8601 格式时间戳 */
  iso: z.string().datetime(),
  /** 相对会话开始的毫秒数 */
  elapsed: z.number().int().min(0)
});
export type Timestamp = z.infer<typeof TimestampSchema>;

// ==================== 进度追踪 ====================

/** 步骤进度记录 */
export const StepProgressSchema = z.object({
  stepId: z.string(),
  /** 0-100 百分比 */
  completionPercent: z.number().min(0).max(100),
  /** 进入次数 */
  entryCount: z.number().int().min(0).default(0),
  /** 完成时间（毫秒），0表示未完成 */
  completedAt: z.number().int().min(0).default(0),
  /** 是否被跳过 */
  skipped: z.boolean().default(false),
  /** 跳过原因 */
  skipReason: z.string().optional()
});
export type StepProgress = z.infer<typeof StepProgressSchema>;

// ==================== 会话配置 ====================

/** 会话配置 */
export const SessionConfigSchema = z.object({
  /** 启用提示系统 */
  hintEnabled: z.boolean().default(true),
  /** 启用鼓励反馈 */
  encouragementEnabled: z.boolean().default(true),
  /** 启用音效 */
  soundEnabled: z.boolean().default(true),
  /** 难度偏好：auto=自动调整，easy=简单优先，challenging=挑战优先 */
  difficultyPreference: z.enum(['auto', 'easy', 'challenging']).default('auto'),
  /** 步骤最大尝试次数，0表示不限制 */
  maxAttemptsPerStep: z.number().int().min(0).default(3),
  /** 会话超时时间（毫秒），0表示不限制 */
  sessionTimeout: z.number().int().min(0).default(0),
  /** 自动暂停阈值（电量百分比） */
  lowBatteryThreshold: z.number().min(0).max(100).default(20)
});
export type SessionConfig = z.infer<typeof SessionConfigSchema>;

// ==================== 性能指标 ====================

/** 性能指标 */
export const PerformanceMetricsSchema = z.object({
  /** 总用时（毫秒） */
  totalDuration: z.number().int().min(0),
  /** 有效学习时间（排除暂停等，毫秒） */
  activeDuration: z.number().int().min(0),
  /** 步骤用时记录 { stepId: milliseconds } */
  stepDurations: z.record(z.string(), z.number().int().min(0)),
  /** 每步尝试次数 { stepId: count } */
  attemptCounts: z.record(z.string(), z.number().int().min(0)),
  /** 正确次数 */
  correctCount: z.number().int().min(0),
  /** 错误次数 */
  incorrectCount: z.number().int().min(0),
  /** 提示使用次数 */
  hintUsageCount: z.number().int().min(0),
  /** 跳过步骤数 */
  skippedStepCount: z.number().int().min(0),
  /** 首次正确率（第一次尝试就正确的比例）0-1 */
  firstAttemptAccuracy: z.number().min(0).max(1),
  /** 总体正确率 0-1 */
  overallAccuracy: z.number().min(0).max(1)
});
export type PerformanceMetrics = z.infer<typeof PerformanceMetricsSchema>;

// ==================== 学习会话 ====================

/**
 * 学习会话完整Schema
 * @description 记录一次完整学习活动的所有状态和信息
 */
export const LearningSessionSchema = z.object({
  /** 会话唯一ID */
  sessionId: z.string(),
  /** 用户ID */
  userId: z.string(),
  /** 内容包ID */
  packageId: z.string(),
  /** 知识点ID */
  kpId: z.string(),
  /** 会话状态 */
  status: SessionStatusEnum,
  /** 当前学习阶段 */
  currentPhase: LearningPhaseEnum,
  /** 当前步骤ID */
  currentStepId: z.string().optional(),

  /** 创建时间 */
  createdAt: TimestampSchema,
  /** 开始时间 */
  startedAt: TimestampSchema.optional(),
  /** 结束时间 */
  completedAt: TimestampSchema.optional(),
  /** 最后活动时间 */
  lastActivityAt: TimestampSchema,

  /** 步骤进度列表 */
  stepProgress: z.array(StepProgressSchema),
  /** 步骤完成顺序 */
  completedStepOrder: z.array(z.string()),

  /** 性能指标 */
  metrics: PerformanceMetricsSchema.optional(),

  /** 会话配置 */
  config: SessionConfigSchema,

  /** 暂停记录 */
  pauseHistory: z.array(z.object({
    pausedAt: TimestampSchema,
    resumedAt: TimestampSchema.optional(),
    reason: PauseReasonEnum,
    duration: z.number().int().min(0).default(0)
  })).default([]),

  /** 设备信息 */
  deviceInfo: z.object({
    platform: z.string(),
    osVersion: z.string().optional(),
    screenWidth: z.number().optional(),
    screenHeight: z.number().optional(),
    viewportWidth: z.number().optional(),
    viewportHeight: z.number().optional()
  }).optional(),

  /** 应用版本 */
  appVersion: z.string().optional(),

  /** 元数据 */
  metadata: z.record(z.unknown()).default({})
});
export type LearningSession = z.infer<typeof LearningSessionSchema>;

