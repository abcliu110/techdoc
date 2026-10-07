import { test, expect, Page } from '@playwright/test';

/**
 * "先完成任务"按钮修复验证测试
 *
 * 问题描述：按钮在初始状态下显示"先完成任务"但仍然可以点击
 * 预期行为：
 * 1. 初始状态：按钮显示"先完成任务"，按钮禁用（disabled）
 * 2. 用户点击扇形后：按钮显示"完成"，按钮启用（enabled）
 * 3. 点击完成按钮后：进入下一步
 */

/**
 * 辅助函数：根据目标高亮完成 split-circle 可视化
 *
 * DOM 结构：扇形按圆和索引顺序排列
 * - 圆0 (4等分): 全局索引 0, 1, 2, 3
 * - 圆1 (3等分): 全局索引 4, 5, 6
 *
 * 需要根据目标高亮点击正确的扇形：
 * - 圆0: highlighted=[0,1,2] -> 全局索引 [0, 1, 2]
 * - 圆1: highlighted=[0,1]   -> 全局索引 [4, 5]
 */
async function completeSplitCircleTask(page: Page) {
  // 根据学习内容 concrete.json 的目标高亮
  const circleConfig = [
    { denominator: 4, highlighted: [0, 1, 2] },
    { denominator: 3, highlighted: [0, 1] },
  ];

  const segments = page.locator('path');

  let globalOffset = 0;
  for (const circle of circleConfig) {
    // 点击该圆需要高亮的所有扇形
    for (const localIdx of circle.highlighted) {
      // 全局索引 = 该圆之前的累计扇形数 + 局部索引
      const globalIndex = globalOffset + localIdx;
      await segments.nth(globalIndex).click();
      await page.waitForTimeout(50);
    }
    // 累加该圆的分母数，作为下一个圆的偏移量
    globalOffset += circle.denominator;
  }
}

test.describe('"先完成任务"按钮修复验证', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('初始状态按钮应为禁用状态', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await page.waitForSelector('.step-actions', { state: 'visible' });

    // 找到主按钮
    const completeButton = page.locator('.step-actions .btn-primary');

    // 验证按钮显示"先完成任务"
    await expect(completeButton).toContainText('先完成任务');

    // 验证按钮处于禁用状态（这是关键修复点）
    await expect(completeButton).toBeDisabled();
  });

  test('点击正确扇形后按钮应变为启用状态', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await page.waitForSelector('.step-actions', { state: 'visible' });

    // 找到主按钮
    const completeButton = page.locator('.step-actions .btn-primary');

    // 验证初始状态
    await expect(completeButton).toBeDisabled();
    await expect(completeButton).toContainText('先完成任务');

    // 点击正确的扇形组合
    await completeSplitCircleTask(page);

    // 等待按钮状态变化（最多5秒）
    await expect(completeButton).toBeEnabled({ timeout: 5000 });

    // 验证按钮文本变为"完成"
    await expect(completeButton).toContainText('完成');
  });

  test('点击正确扇形后可以点击完成进入下一步', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await page.waitForSelector('.step-actions', { state: 'visible' });

    // 找到主按钮
    const completeButton = page.locator('.step-actions .btn-primary');

    // 验证初始状态
    await expect(completeButton).toBeDisabled();

    // 点击正确的扇形组合
    await completeSplitCircleTask(page);

    // 等待按钮变为启用
    await expect(completeButton).toBeEnabled({ timeout: 5000 });

    // 点击完成按钮
    await completeButton.click();

    // 等待步骤切换
    await page.waitForTimeout(500);

    // 验证进入下一步
    await expect(page.locator('.step-progress')).toContainText('2 /');
  });

  test('取消高亮后按钮应恢复禁用状态', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await page.waitForSelector('.step-actions', { state: 'visible' });

    // 找到主按钮
    const completeButton = page.locator('.step-actions .btn-primary');

    // 初始状态：按钮禁用
    await expect(completeButton).toBeDisabled();

    // 点击正确的扇形使按钮启用
    await completeSplitCircleTask(page);
    await expect(completeButton).toBeEnabled({ timeout: 5000 });

    // 再次点击第一个扇形取消高亮
    const segment = page.locator('path').first();
    await segment.click();

    // 等待按钮恢复禁用状态
    await expect(completeButton).toBeDisabled();
    await expect(completeButton).toContainText('先完成任务');
  });

  test('按钮禁用时点击不应触发任何操作', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await page.waitForSelector('.step-actions', { state: 'visible' });

    // 找到主按钮
    const completeButton = page.locator('.step-actions .btn-primary');

    // 验证按钮禁用
    await expect(completeButton).toBeDisabled();

    // 获取当前步骤
    const stepProgress = await page.locator('.step-progress').textContent();

    // 尝试点击禁用的按钮
    await completeButton.click({ force: true });

    // 等待一小段时间
    await page.waitForTimeout(300);

    // 验证步骤没有变化
    await expect(page.locator('.step-progress')).toContainText(stepProgress || '');
  });

  test('按钮启用后点击应正确处理完成逻辑', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await page.waitForSelector('.step-actions', { state: 'visible' });

    // 找到主按钮
    const completeButton = page.locator('.step-actions .btn-primary');

    // 点击正确的扇形使按钮启用
    await completeSplitCircleTask(page);
    await expect(completeButton).toBeEnabled({ timeout: 5000 });

    // 记录完成前的状态
    const beforeStep = await page.locator('.step-progress').textContent();

    // 点击完成按钮
    await completeButton.click();

    // 等待页面响应
    await page.waitForTimeout(500);

    // 验证步骤已经切换（不是停留在原步骤）
    const afterStep = await page.locator('.step-progress').textContent();
    expect(afterStep).not.toBe(beforeStep);
  });
});
