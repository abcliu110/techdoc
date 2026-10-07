# 数学思维启发学习系统 - 测试抓手（Test Hooks）规范

> 版本：v1.0.0
> 创建日期：2026-10-06
> 适用框架：React + Playwright + Vitest

## 1. 概述

本文档定义数学思维启发学习系统中所有可交互元素的 `data-testid` 命名规则，确保 E2E 测试和单元测试能够稳定定位 UI 元素。

### 1.1 命名原则

- **语义化**：testid 应反映元素的业务含义，而非实现细节
- **唯一性**：同一组件树内保持唯一，避免重复
- **可组合性**：支持前缀组合，便于分层定位
- **稳定性**：不随实现细节变化而变化

### 1.2 命名格式

```
{页面/模块}-{组件类型}-{具体功能}-{状态?}
```

示例：
- `home-start-button`
- `session-step-content-pie-chart`
- `practice-drag-item-1`

---

## 2. 页面级 Testids

### 2.1 首页 (Home)

| Testid | 元素 | 说明 |
|--------|------|------|
| `home-container` | 主容器 | 首页根容器 |
| `home-header` | 页头 | 包含标题和设置入口 |
| `home-logo` | Logo | 应用 Logo |
| `home-title` | 应用标题 | "数学思维启发" |
| `home-subtitle` | 副标题 | 欢迎语 |
| `home-start-button` | 开始学习按钮 | 进入学习选择 |
| `home-progress-button` | 学习进度按钮 | 查看能力画像 |
| `home-settings-button` | 设置按钮 | 进入设置页 |
| `home-user-avatar` | 用户头像 | 点击进入个人中心 |

### 2.2 学习选择页 (Select)

| Testid | 元素 | 说明 |
|--------|------|------|
| `select-container` | 主容器 | 学习选择页根容器 |
| `select-back-button` | 返回按钮 | 返回首页 |
| `select-title` | 页面标题 | "选择学习内容" |
| `select-filter-thought-line` | 思想主线筛选 | 筛选下拉框 |
| `select-filter-difficulty` | 难度筛选 | 难度筛选下拉框 |
| `select-filter-grade` | 年级筛选 | 年级筛选下拉框 |
| `select-content-list` | 内容列表 | 内容包列表容器 |
| `select-content-item-{id}` | 内容项 | 单个内容包卡片 |
| `select-content-item-{id}-title` | 内容标题 | 内容包名称 |
| `select-content-item-{id}-description` | 内容描述 | 内容包简短描述 |
| `select-content-item-{id}-difficulty` | 难度标签 | 难度等级显示 |
| `select-content-item-{id}-time` | 预计时长 | 预计学习时间 |
| `select-content-item-{id}-start-button` | 开始按钮 | 开始该内容学习 |
| `select-empty-state` | 空状态 | 无匹配内容时显示 |

### 2.3 学习会话页 (Session)

| Testid | 元素 | 说明 |
|--------|------|------|
| `session-container` | 主容器 | 学习会话根容器 |
| `session-header` | 页头 | 进度和退出按钮 |
| `session-progress-bar` | 进度条 | 整体进度指示 |
| `session-progress-text` | 进度文字 | "步骤 X / Y" |
| `session-exit-button` | 退出按钮 | 退出当前会话 |
| `session-pause-button` | 暂停按钮 | 暂停学习 |
| `session-step-container` | 步骤容器 | 步骤内容区域 |
| `session-step-title` | 步骤标题 | 当前步骤标题 |
| `session-step-instruction` | 步骤说明 | 题目说明文字 |
| `session-step-type-badge` | 步骤类型标签 | concrete/pictorial 等 |
| `session-timer` | 计时器 | 剩余时间显示 |
| `session-timer-bar` | 计时器进度条 | 时间进度可视化 |
| `session-hint-button` | 提示按钮 | 请求提示 |
| `session-skip-button` | 跳过按钮 | 跳过当前步骤 |

### 2.4 可视化组件 (Visualization)

