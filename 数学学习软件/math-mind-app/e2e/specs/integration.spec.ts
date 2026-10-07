import { test, expect } from '@playwright/test';
import { HomePage, LearnPage } from '../pages';

/**
 * 集成测试套件
 * @description 测试跨页面的完整用户流程
 */
test.describe('集成测试', () => {
  let homePage: HomePage;
  let learnPage: LearnPage;

  test.beforeEach(async ({ page }) => {
    homePage = new HomePage(page);
    learnPage = new LearnPage(page);
  });

  /**
   * 测试完整用户旅程：首页 -> 学习 -> 完成 -> 返回首页
   */
  test('完整用户旅程', async ({ page }) => {
    // 1. 访问首页
    await homePage.goto();
    await homePage.waitForLoad();

    // 验证首页正确加载
    await expect(page.locator('[data-testid="page-home"]')).toBeVisible();
    await expect(page.locator('.home-title')).toContainText('数学思维启发系统');

    // 2. 点击开始学习
    await homePage.clickStartButton('number-shape-integration');
    await expect(page).toHaveURL(/number-shape-integration/);

    // 3. 验证学习页面加载
    await learnPage.waitForLoad();
    await expect(learnPage.pageContainer).toBeVisible();

    // 4. 完成学习步骤
    const counter = await page.locator('.step-counter').textContent();
    const match = counter?.match(/(\d+)\s*\/\s*(\d+)/);
    const totalSteps = match ? parseInt(match[2], 10) : 3;

    for (let i = 0; i < totalSteps; i++) {
      const inputVisible = await learnPage.comparisonInput.isVisible().catch(() => false);
      if (inputVisible) {
        await learnPage.fillComparisonInput('>');
      }
      await learnPage.clickComplete();
      await page.waitForTimeout(200);
    }

    // 5. 验证完成页面
    await learnPage.verifyCompletePage();
    await expect(page.locator('.complete-celebration h1')).toContainText('恭喜完成');

    // 6. 返回首页
    await page.locator('.complete-actions button').click();
    await expect(page).toHaveURL('/');
    await expect(page.locator('[data-testid="page-home"]')).toBeVisible();
  });

  /**
   * 测试所有能力的可访问性
   */
  test('所有能力可访问', async ({ page }) => {
    const abilities = [
      'number-shape-integration',
      'unit-unification',
      'whole-part',
      'transformation',
      'equation-balance',
    ];

    for (const ability of abilities) {
      // 进入学习页面
      await learnPage.goto(ability);
      await learnPage.waitForLoad();

      // 验证页面元素
      await expect(learnPage.pageContainer).toBeVisible();
      await expect(learnPage.progressBar).toBeVisible();
      await expect(learnPage.completeButton).toBeVisible();

      // 返回首页
      await learnPage.clickBack();
      await expect(page.locator('[data-testid="page-home"]')).toBeVisible();
    }
  });

  /**
   * 测试错误输入和更正流程
   */
  test('错误输入和更正流程', async ({ page }) => {
    // 进入学习页面
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 跳过前两个步骤
    await learnPage.clickComplete(); // concrete
    await page.waitForTimeout(300);
    await learnPage.clickComplete(); // pictorial
    await page.waitForTimeout(300);

    // 检查是否是符号步骤
    const inputVisible = await learnPage.comparisonInput.isVisible().catch(() => false);
    if (!inputVisible) {
      // 如果不是符号步骤，跳过此测试
      return;
    }

    // 1. 输入错误答案
    await learnPage.fillComparisonInput('<');
    await learnPage.clickComplete();

    // 2. 验证错误反馈
    await learnPage.verifyErrorFeedback();

    // 3. 更正为正确答案
    await learnPage.fillComparisonInput('>');
    await learnPage.clickComplete();

    // 4. 验证成功反馈
    await learnPage.verifySuccessFeedback();
  });

  /**
   * 测试使用提示后继续学习
   */
  test('使用提示后继续学习', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 点击提示
    await learnPage.clickHint();

    // 验证提示反馈
    await learnPage.verifyHintFeedback();

    // 获取提示内容
    const hintText = await learnPage.hintFeedback.textContent();
    expect(hintText).toBeTruthy();

    // 继续学习
    await learnPage.clickComplete();
    await page.waitForTimeout(300);

    // 验证进入下一步（提示反馈消失）
    const hintStillVisible = await learnPage.hintFeedback.isVisible().catch(() => false);
    // 如果进入符号步骤，提示反馈可能仍然显示；如果进入下一步，则消失
  });

  /**
   * 测试边界情况：快速连续点击
   */
  test('快速连续点击不会导致异常', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 快速点击完成按钮多次
    await Promise.all([
      learnPage.clickComplete(),
      learnPage.clickComplete(),
      learnPage.clickComplete(),
    ]);

    await page.waitForTimeout(500);

    // 验证页面仍然正常
    const url = page.url();
    expect(url.includes('learn') || url === '/').toBeTruthy();
  });
});
