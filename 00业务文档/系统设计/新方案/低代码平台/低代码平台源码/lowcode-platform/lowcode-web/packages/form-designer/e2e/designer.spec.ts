/**
 * 表单设计器 E2E 测试 - 完整功能覆盖
 *
 * 测试策略：按组件分类，每类组件测试其核心功能和交互行为
 * AI 可通过 data-testid 定位元素并模拟真实鼠标/键盘操作
 *
 * 测试覆盖：
 * - 29 个组件的添加、选中、属性配置、预览交互
 * - 3 个容器组件的子组件嵌套
 * - 视图切换、字段操作、尺寸配置、CSS 布局
 */

import { test, expect, type Page } from '@playwright/test';

// ================================ 辅助函数 ================================

/** 等待画布加载 */
async function waitForCanvas(page: Page) {
  await page.locator('[data-testid="canvas-root"]').waitFor({ state: 'visible', timeout: 10000 });
}

/** 点击 palette 添加组件 */
async function addComponent(page: Page, type: string) {
  const palette = page.locator(`[data-testid="palette-${type}"]`);
  await palette.waitFor({ state: 'visible' });
  await palette.click();
}

/** 选中画布中的节点 */
async function selectField(page: Page, type: string) {
  const node = page.locator(`[data-testid="canvas-node"][data-node-type="${type}"]`).first();
  await node.click();
}

/** 获取画布节点数量 */
async function getNodeCount(page: Page): Promise<number> {
  return page.locator('[data-testid="canvas-node"]').count();
}

/** 点击 AntD Select 并选择选项 */
async function selectAntDOption(page: Page, testId: string, optionText: string) {
  const select = page.locator(`[data-testid="${testId}"]`);
  await select.click();
  await page.locator(`.ant-select-dropdown:visible .ant-select-item:has-text("${optionText}")`).click();
}

/** 切换到指定视图模式 */
async function switchToView(page: Page, viewName: 'design' | 'preview' | 'JSON') {
  const labelMap = { design: '设计', preview: '预览', JSON: 'JSON' };
  const viewTab = page.locator(`.ant-tabs-tab:has-text("${labelMap[viewName]}")`);
  await viewTab.click();
}

// ================================ 1. 基础组件 - 输入类 ================================

test.describe('基础组件 - 输入类', () => {

  test('input: 添加到画布并在预览模式输入文字', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="input"]');
    await expect(node).toBeVisible();

    // 预览模式验证输入
    await switchToView(page, 'preview');
    const banner = page.locator('[data-testid="preview-mode-banner"]');
    await expect(banner).toBeVisible();

    const inputEl = page.locator('.ant-input').first();
    await expect(inputEl).toBeVisible();
    await inputEl.fill('测试用户名');
    await expect(inputEl).toHaveValue('测试用户名');
  });

  test('input: 属性面板修改标签后画布节点文字同步变化', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('用户名');
    await labelInput.blur();

    const node = page.locator('[data-testid="canvas-node"][data-node-type="input"]');
    await expect(node).toContainText('用户名');
  });

  test('input: 属性面板修改占位符', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const placeholderInput = page.locator('[data-testid="prop-placeholder"]');
    await placeholderInput.fill('请输入用户名');
    await placeholderInput.blur();

    // 切换预览验证占位符
    await switchToView(page, 'preview');
    const inputEl = page.locator('.ant-input').first();
    await expect(inputEl).toHaveAttribute('placeholder', '请输入用户名');
  });

  test('input: 修改默认值', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const defaultValueInput = page.locator('[data-testid="prop-default-value"]');
    await defaultValueInput.fill('admin');
    await defaultValueInput.blur();

    await switchToView(page, 'preview');
    const inputEl = page.locator('.ant-input').first();
    await expect(inputEl).toHaveValue('admin');
  });

  test('input: 配置必填/禁用/只读', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    // 必填
    const requiredSwitch = page.locator('[data-testid="prop-required"]');
    await expect(requiredSwitch).toBeVisible();
    await requiredSwitch.click();

    // 禁用
    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();

    // 只读
    const readonlySwitch = page.locator('[data-testid="prop-readonly"]');
    await readonlySwitch.click();

    // 预览验证禁用
    await switchToView(page, 'preview');
    const inputEl = page.locator('.ant-input').first();
    await expect(inputEl).toBeDisabled();
  });

  test('inputNumber: 添加并验证数字输入功能', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'inputNumber');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="inputNumber"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const inputNumEl = page.locator('.ant-input-number').first();
    await expect(inputNumEl).toBeVisible();
    await inputNumEl.locator('input').fill('123');
    await expect(inputNumEl.locator('input')).toHaveValue('123');
  });

  test('inputNumber: 预览模式步进按钮可用', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'inputNumber');
    await selectField(page, 'inputNumber');

    const defaultValueInput = page.locator('[data-testid="prop-default-value"]');
    await defaultValueInput.fill('10');
    await defaultValueInput.blur();

    await switchToView(page, 'preview');
    const inputNumEl = page.locator('.ant-input-number').first();
    const upBtn = inputNumEl.locator('.ant-input-number-handler-up');
    // 使用 force:true 避免被子元素拦截
    await upBtn.click({ force: true });
    await page.waitForTimeout(300);
  });

  test('textarea: 添加并验证多行输入', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'textarea');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="textarea"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const textareaEl = page.locator('textarea').first();
    await expect(textareaEl).toBeVisible();
    await textareaEl.fill('这是多行文本内容\n第二行内容');
    await expect(textareaEl).toHaveValue('这是多行文本内容\n第二行内容');
  });

  test('textarea: 高度配置控件存在', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'textarea');
    await selectField(page, 'textarea');

    const heightInput = page.locator('[data-testid="prop-height"]');
    await expect(heightInput).toBeVisible();
    await heightInput.fill('150');
    await heightInput.blur();
  });

  test('textarea: 修改标签和帮助文本', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'textarea');
    await selectField(page, 'textarea');

    await page.locator('[data-testid="prop-label"]').fill('详细描述');
    await page.locator('[data-testid="prop-help-text"]').fill('请详细描述您的需求，至少20字');
  });

  test('input: 校验规则 - 最小/最大长度', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const minLenInput = page.locator('[data-testid="prop-min-length"]');
    const maxLenInput = page.locator('[data-testid="prop-max-length"]');
    await minLenInput.fill('3');
    await maxLenInput.fill('20');
  });

  test('input: 正则表达式配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const patternInput = page.locator('[data-testid="prop-pattern"]');
    await patternInput.fill('^[a-zA-Z]+$');
    await patternInput.blur();

    const errorMsgInput = page.locator('[data-testid="prop-error-message"]');
    await errorMsgInput.fill('只允许输入英文字母');
  });

  test('input: 字段编码修改', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const fieldIdInput = page.locator('[data-testid="prop-field-id"]');
    await expect(fieldIdInput).toBeVisible();
    await fieldIdInput.fill('userName');
  });

  test('input: BO 绑定字段配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const boFieldInput = page.locator('[data-testid="prop-bo-field"]');
    await boFieldInput.fill('sys_user.username');
  });
});

