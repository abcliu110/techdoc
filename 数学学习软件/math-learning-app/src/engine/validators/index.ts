import type { ValidationResult } from '../../engine/step-runtime';

/**
 * 验证器接口
 */
export interface Validator {
  /**
   * 验证输入
   */
  validate(input: unknown): ValidationResult;
}

/**
 * 创建基础验证结果
 */
export function createValidResult(): ValidationResult {
  return { valid: true };
}

/**
 * 创建无效验证结果
 */
export function createInvalidResult(errors: string[]): ValidationResult {
  return { valid: false, errors };
}