| Testid | 元素 | 说明 |
|--------|------|------|
| `viz-pie-chart` | 圆饼图容器 | 圆饼图根容器 |
| `viz-pie-chart-segment-{index}` | 圆饼段 | 单个填充段 |
| `viz-pie-chart-label-{index}` | 圆饼标签 | 段标签 |
| `viz-bar-chart` | 条形图容器 | 条形图根容器 |
| `viz-bar-chart-bar-{index}` | 条形 | 单个条形 |
| `viz-bar-chart-value-{index}` | 条形值 | 条形上方数值 |
| `viz-fraction-bar` | 分数条容器 | 分数条根容器 |
| `viz-fraction-bar-item-{index}` | 分数条项 | 单个分数条 |
| `viz-fraction-bar-numerator` | 分子显示 | 分子文字 |
| `viz-fraction-bar-denominator` | 分母显示 | 分母文字 |
| `viz-number-line` | 数轴容器 | 数轴根容器 |
| `viz-number-line-point-{index}` | 数轴点 | 单个标记点 |
| `viz-rect-grid` | 矩形网格容器 | 网格根容器 |
| `viz-rect-grid-cell-{row}-{col}` | 网格单元格 | 单个格子 |

### 2.5 交互组件 (Interaction)

| Testid | 元素 | 说明 |
|--------|------|------|
| `interaction-drag-container` | 拖拽容器 | 拖拽交互根容器 |
| `interaction-drag-item-{id}` | 拖拽项 | 可拖拽元素 |
| `interaction-drop-zone-{id}` | 放置区 | 目标放置区域 |
| `interaction-tap-container` | 点击容器 | 点击选择根容器 |
| `interaction-tap-option-{id}` | 选项 | 单个可选项 |
| `interaction-tap-option-{id}-label` | 选项标签 | 选项文字 |
| `interaction-tap-option-{id}-selected` | 选中状态 | 选中样式标记 |
| `interaction-input-container` | 输入容器 | 输入框根容器 |
| `interaction-input-field` | 输入框 | 文本/数值输入框 |
| `interaction-input-submit-button` | 提交按钮 | 提交输入 |
| `interaction-order-container` | 排序容器 | 排序交互根容器 |
| `interaction-order-item-{index}` | 排序项 | 单个可排序项 |
| `interaction-order-submit-button` | 确认顺序按钮 | 提交排序结果 |

### 2.6 反馈组件 (Feedback)

| Testid | 元素 | 说明 |
|--------|------|------|
| `feedback-container` | 反馈容器 | 反馈消息根容器 |
| `feedback-correct` | 正确反馈 | 正确时的反馈 |
| `feedback-incorrect` | 错误反馈 | 错误时的反馈 |
| `feedback-hint` | 提示反馈 | 提示信息 |
| `feedback-encourage` | 鼓励反馈 | 鼓励消息 |
| `feedback-message` | 反馈文字 | 反馈内容文字 |
| `feedback-next-button` | 下一步按钮 | 进入下一步 |
| `feedback-try-again-button` | 再试一次按钮 | 重新尝试 |

### 2.7 能力画像页 (Profile)

| Testid | 元素 | 说明 |
|--------|------|------|
| `profile-container` | 主容器 | 能力画像根容器 |
| `profile-back-button` | 返回按钮 | 返回上一页 |
| `profile-header` | 页头 | 用户信息 |
| `profile-user-name` | 用户名 | 用户姓名 |
| `profile-overall-score` | 总体分数 | 能力总分 |
| `profile-overall-level` | 总体等级 | 能力等级 |
| `profile-thought-line-{name}` | 思想主线能力 | 单主线能力卡片 |
| `profile-thought-line-{name}-score` | 主线分数 | 分数数值 |
| `profile-thought-line-{name}-bar` | 能力条 | 能力可视化条 |
| `profile-strengths-section` | 优势区域 | 优势列表 |
| `profile-weaknesses-section` | 待提升区域 | 弱点列表 |
| `profile-learning-history` | 学习历史 | 历史记录 |

### 2.8 设置页 (Settings)

| Testid | 元素 | 说明 |
|--------|------|------|
| `settings-container` | 主容器 | 设置页根容器 |
| `settings-back-button` | 返回按钮 | 返回上一页 |
| `settings-title` | 页面标题 | "设置" |
| `settings-hint-toggle` | 提示开关 | 启用/禁用提示 |
| `settings-sound-toggle` | 音效开关 | 启用/禁用音效 |
| `settings-encouragement-toggle` | 鼓励开关 | 启用/禁用鼓励反馈 |
| `settings-difficulty-select` | 难度选择 | 难度偏好选择 |
| `settings-reset-button` | 重置按钮 | 重置学习数据 |