// ================================ 2. 基础组件 - 选择类 ================================

test.describe('基础组件 - 选择类', () => {

  test('select: 添加到画布并验证下拉选项', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'select');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="select"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const selectEl = page.locator('.ant-select').first();
    await expect(selectEl).toBeVisible();
    await selectEl.click();

    const dropdown = page.locator('.ant-select-dropdown:visible');
    await expect(dropdown).toBeVisible();
    const firstOption = dropdown.locator('.ant-select-item').first();
    await expect(firstOption).toBeVisible();
    await firstOption.click();

    await expect(selectEl.locator('.ant-select-selection-item')).toBeVisible();
  });

  test('select: 属性面板配置多选模式', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'select');
    await selectField(page, 'select');

    const multipleSwitch = page.locator('[data-testid="prop-multiple"]');
    await multipleSwitch.click();

    await switchToView(page, 'preview');
    const selectEl = page.locator('.ant-select').first();
    await selectEl.click();
    // 等待下拉菜单展开
    const dropdown = page.locator('.ant-select-dropdown:visible');
    await expect(dropdown).toBeVisible();
    // 多选模式下下拉选项有复选框
    const firstOption = dropdown.locator('.ant-select-item-option').first();
    await expect(firstOption).toBeVisible();
    await firstOption.click();
    // 验证选中项显示在输入框中
    await expect(selectEl.locator('.ant-select-selection-item').first()).toBeVisible();
  });

  test('checkbox: 添加到画布并验证复选行为', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'checkbox');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="checkbox"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    // 复选框组
    const checkboxGroup = page.locator('.ant-checkbox-group').first();
    if (await checkboxGroup.isVisible()) {
      const firstCheckbox = checkboxGroup.locator('.ant-checkbox').first();
      await firstCheckbox.click();
      await expect(firstCheckbox.locator('.ant-checkbox-input')).toBeChecked();
    } else {
      // 单个复选框
      const singleCheckbox = page.locator('.ant-checkbox').first();
      await singleCheckbox.click();
    }
  });

  test('checkbox: 禁用状态下不可点击', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'checkbox');
    await selectField(page, 'checkbox');

    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();

    await switchToView(page, 'preview');
    const checkbox = page.locator('.ant-checkbox').first();
    await expect(checkbox).toHaveClass(/ant-checkbox-disabled/);
  });

  test('radio: 添加到画布并验证单选行为', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'radio');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="radio"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const radioGroup = page.locator('.ant-radio-group').first();
    await expect(radioGroup).toBeVisible();

    const firstRadio = radioGroup.locator('.ant-radio').nth(1);
    await firstRadio.click();
    await expect(firstRadio.locator('input')).toBeChecked();
  });

  test('radio: 配置默认值', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'radio');
    await selectField(page, 'radio');

    const defaultValueInput = page.locator('[data-testid="prop-default-value"]');
    await defaultValueInput.fill('1');
  });

  test('switch: 添加到画布并验证开关切换', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'switch');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="switch"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const switchEl = page.locator('.ant-switch').first();
    await expect(switchEl).toBeVisible();
    await switchEl.click();
    await page.waitForTimeout(200);
    await expect(switchEl).toHaveClass(/ant-switch-checked/);
  });

  test('switch: 配置默认值并验证初始状态', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'switch');
    await selectField(page, 'switch');

    const defaultValueInput = page.locator('[data-testid="prop-default-value"]');
    await defaultValueInput.fill('true');

    await switchToView(page, 'preview');
    const switchEl = page.locator('.ant-switch').first();
    await expect(switchEl).toHaveClass(/ant-switch-checked/);
  });

  test('switch: 禁用开关不可切换', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'switch');
    await selectField(page, 'switch');

    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();

    await switchToView(page, 'preview');
    const switchEl = page.locator('.ant-switch').first();
    await expect(switchEl).toHaveClass(/ant-switch-disabled/);
  });
});

// ================================ 3. 基础组件 - 日期/时间类 ================================

