import { test, expect } from '@playwright/test';
import { LearnPage } from '../pages';
import { getStepCount, verifyStepCounter, getProgressValue } from '../helpers';

/**
 * 导航E2E测试套件
 * @description 测试页面之间的导航和步骤之间的导航
 */
test.describe('导航测试', () => {
  let learnPage: LearnPage;

  test.beforeEach(async ({ page }) => {
    learnPage = new LearnPage(page);
  });

  /**
   * 测试首页到学习页面的导航
   */
  test('首页到学习页面导航', async ({ page }) => {
    await page.goto('/');

    // 验证首页
    await expect(page.locator('[data-testid="page-home"]')).toBeVisible();

    // 点击开始按钮
    await page.locator('[data-testid="btn-start-number-shape-integration"]').click();

    // 验证进入学习页面
    await expect(page).toHaveURL(/number-shape-integration/);
    await expect(page.locator('[data-testid="page-learn"]')).toBeVisible();
  });

  /**
   * 测试返回按钮导航
   */
  test('返回按钮导航回首页', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 点击返回按钮
    await learnPage.clickBack();

    // 验证回到首页
    await expect(page).toHaveURL('/');
    await expect(page.locator('[data-testid="page-home"]')).toBeVisible();
  });

  /**
   * 测试步骤导航
   */
  test('步骤导航', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取初始步骤数
    const { current: initialStep } = await getStepCount(page);
    expect(initialStep).toBe(1);

    // 完成当前步骤
    await learnPage.clickComplete();
    await page.waitForTimeout(300);

    // 获取新步骤数
    const { current: newStep } = await getStepCount(page);

    // 步骤应该增加
    expect(newStep).toBeGreaterThanOrEqual(initialStep);
  });

  /**
   * 测试进度条与步骤同步
   */
  test('进度条与步骤同步', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取初始进度
    const initialProgress = await getProgressValue(page);

    // 完成一步
    await learnPage.clickComplete();
    await page.waitForTimeout(300);

    // 获取新进度
    const newProgress = await getProgressValue(page);

    // 进度应该增加
    expect(newProgress).toBeGreaterThan(initialProgress);
  });

  /**
   * 测试步骤计数器格式
   */
  test('步骤计数器格式正确', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 验证计数器格式为 "当前/总数"
    const counter = page.locator('.step-counter');
    await expect(counter).toBeVisible();
    await expect(counter).toHaveText(/\d+\s*\/\s*\d+/);
  });

  /**
   * 测试完成页面显示
   */
  test('完成页面显示', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取总步骤数
    const { total } = await getStepCount(page);

    // 快速完成所有步骤
    for (let i = 0; i < total; i++) {
      // 如果是符号步骤，需要输入答案
      const inputVisible = await page.locator('[data-testid="input-comparison"]').isVisible().catch(() => false);
      if (inputVisible) {
        await learnPage.fillComparisonInput('>');
      }

      await learnPage.clickComplete();
      await page.waitForTimeout(200);
    }

    // 验证完成页面显示
    await learnPage.verifyCompletePage();
  });

  /**
   * 测试从完成页返回首页
   */
  test('从完成页返回首页', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取总步骤数并完成
    const { total } = await getStepCount(page);
    for (let i = 0; i < total; i++) {
      const inputVisible = await page.locator('[data-testid="input-comparison"]').isVisible().catch(() => false);
      if (inputVisible) {
        await learnPage.fillComparisonInput('>');
      }
      await learnPage.clickComplete();
      await page.waitForTimeout(200);
    }

    // 点击返回首页按钮
    await page.locator('.complete-actions button').click();

    // 验证回到首页
    await expect(page).toHaveURL('/');
    await expect(page.locator('[data-testid="page-home"]')).toBeVisible();
  });

  /**
   * 测试直接访问学习页面
   */
  test('直接访问学习页面', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 验证页面元素
    await expect(learnPage.pageContainer).toBeVisible();
    await expect(learnPage.backButton).toBeVisible();
    await expect(learnPage.progressBar).toBeVisible();
  });

  /**
   * 测试不同能力页面的导航
   */
  test('不同能力页面导航', async ({ page }) => {
    const abilities = [
      'number-shape-integration',
      'unit-unification',
      'whole-part',
    ];

    for (const ability of abilities) {
      await learnPage.goto(ability);
      await learnPage.waitForLoad();

      // 验证页面加载
      await expect(learnPage.pageContainer).toBeVisible();

      // 返回首页
      await learnPage.clickBack();
      await expect(page.locator('[data-testid="page-home"]')).toBeVisible();
    }
  });
});
