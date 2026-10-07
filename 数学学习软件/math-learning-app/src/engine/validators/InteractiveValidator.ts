import type { Validator } from './index';
import type { ValidationResult } from '../../engine/step-runtime';

/**
 * 交互验证器
 * 验证用户交互是否满足要求
 */
export class InteractiveValidator implements Validator {
  private requiredInteraction: string;

  constructor(requiredInteraction: string) {
    this.requiredInteraction = requiredInteraction;
  }

  validate(input: unknown): ValidationResult {
    if (typeof input !== 'object' || input === null) {
      return { valid: false, errors: ['输入必须是对象'] };
    }

    const data = input as Record<string, unknown>;
    const interaction = data.interaction as string | undefined;

    if (!interaction) {
      return { valid: false, errors: ['缺少交互类型'] };
    }

    if (interaction !== this.requiredInteraction) {
      return {
        valid: false,
        errors: [`期望交互: ${this.requiredInteraction}, 实际: ${interaction}`],
      };
    }

    return { valid: true };
  }
}

/**
 * 选择验证器
 * 验证选择题答案
 */
export class ChoiceValidator implements Validator {
  private correctIndex: number;

  constructor(correctIndex: number) {
    this.correctIndex = correctIndex;
  }

  validate(input: unknown): ValidationResult {
    if (typeof input !== 'number') {
      return { valid: false, errors: ['输入必须是数字'] };
    }

    if (input === this.correctIndex) {
      return { valid: true };
    }

    return { valid: false, errors: ['答案不正确'] };
  }
}

/**
 * 输入验证器
 * 验证文本输入
 */
export class InputValidator implements Validator {
  private expectedAnswers: string[];
  private tolerance: number;

  constructor(expectedAnswers: string[], tolerance: number = 0) {
    this.expectedAnswers = expectedAnswers;
    this.tolerance = tolerance;
  }

  validate(input: unknown): ValidationResult {
    if (typeof input !== 'string') {
      return { valid: false, errors: ['输入必须是字符串'] };
    }

    const normalized = input.trim().toLowerCase();

    for (const answer of this.expectedAnswers) {
      const normalizedAnswer = answer.trim().toLowerCase();
      if (normalized === normalizedAnswer) {
        return { valid: true };
      }
    }

    if (this.tolerance > 0) {
      // 简单模糊匹配（未来可以改进）
      return { valid: false, errors: ['答案不正确'] };
    }

    return {
      valid: false,
      errors: [`期望答案: ${this.expectedAnswers.join(' 或 ')}`],
    };
  }
}
