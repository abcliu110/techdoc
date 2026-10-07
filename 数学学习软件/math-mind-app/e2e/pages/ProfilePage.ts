import { type Page, type Locator, expect } from '@playwright/test';

/**
 * 能力画像页面Page Object
 * @description 封装能力画像页面所有交互元素和操作方法
 */
export class ProfilePage {
  readonly page: Page;

  // 页面级定位器
  readonly pageContainer: Locator;

  // 能力画像相关元素
  readonly radarChart: Locator;
  readonly abilityCards: Locator;
  readonly levelIndicators: Locator;

  // 操作按钮
  readonly backButton: Locator;

  // 构造函数
  constructor(page: Page) {
    this.page = page;
    this.pageContainer = page.locator('[data-testid="page-profile"]');
    this.radarChart = page.locator('[data-testid="radar-chart"]');
    this.abilityCards = page.locator('[data-testid^="card-ability-detail-"]');
    this.levelIndicators = page.locator('[data-testid^="card-ability-detail-"] .level-text');
    this.backButton = page.locator('[data-testid="btn-back"]');
  }

  /**
   * 访问能力画像页面
   */
  async goto(): Promise<void> {
    await this.page.goto('/profile');
  }

  /**
   * 等待页面加载完成
   */
  async waitForLoad(): Promise<void> {
    await expect(this.pageContainer).toBeVisible();
  }

  /**
   * 点击返回按钮
   */
  async clickBack(): Promise<void> {
    await this.backButton.click();
  }

  /**
   * 获取指定能力的状态卡片
   * @param abilityId 能力ID
   */
  getAbilityCard(abilityId: string): Locator {
    return this.page.locator(`[data-testid="card-ability-detail-${abilityId}"]`);
  }

  /**
   * 获取指定能力的等级指示器
   * @param abilityId 能力ID
   */
  getLevelIndicator(abilityId: string): Locator {
    return this.page.locator(`[data-testid="card-ability-detail-${abilityId}"] .level-text`);
  }

  /**
   * 验证能力卡片显示
   * @param abilityId 能力ID
   */
  async verifyAbilityCard(abilityId: string): Promise<void> {
    await expect(this.getAbilityCard(abilityId)).toBeVisible();
  }

  /**
   * 获取能力等级文本
   * @param abilityId 能力ID
   */
  async getAbilityLevel(abilityId: string): Promise<string> {
    const levelIndicator = this.getLevelIndicator(abilityId);
    return levelIndicator.textContent() ?? '';
  }
}

export default ProfilePage;