---

## 3. 通用组件 Testids

### 3.1 按钮 (Button)

```tsx
// 使用示例
<button data-testid="session-submit-button" onClick={handleSubmit}>
  提交答案
</button>
```

| Testid | 元素 | 说明 |
|--------|------|------|
| `{context}-{action}-button` | 操作按钮 | {context}为上下文，{action}为动作 |

### 3.2 输入框 (Input)

```tsx
// 使用示例
<input 
  data-testid="practice-number-input" 
  type="number" 
  value={value}
  onChange={handleChange}
/>
```

| Testid | 元素 | 说明 |
|--------|------|------|
| `{context}-{type}-input` | 输入框 | {context}为上下文，{type}为输入类型 |

### 3.3 模态框 (Modal)

```tsx
// 使用示例
<div data-testid="session-exit-confirm-modal">
  <button data-testid="modal-confirm-button">确认</button>
  <button data-testid="modal-cancel-button">取消</button>
</div>
```

| Testid | 元素 | 说明 |
|--------|------|------|
| `{context}-{type}-modal` | 模态框 | 模态框容器 |
| `modal-confirm-button` | 确认按钮 | 模态框确认 |
| `modal-cancel-button` | 取消按钮 | 模态框取消 |
| `modal-close-button` | 关闭按钮 | 关闭模态框 |

### 3.4 加载状态 (Loading)

```tsx
// 使用示例
<div data-testid="session-loading">
  <span data-testid="loading-spinner" />
  <span data-testid="loading-text">加载中...</span>
</div>
```

| Testid | 元素 | 说明 |
|--------|------|------|
| `{context}-loading` | 加载容器 | 加载状态根容器 |
| `loading-spinner` | 加载动画 | 旋转加载动画 |
| `loading-text` | 加载文字 | 加载提示文字 |

### 3.5 空状态 (Empty)

```tsx
// 使用示例
<div data-testid="select-empty-state">
  <span data-testid="empty-icon" />
  <span data-testid="empty-message">暂无内容</span>
</div>
```

| Testid | 元素 | 说明 |
|--------|------|------|
| `{context}-empty-state` | 空状态容器 | 空状态根容器 |
| `empty-icon` | 空状态图标 | 空状态图标 |
| `empty-message` | 空状态消息 | 空状态文字说明 |

---

## 4. React Hooks 使用示例

### 4.1 基本使用

```tsx
import { render, screen } from '@testing-library/react';

// 使用 getByTestId 查询元素
test('点击开始学习按钮', () => {
  render(<HomePage />);
  
  const startButton = screen.getByTestId('home-start-button');
  expect(startButton).toBeInTheDocument();
  expect(startButton).toBeEnabled();
  
  userEvent.click(startButton);
  
  expect(screen.getByTestId('select-container')).toBeInTheDocument();
});
```

### 4.2 组合查询

```tsx
test('验证内容包卡片元素', () => {
  render(<ContentList items={contentPackages} />);
  
  // 遍历所有内容项
  contentPackages.forEach((pkg) => {
    const card = screen.getByTestId(`select-content-item-${pkg.id}`);
    const title = screen.getByTestId(`select-content-item-${pkg.id}-title`);
    const startBtn = screen.getByTestId(`select-content-item-${pkg.id}-start-button`);
    
    expect(title).toHaveTextContent(pkg.title);
    expect(startBtn).toBeEnabled();
  });
});
```

### 4.3 动态元素

```tsx
test('验证拖拽交互', () => {
  render(<DragInteraction config={dragConfig} />);
  
  // 动态生成多个拖拽项
  dragConfig.items.forEach((item, index) => {
    const dragItem = screen.getByTestId(`interaction-drag-item-${item.id}`);
    expect(dragItem).toBeInTheDocument();
    expect(dragItem).toHaveTextContent(item.content);
  });
  
  // 验证放置区
  dragConfig.dropZones.forEach((zone) => {
    const dropZone = screen.getByTestId(`interaction-drop-zone-${zone.id}`);
    expect(dropZone).toBeInTheDocument();
  });
});
```

### 4.4 状态验证

