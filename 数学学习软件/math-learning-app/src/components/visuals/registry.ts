import type { ComponentType } from 'react';

/**
 * 可视化组件注册表
 * 用于动态注册和加载可视化组件
 */
interface VisualComponentRegistry {
  [key: string]: {
    component: ComponentType<unknown>;
    description: string;
  };
}

const registry: VisualComponentRegistry = {};

/**
 * 注册可视化组件
 */
export function registerVisual(
  name: string,
  component: ComponentType<unknown>,
  description: string = ''
): void {
  registry[name] = { component, description };
}

/**
 * 获取可视化组件
 */
export function getVisual(name: string): ComponentType<unknown> | null {
  const entry = registry[name];
  return entry ? entry.component : null;
}

/**
 * 获取所有已注册的可视化组件名称
 */
export function listVisuals(): string[] {
  return Object.keys(registry);
}

/**
 * 检查可视化组件是否存在
 */
export function hasVisual(name: string): boolean {
  return name in registry;
}

// 默认导出
export default registry;