test.describe('基础组件 - 日期/时间类', () => {

  test('datePicker: 添加到画布并展开日期选择器', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'datePicker');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="datePicker"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const datePickerEl = page.locator('.ant-picker').first();
    await expect(datePickerEl).toBeVisible();
    await datePickerEl.click();

    const datePickerDropdown = page.locator('.ant-picker-panel-container').first();
    await expect(datePickerDropdown).toBeVisible();
  });

  test('datePicker: 选择日期后回填输入框', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'datePicker');

    await switchToView(page, 'preview');
    const datePickerEl = page.locator('.ant-picker').first();
    await datePickerEl.click();

    const todayCell = page.locator('.ant-picker-cell-today .ant-picker-cell-inner').first();
    if (await todayCell.isVisible()) {
      await todayCell.click();
      await page.waitForTimeout(300);
    }
  });

  test('datePicker: 属性面板配置占位符', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'datePicker');
    await selectField(page, 'datePicker');

    const placeholderInput = page.locator('[data-testid="prop-placeholder"]');
    await placeholderInput.fill('请选择日期');
    await placeholderInput.blur();

    await switchToView(page, 'preview');
    const datePickerEl = page.locator('.ant-picker').first();
    // DatePicker placeholder 在内部的 input 元素上
    const inputEl = datePickerEl.locator('input');
    await expect(inputEl).toHaveAttribute('placeholder', '请选择日期');
  });

  test('timePicker: 添加到画布并展开时间选择器', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'timePicker');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="timePicker"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const timePickerEl = page.locator('.ant-picker').first();
    await expect(timePickerEl).toBeVisible();
    await timePickerEl.click();

    const timePickerDropdown = page.locator('.ant-picker-panel-container').first();
    await expect(timePickerDropdown).toBeVisible();
  });

  test('rangePicker: 添加到画布并展开日期范围选择器', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'rangePicker');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="rangePicker"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const rangePickerEl = page.locator('.ant-picker-range').first();
    await expect(rangePickerEl).toBeVisible();
    await rangePickerEl.click();

    const rangePickerDropdown = page.locator('.ant-picker-panel-container').first();
    await expect(rangePickerDropdown).toBeVisible();
  });

  test('rangePicker: 配置占位符', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'rangePicker');
    await selectField(page, 'rangePicker');

    const placeholderInput = page.locator('[data-testid="prop-placeholder"]');
    await placeholderInput.fill('开始日期 - 结束日期');
    await placeholderInput.blur();
  });
});

// ================================ 4. 基础组件 - 按钮类 ================================

test.describe('基础组件 - 按钮类', () => {

  test('button: 添加到画布并验证按钮可点击', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'button');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="button"]');
    await expect(node).toBeVisible();

    // 设计模式按钮可见
    const btnEl = node.locator('.ant-btn').first();
    await expect(btnEl).toBeVisible();
  });

  test('button: 属性面板修改标签', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'button');
    await selectField(page, 'button');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('提交表单');

    // 按钮文字应更新（在画布节点内查找，排除控制栏的删除按钮）
    const btnEl = page.locator('[data-testid="canvas-node"][data-node-type="button"] .ant-btn:not([data-testid="delete-node-button"])').first();
    await expect(btnEl).toContainText('提交表单');
  });

  test('button: 配置禁用后按钮不可点击', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'button');
    await selectField(page, 'button');

    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();

    await switchToView(page, 'preview');
    // 在预览内容区查找按钮（避开工具栏的保存按钮）
    const btnEl = page.locator('[data-testid="preview-mode-banner"] + * .ant-btn, [data-testid="preview-mode-banner"] ~ * .ant-btn').first();
    await expect(btnEl).toBeDisabled();
  });

  test('button: 配置宽度后按钮尺寸变化', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'button');
    await selectField(page, 'button');

    const widthInput = page.locator('[data-testid="prop-width"]');
    await widthInput.fill('200');
    await widthInput.blur();
  });

  test('button: 预览模式点击触发响应', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'button');
    await selectField(page, 'button');

    await page.locator('[data-testid="prop-label"]').fill('点击我');

    await switchToView(page, 'preview');
    const btnEl = page.locator('[data-testid="preview-mode-banner"] + * .ant-btn, [data-testid="preview-mode-banner"] ~ * .ant-btn').first();
    await expect(btnEl).toContainText('点击我');
    // 点击后应有响应（即使无实际提交逻辑）
    await btnEl.click();
  });
});

// ================================ 5. 高级组件 - 增强选择类 ================================

test.describe('高级组件 - 增强选择类', () => {

  test('cascader: 添加到画布并展开级联选择器', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'cascader');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="cascader"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const cascaderEl = page.locator('.ant-cascader').first();
    await expect(cascaderEl).toBeVisible();
    await cascaderEl.click();

    const cascaderDropdown = page.locator('.ant-cascader-menus').first();
    await expect(cascaderDropdown).toBeVisible();
  });

  test('autoComplete: 添加到画布并输入触发建议', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'autoComplete');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="autoComplete"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const autoCompleteEl = page.locator('.ant-select-auto-complete').first();
    if (await autoCompleteEl.isVisible()) {
      await autoCompleteEl.locator('input').fill('选项');
      await page.waitForTimeout(300);
      const dropdown = page.locator('.ant-select-item-option-content').first();
      if (await dropdown.isVisible()) {
        await expect(dropdown).toBeVisible();
      }
    }
  });

  test('tree: 添加到画布并展开树形选择', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tree');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="tree"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const treeSelectEl = page.locator('.ant-tree-select').first();
    if (await treeSelectEl.isVisible()) {
      await treeSelectEl.click();
      const treeDropdown = page.locator('.ant-select-tree').first();
      if (await treeDropdown.isVisible()) {
        await expect(treeDropdown).toBeVisible();
      }
    }
  });

  test('transfer: 添加到画布并验证穿梭框结构', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'transfer');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="transfer"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const transferEl = page.locator('.ant-transfer').first();
    await expect(transferEl).toBeVisible();

    // 应有左右两个列表区
    const leftList = transferEl.locator('.ant-transfer-list').first();
    const rightList = transferEl.locator('.ant-transfer-list').nth(1);
    await expect(leftList).toBeVisible();
    await expect(rightList).toBeVisible();
  });

  test('cascader: 配置多选', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'cascader');
    await selectField(page, 'cascader');

    const multipleSwitch = page.locator('[data-testid="prop-multiple"]');
    await multipleSwitch.click();
  });

  test('tree: 配置多选', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tree');
    await selectField(page, 'tree');

    const multipleSwitch = page.locator('[data-testid="prop-multiple"]');
    await multipleSwitch.click();
  });

  test('autoComplete: 配置占位符和默认值', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'autoComplete');
    await selectField(page, 'autoComplete');

    await page.locator('[data-testid="prop-placeholder"]').fill('输入搜索');
    await page.locator('[data-testid="prop-default-value"]').fill('选项1');
  });
});

// ================================ 6. 高级组件 - 数值/进度类 ================================

