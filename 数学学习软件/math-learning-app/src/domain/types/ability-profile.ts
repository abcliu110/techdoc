import type { Ability, AbilityState } from './ability';
import type { LearningEvidence } from './learning-session';

export type { AbilityState };

/**
 * 能力画像聚合根
 */
export interface AbilityProfile {
  /** 用户唯一标识 */
  readonly userId: string;
  /** 能力状态列表 */
  states: AbilityState[];
  /** 累计证据 */
  totalEvidence: LearningEvidence[];
  /** 最后更新时间 */
  updatedAt: number;
}

/**
 * 能力画像服务结果
 */
export interface ProfileResult {
  /** 能力状态列表 */
  abilities: AbilityState[];
  /** 雷达图数据 */
  radarData: RadarDataPoint[];
  /** 成长趋势 */
  trend: TrendDataPoint[];
}

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
 * 趋势数据点
 */
export interface TrendDataPoint {
  date: string;
  abilities: Record<Ability, number>;
}
