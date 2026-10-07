/**
 * 数学思维启发学习系统 - 内容包Schema
 * @description 定义学习内容包的结构、版本管理和发布状态
 */

import { z } from 'zod';

// ==================== 基础枚举 ====================

/** 内容包状态枚举 */
export const ContentStatusEnum = z.enum([
  'draft',        // 草稿
  'review',       // 审核中
  'published',    // 已发布
  'deprecated',   // 已废弃
  'archived'      // 已归档
]);
export type ContentStatus = z.infer<typeof ContentStatusEnum>;

/** 目标年级枚举 */
export const GradeLevelEnum = z.enum([
  'grade1', 'grade2', 'grade3', 'grade4', 'grade5', 'grade6',
  'grade7', 'grade8', 'grade9'
]);
export type GradeLevel = z.infer<typeof GradeLevelEnum>;

// ==================== 版本管理 ====================

/** 内容包版本 */
export const ContentVersionSchema = z.object({
  /** 版本号（语义化版本） */
  version: z.string().regex(/^\d+\.\d+\.\d+$/, '使用语义化版本格式'),
  /** 发布日期 */
  releasedAt: z.string().datetime(),
  /** 变更说明 */
  changelog: z.string(),
  /** 变更类型 */
  changeType: z.enum(['major', 'minor', 'patch']),
  /** 是否强制更新 */
  forceUpdate: z.boolean().default(false)
});
export type ContentVersion = z.infer<typeof ContentVersionSchema>;

// ==================== 元信息 ====================

/** 内容包元信息 */
export const ContentMetaSchema = z.object({
  /** 内容包ID */
  contentId: z.string(),
  /** 内容包名称 */
  name: z.string().min(1).max(100),
  /** 简短描述 */
  shortDescription: z.string().min(1).max(200),
  /** 详细描述 */
  description: z.string().max(2000).optional(),
  /** 思想主线 */
  thoughtLine: z.string(),
  /** 目标年级 */
  targetGrades: z.array(GradeLevelEnum),
  /** 预估学习时长（分钟） */
  estimatedMinutes: z.number().int().min(1).max(180),
  /** 难度等级 */
  difficulty: z.enum(['easy', 'medium', 'hard']),
  /** 标签 */
  tags: z.array(z.string()).default([]),
  /** 缩略图URL */
  thumbnailUrl: z.string().url().optional(),
  /** 作者 */
  author: z.string(),
  /** 创建时间 */
  createdAt: z.string().datetime(),
  /** 更新时间 */
  updatedAt: z.string().datetime()
});
export type ContentMeta = z.infer<typeof ContentMetaSchema>;

// ==================== 学习目标 ====================

/** 学习目标 */
export const LearningObjectiveSchema = z.object({
  /** 目标ID */
  objectiveId: z.string(),
  /** 目标描述 */
  description: z.string(),
  /** 目标类型 */
  type: z.enum(['knowledge', 'skill', 'attitude', 'ability']),
  /** 可评估性 */
  assessable: z.boolean().default(true),
  /** 关联的认知层级 */
  cognitiveLevel: z.enum(['remember', 'understand', 'apply', 'analyze', 'evaluate', 'create'])
});
export type LearningObjective = z.infer<typeof LearningObjectiveSchema>;

// ==================== 步骤定义 ====================

/** 步骤定义 */
export const StepDefinitionSchema = z.object({
  /** 步骤ID */
  stepId: z.string(),
  /** 步骤序号（1-based） */
  order: z.number().int().min(1),
  /** 步骤类型 */
  stepType: z.enum(['concrete', 'pictorial', 'symbolic', 'conjecture', 'application']),
  /** 步骤标题 */
  title: z.string(),
  /** 步骤描述 */
  description: z.string().optional(),
  /** 学习目标ID列表 */
  objectives: z.array(z.string()).default([]),
  /** 预估时长（秒） */
  estimatedSeconds: z.number().int().min(1).default(60),
  /** 最大尝试次数 */
  maxAttempts: z.number().int().min(1).default(3),
  /** 是否可跳过 */
  skippable: z.boolean().default(false),
  /** 是否启用计时 */
  timed: z.boolean().default(false),
  /** 时间限制（秒），0表示不限制 */
  timeLimit: z.number().int().min(0).default(0)
});
export type StepDefinition = z.infer<typeof StepDefinitionSchema>;

// ==================== 步骤内容配置 ====================

/** 可视化配置 */
export const VisualizationConfigSchema = z.object({
  /** 可视化类型 */
  vizType: z.enum(['pie', 'bar', 'numberLine', 'rectGrid', 'fractionBar', 'custom']),
  /** 配置数据 */
  config: z.record(z.unknown()),
  /** 动画配置 */
  animation: z.object({
    enabled: z.boolean().default(true),
    duration: z.number().int().min(0).default(300),
    easing: z.string().default('ease-out')
  }).optional()
});
export type VisualizationConfig = z.infer<typeof VisualizationConfigSchema>;

