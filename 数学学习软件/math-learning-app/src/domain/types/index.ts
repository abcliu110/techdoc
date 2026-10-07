// 领域层类型统一导出

// 能力相关类型
export {
  Ability,
  AbilityLevel,
  type AbilityState,
} from './ability';

// 学习会话相关类型
export {
  SessionStatus,
  EvidenceType,
  type LearningSession,
  type SessionSnapshot,
  type LearningEvidence,
  type EvidenceData,
  type OperationEvidence,
  type AnswerEvidence,
  type ExplanationEvidence,
  type HintUsageEvidence,
  type TransferEvidence,
} from './learning-session';

// 学习步骤相关类型
export {
  StepType,
  CompletionType,
  type LearningStep,
  type StepContent,
  type ConcreteContent,
  type PictorialContent,
  type SymbolicContent,
  type ConjectureContent,
  type VerificationContent,
  type ApplicationContent,
  type ObservationExample,
  type VariantItem,
  type CompletionCriteria,
  type InteractiveConfig,
  type InputConfig,
  type ChoiceConfig,
  type VerbalConfig,
  type EquivalenceRule,
  type VerificationTestCase,
} from './learning-step';

// 能力画像相关类型
export {
  type AbilityProfile,
  type ProfileResult,
  type RadarDataPoint,
  type TrendDataPoint,
} from './ability-profile';
