import { type Page, type Locator, expect } from '@playwright/test';

/**
 * 学习页面Page Object
 * @description 封装学习页面所有交互元素和操作方法
 */
export class LearnPage {
  readonly page: Page;

  // 页面级定位器
  readonly pageContainer: Locator;
  readonly completePageContainer: Locator;

  // 头部导航
  readonly backButton: Locator;
  readonly progressBar: Locator;
  readonly stepCounter: Locator;

  // 步骤定位器
  readonly currentStep: Locator;

  // 操作按钮
  readonly completeButton: Locator;
  readonly hintButton: Locator;

  // 反馈元素
  readonly successFeedback: Locator;
  readonly errorFeedback: Locator;
  readonly hintFeedback: Locator;

  // 可视化组件
  readonly splitCircleA: Locator;
  readonly splitCircleB: Locator;
  readonly fractionBarA: Locator;
  readonly fractionBarB: Locator;

  // 输入框
  readonly comparisonInput: Locator;

  // 完成页按钮
  readonly returnHomeButton: Locator;

  // 构造函数
  constructor(page: Page) {
    this.page = page;
    this.pageContainer = page.locator('[data-testid="page-learn"]');
    this.completePageContainer = page.locator('[data-testid="page-learn-complete"]');

    // 头部导航
    this.backButton = page.locator('[data-testid="btn-back"]');
    this.progressBar = page.locator('[data-testid="progress-bar"]');
    this.stepCounter = page.locator('.step-counter');

    // 操作按钮
    this.completeButton = page.locator('[data-testid="btn-complete"]');
    this.hintButton = page.locator('[data-testid="btn-hint"]');

    // 反馈元素
    this.successFeedback = page.locator('[data-testid="feedback-success"]');
    this.errorFeedback = page.locator('[data-testid="feedback-error"]');
    this.hintFeedback = page.locator('[data-testid="feedback-hint"]');

    // 可视化组件
    this.splitCircleA = page.locator('[data-testid="visual-split-circle-a"]');
    this.splitCircleB = page.locator('[data-testid="visual-split-circle-b"]');
    this.fractionBarA = page.locator('[data-testid="visual-fraction-bar-a"]');
    this.fractionBarB = page.locator('[data-testid="visual-fraction-bar-b"]');

    // 输入框
    this.comparisonInput = page.locator('[data-testid="input-comparison"]');

    // 完成页
    this.returnHomeButton = page.locator('[data-testid="page-learn-complete"] button');
  }

  /**
   * 访问指定能力的学习页面
   * @param abilityId 能力ID
   */
  async goto(abilityId: string): Promise<void> {
    await this.page.goto(`/learn/${abilityId}`);
  }

  /**
   * 等待学习页面加载完成
   */
  async waitForLoad(): Promise<void> {
    await expect(this.pageContainer).toBeVisible();
  }

  /**
   * 获取当前步骤定位器
   * @param stepType 步骤类型
   * @param index 步骤索引
   */
  getStepLocator(stepType: string, index: number): Locator {
    return this.page.locator(`[data-testid="step-${stepType}-${index}"]`);
  }

  /**
   * 获取分割圆扇形定位器
   * @param circleId 圆ID (如 'visual-split-circle-a')
   * @param segmentIndex 扇形索引
   */
  getSegmentLocator(circleId: string, segmentIndex: number): Locator {
    return this.page.locator(`[data-testid="${circleId}-segment-${segmentIndex}"]`);
  }

  /**
   * 点击完成按钮
   */
  async clickComplete(): Promise<void> {
    await this.completeButton.click();
  }

  /**
   * 点击提示按钮
   */
  async clickHint(): Promise<void> {
    await this.hintButton.click();
  }

  /**
   * 点击返回按钮
   */
  async clickBack(): Promise<void> {
    await this.backButton.click();
  }

  /**
   * 填写比较输入框
   * @param value 输入值
   */
  async fillComparisonInput(value: string): Promise<void> {
    await this.comparisonInput.fill(value);
  }

  /**
   * 获取进度条文本
   */
  async getProgressText(): Promise<string> {
    const progressText = this.page.locator('[data-testid="progress-bar-text"]');
    return progressText.textContent() ?? '';
  }

  /**
   * 验证成功反馈显示
   */
  async verifySuccessFeedback(): Promise<void> {
    await expect(this.successFeedback).toBeVisible();
  }

  /**
   * 验证错误反馈显示
   */
  async verifyErrorFeedback(): Promise<void> {
    await expect(this.errorFeedback).toBeVisible();
  }

  /**
   * 验证提示反馈显示
   */
  async verifyHintFeedback(): Promise<void> {
    await expect(this.hintFeedback).toBeVisible();
  }

  /**
   * 验证完成页面显示
   */
  async verifyCompletePage(): Promise<void> {
    await expect(this.completePageContainer).toBeVisible();
    await expect(this.successFeedback).toBeVisible();
  }

  /**
   * 点击扇形并验证高亮
   * @param circleId 圆ID
   * @param segmentIndex 扇形索引
   */
  async clickAndVerifySegment(circleId: string, segmentIndex: number): Promise<void> {
    const segment = this.getSegmentLocator(circleId, segmentIndex);
    await segment.click();
    await expect(segment).toHaveClass(/highlighted/);
  }

  /**
   * 返回首页
   */
  async returnToHome(): Promise<void> {
    await this.returnHomeButton.click();
  }
}

export default LearnPage;
