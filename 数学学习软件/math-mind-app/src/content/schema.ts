/**
 * 数学思维启发学习系统 - 内容Schema定义
 * @description 定义学习内容包的结构，包括知识点、学习步骤、交互配置等
 */

import { z } from 'zod';

// ==================== 枚举定义 ====================

/** 步骤类型枚举 */
export const StepTypeEnum = z.enum([
  'concrete',    // 具体操作阶段 - 动手操作、实物感知
  'pictorial',   // 图像表征阶段 - 图形化展示
  'symbolic',    // 符号抽象阶段 - 数学符号表达
  'conjecture',  // 猜想验证阶段 - 规律发现与验证
  'application'  // 应用拓展阶段 - 迁移与综合应用
]);
export type StepType = z.infer<typeof StepTypeEnum>;

/** 交互类型枚举 */
export const InteractionTypeEnum = z.enum([
  'drag',        // 拖拽操作
  'tap',         // 点击选择
  'input',       // 数值输入
  'match',       // 配对操作
  'order',       // 排序操作
  'fill',        // 填空操作
  'compare'      // 比较操作
]);
export type InteractionType = z.infer<typeof InteractionTypeEnum>;

/** 反馈类型枚举 */
export const FeedbackTypeEnum = z.enum([
  'correct',     // 正确反馈
  'incorrect',   // 错误反馈
  'hint',        // 提示反馈
  'encourage'    // 鼓励反馈
]);
export type FeedbackType = z.infer<typeof FeedbackTypeEnum>;

/** 难度等级枚举 */
export const DifficultyEnum = z.enum(['easy', 'medium', 'hard']);
export type Difficulty = z.infer<typeof DifficultyEnum>;

// ==================== 验证规则 ====================

/** 数值验证规则 */
export const ValidationRuleSchema = z.object({
  type: z.enum(['range', 'precision', 'comparison', 'custom']),
  min: z.number().optional(),
  max: z.number().optional(),
  precision: z.number().optional(),
  equals: z.union([z.number(), z.string()]).optional(),
  message: z.string().optional()
});
export type ValidationRule = z.infer<typeof ValidationRuleSchema>;

/** 正确答案定义 */
export const AnswerSchema = z.object({
  value: z.union([z.number(), z.string(), z.array(z.number()), z.array(z.string())]),
  tolerance: z.number().optional(),  // 允许误差
  alternatives: z.array(z.union([z.number(), z.string()])).optional()  // 备选答案
});
export type Answer = z.infer<typeof AnswerSchema>;

// ==================== 可视化配置 ====================

/** 圆饼图可视化配置 */
export const PieChartConfigSchema = z.object({
  type: z.literal('pie'),
  totalParts: z.number().min(1).max(24),
  filledParts: z.number().min(0),
  colors: z.object({
    filled: z.string(),
    empty: z.string()
  }).optional(),
  showLabels: z.boolean().optional(),
  animatable: z.boolean().optional()
});
export type PieChartConfig = z.infer<typeof PieChartConfigSchema>;

/** 条形图可视化配置 */
export const BarChartConfigSchema = z.object({
  type: z.literal('bar'),
  bars: z.array(z.object({
    value: z.number(),
    label: z.string().optional(),
    color: z.string().optional()
  })),
  maxValue: z.number().optional(),
  showValues: z.boolean().optional(),
  animatable: z.boolean().optional()
});
export type BarChartConfig = z.infer<typeof BarChartConfigSchema>;

/** 数轴可视化配置 */
export const NumberLineConfigSchema = z.object({
  type: z.literal('numberLine'),
  start: z.number(),
  end: z.number(),
  marks: z.array(z.number()),
  points: z.array(z.object({
    value: z.number(),
    label: z.string().optional(),
    color: z.string().optional()
  })),
  animatable: z.boolean().optional()
});
export type NumberLineConfig = z.infer<typeof NumberLineConfigSchema>;

/** 矩形分割可视化配置 */
export const RectGridConfigSchema = z.object({
  type: z.literal('rectGrid'),
  rows: z.number().min(1).max(10),
  cols: z.number().min(1).max(10),
  filledCells: z.array(z.object({
    row: z.number(),
    col: z.number()
  })),
  showGrid: z.boolean().optional(),
  animatable: z.boolean().optional()
});
export type RectGridConfig = z.infer<typeof RectGridConfigSchema>;

/** 分数条可视化配置 */
export const FractionBarConfigSchema = z.object({
  type: z.literal('fractionBar'),
  fractions: z.array(z.object({
    denominator: z.number(),
    numerator: z.number(),
    label: z.string().optional(),
    color: z.string().optional()
  })),
  equalLength: z.boolean().optional(),  // 是否等长显示
  showLabels: z.boolean().optional(),
  animatable: z.boolean().optional()
});
export type FractionBarConfig = z.infer<typeof FractionBarConfigSchema>;

/** 可视化配置联合类型 */
export const VisualConfigSchema = z.discriminatedUnion('type', [
  PieChartConfigSchema,
  BarChartConfigSchema,
  NumberLineConfigSchema,
  RectGridConfigSchema,
  FractionBarConfigSchema
]);
export type VisualConfig = z.infer<typeof VisualConfigSchema>;

// ==================== 交互配置 ====================