```tsx
test('验证选中状态', () => {
  render(<TapInteraction options={options} onSelect={handleSelect} />);
  
  const option = screen.getByTestId('interaction-tap-option-a');
  
  // 初始状态未选中
  expect(screen.getByTestId('interaction-tap-option-a-selected')).not.toBeVisible();
  
  userEvent.click(option);
  
  // 选中后显示选中标记
  expect(screen.getByTestId('interaction-tap-option-a-selected')).toBeVisible();
});
```

---

## 5. Playwright E2E 测试示例

### 5.1 基础定位

```typescript
import { test, expect } from '@playwright/test';

test.describe('学习流程', () => {
  test('完整学习流程', async ({ page }) => {
    // 首页
    await page.goto('/');
    await expect(page.locator('[data-testid="home-container"]')).toBeVisible();
    await expect(page.locator('[data-testid="home-title"]')).toHaveText('数学思维启发');
    
    // 点击开始学习
    await page.click('[data-testid="home-start-button"]');
    
    // 选择内容页
    await expect(page.locator('[data-testid="select-container"]')).toBeVisible();
    
    // 选择第一个内容包
    const firstItem = page.locator('[data-testid^="select-content-item-"]').first();
    await firstItem.locator('[data-testid$="-start-button"]').click();
    
    // 进入学习会话
    await expect(page.locator('[data-testid="session-container"]')).toBeVisible();
    await expect(page.locator('[data-testid="session-progress-bar"]')).toBeVisible();
  });
});
```

### 5.2 可视化组件测试

```typescript
test.describe('可视化组件', () => {
  test('圆饼图交互', async ({ page }) => {
    await page.goto('/session/demo-session');
    
    // 验证圆饼图存在
    const pieChart = page.locator('[data-testid="viz-pie-chart"]');
    await expect(pieChart).toBeVisible();
    
    // 验证各分段
    const segments = pieChart.locator('[data-testid^="viz-pie-chart-segment-"]');
    await expect(segments).toHaveCount(8); // 8个分段
    
    // 点击第一个分段
    await segments.first().click();
    
    // 验证选中状态
    await expect(segments.first()).toHaveClass(/selected/);
  });
  
  test('分数条验证', async ({ page }) => {
    await page.goto('/session/demo-session');
    
    const fractionBars = page.locator('[data-testid^="viz-fraction-bar-item-"]');
    await expect(fractionBars).toHaveCount(3);
    
    // 验证分子分母显示
    const firstBar = fractionBars.first();
    await expect(firstBar.locator('[data-testid="viz-fraction-bar-numerator"]')).toHaveText('3');
    await expect(firstBar.locator('[data-testid="viz-fraction-bar-denominator"]')).toHaveText('4');
  });
});
```

### 5.3 交互测试

```typescript
test.describe('交互功能', () => {
  test('拖拽交互', async ({ page }) => {
    await page.goto('/session/demo-session');
    
    const dragItem = page.locator('[data-testid="interaction-drag-item-circle"]');
    const dropZone = page.locator('[data-testid="interaction-drop-zone-target"]');
    
    // 执行拖拽
    await dragItem.dragTo(dropZone);
    
    // 验证放置成功
    await expect(dropZone).toContainText('circle');
  });
  
  test('输入提交', async ({ page }) => {
    await page.goto('/session/demo-session');
    
    const input = page.locator('[data-testid="interaction-input-field"]');
    const submitBtn = page.locator('[data-testid="interaction-input-submit-button"]');
    
    await input.fill('42');
    await submitBtn.click();
    
    // 等待反馈
    await expect(page.locator('[data-testid="feedback-container"]')).toBeVisible();
  });
});
```

### 5.4 状态转换测试

```typescript
test.describe('状态验证', () => {
  test('步骤完成转换', async ({ page }) => {
    await page.goto('/session/demo-session');
    
    // 初始进度
    await expect(page.locator('[data-testid="session-progress-text"]')).toHaveText('步骤 1 / 5');
    
    // 完成任务
    await completeCurrentStep(page);
    
    // 进度更新
    await expect(page.locator('[data-testid="session-progress-text"]')).toHaveText('步骤 2 / 5');
  });
  
  test('暂停恢复', async ({ page }) => {
    await page.goto('/session/demo-session');
    
    // 暂停
    await page.click('[data-testid="session-pause-button"]');
    await expect(page.locator('[data-testid="session-pause-overlay"]')).toBeVisible();
    
    // 恢复
    await page.click('[data-testid="pause-resume-button"]');
    await expect(page.locator('[data-testid="session-pause-overlay"]')).not.toBeVisible();
  });
});
```

