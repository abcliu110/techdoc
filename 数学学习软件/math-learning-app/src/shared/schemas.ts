/**
 * 共享 Schema 定义 - 可视化配置类型安全
 *
 * 本文件定义所有步骤内容中使用的可视化配置 Schema，
 * 用于类型验证和自动补全。
 *
 * @module shared/schemas
 */

import { z } from 'zod';

// ==================== 基础 Schema ====================

/**
 * 场景描述 Schema
 * 用于具象步骤的场景卡片
 */
export const ScenarioSchema = z.object({
  /** 场景标题 */
  title: z.string().min(1),
  /** 场景描述 */
  description: z.string().min(1),
  /** 可选的表情符号 */
  emoji: z.string().optional(),
});

/**
 * 交互配置 Schema
 * 定义用户与可视化组件的交互方式
 */
export const InteractionSchema = z.object({
  /** 交互类型 */
  kind: z.enum(['split', 'tap', 'drag', 'draw', 'select']),
  /** 交互目标描述 */
  target: z.string().min(1),
  /** 可视化组件类型 */
  visualType: z.string().min(1),
  /** 可视化组件配置 */
  visualConfig: z.record(z.unknown()).optional(),
});

// ==================== 可视化配置 Schema ====================

/**
 * 分割圆可视化配置 Schema
 * 用于分数比较的具象表示
 *
 * @example
 * ```json
 * {
 *   "circles": [
 *     { "denominator": 4, "highlighted": [0, 1, 2] },
 *     { "denominator": 3, "highlighted": [0, 1] }
 *   ]
 * }
 * ```
 */
export const SplitCircleConfigSchema = z.object({
  /** 圆配置数组 */
  circles: z.array(
    z.object({
      /** 分母（分割份数），范围 1-360 */
      denominator: z.number().int().min(1).max(360),
      /** 高亮的份数索引数组，从 0 开始 */
      highlighted: z.array(z.number().int().min(0)),
      /** 可选的标签 */
      label: z.string().optional(),
    })
  ),
  /** 圆的大小（可选） */
  size: z.number().positive().optional(),
});

/**
 * 分数条可视化配置 Schema
 * 用于分数的图示比较
 *
 * @example
 * ```json
 * {
 *   "fractions": [
 *     { "id": "f1", "numerator": 3, "denominator": 5, "label": "3/5", "color": "#4CAF50" }
 *   ],
 *   "showUnit": true,
 *   "alignment": "bottom"
 * }
 * ```
 */
export const FractionBarConfigSchema = z.object({
  /** 分数数组 */
  fractions: z.array(
    z.object({
      /** 唯一标识 */
      id: z.string(),
      /** 分子 */
      numerator: z.number().int().min(0),
      /** 分母 */
      denominator: z.number().int().min(1),
      /** 显示标签 */
      label: z.string(),
      /** 颜色（可选） */
      color: z.string().optional(),
    })
  ),
  /** 显示单位刻度 */
  showUnit: z.boolean().optional(),
  /** 对齐方式 */
  alignment: z.enum(['top', 'bottom', 'center']).optional(),
});

/**
 * 苹果可视化配置 Schema
 * 用于整体与部分、分配等场景
 *
 * @example
 * ```json
 * {
 *   "totalApples": 10,
 *   "highlightRange": [0, 5],
 *   "appleColor": "#ef4444"
 * }
 * ```
 */
export const ApplesConfigSchema = z.object({
  /** 总苹果数 */
  totalApples: z.number().int().min(1).max(100),
  /** 高亮区间，格式 [start, end]，包含 start 不包含 end */
  highlightRange: z.tuple([z.number().int().min(0), z.number().int()]),
  /** 苹果颜色（可选） */
  appleColor: z.string().optional(),
  /** 每行数量（可选） */
  itemsPerRow: z.number().int().positive().optional(),
  /** 苹果大小（可选） */
  size: z.number().positive().optional(),
  /** 坏苹果索引数组（可选） */
  badApples: z.array(z.number().int().min(0)).optional(),
});

/**
 * 天平可视化配置 Schema
 * 用于等量关系与方程的学习
 *
 * @example
 * ```json
 * {
 *   "leftItems": [{ "type": "weight", "count": 3, "value": 2 }],
 *   "rightItems": [{ "type": "weight", "count": 2, "value": 3 }],
 *   "showEqual": true
 * }
 * ```
 */
