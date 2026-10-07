/**
 * 领域类型定义
 * @description 包含所有核心领域类型：枚举、接口、实体
 */

// ==================== 枚举类型 ====================

/**
 * 学习会话状态枚举
 */
export enum SessionStatus {
  /** 已创建 */
  CREATED = 'created',
  /** 进行中 */
  IN_PROGRESS = 'in_progress',
  /** 已暂停 */
  PAUSED = 'paused',
  /** 已完成 */
  COMPLETED = 'completed',
  /** 已放弃 */
  ABANDONED = 'abandoned',
}

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
  /** 应用 */
  APPLICATION = 'application',
}

/**
 * 数学能力枚举（五大数学思想主线）
 */
export enum Ability {
  /** 数形结合 */
  NUMBER_SHAPE_INTEGRATION = 'number-shape-integration',
  /** 单位统一 */
  UNIT_UNIFICATION = 'unit-unification',
  /** 整体与部分 */
  WHOLE_PART = 'whole-part',
  /** 转化与化归 */
  TRANSFORMATION = 'transformation',
  /** 等量关系与方程 */
  EQUATION_BALANCE = 'equation-balance',
}

/**
 * 能力等级枚举
 */
export enum AbilityLevel {
  /** 未开始 */
  NOT_STARTED = 0,
  /** 初步感知 */
  AWARE = 1,
  /** 正在发展 */
  DEVELOPING = 2,
  /** 已掌握 */
  MASTERED = 3,
}

/**
 * 证据类型枚举
 */
export enum EvidenceType {
  /** 观察证据 */
  OBSERVATION = 'observation',
  /** 表示证据 */
  REPRESENTATION = 'representation',
  /** 比较证据 */
  COMPARISON = 'comparison',
  /** 猜想证据 */
  CONJECTURE = 'conjecture',
  /** 验证证据 */
  VERIFICATION = 'verification',
  /** 迁移证据 */
  TRANSFER = 'transfer',
  /** 反思证据 */
  REFLECTION = 'reflection',
}

// ==================== 实体类型 ====================

/**
 * 学习会话实体
 * @description 表示一个完整的学习会话，包含会话状态、步骤进度和学习证据
 */
export interface LearningSession {
  /** 会话唯一标识 */
  readonly id: string;
  /** 知识点ID */
  readonly knowledgePointId: string;
  /** 关联的数学能力 */
  readonly ability: Ability;
  /** 当前会话状态 */
  status: SessionStatus;
  /** 当前步骤索引 */
  currentStepIndex: number;
  /** 会话开始时间戳 */
  startedAt: number;
  /** 暂停时间戳 */
  pausedAt?: number;
  /** 完成时间戳 */
  completedAt?: number;
  /** 学习证据列表 */
  evidence: LearningEvidence[];
}

/**
 * 学习步骤实体
 * @description 定义一个学习步骤的内容、类型和完成条件
 */
export interface LearningStep {
  /** 步骤唯一标识 */
  readonly id: string;
  /** 步骤类型 */
  readonly type: StepType;
  /** 步骤名称 */
  readonly name: string;
  /** 步骤说明/指令 */
  readonly instruction: string;
  /** 步骤内容（具体内容根据type而定） */
  readonly content: StepContent;
  /** 完成条件 */
  readonly completionCriteria: CompletionCriteria;
  /** 提示层级列表 */
  readonly hintLevels: string[];
  /** 关联的能力 */
  readonly ability: Ability;
}

/**
 * 学习证据实体
 * @description 记录学习过程中的关键表现证据
 */
export interface LearningEvidence {
  /** 证据唯一标识 */
  readonly id: string;
  /** 关联的步骤ID */
  readonly stepId: string;
  /** 证据类型 */
  readonly type: EvidenceType;
  /** 证据数据 */
  readonly data: EvidenceData;
  /** 证据时间戳 */
  readonly timestamp: number;
}

/**
 * 能力画像实体
 * @description 记录用户在各能力维度上的发展状态
 */
export interface AbilityProfile {
  /** 用户ID */
  readonly userId: string;
  /** 能力状态列表 */
  states: AbilityState[];
  /** 能力画像更新时间 */
  updatedAt: number;
}