---

## 6. Vitest 单元测试示例

### 6.1 组件渲染测试

```typescript
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { PieChart } from '../components/PieChart';

describe('PieChart', () => {
  it('渲染指定数量的分段', () => {
    render(<PieChart totalParts={8} filledParts={3} />);
    
    const segments = screen.getAllByTestId(/viz-pie-chart-segment-/);
    expect(segments).toHaveLength(8);
  });
  
  it('渲染标签', () => {
    render(
      <PieChart 
        totalParts={4} 
        filledParts={2} 
        showLabels={true} 
      />
    );
    
    const labels = screen.getAllByTestId(/viz-pie-chart-label-/);
    expect(labels).toHaveLength(4);
  });
});
```

### 6.2 交互测试

```typescript
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { TapOptions } from '../components/TapOptions';

describe('TapOptions', () => {
  it('点击选项触发回调', async () => {
    const handleSelect = vi.fn();
    render(
      <TapOptions 
        options={[
          { id: 'a', label: '选项 A' },
          { id: 'b', label: '选项 B' }
        ]}
        onSelect={handleSelect}
      />
    );
    
    await userEvent.click(screen.getByTestId('interaction-tap-option-a'));
    
    expect(handleSelect).toHaveBeenCalledWith('a');
  });
  
  it('单选模式下只能选择一个', async () => {
    render(
      <TapOptions 
        options={[{ id: 'a' }, { id: 'b' }]}
        multiSelect={false}
      />
    );
    
    await userEvent.click(screen.getByTestId('interaction-tap-option-a'));
    await userEvent.click(screen.getByTestId('interaction-tap-option-b'));
    
    // 验证第二个选项被选中
    expect(screen.getByTestId('interaction-tap-option-b-selected')).toBeVisible();
  });
});
```

---

## 7. 数据属性辅助工具

### 7.1 Testid 构建工具

```typescript
// src/test/utils/testid.ts

type TestidPart = string | number;

/**
 * 构建 testid 字符串
 */
export function testid(...parts: TestidPart[]): string {
  return parts.join('-');
}

/**
 * 常见前缀
 */
export const TestidPrefix = {
  HOME: 'home',
  SELECT: 'select',
  SESSION: 'session',
  VIZ: 'viz',
  INTERACTION: 'interaction',
  FEEDBACK: 'feedback',
  PROFILE: 'profile',
  SETTINGS: 'settings',
  MODAL: 'modal',
  LOADING: 'loading',
  EMPTY: 'empty',
} as const;

/**
 * Session 相关 testid
 */
export const SessionTestid = {
  container: testid(TestidPrefix.SESSION, 'container'),
  header: testid(TestidPrefix.SESSION, 'header'),
  progressBar: testid(TestidPrefix.SESSION, 'progress-bar'),
  progressText: testid(TestidPrefix.SESSION, 'progress-text'),
  exitButton: testid(TestidPrefix.SESSION, 'exit-button'),
  pauseButton: testid(TestidPrefix.SESSION, 'pause-button'),
  stepContainer: testid(TestidPrefix.SESSION, 'step-container'),
  stepTitle: testid(TestidPrefix.SESSION, 'step-title'),
  stepInstruction: testid(TestidPrefix.SESSION, 'step-instruction'),
  timer: testid(TestidPrefix.SESSION, 'timer'),
  hintButton: testid(TestidPrefix.SESSION, 'hint-button'),
  skipButton: testid(TestidPrefix.SESSION, 'skip-button'),
  submitButton: testid(TestidPrefix.SESSION, 'submit-button'),
  
  // 可变部分
  stepTypeBadge: (type: string) => testid(TestidPrefix.SESSION, 'step-type-badge', type),
} as const;

/**
 * Visualization 相关 testid
 */
export const VizTestid = {
  pieChart: testid(TestidPrefix.VIZ, 'pie-chart'),
  pieSegment: (index: number) => testid(TestidPrefix.VIZ, 'pie-chart-segment', String(index)),
  pieLabel: (index: number) => testid(TestidPrefix.VIZ, 'pie-chart-label', String(index)),
  barChart: testid(TestidPrefix.VIZ, 'bar-chart'),
  bar: (index: number) => testid(TestidPrefix.VIZ, 'bar-chart-bar', String(index)),
  fractionBar: testid(TestidPrefix.VIZ, 'fraction-bar'),
  fractionItem: (index: number) => testid(TestidPrefix.VIZ, 'fraction-bar-item', String(index)),
  numerator: testid(TestidPrefix.VIZ, 'fraction-bar-numerator'),
  denominator: testid(TestidPrefix.VIZ, 'fraction-bar-denominator'),
} as const;

/**
 * Interaction 相关 testid
 */
export const InteractionTestid = {
  dragContainer: testid(TestidPrefix.INTERACTION, 'drag-container'),
  dragItem: (id: string) => testid(TestidPrefix.INTERACTION, 'drag-item', id),
  dropZone: (id: string) => testid(TestidPrefix.INTERACTION, 'drop-zone', id),
  tapContainer: testid(TestidPrefix.INTERACTION, 'tap-container'),
  tapOption: (id: string) => testid(TestidPrefix.INTERACTION, 'tap-option', id),
  tapOptionSelected: (id: string) => testid(TestidPrefix.INTERACTION, 'tap-option', id, 'selected'),
  inputContainer: testid(TestidPrefix.INTERACTION, 'input-container'),
  inputField: testid(TestidPrefix.INTERACTION, 'input-field'),
  inputSubmit: testid(TestidPrefix.INTERACTION, 'input-submit-button'),
} as const;
```

