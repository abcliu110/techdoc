import { type Page, type Locator, expect } from '@playwright/test';

/**
 * 首页Page Object
 * @description 封装首页所有交互元素和操作方法
 */
export class HomePage {
  readonly page: Page;

  // 页面级定位器
  readonly pageContainer: Locator;

  // 能力卡片定位器
  readonly abilityCards: Locator;

  // 能力卡片按钮定位器（缓存以提高性能）
  readonly startButtons: Map<string, Locator>;

  // 能力画像卡片
  readonly profileCard: Locator;
  readonly viewProfileButton: Locator;

  // 构造函数
  constructor(page: Page) {
    this.page = page;
    this.pageContainer = page.locator('[data-testid="page-home"]');
    this.abilityCards = page.locator('[data-testid^="card-ability-"]');
    this.profileCard = page.locator('[data-testid="card-view-profile"]');
    this.viewProfileButton = page.locator('[data-testid="btn-view-profile"]');

    // 初始化能力ID对应的开始按钮
    this.startButtons = new Map([
      ['number-shape-integration', page.locator('[data-testid="btn-start-number-shape-integration"]')],
      ['unit-unification', page.locator('[data-testid="btn-start-unit-unification"]')],
      ['whole-part', page.locator('[data-testid="btn-start-whole-part"]')],
      ['transformation', page.locator('[data-testid="btn-start-transformation"]')],
      ['equation-balance', page.locator('[data-testid="btn-start-equation-balance"]')],
    ]);
  }

  /**
   * 访问首页
   */
  async goto(): Promise<void> {
    await this.page.goto('/');
  }

  /**
   * 等待首页加载完成
   */
  async waitForLoad(): Promise<void> {
    await expect(this.pageContainer).toBeVisible();
  }

  /**
   * 点击指定能力的学习开始按钮
   * @param abilityId 能力ID
   */
  async clickStartButton(abilityId: string): Promise<void> {
    const button = this.startButtons.get(abilityId);
    if (!button) {
      throw new Error(`Unknown ability ID: ${abilityId}`);
    }
    await button.click();
  }

  /**
   * 获取指定能力卡片
   * @param abilityId 能力ID
   */
  getAbilityCard(abilityId: string): Locator {
    return this.page.locator(`[data-testid="card-ability-${abilityId}"]`);
  }

  /**
   * 验证所有能力卡片都显示
   */
  async verifyAllAbilityCards(): Promise<void> {
    const expectedAbilities = [
      'number-shape-integration',
      'unit-unification',
      'whole-part',
      'transformation',
      'equation-balance',
    ];

    for (const abilityId of expectedAbilities) {
      await expect(this.getAbilityCard(abilityId)).toBeVisible();
    }
  }

  /**
   * 点击能力卡片进入学习页面
   * @param abilityId 能力ID
   */
  async clickAbilityCard(abilityId: string): Promise<void> {
    await this.getAbilityCard(abilityId).click();
  }

  /**
   * 访问能力画像页面
   */
  async goToProfile(): Promise<void> {
    await this.viewProfileButton.click();
  }
}

export default HomePage;
