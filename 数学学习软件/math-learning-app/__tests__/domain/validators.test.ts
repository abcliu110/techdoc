import { describe, it, expect } from 'vitest';
import { createValidResult, createInvalidResult } from '../../src/engine/validators/index';

describe('验证器工具函数', () => {
  describe('createValidResult', () => {
    it('应该创建有效的验证结果', () => {
      const result = createValidResult();
      expect(result.valid).toBe(true);
      expect(result.errors).toBeUndefined();
    });
  });

  describe('createInvalidResult', () => {
    it('应该创建无效的验证结果', () => {
      const result = createInvalidResult(['错误1', '错误2']);
      expect(result.valid).toBe(false);
      expect(result.errors).toEqual(['错误1', '错误2']);
    });

    it('应该处理空错误列表', () => {
      const result = createInvalidResult([]);
      expect(result.valid).toBe(false);
      expect(result.errors).toEqual([]);
    });
  });
});
