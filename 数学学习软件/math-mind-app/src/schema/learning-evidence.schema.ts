/**
 * 数学思维启发学习系统 - 学习证据Schema
 * @description 定义学习过程中的行为证据、思维过程和理解状态的记录
 */

import { z } from 'zod';

// ==================== 证据类型枚举 ====================

/** 证据类型枚举 */
export const EvidenceTypeEnum = z.enum([
  'answer',           // 答案证据
  'interaction',     // 交互行为证据
  'time_spent',      // 时间行为证据
  'hint_usage',      // 提示使用证据
  'error_pattern',   // 错误模式证据
  'strategy_choice', // 策略选择证据
  'concept_access',  // 概念访问证据
  'emotional',       // 情感状态证据
  'collaboration',   // 协作行为证据
  'reflection'       // 反思证据
]);
export type EvidenceType = z.infer<typeof EvidenceTypeEnum>;

/** 证据来源枚举 */
export const EvidenceSourceEnum = z.enum([
  'system',          // 系统自动采集
  'user_action',     // 用户主动提交
  'sensor',          // 传感器数据
  'self_report',     // 用户自我报告
  'peer_feedback',   // 同伴反馈
  'teacher_feedback' // 教师反馈
]);
export type EvidenceSource = z.infer<typeof EvidenceSourceEnum>;

/** 证据可信度枚举 */
export const EvidenceConfidenceEnum = z.enum([
  'high',    // 高可信
  'medium',  // 中可信
  'low'      // 低可信
]);
export type EvidenceConfidence = z.infer<typeof EvidenceConfidenceEnum>;

// ==================== 答案证据 ====================

/** 答案证据 */
export const AnswerEvidenceSchema = z.object({
  evidenceType: z.literal('answer'),
  /** 问题/步骤ID */
  stepId: z.string(),
  /** 问题内容（可选，用于上下文） */
  question: z.string().optional(),
  /** 用户答案 */
  userAnswer: z.unknown(),
  /** 正确答案 */
  correctAnswer: z.unknown().optional(),
  /** 是否正确 */
  isCorrect: z.boolean(),
  /** 尝试次数 */
  attemptNumber: z.number().int().min(1),
  /** 距正确答案的编辑距离（如果是文本） */
  editDistance: z.number().int().optional(),
  /** 部分正确比例（0-1，用于填空等） */
  partialScore: z.number().min(0).max(1).optional(),
  /** 用时（毫秒） */
  duration: z.number().int().min(0),
  /** 时间戳 */
  timestamp: z.string().datetime()
});
export type AnswerEvidence = z.infer<typeof AnswerEvidenceSchema>;

// ==================== 交互证据 ====================

/** 交互证据 - 记录用户操作序列 */
export const InteractionEvidenceSchema = z.object({
  evidenceType: z.literal('interaction'),
  /** 步骤ID */
  stepId: z.string(),
  /** 交互类型 */
  interactionType: z.enum(['drag', 'tap', 'input', 'swipe', 'zoom', 'scroll']),
  /** 操作序列 */
  actions: z.array(z.object({
    /** 操作类型 */
    actionType: z.string(),
    /** 操作目标元素 */
    targetElement: z.string().optional(),
    /** 操作坐标（如果有） */
    coordinates: z.object({
      x: z.number(),
      y: z.number()
    }).optional(),
    /** 操作值（如果有） */
    value: z.unknown().optional(),
    /** 操作时间戳 */
    timestamp: z.string().datetime(),
    /** 操作持续时间（毫秒） */
    duration: z.number().int().min(0).optional()
  })),
  /** 关键操作点 */
  keyActions: z.array(z.string()).optional(),
  /** 总操作次数 */
  totalActions: z.number().int().min(0),
  /** 是否完成了目标操作 */
  completed: z.boolean(),
  /** 操作效率评分（1-5） */
  efficiencyScore: z.number().min(1).max(5).optional()
});
export type InteractionEvidence = z.infer<typeof InteractionEvidenceSchema>;

// ==================== 时间证据 ====================

/** 时间行为证据 */
export const TimeSpentEvidenceSchema = z.object({
  evidenceType: z.literal('time_spent'),
  /** 步骤ID */
  stepId: z.string().optional(),
  /** 活动类型 */
  activityType: z.enum(['reading', 'thinking', 'interacting', 'reviewing', 'idle']),
  /** 开始时间 */
  startTime: z.string().datetime(),
  /** 结束时间 */
  endTime: z.string().datetime(),
  /** 持续时长（毫秒） */
  duration: z.number().int().min(0),
  /** 预期时长（毫秒，用于对比） */
  expectedDuration: z.number().int().min(0).optional(),
  /** 是否超时 */
  timedOut: z.boolean().default(false),
  /** 区域/元素标识 */
  regionId: z.string().optional()
});
export type TimeSpentEvidence = z.infer<typeof TimeSpentEvidenceSchema>;

// ==================== 提示使用证据 ====================