/**
 * 能力状态值对象
 */
export interface AbilityState {
  /** 能力类型 */
  ability: Ability;
  /** 当前等级 */
  level: AbilityLevel;
  /** 证据数量 */
  evidenceCount: number;
  /** 最后练习时间 */
  lastPracticedAt: number;
}

// ==================== 内容类型 ====================

/**
 * 步骤内容联合类型
 */
export type StepContent =
  | ConcreteContent
  | PictorialContent
  | SymbolicContent
  | ConjectureContent
  | ApplicationContent;

/**
 * 具象操作内容
 */
export interface ConcreteContent {
  type: 'concrete';
  /** 场景信息 */
  scenario: {
    title: string;
    description: string;
    emoji: string;
  };
  /** 交互配置 */
  interaction: {
    kind: 'drag' | 'tap' | 'draw' | 'split' | 'select';
    target: string;
    visualType: string;
    visualConfig: Record<string, unknown>;
  };
}

/**
 * 图示表达内容
 */
export interface PictorialContent {
  type: 'pictorial';
  task: string;
  visualType: string;
  visualConfig: Record<string, unknown>;
  outputFormat: 'draw' | 'select' | 'arrange';
}

/**
 * 符号表示内容
 */
export interface SymbolicContent {
  type: 'symbolic';
  instruction: string;
  inputType: 'fraction' | 'expression' | 'equation';
  expectedAnswer: string | string[];
}

/**
 * 猜想内容
 */
export interface ConjectureContent {
  type: 'conjecture';
  observationPrompt: string;
  examples: Array<{ input: string; output: string }>;
  conjecturePrompt: string;
}

/**
 * 应用内容
 */
export interface ApplicationContent {
  type: 'application';
  instruction: string;
  variants: Array<{
    id: string;
    question: string;
    options?: string[];
    correctAnswer: string;
  }>;
  minCorrect: number;
}

// ==================== 完成条件类型 ====================

/**
 * 完成条件接口
 */
export interface CompletionCriteria {
  type: CompletionType;
  config: CompletionConfig;
}

/**
 * 完成条件类型枚举
 */
export enum CompletionType {
  /** 交互完成 */
  INTERACTIVE = 'interactive',
  /** 输入验证 */
  INPUT = 'input',
  /** 选择判断 */
  CHOICE = 'choice',
  /** 语言描述 */
  VERBAL = 'verbal',
}

/**
 * 完成条件配置联合类型
 */
export type CompletionConfig =
  | { type: string; requiredInteraction?: string }
  | { type: string; expectedAnswers?: string[] }
  | { type: string; correctIndex?: number }
  | { type: string; minKeywords?: number };

// ==================== 证据数据类型 ====================

/**
 * 证据数据联合类型
 */
export type EvidenceData =
  | OperationEvidence
  | AnswerEvidence
  | HintUsageEvidence
  | TransferEvidence;

/**
 * 操作证据
 */
export interface OperationEvidence {
  type: EvidenceType;
  interactionKind: 'drag' | 'tap' | 'draw' | 'split' | 'select';
  result: Record<string, unknown>;
  attempts: number;
}

/**
 * 答案证据
 */
export interface AnswerEvidence {
  type: EvidenceType;
  answer: string;
  isCorrect: boolean;
  attempts: number;
}

/**
 * 提示使用证据
 */
export interface HintUsageEvidence {
  type: EvidenceType;
  hintsUsed: number;
  hintLevels: string[];
}

/**
 * 迁移证据
 */
export interface TransferEvidence {
  type: EvidenceType;
  originalProblem: string;
  transferredProblem: string;
  success: boolean;
}

// ==================== 雷达图数据类型 ====================

/**
 * 雷达图数据点
 */
export interface RadarDataPoint {
  ability: Ability;
  level: number;
  maxLevel: number;
  label: string;
}

/**
 * 能力信息（用于首页展示）
 */
export interface AbilityInfo {
  id: Ability;
  name: string;
  description: string;
  color: string;
  icon: string;
  stepCount: number;
}

/**
 * 知识点元信息
 */
export interface KnowledgePointMeta {
  id: string;
  name: string;
  description: string;
  ability: Ability;
  grade: number;
  level: number;
  stepCount: number;
}