export const BalanceConfigSchema = z.object({
  /** 左侧物品 */
  leftItems: z.array(
    z.object({
      /** 物品类型 */
      type: z.enum(['weight', 'unknown', 'box']),
      /** 数量 */
      count: z.number().int().min(1),
      /** 单个值（weight 类型时） */
      value: z.number().optional(),
      /** 标签 */
      label: z.string().optional(),
    })
  ),
  /** 右侧物品 */
  rightItems: z.array(
    z.object({
      type: z.enum(['weight', 'unknown', 'box']),
      count: z.number().int().min(1),
      value: z.number().optional(),
      label: z.string().optional(),
    })
  ),
  /** 是否显示等号 */
  showEqual: z.boolean().optional(),
  /** 平衡状态 */
  balanceState: z.enum(['balanced', 'left-heavy', 'right-heavy', 'unknown']).optional(),
});

/**
 * 尺子可视化配置 Schema
 * 用于单位换算的学习
 *
 * @example
 * ```json
 * {
 *   "units": [
 *     { "name": "米", "factor": 100, "color": "#3b82f6" },
 *     { "name": "厘米", "factor": 1, "color": "#22c55e" }
 *   ],
 *   "value": 150,
 *   "sourceUnit": "厘米",
 *   "targetUnit": "米"
 * }
 * ```
 */
export const RulerConfigSchema = z.object({
  /** 单位数组 */
  units: z.array(
    z.object({
      /** 单位名称 */
      name: z.string(),
      /** 相对基本单位的倍数 */
      factor: z.number().positive(),
      /** 显示颜色 */
      color: z.string().optional(),
    })
  ),
  /** 当前值 */
  value: z.number().positive(),
  /** 源单位名称 */
  sourceUnit: z.string(),
  /** 目标单位名称 */
  targetUnit: z.string(),
  /** 刻度间隔（可选） */
  tickInterval: z.number().positive().optional(),
});

/**
 * 形状可视化配置 Schema
 * 用于几何图形相关的学习
 *
 * @example
 * ```json
 * {
 *   "shapes": [
 *     { "type": "rectangle", "width": 4, "height": 3, "label": "A" },
 *     { "type": "square", "side": 5, "label": "B" }
 *   ]
 * }
 * ```
 */
export const ShapesConfigSchema = z.object({
  /** 形状数组 */
  shapes: z.array(
    z.object({
      /** 形状类型 */
      type: z.enum(['rectangle', 'square', 'circle', 'triangle']),
      /** 宽度（长方形） */
      width: z.number().positive().optional(),
      /** 高度（长方形） */
      height: z.number().positive().optional(),
      /** 边长（正方形、圆形） */
      side: z.number().positive().optional(),
      /** 半径（圆形） */
      radius: z.number().positive().optional(),
      /** 标签 */
      label: z.string().optional(),
      /** 填充颜色 */
      fill: z.string().optional(),
    })
  ),
  /** 比较属性 */
  compareProperty: z.enum(['area', 'perimeter', 'diagonal']).optional(),
});

// ==================== 步骤内容 Schema ====================

/**
 * 具象步骤内容 Schema
 * 通过实物操作理解抽象概念
 */
export const ConcreteContentSchema = z.object({
  type: z.literal('concrete'),
  scenario: ScenarioSchema,
  interaction: InteractionSchema,
});

/**
 * 图示步骤内容 Schema
 * 通过图形表示理解数学概念
 */
export const PictorialContentSchema = z.object({
  type: z.literal('pictorial'),
  task: z.string().min(1),
  visualType: z.string().min(1),
  visualConfig: z.record(z.unknown()).optional(),
  outputFormat: z.enum(['draw', 'select', 'arrange']),
});

/**
 * 符号步骤内容 Schema
 * 使用数学符号和表达式
 */
export const SymbolicContentSchema = z.object({
  type: z.literal('symbolic'),
  instruction: z.string().min(1),
  inputType: z.enum(['fraction', 'expression', 'equation']),
  expectedAnswer: z.union([z.string(), z.array(z.string())]),
  /** 计算方法（可选） */
  method: z.string().optional(),
  /** 计算步骤（可选） */
  steps: z.array(z.string()).optional(),
  /** 等价规则（可选） */
  equivalenceRules: z
    .array(
      z.object({
        name: z.string(),
        pattern: z.string(),
        replacement: z.string(),
      })
    )
    .optional(),
});

