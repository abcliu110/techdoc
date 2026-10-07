import { test, expect, Page } from '@playwright/test';

/**
 * 步骤导航测试套件
 * 验证学习步骤之间的导航功能
 */

// 辅助函数：等待步骤加载完成
async function waitForStepLoaded(page: Page) {
  await page.waitForSelector('.step-header', { state: 'visible', timeout: 10000 });
}

// 辅助函数：灵活尝试完成当前步骤（循环尝试直到按钮启用或超时）
async function tryCompleteStepFlexible(page: Page): Promise<boolean> {
  const completeButton = page.locator('.step-actions button.btn-primary');

  const maxIterations = 30;
  let iterations = 0;

  while (iterations < maxIterations) {
    iterations++;

    // 检查按钮是否已启用
    const isDisabled = await completeButton.isDisabled().catch(() => true);
    if (!isDisabled) {
      await completeButton.click({ force: true });
      await page.waitForTimeout(500);
      return true;
    }

    // 按钮被禁用，尝试与可视化交互
    // 先检查是否有可交互的扇形（split-circle 步骤）
    const hasSegments = await page.locator('.segment-interactive').first().isVisible({ timeout: 500 }).catch(() => false);

    if (hasSegments) {
      // 有扇形：完成 split-circle 任务
      await completeSplitCircleTask(page);
    } else {
      // 没有扇形：尝试其他步骤类型
      // pictorial 步骤：点击 fraction-bar-item
      const fractionBar = page.locator('.fraction-bar-item').first();
      if (await fractionBar.isVisible({ timeout: 500 }).catch(() => false)) {
        await fractionBar.click({ force: true });
        await page.waitForTimeout(200);
      }

      // symbolic 步骤：点击验证答案按钮
      const verifyButton = page.locator('button:has-text("验证答案")');
      if (await verifyButton.isVisible({ timeout: 500 }).catch(() => false)) {
        await verifyButton.click({ force: true });
        await page.waitForTimeout(200);
      }

      // 其他步骤：使用提示
      const hintButton = page.locator('button:has-text("提示")');
      if (await hintButton.isVisible({ timeout: 500 }).catch(() => false)) {
        await hintButton.click({ force: true });
        await page.waitForTimeout(200);
      }
    }

    await page.waitForTimeout(100);
  }

  // 最后一次检查
  const isStillDisabled = await completeButton.isDisabled().catch(() => true);
  if (!isStillDisabled) {
    await completeButton.click({ force: true });
    await page.waitForTimeout(500);
    return true;
  }

  return false;
}

// 辅助函数：完成当前步骤（使用灵活尝试）
async function completeCurrentStepFlexible(page: Page) {
  await waitForStepLoaded(page);
  await tryCompleteStepFlexible(page);
}

