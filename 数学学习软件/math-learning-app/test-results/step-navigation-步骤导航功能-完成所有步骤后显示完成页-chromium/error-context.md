# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: step-navigation.spec.ts >> 步骤导航功能 >> 完成所有步骤后显示完成页
- Location: __tests__\e2e\step-navigation.spec.ts:224:3

# Error details

```
Error: page.goto: Target page, context or browser has been closed
```

# Test source

```ts
  58  |         await page.waitForTimeout(200);
  59  |       }
  60  |     }
  61  | 
  62  |     await page.waitForTimeout(100);
  63  |   }
  64  | 
  65  |   // 最后一次检查
  66  |   const isStillDisabled = await completeButton.isDisabled().catch(() => true);
  67  |   if (!isStillDisabled) {
  68  |     await completeButton.click({ force: true });
  69  |     await page.waitForTimeout(500);
  70  |     return true;
  71  |   }
  72  | 
  73  |   return false;
  74  | }
  75  | 
  76  | // 辅助函数：完成当前步骤（使用灵活尝试）
  77  | async function completeCurrentStepFlexible(page: Page) {
  78  |   await waitForStepLoaded(page);
  79  |   await tryCompleteStepFlexible(page);
  80  | }
  81  | 
  82  | // concrete.json 要求：圆0(denominator:4)高亮[0,1,2]，圆1(denominator:3)高亮[0,1]
  83  | async function completeSplitCircleTask(page: Page) {
  84  |   const circleConfig = [
  85  |     { denominator: 4, highlighted: [0, 1, 2] },
  86  |     { denominator: 3, highlighted: [0, 1] },
  87  |   ];
  88  | 
  89  |   const segments = page.locator('path');
  90  | 
  91  |   let globalOffset = 0;
  92  |   for (const circle of circleConfig) {
  93  |     for (const localIdx of circle.highlighted) {
  94  |       const globalIndex = globalOffset + localIdx;
  95  |       await segments.nth(globalIndex).click({ force: true });
  96  |       await page.waitForTimeout(50);
  97  |     }
  98  |     globalOffset += circle.denominator;
  99  |   }
  100 | }
  101 | 
  102 | /**
  103 |  * 辅助函数：完成当前步骤
  104 |  */
  105 | async function completeCurrentStep(page: Page) {
  106 |   // 等待步骤加载
  107 |   await waitForStepLoaded(page);
  108 | 
  109 |   // 检查按钮状态
  110 |   const completeButton = page.locator('.step-actions button.btn-primary');
  111 | 
  112 |   // 如果按钮已启用（任务已完成），直接点击完成
  113 |   if (await completeButton.isEnabled()) {
  114 |     await completeButton.click();
  115 |     await page.waitForTimeout(500);
  116 |     return;
  117 |   }
  118 | 
  119 |   // 按钮未启用，需要先完成任务
  120 |   // 先检查是否有可交互的扇形
  121 |   const hasSegments = await page.locator('.segment-interactive').first().isVisible({ timeout: 500 }).catch(() => false);
  122 | 
  123 |   if (hasSegments) {
  124 |     // 有扇形：完成 split-circle 任务
  125 |     await completeSplitCircleTask(page);
  126 |   } else {
  127 |     // 没有扇形：尝试其他步骤类型
  128 |     // pictorial 步骤：点击 fraction-bar-item
  129 |     const fractionBar = page.locator('.fraction-bar-item').first();
  130 |     if (await fractionBar.isVisible({ timeout: 500 }).catch(() => false)) {
  131 |       await fractionBar.click({ force: true });
  132 |       await page.waitForTimeout(200);
  133 |     }
  134 | 
  135 |     // symbolic 步骤：点击验证答案按钮
  136 |     const verifyButton = page.locator('button:has-text("验证答案")');
  137 |     if (await verifyButton.isVisible({ timeout: 500 }).catch(() => false)) {
  138 |       await verifyButton.click({ force: true });
  139 |       await page.waitForTimeout(200);
  140 |     }
  141 | 
  142 |     // 其他步骤：使用提示
  143 |     const hintButton = page.locator('button:has-text("提示")');
  144 |     if (await hintButton.isVisible({ timeout: 500 }).catch(() => false)) {
  145 |       await hintButton.click({ force: true });
  146 |       await page.waitForTimeout(200);
  147 |     }
  148 |   }
  149 | 
  150 |   // 等待完成按钮变为可用
  151 |   await expect(completeButton).toBeEnabled({ timeout: 5000 });
  152 | 
  153 |   // 点击完成按钮
  154 |   await completeButton.click();
  155 |   await page.waitForTimeout(500);
  156 | }
  157 | 
> 158 | test.describe('步骤导航功能', () => {
      |                ^ Error: page.goto: Target page, context or browser has been closed
  159 |   test.beforeEach(async ({ page }) => {
  160 |     await page.goto('/');
  161 |   });
  162 | 
  163 |   test('完成步骤后应切换到下一步', async ({ page }) => {
  164 |     // 进入学习页面
  165 |     await page.locator('.topic-card').first().click();
  166 |     await page.waitForURL(/\/learn\//);
  167 | 
  168 |     // 等待步骤1加载
  169 |     await waitForStepLoaded(page);
  170 | 
  171 |     // 验证显示步骤1进度
  172 |     await expect(page.locator('.step-progress')).toContainText('1 /');
  173 | 
  174 |     // 完成步骤1
  175 |     await completeCurrentStep(page);
  176 | 
  177 |     // 等待步骤切换
  178 |     await page.waitForTimeout(500);
  179 | 
  180 |     // 验证显示步骤2
  181 |     await expect(page.locator('.step-progress')).toContainText('2 /');
  182 |   });
  183 | 
  184 |   test('可以连续完成多个步骤', async ({ page }) => {
  185 |     // 进入学习页面
  186 |     await page.locator('.topic-card').first().click();
  187 |     await page.waitForURL(/\/learn\//);
  188 | 
  189 |     // 等待步骤1加载
  190 |     await waitForStepLoaded(page);
  191 | 
  192 |     // 完成步骤1
  193 |     await completeCurrentStep(page);
  194 |     await page.waitForTimeout(500);
  195 | 
  196 |     // 验证步骤2
  197 |     await expect(page.locator('.step-progress')).toContainText('2 /');
  198 | 
  199 |     // 完成步骤2
  200 |     await completeCurrentStep(page);
  201 |     await page.waitForTimeout(500);
  202 | 
  203 |     // 验证步骤3
  204 |     await expect(page.locator('.step-progress')).toContainText('3 /');
  205 |   });
  206 | 
  207 |   test('步骤进度显示正确', async ({ page }) => {
  208 |     // 进入学习页面
  209 |     await page.locator('.topic-card').first().click();
  210 |     await page.waitForURL(/\/learn\//);
  211 | 
  212 |     // 等待步骤加载
  213 |     await waitForStepLoaded(page);
  214 | 
  215 |     // 验证初始进度显示
  216 |     await expect(page.locator('.step-progress')).toContainText('1 /');
  217 | 
  218 |     // 完成步骤1
  219 |     await completeCurrentStep(page);
  220 |     await page.waitForTimeout(500);
  221 | 
  222 |     // 验证进度更新
  223 |     await expect(page.locator('.step-progress')).toContainText('2 /');
  224 |   });
  225 | 
  226 |   test('完成所有步骤后显示完成页', async ({ page }) => {
  227 |     // 进入学习页面
  228 |     await page.locator('.topic-card').first().click();
  229 |     await page.waitForURL(/\/learn\//);
  230 | 
  231 |     // 检查初始状态（可能没有步骤）
  232 |     const initialComplete = await page.locator('.learn-complete').isVisible().catch(() => false);
  233 |     if (initialComplete) {
  234 |       await expect(page.locator('.learn-complete')).toBeVisible();
  235 |       return;
  236 |     }
  237 | 
  238 |     // 等待步骤加载
  239 |     await expect(page.locator('.step')).toBeVisible({ timeout: 10000 });
  240 | 
  241 |     // 循环尝试完成步骤
  242 |     let maxIterations = 15;
  243 |     let stepCompleted = false;
  244 | 
  245 |     while (maxIterations > 0 && !stepCompleted) {
  246 |       maxIterations--;
  247 | 
  248 |       // 检查是否到达完成页
  249 |       const completePage = page.locator('.learn-complete');
  250 |       if (await completePage.isVisible({ timeout: 500 }).catch(() => false)) {
  251 |         stepCompleted = true;
  252 |         break;
  253 |       }
  254 | 
  255 |       // 检查是否有错误
  256 |       const errorPage = page.locator('.learn-error');
  257 |       if (await errorPage.isVisible({ timeout: 500 }).catch(() => false)) {
  258 |         throw new Error('学习页面出现错误');
```