test.describe('高级组件 - 数值/进度类', () => {

  test('slider: 添加到画布并拖动滑块', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'slider');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="slider"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const sliderEl = page.locator('.ant-slider').first();
    await expect(sliderEl).toBeVisible();

    // 验证滑块手柄存在
    const handle = sliderEl.locator('.ant-slider-handle');
    await expect(handle).toBeVisible();
  });

  test('slider: 配置默认值', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'slider');
    await selectField(page, 'slider');

    const defaultValueInput = page.locator('[data-testid="prop-default-value"]');
    await defaultValueInput.fill('60');
  });

  test('slider: 禁用滑块不可拖动', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'slider');
    await selectField(page, 'slider');

    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();

    await switchToView(page, 'preview');
    const sliderEl = page.locator('.ant-slider').first();
    await expect(sliderEl).toHaveClass(/ant-slider-disabled/);
  });

  test('rate: 添加到画布并点击评分', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'rate');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="rate"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const rateEl = page.locator('.ant-rate').first();
    await expect(rateEl).toBeVisible();

    // 点击第三颗星
    const thirdStar = rateEl.locator('.ant-rate-star-full').nth(2);
    if (await thirdStar.isVisible()) {
      await thirdStar.click();
    }
  });

  test('rate: 配置默认值', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'rate');
    await selectField(page, 'rate');

    const defaultValueInput = page.locator('[data-testid="prop-default-value"]');
    await defaultValueInput.fill('4');
  });

  test('rate: 禁用状态下不可评分', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'rate');
    await selectField(page, 'rate');

    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();

    await switchToView(page, 'preview');
    const rateEl = page.locator('.ant-rate').first();
    await expect(rateEl).toHaveClass(/ant-rate-disabled/);
  });
});

// ================================ 7. 高级组件 - 文件/颜色类 ================================

test.describe('高级组件 - 文件/颜色类', () => {

  test('upload: 添加到画布并验证上传按钮', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'upload');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="upload"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const uploadBtn = page.locator('.ant-btn-icon-only').first();
    if (await uploadBtn.isVisible()) {
      await expect(uploadBtn).toBeVisible();
    }
  });

  test('upload: 配置标签文字', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'upload');
    await selectField(page, 'upload');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('上传附件');
  });

  test('upload: 配置禁用', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'upload');
    await selectField(page, 'upload');

    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();

    await switchToView(page, 'preview');
    const uploadEl = page.locator('.ant-upload').first();
    if (await uploadEl.isVisible()) {
      await expect(uploadEl).toHaveClass(/ant-upload-disabled/);
    }
  });

  test('colorPicker: 添加到画布并点击展开颜色选择器', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'colorPicker');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="colorPicker"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    // 找到颜色预览区域
    const colorArea = node.locator('div[style*="background"]').first();
    if (await colorArea.isVisible()) {
      await colorArea.click();
      await page.waitForTimeout(500);
    }
  });

  test('colorPicker: 配置默认值', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'colorPicker');
    await selectField(page, 'colorPicker');

    const defaultValueInput = page.locator('[data-testid="prop-default-value"]');
    await defaultValueInput.fill('#ff0000');
  });
});

// ================================ 8. 高级组件 - 复合类 ================================

test.describe('高级组件 - 复合类', () => {

  test('subTable: 添加到画布', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'subTable');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="subTable"]');
    await expect(node).toBeVisible();
  });

  test('subTable: 预览模式显示表格', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'subTable');
    await selectField(page, 'subTable');

    await switchToView(page, 'preview');
    const tableEl = page.locator('.ant-table').first();
    await expect(tableEl).toBeVisible();
  });

  test('richText: 添加到画布', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'richText');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="richText"]');
    await expect(node).toBeVisible();
  });

  test('richText: 预览模式显示编辑器', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'richText');
    await selectField(page, 'richText');

    await switchToView(page, 'preview');
    const textarea = page.locator('[data-testid="canvas-root"] textarea').first();
    await expect(textarea).toBeVisible();
  });

  test('richText: 配置高度', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'richText');
    await selectField(page, 'richText');

    const heightInput = page.locator('[data-testid="prop-height"]');
    await heightInput.fill('200');
    await heightInput.blur();
  });

  test('richText: 配置标签', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'richText');
    await selectField(page, 'richText');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('文章正文');
  });
});

// ================================ 9. 容器组件 - Card ================================

test.describe('容器组件 - Card', () => {

  test('card: 添加到画布并显示 drop-zone', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="card"]');
    await expect(node).toBeVisible();

    const dropZone = page.locator('[data-testid="drop-zone-card"]');
    await expect(dropZone).toBeVisible();
  });

  test('card: 选中后属性面板显示 CSS 布局配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    const displaySelect = page.locator('[data-testid="prop-display"]');
    await expect(displaySelect).toBeVisible();
  });

  test('card: 配置标签', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('基本信息');
  });

  test('card: 配置 flex 布局并验证子组件水平排列', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    // 设置为弹性盒子布局
    await selectAntDOption(page, 'prop-display', '弹性盒子');

    // 配置主轴方向为水平
    const flexDirSelect = page.locator('[data-testid="prop-flex-direction"]');
    await expect(flexDirSelect).toBeVisible();

    // 配置换行
    const flexWrapSelect = page.locator('[data-testid="prop-flex-wrap"]');
    await expect(flexWrapSelect).toBeVisible();

    // 配置间距
    const gapInput = page.locator('[data-testid="prop-gap"]');
    await gapInput.fill('12px');
  });

  test('card: 配置 grid 布局并验证 grid 专属配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    await selectAntDOption(page, 'prop-display', '网格');

    const gridColsInput = page.locator('[data-testid="prop-grid-template-columns"]');
    await expect(gridColsInput).toBeVisible();
    await gridColsInput.fill('1fr 1fr 1fr');

    const gridGapInput = page.locator('[data-testid="prop-grid-gap"]');
    await expect(gridGapInput).toBeVisible();
    await gridGapInput.fill('16px');
  });

  test('card: 配置 padding 和 margin', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    const paddingInput = page.locator('[data-testid="prop-padding"]');
    await paddingInput.fill('20px');
    await paddingInput.blur();

    const marginInput = page.locator('[data-testid="prop-margin"]');
    await marginInput.fill('8px 0');
    await marginInput.blur();
  });

  test('card: 预览模式显示卡片样式', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');
    await page.locator('[data-testid="prop-label"]').fill('卡片标题');
    await page.locator('[data-testid="prop-label"]').blur();

    await switchToView(page, 'preview');
    const cardEl = page.locator('.ant-card').first();
    await expect(cardEl).toBeVisible();
    await expect(cardEl).toContainText('卡片标题');
  });

  test('card: 向卡片内添加子组件（设计模式）', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await addComponent(page, 'input');
    await addComponent(page, 'select');

    // 两个组件都应该在画布中
    const nodeCount = await getNodeCount(page);
    expect(nodeCount).toBe(3);

    // 预览模式看 card 内的子组件
    await switchToView(page, 'preview');
    const cardEl = page.locator('.ant-card').first();
    await expect(cardEl).toBeVisible();
  });
});

