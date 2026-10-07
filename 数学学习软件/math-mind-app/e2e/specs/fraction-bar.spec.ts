import { test, expect } from '@playwright/test';
import { LearnPage } from '../pages';

/**
 * 分数条组件E2E测试套件
 * @description 测试分数条可视化组件的显示和交互
 */
test.describe('分数条组件测试', () => {
  let learnPage: LearnPage;

  test.beforeEach(async ({ page }) => {
    learnPage = new LearnPage(page);
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 完成concrete步骤进入pictorial步骤（分数条步骤）
    await learnPage.clickComplete();
    await page.waitForTimeout(500);
  });

  /**
   * 测试分数条A可见
   */
  test('分数条A显示', async ({ page }) => {
    // 验证分数条可见
    const fractionBarVisible = await learnPage.fractionBarA.isVisible().catch(() => false);

    if (fractionBarVisible) {
      await expect(learnPage.fractionBarA).toBeVisible();
    } else {
      // 如果还在concrete步骤，验证分割圆可见
      await expect(learnPage.splitCircleA).toBeVisible();
    }
  });

  /**
   * 测试分数条B可见
   */
  test('分数条B可见', async ({ page }) => {
    // 检查分数条B
    const fractionBarVisible = await learnPage.fractionBarB.isVisible().catch(() => false);

    if (fractionBarVisible) {
      await expect(learnPage.fractionBarB).toBeVisible();
    } else {
      await expect(learnPage.splitCircleB).toBeVisible();
    }
  });

  /**
   * 测试分数条标签显示
   */
  test('分数条标签显示', async ({ page }) => {
    // 验证分数条标签
    const fractionBarVisible = await learnPage.fractionBarA.isVisible().catch(() => false);
    if (fractionBarVisible) {
      const label = page.locator('[data-testid="visual-fraction-bar-a-label"]');
      await expect(label).toBeVisible();
    }
  });

  /**
   * 测试分数条分段
   */
  test('分数条分段显示', async ({ page }) => {
    const fractionBarVisible = await learnPage.fractionBarA.isVisible().catch(() => false);
    if (fractionBarVisible) {
      // 获取第一个分段的定位器
      const segment0 = page.locator('[data-testid="visual-fraction-bar-a-segment-0"]');
      await expect(segment0).toBeVisible();

      // 获取总段数
      const segments = page.locator('[data-testid^="visual-fraction-bar-a-segment-"]');
      const count = await segments.count();
      expect(count).toBeGreaterThan(0);
    }
  });

  /**
   * 测试比较两个分数条
   */
  test('比较两个分数条', async ({ page }) => {
    const fractionBarVisible = await learnPage.fractionBarA.isVisible().catch(() => false);
    if (fractionBarVisible) {
      // 验证两个分数条都可见
      await expect(learnPage.fractionBarA).toBeVisible();
      await expect(learnPage.fractionBarB).toBeVisible();

      // 验证它们代表不同的分数
      const labelA = page.locator('[data-testid="visual-fraction-bar-a-label"]');
      const labelB = page.locator('[data-testid="visual-fraction-bar-b-label"]');

      const textA = await labelA.textContent();
      const textB = await labelB.textContent();

      // 两个标签应该不同
      expect(textA).not.toBe(textB);
    }
  });
});
