/**
 * Schema 验证工具
 *
 * 提供类型安全的验证函数，用于在运行时检查数据是否符合 Schema 定义。
 *
 * @module shared/validate
 */

import { ZodError, ZodSchema } from 'zod';

/**
 * 验证结果接口
 */
export interface ValidationResult<T> {
  success: boolean;
  data?: T;
  errors?: ZodError['errors'];
  formattedErrors?: string;
}

/**
 * 通用验证函数
 *
 * @param data - 待验证的数据
 * @param schema - Zod Schema
 * @returns 验证结果
 *
 * @example
 * ```typescript
 * const result = validate(123, z.number().min(0));
 * if (!result.success) {
 *   console.log(result.errors);
 * }
 * ```
 */
export function validate<T>(data: unknown, schema: ZodSchema<T>): ValidationResult<T> {
  const result = schema.safeParse(data);

  if (result.success) {
    return { success: true, data: result.data };
  }

  return {
    success: false,
    errors: result.error.errors,
    formattedErrors: JSON.stringify(result.error.format(), null, 2),
  };
}

/**
 * 严格验证函数，验证失败时抛出异常
 *
 * @param data - 待验证的数据
 * @param schema - Zod Schema
 * @param options - 可选配置
 * @returns 验证后的数据
 * @throws ZodError 验证失败时
 *
 * @example
 * ```typescript
 * const data = validateStrict(step, LearningStepSchema, { name: 'step-1' });
 * ```
 */
export function validateStrict<T>(
  data: unknown,
  schema: ZodSchema<T>,
  options?: { name?: string }
): T {
  const result = schema.safeParse(data);

  if (!result.success) {
    const context = options?.name ? `[${options.name}] ` : '';
    const messages = result.error.errors
      .map((e) => `${context}${e.path.join('.')}: ${e.message}`)
      .join('; ');

    throw new Error(`Schema validation failed: ${messages}`);
  }

  return result.data;
}

/**
 * 验证学习步骤
 *
 * @param step - 待验证的步骤数据
 * @returns 验证结果
 */
export function validateStep(step: unknown): ValidationResult<unknown> {
  // 动态导入以避免循环依赖
  const { LearningStepSchema } = require('./schemas');
  return validate(step, LearningStepSchema);
}

/**
 * 验证知识点
 *
 * @param knowledgePoint - 待验证的知识点数据
 * @returns 验证结果
 */
export function validateKnowledgePoint(knowledgePoint: unknown): ValidationResult<unknown> {
  const { KnowledgePointSchema } = require('./schemas');
  return validate(knowledgePoint, KnowledgePointSchema);
}

/**
 * 验证分割圆配置
 *
 * @param config - 待验证的配置
 * @returns 验证结果
 *
 * @example
 * ```typescript
 * const result = validateSplitCircleConfig({
 *   circles: [{ denominator: 4, highlighted: [0, 1, 2] }]
 * });
 * ```
 */
export function validateSplitCircleConfig(config: unknown) {
  const { SplitCircleConfigSchema } = require('./schemas');
  return validate(config, SplitCircleConfigSchema);
}

/**
 * 验证分数条配置
 *
 * @param config - 待验证的配置
 * @returns 验证结果
 */
export function validateFractionBarConfig(config: unknown) {
  const { FractionBarConfigSchema } = require('./schemas');
  return validate(config, FractionBarConfigSchema);
}

/**
 * 验证苹果配置
 *
 * @param config - 待验证的配置
 * @returns 验证结果
 *
 * @example
 * ```typescript
 * const result = validateApplesConfig({
 *   totalApples: 10,
 *   highlightRange: [0, 5]
 * });
 * ```
 */
export function validateApplesConfig(config: unknown) {
  const { ApplesConfigSchema } = require('./schemas');
  return validate(config, ApplesConfigSchema);
}

/**
 * 验证天平配置
 *
 * @param config - 待验证的配置
 * @returns 验证结果
 */
export function validateBalanceConfig(config: unknown) {
  const { BalanceConfigSchema } = require('./schemas');
  return validate(config, BalanceConfigSchema);
}

/**
 * 验证尺子配置
 *
 * @param config - 待验证的配置
 * @returns 验证结果
 */
export function validateRulerConfig(config: unknown) {
  const { RulerConfigSchema } = require('./schemas');
  return validate(config, RulerConfigSchema);
}

/**
 * 验证形状配置
 *
 * @param config - 待验证的配置
 * @returns 验证结果
 */
export function validateShapesConfig(config: unknown) {
  const { ShapesConfigSchema } = require('./schemas');
  return validate(config, ShapesConfigSchema);
}

/**
 * 创建验证装饰器工厂函数
 *
 * 用于在函数入口处自动验证参数
 *
 * @param schema - Zod Schema
 * @returns 装饰器函数
 *
 * @example
 * ```typescript
 * const validateStepParam = createValidator(z.object({
 *   id: z.string(),
 *   type: z.string()
 * }));
 *
 * function loadStep(params: unknown) {
 *   return validateStepParam(params, () => {
 *     // 实际逻辑
 *   });
 * }
 * ```
 */
export function createValidator<T>(
  schema: ZodSchema<T>
): (data: unknown, fn: () => T) => T {
  return (data: unknown, fn: () => T): T => {
    const result = validate(data, schema);
    if (!result.success) {
      throw new Error(`Validation failed: ${JSON.stringify(result.formattedErrors)}`);
    }
    return fn();
  };
}

/**
 * 批量验证数组
 *
 * @param items - 待验证的数组
 * @param schema - Zod Schema
 * @returns 验证结果，包含成功项和失败项
 *
 * @example
 * ```typescript
 * const result = validateBatch(steps, LearningStepSchema);
 * console.log(`Valid: ${result.valid.length}, Invalid: ${result.invalid.length}`);
 * ```
 */
export function validateBatch<T>(
  items: unknown[],
  schema: ZodSchema<T>
): { valid: T[]; invalid: { index: number; errors: ZodError['errors'] }[] } {
  const valid: T[] = [];
  const invalid: { index: number; errors: ZodError['errors'] }[] = [];

  items.forEach((item, index) => {
    const result = schema.safeParse(item);
    if (result.success) {
      valid.push(result.data);
    } else {
      invalid.push({ index, errors: result.error.errors });
    }
  });

  return { valid, invalid };
}

/**
 * 验证并打印错误（开发环境用）
 *
 * @param data - 待验证的数据
 * @param schema - Zod Schema
 * @param label - 标签，用于日志输出
 * @returns 验证是否成功
 */
export function validateAndLog<T>(
  data: unknown,
  schema: ZodSchema<T>,
  label: string = 'data'
): boolean {
  const result = schema.safeParse(data);

  if (result.success) {
    return true;
  }

  console.error(`[${label}] Schema validation failed:`);
  result.error.errors.forEach((err) => {
    console.error(`  - ${err.path.join('.')}: ${err.message}`);
  });

  return false;
}
