import { describe, it, expect } from 'vitest';
import { ExpressionParser, ParsedExpression } from '../../src/engine/math/ExpressionParser';

describe('ExpressionParser', () => {
  describe('parse', () => {
    describe('分数表达式解析', () => {
      it('应该正确解析简单分数', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('3/4');
        expect(result.type).toBe('fraction');
        expect(result.numerator).toBe(3);
        expect(result.denominator).toBe(4);
        expect(result.original).toBe('3/4');
      });

      it('应该正确解析带空格的分数', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('3 / 4');
        expect(result.type).toBe('fraction');
        expect(result.numerator).toBe(3);
        expect(result.denominator).toBe(4);
      });

      it('应该正确解析整数作为分数', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('5/1');
        expect(result.type).toBe('fraction');
        expect(result.numerator).toBe(5);
        expect(result.denominator).toBe(1);
      });

      it('应该正确解析大数分数', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('123/456');
        expect(result.type).toBe('fraction');
        expect(result.numerator).toBe(123);
        expect(result.denominator).toBe(456);
      });
    });

    describe('小数表达式解析', () => {
      it('应该正确解析简单小数', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('0.75');
        expect(result.type).toBe('decimal');
        expect(result.value).toBe(0.75);
      });

      it('应该正确解析整数小数', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('5.0');
        expect(result.type).toBe('decimal');
        expect(result.value).toBe(5.0);
      });
    });

    describe('未知表达式解析', () => {
      it('应该将非数字表达式标记为 unknown', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('x + y');
        expect(result.type).toBe('unknown');
      });

      it('应该将空字符串标记为 unknown', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('');
        expect(result.type).toBe('unknown');
      });

      it('应该正确处理仅包含空格的字符串', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('   ');
        expect(result.type).toBe('unknown');
      });
    });

    describe('边界情况', () => {
      it('应该保留原始输入', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('3/4');
        expect(result.original).toBe('3/4');
      });

      it('应该正确解析分子为 0 的分数', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('0/5');
        expect(result.type).toBe('fraction');
        expect(result.numerator).toBe(0);
        expect(result.denominator).toBe(5);
      });

      it('应该正确处理无前导零小数（解析为 unknown）', () => {
        const parser = new ExpressionParser();
        const result = parser.parse('.5');
        // MVP 阶段不支持无前导零小数
        expect(result.type).toBe('unknown');
      });
    });
  });

  describe('fractionToDecimal', () => {
    it('应该正确将分数转换为小数', () => {
      const parser = new ExpressionParser();
      const result = parser.fractionToDecimal(3, 4);
      expect(result).toBe(0.75);
    });

    it('应该正确将分数转换为整数', () => {
      const parser = new ExpressionParser();
      const result = parser.fractionToDecimal(6, 3);
      expect(result).toBe(2);
    });

    it('当分母为零时应抛出错误', () => {
      const parser = new ExpressionParser();
      expect(() => parser.fractionToDecimal(1, 0)).toThrow('分母不能为零');
    });

    it('应该正确处理负数分数', () => {
      const parser = new ExpressionParser();
      const result = parser.fractionToDecimal(-3, 4);
      expect(result).toBe(-0.75);
    });
  });

  describe('compareFractions', () => {
    it('当 a < b 时应返回 -1', () => {
      const parser = new ExpressionParser();
      const result = parser.compareFractions(
        { numerator: 1, denominator: 4 },
        { numerator: 1, denominator: 2 }
      );
      expect(result).toBe(-1);
    });

    it('当 a > b 时应返回 1', () => {
      const parser = new ExpressionParser();
      const result = parser.compareFractions(
        { numerator: 3, denominator: 4 },
        { numerator: 1, denominator: 2 }
      );
      expect(result).toBe(1);
    });

    it('当 a = b 时应返回 0', () => {
      const parser = new ExpressionParser();
      const result = parser.compareFractions(
        { numerator: 1, denominator: 2 },
        { numerator: 2, denominator: 4 }
      );
      expect(result).toBe(0);
    });

    it('应该正确比较不同分母的分数', () => {
      const parser = new ExpressionParser();
      expect(
        parser.compareFractions(
          { numerator: 2, denominator: 3 },
          { numerator: 3, denominator: 5 }
        )
      ).toBe(1);
    });

    it('应该正确比较负数分数', () => {
      const parser = new ExpressionParser();
      expect(
        parser.compareFractions(
          { numerator: -1, denominator: 2 },
          { numerator: 1, denominator: 2 }
        )
      ).toBe(-1);
    });
  });
});
