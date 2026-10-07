/**
 * 数学思维启发学习系统 - 能力画像Schema
 * @description 定义用户数学能力的多维度画像和评估结构
 */

import { z } from 'zod';

// ==================== 能力维度枚举 ====================

/** 数学思想主线枚举 */
export const ThoughtLineEnum = z.enum([
  'number_shape',      // 数形结合
  'transformation',    // 转化与化归
  'classify_compare',  // 分类与比较
  'wholeness_part',    // 整体与部分
  'equivalence',       // 等价与守恒
  'pattern_generalize' // 归纳与推广
]);
export type ThoughtLine = z.infer<typeof ThoughtLineEnum>;

/** 认知层级枚举（SOLO分类法简化） */
export const CognitiveLevelEnum = z.enum([
  'pre_structural',   // 前结构
  'uni_structural',   // 单点结构
  'multi_structural', // 多点结构
  'relational',       // 关联结构
  'extended_abstract' // 抽象拓展
]);
export type CognitiveLevel = z.infer<typeof CognitiveLevelEnum>;

/** 能力评估状态枚举 */
export const AbilityAssessmentStatusEnum = z.enum([
  'not_assessed',    // 未评估
  'in_progress',     // 评估中
  'assessed',        // 已评估
  'needs_reassessment' // 需要重新评估
]);
export type AbilityAssessmentStatus = z.infer<typeof AbilityAssessmentStatusEnum>;

/** 能力等级枚举 */
export const AbilityLevelEnum = z.enum([
  'beginner',      // 初学者
  'developing',    // 发展中
  'competent',     // 胜任
  'proficient',    // 精通
  'expert'         // 专家
]);
export type AbilityLevel = z.infer<typeof AbilityLevelEnum>;

// ==================== 数值范围 ====================

/** 百分比范围 */
export const PercentageRangeSchema = z.object({
  min: z.number().min(0).max(100),
  max: z.number().min(0).max(100)
});
export type PercentageRange = z.infer<typeof PercentageRangeSchema>;

// ==================== 维度能力 ====================

/** 维度能力评估记录 */
export const DimensionAbilitySchema = z.object({
  /** 维度ID */
  dimensionId: z.string(),
  /** 维度名称 */
  dimensionName: z.string(),
  /** 能力等级 */
  level: AbilityLevelEnum,
  /** 置信度（0-1） */
  confidence: z.number().min(0).max(1),
  /** 评估样本数 */
  sampleCount: z.number().int().min(0),
  /** 正确率（0-1） */
  accuracy: z.number().min(0).max(1),
  /** 平均用时（毫秒） */
  avgDuration: z.number().int().min(0).optional(),
  /** 能力发展趋势 */
  trend: z.enum(['improving', 'stable', 'declining']).default('stable'),
  /** 最近评估时间 */
  lastAssessedAt: z.string().datetime().optional(),
  /** 评估来源 */
  assessmentSource: z.enum(['answer_evidence', 'time_evidence', 'strategy_evidence', 'composite']).default('composite')
});
export type DimensionAbility = z.infer<typeof DimensionAbilitySchema>;

// ==================== 思想主线能力 ====================

/** 思想主线能力 */
export const ThoughtLineAbilitySchema = z.object({
  thoughtLine: ThoughtLineEnum,
  /** 能力分数（0-100） */
  score: z.number().min(0).max(100),
  /** 置信区间 */
  confidenceInterval: PercentageRangeSchema,
  /** 认知层级分布 */
  cognitiveLevelDistribution: z.object({
    pre_structural: z.number().min(0).max(1).default(0),
    uni_structural: z.number().min(0).max(1).default(0),
    multi_structural: z.number().min(0).max(1).default(0),
    relational: z.number().min(0).max(1).default(0),
    extended_abstract: z.number().min(0).max(1).default(0)
  }),
  /** 主线内各维度能力 */
  dimensions: z.array(DimensionAbilitySchema),
  /** 常见错误模式 */
  commonErrorPatterns: z.array(z.object({
    errorType: z.string(),
    frequency: z.number().min(0).max(1)
  })).default([]),
  /** 推荐学习路径 */
  recommendedPath: z.array(z.string()).optional()
});
export type ThoughtLineAbility = z.infer<typeof ThoughtLineAbilitySchema>;

// ==================== 学习进度 ====================