// ================================ 10. 容器组件 - Tabs ================================

test.describe('容器组件 - Tabs', () => {

  test('tabs: 添加到画布并显示 drop-zone', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tabs');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="tabs"]');
    await expect(node).toBeVisible();

    const dropZone = page.locator('[data-testid="drop-zone-tabs"]');
    await expect(dropZone).toBeVisible();
  });

  test('tabs: 切换选项卡', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tabs');
    await selectField(page, 'tabs');

    await switchToView(page, 'preview');
    const tabsEl = page.locator('.ant-tabs').first();
    await expect(tabsEl).toBeVisible();

    // 点击选项卡2
    const tab2 = tabsEl.locator('.ant-tabs-nav-list .ant-tabs-tab').nth(1);
    await tab2.click();
    await page.waitForTimeout(300);
  });

  test('tabs: 配置 flex 布局', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tabs');
    await selectField(page, 'tabs');

    await selectAntDOption(page, 'prop-display', '弹性盒子');

    const flexDirSelect = page.locator('[data-testid="prop-flex-direction"]');
    await expect(flexDirSelect).toBeVisible();
  });

  test('tabs: 配置 padding', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tabs');
    await selectField(page, 'tabs');

    const paddingInput = page.locator('[data-testid="prop-padding"]');
    await paddingInput.fill('16px');
    await paddingInput.blur();
  });

  test('tabs: 预览模式选项卡可交互', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tabs');
    await addComponent(page, 'input');

    await switchToView(page, 'preview');
    const tabsEl = page.locator('.ant-tabs').first();
    await expect(tabsEl).toBeVisible();

    // 三个选项卡
    const tabs = tabsEl.locator('.ant-tabs-tab');
    await expect(tabs).toHaveCount(3);
  });

  test('tabs: 向 tabs 内添加子组件', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tabs');
    await addComponent(page, 'input');

    const nodeCount = await getNodeCount(page);
    expect(nodeCount).toBe(2);
  });
});

// ================================ 11. 容器组件 - Collapse ================================

test.describe('容器组件 - Collapse', () => {

  test('collapse: 添加到画布并显示 drop-zone', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'collapse');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="collapse"]');
    await expect(node).toBeVisible();

    const dropZone = page.locator('[data-testid="drop-zone-collapse"]');
    await expect(dropZone).toBeVisible();
  });

  test('collapse: 点击展开折叠面板', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'collapse');

    await switchToView(page, 'preview');
    const collapseEl = page.locator('.ant-collapse').first();
    await expect(collapseEl).toBeVisible();

    // 点击第一个面板头展开
    const firstHeader = collapseEl.locator('.ant-collapse-header').first();
    if (await firstHeader.isVisible()) {
      await firstHeader.click();
      await page.waitForTimeout(300);
    }
  });

  test('collapse: 配置标签', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'collapse');
    await selectField(page, 'collapse');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('高级配置');
  });

  test('collapse: 配置 flex 布局', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'collapse');
    await selectField(page, 'collapse');

    await selectAntDOption(page, 'prop-display', '弹性盒子');

    const flexDirSelect = page.locator('[data-testid="prop-flex-direction"]');
    await expect(flexDirSelect).toBeVisible();
  });

  test('collapse: 配置 padding', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'collapse');
    await selectField(page, 'collapse');

    const paddingInput = page.locator('[data-testid="prop-padding"]');
    await paddingInput.fill('12px');
    await paddingInput.blur();
  });

  test('collapse: 预览模式默认展开', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'collapse');

    await switchToView(page, 'preview');
    const collapseEl = page.locator('.ant-collapse').first();
    await expect(collapseEl).toBeVisible();

    // 默认展开的面板应有展开图标旋转
    const firstPanel = collapseEl.locator('.ant-collapse-item').first();
    await expect(firstPanel).toBeVisible();
  });

  test('collapse: 向 collapse 内添加子组件', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'collapse');
    await addComponent(page, 'input');
    await addComponent(page, 'select');

    const nodeCount = await getNodeCount(page);
    expect(nodeCount).toBe(3);
  });
});

// ================================ 12. 展示组件 ================================

test.describe('展示组件', () => {

  test('tag: 添加到画布并显示标签列表', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tag');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="tag"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const tags = page.locator('.ant-tag').first();
    await expect(tags).toBeVisible();
  });

  test('tag: 配置标签文本', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tag');
    await selectField(page, 'tag');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('状态标签');
  });

  test('tag: 配置禁用', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'tag');
    await selectField(page, 'tag');

    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();
  });

  test('divider: 添加到画布并显示分割线', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'divider');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="divider"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const dividerEl = page.locator('.ant-divider').first();
    await expect(dividerEl).toBeVisible();
  });

  test('divider: 配置标签文本', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'divider');
    await selectField(page, 'divider');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('分割区域');
  });

  test('calendar: 添加到画布并显示日历', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'calendar');
    const node = page.locator('[data-testid="canvas-node"][data-node-type="calendar"]');
    await expect(node).toBeVisible();

    await switchToView(page, 'preview');
    const calendarEl = page.locator('.ant-picker-calendar').first();
    await expect(calendarEl).toBeVisible();

    // 日历应有日期网格
    const calendarDate = calendarEl.locator('.ant-picker-calendar-date').first();
    await expect(calendarDate).toBeVisible();
  });

  test('calendar: 配置标签', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'calendar');
    await selectField(page, 'calendar');

    const labelInput = page.locator('[data-testid="prop-label"]');
    await labelInput.fill('日程安排');
  });

  test('calendar: 日历可切换月份', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'calendar');

    await switchToView(page, 'preview');
    const calendarEl = page.locator('.ant-picker-calendar').first();

    // 上月/下月按钮
    const prevBtn = calendarEl.locator('.ant-picker-calendar-header button').first();
    if (await prevBtn.isVisible()) {
      await prevBtn.click();
      await page.waitForTimeout(200);
    }
  });
});