/** 交互配置 */
export const InteractionConfigSchema = z.object({
  /** 交互类型 */
  interactionType: z.enum(['drag', 'tap', 'input', 'order', 'match', 'none']),
  /** 配置数据 */
  config: z.record(z.unknown()),
  /** 输入验证规则 */
  validation: z.object({
    type: z.enum(['exact', 'range', 'comparison', 'custom']),
    params: z.record(z.unknown())
  }).optional()
});
export type InteractionConfig = z.infer<typeof InteractionConfigSchema>;

/** 反馈配置 */
export const FeedbackConfigSchema = z.object({
  /** 反馈类型 */
  feedbackType: z.enum(['correct', 'incorrect', 'hint', 'encourage', 'none']),
  /** 条件表达式 */
  condition: z.string().optional(),
  /** 消息内容 */
  message: z.string(),
  /** 消息类型 */
  messageType: z.enum(['text', 'image', 'audio', 'animation']),
  /** 下一个步骤ID（可选） */
  nextStepId: z.string().optional(),
  /** 高亮元素ID列表 */
  highlightElements: z.array(z.string()).optional(),
  /** 动画效果 */
  animationEffect: z.enum(['shake', 'bounce', 'glow', 'confetti', 'none']).optional()
});
export type FeedbackConfig = z.infer<typeof FeedbackConfigSchema>;

/** 步骤内容 */
export const StepContentSchema = z.object({
  /** 步骤ID */
  stepId: z.string(),
  /** 题目内容 */
  question: z.string(),
  /** 题目备选文本（用于选择题等） */
  options: z.array(z.object({
    id: z.string(),
    text: z.string()
  })).optional(),
  /** 正确答案 */
  correctAnswer: z.unknown(),
  /** 可选答案列表（如果有多个正确答案） */
  alternativeAnswers: z.array(z.unknown()).optional(),
  /** 可视化配置 */
  visualization: VisualizationConfigSchema.optional(),
  /** 交互配置 */
  interaction: InteractionConfigSchema.optional(),
  /** 反馈配置列表 */
  feedback: z.array(FeedbackConfigSchema).default([]),
  /** 提示列表（按级别） */
  hints: z.array(z.object({
    level: z.number().int().min(1),
    content: z.string()
  })).default([])
});
export type StepContent = z.infer<typeof StepContentSchema>;

// ==================== 前置条件 ====================

/** 前置条件 */
export const PrerequisiteConditionSchema = z.object({
  /** 条件类型 */
  type: z.enum(['always', 'completed', 'not_completed', 'score_above', 'time_above', 'attempts_below']),
  /** 关联的步骤ID */
  stepId: z.string().optional(),
  /** 条件参数 */
  params: z.record(z.unknown()).optional(),
  /** 条件描述 */
  description: z.string().optional()
});
export type PrerequisiteCondition = z.infer<typeof PrerequisiteConditionSchema>;

// ==================== 步骤路由 ====================

/** 步骤路由规则 */
export const StepRouteSchema = z.object({
  /** 源步骤ID */
  fromStepId: z.string(),
  /** 目标步骤ID */
  toStepId: z.string(),
  /** 路由条件 */
  condition: PrerequisiteConditionSchema,
  /** 条件描述 */
  description: z.string().optional(),
  /** 权重（用于随机路由） */
  weight: z.number().min(0).max(1).default(1)
});
export type StepRoute = z.infer<typeof StepRouteSchema>;

// ==================== 内容包完整结构 ====================

/**
 * 内容包完整Schema
 * @description 定义完整的学习内容包结构
 */
export const ContentPackageSchema = z.object({
  /** 协议版本 */
  $schema: z.string().default('math-mind-content/v1'),
  /** 格式版本 */
  version: z.string(),

  /** 元信息 */
  meta: ContentMetaSchema,

  /** 状态 */
  status: ContentStatusEnum,

  /** 学习目标 */
  objectives: z.array(LearningObjectiveSchema),

  /** 前置条件 */
  prerequisites: z.array(z.object({
    contentId: z.string().optional(),
    kpId: z.string().optional(),
    masteryLevel: z.number().min(0).max(1).optional()
  })).default([]),

  /** 步骤定义（简化） */
  stepDefinitions: z.array(StepDefinitionSchema),

  /** 步骤内容 */
  stepContents: z.array(StepContentSchema),

  /** 步骤路由 */
  routes: z.array(StepRouteSchema).default([]),

  /** 版本历史 */
  versionHistory: z.array(ContentVersionSchema).default([]),

  /** 发布信息 */
  publishing: z.object({
    publishedAt: z.string().datetime().optional(),
    publishedBy: z.string().optional(),
    reviewNotes: z.string().optional(),
    reviewStatus: z.enum(['pending', 'approved', 'rejected']).optional()
  }).optional()
});
export type ContentPackage = z.infer<typeof ContentPackageSchema>;

// ==================== 内容包引用 ====================

/** 内容包引用（轻量级引用） */
export const ContentPackageRefSchema = z.object({
  contentId: z.string(),
  name: z.string(),
  thoughtLine: z.string(),
  difficulty: z.enum(['easy', 'medium', 'hard']),
  targetGrades: z.array(GradeLevelEnum),
  estimatedMinutes: z.number().int().min(1),
  thumbnailUrl: z.string().url().optional()
});
export type ContentPackageRef = z.infer<typeof ContentPackageRefSchema>;

