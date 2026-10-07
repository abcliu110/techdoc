import { test, expect } from '@playwright/test';
import { HomePage } from '../pages';

/**
 * 首页E2E测试套件
 * @description 测试首页加载、卡片显示、导航等功能
 */
test.describe('首页测试', () => {
  let homePage: HomePage;

  test.beforeEach(async ({ page }) => {
    homePage = new HomePage(page);
    await homePage.goto();
    await homePage.waitForLoad();
  });

  /**
   * 测试首页正确加载
   */
  test('首页正确加载', async ({ page }) => {
    // 验证页面容器可见
    await expect(page.locator('[data-testid="page-home"]')).toBeVisible();

    // 验证标题显示
    await expect(page.locator('.home-title')).toContainText('数学思维启发系统');

    // 验证副标题显示
    await expect(page.locator('.home-subtitle')).toBeVisible();
  });

  /**
   * 测试五大数学思想卡片都显示
   */
  test('显示五大数学思想卡片', async ({ page }) => {
    // 验证所有能力卡片都显示
    await homePage.verifyAllAbilityCards();
  });

  /**
   * 测试数形结合卡片显示
   */
  test('数形结合卡片显示正确', async ({ page }) => {
    const card = homePage.getAbilityCard('number-shape-integration');

    // 验证卡片可见
    await expect(card).toBeVisible();

    // 验证卡片标题包含"数形结合"
    await expect(card.locator('.card-title')).toContainText('数形结合');

    // 验证开始按钮可见
    const startButton = page.locator('[data-testid="btn-start-number-shape-integration"]');
    await expect(startButton).toBeVisible();
    await expect(startButton).toContainText('开始学习');
  });

  /**
   * 测试点击开始按钮进入学习页面
   */
  test('点击开始按钮进入学习页面', async ({ page }) => {
    // 点击数形结合的开始按钮
    await homePage.clickStartButton('number-shape-integration');

    // 验证URL变化
    await expect(page).toHaveURL(/\/learn\/number-shape-integration/);

    // 验证学习页面加载
    await expect(page.locator('[data-testid="page-learn"]')).toBeVisible();
  });

  /**
   * 测试点击能力卡片进入学习页面
   */
  test('点击能力卡片进入学习页面', async ({ page }) => {
    // 点击数形结合卡片
    await homePage.clickAbilityCard('number-shape-integration');

    // 验证URL变化
    await expect(page).toHaveURL(/\/learn\/number-shape-integration/);
  });

  /**
   * 测试能力画像卡片显示
   */
  test('能力画像卡片显示', async ({ page }) => {
    const profileCard = homePage.profileCard;

    // 验证卡片可见
    await expect(profileCard).toBeVisible();

    // 验证卡片标题
    await expect(profileCard.locator('.card-title')).toContainText('查看能力画像');

    // 验证查看按钮
    await expect(homePage.viewProfileButton).toBeVisible();
  });

  /**
   * 测试五个开始按钮都可点击
   */
  test('所有开始按钮可点击', async ({ page }) => {
    const abilities = [
      'number-shape-integration',
      'unit-unification',
      'whole-part',
      'transformation',
      'equation-balance',
    ];

    for (const ability of abilities) {
      const button = page.locator(`[data-testid="btn-start-${ability}"]`);
      await expect(button).toBeVisible();
      await expect(button).toBeEnabled();

      // 点击后验证页面跳转
      await button.click();
      await expect(page).toHaveURL(new RegExp(`/learn/${ability}`));

      // 返回首页继续测试下一个
      await page.goto('/');
    }
  });

  /**
   * 测试卡片悬停效果（CSS测试）
   */
  test('卡片悬停效果', async ({ page }) => {
    const card = homePage.getAbilityCard('number-shape-integration');

    // 验证卡片初始状态
    await expect(card).toBeVisible();

    // 悬停时添加hover类
    await card.hover();
    await expect(card).toHaveClass(/ability-card/);
  });

  /**
   * 测试页脚显示
   */
  test('页脚显示正确', async ({ page }) => {
    const footer = page.locator('.home-footer');

    // 验证页脚可见
    await expect(footer).toBeVisible();

    // 验证版本信息
    await expect(footer).toContainText('数学思维启发型学习系统 v1.0');
  });
});
