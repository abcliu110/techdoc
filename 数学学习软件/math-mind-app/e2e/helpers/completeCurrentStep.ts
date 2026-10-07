import { type Page, type Locator, expect } from '@playwright/test';

/**
 * 完成当前步骤辅助函数
 * @description 根据当前步骤类型智能完成步骤
 * @param page Playwright Page对象
 * @param stepType 当前步骤类型
 */
export async function completeCurrentStep(page: Page, stepType: string): Promise<void> {
  switch (stepType) {
    case 'concrete':
      // 具象步骤：直接点击完成按钮
      await page.locator('[data-testid="btn-complete"]').click();
      break;

    case 'pictorial':
      // 图示步骤：直接点击完成按钮
      await page.locator('[data-testid="btn-complete"]').click();
      break;

    case 'symbolic':
      // 符号步骤：需要先填写正确答案
      const input = page.locator('[data-testid="input-comparison"]');
      await expect(input).toBeVisible();
      await input.fill('>');
      await page.locator('[data-testid="btn-complete"]').click();
      break;

    default:
      // 其他步骤类型：直接点击完成
      await page.locator('[data-testid="btn-complete"]').click();
  }
}

/**
 * 完成当前步骤并验证
 * @param page Playwright Page对象
 * @param stepType 当前步骤类型
 * @param expectSuccess 是否期望成功反馈
 */
export async function completeStepAndVerify(
  page: Page,
  stepType: string,
  expectSuccess: boolean = true
): Promise<void> {
  await completeCurrentStep(page, stepType);

  if (expectSuccess) {
    // 等待成功反馈或进入下一步骤
    const successFeedback = page.locator('[data-testid="feedback-success"]');
    const nextStep = page.locator('[data-testid^="step-"]:visible');

    // 至少有一个应该出现
    const successVisible = await successFeedback.isVisible().catch(() => false);
    const nextVisible = await nextStep.isVisible().catch(() => false);

    if (!successVisible && !nextVisible) {
      throw new Error('Neither success feedback nor next step appeared');
    }
  }
}

export default completeCurrentStep;
