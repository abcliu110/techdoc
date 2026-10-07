import type { EquivalenceRule } from '../../domain/types/learning-step';
import { ExpressionParser } from './ExpressionParser';

/**
 * 等价性检查器
 * 检查数学表达式的等价性
 */
export class EquivalenceChecker {
  private parser: ExpressionParser;
  private rules: EquivalenceRule[];

  constructor(rules: EquivalenceRule[] = []) {
    this.parser = new ExpressionParser();
    this.rules = rules;
  }

  /**
   * 检查两个表达式是否等价
   */
  checkEquivalence(expression1: string, expression2: string): boolean {
    // 标准化表达式
    const normalized1 = this.normalize(expression1);
    const normalized2 = this.normalize(expression2);

    return normalized1 === normalized2;
  }

  /**
   * 标准化表达式
   */
  normalize(expression: string): string {
    let result = expression.trim();

    // 应用等价规则
    for (const rule of this.rules) {
      const regex = new RegExp(rule.pattern, 'g');
      result = result.replace(regex, rule.replacement);
    }

    // 解析并重新生成标准形式
    const parsed = this.parser.parse(result);

    switch (parsed.type) {
      case 'fraction':
        if (parsed.numerator !== undefined && parsed.denominator !== undefined) {
          // 约分
          const gcdValue = this.gcd(parsed.numerator, parsed.denominator);
          const reducedNumerator = parsed.numerator / gcdValue;
          const reducedDenominator = parsed.denominator / gcdValue;
          return `${reducedNumerator}/${reducedDenominator}`;
        }
        break;
      case 'decimal':
        if (parsed.value !== undefined) {
          // 转换为分数形式
          const fraction = this.decimalToFraction(parsed.value);
          return `${fraction.numerator}/${fraction.denominator}`;
        }
        break;
    }

    return result.toLowerCase();
  }

  /**
   * 最大公约数
   */
  private gcd(a: number, b: number): number {
    a = Math.abs(a);
    b = Math.abs(b);
    while (b !== 0) {
      const temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  /**
   * 小数转分数
   */
  private decimalToFraction(decimal: number): { numerator: number; denominator: number } {
    const precision = 1e-10;
    let numerator = 1;
    let denominator = 1;

    if (Number.isInteger(decimal)) {
      return { numerator: decimal, denominator: 1 };
    }

    const wholePart = Math.floor(decimal);
    let fractionalPart = decimal - wholePart;

    // 迭代逼近
    for (let i = 0; i < 10; i++) {
      const tempDenominator = numerator + denominator;
      const tempNumerator = Math.round(fractionalPart * tempDenominator);

      if (Math.abs(tempNumerator / tempDenominator - fractionalPart) < precision) {
        return {
          numerator: wholePart * tempDenominator + tempNumerator,
          denominator: tempDenominator,
        };
      }

      numerator = tempDenominator;
      denominator = tempNumerator;
    }

    return { numerator: decimal * 10000, denominator: 10000 };
  }

  /**
   * 检查答案是否正确
   */
  checkAnswer(userAnswer: string, expectedAnswers: string[]): boolean {
    for (const expected of expectedAnswers) {
      if (this.checkEquivalence(userAnswer, expected)) {
        return true;
      }
    }
    return false;
  }
}