/** 拖拽交互配置 */
export const DragInteractionConfigSchema = z.object({
  type: z.literal('drag'),
  items: z.array(z.object({
    id: z.string(),
    content: z.string(),
    position: z.object({
      x: z.number(),
      y: z.number()
    }).optional()
  })),
  dropZones: z.array(z.object({
    id: z.string(),
    position: z.object({
      x: z.number(),
      y: z.number()
    }),
    size: z.object({
      width: z.number(),
      height: z.number()
    }),
    acceptedIds: z.array(z.string()).optional()  // 允许接受的item id
  })),
  multiple: z.boolean().optional()
});
export type DragInteractionConfig = z.infer<typeof DragInteractionConfigSchema>;

/** 点击选择交互配置 */
export const TapInteractionConfigSchema = z.object({
  type: z.literal('tap'),
  options: z.array(z.object({
    id: z.string(),
    label: z.string(),
    isCorrect: z.boolean().optional()
  })),
  multiSelect: z.boolean().optional(),
  required: z.boolean().optional()
});
export type TapInteractionConfig = z.infer<typeof TapInteractionConfigSchema>;

/** 数值输入交互配置 */
export const InputInteractionConfigSchema = z.object({
  type: z.literal('input'),
  placeholder: z.string().optional(),
  inputType: z.enum(['number', 'text']).optional(),
  validation: ValidationRuleSchema.optional()
});
export type InputInteractionConfig = z.infer<typeof InputInteractionConfigSchema>;

/** 排序交互配置 */
export const OrderInteractionConfigSchema = z.object({
  type: z.literal('order'),
  items: z.array(z.object({
    id: z.string(),
    content: z.string()
  })),
  direction: z.enum(['asc', 'desc', 'custom']).optional()
});
export type OrderInteractionConfig = z.infer<typeof OrderInteractionConfigSchema>;

/** 交互配置联合类型 */
export const InteractionConfigSchema = z.discriminatedUnion('type', [
  DragInteractionConfigSchema,
  TapInteractionConfigSchema,
  InputInteractionConfigSchema,
  OrderInteractionConfigSchema
]);
export type InteractionConfig = z.infer<typeof InteractionConfigSchema>;

// ==================== 反馈配置 ====================

/** 反馈配置 */
export const FeedbackConfigSchema = z.object({
  type: FeedbackTypeEnum,
  message: z.string(),
  nextStep: z.string().optional(),  // 指定下一步
  highlight: z.array(z.string()).optional(),  // 高亮元素
  animation: z.enum(['shake', 'bounce', 'glow', 'none']).optional()
});
export type FeedbackConfig = z.infer<typeof FeedbackConfigSchema>;

// ==================== 步骤内容 ====================

/** 学习步骤内容 */
export const StepContentSchema = z.object({
  stepId: z.string(),
  stepType: StepTypeEnum,
  title: z.string(),
  instruction: z.string(),
  /** 视觉呈现配置 */
  visual: VisualConfigSchema.optional(),
  /** 用户交互配置 */
  interaction: InteractionConfigSchema.optional(),
  /** 反馈配置数组 */
  feedback: z.array(FeedbackConfigSchema),
  /** 完成后自动进入下一步的延迟（毫秒），0表示手动触发 */
  autoAdvance: z.number().min(0).max(5000).optional(),
  /** 步骤时长限制（毫秒），0表示不限制 */
  timeLimit: z.number().min(0).optional()
});
export type StepContent = z.infer<typeof StepContentSchema>;

// ==================== 学习步骤 ====================

/** 学习步骤 */
export const LearningStepSchema = z.object({
  stepId: z.string(),
  stepType: StepTypeEnum,
  title: z.string(),
  description: z.string(),
  /** 步骤内容配置 */
  content: StepContentSchema,
  /** 前置步骤ID列表 */
  prerequisites: z.array(z.string()).optional(),
  /** 完成后解锁的步骤ID列表 */
  unlocks: z.array(z.string()).optional()
});
export type LearningStep = z.infer<typeof LearningStepSchema>;

// ==================== 知识点 ====================

/** 知识点定义 */
export const KnowledgePointSchema = z.object({
  kpId: z.string(),
  name: z.string(),
  description: z.string(),
  /** 数学思想主线 */
  thoughtLine: z.string(),
  /** 年级建议 */
  gradeLevel: z.union([z.number(), z.string()]),
  /** 关联的前置知识点ID */
  prerequisites: z.array(z.string()).optional(),
  /** 关联的后续知识点ID */
  successors: z.array(z.string()).optional(),
  /** 学习目标 */
  learningObjectives: z.array(z.string()),
  /** 常见错误/迷思概念 */
  misconceptions: z.array(z.string()).optional()
});
export type KnowledgePoint = z.infer<typeof KnowledgePointSchema>;

// ==================== 内容包 ====================

/** 内容包元信息 */
export const ContentPackageMetaSchema = z.object({
  packageId: z.string(),
  title: z.string(),
  description: z.string(),
  thoughtLine: z.string(),
  thoughtLineOrder: z.number(),  // 在思想主线中的顺序
  difficulty: DifficultyEnum,
  gradeLevel: z.union([z.number(), z.string()]),
  estimatedMinutes: z.number(),
  version: z.string(),
  author: z.string().optional(),
  createdAt: z.string(),
  updatedAt: z.string()
});
export type ContentPackageMeta = z.infer<typeof ContentPackageMetaSchema>;

/** 内容包完整结构 */
export const ContentPackageSchema = z.object({
  meta: ContentPackageMetaSchema,
  knowledgePoint: KnowledgePointSchema,
  steps: z.array(LearningStepSchema)
});
export type ContentPackage = z.infer<typeof ContentPackageSchema>;
