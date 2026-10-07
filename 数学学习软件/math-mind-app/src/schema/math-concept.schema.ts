/**
 * 数学思维启发学习系统 - 数学概念Schema
 * @description 定义数学概念的本体结构、关系网络和理解层次
 */

import { z } from 'zod';

// ==================== 辅助枚举 ====================

/** 年级枚举（简化版） */
const GradeEnum = z.enum([
  'grade1', 'grade2', 'grade3', 'grade4', 'grade5', 'grade6',
  'grade7', 'grade8', 'grade9'
]);
export type Grade = z.infer<typeof GradeEnum>;

// ==================== 基础枚举 ====================

/** 数学领域枚举 */
export const MathDomainEnum = z.enum([
  'number',           // 数与运算
  'algebra',          // 代数与函数
  'geometry',         // 几何与测量
  'statistics',      // 统计与概率
  'ratio',            // 比与比例
  'measurement'       // 量与计量
]);
export type MathDomain = z.infer<typeof MathDomainEnum>;

/** 概念层级枚举 */
export const ConceptHierarchyEnum = z.enum([
  'big_idea',         // 大概念/核心思想
  'concept_cluster',  // 概念簇
  'knowledge_point',  // 知识点
  'sub_skill'         // 子技能
]);
export type ConceptHierarchy = z.infer<typeof ConceptHierarchyEnum>;

/** 理解层次枚举 */
export const UnderstandingLevelEnum = z.enum([
  'unknown',          // 未接触
  'introduced',       // 已引入
  'exploring',       // 探索中
  'emerging',        // 初形成
  'developing',      // 发展中
  'established',      // 已建立
  'mastered'          // 已掌握
]);
export type UnderstandingLevel = z.infer<typeof UnderstandingLevelEnum>;

// ==================== 概念属性 ====================

/** 概念描述 */
export const ConceptDescriptionSchema = z.object({
  /** 简短定义 */
  shortDefinition: z.string(),
  /** 详细解释 */
  detailedExplanation: z.string().optional(),
  /** 关键特征列表 */
  keyCharacteristics: z.array(z.string()).default([]),
  /** 常见误解 */
  commonMisconceptions: z.array(z.object({
    misconception: z.string(),
    correctUnderstanding: z.string()
  })).default([])
});
export type ConceptDescription = z.infer<typeof ConceptDescriptionSchema>;

// ==================== 表征方式 ====================

/** 表征方式 */
export const RepresentationSchema = z.object({
  /** 表征类型 */
  type: z.enum([
    'concrete',     // 具象（实物操作）
    'pictorial',    // 形象（图示表征）
    'symbolic',     // 抽象（符号表征）
    'verbal',       // 语言（口头/书面）
    'kinesthetic'   // 动作（身体感知）
  ]),
  /** 表征名称 */
  name: z.string(),
  /** 表征描述 */
  description: z.string(),
  /** 示例 */
  examples: z.array(z.object({
    id: z.string(),
    content: z.string(),
    mediaType: z.enum(['text', 'image', 'video', 'interactive']),
    mediaUrl: z.string().optional()
  })).default([])
});
export type Representation = z.infer<typeof RepresentationSchema>;

// ==================== 概念关系 ====================

/** 关系类型枚举 */
export const RelationTypeEnum = z.enum([
  'prerequisite',     // 前置关系（A是B的前置）
  'successor',       // 后续关系（A是B的后续）
  'parent',          // 父子关系（A是B的上位概念）
  'child',           // 子概念（A是B的下位概念）
  'sibling',         // 同级关系（A和B是同级别概念）
  'analogy',         // 类比关系（A类似于B）
  'contrast',        // 对比关系（A与B相对）
  'part_whole',      // 部分整体关系
  'instance',        // 实例关系（A是B的一个实例）
  'transforms_to'    // 转化关系（A可以转化为B）
]);
export type RelationType = z.infer<typeof RelationTypeEnum>;

/** 概念关系 */
export const ConceptRelationSchema = z.object({
  /** 关系ID */
  relationId: z.string(),
  /** 关系类型 */
  relationType: RelationTypeEnum,
  /** 关联概念ID */
  relatedConceptId: z.string(),
  /** 关联概念名称 */
  relatedConceptName: z.string(),
  /** 关系强度（0-1） */
  strength: z.number().min(0).max(1).default(0.5),
  /** 关系描述 */
  description: z.string().optional(),
  /** 是否关键关系 */
  isKeyRelation: z.boolean().default(false)
});
export type ConceptRelation = z.infer<typeof ConceptRelationSchema>;

// ==================== 数学概念 ====================

/**
 * 数学概念完整Schema
 * @description 定义数学概念的完整结构
 */
