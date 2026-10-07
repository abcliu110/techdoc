import { type Page, type Locator, expect } from '@playwright/test';

/**
 * 填写输入框辅助函数
 * @description 统一处理各种输入框的填写和验证
 */

/**
 * 填写比较表达式输入框
 * @param page Playwright Page对象
 * @param value 要填写的值
 */
export async function fillInput(page: Page, value: string): Promise<void> {
  const input = page.locator('[data-testid="input-comparison"]');
  await expect(input).toBeVisible();
  await input.fill(value);
}

/**
 * 清空并填写输入框
 * @param page Playwright Page对象
 * @param value 要填写的值
 */
export async function clearAndFillInput(page: Page, value: string): Promise<void> {
  const input = page.locator('[data-testid="input-comparison"]');
  await expect(input).toBeVisible();
  await input.clear();
  await input.fill(value);
}

/**
 * 获取输入框当前值
 * @param page Playwright Page对象
 * @returns 输入框的值
 */
export async function getInputValue(page: Page): Promise<string> {
  const input = page.locator('[data-testid="input-comparison"]');
  return input.inputValue();
}

/**
 * 验证输入框值
 * @param page Playwright Page对象
 * @param expectedValue 期望的值
 */
export async function verifyInputValue(page: Page, expectedValue: string): Promise<void> {
  const input = page.locator('[data-testid="input-comparison"]');
  await expect(input).toHaveValue(expectedValue);
}

/**
 * 验证输入框为空
 * @param page Playwright Page对象
 */
export async function verifyInputEmpty(page: Page): Promise<void> {
  const input = page.locator('[data-testid="input-comparison"]');
  await expect(input).toHaveValue('');
}

/**
 * 模拟错误输入后正确输入
 * @param page Playwright Page对象
 * @param wrongValue 错误值
 * @param correctValue 正确值
 */
export async function inputWithRetry(
  page: Page,
  wrongValue: string,
  correctValue: string
): Promise<void> {
  // 先输入错误值
  await fillInput(page, wrongValue);

  // 验证出现错误反馈
  const errorFeedback = page.locator('[data-testid="feedback-error"]');
  await expect(errorFeedback).toBeVisible();

  // 清空并输入正确值
  await clearAndFillInput(page, correctValue);
}

/**
 * 按下回车键
 * @param page Playwright Page对象
 * @param inputLocator 输入框定位器（可选）
 */
export async function pressEnter(page: Page, inputLocator?: Locator): Promise<void> {
  if (inputLocator) {
    await inputLocator.press('Enter');
  } else {
    await page.locator('[data-testid="input-comparison"]').press('Enter');
  }
}

export default fillInput;
