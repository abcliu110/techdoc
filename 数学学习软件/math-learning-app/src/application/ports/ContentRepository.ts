import type { LearningStep } from '../../domain/types/learning-step';

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
 * 定义学习内容数据的加载契约
 */
export interface ContentRepository {
  /**
   * 获取知识点元信息列表
   */
  listKnowledgePoints(): Promise<KnowledgePointMeta[]>;

  /**
   * 获取知识点定义
   */
  findKnowledgePoint(id: string): Promise<KnowledgePointMeta | null>;

  /**
   * 获取知识点下的所有步骤
   */
  findSteps(knowledgePointId: string): Promise<LearningStep[]>;

  /**
   * 获取指定步骤
   */
  findStep(stepId: string): Promise<LearningStep | null>;
}
