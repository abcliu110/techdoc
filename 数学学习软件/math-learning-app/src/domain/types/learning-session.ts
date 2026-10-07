import type { Ability } from './ability';

/**
 * 学习会话状态枚举
 */
export enum SessionStatus {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  ABANDONED = 'abandoned',
}

/**
 * 学习会话聚合根
 */
export interface LearningSession {
  /** 会话唯一标识 */
  readonly id: string;
  /** 知识点 ID */
  readonly knowledgePointId: string;
  /** 数学思想 */
  readonly ability: Ability;
  /** 当前状态 */
  status: SessionStatus;
  /** 当前步骤索引 */
  currentStepIndex: number;
  /** 开始时间 */
  startedAt: number;
  /** 创建时间 */
  createdAt?: number;
  /** 更新时间 */
  updatedAt?: number;
  /** 暂停时间（暂停时记录） */
  pausedAt?: number;
  /** 完成时间 */
  completedAt?: number;
  /** 放弃时间 */
  abandonedAt?: number;
  /** 已记录的证据 */
  evidence: LearningEvidence[];
  /** 暂停时的快照数据 */
  snapshot?: SessionSnapshot;
}

/**
 * 会话快照（用于暂停恢复）
 */
export interface SessionSnapshot {
  stepIndex: number;
  stepData: Record<string, unknown>;
  timestamp: number;
}

/**
 * 学习证据值对象
 */
export interface LearningEvidence {
  /** 证据唯一标识 */
  readonly id: string;
  /** 步骤 ID */
  readonly stepId: string;
  /** 会话 ID（用于数据库关联） */
  sessionId?: string;
  /** 证据类型 */
  readonly type: EvidenceType;
  /** 证据数据 */
  readonly data: EvidenceData;
  /** 时间戳 */
  readonly timestamp: number;
}

/**
 * 证据类型枚举
 */
export enum EvidenceType {
  /** 操作证据 */
  OPERATION = 'operation',
  /** 答案证据 */
  ANSWER = 'answer',
  /** 解释证据 */
  EXPLANATION = 'explanation',
  /** 提示使用证据 */
  HINT_USAGE = 'hint_usage',
  /** 迁移表现证据 */
  TRANSFER = 'transfer',
}

/**
 * 证据数据（联合类型）
 */
export type EvidenceData =
  | OperationEvidence
  | AnswerEvidence
  | ExplanationEvidence
  | HintUsageEvidence
  | TransferEvidence;

/** 操作证据 */
export interface OperationEvidence {
  type: EvidenceType.OPERATION;
  interactionKind: 'drag' | 'tap' | 'draw' | 'split' | 'select';
  result: Record<string, unknown>;
  attempts: number;
}

/** 答案证据 */
export interface AnswerEvidence {
  type: EvidenceType.ANSWER;
  answer: string;
  isCorrect: boolean;
  attempts: number;
}

/** 解释证据 */
export interface ExplanationEvidence {
  type: EvidenceType.EXPLANATION;
  text: string;
  keywords: string[];
  hasLogicalConnectors: boolean;
}

/** 提示使用证据 */
export interface HintUsageEvidence {
  type: EvidenceType.HINT_USAGE;
  hintsUsed: number;
  hintLevels: string[];
}

/** 迁移表现证据 */
export interface TransferEvidence {
  type: EvidenceType.TRANSFER;
  originalProblem: string;
  transferredProblem: string;
  success: boolean;
}
