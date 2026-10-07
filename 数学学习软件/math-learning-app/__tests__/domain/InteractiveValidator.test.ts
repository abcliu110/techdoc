import { describe, it, expect } from 'vitest';
import { InteractiveValidator } from '../../src/engine/validators/InteractiveValidator';

describe('InteractiveValidator', () => {
  describe('构造函数', () => {
    it('应该正确初始化 requiredInteraction', () => {
      const validator = new InteractiveValidator('tap');
      expect(validator).toBeDefined();
    });
  });

  describe('validate', () => {
    it('当输入为 null 时应返回无效', () => {
      const validator = new InteractiveValidator('tap');
      const result = validator.validate(null);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('输入必须是对象');
    });

    it('当输入为非对象类型时应返回无效', () => {
      const validator = new InteractiveValidator('tap');
      const result = validator.validate('string');
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('输入必须是对象');
    });

    it('当输入对象缺少 interaction 字段时应返回无效', () => {
      const validator = new InteractiveValidator('tap');
      const result = validator.validate({});
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('缺少交互类型');
    });

    it('当交互类型匹配时应返回有效', () => {
      const validator = new InteractiveValidator('tap');
      const result = validator.validate({ interaction: 'tap' });
      expect(result.valid).toBe(true);
      expect(result.errors).toBeUndefined();
    });

    it('当交互类型不匹配时应返回无效', () => {
      const validator = new InteractiveValidator('tap');
      const result = validator.validate({ interaction: 'drag' });
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('期望交互: tap, 实际: drag');
    });

    it('当支持多种交互类型时应正确验证', () => {
      const validator = new InteractiveValidator('drag');
      const result = validator.validate({ interaction: 'drag' });
      expect(result.valid).toBe(true);
    });

    it('当支持 split 交互类型时应正确验证', () => {
      const validator = new InteractiveValidator('split');
      const result = validator.validate({
        interaction: 'split',
        circleIndex: 0,
        segmentIndex: 1
      });
      expect(result.valid).toBe(true);
    });

    it('当支持 select 交互类型时应正确验证', () => {
      const validator = new InteractiveValidator('select');
      const result = validator.validate({
        interaction: 'select',
        selectedOption: 'A'
      });
      expect(result.valid).toBe(true);
    });
  });
});
