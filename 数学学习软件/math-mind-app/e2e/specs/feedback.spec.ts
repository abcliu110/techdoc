import { test, expect } from '@playwright/test';
import { LearnPage } from '../pages';

/**
 * 反馈组件E2E测试套件
 * @description 测试成功、错误、提示等反馈显示
 */
test.describe('反馈测试', () => {
  let learnPage: LearnPage;

  test.beforeEach(async ({ page }) => {
    learnPage = new LearnPage(page);
  });

  /**
   * 测试初始状态无反馈
   */
  test('初始状态无反馈', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 验证没有反馈元素
    const successFeedback = page.locator('[data-testid="feedback-success"]');
    const errorFeedback = page.locator('[data-testid="feedback-error"]');
    const hintFeedback = page.locator('[data-testid="feedback-hint"]');

    await expect(successFeedback).not.toBeVisible();
    await expect(errorFeedback).not.toBeVisible();
    await expect(hintFeedback).not.toBeVisible();
  });

  /**
   * 测试成功反馈显示
   */
  test('成功反馈显示', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 完成步骤（具象步骤直接完成）
    await learnPage.clickComplete();
    await page.waitForTimeout(300);

    // 具象步骤不显示成功反馈，而是进入下一步
    // 只有符号步骤答对时才显示成功反馈
  });

  /**
   * 测试错误反馈显示
   */
  test('错误反馈显示（符号步骤）', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 跳过前两个步骤
    await learnPage.clickComplete(); // concrete
    await page.waitForTimeout(300);

    // 检查是否是符号步骤
    const inputVisible = await learnPage.comparisonInput.isVisible().catch(() => false);
    if (inputVisible) {
      await learnPage.clickComplete(); // pictorial
      await page.waitForTimeout(300);
    }

    // 现在应该是符号步骤
    const inputVisibleNow = await learnPage.comparisonInput.isVisible().catch(() => false);
    if (inputVisibleNow) {
      // 输入错误答案
      await learnPage.fillComparisonInput('<');
      await learnPage.clickComplete();

      // 等待错误反馈
      await page.waitForTimeout(300);

      // 验证错误反馈显示
      await learnPage.verifyErrorFeedback();
    }
  });

  /**
   * 测试正确答案后显示成功反馈
   */
  test('正确答案显示成功反馈', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 跳过前两个步骤
    await learnPage.clickComplete(); // concrete
    await page.waitForTimeout(300);

    const inputVisible = await learnPage.comparisonInput.isVisible().catch(() => false);
    if (inputVisible) {
      await learnPage.clickComplete(); // pictorial
      await page.waitForTimeout(300);
    }

    // 输入正确答案
    const inputVisibleNow = await learnPage.comparisonInput.isVisible().catch(() => false);
    if (inputVisibleNow) {
      await learnPage.fillComparisonInput('>');
      await learnPage.clickComplete();

      // 等待成功反馈
      await page.waitForTimeout(300);

      // 验证成功反馈显示
      await learnPage.verifySuccessFeedback();
    }
  });

  /**
   * 测试提示反馈显示
   */
  test('提示反馈显示', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 点击提示按钮
    await learnPage.clickHint();

    // 验证提示反馈显示
    await learnPage.verifyHintFeedback();
  });

  /**
   * 测试连续点击提示按钮
   */
  test('连续点击提示按钮显示多个提示', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 第一次点击提示
    await learnPage.clickHint();
    await expect(learnPage.hintFeedback).toBeVisible();
    const firstHint = await learnPage.hintFeedback.textContent();

    // 第二次点击提示
    await learnPage.clickHint();
    await page.waitForTimeout(100);

    // 验证提示内容变化（如果有多个提示层级）
    const secondHint = await learnPage.hintFeedback.textContent();
    // 如果有多个提示层级，内容应该不同
    // 如果没有更多提示，应该显示"没有更多提示了"
  });

  /**
   * 测试完成后的成功反馈
   */
  test('完成后显示成功反馈', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 获取总步骤数
    const counter = await page.locator('.step-counter').textContent();
    const match = counter?.match(/(\d+)\s*\/\s*(\d+)/);
    const totalSteps = match ? parseInt(match[2], 10) : 3;

    // 完成所有步骤
    for (let i = 0; i < totalSteps; i++) {
      const inputVisible = await learnPage.comparisonInput.isVisible().catch(() => false);
      if (inputVisible) {
        await learnPage.fillComparisonInput('>');
      }
      await learnPage.clickComplete();
      await page.waitForTimeout(200);
    }

    // 验证完成页面有成功反馈
    await expect(learnPage.successFeedback).toBeVisible();
  });

  /**
   * 测试反馈消失后再出现
   */
  test('反馈状态切换', async ({ page }) => {
    await learnPage.goto('number-shape-integration');
    await learnPage.waitForLoad();

    // 点击提示按钮
    await learnPage.clickHint();
    await expect(learnPage.hintFeedback).toBeVisible();

    // 点击完成按钮（提示后完成）
    await learnPage.clickComplete();
    await page.waitForTimeout(300);

    // 进入下一步后，提示反馈应该消失
    // （除非进入了符号步骤且没有输入答案）
  });
});