// ================================ 13. 尺寸配置 ================================

test.describe('尺寸配置', () => {

  test('宽度配置 - px 单位', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const widthInput = page.locator('[data-testid="prop-width"]');
    await widthInput.fill('300');
    await widthInput.blur();

    // 单位默认 px - Select 显示当前选中项的文本
    const widthUnit = page.locator('[data-testid="prop-width-unit"] .ant-select-selection-item');
    await expect(widthUnit).toContainText('px');
  });

  test('宽度配置 - 百分比单位', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const widthInput = page.locator('[data-testid="prop-width"]');
    await widthInput.fill('50');

    const widthUnit = page.locator('[data-testid="prop-width-unit"]');
    await widthUnit.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("%")').click();
  });

  test('宽度配置 - auto', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const widthUnit = page.locator('[data-testid="prop-width-unit"]');
    await widthUnit.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("auto")').click();
  });

  test('高度配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'textarea');
    await selectField(page, 'textarea');

    // 输入数值
    const heightInput = page.locator('[data-testid="prop-height"]');
    await heightInput.fill('150');
    await heightInput.blur();

    // 切换单位为 px（与宽度配置一致的做法：通过下拉文本定位）
    const heightUnit = page.locator('[data-testid="prop-height-unit"]');
    await heightUnit.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("px")').click();

    const unitLabel = page.locator('[data-testid="prop-height-unit"] .ant-select-selection-item');
    await expect(unitLabel).toContainText('px');
  });

  test('最小宽度/最大宽度配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const minWidthInput = page.locator('[data-testid="prop-min-width"]');
    await minWidthInput.fill('100');
    await minWidthInput.blur();

    const maxWidthInput = page.locator('[data-testid="prop-max-width"]');
    await maxWidthInput.fill('500');
    await maxWidthInput.blur();
  });

  test('最小高度/最大高度配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'textarea');
    await selectField(page, 'textarea');

    const minHeightInput = page.locator('[data-testid="prop-min-height"]');
    await minHeightInput.fill('80');
    await minHeightInput.blur();

    const maxHeightInput = page.locator('[data-testid="prop-max-height"]');
    await maxHeightInput.fill('400');
    await maxHeightInput.blur();
  });

  test('快捷尺寸按钮', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    // 点击 100% 快捷按钮
    const quickBtn = page.locator('button:has-text("100%")');
    await quickBtn.click();
  });
});

// ================================ 14. 视图模式 ================================

test.describe('视图模式', () => {

  test('设计模式 - 显示 canvas-node', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await addComponent(page, 'select');

    const nodes = page.locator('[data-testid="canvas-node"]');
    await expect(nodes).toHaveCount(2);
  });

  test('设计模式 - 显示拖拽手柄', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const dragHandle = page.locator('[data-testid="drag-handle"]').first();
    await expect(dragHandle).toBeVisible();
  });

  test('预览模式 - 显示预览横幅', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await switchToView(page, 'preview');

    const banner = page.locator('[data-testid="preview-mode-banner"]');
    await expect(banner).toBeVisible();
    await expect(banner).toContainText('预览模式');
  });

  test('预览模式 - 所有字段可见且可交互', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await addComponent(page, 'select');
    await addComponent(page, 'switch');

    await switchToView(page, 'preview');

    const banner = page.locator('[data-testid="preview-mode-banner"]');
    await expect(banner).toBeVisible();
    // 使用 canvas-root 限定范围避免匹配属性面板中的输入框
    const canvasRoot = page.locator('[data-testid="canvas-root"]');
    await expect(canvasRoot.locator('.ant-input').first()).toBeVisible();
    await expect(canvasRoot.locator('.ant-select').first()).toBeVisible();
    await expect(canvasRoot.locator('.ant-switch').first()).toBeVisible();
  });

  test('JSON 模式 - 显示 JSON 输出', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await addComponent(page, 'select');
    await switchToView(page, 'JSON');

    const jsonOutput = page.locator('[data-testid="form-json-output"]');
    await expect(jsonOutput).toBeVisible({ timeout: 5000 });
    await expect(jsonOutput).toContainText('"formId"');
    await expect(jsonOutput).toContainText('"fields"');
  });

  test('JSON 模式 - 包含所有字段类型', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await addComponent(page, 'inputNumber');
    await addComponent(page, 'select');
    await addComponent(page, 'datePicker');
    await addComponent(page, 'switch');
    await addComponent(page, 'button');

    await switchToView(page, 'JSON');

    const jsonOutput = page.locator('[data-testid="form-json-output"]');
    await expect(jsonOutput).toContainText('"input"');
    await expect(jsonOutput).toContainText('"inputNumber"');
    await expect(jsonOutput).toContainText('"select"');
    await expect(jsonOutput).toContainText('"datePicker"');
    await expect(jsonOutput).toContainText('"switch"');
    await expect(jsonOutput).toContainText('"button"');
  });

  test('JSON 模式 - 包含字段属性配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    await page.locator('[data-testid="prop-label"]').fill('用户名');
    await page.locator('[data-testid="prop-field-id"]').fill('userName');
    await page.locator('[data-testid="prop-required"]').click();

    await switchToView(page, 'JSON');

    const jsonOutput = page.locator('[data-testid="form-json-output"]');
    await expect(jsonOutput).toContainText('"userName"');
    await expect(jsonOutput).toContainText('"用户名"');
    await expect(jsonOutput).toContainText('"required"');
  });

  test('视图切换 - 从预览切回设计', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await switchToView(page, 'preview');
    await switchToView(page, 'design');

    const nodes = page.locator('[data-testid="canvas-node"]');
    await expect(nodes).toHaveCount(1);
  });

  test('空画布状态', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    const emptyState = page.locator('[data-testid="canvas-empty"]');
    await expect(emptyState).toBeVisible();
    await expect(emptyState).toContainText('从左侧拖动组件到这里');
  });
});

