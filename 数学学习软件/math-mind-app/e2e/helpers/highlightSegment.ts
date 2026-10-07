import { type Page, type Locator, expect } from '@playwright/test';

/**
 * 高亮扇形辅助函数
 * @description 点击指定扇形并验证高亮效果
 * @param page Playwright Page对象
 * @param circleTestId 圆组件的data-testid
 * @param segmentIndex 扇形索引
 * @returns 扇形定位器
 */
export async function highlightSegment(
  page: Page,
  circleTestId: string,
  segmentIndex: number
): Promise<Locator> {
  const segment = page.locator(`[data-testid="${circleTestId}-segment-${segmentIndex}"]`);

  // 验证扇形存在
  await expect(segment).toBeVisible();

  // 点击扇形
  await segment.click();

  // 验证高亮样式
  await expect(segment).toHaveClass(/highlighted/);

  return segment;
}

/**
 * 高亮多个扇形
 * @param page Playwright Page对象
 * @param circleTestId 圆组件的data-testid
 * @param indices 扇形索引数组
 */
export async function highlightMultipleSegments(
  page: Page,
  circleTestId: string,
  indices: number[]
): Promise<void> {
  for (const index of indices) {
    await highlightSegment(page, circleTestId, index);
  }
}

/**
 * 取消高亮扇形
 * @param page Playwright Page对象
 * @param circleTestId 圆组件的data-testid
 * @param segmentIndex 扇形索引
 */
export async function unhighlightSegment(
  page: Page,
  circleTestId: string,
  segmentIndex: number
): Promise<void> {
  const segment = page.locator(`[data-testid="${circleTestId}-segment-${segmentIndex}"]`);

  // 验证扇形存在
  await expect(segment).toBeVisible();

  // 点击已高亮的扇形会取消高亮
  await segment.click();

  // 验证高亮样式被移除
  await expect(segment).not.toHaveClass(/highlighted/);
}

/**
 * 验证扇形高亮状态
 * @param page Playwright Page对象
 * @param circleTestId 圆组件的data-testid
 * @param segmentIndex 扇形索引
 * @param expectedHighlighted 期望的高亮状态
 */
export async function verifySegmentHighlight(
  page: Page,
  circleTestId: string,
  segmentIndex: number,
  expectedHighlighted: boolean
): Promise<void> {
  const segment = page.locator(`[data-testid="${circleTestId}-segment-${segmentIndex}"]`);
  await expect(segment).toBeVisible();

  if (expectedHighlighted) {
    await expect(segment).toHaveClass(/highlighted/);
  } else {
    await expect(segment).not.toHaveClass(/highlighted/);
  }
}

/**
 * 等待分割完成标记出现
 * @param page Playwright Page对象
 * @param circleTestId 圆组件的data-testid
 */
export async function waitForSplitComplete(
  page: Page,
  circleTestId: string
): Promise<void> {
  const completeMarker = page.locator(`[data-testid="${circleTestId}-complete"]`);
  await expect(completeMarker).toBeVisible({ timeout: 5000 });
}

export default highlightSegment;
