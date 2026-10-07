import { z } from 'zod';

// ==================== 场景 Schema ====================

const ScenarioSchema = z.object({
  title: z.string().min(1),
  description: z.string().min(1),
  emoji: z.string().optional(),
});

// ==================== 交互配置 Schema ====================

const InteractionSchema = z.object({
  kind: z.enum(['drag', 'tap', 'draw', 'split', 'select']),
  target: z.string().min(1),
  visualType: z.string().min(1),
  visualConfig: z.record(z.unknown()).optional(),
});

// ==================== 步骤内容 Schema ====================

const ConcreteContentSchema = z.object({
  type: z.literal('concrete'),
  scenario: ScenarioSchema,
  interaction: InteractionSchema,
});

const PictorialContentSchema = z.object({
  type: z.literal('pictorial'),
  task: z.string().min(1),
  visualType: z.string().min(1),
  visualConfig: z.object({
    // 通用字段
    totalApples: z.number().optional(),
    itemsPerRow: z.number().optional(),
    size: z.number().optional(),
    appleColor: z.string().optional(),
    badApples: z.array(z.number()).optional(),
    // highlightRange: 数组格式 [start, end]
    highlightRange: z.tuple([z.number(), z.number()]).optional(),
    // 分割圆配置
    circles: z.array(z.object({
      denominator: z.number(),
      highlighted: z.array(z.number()),
      label: z.string().optional(),
    })).optional(),
    // 分数条配置
    fractions: z.array(z.object({
      id: z.string(),
      numerator: z.number(),
      denominator: z.number(),
      label: z.string().optional(),
      color: z.string().optional(),
    })).optional(),
    showUnit: z.boolean().optional(),
    alignment: z.enum(['bottom', 'top', 'center']).optional(),
    // 形状配置
    shapes: z.array(z.object({
      type: z.enum(['circle', 'square', 'triangle', 'rectangle']),
      count: z.number(),
      label: z.string().optional(),
      color: z.string().optional(),
      highlighted: z.boolean().optional(),
    })).optional(),
    // 数轴/刻度尺配置
    marks: z.array(z.object({
      value: z.number(),
      isMajor: z.boolean().optional(),
      label: z.string().optional(),
    })).optional(),
    minValue: z.number().optional(),
    maxValue: z.number().optional(),
    unit: z.string().optional(),
    orientation: z.enum(['horizontal', 'vertical']).optional(),
    highlightedRange: z.tuple([z.number(), z.number()]).optional(),
    // 可选项目（用于 draw/select/arrange）
    availableItems: z.array(z.string()).optional(),
    itemCount: z.number().optional(),
  }).optional(),
  outputFormat: z.enum(['draw', 'select', 'arrange']),
});

const SymbolicContentSchema = z.object({
  type: z.literal('symbolic'),
  // instruction 字段已在步骤级别定义，content 内部不需要重复
  inputType: z.enum(['fraction', 'expression', 'equation']),
  expectedAnswer: z.union([z.string(), z.array(z.string())]),
  equivalenceRules: z
    .array(
      z.object({
        name: z.string(),
        pattern: z.string(),
        replacement: z.string(),
      })
    )
    .optional(),
  // 实际 JSON 中可能存在的额外字段（可选）
  method: z.string().optional(),
  steps: z.array(z.string()).optional(),
});

const ConjectureContentSchema = z.object({
  type: z.literal('conjecture'),
  observationPrompt: z.string().min(1),
  examples: z.array(
    z.object({
      input: z.string(),
      output: z.string(),
    })
  ),
  conjecturePrompt: z.string().min(1),
});

const ApplicationContentSchema = z.object({
  type: z.literal('application'),
  instruction: z.string().min(1),
  variants: z.array(
    z.object({
      id: z.string(),
      question: z.string(),
      options: z.array(z.string()).optional(),
      correctAnswer: z.string(),
    })
  ),
  minCorrect: z.number().min(1),
});

const VerificationContentSchema = z.object({
  type: z.literal('verification'),
  conjectureToVerify: z.string().min(1),
  testCases: z.array(
    z.object({
      input: z.string(),
      expectedOutput: z.string(),
    })
  ),
  verificationPrompt: z.string().min(1),
  feedbackConfig: z.object({
    showCounterExample: z.boolean().optional(),
    allowRetry: z.boolean().optional(),
  }).optional(),
});

// ==================== 步骤 Schema ====================

const CompletionCriteriaSchema = z.object({
  type: z.enum(['interactive', 'input', 'choice', 'verbal']),
  config: z.record(z.unknown()),
});

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

// ==================== 知识点 Schema ====================

export const KnowledgePointSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  description: z.string().optional(),
  ability: z.string().min(1),
  grade: z.number().min(1).max(9),
  level: z.number().min(1).max(5),
  prerequisites: z.array(z.string()).optional(),
  stepCount: z.number().min(1),
});

export type KnowledgePoint = z.infer<typeof KnowledgePointSchema>;
export type LearningStepType = z.infer<typeof LearningStepSchema>;

// ==================== 验证函数 ====================

export function validateKnowledgePoint(data: unknown): KnowledgePoint {
  return KnowledgePointSchema.parse(data);
}

export function validateLearningStep(data: unknown): LearningStepType {
  return LearningStepSchema.parse(data);
}