### 7.2 自定义渲染函数

```typescript
// src/test/render.tsx
import React, { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';

// 自定义 render，包含常用 Provider
function customRender(
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) {
  return render(ui, { 
    wrapper: ({ children }) => (
      <BrowserRouter>
        {children}
      </BrowserRouter>
    ),
    ...options 
  });
}

// 重新导出
export * from '@testing-library/react';
export { customRender as render };
```

---

## 8. 测试注意事项

### 8.1 不要依赖的细节

- 不依赖 CSS 类名
- 不依赖内部组件状态
- 不依赖 DOM 结构细节（仅使用 data-testid）
- 不依赖动画时长

### 8.2 异步处理

```typescript
// 等待元素出现
await page.waitForSelector('[data-testid="session-container"]');

// 等待动画完成
await page.waitForTimeout(500);

// 等待 API 完成
await expect(page.locator('[data-testid="loading-spinner"]')).not.toBeVisible();
```

### 8.3 可访问性

`data-testid` 不替代可访问性属性，应同时提供：

```tsx
<button
  data-testid="session-submit-button"
  aria-label="提交答案"
  aria-describedby="submit-help"
>
  提交
</button>
```

---

## 9. 附录：完整 Testid 速查表

### 9.1 页面级

| Testid | 页面 | 元素 |
|--------|------|------|
| `home-container` | 首页 | 主容器 |
| `home-start-button` | 首页 | 开始学习按钮 |
| `home-progress-button` | 首页 | 学习进度按钮 |
| `home-settings-button` | 首页 | 设置按钮 |
| `select-container` | 选择页 | 主容器 |
| `select-content-item-{id}` | 选择页 | 内容项 |
| `session-container` | 会话页 | 主容器 |
| `session-progress-bar` | 会话页 | 进度条 |
| `session-step-content` | 会话页 | 步骤内容 |
| `profile-container` | 画像页 | 主容器 |
| `profile-overall-score` | 画像页 | 总体分数 |
| `settings-container` | 设置页 | 主容器 |

### 9.2 组件级

| Testid | 组件 | 元素 |
|--------|------|------|
| `viz-pie-chart` | 圆饼图 | 容器 |
| `viz-bar-chart` | 条形图 | 容器 |
| `viz-fraction-bar` | 分数条 | 容器 |
| `interaction-drag-item-{id}` | 拖拽 | 拖拽项 |
| `interaction-drop-zone-{id}` | 拖拽 | 放置区 |
| `interaction-tap-option-{id}` | 点击 | 选项 |
| `interaction-input-field` | 输入 | 输入框 |
| `feedback-correct` | 反馈 | 正确反馈 |
| `feedback-incorrect` | 反馈 | 错误反馈 |

---

*最后更新：2026-10-06*
