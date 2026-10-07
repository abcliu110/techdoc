import type { ContentRepository } from '../../application/ports/ContentRepository';
import type { KnowledgePointMeta } from '../../shared/interfaces';
import type { LearningStep } from '../../domain/types/learning-step';
import { LearningStepSchema } from '../../shared/schemas';
import { validateAndLog } from '../../shared/validate';

// 元数据导入
import fractionMetaData from '../../content/kps/fraction-comparison/meta.json';
import unitMetaData from '../../content/kps/unit-unification/meta.json';
import wholePartMetaData from '../../content/kps/whole-part-thinking/meta.json';
import transformationMetaData from '../../content/kps/transformation/meta.json';
import equationMetaData from '../../content/kps/equation-reasoning/meta.json';

// 数形结合 - 分数比较 步骤导入
import fracConcrete from '../../content/kps/fraction-comparison/steps/concrete.json';
import fracPictorial from '../../content/kps/fraction-comparison/steps/pictorial.json';
import fracSymbolic from '../../content/kps/fraction-comparison/steps/symbolic.json';
import fracConjecture from '../../content/kps/fraction-comparison/steps/conjecture.json';
import fracVerification from '../../content/kps/fraction-comparison/steps/verification.json';
import fracApplication from '../../content/kps/fraction-comparison/steps/application.json';

// 单位统一 步骤导入
import unitConcrete from '../../content/kps/unit-unification/steps/concrete.json';
import unitPictorial from '../../content/kps/unit-unification/steps/pictorial.json';
import unitSymbolic from '../../content/kps/unit-unification/steps/symbolic.json';
import unitConjecture from '../../content/kps/unit-unification/steps/conjecture.json';
import unitApplication from '../../content/kps/unit-unification/steps/application.json';

// 整体与部分 步骤导入
import wholeConcrete from '../../content/kps/whole-part-thinking/steps/concrete.json';
import wholePictorial from '../../content/kps/whole-part-thinking/steps/pictorial.json';
import wholeSymbolic from '../../content/kps/whole-part-thinking/steps/symbolic.json';
import wholeConjecture from '../../content/kps/whole-part-thinking/steps/conjecture.json';
import wholeApplication from '../../content/kps/whole-part-thinking/steps/application.json';

// 转化与化归 步骤导入
import transConcrete from '../../content/kps/transformation/steps/concrete.json';
import transPictorial from '../../content/kps/transformation/steps/pictorial.json';
import transSymbolic from '../../content/kps/transformation/steps/symbolic.json';
import transConjecture from '../../content/kps/transformation/steps/conjecture.json';
import transApplication from '../../content/kps/transformation/steps/application.json';

// 等量关系与方程 步骤导入
import eqConcrete from '../../content/kps/equation-reasoning/steps/concrete.json';
import eqPictorial from '../../content/kps/equation-reasoning/steps/pictorial.json';
import eqSymbolic from '../../content/kps/equation-reasoning/steps/symbolic.json';
import eqConjecture from '../../content/kps/equation-reasoning/steps/conjecture.json';
import eqApplication from '../../content/kps/equation-reasoning/steps/application.json';

/**
 * 文件系统内容仓储实现
 * 从 JSON 文件加载学习内容
 */
export class FileSystemContentRepository implements ContentRepository {
  private knowledgePoints: KnowledgePointMeta[] = [
    fractionMetaData as KnowledgePointMeta,
    unitMetaData as KnowledgePointMeta,
    wholePartMetaData as KnowledgePointMeta,
    transformationMetaData as KnowledgePointMeta,
    equationMetaData as KnowledgePointMeta,
  ];

  private steps: Map<string, LearningStep[]> = new Map();

  constructor() {
    this.loadSteps();
  }

  /**
   * 加载所有知识点对应的步骤
   */
  private loadSteps(): void {
    // 步骤数据映射
    const stepDataMap: Record<string, unknown[]> = {
      'fraction-comparison': [
        fracConcrete, fracPictorial, fracSymbolic, fracConjecture, fracVerification, fracApplication,
      ],
      'unit-unification': [
        unitConcrete, unitPictorial, unitSymbolic, unitConjecture, unitApplication,
      ],
      'whole-part-thinking': [
        wholeConcrete, wholePictorial, wholeSymbolic, wholeConjecture, wholeApplication,
      ],
      'transformation': [
        transConcrete, transPictorial, transSymbolic, transConjecture, transApplication,
      ],
      'equation-reasoning': [
        eqConcrete, eqPictorial, eqSymbolic, eqConjecture, eqApplication,
      ],
    };

    // 批量验证并加载步骤
    for (const [kpId, steps] of Object.entries(stepDataMap)) {
      const validatedSteps: LearningStep[] = [];

      for (let i = 0; i < steps.length; i++) {
        const step = steps[i];
        const stepId = (step as { id?: string }).id ?? `${kpId}-step-${i}`;

        if (validateAndLog(step, LearningStepSchema, `Step[${stepId}]`)) {
          validatedSteps.push(step as unknown as LearningStep);
        } else {
          console.warn(`[FileSystemContentRepository] Skipping invalid step: ${stepId}`);
        }
      }

      this.steps.set(kpId, validatedSteps);
    }
  }

  async listKnowledgePoints(): Promise<KnowledgePointMeta[]> {
    return this.knowledgePoints;
  }

  async findKnowledgePoint(id: string): Promise<KnowledgePointMeta | null> {
    return this.knowledgePoints.find((kp) => kp.id === id) ?? null;
  }

  async findSteps(knowledgePointId: string): Promise<LearningStep[]> {
    const steps = this.steps.get(knowledgePointId);
    if (!steps || steps.length === 0) {
      console.warn(`[FileSystemContentRepository] No steps found for: ${knowledgePointId}`);
      return [];
    }
    return steps;
  }

  async findStep(stepId: string): Promise<LearningStep | null> {
    for (const steps of this.steps.values()) {
      const step = steps.find((s) => s.id === stepId);
      if (step) {
        return step;
      }
    }
    return null;
  }
}
