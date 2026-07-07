/**
 * 表达式引擎
 * 解析和执行表达式，支持字段引用、函数调用、运算符
 */
export class ExpressionEngine {
  private context: Record<string, any> = {};
  private functions: Map<string, Function> = new Map();

  constructor() {
    this.registerBuiltInFunctions();
  }

  /**
   * 设置上下文数据
   */
  setContext(context: Record<string, any>): void {
    this.context = context;
  }

  /**
   * 执行表达式
   * @param expression - 表达式字符串，如 '${qty * price}' 或 '${SUM(items.*.amount)}'
   * @returns 计算结果
   */
  evaluate(expression: string): any {
    if (!expression) return undefined;

    // 移除 ${} 包裹
    const expr = expression.trim();
    if (expr.startsWith('${') && expr.endsWith('}')) {
      const innerExpr = expr.slice(2, -1).trim();
      return this.evaluateExpression(innerExpr);
    }

    return expression;
  }

  /**
   * 批量执行表达式
   */
  evaluateBatch(expressions: string[]): any[] {
    return expressions.map(expr => this.evaluate(expr));
  }

  /**
   * 注册自定义函数
   */
  registerFunction(name: string, fn: Function): void {
    this.functions.set(name.toUpperCase(), fn);
  }

  /**
   * 注册内置函数
   */
  private registerBuiltInFunctions(): void {
    // 数学函数
    this.registerFunction('SUM', (arr: any[]) => {
      if (!Array.isArray(arr)) return 0;
      return arr.reduce((sum, val) => sum + (Number(val) || 0), 0);
    });

    this.registerFunction('AVG', (arr: any[]) => {
      if (!Array.isArray(arr) || arr.length === 0) return 0;
      const sum = this.functions.get('SUM')!(arr);
      return sum / arr.length;
    });

    this.registerFunction('MAX', (arr: any[]) => {
      if (!Array.isArray(arr) || arr.length === 0) return undefined;
      return Math.max(...arr.map(v => Number(v) || 0));
    });

    this.registerFunction('MIN', (arr: any[]) => {
      if (!Array.isArray(arr) || arr.length === 0) return undefined;
      return Math.min(...arr.map(v => Number(v) || 0));
    });

    this.registerFunction('COUNT', (arr: any[]) => {
      return Array.isArray(arr) ? arr.length : 0;
    });

    // 日期函数
    this.registerFunction('TODAY', () => {
      const today = new Date();
      return today.toISOString().split('T')[0];
    });

    this.registerFunction('NOW', () => {
      return new Date().toISOString();
    });

    // 字符串函数
    this.registerFunction('UPPER', (str: string) => String(str).toUpperCase());
    this.registerFunction('LOWER', (str: string) => String(str).toLowerCase());
    this.registerFunction('TRIM', (str: string) => String(str).trim());

    this.registerFunction('CONCAT', (...args: any[]) => {
      return args.map(String).join('');
    });

    // 条件函数
    this.registerFunction('IF', (condition: any, trueValue: any, falseValue: any) => {
      return condition ? trueValue : falseValue;
    });
  }

  /**
   * 解析并执行表达式
   */
  private evaluateExpression(expr: string): any {
    try {
      // 处理函数调用
      if (this.isFunctionCall(expr)) {
        return this.evaluateFunction(expr);
      }

      // 处理字段引用
      expr = this.replaceFieldReferences(expr);

      // 执行JavaScript表达式
      // 注意：生产环境应使用更安全的表达式解析器
      const result = new Function('context', `with(context) { return ${expr}; }`)(this.context);
      return result;
    } catch (error) {
      console.error('Expression evaluation error:', error, 'Expression:', expr);
      return undefined;
    }
  }

  /**
   * 判断是否为函数调用
   */
  private isFunctionCall(expr: string): boolean {
    return /^[A-Z_]+\s*\(/.test(expr.trim());
  }

  /**
   * 执行函数调用
   */
  private evaluateFunction(expr: string): any {
    const match = expr.match(/^([A-Z_]+)\s*\((.*)\)\s*$/);
    if (!match) return undefined;

    const [, funcName, argsStr] = match;
    const func = this.functions.get(funcName);

    if (!func) {
      console.warn(`Function ${funcName} not found`);
      return undefined;
    }

    // 解析参数
    const args = this.parseArguments(argsStr);
    const evaluatedArgs = args.map(arg => {
      // 如果参数是路径表达式（如 items.*.amount）
      if (arg.includes('.*.')) {
        return this.evaluateWildcardPath(arg);
      }
      // 如果参数是字段引用
      if (/^[a-zA-Z_][\w.]*$/.test(arg.trim())) {
        return this.getFieldValue(arg.trim());
      }
      // 否则作为表达式求值
      return this.evaluateExpression(arg);
    });

    return func(...evaluatedArgs);
  }

  /**
   * 解析函数参数
   */
  private parseArguments(argsStr: string): string[] {
    if (!argsStr.trim()) return [];

    const args: string[] = [];
    let current = '';
    let depth = 0;

    for (const char of argsStr) {
      if (char === '(') depth++;
      else if (char === ')') depth--;
      else if (char === ',' && depth === 0) {
        args.push(current.trim());
        current = '';
        continue;
      }
      current += char;
    }

    if (current.trim()) {
      args.push(current.trim());
    }

    return args;
  }

  /**
   * 替换字段引用
   */
  private replaceFieldReferences(expr: string): string {
    return expr.replace(/\b([a-zA-Z_][\w.]*)\b/g, (match) => {
      // 跳过JavaScript关键字
      if (['true', 'false', 'null', 'undefined'].includes(match)) {
        return match;
      }

      const value = this.getFieldValue(match);
      if (value === undefined) {
        return match;
      }

      // 字符串需要加引号
      if (typeof value === 'string') {
        return `"${value.replace(/"/g, '\\"')}"`;
      }

      return String(value);
    });
  }

  /**
   * 获取字段值（支持路径）
   */
  private getFieldValue(path: string): any {
    const keys = path.split('.');
    let current: any = this.context;

    for (const key of keys) {
      if (current === null || current === undefined) {
        return undefined;
      }
      current = current[key];
    }

    return current;
  }

  /**
   * 处理通配符路径（如 items.*.amount）
   */
  private evaluateWildcardPath(path: string): any[] {
    const parts = path.split('.*.');
    if (parts.length !== 2) return [];

    const [arrayPath, fieldName] = parts;
    const array = this.getFieldValue(arrayPath);

    if (!Array.isArray(array)) return [];

    return array.map(item => item?.[fieldName]).filter(v => v !== undefined);
  }

  /**
   * 分析表达式依赖的字段
   */
  analyzeDependencies(expression: string): string[] {
    const dependencies = new Set<string>();

    if (!expression) return [];

    const expr = expression.trim();
    if (expr.startsWith('${') && expr.endsWith('}')) {
      const innerExpr = expr.slice(2, -1);

      // 提取字段引用
      const fieldPattern = /\b([a-zA-Z_][\w.]*)\b/g;
      let match;

      while ((match = fieldPattern.exec(innerExpr)) !== null) {
        const field = match[1];
        // 过滤关键字和函数名
        if (!['true', 'false', 'null', 'undefined'].includes(field) &&
            !this.functions.has(field.toUpperCase())) {
          dependencies.add(field);
        }
      }
    }

    return Array.from(dependencies);
  }
}
