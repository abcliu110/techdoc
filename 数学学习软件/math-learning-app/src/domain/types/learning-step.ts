import type { Ability } from './ability';

/**
 * 步骤类型枚举
 */
export enum StepType {
  /** 具象操作 */
  CONCRETE = 'concrete',
  /** 图示表达 */
  PICTORIAL = 'pictorial',
  /** 符号表示 */
  SYMBOLIC = 'symbolic',
  /** 猜想 */
  CONJECTURE = 'conjecture',
  /** 验证 */
  VERIFICATION = 'verification',
  /** 迁移应用 */
  APPLICATION = 'application',
}

/**
 * 学习步骤定义（内容层，不含运行时状态）
 */
export interface LearningStep {
  /** 步骤唯一标识 */
  readonly id: string;
  /** 步骤类型 */
  readonly type: StepType;
  /** 步骤名称 */
  readonly name: string;
  /** 步骤说明 */
  readonly instruction: string;
  /** 步骤内容 */
  readonly content: StepContent;
  /** 过关条件 */
  readonly completionCriteria: CompletionCriteria;
  /** 提示层级 */
  readonly hintLevels: string[];
  /** 关联的能力 */
  readonly ability: Ability;
}

/**
 * 步骤内容联合类型
 */
export type StepContent =
  | ConcreteContent
  | PictorialContent
  | SymbolicContent
  | ConjectureContent
  | VerificationContent
  | ApplicationContent;

/** 具象操作内容 */
export interface ConcreteContent {
  type: 'concrete';
  scenario: {
    title: string;
    description: string;
    emoji: string;
  };
  interaction: {
    kind: 'drag' | 'tap' | 'draw' | 'split' | 'select';
    target: string;
    visualType: string;
    visualConfig: Record<string, unknown>;
  };
}

/** 图示表达内容 */
export interface PictorialContent {
  type: 'pictorial';
  task: string;
  visualType: string;
  visualConfig: Record<string, unknown>;
  outputFormat: 'draw' | 'select' | 'arrange';
}

/** 符号表示内容 */
export interface SymbolicContent {
  type: 'symbolic';
  instruction: string;
  inputType: 'fraction' | 'expression' | 'equation';
  expectedAnswer: string | string[];
  equivalenceRules?: EquivalenceRule[];
}

/** 猜想内容 */
export interface ConjectureContent {
  type: 'conjecture';
  observationPrompt: string;
  examples: ObservationExample[];
  conjecturePrompt: string;
}

/** 观察示例 */
export interface ObservationExample {
  input: string;
  output: string;
}

/** 迁移应用内容 */
export interface ApplicationContent {
  type: 'application';
  instruction: string;
  variants: VariantItem[];
  minCorrect: number;
}

/** 验证内容 */
export interface VerificationContent {
  type: 'verification';
  instruction: string;
  conjectureToVerify?: string;
  hypothesis?: string;
  testCases: VerificationTestCase[];
  verificationPrompt?: string;
  feedbackConfig?: {
    showCounterExample?: boolean;
    allowRetry?: boolean;
  };
}

/** 验证测试用例 */
export interface VerificationTestCase {
  id?: string;
  input: string;
  expectedOutput: string;
  visualType?: string;
  visualConfig?: Record<string, unknown>;
}

/** 变式题目 */
export interface VariantItem {
  id: string;
  question: string;
  options?: string[];
  correctAnswer: string;
}

/**
 * 过关条件
 */
export interface CompletionCriteria {
  type: CompletionType;
  config: InteractiveConfig | InputConfig | ChoiceConfig | VerbalConfig;
}

/**
 * 过关条件类型
 */
export enum CompletionType {
  /** 交互达标 */
  INTERACTIVE = 'interactive',
  /** 输入判定 */
  INPUT = 'input',
  /** 选择判定 */
  CHOICE = 'choice',
  /** 语言描述判定 */
  VERBAL = 'verbal',
}

/** 交互达标配置 */
export interface InteractiveConfig {
  requiredInteraction: string;
  tolerance?: number;
}

/** 输入判定配置 */
export interface InputConfig {
  expectedAnswers: string[];
  equivalenceRules?: EquivalenceRule[];
  tolerance?: number;
}

/** 选择判定配置 */
export interface ChoiceConfig {
  correctIndex: number;
  shuffle: boolean;
}

/** 语言描述配置 */
export interface VerbalConfig {
  minLength: number;
  expectedKeywords: string[];
  minKeywords: number;
  requireLogicalConnectors: boolean;
}

/**
 * 等价规则
 */
export interface EquivalenceRule {
  name: string;
  pattern: string;
  replacement: string;
}
