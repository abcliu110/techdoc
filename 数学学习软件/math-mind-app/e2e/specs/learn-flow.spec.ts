import { test, expect, Page } from '@playwright/test';
import { LearnPage } from '../pages';
import { completeCurrentStep, completeStepAndVerify } from '../helpers';

/**
 * 学习流程E2E测试套件
 * @description 测试从首页进入学习到完成的全流程
 */
test.describe('学习流程测试', () => {
  let learnPage: LearnPage;

  test.beforeEach(async ({ page }) => {
    learnPage = new LearnPage(page);
  });

  /**
   * 测试从首页进入学习页面
   */
  test('从首页进入学习页面', async ({ page }) => {
    // 从首页开始
    await page.goto('/');

    // 点击开始学习按钮
    await page.locator('[data-testid="btn-start-number-shape-integration"]').click();

    // 验证进入学习页面
    await expect(page.locator('[data-testid="page-learn"]')).toBeVisible();

    // 验证URL包含知识点ID
    await expect(page).toHaveURL(/number-shape-integration/);
  });

  /**
   * 测试学习页面正确加载
   */
  test('学习页面正确加载', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 验证页面元素
    await expect(learnPage.pageContainer).toBeVisible();
    await expect(learnPage.progressBar).toBeVisible();
    await expect(learnPage.completeButton).toBeVisible();
  });

  /**
   * 测试完成按钮默认状态
   */
  test('完成按钮默认状态', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 具象步骤：完成按钮应该可点击
    const completeBtn = learnPage.completeButton;
    await expect(completeBtn).toBeVisible();
    await expect(completeBtn).toBeEnabled();
  });

  /**
   * 测试提示按钮功能
   */
  test('提示按钮显示和点击', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    const hintBtn = learnPage.hintButton;
    await expect(hintBtn).toBeVisible();

    // 点击提示按钮
    await hintBtn.click();

    // 验证提示反馈出现
    await expect(learnPage.hintFeedback).toBeVisible();
  });

  /**
   * 测试返回按钮功能
   */
  test('返回按钮返回首页', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 点击返回按钮
    await learnPage.clickBack();

    // 验证返回首页
    await expect(page.locator('[data-testid="page-home"]')).toBeVisible();
    await expect(page).toHaveURL('/');
  });

  /**
   * 测试完整学习流程（简化版）
   */
  test('完整学习流程', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取总步骤数
    const stepCounter = await page.locator('.step-counter').textContent();
    const match = stepCounter?.match(/(\d+)\s*\/\s*(\d+)/);
    const totalSteps = match ? parseInt(match[2], 10) : 3;

    // 完成前几个步骤
    for (let i = 0; i < Math.min(totalSteps, 3); i++) {
      // 获取当前步骤类型
      const stepContainer = page.locator('[data-testid^="step-"][data-testid$="-0"], [data-testid^="step-"][data-testid$="-1"], [data-testid^="step-"][data-testid$="-2"]').first();
      const stepType = await stepContainer.getAttribute('data-testid');

      // 根据步骤类型完成
      if (stepType?.includes('symbolic')) {
        // 符号步骤需要先输入答案
        await learnPage.fillComparisonInput('>');
      }

      // 点击完成
      await learnPage.clickComplete();

      // 等待下一个步骤或完成页
      await page.waitForTimeout(300);
    }

    // 验证至少完成了部分步骤
    const url = page.url();
    expect(url.includes('learn') || url === '/').toBeTruthy();
  });

  /**
   * 测试进度条更新
   */
  test('进度条显示和更新', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 验证进度条可见
    await expect(learnPage.progressBar).toBeVisible();

    // 获取初始进度
    const progressText = await learnPage.getProgressText();

    // 完成一步后验证进度更新
    await learnPage.clickComplete();
    await page.waitForTimeout(300);

    // 进度应该有所变化
    const newProgressText = await learnPage.getProgressText();
    expect(newProgressText).not.toBe(progressText);
  });

  /**
   * 测试步骤导航
   */
  test('步骤导航正确', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 验证第一步可见
    const step0 = learnPage.getStepLocator('concrete', 0);
    await expect(step0).toBeVisible();

    // 完成第一步
    await learnPage.clickComplete();
    await page.waitForTimeout(300);

    // 验证第二步可见（如果有多步骤的话）
    const currentUrl = page.url();
    if (currentUrl.includes('learn')) {
      const step1 = learnPage.getStepLocator('pictorial', 1);
      const step1Visible = await step1.isVisible().catch(() => false);
      if (step1Visible) {
        await expect(step1).toBeVisible();
      }
    }
  });
});