/** 提示使用证据 */
export const HintUsageEvidenceSchema = z.object({
  evidenceType: z.literal('hint_usage'),
  /** 步骤ID */
  stepId: z.string(),
  /** 提示级别（1-based） */
  hintLevel: z.number().int().min(1),
  /** 提示内容 */
  hintContent: z.string(),
  /** 是否在查看提示后立即给出正确答案 */
  answeredCorrectlyAfterHint: z.boolean().optional(),
  /** 请求提示的时间点 */
  requestedAt: z.string().datetime(),
  /** 查看提示到提交答案的间隔（毫秒） */
  hintToAnswerInterval: z.number().int().min(0).optional()
});
export type HintUsageEvidence = z.infer<typeof HintUsageEvidenceSchema>;

// ==================== 错误模式证据 ====================

/** 错误模式证据 */
export const ErrorPatternEvidenceSchema = z.object({
  evidenceType: z.literal('error_pattern'),
  /** 步骤ID */
  stepId: z.string(),
  /** 错误类型标识 */
  errorType: z.string(),
  /** 错误类型描述 */
  errorDescription: z.string(),
  /** 错误分类（数学概念错误、计算错误、理解错误等） */
  errorCategory: z.enum([
    'conceptual',      // 概念错误
    'procedural',      // 程序错误
    'computational',   // 计算错误
    'representational', // 表征错误
    'strategic',       // 策略错误
    'transcription',   // 抄写错误
    'other'            // 其他
  ]),
  /** 错误严重程度（1-5） */
  severity: z.number().int().min(1).max(5),
  /** 相关概念 */
  relatedConcepts: z.array(z.string()).optional(),
  /** 发生次数 */
  occurrenceCount: z.number().int().min(1).default(1),
  /** 是否是常见错误 */
  isCommonMisconception: z.boolean().default(false)
});
export type ErrorPatternEvidence = z.infer<typeof ErrorPatternEvidenceSchema>;

// ==================== 策略选择证据 ====================

/** 策略选择证据 */
export const StrategyChoiceEvidenceSchema = z.object({
  evidenceType: z.literal('strategy_choice'),
  /** 步骤ID */
  stepId: z.string(),
  /** 问题类型 */
  problemType: z.string(),
  /** 选择的策略 */
  chosenStrategy: z.string(),
  /** 策略描述 */
  strategyDescription: z.string(),
  /** 策略效果评分（1-5） */
  effectivenessScore: z.number().min(1).max(5).optional(),
  /** 是否成功 */
  success: z.boolean(),
  /** 可用策略列表（如果有） */
  availableStrategies: z.array(z.string()).optional(),
  /** 策略切换次数 */
  strategySwitchCount: z.number().int().min(0).default(0)
});
export type StrategyChoiceEvidence = z.infer<typeof StrategyChoiceEvidenceSchema>;

// ==================== 情感状态证据 ====================

/** 情感状态证据 */
export const EmotionalEvidenceSchema = z.object({
  evidenceType: z.literal('emotional'),
  /** 情感类型 */
  emotionType: z.enum([
    'engaged',     // 投入
    'frustrated',  // 受挫
    'confident',   // 自信
    'confused',    // 困惑
    'excited',     // 兴奋
    'bored',       // 厌倦
    'anxious',     // 焦虑
    'satisfied',    // 满足
    'neutral'      // 中性
  ]),
  /** 可信度 */
  confidence: EvidenceConfidenceEnum,
  /** 来源（系统推断/用户自报） */
  source: EvidenceSourceEnum,
  /** 触发因素 */
  trigger: z.string().optional(),
  /** 时间戳 */
  timestamp: z.string().datetime(),
  /** 强度（1-5） */
  intensity: z.number().int().min(1).max(5).default(3),
  /** 持续时长（毫秒） */
  duration: z.number().int().min(0).optional()
});
export type EmotionalEvidence = z.infer<typeof EmotionalEvidenceSchema>;

// ==================== 通用证据记录 ====================

/** 通用证据记录 */
export const LearningEvidenceSchema = z.discriminatedUnion('evidenceType', [
  AnswerEvidenceSchema,
  InteractionEvidenceSchema,
  TimeSpentEvidenceSchema,
  HintUsageEvidenceSchema,
  ErrorPatternEvidenceSchema,
  StrategyChoiceEvidenceSchema,
  EmotionalEvidenceSchema
]);
export type LearningEvidence = z.infer<typeof LearningEvidenceSchema>;

// ==================== 证据集合 ====================

/** 证据批次记录 */
export const EvidenceBatchSchema = z.object({
  /** 批次ID */
  batchId: z.string(),
  /** 会话ID */
  sessionId: z.string(),
  /** 用户ID */
  userId: z.string(),
  /** 知识点ID */
  kpId: z.string(),
  /** 证据列表 */
  evidences: z.array(LearningEvidenceSchema),
  /** 收集开始时间 */
  collectStartAt: z.string().datetime(),
  /** 收集结束时间 */
  collectEndAt: z.string().datetime(),
  /** 元数据 */
  metadata: z.record(z.unknown()).default({})
});
export type EvidenceBatch = z.infer<typeof EvidenceBatchSchema>;

