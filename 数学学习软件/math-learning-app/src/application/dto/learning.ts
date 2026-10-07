/**
 * 学习相关 DTO 统一导出
 */
export interface StartSessionDTO {
  userId: string;
  knowledgePointId: string;
}

export interface CompleteStepDTO {
  sessionId: string;
  stepData: Record<string, unknown>;
  interactionKind?: 'drag' | 'tap' | 'draw' | 'split' | 'select';
}

export interface RecordEvidenceDTO {
  sessionId: string;
  evidenceType: 'operation' | 'answer' | 'explanation' | 'hint-usage' | 'transfer';
  data: Record<string, unknown>;
}
