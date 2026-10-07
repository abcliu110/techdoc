/**
 * 数学思维启发学习系统 - Schema 模块导出
 * @description 统一导出所有 Schema 类型定义
 */

// 学习会话 Schema
export {
  SessionStatusEnum,
  LearningPhaseEnum,
  PauseReasonEnum,
  TimestampSchema,
  StepProgressSchema,
  SessionConfigSchema,
  PerformanceMetricsSchema,
  LearningSessionSchema,
  type SessionStatus,
  type LearningPhase,
  type PauseReason,
  type Timestamp,
  type StepProgress,
  type SessionConfig,
  type PerformanceMetrics,
  type LearningSession
} from './learning-session.schema';

// 学习步骤 Schema
export {
  StepStatusEnum,
  InteractionStateEnum,
  InputTypeEnum,
  InteractionAttemptSchema,
  StepRuntimeStateSchema,
  StepExecutionContextSchema,
  StepTransitionSchema,
  type StepStatus,
  type InteractionState,
  type InputType,
  type InteractionAttempt,
  type StepRuntimeState,
  type StepExecutionContext,
  type StepTransition
} from './learning-step.schema';

// 学习证据 Schema
export {
  EvidenceTypeEnum,
  EvidenceSourceEnum,
  EvidenceConfidenceEnum,
  AnswerEvidenceSchema,
  InteractionEvidenceSchema,
  TimeSpentEvidenceSchema,
  HintUsageEvidenceSchema,
  ErrorPatternEvidenceSchema,
  StrategyChoiceEvidenceSchema,
  EmotionalEvidenceSchema,
  LearningEvidenceSchema,
  EvidenceBatchSchema,
  type EvidenceType,
  type EvidenceSource,
  type EvidenceConfidence,
  type AnswerEvidence,
  type InteractionEvidence,
  type TimeSpentEvidence,
  type HintUsageEvidence,
  type ErrorPatternEvidence,
  type StrategyChoiceEvidence,
  type EmotionalEvidence,
  type LearningEvidence,
  type EvidenceBatch
} from './learning-evidence.schema';

// 能力画像 Schema
export {
  ThoughtLineEnum,
  CognitiveLevelEnum,
  AbilityAssessmentStatusEnum,
  AbilityLevelEnum,
  PercentageRangeSchema,
  DimensionAbilitySchema,
  ThoughtLineAbilitySchema,
  LearningProgressSchema,
  AbilityProfileSchema,
  AbilityComparisonSchema,
  type ThoughtLine,
  type CognitiveLevel,
  type AbilityAssessmentStatus,
  type AbilityLevel,
  type PercentageRange,
  type DimensionAbility,
  type ThoughtLineAbility,
  type LearningProgress,
  type AbilityProfile,
  type AbilityComparison
} from './ability-profile.schema';

// 内容包 Schema
export {
  ContentStatusEnum,
  GradeLevelEnum,
  ContentVersionSchema,
  ContentMetaSchema,
  LearningObjectiveSchema,
  StepDefinitionSchema,
  VisualizationConfigSchema,
  InteractionConfigSchema,
  FeedbackConfigSchema,
  StepContentSchema,
  PrerequisiteConditionSchema,
  StepRouteSchema,
  ContentPackageSchema,
  ContentPackageRefSchema,
  type ContentStatus,
  type GradeLevel,
  type ContentVersion,
  type ContentMeta,
  type LearningObjective,
  type StepDefinition,
  type VisualizationConfig,
  type InteractionConfig,
  type FeedbackConfig,
  type StepContent,
  type PrerequisiteCondition,
  type StepRoute,
  type ContentPackage,
  type ContentPackageRef
} from './content-package.schema';

// 数学概念 Schema
export {
  MathDomainEnum,
  ConceptHierarchyEnum,
  UnderstandingLevelEnum,
  ConceptDescriptionSchema,
  RepresentationSchema,
  ConceptRelationSchema,
  MathConceptSchema,
  ConceptUnderstandingSchema,
  ConceptNetworkNodeSchema,
  ConceptNetworkEdgeSchema,
  ConceptNetworkSchema,
  type MathDomain,
  type ConceptHierarchy,
  type UnderstandingLevel,
  type ConceptDescription,
  type Representation,
  type RelationType,
  type ConceptRelation,
  type MathConcept,
  type ConceptUnderstanding,
  type ConceptNetworkNode,
  type ConceptNetworkEdge,
  type ConceptNetwork
} from './math-concept.schema';