/**
 * 猜想步骤内容 Schema
 * 观察规律，提出猜想
 */
export const ConjectureContentSchema = z.object({
  type: z.literal('conjecture'),
  observationPrompt: z.string().min(1),
  examples: z.array(
    z.object({
      input: z.string(),
      output: z.string(),
    })
  ),
  conjecturePrompt: z.string().min(1),
  /** 反思问题（可选） */
  reflection: z.string().optional(),
});

/**
 * 应用步骤内容 Schema
 * 在新情境中迁移应用
 */
export const ApplicationContentSchema = z.object({
  type: z.literal('application'),
  instruction: z.string().min(1),
  /** 场景描述（可选） */
  scenario: z.string().optional(),
  variants: z.array(
    z.object({
      id: z.string(),
      question: z.string(),
      options: z.array(z.string()).optional(),
      correctAnswer: z.string(),
      /** 解析（可选） */
      explanation: z.string().optional(),
    })
  ),
  minCorrect: z.number().int().min(1).optional(),
});

/**
 * 验证步骤内容 Schema
 * 通过例子验证猜想
 */
export const VerificationContentSchema = z.object({
  type: z.literal('verification'),
  conjectureToVerify: z.string().min(1),
  testCases: z.array(
    z.object({
      input: z.string(),
      expectedOutput: z.string(),
    })
  ),
  verificationPrompt: z.string().min(1),
  feedbackConfig: z
    .object({
      showCounterExample: z.boolean().optional(),
      allowRetry: z.boolean().optional(),
    })
    .optional(),
});

// ==================== 完整步骤 Schema ====================

/**
 * 完成条件配置 Schema
 */
const CompletionCriteriaSchema = z.object({
  type: z.enum(['interactive', 'input', 'choice', 'verbal']),
  config: z.record(z.unknown()),
});

/**
 * 学习步骤 Schema
 * 定义完整的学习步骤结构
 */
export const LearningStepSchema = z.object({
  id: z.string().min(1),
  type: z.enum(['concrete', 'pictorial', 'symbolic', 'conjecture', 'verification', 'application']),
  name: z.string().min(1),
  instruction: z.string().min(1),
  content: z.discriminatedUnion('type', [
    ConcreteContentSchema,
    PictorialContentSchema,
    SymbolicContentSchema,
    ConjectureContentSchema,
    ApplicationContentSchema,
    VerificationContentSchema,
  ]),
  completionCriteria: CompletionCriteriaSchema,
  hintLevels: z.array(z.string()),
  ability: z.string().min(1),
});

/**
 * 知识点 Schema
 */
export const KnowledgePointSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  description: z.string().optional(),
  ability: z.string().min(1),
  grade: z.number().int().min(1).max(9),
  level: z.number().int().min(1).max(5),
  prerequisites: z.array(z.string()).optional(),
  stepCount: z.number().int().min(1),
});

// ==================== 类型导出 ====================

export type Scenario = z.infer<typeof ScenarioSchema>;
export type Interaction = z.infer<typeof InteractionSchema>;

export type SplitCircleConfig = z.infer<typeof SplitCircleConfigSchema>;
export type FractionBarConfig = z.infer<typeof FractionBarConfigSchema>;
export type ApplesConfig = z.infer<typeof ApplesConfigSchema>;
export type BalanceConfig = z.infer<typeof BalanceConfigSchema>;
export type RulerConfig = z.infer<typeof RulerConfigSchema>;
export type ShapesConfig = z.infer<typeof ShapesConfigSchema>;

export type ConcreteContent = z.infer<typeof ConcreteContentSchema>;
export type PictorialContent = z.infer<typeof PictorialContentSchema>;
export type SymbolicContent = z.infer<typeof SymbolicContentSchema>;
export type ConjectureContent = z.infer<typeof ConjectureContentSchema>;
export type ApplicationContent = z.infer<typeof ApplicationContentSchema>;
export type VerificationContent = z.infer<typeof VerificationContentSchema>;

export type LearningStep = z.infer<typeof LearningStepSchema>;
export type KnowledgePoint = z.infer<typeof KnowledgePointSchema>;
