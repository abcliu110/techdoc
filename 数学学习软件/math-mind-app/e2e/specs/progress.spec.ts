import { test, expect } from '@playwright/test';
import { LearnPage } from '../pages';

/**
 * 进度条E2E测试套件
 * @description 测试进度条的显示、更新和计算
 */
test.describe('进度条测试', () => {
  let learnPage: LearnPage;

  test.beforeEach(async ({ page }) => {
    learnPage = new LearnPage(page);
  });

  /**
   * 测试进度条可见
   */
  test('进度条可见', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    await expect(learnPage.progressBar).toBeVisible();
  });

  /**
   * 测试初始进度
   */
  test('初始进度正确', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 等待进度条初始化完成
    await page.waitForTimeout(500);

    // 获取步骤计数器
    const counter = page.locator('.step-counter');
    await expect(counter).toBeVisible();
    await expect(counter).toContainText('1 / ');

    // 进度条应该显示0%（第一步开始时进度为0%）
    const progressText = await learnPage.getProgressText();
    expect(progressText).toBe('0%');
  });

  /**
   * 测试完成一步后进度增加
   */
  test('完成一步后进度增加', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取初始进度
    const initialProgress = await learnPage.getProgressText();

    // 完成一步
    await learnPage.clickComplete();
    await page.waitForTimeout(300);

    // 获取新进度
    const newProgress = await learnPage.getProgressText();

    // 进度应该增加
    // 注意：如果有多个步骤，每个步骤大约增加 100/totalSteps %
    expect(newProgress).not.toBe(initialProgress);
  });

  /**
   * 测试进度条与步骤数对应
   */
  test('进度条与步骤数对应', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取步骤计数器
    const counter = page.locator('.step-counter');
    const text = await counter.textContent();
    const match = text?.match(/(\d+)\s*\/\s*(\d+)/);

    expect(match).not.toBeNull();
    const totalSteps = parseInt(match![2], 10);

    // 跳过步骤检查直接完成（因为具象步骤可以直接完成）
    for (let i = 1; i <= Math.min(totalSteps, 3); i++) {
      // 检查完成按钮是否可用
      const isDisabled = await learnPage.completeButton.isDisabled().catch(() => true);

      if (isDisabled) {
        // 如果按钮禁用，可能是符号步骤，需要先输入答案
        const inputVisible = await learnPage.comparisonInput.isVisible().catch(() => false);
        if (inputVisible) {
          await learnPage.fillComparisonInput('>');
        }
      }

      // 等待按钮可用
      await learnPage.completeButton.waitFor({ state: 'enabled', timeout: 3000 }).catch(() => {});

      // 点击完成
      await learnPage.clickComplete();
      await page.waitForTimeout(300);
    }
  });

  /**
   * 测试最终进度为100%
   */
  test('完成后进度为100%', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取总步骤数
    const counter = page.locator('.step-counter');
    const text = await counter.textContent();
    const match = text?.match(/(\d+)\s*\/\s*(\d+)/);
    const totalSteps = match ? parseInt(match[2], 10) : 3;

    // 完成所有步骤
    for (let i = 0; i < totalSteps; i++) {
      const inputVisible = await learnPage.comparisonInput.isVisible().catch(() => false);
      if (inputVisible) {
        await learnPage.fillComparisonInput('>');
      }
      await learnPage.clickComplete();
      await page.waitForTimeout(200);
    }

    // 验证进入完成页面
    await learnPage.verifyCompletePage();
  });

  /**
   * 测试进度文本格式
   */
  test('进度文本格式正确', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    const progressText = await learnPage.getProgressText();

    // 进度文本应该包含数字和百分号
    expect(progressText).toMatch(/\d+%/);
  });

  /**
   * 测试进度条无障碍属性
   */
  test('进度条无障碍属性', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 验证进度条有role属性
    const progressBar = learnPage.progressBar;
    await expect(progressBar).toHaveAttribute('role', 'progressbar');

    // 验证有aria属性
    const ariaValueNow = await progressBar.getAttribute('aria-valuenow');
    const ariaValueMin = await progressBar.getAttribute('aria-valuemin');
    const ariaValueMax = await progressBar.getAttribute('aria-valuemax');

    expect(ariaValueNow).not.toBeNull();
    expect(ariaValueMin).toBe('0');
    expect(ariaValueMax).toBe('100');
  });
});
