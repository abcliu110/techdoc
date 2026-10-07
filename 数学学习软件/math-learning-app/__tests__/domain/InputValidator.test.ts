import { describe, it, expect } from 'vitest';
import { InputValidator } from '../../src/engine/validators/InteractiveValidator';

describe('InputValidator', () => {
  describe('构造函数', () => {
    it('应该正确初始化 expectedAnswers 和 tolerance', () => {
      const validator = new InputValidator(['3/4', '0.75']);
      expect(validator).toBeDefined();
    });

    it('应该设置默认 tolerance 为 0', () => {
      const validator = new InputValidator(['answer']);
      expect(validator).toBeDefined();
    });

    it('应该接受自定义 tolerance', () => {
      const validator = new InputValidator(['answer'], 2);
      expect(validator).toBeDefined();
    });
  });

  describe('validate', () => {
    it('当输入为非字符串类型时应返回无效', () => {
      const validator = new InputValidator(['3/4']);
      const result = validator.validate(123);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('输入必须是字符串');
    });

    it('当输入为数字时应返回无效', () => {
      const validator = new InputValidator(['3/4']);
      const result = validator.validate(0.75);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('输入必须是字符串');
    });

    it('当答案完全匹配时应返回有效', () => {
      const validator = new InputValidator(['3/4']);
      const result = validator.validate('3/4');
      expect(result.valid).toBe(true);
    });

    it('当答案忽略大小写匹配时应返回有效', () => {
      const validator = new InputValidator(['Answer']);
      const result = validator.validate('answer');
      expect(result.valid).toBe(true);
    });

    it('当答案忽略前后空格匹配时应返回有效', () => {
      const validator = new InputValidator([' 3/4 ']);
      const result = validator.validate('3/4');
      expect(result.valid).toBe(true);
    });

    it('当输入答案有前后空格时应返回有效', () => {
      const validator = new InputValidator(['3/4']);
      const result = validator.validate('  3/4  ');
      expect(result.valid).toBe(true);
    });

    it('当多个正确答案之一匹配时应返回有效', () => {
      const validator = new InputValidator(['3/4', '0.75', '6/8']);
      expect(validator.validate('0.75').valid).toBe(true);
      expect(validator.validate('6/8').valid).toBe(true);
    });

    it('当答案不匹配时应返回无效', () => {
      const validator = new InputValidator(['3/4']);
      const result = validator.validate('1/2');
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('期望答案: 3/4');
    });

    it('当多个正确答案都不匹配时应返回无效', () => {
      const validator = new InputValidator(['3/4', '0.75']);
      const result = validator.validate('1/2');
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('期望答案: 3/4 或 0.75');
    });

    it('当 tolerance 大于 0 但不使用模糊匹配时应返回无效', () => {
      const validator = new InputValidator(['3/4'], 2);
      const result = validator.validate('1/2');
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('答案不正确');
    });

    it('当输入为空字符串时应返回无效', () => {
      const validator = new InputValidator(['3/4']);
      const result = validator.validate('');
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('期望答案: 3/4');
    });

    it('当输入只有空格时应返回无效', () => {
      const validator = new InputValidator(['3/4']);
      const result = validator.validate('   ');
      expect(result.valid).toBe(false);
    });

    it('当 expectedAnswers 为空数组时应返回无效', () => {
      const validator = new InputValidator([]);
      const result = validator.validate('anything');
      expect(result.valid).toBe(false);
    });
  });
});
