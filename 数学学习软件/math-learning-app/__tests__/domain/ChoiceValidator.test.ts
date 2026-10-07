import { describe, it, expect } from 'vitest';
import { ChoiceValidator } from '../../src/engine/validators/InteractiveValidator';

describe('ChoiceValidator', () => {
  describe('构造函数', () => {
    it('应该正确初始化 correctIndex', () => {
      const validator = new ChoiceValidator(0);
      expect(validator).toBeDefined();
    });
  });

  describe('validate', () => {
    it('当输入为非数字类型时应返回无效', () => {
      const validator = new ChoiceValidator(0);
      const result = validator.validate('0');
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('输入必须是数字');
    });

    it('当输入为数字但类型为字符串时应返回无效', () => {
      const validator = new ChoiceValidator(0);
      const result = validator.validate('0' as unknown as number);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('输入必须是数字');
    });

    it('当选择正确选项时应返回有效', () => {
      const validator = new ChoiceValidator(2);
      const result = validator.validate(2);
      expect(result.valid).toBe(true);
      expect(result.errors).toBeUndefined();
    });

    it('当选择错误选项时应返回无效', () => {
      const validator = new ChoiceValidator(2);
      const result = validator.validate(0);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('答案不正确');
    });

    it('当选择超出范围的选项时应返回无效', () => {
      const validator = new ChoiceValidator(3);
      const result = validator.validate(10);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('答案不正确');
    });

    it('当 index 为 0 时应正确验证', () => {
      const validator = new ChoiceValidator(0);
      expect(validator.validate(0).valid).toBe(true);
      expect(validator.validate(1).valid).toBe(false);
    });

    it('当 index 为负数时应正确验证', () => {
      const validator = new ChoiceValidator(-1);
      const result = validator.validate(-1);
      expect(result.valid).toBe(true);
    });
  });
});
