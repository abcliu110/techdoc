import { type Page, type Locator, expect } from '@playwright/test';

/**
 * 验证进度辅助函数
 * @description 验证学习进度相关的元素和状态
 */

/**
 * 获取进度条定位器
 * @param page Playwright Page对象
 */
function getProgressBar(page: Page): Locator {
  return page.locator('[data-testid="progress-bar"]');
}

/**
 * 获取进度文本定位器
 * @param page Playwright Page对象
 */
function getProgressText(page: Page): Locator {
  return page.locator('[data-testid="progress-bar-text"]');
}

/**
 * 获取步骤计数器定位器
 * @param page Playwright Page对象
 */
function getStepCounter(page: Page): Locator {
  return page.locator('.step-counter');
}

/**
 * 验证进度条可见
 * @param page Playwright Page对象
 */
export async function verifyProgressBarVisible(page: Page): Promise<void> {
  await expect(getProgressBar(page)).toBeVisible();
}

/**
 * 获取当前进度百分比
 * @param page Playwright Page对象
 * @returns 进度百分比数值
 */
export async function getProgressValue(page: Page): Promise<number> {
  const progressBar = getProgressBar(page);
  await expect(progressBar).toBeVisible();

  // 从样式中获取进度值
  const style = await progressBar.getAttribute('style');
  const match = style?.match(/width:\s*(\d+(?:\.\d+)?)%/);
  if (match) {
    return parseFloat(match[1]);
  }

  // 如果没有内联样式，检查aria-valuenow
  const ariaValue = await progressBar.getAttribute('aria-valuenow');
  if (ariaValue) {
    return parseFloat(ariaValue);
  }

  // 从文本中提取进度
  const progressText = await getProgressText(page).textContent();
  const textMatch = progressText?.match(/(\d+)\s*%/);
  if (textMatch) {
    return parseFloat(textMatch[1]);
  }

  throw new Error('Could not determine progress value');
}

/**
 * 验证进度增加
 * @param page Playwright Page对象
 * @param previousProgress 之前的进度值
 * @param expectedIncrease 期望的增加量
 */
export async function verifyProgressIncrease(
  page: Page,
  previousProgress: number,
  expectedIncrease: number
): Promise<void> {
  const newProgress = await getProgressValue(page);
  const actualIncrease = newProgress - previousProgress;

  // 允许一些误差
  expect(actualIncrease).toBeGreaterThanOrEqual(expectedIncrease - 5);
  expect(actualIncrease).toBeLessThanOrEqual(expectedIncrease + 5);
}

/**
 * 获取当前步骤数/总步骤数
 * @param page Playwright Page对象
 * @returns 当前步骤索引和总步骤数
 */
export async function getStepCount(page: Page): Promise<{ current: number; total: number }> {
  const counter = getStepCounter(page);
  await expect(counter).toBeVisible();

  const text = await counter.textContent();
  const match = text?.match(/(\d+)\s*\/\s*(\d+)/);

  if (match) {
    return {
      current: parseInt(match[1], 10),
      total: parseInt(match[2], 10),
    };
  }

  throw new Error('Could not parse step counter');
}

/**
 * 验证步骤计数器更新
 * @param page Playwright Page对象
 * @param expectedCurrent 期望的当前步骤数
 */
export async function verifyStepCounter(page: Page, expectedCurrent: number): Promise<void> {
  const counter = getStepCounter(page);
  await expect(counter).toBeVisible();

  const { current, total } = await getStepCount(page);
  expect(current).toBe(expectedCurrent);

  // 同时验证格式正确
  await expect(counter).toContainText(`/${total}`);
}

/**
 * 验证进度条完成状态
 * @param page Playwright Page对象
 */
export async function verifyProgressComplete(page: Page): Promise<void> {
  const progress = await getProgressValue(page);
  expect(progress).toBe(100);
}

/**
 * 验证步骤之间的进度正确增加
 * @param page Playwright Page对象
 * @param totalSteps 总步骤数
 */
export async function verifyProgressSteps(page: Page, totalSteps: number): Promise<void> {
  const expectedStepIncrement = 100 / totalSteps;
  let previousProgress = 0;

  for (let i = 1; i <= totalSteps; i++) {
    await verifyProgressIncrease(page, previousProgress, expectedStepIncrement);
    previousProgress = await getProgressValue(page);

    if (i < totalSteps) {
      // 如果不是最后一步，点击完成按钮进入下一步
      await page.locator('[data-testid="btn-complete"]').click();
      // 等待下一步加载
      await page.waitForTimeout(500);
    }
  }

  // 验证最终进度为100%
  await verifyProgressComplete(page);
}

export default {
  verifyProgressBarVisible,
  getProgressValue,
  verifyProgressIncrease,
  getStepCount,
  verifyStepCounter,
  verifyProgressComplete,
  verifyProgressSteps,
};
