import { describe, it, expect, beforeEach } from 'vitest';
import { EquivalenceChecker } from '../../src/engine/math/EquivalenceChecker';
import type { EquivalenceRule } from '../../src/domain/types/learning-step';

describe('EquivalenceChecker', () => {
  describe('构造函数', () => {
    it('应该正确初始化空规则', () => {
      const checker = new EquivalenceChecker();
      expect(checker).toBeDefined();
    });

    it('应该正确初始化自定义规则', () => {
      const rules: EquivalenceRule[] = [
        { name: 'removeSpaces', pattern: '\\s+', replacement: '' },
      ];
      const checker = new EquivalenceChecker(rules);
      expect(checker).toBeDefined();
    });
  });

  describe('checkEquivalence', () => {
    it('当两个表达式完全相同时应返回 true', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkEquivalence('3/4', '3/4')).toBe(true);
    });

    it('当表达式忽略大小写相同时应返回 true', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkEquivalence('abc', 'ABC')).toBe(true);
    });

    it('当表达式有前后空格时应正确比较', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkEquivalence('  3/4  ', '3/4')).toBe(true);
    });

    it('当分数等价时应返回 true', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkEquivalence('1/2', '2/4')).toBe(true);
    });

    it('当分数等价但格式不同时应返回 true', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkEquivalence('3/6', '1/2')).toBe(true);
    });

    it('当小数等于分数时应返回 true', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkEquivalence('0.5', '1/2')).toBe(true);
    });

    it('当表达式不相等时应返回 false', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkEquivalence('1/2', '1/3')).toBe(false);
    });

    it('当小数不等于分数时应返回 false', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkEquivalence('0.75', '1/2')).toBe(false);
    });
  });

  describe('normalize', () => {
    it('应该正确约分分数', () => {
      const checker = new EquivalenceChecker();
      expect(checker.normalize('2/4')).toBe('1/2');
    });

    it('应该正确约分大分数', () => {
      const checker = new EquivalenceChecker();
      expect(checker.normalize('6/8')).toBe('3/4');
    });

    it('应该正确处理无法约分的分数', () => {
      const checker = new EquivalenceChecker();
      expect(checker.normalize('3/4')).toBe('3/4');
    });

    it('应该正确转换整数为分数', () => {
      const checker = new EquivalenceChecker();
      expect(checker.normalize('2.0')).toBe('2/1');
    });

    it('应该正确转换小数为分数', () => {
      const checker = new EquivalenceChecker();
      const result = checker.normalize('0.5');
      expect(result).toBe('1/2');
    });

    it('应该正确处理循环小数', () => {
      const checker = new EquivalenceChecker();
      const result = checker.normalize('0.333');
      expect(result).toMatch(/^\d+\/\d+$/);
    });

    it('应该正确处理带空格的表达式', () => {
      const checker = new EquivalenceChecker();
      expect(checker.normalize('  3/4  ')).toBe('3/4');
    });

    it('应该将未知表达式转为小写', () => {
      const checker = new EquivalenceChecker();
      expect(checker.normalize('ABC')).toBe('abc');
    });
  });

  describe('checkAnswer', () => {
    it('当用户答案与期望答案之一匹配时应返回 true', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkAnswer('3/4', ['3/4', '0.75'])).toBe(true);
      expect(checker.checkAnswer('0.75', ['3/4', '0.75'])).toBe(true);
    });

    it('当用户答案与期望答案等价时应返回 true', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkAnswer('6/8', ['3/4'])).toBe(true);
    });

    it('当用户答案与期望答案不匹配时应返回 false', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkAnswer('1/2', ['3/4'])).toBe(false);
    });

    it('当期望答案列表为空时应返回 false', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkAnswer('3/4', [])).toBe(false);
    });

    it('应该正确处理多个等价答案', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkAnswer('0.5', ['1/2', '2/4', '0.5'])).toBe(true);
    });

    it('应该正确处理带空格的答案', () => {
      const checker = new EquivalenceChecker();
      expect(checker.checkAnswer('  3/4  ', ['3/4'])).toBe(true);
    });
  });

  describe('内部 GCD 算法', () => {
    it('应该正确计算最大公约数', () => {
      const checker = new EquivalenceChecker();
      // 通过 normalize 函数间接测试 GCD
      expect(checker.normalize('4/8')).toBe('1/2');
      expect(checker.normalize('6/9')).toBe('2/3');
      expect(checker.normalize('12/18')).toBe('2/3');
    });
  });

  describe('小数转分数', () => {
    it('应该正确转换 0.25', () => {
      const checker = new EquivalenceChecker();
      expect(checker.normalize('0.25')).toBe('1/4');
    });

    it('应该正确转换 0.333', () => {
      const checker = new EquivalenceChecker();
      const result = checker.normalize('0.333');
      // 近似值，约等于 1/3
      expect(parseFloat(result.split('/')[0]) / parseFloat(result.split('/')[1])).toBeCloseTo(0.333, 2);
    });

    it('应该正确转换整数', () => {
      const checker = new EquivalenceChecker();
      expect(checker.normalize('5')).toBe('5/1');
    });

    it('应该正确转换带整数部分的小数', () => {
      const checker = new EquivalenceChecker();
      const result = checker.normalize('1.5');
      expect(result).toBe('3/2');
    });
  });
});
