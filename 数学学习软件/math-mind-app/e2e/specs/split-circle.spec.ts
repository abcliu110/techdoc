import { test, expect } from '@playwright/test';
import { highlightSegment, verifySegmentHighlight, waitForSplitComplete } from '../helpers';

/**
 * 分割圆组件E2E测试套件
 * @description 测试分割圆可视化组件的交互功能
 */
test.describe('分割圆组件测试', () => {
  test.beforeEach(async ({ page }) => {
    // 使用交互测试页面，该页面的分割圆是可交互的
    await page.goto('/test/interaction');
    await page.waitForSelector('[data-testid="test-split-circle"]');
  });

  /**
   * 测试分割圆可见
   */
  test('分割圆显示', async ({ page }) => {
    const splitCircle = page.locator('[data-testid="test-split-circle"]');
    await expect(splitCircle).toBeVisible();
  });

  /**
   * 测试点击扇形高亮显示
   */
  test('点击扇形高亮显示', async ({ page }) => {
    // 获取第一个扇形
    const segment = page.locator('[data-testid="test-split-circle-segment-0"]');

    // 验证扇形可见
    await expect(segment).toBeVisible();

    // 点击扇形
    await segment.click();

    // 验证高亮样式
    await expect(segment).toHaveClass(/highlighted/);
  });

  /**
   * 测试点击已高亮扇形取消高亮
   */
  test('点击已高亮扇形取消高亮', async ({ page }) => {
    const segment = page.locator('[data-testid="test-split-circle-segment-0"]');

    // 先点击高亮
    await segment.click();
    await expect(segment).toHaveClass(/highlighted/);

    // 再点击取消高亮
    await segment.click();
    await expect(segment).not.toHaveClass(/highlighted/);
  });

  /**
   * 测试多个扇形可以同时高亮
   */
  test('多个扇形同时高亮', async ({ page }) => {
    // 高亮前两个扇形
    await highlightSegment(page, 'test-split-circle', 0);
    await highlightSegment(page, 'test-split-circle', 1);

    // 验证两个扇形都是高亮状态
    await verifySegmentHighlight(page, 'test-split-circle', 0, true);
    await verifySegmentHighlight(page, 'test-split-circle', 1, true);
  });

  /**
   * 测试辅助函数highlightSegment
   */
  test('使用辅助函数高亮扇形', async ({ page }) => {
    // 使用辅助函数
    await highlightSegment(page, 'test-split-circle', 2);

    // 验证高亮
    await verifySegmentHighlight(page, 'test-split-circle', 2, true);
  });

  /**
   * 测试所有扇形高亮后显示完成标记
   */
  test('所有扇形高亮后显示完成标记', async ({ page }) => {
    // 点击所有扇形
    for (let i = 0; i < 4; i++) {
      await highlightSegment(page, 'test-split-circle', i);
    }

    // 验证完成标记出现
    await waitForSplitComplete(page, 'test-split-circle');
  });

  /**
   * 测试分割圆标签显示（通过中心文字）
   */
  test('分割圆标签显示', async ({ page }) => {
    // 分割圆通过SVG中心文字显示分数
    const splitCircle = page.locator('[data-testid="test-split-circle"]');
    const textElement = splitCircle.locator('.split-circle-text');

    // 初始应该显示 0/4
    await expect(textElement).toContainText('0/4');

    // 点击一个扇形后应该显示 1/4
    const segment = page.locator('[data-testid="test-split-circle-segment-0"]');
    await segment.click();
    await expect(textElement).toContainText('1/4');
  });

  /**
   * 测试点击扇形后计数更新
   */
  test('点击扇形后计数更新', async ({ page }) => {
    const countElement = page.locator('[data-testid="split-highlight-count"]');

    // 初始计数为0
    await expect(countElement).toContainText('高亮数量: 0');

    // 点击一个扇形
    const segment = page.locator('[data-testid="test-split-circle-segment-0"]');
    await segment.click();

    // 计数应该更新为1
    await expect(countElement).toContainText('高亮数量: 1');
  });
});
