/**
 * 步骤组件注册表
 * @description 统一管理所有步骤类型对应的组件，支持动态渲染
 */

import { ConcreteStep } from './ConcreteStep';
import { PictorialStep } from './PictorialStep';
import { SymbolicStep } from './SymbolicStep';
import { ConjectureStep } from './ConjectureStep';
import { VerificationStep } from './VerificationStep';
import { ApplicationStep } from './ApplicationStep';

/**
 * 步骤类型枚举
 */
export type StepType = 'concrete' | 'pictorial' | 'symbolic' | 'conjecture' | 'verification' | 'application';

/**
 * 步骤类型元数据
 */
export interface StepTypeMeta {
  /** 类型标识 */
  type: StepType;
  /** 显示名称 */
  label: string;
  /** 图标 */
  emoji: string;
  /** 类型描述 */
  description: string;
  /** 颜色标识 */
  color: string;
}

/**
 * 步骤类型元数据表
 */
export const STEP_TYPE_META: Record<StepType, StepTypeMeta> = {
  concrete: {
    type: 'concrete',
    label: '具象操作',
    emoji: '🎯',
    description: '通过动手操作实物或模型来感知数学概念',
    color: '#4f46e5',
  },
  pictorial: {
    type: 'pictorial',
    label: '图示表达',
    emoji: '🎨',
    description: '通过图形、图表等形象化的方式表达数学概念',
    color: '#f59e0b',
  },
  symbolic: {
    type: 'symbolic',
    label: '符号表示',
    emoji: '📝',
    description: '通过数学符号、算式等抽象化的方式表达数学概念',
    color: '#8b5cf6',
  },
  conjecture: {
    type: 'conjecture',
    label: '猜想',
    emoji: '💡',
    description: '提出猜想，发现规律',
    color: '#10b981',
  },
  verification: {
    type: 'verification',
    label: '验证',
    emoji: '✅',
    description: '验证猜想的正确性',
    color: '#3b82f6',
  },
  application: {
    type: 'application',
    label: '迁移应用',
    emoji: '🚀',
    description: '将学到的概念应用到新的问题情境中',
    color: '#ef4444',
  },
};

/**
 * 步骤组件注册表
 * @description 通过步骤类型动态获取对应的组件
 */
export const StepRegistry = {
  concrete: ConcreteStep,
  pictorial: PictorialStep,
  symbolic: SymbolicStep,
  conjecture: ConjectureStep,
  verification: VerificationStep,
  application: ApplicationStep,
} as const;

/**
 * 获取步骤类型元数据
 */
export const getStepTypeMeta = (type: StepType): StepTypeMeta => {
  return STEP_TYPE_META[type];
};

/**
 * 检查步骤类型是否有效
 */
export const isValidStepType = (type: string): type is StepType => {
  return type in StepRegistry;
};

/**
 * 获取所有步骤类型
 */
export const getAllStepTypes = (): StepType[] => {
  return Object.keys(STEP_TYPE_META) as StepType[];
};

export default StepRegistry;
