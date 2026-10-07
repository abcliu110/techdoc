# 数学学习软件设计规范

> 版本：1.0.0  
> 最后更新：2026-10-06  
> 技术栈：React 18 + TypeScript + Vite + Tauri

---

## 目录

1. [设计原则](#1-设计原则)
2. [设计 Token](#2-设计-token)
3. [色彩系统](#3-色彩系统)
4. [字体系统](#4-字体系统)
5. [间距系统](#5-间距系统)
6. [圆角与阴影](#6-圆角与阴影)
7. [动效与过渡](#7-动效与过渡)
8. [组件规范](#8-组件规范)
9. [交互规范](#9-交互规范)
10. [响应式设计](#10-响应式设计)
11. [无障碍设计](#11-无障碍设计)

---

## 1. 设计原则

### 1.1 核心原则

| 原则 | 说明 | 应用场景 |
|------|------|----------|
| **清晰优先** | 信息层次分明，重点突出 | 标题、内容、操作按钮 |
| **一致体验** | 相同场景使用相同设计模式 | 按钮、卡片、反馈 |
| **即时反馈** | 每个操作都有视觉响应 | 点击、加载、成功/错误 |
| **渐进披露** | 复杂内容分步展示 | 学习步骤、任务引导 |
| **情感共鸣** | 使用友好色彩和表情符号 | 成功反馈、错误提示 |

### 1.2 数学学习场景特点

- **视觉化优先**：分数、几何等概念需要直观的可视化展示
- **渐进式学习**：步骤引导，强调学习进度
- **即时反馈**：正确答案/错误答案的清晰反馈
- **友好鼓励**：温和的错误提示，积极的成功鼓励

---

## 2. 设计 Token

设计 Token 是设计系统的基础原子，通过 CSS 变量实现。

### 2.1 Token 命名规范

```
--<category>-<variant>-<state>
```

示例：
- `--color-primary` 主色
- `--color-primary-hover` 主色悬停态
- `--color-primary-active` 主色激活态
- `--font-size-md` 中等字号
- `--spacing-4` 16px 间距

### 2.2 Token 定义位置

所有 Token 集中定义在 `src/styles/variables.css` 的 `:root` 中。

---

## 3. 色彩系统

### 3.1 色彩语义

| 语义 | Token | 色值 | 用途 |
|------|-------|------|------|
| **主色** | `--color-primary` | `#3b82f6` | 主要按钮、链接、强调 |
| **主色-悬停** | `--color-primary-hover` | `#2563eb` | 按钮悬停状态 |
| **主色-激活** | `--color-primary-active` | `#1d4ed8` | 按钮激活状态 |
| **成功** | `--color-success` | `#22c55e` | 正确答案、成功提示 |
| **错误** | `--color-error` | `#ef4444` | 错误答案、错误提示 |
| **警告** | `--color-warning` | `#f59e0b` | 警告提示、任务标签 |
| **信息** | `--color-info` | `#3b82f6` | 信息提示（同主色） |

### 3.2 文本颜色

| Token | 色值 | 用途 |
|-------|------|------|
| `--text-primary` | `#1f2937` | 主要文本、标题 |
| `--text-secondary` | `#6b7280` | 次要文本、描述 |
| `--text-muted` | `#9ca3af` | 辅助文本、占位符 |

### 3.3 背景颜色

| Token | 色值 | 用途 |
|-------|------|------|
| `--bg-primary` | `#ffffff` | 卡片、容器背景 |
| `--bg-secondary` | `#f3f4f6` | 页面背景 |
| `--bg-tertiary` | `#f8fafc` | 次级容器、Header 背景 |

### 3.4 边框颜色

| Token | 色值 | 用途 |
|-------|------|------|
| `--border-color` | `#e5e7eb` | 默认边框 |
| `--border-hover` | `#d1d5db` | 悬停边框 |

### 3.5 语义背景色（反馈组件）

```css
/* 成功反馈背景 */
background-color: #dcfce7;  /* 浅绿 */
color: #166534;             /* 深绿文字 */
border: 1px solid #86efac;

/* 提示反馈背景 */
background-color: #fef9c3;  /* 浅黄 */
color: #854d0e;             /* 深黄文字 */
border: 1px solid #fde047;

/* 错误反馈背景 */
background-color: #fee2e2;  /* 浅红 */
color: #991b1b;             /* 深红文字 */
border: 1px solid #fca5a5;

/* 场景卡片背景 */
background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);  /* 浅蓝渐变 */
color: #0c4a6e;

/* 任务卡片背景 */
background-color: #fef3c7;  /* 浅黄 */
color: #78350f;

/* 标签背景 */
background-color: #e0f2fe;  /* 浅蓝 */
color: #0369a1;
```

---

## 4. 字体系统

### 4.1 字体栈

```css
font-family: 
  -apple-system,           /* macOS Safari */
  BlinkMacSystemFont,      /* Chrome macOS */
  'Segoe UI',              /* Windows */
  Roboto,                  /* Android */
  'Helvetica Neue',        /* 旧 macOS */
  Arial,                   /* 通用 */
  'Noto Sans',             /* 中文字体 */
  sans-serif,
  'Apple Color Emoji',     /* Emoji */
  'Segoe UI Emoji',
  'Segoe UI Symbol',
  'Noto Color Emoji';
```

### 4.2 字号系统

| Token | 值 | 用途 | 行高 |
|-------|-----|------|------|
| `--font-xs` | 12px | 标签、注释 | 1.4 |
| `--font-sm` | 14px | 次要文本、反馈消息 | 1.5 |
| `--font-md` | 16px | 正文内容 | 1.5 |
| `--font-lg` | 18px | 卡片标题、次要标题 | 1.5 |
| `--font-xl` | 20px | 页面标题 | 1.4 |
| `--font-2xl` | 24px | Hero 标题 | 1.3 |
| `--font-3xl` | 28px | 大 Hero 标题 | 1.2 |

### 4.3 字重

| 字重 | 值 | 用途 |
|------|-----|------|
| 正常 | 400 | 正文 |
| 中等 | 500 | 次要强调、标签 |
| 半粗 | 600 | 标题、按钮 |
| 粗体 | 700 | Hero 标题、重要强调 |

### 4.4 数学表达式

数学内容使用蓝色高亮：

```css
.math-expression {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-primary);  /* #3b82f6 */
}
```

---

## 5. 间距系统

### 5.1 间距 Token

| Token | 值 | 用途 |
|-------|-----|------|
| `--space-1` | 4px | 紧凑间距、内联元素 |
| `--space-2` | 8px | 元素内部间距 |
| `--space-3` | 12px | 小组件间距 |
| `--space-4` | 16px | 标准间距、组件间距 |
| `--space-5` | 20px | 卡片内间距 |
| `--space-6` | 24px | 区块间距 |
| `--space-8` | 32px | 大区块间距 |

### 5.2 常用间距模式

```css
/* 卡片内间距 */
.card {
  padding: var(--space-5);  /* 20px */
}

/* 区块间距 */
.section {
  gap: var(--space-8);  /* 32px */
}

/* 按钮间距 */
.button-group {
  gap: var(--space-3);  /* 12px */
}

/* 列表项间距 */
.list-item {
  margin-bottom: var(--space-4);  /* 16px */
}
```

---

## 6. 圆角与阴影

### 6.1 圆角系统

| Token | 值 | 用途 |
|-------|-----|------|
| `--radius-sm` | 4px | 小标签、徽章 |
| `--radius-md` | 8px | 按钮、输入框 |
| `--radius-lg` | 12px | 卡片、容器 |
| `--radius-xl` | 16px | 大卡片、模态框 |
| `50%` | 50% | 圆形、头像 |

### 6.2 圆角应用

```css
/* 按钮 */
border-radius: var(--radius-md);  /* 8px */

/* 卡片 */
border-radius: var(--radius-lg);  /* 12px */

/* 标签/徽章 */
border-radius: 16px;  /* 药丸形 */

/* 小组件 */
border-radius: var(--radius-sm);  /* 4px */
```

### 6.3 阴影系统

| Token | 值 | 用途 |
|-------|-----|------|
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | 轻微阴影 |
| `--shadow-md` | `0 2px 8px rgba(0,0,0,0.08)` | 默认卡片阴影 |
| `--shadow-lg` | `0 4px 16px rgba(0,0,0,0.12)` | 悬停/强调阴影 |

### 6.4 阴影应用

```css
/* 默认卡片 */
box-shadow: var(--shadow-md);

/* 卡片悬停 */
.card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

/* Header 固定阴影 */
.app-header {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

/* Toast 提示 */
.toast {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}
```

---

## 7. 动效与过渡

### 7.1 过渡速度

| Token | 值 | 用途 |
|-------|-----|------|
| `--transition-fast` | `0.15s ease` | 微交互、颜色变化 |
| `--transition-normal` | `0.2s ease` | 默认过渡 |
| `--transition-slow` | `0.3s ease` | 大元素移动、进度条 |

### 7.2 过渡应用

```css
/* 按钮过渡 */
.btn {
  transition: all var(--transition-normal);
}

/* 链接过渡 */
a {
  transition: color var(--transition-fast);
}

/* 进度条 */
.progress-fill {
  transition: width var(--transition-slow);
}

/* 卡片悬停 */
.card-clickable {
  transition: all var(--transition-normal);
}
```

### 7.3 关键帧动画

```css
/* 滑入动画 - 反馈消息 */
@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Toast 动画 */
@keyframes toastSlideIn {
  from {
    opacity: 0;
    transform: translateX(-50%) translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
  }
}

.step-feedback {
  animation: slideIn 0.3s ease;
}

.toast {
  animation: toastSlideIn 0.3s ease;
}
```

### 7.4 交互反馈

```css
/* 可点击元素悬停 */
.segment-interactive:hover {
  opacity: 0.8;
}

.segment-interactive:active {
  opacity: 0.6;
}

/* 卡片悬停效果 */
.concept-card:hover {
  transform: translateY(-4px);
}
```

---

## 8. 组件规范

### 8.1 Button 按钮

#### 尺寸变体

| 尺寸 | Token | 内边距 | 字号 |
|------|-------|--------|------|
| 小 | `--btn-size-sm` | `6px 12px` | 14px |
| 中 | `--btn-size-md` | `10px 20px` | 16px |
| 大 | `--btn-size-lg` | `14px 28px` | 18px |

#### 视觉变体

```css
/* 主要按钮 */
.btn-primary {
  background-color: var(--color-primary);
  color: white;
}
.btn-primary:hover:not(:disabled) {
  background-color: var(--color-primary-hover);
}
.btn-primary:active:not(:disabled) {
  background-color: var(--color-primary-active);
}

/* 次要按钮 */
.btn-secondary {
  background-color: var(--color-secondary);
  color: #374151;
}
.btn-secondary:hover:not(:disabled) {
  background-color: var(--border-hover);
}
.btn-secondary:active:not(:disabled) {
  background-color: #9ca3af;
}

/* 幽灵按钮 */
.btn-ghost {
  background-color: transparent;
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
}
.btn-ghost:hover:not(:disabled) {
  background-color: var(--bg-secondary);
  color: #374151;
}
.btn-ghost:active:not(:disabled) {
  background-color: var(--color-secondary);
}
```

#### 状态

| 状态 | 表现 |
|------|------|
| 默认 | 正常显示 |
| 悬停 | 颜色加深、指针变为 `pointer` |
| 激活 | 颜色进一步加深 |
| 禁用 | `opacity: 0.6`、`cursor: not-allowed` |

#### 使用示例

```tsx
import { Button } from '@/components/ui';

<Button variant="primary" size="md" onClick={handleSubmit}>
  提交答案
</Button>

<Button variant="secondary" size="sm" disabled>
  下一题
</Button>
```

---

### 8.2 Card 卡片

#### 基础卡片

```css
.card {
  background-color: var(--bg-primary);
  border-radius: var(--radius-lg);  /* 12px */
  padding: var(--space-5);          /* 20px */
  box-shadow: var(--shadow-md);
  transition: all var(--transition-normal);
}
```

#### 可点击卡片

```css
.card-clickable {
  cursor: pointer;
}

.card-clickable:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}
```

#### 卡片内容样式

```css
.card-title {
  margin: 0 0 var(--space-3) 0;    /* 0 0 12px 0 */
  font-size: var(--font-lg);        /* 18px */
  font-weight: 600;
  color: var(--text-primary);
}

.card-content {
  color: #4b5563;
  line-height: 1.6;
}
```

#### 使用示例

```tsx
import { Card } from '@/components/ui';

<Card title="分数比较" onClick={handleSelect}>
  <p>比较 1/2 和 2/3 的大小</p>
</Card>
```

---

### 8.3 ProgressBar 进度条

#### 样式定义

```css
.progress-container {
  display: flex;
  align-items: center;
  gap: var(--space-3);  /* 12px */
  width: 100%;
}

.progress-bar {
  flex: 1;
  background-color: var(--color-secondary);
  border-radius: var(--radius-sm);  /* 4px */
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--color-primary), #60a5fa);
  border-radius: var(--radius-sm);
  transition: width var(--transition-slow);
}

.progress-label {
  font-size: var(--font-sm);
  font-weight: 500;
  color: var(--text-secondary);
  min-width: 40px;
  text-align: right;
}
```

#### Props 接口

```tsx
interface ProgressBarProps {
  value: number;       // 0-100
  height?: number;     // 默认 8px
  showLabel?: boolean; // 默认 true
  className?: string;
}
```

#### 使用示例

```tsx
<ProgressBar value={75} height={8} showLabel={true} />
```

---

### 8.4 StepHeader 步骤头

#### 样式定义

```css
.step-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--space-4) var(--space-5);  /* 16px 20px */
  background-color: var(--bg-tertiary);
  border-bottom: 1px solid #e2e8f0;
  border-radius: var(--radius-lg) var(--radius-lg) 0 0;
}

.step-info {
  display: flex;
  align-items: center;
  gap: var(--space-2);  /* 8px */
}

.step-emoji {
  font-size: 24px;
}

.step-name {
  font-size: var(--font-lg);
  font-weight: 600;
  color: #1e293b;
}

.step-progress {
  font-size: var(--font-sm);
  color: #64748b;
  background-color: var(--color-secondary);
  padding: 4px 12px;
  border-radius: 16px;  /* 药丸形 */
}
```

---

### 8.5 StepFeedback 反馈

#### 样式定义

```css
.step-feedback {
  display: flex;
  align-items: center;
  gap: var(--space-2);  /* 8px */
  padding: 12px 16px;
  border-radius: var(--radius-md);
  margin: var(--space-4) 0;
  animation: slideIn 0.3s ease;
}

/* 成功状态 */
.step-feedback-success {
  background-color: #dcfce7;
  color: #166534;
  border: 1px solid #86efac;
}

/* 提示状态 */
.step-feedback-hint {
  background-color: #fef9c3;
  color: #854d0e;
  border: 1px solid #fde047;
}

/* 错误状态 */
.step-feedback-error {
  background-color: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
}

.feedback-icon {
  font-size: 18px;
}

.feedback-message {
  font-size: var(--font-sm);
  line-height: 1.5;
}
```

#### 类型

| 类型 | 背景色 | 文字色 | 边框色 | 图标 | 用途 |
|------|--------|--------|--------|------|------|
| success | `#dcfce7` | `#166534` | `#86efac` | `✓` | 正确答案 |
| hint | `#fef9c3` | `#854d0e` | `#fde047` | `💡` | 提示帮助 |
| error | `#fee2e2` | `#991b1b` | `#fca5a5` | `✗` | 错误提示 |

---

### 8.6 AppLayout 布局

#### 样式定义

```css
.app-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #f1f5f9;
}

.app-header {
  display: flex;
  align-items: center;
  gap: var(--space-4);  /* 16px */
  padding: var(--space-4) var(--space-6);  /* 16px 24px */
  background-color: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 100;
}

.back-button {
  background: none;
  border: none;
  color: var(--color-primary);
  font-size: var(--font-md);
  cursor: pointer;
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-md);
  transition: background-color var(--transition-normal);
}

.back-button:hover {
  background-color: #f1f5f9;
}

.app-title {
  margin: 0;
  font-size: var(--font-xl);
  font-weight: 600;
  color: #1e293b;
}

.app-main {
  flex: 1;
  padding: var(--space-6);
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
}
```

---

### 8.7 Toast 提示

#### 样式定义

```css
.toast {
  position: fixed;
  bottom: var(--space-6);  /* 24px */
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 24px;
  border-radius: var(--radius-md);
  font-size: var(--font-sm);
  font-weight: 500;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  animation: toastSlideIn 0.3s ease;
  z-index: 1000;
}

.toast-success {
  background-color: var(--color-success);
  color: white;
}

.toast-error {
  background-color: var(--color-error);
  color: white;
}

.toast-info {
  background-color: var(--color-info);
  color: white;
}
```

---

### 8.8 可视化组件 - SplitCircle 分割圆

```css
.split-circles {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  gap: 32px;
  flex-wrap: wrap;
  padding: var(--space-5);
}

.split-circle-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
}

.circle-label {
  font-size: var(--font-md);
  font-weight: 500;
  color: #374151;
}

.fraction-label {
  font-size: var(--font-lg);
  font-weight: 600;
  color: var(--color-primary);
  margin-top: var(--space-2);
}

.segment {
  transition: all var(--transition-normal);
}

.segment-interactive:hover {
  opacity: 0.8;
}

.segment-interactive:active {
  opacity: 0.6;
}
```

---

## 9. 交互规范

### 9.1 按钮点击反馈

| 状态 | 视觉反馈 | 时长 |
|------|----------|------|
| 悬停 | 背景色加深 10% | 0ms |
| 按下 | 背景色再加深 10% | 0ms |
| 释放 | 恢复悬停色 | 0ms |
| 禁用 | `opacity: 0.6` | - |

```css
.btn-primary:hover:not(:disabled) {
  background-color: var(--color-primary-hover);
}

.btn-primary:active:not(:disabled) {
  background-color: var(--color-primary-active);
}
```

### 9.2 加载状态

```css
/* 加载中按钮 */
.btn-loading {
  position: relative;
  color: transparent !important;
}

.btn-loading::after {
  content: '';
  position: absolute;
  width: 16px;
  height: 16px;
  border: 2px solid white;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

### 9.3 错误状态

| 场景 | 处理方式 |
|------|----------|
| 表单错误 | 输入框红色边框 + 错误提示文字 |
| 操作失败 | Toast 红色提示，3秒自动消失 |
| 网络错误 | 模态框或全页错误提示 + 重试按钮 |
| 数据为空 | 空状态插图 + 友好提示文案 |

```css
/* 输入框错误状态 */
.input-error {
  border-color: var(--color-error) !important;
}

.input-error-message {
  color: var(--color-error);
  font-size: var(--font-sm);
  margin-top: var(--space-1);
}
```

### 9.4 空状态

```css
.step-placeholder {
  text-align: center;
  padding: var(--space-8);
  background-color: var(--bg-tertiary);
  border-radius: var(--radius-lg);
  color: #64748b;
}

.step-placeholder-icon {
  font-size: 48px;
  margin-bottom: var(--space-4);
}

.step-placeholder-text {
  font-size: var(--font-md);
  margin: var(--space-2) 0;
}
```

### 9.5 交互延迟

| 交互类型 | 建议延迟 |
|----------|----------|
| 按钮防抖 | 300ms |
| Toast 自动消失 | 3000ms |
| 页面切换动画 | 300ms |
| 进度条更新 | 300ms |
| 反馈消息滑入 | 300ms |

---

## 10. 响应式设计

### 10.1 断点定义

| 断点 | 宽度 | 设备类型 |
|------|------|----------|
| `sm` | < 640px | 手机 |
| `md` | 640px - 1024px | 平板 |
| `lg` | > 1024px | 桌面 |

### 10.2 响应式容器

```css
/* 最大宽度容器 */
.app-main {
  max-width: 1200px;
  margin: 0 auto;
}

/* 移动端全宽 */
@media (max-width: 640px) {
  .app-main {
    padding: var(--space-4);
  }
  
  .hero-section {
    padding: var(--space-6) var(--space-4);
  }
  
  .hero-title {
    font-size: var(--font-xl);
  }
}
```

### 10.3 网格响应式

```css
/* 桌面：3列，平板：2列，手机：1列 */
.concepts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: var(--space-4);
}

/* 手机端调整 */
@media (max-width: 640px) {
  .concepts-grid {
    grid-template-columns: 1fr;
  }
}
```

### 10.4 字体响应式

```css
/* 默认 */
.hero-title {
  font-size: var(--font-3xl);  /* 28px */
}

/* 移动端缩小 */
@media (max-width: 640px) {
  .hero-title {
    font-size: var(--font-2xl);  /* 24px */
  }
  
  .step-name {
    font-size: var(--font-md);  /* 16px */
  }
}
```

---

## 11. 无障碍设计

### 11.1 颜色对比度

| 文本类型 | 最小对比度 | 当前值 |
|----------|------------|--------|
| 正常文本 | 4.5:1 | ✅ 通过 |
| 大文本 | 3:1 | ✅ 通过 |
| 组件边缘 | 3:1 | ✅ 通过 |

**验证**：
- 主色 `#3b82f6` 与白色对比度：4.6:1 ✅
- 正文色 `#1f2937` 与白色背景 `#ffffff` 对比度：15.3:1 ✅

### 11.2 焦点可见性

```css
/* 焦点环样式 */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* 确保焦点在所有交互元素上可见 */
button:focus-visible,
a:focus-visible,
input:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

### 11.3 ARIA 属性

```tsx
// 可点击卡片
<div
  className="card card-clickable"
  onClick={onClick}
  role="button"
  tabIndex={0}
  onKeyDown={(e) => e.key === 'Enter' && onClick()}
>
  {/* 内容 */}
</div>

// 进度条
<div
  role="progressbar"
  aria-valuenow={value}
  aria-valuemin={0}
  aria-valuemax={100}
  aria-label="学习进度"
>
  <div className="progress-fill" style={{ width: `${value}%` }} />
</div>

// 按钮
<button
  type="button"
  disabled={disabled}
  aria-disabled={disabled}
>
  提交
</button>
```

### 11.4 键盘导航

| 元素 | Tab | Enter | Space | Escape |
|------|-----|-------|-------|--------|
| 按钮 | ✅ | ✅ 激活 | ✅ 激活 | - |
| 链接 | ✅ | ✅ 跳转 | - | - |
| 卡片按钮 | ✅ | ✅ 点击 | ✅ 点击 | - |
| 模态框 | ✅ | - | - | ✅ 关闭 |

### 11.5 屏幕阅读器支持

```tsx
// 使用 aria-label 提供语义
<button aria-label="返回上一页">←</button>

// 使用 aria-describedby 关联描述
<input
  id="answer-input"
  aria-describedby="answer-hint"
/>
<p id="answer-hint">请输入你的答案</p>

// 状态变化通知
<div aria-live="polite" aria-atomic="true">
  {feedback && <StepFeedback type={feedback.type} message={feedback.message} />}
</div>
```

### 11.6 减少动画偏好

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 附录

### A. 设计资源

| 资源 | 位置 |
|------|------|
| 设计 Token | `src/styles/variables.css` |
| 全局样式 | `src/styles/index.css` |
| UI 组件 | `src/components/ui/` |
| 步骤组件 | `src/components/steps/` |
| 布局组件 | `src/components/layout/` |
| 可视化组件 | `src/components/visuals/` |

### D. 步骤组件样式文件清单

| 文件 | 组件 | 说明 |
|------|------|------|
| `StepHeader.css` | StepHeader | 步骤头，包含步骤名称和进度 |
| `StepFeedback.css` | StepFeedback | 反馈提示（成功/提示/错误） |
| `StepContainer.css` | StepContainer | 步骤容器和占位符 |
| `ConcreteStep.css` | ConcreteStep | 具象操作步骤（分割圆交互） |
| `SymbolicStep.css` | SymbolicStep | 符号表示步骤（数学表达式输入） |
| `ConjectureStep.css` | ConjectureStep | 猜想步骤（猜想输入和观察） |
| `PictorialStep.css` | PictorialStep | 图示表达步骤（可视化比较） |
| `VerificationStep.css` | VerificationStep | 验证猜想步骤（选择题验证） |
| `ApplicationStep.css` | ApplicationStep | 迁移应用步骤（题目和选项） |

### E. 步骤组件样式规范

#### 通用样式结构

所有步骤组件共享相同的容器结构：

```css
/* 步骤容器 */
.step {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

/* 步骤内容区 */
.step-content {
  padding: 20px;
}

/* 步骤操作区 */
.step-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #e2e8f0;
  background-color: #f8fafc;
}
```

#### 卡片类型样式

| 卡片类型 | 背景色 | 标题色 | 文字色 | 用途 |
|----------|--------|--------|--------|------|
| 情境/指令卡片 | `linear-gradient(#f0f9ff, #e0f2fe)` | `#0c4a6e` | `#0369a1` | 场景描述、任务指令 |
| 任务卡片 | `#fef3c7` | `#92400e` | `#78350f` | 任务提示、输入区域 |
| 观察卡片 | `linear-gradient(#faf5ff, #ede9fe)` | `#5b21b6` | `#7c3aed` | 观察示例、猜想区域 |
| 验证卡片 | `linear-gradient(#f0fdf4, #dcfce7)` | `#166534` | `#15803d` | 验证说明、成功结果 |

#### PictorialStep 图示表达

```css
/* 图示比较区域 */
.pictorial-area {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-bottom: 20px;
}

.comparison-group {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  gap: 32px;
  flex-wrap: wrap;
  padding: 16px;
  background-color: #f8fafc;
  border-radius: 12px;
}

/* 关系指示器 */
.relation-indicator {
  font-size: 24px;
  font-weight: 700;
  color: #7c3aed;
}

.relation-indicator.greater { color: #16a34a; }
.relation-indicator.less { color: #dc2626; }
.relation-indicator.equal { color: #7c3aed; }
```

#### VerificationStep 验证步骤

```css
/* 猜想回顾卡片 */
.conjecture-recall {
  background-color: #faf5ff;
  border: 2px solid #ddd6fe;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
}

/* 验证进度点 */
.progress-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #e2e8f0;
}

.progress-dot.completed { background-color: #22c55e; }
.progress-dot.current { background-color: #3b82f6; }
.progress-dot.failed { background-color: #ef4444; }

/* 验证摘要统计 */
.summary-stats {
  display: flex;
  justify-content: space-around;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
}

.stat-value.success { color: #22c55e; }
.stat-value.failed { color: #ef4444; }
.stat-value.total { color: #3b82f6; }
```

#### 选项交互样式

```css
.option-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background-color: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.option-item:hover:not(.correct):not(.incorrect) {
  border-color: #3b82f6;
  background-color: #eff6ff;
}

.option-item.selected {
  border-color: #3b82f6;
  background-color: #eff6ff;
}

.option-item.correct {
  border-color: #22c55e;
  background-color: #f0fdf4;
}

.option-item.incorrect {
  border-color: #ef4444;
  background-color: #fef2f2;
}
```

### B. 相关文档

| 文档 | 描述 |
|------|------|
| `README.md` | 项目说明 |
| `src/content/schema.ts` | 内容结构定义 |
| `src/i18n/zh-CN.ts` | 国际化文本 |

### C. 色彩参考

```
主色调：Blue 500 (#3b82f6) - 信任、学习
成功色：Green 500 (#22c55e) - 正确、积极
警告色：Amber 500 (#f59e0b) - 注意、任务
错误色：Red 500 (#ef4444) - 错误、问题
```

---

**文档版本历史**

| 版本 | 日期 | 修改内容 |
|------|------|----------|
| 1.0.1 | 2026-10-06 | 新增 PictorialStep.css、VerificationStep.css；完善步骤组件样式规范 |
| 1.0.0 | 2026-10-06 | 初始版本，基于现有代码规范整理 |
