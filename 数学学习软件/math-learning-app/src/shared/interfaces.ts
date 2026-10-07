/**
 * 共享接口定义
 * 本文件是整个项目的接口契约，所有模块必须遵循
 * 版本：v1.0.0
 * 更新日期：2026-10-06
 */

// ==================== 转发 domain 层类型 ====================

// 学习会话相关
import type {
  LearningSession,
  LearningEvidence,
  SessionSnapshot,
  EvidenceData,
  OperationEvidence,
  AnswerEvidence,
  ExplanationEvidence,
  HintUsageEvidence,
  TransferEvidence,
} from '../domain/types/learning-session';

import { SessionStatus, EvidenceType } from '../domain/types/learning-session';

// 能力相关
import type {
  AbilityProfile,
  AbilityState,
  ProfileResult,
  RadarDataPoint,
  TrendDataPoint,
} from '../domain/types/ability-profile';

import { Ability, AbilityLevel } from '../domain/types/ability';

// 学习步骤相关
import type {
  LearningStep,
  StepContent,
  ConcreteContent,
  PictorialContent,
  SymbolicContent,
  ConjectureContent,
  VerificationContent,
  ApplicationContent,
  ObservationExample,
  VariantItem,
  CompletionCriteria,
  CompletionType,
  InteractiveConfig,
  InputConfig,
  ChoiceConfig,
  VerbalConfig,
  EquivalenceRule,
  VerificationTestCase,
} from '../domain/types/learning-step';

import { StepType } from '../domain/types/learning-step';

export type {
  LearningSession,
  LearningEvidence,
  SessionSnapshot,
  EvidenceData,
  OperationEvidence,
  AnswerEvidence,
  ExplanationEvidence,
  HintUsageEvidence,
  TransferEvidence,
};

export { SessionStatus, EvidenceType };

export type {
  AbilityProfile,
  AbilityState,
  ProfileResult,
  RadarDataPoint,
  TrendDataPoint,
};

export { Ability, AbilityLevel };

export type {
  LearningStep,
  StepContent,
  ConcreteContent,
  PictorialContent,
  SymbolicContent,
  ConjectureContent,
  VerificationContent,
  ApplicationContent,
  ObservationExample,
  VariantItem,
  CompletionCriteria,
  CompletionType,
  InteractiveConfig,
  InputConfig,
  ChoiceConfig,
  VerbalConfig,
  EquivalenceRule,
  VerificationTestCase,
};

export { StepType };

// ==================== 能力报告接口 ====================

/**
 * 能力报告聚合视图
 * 用于能力报告页面展示
 */
export interface AbilityReport {
  /** 能力画像 */
  profile: AbilityProfile;
  /** 雷达图数据 */
  radarData: RadarDataPoint[];
  /** 成长趋势数据 */
  trend: TrendDataPoint[];
  /** 常见错误类型 */
  commonMistakes: string[];
  /** 下一步学习建议 */
  recommendations: string[];
}

// ==================== 步骤组件接口 ====================

/**
 * 步骤组件Props接口
 * 所有步骤类型组件必须实现的统一接口
 */
export interface StepComponentProps {
  content: StepContent;
  stepName: string;
  stepIndex: number;
  totalSteps?: number;
  hintLevels: string[];
  onComplete: (data: Record<string, unknown>) => void;
  onHint?: () => void;
  isCompleted?: boolean;
  currentHintLevel?: number;
}

// ==================== Repository 接口 ====================

/**
 * 知识点元信息
 */
export interface KnowledgePointMeta {
  id: string;
  name: string;
  description: string;
  ability: string;
  grade: number;
  level: number;
  prerequisites: string[];
  stepCount: number;
}

/**
 * 内容仓储接口
 */
export interface ContentRepository {
  listKnowledgePoints(): Promise<KnowledgePointMeta[]>;
  findKnowledgePoint(id: string): Promise<KnowledgePointMeta | null>;
  findSteps(knowledgePointId: string): Promise<LearningStep[]>;
  findStep(stepId: string): Promise<LearningStep | null>;
}

/**
 * 会话仓储接口
 */
export interface SessionRepository {
  initialize?(): Promise<void>;
  createSession(knowledgePointId: string): Promise<LearningSession>;
  getSession(sessionId: string): Promise<LearningSession | null>;
  updateSessionProgress(sessionId: string, stepIndex: number): Promise<void>;
  recordEvidence(sessionId: string, evidence: LearningEvidence): Promise<void>;
  getSessionEvidence(sessionId: string): Promise<LearningEvidence[]>;
  delete(sessionId: string): Promise<void>;
  completeSession?(sessionId: string): Promise<void>;
  /**
   * 恢复未完成的会话
   * 用于从 IndexedDB/SQLite 恢复中断的学习会话
   * @returns 未完成状态的所有会话列表（按最近更新时间倒序）
   */
  resumeSession?(): Promise<LearningSession[]>;
  /**
   * 获取用户最近的未完成会话
   */
  getLatestIncompleteSession?(): Promise<LearningSession | null>;
  /**
   * 获取用户所有会话列表（分页）
   */
  listUserSessions?(limit?: number, offset?: number): Promise<LearningSession[]>;
  /**
   * 按时间范围查询证据
   */
  getEvidenceByTimeRange?(startTime: number, endTime: number): Promise<LearningEvidence[]>;
  /**
   * 按证据类型查询
   */
  getEvidenceByType?(type: string): Promise<LearningEvidence[]>;
  /**
   * 获取能力相关的证据统计
   */
  getAbilityEvidenceStats?(): Promise<Record<string, number>>;
}

/**
 * 画像仓储接口
 */
export interface ProfileRepository {
  initialize?(): Promise<void>;
  getProfile(userId: string): Promise<AbilityProfile | null>;
  updateProfile(profile: AbilityProfile): Promise<void>;
  /**
   * 批量更新能力状态
   */
  batchUpdateAbilities?(userId: string, updates: Partial<{ ability: string }>[]): Promise<void>;
  /**
   * 获取能力成长趋势
   */
  getAbilityTrend?(userId: string, days?: number): Promise<TrendDataPoint[]>;
}

// ==================== 其他接口 ====================

/**
 * 分割圆可视化配置
 */
export interface SplitCircleConfig {
  totalSlices: number;
  highlightedSlices: number[];
  colors: string[];
  radius?: number;
}

/**
 * 分数面积图配置
 */
export interface FractionAreaConfig {
  fractions: Array<{
    numerator: number;
    denominator: number;
    label?: string;
  }>;
  comparisonType?: 'area' | 'bar';
}

/**
 * 验证器接口
 */
export interface Validator {
  validate(input: unknown, criteria: CompletionCriteria): ValidationResult;
}

/**
 * 验证结果
 */
export interface ValidationResult {
  valid: boolean;
  message?: string;
  errors?: string[];
  equivalenceGroup?: string;
}
