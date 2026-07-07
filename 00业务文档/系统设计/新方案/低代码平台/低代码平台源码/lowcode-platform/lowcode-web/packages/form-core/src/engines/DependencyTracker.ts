import { ExpressionEngine } from './ExpressionEngine';

/**
 * 依赖追踪器
 * 分析字段间的依赖关系，实现精确更新
 */
export class DependencyTracker {
  // 字段 -> 依赖的字段列表
  private dependencies: Map<string, Set<string>> = new Map();

  // 字段 -> 被谁依赖的字段列表（反向索引）
  private reverseDependencies: Map<string, Set<string>> = new Map();

  private expressionEngine: ExpressionEngine;

  constructor(expressionEngine?: ExpressionEngine) {
    this.expressionEngine = expressionEngine || new ExpressionEngine();
  }

  /**
   * 注册字段依赖
   * @param fieldId - 字段ID
   * @param expression - 该字段的计算表达式
   */
  registerDependency(fieldId: string, expression: string): void {
    if (!expression) return;

    const deps = this.expressionEngine.analyzeDependencies(expression);

    // 存储依赖关系
    this.dependencies.set(fieldId, new Set(deps));

    // 更新反向索引
    for (const dep of deps) {
      if (!this.reverseDependencies.has(dep)) {
        this.reverseDependencies.set(dep, new Set());
      }
      this.reverseDependencies.get(dep)!.add(fieldId);
    }
  }

  /**
   * 批量注册依赖
   */
  registerBatch(fields: Array<{ fieldId: string; expression?: string }>): void {
    fields.forEach(({ fieldId, expression }) => {
      if (expression) {
        this.registerDependency(fieldId, expression);
      }
    });
  }

  /**
   * 获取字段依赖的字段列表
   */
  getDependencies(fieldId: string): string[] {
    return Array.from(this.dependencies.get(fieldId) || []);
  }

  /**
   * 获取依赖某字段的字段列表（反向查询）
   */
  getDependents(fieldId: string): string[] {
    return Array.from(this.reverseDependencies.get(fieldId) || []);
  }

  /**
   * 计算受影响的字段列表（级联）
   * 当某字段变化时，找出所有需要重新计算的字段
   */
  getAffectedFields(changedFieldId: string): string[] {
    const affected = new Set<string>();
    const queue = [changedFieldId];
    const visited = new Set<string>();

    while (queue.length > 0) {
      const fieldId = queue.shift()!;

      if (visited.has(fieldId)) continue;
      visited.add(fieldId);

      const dependents = this.getDependents(fieldId);

      for (const dependent of dependents) {
        affected.add(dependent);
        queue.push(dependent);
      }
    }

    return Array.from(affected);
  }

  /**
   * 拓扑排序，确定字段计算顺序
   * 返回按依赖关系排序的字段列表
   */
  topologicalSort(fieldIds: string[]): string[] {
    const sorted: string[] = [];
    const visited = new Set<string>();
    const visiting = new Set<string>();

    const visit = (fieldId: string): void => {
      if (visited.has(fieldId)) return;
      if (visiting.has(fieldId)) {
        // 检测到循环依赖
        console.warn(`Circular dependency detected: ${fieldId}`);
        return;
      }

      visiting.add(fieldId);

      const deps = this.getDependencies(fieldId);
      for (const dep of deps) {
        if (fieldIds.includes(dep)) {
          visit(dep);
        }
      }

      visiting.delete(fieldId);
      visited.add(fieldId);
      sorted.push(fieldId);
    };

    for (const fieldId of fieldIds) {
      visit(fieldId);
    }

    return sorted;
  }

  /**
   * 检测循环依赖
   */
  detectCircularDependency(fieldId: string): string[] | null {
    const path: string[] = [];
    const visited = new Set<string>();

    const dfs = (current: string): boolean => {
      if (path.includes(current)) {
        // 找到循环
        const cycleStart = path.indexOf(current);
        return true;
      }

      if (visited.has(current)) {
        return false;
      }

      visited.add(current);
      path.push(current);

      const deps = this.getDependencies(current);
      for (const dep of deps) {
        if (dfs(dep)) {
          return true;
        }
      }

      path.pop();
      return false;
    };

    if (dfs(fieldId)) {
      return path;
    }

    return null;
  }

  /**
   * 获取依赖图
   */
  getDependencyGraph(): Record<string, string[]> {
    const graph: Record<string, string[]> = {};

    this.dependencies.forEach((deps, fieldId) => {
      graph[fieldId] = Array.from(deps);
    });

    return graph;
  }

  /**
   * 清空所有依赖
   */
  clear(): void {
    this.dependencies.clear();
    this.reverseDependencies.clear();
  }

  /**
   * 移除字段的依赖
   */
  removeDependency(fieldId: string): void {
    // 从反向索引中移除
    const deps = this.dependencies.get(fieldId);
    if (deps) {
      for (const dep of deps) {
        this.reverseDependencies.get(dep)?.delete(fieldId);
      }
    }

    // 移除正向索引
    this.dependencies.delete(fieldId);

    // 移除反向索引
    this.reverseDependencies.delete(fieldId);
  }

  /**
   * 统计信息
   */
  getStats(): {
    totalFields: number;
    fieldsWithDependencies: number;
    totalDependencies: number;
    averageDependencies: number;
  } {
    const totalFields = this.dependencies.size;
    const fieldsWithDependencies = Array.from(this.dependencies.values())
      .filter(deps => deps.size > 0).length;

    let totalDeps = 0;
    this.dependencies.forEach(deps => {
      totalDeps += deps.size;
    });

    return {
      totalFields,
      fieldsWithDependencies,
      totalDependencies: totalDeps,
      averageDependencies: totalFields > 0 ? totalDeps / totalFields : 0,
    };
  }

  /**
   * 可视化依赖图（用于调试）
   */
  visualize(): string {
    const lines: string[] = ['Dependency Graph:'];

    this.dependencies.forEach((deps, fieldId) => {
      if (deps.size > 0) {
        lines.push(`  ${fieldId} -> [${Array.from(deps).join(', ')}]`);
      }
    });

    if (lines.length === 1) {
      lines.push('  (empty)');
    }

    return lines.join('\n');
  }
}