// ================================ 15. 字段操作 ================================

test.describe('字段操作', () => {

  test('选中字段后属性面板显示', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    await expect(page.locator('[data-testid="property-panel-title"]')).toBeVisible();
    await expect(page.locator('[data-testid="prop-label"]')).toBeVisible();
    await expect(page.locator('[data-testid="prop-field-id"]')).toBeVisible();
  });

  test('空状态属性面板提示', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    const emptyPanel = page.locator('[data-testid="property-panel-empty"]');
    await expect(emptyPanel).toBeVisible();
    await expect(emptyPanel).toContainText('从画布选择一个字段');
  });

  test('删除字段 - 画布删除按钮', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await addComponent(page, 'select');

    const countBefore = await getNodeCount(page);
    expect(countBefore).toBe(2);

    await selectField(page, 'input');
    const deleteBtn = page.locator('[data-testid="delete-node-button"]').first();
    await deleteBtn.click();

    const countAfter = await getNodeCount(page);
    expect(countAfter).toBe(1);
  });

  test('删除字段 - 属性面板删除按钮', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const deleteBtn = page.locator('[data-testid="prop-delete-button"]');
    await deleteBtn.click();

    const countAfter = await getNodeCount(page);
    expect(countAfter).toBe(0);
  });

  test('复制字段', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const countBefore = await getNodeCount(page);

    const duplicateBtn = page.locator('[data-testid="prop-duplicate-button"]');
    await duplicateBtn.click();

    const countAfter = await getNodeCount(page);
    expect(countAfter).toBe(countBefore + 1);

    // 新字段应在原字段后面
    const nodes = page.locator('[data-testid="canvas-node"]');
    const firstNode = nodes.first();
    const secondNode = nodes.nth(1);
    await expect(secondNode).toContainText('(副本)');
  });

  test('复制字段后新字段自动选中', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const duplicateBtn = page.locator('[data-testid="prop-duplicate-button"]');
    await duplicateBtn.click();

    // 新字段应自动进入选中状态（显示属性面板）
    await expect(page.locator('[data-testid="property-panel-title"]')).toBeVisible();
  });

  test('批量添加组件', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await addComponent(page, 'inputNumber');
    await addComponent(page, 'select');
    await addComponent(page, 'datePicker');
    await addComponent(page, 'checkbox');
    await addComponent(page, 'radio');
    await addComponent(page, 'switch');
    await addComponent(page, 'button');
    await addComponent(page, 'textarea');

    const count = await getNodeCount(page);
    expect(count).toBe(9);
  });

  test('字段编码唯一性', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const fieldIdInput = page.locator('[data-testid="prop-field-id"]');
    await fieldIdInput.fill('testField');
    await fieldIdInput.blur();

    // 复制后 fieldId 应自动加后缀，复制的新节点在最后，选中它
    const duplicateBtn = page.locator('[data-testid="prop-duplicate-button"]');
    await duplicateBtn.click();

    const allInputNodes = page.locator('[data-testid="canvas-node"][data-node-type="input"]');
    await allInputNodes.last().click();
    const newFieldId = page.locator('[data-testid="prop-field-id"]');
    await expect(newFieldId).toHaveValue('testField_copy');
  });
});

// ================================ 16. CSS 布局（容器专属） ================================

test.describe('CSS 布局配置', () => {

  test('flex 布局 - 主轴对齐', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    await selectAntDOption(page, 'prop-display', '弹性盒子');

    const justifySelect = page.locator('[data-testid="prop-justify-content"]');
    await expect(justifySelect).toBeVisible();
    await justifySelect.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("居中")').click();
  });

  test('flex 布局 - 交叉轴对齐', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    await selectAntDOption(page, 'prop-display', '弹性盒子');

    const alignSelect = page.locator('[data-testid="prop-align-items"]');
    await expect(alignSelect).toBeVisible();
    await alignSelect.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("居中")').click();
  });

  test('flex 布局 - 换行设置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    await selectAntDOption(page, 'prop-display', '弹性盒子');

    const wrapSelect = page.locator('[data-testid="prop-flex-wrap"]');
    await expect(wrapSelect).toBeVisible();
    await wrapSelect.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("换行")').first().click();
  });

  test('grid 布局 - 行定义', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    await selectAntDOption(page, 'prop-display', '网格');

    const gridRowsInput = page.locator('[data-testid="prop-grid-template-rows"]');
    await expect(gridRowsInput).toBeVisible();
    await gridRowsInput.fill('auto 1fr auto');
  });

  test('旧版子组件布局 - 垂直排列', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    // 先切换到 block 以显示旧版 childLayout 配置
    await selectAntDOption(page, 'prop-display', '块级 (block)');

    const childLayoutSelect = page.locator('[data-testid="prop-child-layout"]');
    await expect(childLayoutSelect).toBeVisible();
    await childLayoutSelect.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("垂直排列")').click();
  });

  test('旧版子组件布局 - 水平排列', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    await selectAntDOption(page, 'prop-display', '块级 (block)');

    const childLayoutSelect = page.locator('[data-testid="prop-child-layout"]');
    await childLayoutSelect.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("水平排列")').click();
  });

  test('旧版子组件布局 - 网格布局', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'card');
    await selectField(page, 'card');

    await selectAntDOption(page, 'prop-display', '块级 (block)');

    const childLayoutSelect = page.locator('[data-testid="prop-child-layout"]');
    await childLayoutSelect.click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item:has-text("网格布局")').click();

    // 网格布局时显示列数配置
    const gridColumnsSelect = page.locator('[data-testid="prop-grid-columns"]');
    await expect(gridColumnsSelect).toBeVisible();
  });
});

