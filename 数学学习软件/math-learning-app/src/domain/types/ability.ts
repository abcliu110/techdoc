/**
 * 数学能力枚举
 */
export enum Ability {
  /** 数形结合 */
  NUMBER_SHAPE_INTEGRATION = 'number-shape-integration',
  /** 单位统一 */
  UNIT_UNIFICATION = 'unit-unification',
  /** 整体部分思想 */
  WHOLE_PART_THINKING = 'whole-part-thinking',
  /** 转化化归思想 */
  TRANSFORMATION = 'transformation',
  /** 等量关系与方程 */
  EQUATION_REASONING = 'equation-reasoning',
}

/**
 * 能力等级
 */
export enum AbilityLevel {
  NOT_STARTED = 0,
  AWARE = 1,
  DEVELOPING = 2,
  MASTERED = 3,
}

/**
 * 能力状态值对象
 */
export interface AbilityState {
  ability: Ability;
  level: AbilityLevel;
  evidenceCount: number;
  lastPracticedAt: number;
}