/** 学习进度记录 */
export const LearningProgressSchema = z.object({
  /** 知识点ID */
  kpId: z.string(),
  /** 知识点名称 */
  kpName: z.string(),
  /** 学习状态 */
  status: z.enum(['not_started', 'in_progress', 'mastered', 'needs_review']),
  /** 掌握度（0-1） */
  mastery: z.number().min(0).max(1),
  /** 学习次数 */
  attemptCount: z.number().int().min(0),
  /** 最近学习时间 */
  lastAttemptAt: z.string().datetime().optional(),
  /** 预计下次复习时间 */
  nextReviewAt: z.string().datetime().optional(),
  /** 学习历史摘要 */
  historySummary: z.object({
    totalTimeSpent: z.number().int().min(0).default(0),
    completedSessions: z.number().int().min(0).default(0),
    avgAccuracy: z.number().min(0).max(1).default(0),
    strongestStepType: z.string().optional(),
    weakestStepType: z.string().optional()
  })
});
export type LearningProgress = z.infer<typeof LearningProgressSchema>;

// ==================== 能力画像 ====================

/**
 * 能力画像完整Schema
 * @description 记录用户在各数学思想主线上的能力表现
 */
export const AbilityProfileSchema = z.object({
  /** 画像ID */
  profileId: z.string(),
  /** 用户ID */
  userId: z.string(),
  /** 创建时间 */
  createdAt: z.string().datetime(),
  /** 最后更新时间 */
  updatedAt: z.string().datetime(),
  /** 评估状态 */
  assessmentStatus: AbilityAssessmentStatusEnum,

  /** 总体能力分数（0-100） */
  overallScore: z.number().min(0).max(100),
  /** 能力等级 */
  abilityLevel: AbilityLevelEnum,
  /** 置信度（0-1） */
  overallConfidence: z.number().min(0).max(1),

  /** 各思想主线能力 */
  thoughtLineAbilities: z.array(ThoughtLineAbilitySchema),

  /** 学习进度记录 */
  learningProgress: z.array(LearningProgressSchema),

  /** 学习偏好推断 */
  learningPreferences: z.object({
    /** 偏好表征方式 */
    preferredRepresentation: z.enum(['concrete', 'pictorial', 'symbolic', 'varies']).default('varies'),
    /** 自主探索倾向（0-1） */
    explorationTendency: z.number().min(0).max(1).default(0.5),
    /** 耐心程度（0-1） */
    patienceLevel: z.number().min(0).max(1).default(0.5),
    /** 风险偏好（0-1，0=保守，1=激进） */
    riskTolerance: z.number().min(0).max(1).default(0.5)
  }),

  /** 学习行为统计 */
  learningBehaviorStats: z.object({
    /** 总学习时长（毫秒） */
    totalLearningTime: z.number().int().min(0).default(0),
    /** 总完成会话数 */
    totalSessions: z.number().int().min(0).default(0),
    /** 总完成知识点数 */
    totalKPsCompleted: z.number().int().min(0).default(0),
    /** 平均会话时长（毫秒） */
    avgSessionDuration: z.number().int().min(0).default(0),
    /** 提示使用率（0-1） */
    hintUsageRate: z.number().min(0).max(1).default(0),
    /** 跳过率（0-1） */
    skipRate: z.number().min(0).max(1).default(0)
  }),

  /** 优势领域 */
  strengths: z.array(z.object({
    thoughtLine: ThoughtLineEnum,
    dimensionId: z.string().optional(),
    description: z.string(),
    evidenceCount: z.number().int().min(0)
  })).default([]),

  /** 待提升领域 */
  improvementAreas: z.array(z.object({
    thoughtLine: ThoughtLineEnum,
    dimensionId: z.string().optional(),
    description: z.string(),
    priority: z.number().int().min(1).max(3).default(2)
  })).default([]),

  /** 元数据 */
  metadata: z.record(z.unknown()).default({})
});
export type AbilityProfile = z.infer<typeof AbilityProfileSchema>;

// ==================== 能力对比 ====================

/** 能力对比记录 */
export const AbilityComparisonSchema = z.object({
  /** 对比ID */
  comparisonId: z.string(),
  /** 用户ID */
  userId: z.string(),
  /** 对比时间 */
  comparedAt: z.string().datetime(),
  /** 对比类型 */
  comparisonType: z.enum(['self_progress', 'peer_average', 'grade_benchmark']),
  /** 思想主线对比 */
  thoughtLineComparisons: z.array(z.object({
    thoughtLine: ThoughtLineEnum,
    /** 用户分数 */
    userScore: z.number().min(0).max(100),
    /** 对比基准分数 */
    benchmarkScore: z.number().min(0).max(100),
    /** 差异 */
    difference: z.number(),
    /** 百分位（如果是与同龄人对比） */
    percentile: z.number().min(0).max(100).optional()
  }))
});
export type AbilityComparison = z.infer<typeof AbilityComparisonSchema>;

