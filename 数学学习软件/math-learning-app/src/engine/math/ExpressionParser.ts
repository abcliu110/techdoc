/**
 * 表达式解析器
 * MVP 阶段支持简单的分数表达式解析
 */
export class ExpressionParser {
  /**
   * 解析表达式
   */
  parse(expression: string): ParsedExpression {
    const trimmed = expression.trim();

    // 解析分数表达式 (如 "3/4")
    const fractionMatch = trimmed.match(/^(\d+)\s*\/\s*(\d+)$/);
    if (fractionMatch) {
      return {
        type: 'fraction',
        numerator: parseInt(fractionMatch[1] ?? '0', 10),
        denominator: parseInt(fractionMatch[2] ?? '1', 10),
        original: expression,
      };
    }

    // 解析小数表达式 (如 "0.75")
    const decimalMatch = trimmed.match(/^(\d+\.?\d*)$/);
    if (decimalMatch) {
      const value = parseFloat(decimalMatch[1] ?? '0');
      return {
        type: 'decimal',
        value,
        original: expression,
      };
    }

    return {
      type: 'unknown',
      original: expression,
    };
  }

  /**
   * 将分数转换为小数
   */
  fractionToDecimal(numerator: number, denominator: number): number {
    if (denominator === 0) {
      throw new Error('分母不能为零');
    }
    return numerator / denominator;
  }

  /**
   * 比较两个分数大小
   */
  compareFractions(
    a: { numerator: number; denominator: number },
    b: { numerator: number; denominator: number }
  ): -1 | 0 | 1 {
    const left = a.numerator * b.denominator;
    const right = b.numerator * a.denominator;

    if (left < right) return -1;
    if (left > right) return 1;
    return 0;
  }
}

/**
 * 解析后的表达式
 */
export interface ParsedExpression {
  type: 'fraction' | 'decimal' | 'unknown';
  numerator?: number;
  denominator?: number;
  value?: number;
  original: string;
}