export const MathConceptSchema = z.object({
  /** 概念ID */
  conceptId: z.string(),
  /** 概念名称 */
  name: z.string(),
  /** 概念编码（用于内部引用） */
  code: z.string().regex(/^[a-z0-9_]+$/, '使用小写字母、数字和下划线'),
  /** 所属领域 */
  domain: MathDomainEnum,
  /** 概念层级 */
  hierarchy: ConceptHierarchyEnum,
  /** 年级范围 */
  gradeRange: z.object({
    min: GradeEnum,
    max: GradeEnum
  }),
  /** 描述 */
  description: ConceptDescriptionSchema,
  /** 表征方式列表 */
  representations: z.array(RepresentationSchema).default([]),
  /** 关联关系列表 */
  relations: z.array(ConceptRelationSchema).default([]),
  /** 关键程度 */
  importance: z.enum(['core', 'supporting', 'optional']).default('supporting'),
  /** 教学优先级 */
  teachingPriority: z.number().int().min(1).max(5).default(3),
  /** 难度系数 */
  difficultyCoefficient: z.number().min(0).max(1).default(0.5),
  /** 关键词 */
  keywords: z.array(z.string()).default([]),
  /** 创建时间 */
  createdAt: z.string().datetime(),
  /** 更新时间 */
  updatedAt: z.string().datetime()
});
export type MathConcept = z.infer<typeof MathConceptSchema>;

// ==================== 概念理解记录 ====================

/** 概念理解记录 */
export const ConceptUnderstandingSchema = z.object({
  /** 记录ID */
  recordId: z.string(),
  /** 用户ID */
  userId: z.string(),
  /** 概念ID */
  conceptId: z.string(),
  /** 理解层次 */
  level: UnderstandingLevelEnum,
  /** 置信度（0-1） */
  confidence: z.number().min(0).max(1),
  /** 评估证据数 */
  evidenceCount: z.number().int().min(0),
  /** 最近评估时间 */
  lastAssessedAt: z.string().datetime(),
  /** 首次接触时间 */
  firstEncounteredAt: z.string().datetime().optional(),
  /** 达到当前层次的时间 */
  reachedCurrentLevelAt: z.string().datetime().optional(),
  /** 掌握时长（天） */
  masteryDays: z.number().int().min(0).default(0),
  /** 关联表征理解度 */
  representationUnderstanding: z.object({
    concrete: z.number().min(0).max(1).default(0),
    pictorial: z.number().min(0).max(1).default(0),
    symbolic: z.number().min(0).max(1).default(0)
  }),
  /** 常见错误记录 */
  commonErrors: z.array(z.object({
    errorType: z.string(),
    occurrenceCount: z.number().int().min(0),
    lastOccurredAt: z.string().datetime().optional()
  })).default([])
});
export type ConceptUnderstanding = z.infer<typeof ConceptUnderstandingSchema>;

// ==================== 概念网络 ====================

/** 概念网络节点 */
export const ConceptNetworkNodeSchema = z.object({
  conceptId: z.string(),
  name: z.string(),
  domain: MathDomainEnum,
  hierarchy: ConceptHierarchyEnum,
  importance: z.enum(['core', 'supporting', 'optional']),
  /** 当前理解层次 */
  understandingLevel: UnderstandingLevelEnum,
  /** 在用户学习路径中的位置 */
  learningPathPosition: z.number().int().min(0).optional()
});
export type ConceptNetworkNode = z.infer<typeof ConceptNetworkNodeSchema>;

/** 概念网络边 */
export const ConceptNetworkEdgeSchema = z.object({
  fromConceptId: z.string(),
  toConceptId: z.string(),
  relationType: RelationTypeEnum,
  strength: z.number().min(0).max(1),
  isKeyRelation: z.boolean(),
  /** 用户是否已建立该关系 */
  relationEstablished: z.boolean().default(false),
  /** 关系建立时间 */
  establishedAt: z.string().datetime().optional()
});
export type ConceptNetworkEdge = z.infer<typeof ConceptNetworkEdgeSchema>;

/** 概念网络 */
export const ConceptNetworkSchema = z.object({
  /** 网络ID */
  networkId: z.string(),
  /** 用户ID */
  userId: z.string(),
  /** 网络版本 */
  version: z.number().int().default(1),
  /** 节点列表 */
  nodes: z.array(ConceptNetworkNodeSchema),
  /** 边列表 */
  edges: z.array(ConceptNetworkEdgeSchema),
  /** 元数据 */
  metadata: z.object({
    totalConcepts: z.number().int().min(0),
    masteredConcepts: z.number().int().min(0),
    networkDensity: z.number().min(0).max(1),
    lastUpdatedAt: z.string().datetime()
  })
});
export type ConceptNetwork = z.infer<typeof ConceptNetworkSchema>;
