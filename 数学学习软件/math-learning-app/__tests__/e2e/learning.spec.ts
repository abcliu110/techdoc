import { test, expect, Page } from '@playwright/test';

/**
 * 学习功能端到端测试
 */

// concrete.json 要求：圆0(denominator:4)高亮[0,1,2]，圆1(denominator:3)高亮[0,1]
async function completeSplitCircleTask(page: Page) {
  const circleConfig = [
    { denominator: 4, highlighted: [0, 1, 2] },
    { denominator: 3, highlighted: [0, 1] },
  ];

  // 使用path选择器
  const segments = page.locator('path');

  let globalOffset = 0;
  for (const circle of circleConfig) {
    for (const localIdx of circle.highlighted) {
      const globalIndex = globalOffset + localIdx;
      await segments.nth(globalIndex).click({ force: true });
      await page.waitForTimeout(50);
    }
    globalOffset += circle.denominator;
  }
}

test.describe('学习功能', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('首页加载正常', async ({ page }) => {
    // 检查页面标题
    await expect(page).toHaveTitle('数学学习软件');

    // 检查欢迎语
    await expect(page.locator('.hero-title')).toContainText('欢迎来到数学学习');

    // 检查数学思想区域
    await expect(page.locator('.section-title').first()).toContainText('数学思想');
  });

  test('可以进入学习页面', async ({ page }) => {
    // 点击第一个知识点卡片
    await page.locator('.topic-card').first().click();

    // 等待页面跳转
    await page.waitForURL(/\/learn\//);

    // 检查学习页面元素
    await expect(page.locator('.learn-page')).toBeVisible();
  });

  test('学习步骤可以交互', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 检查步骤内容存在
    await expect(page.locator('.step-header')).toBeVisible();
    await expect(page.locator('.scenario-card')).toBeVisible();

    // 检查分割圆可视化
    await expect(page.locator('.split-circles')).toBeVisible();

    // 检查完成按钮存在
    await expect(page.locator('.step-actions .btn-primary')).toBeVisible();
  });

  test('点击分割圆可以高亮', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 点击第一个扇形
    const segment = page.locator('path').first();
    await segment.click({ force: true });

    // 等待 DOM 更新
    await page.waitForTimeout(100);

    // 验证扇形被高亮（分数标签应该显示 1/4）
    await expect(page.locator('.fraction-label').first()).toHaveText(/1\/\d+/);
  });

  test('完成所有扇形高亮后显示反馈并启用按钮', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 完成所有扇形高亮
    await completeSplitCircleTask(page);

    // 检查是否有反馈
    await expect(page.locator('.step-feedback')).toBeVisible({ timeout: 5000 });

    // 检查按钮已启用
    const completeButton = page.locator('.step-actions .btn-primary');
    await expect(completeButton).toBeEnabled();
    await expect(completeButton).toContainText('完成');
  });
});