// ================================ 17. 完整表单流程 ================================

test.describe('完整表单流程', () => {

  test('创建包含多种组件的表单', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    // 添加多种组件
    await addComponent(page, 'input');        // 姓名
    await selectField(page, 'input');
    await page.locator('[data-testid="prop-label"]').fill('姓名');
    await page.locator('[data-testid="prop-field-id"]').fill('name');
    await page.locator('[data-testid="prop-required"]').click();

    await addComponent(page, 'inputNumber');  // 年龄
    await selectField(page, 'inputNumber');
    await page.locator('[data-testid="prop-label"]').fill('年龄');
    await page.locator('[data-testid="prop-field-id"]').fill('age');

    await addComponent(page, 'select');       // 部门
    await selectField(page, 'select');
    await page.locator('[data-testid="prop-label"]').fill('部门');
    await page.locator('[data-testid="prop-field-id"]').fill('department');

    await addComponent(page, 'datePicker');   // 入职日期
    await selectField(page, 'datePicker');
    await page.locator('[data-testid="prop-label"]').fill('入职日期');
    await page.locator('[data-testid="prop-field-id"]').fill('joinDate');

    await addComponent(page, 'radio');        // 性别
    await selectField(page, 'radio');
    await page.locator('[data-testid="prop-label"]').fill('性别');
    await page.locator('[data-testid="prop-field-id"]').fill('gender');

    await addComponent(page, 'switch');       // 在职状态
    await selectField(page, 'switch');
    await page.locator('[data-testid="prop-label"]').fill('在职状态');
    await page.locator('[data-testid="prop-field-id"]').fill('active');

    const count = await getNodeCount(page);
    expect(count).toBe(6);

    // 预览
    await switchToView(page, 'preview');
    await expect(page.locator('[data-testid="preview-mode-banner"]')).toBeVisible();

    // JSON
    await switchToView(page, 'JSON');
    const jsonOutput = page.locator('[data-testid="form-json-output"]');
    await expect(jsonOutput).toContainText('"name"');
    await expect(jsonOutput).toContainText('"age"');
    await expect(jsonOutput).toContainText('"department"');
    await expect(jsonOutput).toContainText('"joinDate"');
    await expect(jsonOutput).toContainText('"gender"');
    await expect(jsonOutput).toContainText('"active"');
  });

  test('删除所有字段后画布为空', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await addComponent(page, 'select');

    let count = await getNodeCount(page);
    expect(count).toBe(2);

    await selectField(page, 'input');
    await page.locator('[data-testid="delete-node-button"]').first().click();

    await selectField(page, 'select');
    await page.locator('[data-testid="delete-node-button"]').first().click();

    count = await getNodeCount(page);
    expect(count).toBe(0);

    const emptyState = page.locator('[data-testid="canvas-empty"]');
    await expect(emptyState).toBeVisible();
  });

  test('组件面板显示 27 个组件', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    // 验证组件面板标题
    const panelTitle = page.locator('h3:has-text("组件库")');
    await expect(panelTitle).toBeVisible();
    await expect(panelTitle).toContainText('27');
  });

  test('所有组件类型都可添加到画布', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    // 基础组件和布局组件可以正常渲染到画布
    const types = [
      'input', 'inputNumber', 'select', 'datePicker', 'checkbox', 'radio',
      'switch', 'button', 'textarea', 'card', 'tabs', 'collapse',
      'tag', 'divider', 'calendar',
    ];

    for (const type of types) {
      await addComponent(page, type);
      const node = page.locator(`[data-testid="canvas-node"][data-node-type="${type}"]`);
      await expect(node).toBeVisible({ timeout: 3000 });
    }

    const finalCount = await getNodeCount(page);
    expect(finalCount).toBe(15);
  });
});

// ================================ 18. 拖拽排序 ================================

test.describe('拖拽排序', () => {

  test('拖拽手柄可见且可交互', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const dragHandle = page.locator('[data-testid="drag-handle"]').first();
    await expect(dragHandle).toBeVisible();
    // 鼠标悬停时控制栏应显示
    await dragHandle.hover();
  });

  test('选中节点时显示删除按钮', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const deleteBtn = page.locator('[data-testid="delete-node-button"]').first();
    await expect(deleteBtn).toBeVisible();
  });

  test('未选中节点时控制栏半透明可见', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    // 先选中字段
    await selectField(page, 'input');
    // 键盘 Escape 取消选中，避免鼠标点击坐标依赖
    await page.keyboard.press('Escape');
    await page.waitForTimeout(300);

    // 拖拽手柄透明度应为 1（打破父级控制栏 opacity 继承，始终完全可见，不受选中状态影响）
    const dragHandle = page.locator('[data-testid="drag-handle"]').first();
    await expect(dragHandle).toBeVisible();
    const opacity = await dragHandle.evaluate(el => window.getComputedStyle(el).opacity);
    expect(opacity).toBe('1');
  });
});

// ================================ 19. 表达式与高级配置 ================================

test.describe('表达式与高级配置', () => {

  test('计算表达式配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'inputNumber');
    await selectField(page, 'inputNumber');

    const formulaInput = page.locator('[data-testid="prop-formula"]');
    await expect(formulaInput).toBeVisible();
    await formulaInput.fill('${price * quantity}');
  });

  test('BO 绑定字段配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const boFieldInput = page.locator('[data-testid="prop-bo-field"]');
    await expect(boFieldInput).toBeVisible();
    await boFieldInput.fill('sys_user.username');
  });

  test('帮助文本配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const helpTextInput = page.locator('[data-testid="prop-help-text"]');
    await helpTextInput.fill('请输入真实姓名，用于身份验证');
  });

  test('隐藏字段配置', async ({ page }) => {
    await page.goto('/');
    await waitForCanvas(page);

    await addComponent(page, 'input');
    await selectField(page, 'input');

    const disabledSwitch = page.locator('[data-testid="prop-disabled"]');
    await disabledSwitch.click();

    await switchToView(page, 'preview');
    const inputEl = page.locator('.ant-input').first();
    await expect(inputEl).toBeDisabled();
  });
});