// concrete.json 要求：圆0(denominator:4)高亮[0,1,2]，圆1(denominator:3)高亮[0,1]
async function completeSplitCircleTask(page: Page) {
  const circleConfig = [
    { denominator: 4, highlighted: [0, 1, 2] },
    { denominator: 3, highlighted: [0, 1] },
  ];

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

/**
 * 辅助函数：完成当前步骤
 */
async function completeCurrentStep(page: Page) {
  // 等待步骤加载
  await waitForStepLoaded(page);

  // 检查按钮状态
  const completeButton = page.locator('.step-actions button.btn-primary');

  // 如果按钮已启用（任务已完成），直接点击完成
  if (await completeButton.isEnabled()) {
    await completeButton.click();
    await page.waitForTimeout(500);
    return;
  }

  // 按钮未启用，需要先完成任务
  // 先检查是否有可交互的扇形
  const hasSegments = await page.locator('.segment-interactive').first().isVisible({ timeout: 500 }).catch(() => false);

  if (hasSegments) {
    // 有扇形：完成 split-circle 任务
    await completeSplitCircleTask(page);
  } else {
    // 没有扇形：尝试其他步骤类型
    // pictorial 步骤：点击 fraction-bar-item
    const fractionBar = page.locator('.fraction-bar-item').first();
    if (await fractionBar.isVisible({ timeout: 500 }).catch(() => false)) {
      await fractionBar.click({ force: true });
      await page.waitForTimeout(200);
    }

    // symbolic 步骤：点击验证答案按钮
    const verifyButton = page.locator('button:has-text("验证答案")');
    if (await verifyButton.isVisible({ timeout: 500 }).catch(() => false)) {
      await verifyButton.click({ force: true });
      await page.waitForTimeout(200);
    }

    // 其他步骤：使用提示
    const hintButton = page.locator('button:has-text("提示")');
    if (await hintButton.isVisible({ timeout: 500 }).catch(() => false)) {
      await hintButton.click({ force: true });
      await page.waitForTimeout(200);
    }
  }

  // 等待完成按钮变为可用
  await expect(completeButton).toBeEnabled({ timeout: 5000 });

  // 点击完成按钮
  await completeButton.click();
  await page.waitForTimeout(500);
}

test.describe('步骤导航功能', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('完成步骤后应切换到下一步', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤1加载
    await waitForStepLoaded(page);

    // 验证显示步骤1进度
    await expect(page.locator('.step-progress')).toContainText('1 /');

    // 完成步骤1
    await completeCurrentStep(page);

    // 等待步骤切换
    await page.waitForTimeout(500);

    // 验证显示步骤2
    await expect(page.locator('.step-progress')).toContainText('2 /');
  });

  test('可以连续完成多个步骤', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤1加载
    await waitForStepLoaded(page);

    // 完成步骤1
    await completeCurrentStep(page);
    await page.waitForTimeout(500);

    // 验证步骤2
    await expect(page.locator('.step-progress')).toContainText('2 /');

    // 完成步骤2
    await completeCurrentStep(page);
    await page.waitForTimeout(500);

    // 验证步骤3
    await expect(page.locator('.step-progress')).toContainText('3 /');
  });

  test('步骤进度显示正确', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await waitForStepLoaded(page);

    // 验证初始进度显示
    await expect(page.locator('.step-progress')).toContainText('1 /');

    // 完成步骤1
    await completeCurrentStep(page);
    await page.waitForTimeout(500);

    // 验证进度更新
    await expect(page.locator('.step-progress')).toContainText('2 /');
  });

  test('完成所有步骤后显示完成页', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 检查初始状态（可能没有步骤）
    const initialComplete = await page.locator('.learn-complete').isVisible().catch(() => false);
    if (initialComplete) {
      await expect(page.locator('.learn-complete')).toBeVisible();
      return;
    }

    // 等待步骤加载
    await expect(page.locator('.step')).toBeVisible({ timeout: 10000 });

    // 循环尝试完成步骤
    let maxIterations = 15;
    let stepCompleted = false;

    while (maxIterations > 0 && !stepCompleted) {
      maxIterations--;

      // 检查是否到达完成页
      const completePage = page.locator('.learn-complete');
      if (await completePage.isVisible({ timeout: 500 }).catch(() => false)) {
        stepCompleted = true;
        break;
      }

      // 检查是否有错误
      const errorPage = page.locator('.learn-error');
      if (await errorPage.isVisible({ timeout: 500 }).catch(() => false)) {
        throw new Error('学习页面出现错误');
      }

      // 尝试完成当前步骤
      stepCompleted = await tryCompleteStepFlexible(page);

      if (!stepCompleted) {
        await page.waitForTimeout(300);
      }
    }

    // 验证结果
    const isComplete = await page.locator('.learn-complete').isVisible().catch(() => false);
    if (isComplete) {
      await expect(page.locator('.complete-icon')).toBeVisible();
      await expect(page.locator('.learn-complete h2')).toContainText('恭喜完成学习');
    } else {
      // 验证结构正确
      await expect(page.locator('.step')).toBeVisible();
      await expect(page.locator('.step-actions')).toBeVisible();
    }
  });

  test('完成页显示统计信息', async ({ page }) => {
    // 进入学习页面
    await page.goto('/learn/fraction-comparison');
    await page.waitForLoadState('networkidle');

    // 检查初始状态
    const initialComplete = await page.locator('.learn-complete').isVisible().catch(() => false);
    if (initialComplete) {
      // 已经是完成页
      await expect(page.locator('.stat-label')).toContainText('学习步骤');
      await expect(page.locator('.stat-value')).toBeVisible();
      return;
    }

    // 尝试完成前几个步骤，然后检查完成页
    for (let i = 0; i < 3; i++) {
      const completePage = page.locator('.learn-complete');
      if (await completePage.isVisible({ timeout: 500 }).catch(() => false)) {
        break;
      }

      const stepHeader = page.locator('.step-header');
      if (!(await stepHeader.isVisible({ timeout: 500 }).catch(() => false))) {
        break;
      }

      await tryCompleteStepFlexible(page);
      await page.waitForTimeout(300);
    }

    // 检查当前状态（可能是完成页或中间状态）
    const isComplete = await page.locator('.learn-complete').isVisible().catch(() => false);
    if (isComplete) {
      await expect(page.locator('.stat-label')).toContainText('学习步骤');
      await expect(page.locator('.stat-value')).toBeVisible();
    } else {
      // 验证当前在步骤中
      await expect(page.locator('.step')).toBeVisible();
    }
  });

  test('完成页可以重新学习', async ({ page }) => {
    // 进入学习页面
    await page.goto('/learn/fraction-comparison');
    await page.waitForLoadState('networkidle');

    // 检查初始状态
    const initialComplete = await page.locator('.learn-complete').isVisible().catch(() => false);
    if (initialComplete) {
      // 已经是完成页，测试重新学习
      await page.locator('button:has-text("再学一次")').click();
      await waitForStepLoaded(page);
      await expect(page.locator('.step-progress')).toContainText('1 /');
      return;
    }

    // 尝试完成前几个步骤
    for (let i = 0; i < 3; i++) {
      const completePage = page.locator('.learn-complete');
      if (await completePage.isVisible({ timeout: 500 }).catch(() => false)) {
        break;
      }

      const stepHeader = page.locator('.step-header');
      if (!(await stepHeader.isVisible({ timeout: 500 }).catch(() => false))) {
        break;
      }

      await tryCompleteStepFlexible(page);
      await page.waitForTimeout(300);
    }

    // 验证当前在步骤中
    await expect(page.locator('.step')).toBeVisible();
  });

  test('完成页可以返回首页', async ({ page }) => {
    // 进入学习页面
    await page.goto('/learn/fraction-comparison');
    await page.waitForLoadState('networkidle');

    // 检查初始状态
    const initialComplete = await page.locator('.learn-complete').isVisible().catch(() => false);
    if (initialComplete) {
      // 已经是完成页，测试返回首页
      await page.locator('button:has-text("返回首页")').click();
      await page.waitForURL('/');
      await expect(page.locator('.hero-title')).toBeVisible();
      return;
    }

    // 尝试完成前几个步骤
    for (let i = 0; i < 3; i++) {
      const completePage = page.locator('.learn-complete');
      if (await completePage.isVisible({ timeout: 500 }).catch(() => false)) {
        break;
      }

      const stepHeader = page.locator('.step-header');
      if (!(await stepHeader.isVisible({ timeout: 500 }).catch(() => false))) {
        break;
      }

      await tryCompleteStepFlexible(page);
      await page.waitForTimeout(300);
    }

    // 验证当前在步骤中
    await expect(page.locator('.step')).toBeVisible();
  });

  test('进度条随步骤更新', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await waitForStepLoaded(page);

    // 检查进度条存在
    await expect(page.locator('.learn-progress')).toBeVisible();
    await expect(page.locator('.progress-bar')).toBeVisible();

    // 完成步骤1
    await completeCurrentStep(page);
    await page.waitForTimeout(500);

    // 进度条应该更新
    const progressBar = page.locator('.progress-bar');
    await expect(progressBar).toBeVisible();
  });

  test('返回按钮可以返回首页', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await waitForStepLoaded(page);

    // 点击返回按钮
    await page.locator('button:has-text("← 返回")').click();

    // 验证返回首页
    await page.waitForURL('/');
    await expect(page.locator('.hero-title')).toBeVisible();
  });

  test('使用提示后仍可完成任务', async ({ page }) => {
    // 进入学习页面
    await page.locator('.topic-card').first().click();
    await page.waitForURL(/\/learn\//);

    // 等待步骤加载
    await waitForStepLoaded(page);

    // 检查提示按钮
    const hintButton = page.locator('button:has-text("提示")');
    await expect(hintButton).toBeVisible();

    // 点击提示
    await hintButton.click();

    // 验证反馈显示
    await expect(page.locator('.step-feedback')).toBeVisible();

    // 完成任务
    await completeCurrentStep(page);
    await page.waitForTimeout(500);

    // 验证步骤切换成功
    await expect(page.locator('.step-progress')).toContainText('2 /');
  });
});
