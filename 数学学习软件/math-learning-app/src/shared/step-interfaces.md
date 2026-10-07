# 步骤组件 Props 接口规范

> 版本：v1.0.0
> 更新日期：2026-10-06
> 状态：正式版

## 概述

本文档定义每个步骤类型组件期望接收的 `content` 字段结构。所有步骤组件共享通用的 Props 接口，但通过 `StepContent` 联合类型实现类型安全的多态。

---

## 通用 Props 接口

所有步骤组件实现统一的 `StepComponentProps` 接口：

```typescript
interface StepComponentProps {
  /** 步骤内容（根据步骤类型不同而不同） */
  content: StepContent;
  /** 步骤名称 */
  stepName: string;
  /** 步骤索引（从1开始） */
  stepIndex: number;
  /** 总步骤数（可选，用于显示进度） */
  totalSteps?: number;
  /** 提示层级数组 */
  hintLevels: string[];
  /** 完成回调，传递步骤数据 */
  onComplete: (data: Record<string, unknown>) => void;
  /** 请求提示回调（可选） */
  onHint?: () => void;
  /** 步骤完成状态（可选，外部控制） */
  isCompleted?: boolean;
  /** 当前提示级别（可选，外部控制） */
  currentHintLevel?: number;
}
```

---

## ConcreteStep 具象操作步骤

### 期望的 content 类型

```typescript
interface ConcreteContent {
  type: 'concrete';
  /** 场景信息 */
  scenario: {
    /** 场景标题 */
    title: string;
    /** 场景描述 */
    description: string;
    /** 表情符号 */
    emoji: string;
  };
  /** 交互信息 */
  interaction: {
    /** 交互类型 */
    kind: 'drag' | 'tap' | 'draw' | 'split' | 'select';
    /** 任务目标描述 */
    target: string;
    /** 可视化类型 */
    visualType: string;
    /** 可视化配置（取决于 visualType） */
    visualConfig: Record<string, unknown>;
  };
}
```

### visualConfig 字段（visualType: "split-circle"）

```typescript
interface SplitCircleVisualConfig {
  /** 圆形数组 */
  circles?: Array<{
    /** 分母（分割份数） */
    denominator: number;
    /** 高亮的扇区索引数组 */
    highlighted: number[];
  }>;
}
```

### 示例 JSON

```json
{
  "type": "concrete",
  "scenario": {
    "title": "分蛋糕",
    "description": "小明和小红各有一个蛋糕...",
    "emoji": "🎂"
  },
  "interaction": {
    "kind": "split",
    "target": "在两个圆上分别表示出 3/4 和 2/3",
    "visualType": "split-circle",
    "visualConfig": {
      "circles": [
        { "denominator": 4, "highlighted": [0, 1, 2] },
        { "denominator": 3, "highlighted": [0, 1] }
      ]
    }
  }
}
```

### 支持的 visualType

| visualType | 说明 | visualConfig 关键字段 |
|------------|------|----------------------|
| `split-circle` | 分割圆 | `circles[]` |
| `drag-item` | 拖拽项目 | `items[]`, `dropZones[]` |
| `tap-area` | 点击区域 | `areas[]` |
| `draw-path` | 绘制路径 | `paths[]`, `tools[]` |

---

## PictorialStep 图示表达步骤

### 期望的 content 类型

```typescript
interface PictorialContent {
  type: 'pictorial';
  /** 任务描述 */
  task: string;
  /** 可视化类型 */
  visualType: string;
  /** 可视化配置 */
  visualConfig: Record<string, unknown>;
  /** 输出格式 */
  outputFormat: 'draw' | 'select' | 'arrange';
}
```

### visualConfig 字段（visualType: "fraction-bar"）

```typescript
interface FractionBarVisualConfig {
  /** 分数数组 */
  fractions?: Array<{
    id: string;
    /** 分子 */
    numerator: number;
    /** 分母 */
    denominator: number;
    /** 标签（可选） */
    label?: string;
    /** 颜色（可选） */
    color?: string;
  }>;
  /** 显示单位刻度 */
  showUnit?: boolean;
  /** 对齐方式 */
  alignment?: 'bottom' | 'top' | 'center';
}
```

### visualConfig 字段（outputFormat: "draw"）

```typescript
interface DrawVisualConfig {
  /** 可用绘制元素 */
  availableItems?: string[];
}
```

### visualConfig 字段（outputFormat: "select"）

```typescript
interface SelectVisualConfig {
  /** 可选项 */
  availableItems?: string[];
}
```

### visualConfig 字段（outputFormat: "arrange"）

```typescript
interface ArrangeVisualConfig {
  /** 可排列项 */
  availableItems?: string[];
}
```

### 示例 JSON

```json
{
  "type": "pictorial",
  "task": "观察下面的图形表示，判断 3/5 和 2/3 哪个更大。",
  "visualType": "fraction-bar",
  "visualConfig": {
    "fractions": [
      { "id": "f1", "numerator": 3, "denominator": 5, "label": "3/5", "color": "#4CAF50" },
      { "id": "f2", "numerator": 2, "denominator": 3, "label": "2/3", "color": "#2196F3" }
    ],
    "showUnit": true,
    "alignment": "bottom"
  },
  "outputFormat": "select"
}
```

### 支持的 visualType

| visualType | 说明 | 适用 outputFormat |
|------------|------|-------------------|
| `fraction-bar` | 分数条形图 | select |
| `fraction-circle` | 分数圆形图 | draw, select |
| `number-line` | 数轴 | select, arrange |
| `area-model` | 面积模型 | draw |

---

## SymbolicStep 符号表示步骤

### 期望的 content 类型

```typescript
interface SymbolicContent {
  type: 'symbolic';
  /** 指令描述 */
  instruction: string;
  /** 输入类型 */
  inputType: 'fraction' | 'expression' | 'equation';
  /** 期望答案（单个或多个等价答案） */
  expectedAnswer: string | string[];
  /** 等价性规则（可选） */
  equivalenceRules?: EquivalenceRule[];
}
```

### EquivalenceRule 等价规则

```typescript
interface EquivalenceRule {
  /** 规则名称 */
  name: string;
  /** 匹配模式（正则表达式） */
  pattern: string;
  /** 替换文本 */
  replacement: string;
}
```

### 示例 JSON（分数输入模式）

```json
{
  "type": "symbolic",
  "instruction": "请输入 3/4 和 2/3 比较的结果",
  "inputType": "fraction",
  "expectedAnswer": ["3/4 > 2/3", "3/4更大", "3/4 大于 2/3"]
}
```

### 示例 JSON（表达式输入模式）

```json
{
  "type": "symbolic",
  "instruction": "用通分或交叉相乘比较分数大小",
  "inputType": "expression",
  "expectedAnswer": "3/4 > 2/3",
  "method": "通分",
  "steps": [
    "找到最小公倍数：4和3的最小公倍数是12",
    "通分：3/4 = 9/12，2/3 = 8/12",
    "比较：9/12 > 8/12，所以 3/4 > 2/3"
  ]
}
```

### inputType 对比

| inputType | 输入控件 | 说明 |
|-----------|----------|------|
| `fraction` | 两个输入框（分子/分母） | 分数形式输入 |
| `expression` | 单个文本框 | 表达式输入，如 `3/4 + 1/2` |
| `equation` | 单个文本框 | 方程输入，如 `x = 3/4` |

---

## ConjectureStep 猜想步骤

### 期望的 content 类型

```typescript
interface ConjectureContent {
  type: 'conjecture';
  /** 观察提示语 */
  observationPrompt: string;
  /** 观察示例数组 */
  examples: ObservationExample[];
  /** 猜想提示语 */
  conjecturePrompt: string;
}
```

### ObservationExample 观察示例

```typescript
interface ObservationExample {
  /** 输入（数学问题或条件） */
  input: string;
  /** 输出（结果或答案） */
  output: string;
}
```

### 示例 JSON

```json
{
  "type": "conjecture",
  "observationPrompt": "观察以下分数对：1/2 vs 2/4，3/5 vs 6/10，2/3 vs 4/6",
  "examples": [
    { "input": "1/2 vs 2/4", "output": "相等" },
    { "input": "3/5 vs 6/10", "output": "相等" },
    { "input": "2/3 vs 4/6", "output": "相等" }
  ],
  "conjecturePrompt": "你发现了什么规律？用你自己的话说一说。"
}
```

### 交互行为

- 示例默认被遮盖，点击后显示
- 用户需要在文本框中输入猜想内容
- 提交后记录猜想文本

---

## VerificationStep 验证步骤

### 期望的 content 类型

```typescript
interface VerificationContent {
  type: 'verification';
  /** 指令描述 */
  instruction: string;
  /** 待验证的猜想（可选） */
  conjectureToVerify?: string;
  /** 假设（可选） */
  hypothesis?: string;
  /** 测试用例数组 */
  testCases: VerificationTestCase[];
  /** 验证提示语（可选） */
  verificationPrompt?: string;
  /** 反馈配置（可选） */
  feedbackConfig?: {
    /** 显示反例 */
    showCounterExample?: boolean;
    /** 允许重试 */
    allowRetry?: boolean;
  };
}
```

### VerificationTestCase 测试用例

```typescript
interface VerificationTestCase {
  /** 用例ID（可选，默认使用索引） */
  id?: string;
  /** 测试输入 */
  input: string;
  /** 期望输出（多个用 | 分隔表示等价答案） */
  expectedOutput: string;
  /** 可视化类型（可选） */
  visualType?: string;
  /** 可视化配置（可选） */
  visualConfig?: Record<string, unknown>;
}
```

### 示例 JSON

```json
{
  "type": "verification",
  "conjectureToVerify": "分子分母同时扩大相同倍数，分数大小不变",
  "testCases": [
    { "input": "1/3 分子分母同时乘以 2", "expectedOutput": "2/6|2/6，与 1/3 相等" },
    { "input": "2/5 分子分母同时乘以 3", "expectedOutput": "6/15|6/15，与 2/5 相等" },
    { "input": "3/7 分子分母同时乘以 4", "expectedOutput": "12/28|12/28，与 3/7 相等" }
  ],
  "verificationPrompt": "请自己写出一个分数，然后把它分子分母同时扩大一个倍数，看看结果是否相等？",
  "feedbackConfig": {
    "showCounterExample": false,
    "allowRetry": true
  }
}
```

### expectedOutput 多答案格式

多个等价答案用 `|` 分隔，验证时任一匹配即视为正确：

```
"expectedOutput": "2/6|2/6，与 1/3 相等"
```

---

## ApplicationStep 迁移应用步骤

### 期望的 content 类型

```typescript
interface ApplicationContent {
  type: 'application';
  /** 整体指令描述 */
  instruction: string;
  /** 变式题目数组 */
  variants: VariantItem[];
  /** 通过的最低正确数 */
  minCorrect: number;
}
```

### VariantItem 变式题目

```typescript
interface VariantItem {
  /** 题目ID */
  id: string;
  /** 问题文本 */
  question: string;
  /** 选项数组（选择题时需要） */
  options?: string[];
  /** 正确答案 */
  correctAnswer: string;
  /** 解析说明（可选） */
  explanation?: string;
}
```

### 示例 JSON

```json
{
  "type": "application",
  "instruction": "小明把一根绳子分成5份取了3份，小红分成4份取了2份。谁拿的绳子更长？",
  "variants": [
    {
      "id": "v1",
      "question": "比较 3/5 和 2/4 的大小",
      "options": ["3/5 更大", "2/4 更大", "一样大"],
      "correctAnswer": "3/5 更大",
      "explanation": "3/5 = 12/20，2/4 = 10/20，所以 3/5 更大"
    },
    {
      "id": "v2",
      "question": "比较 4/7 和 3/5 的大小",
      "options": ["4/7 更大", "3/5 更大", "一样大"],
      "correctAnswer": "3/5 更大"
    }
  ],
  "minCorrect": 2
}
```

### 填空题模式

如果 `options` 为空或未提供，组件将使用填空题模式：

```json
{
  "variants": [
    {
      "id": "v1",
      "question": "3/4 = ?/12，请填空",
      "correctAnswer": "9"
    }
  ]
}
```

---

## CompletionCriteria 过关条件

每个步骤还包含 `completionCriteria` 字段定义完成条件：

```typescript
interface CompletionCriteria {
  type: CompletionType;
  config: InteractiveConfig | InputConfig | ChoiceConfig | VerbalConfig;
}

enum CompletionType {
  INTERACTIVE = 'interactive',  // 交互达标
  INPUT = 'input',              // 输入判定
  CHOICE = 'choice',            // 选择判定
  VERBAL = 'verbal',            // 语言描述判定
}
```

### 各类型配置

```typescript
interface InteractiveConfig {
  requiredInteraction: string;
  tolerance?: number;
}

interface InputConfig {
  expectedAnswers: string[];
  equivalenceRules?: EquivalenceRule[];
  tolerance?: number;
}

interface ChoiceConfig {
  correctIndex: number;
  shuffle: boolean;
}

interface VerbalConfig {
  minLength: number;
  expectedKeywords: string[];
  minKeywords: number;
  requireLogicalConnectors: boolean;
}
```

---

## 字段兼容性说明

### 必须字段 vs 可选字段

| 步骤类型 | 必须字段 | 可选字段 |
|----------|----------|----------|
| ConcreteStep | scenario, interaction | - |
| PictorialStep | task, visualType, outputFormat | visualConfig |
| SymbolicStep | instruction, inputType, expectedAnswer | equivalenceRules |
| ConjectureStep | observationPrompt, examples, conjecturePrompt | - |
| VerificationStep | instruction, testCases | conjectureToVerify, hypothesis, verificationPrompt, feedbackConfig |
| ApplicationStep | instruction, variants, minCorrect | - |

### 向后兼容性

为保证向后兼容，所有 `visualConfig` 使用 `Record<string, unknown>` 类型，允许新增字段而不破坏现有代码。组件内部应使用类型断言访问特定字段。

---

## 类型导出

所有类型通过 `src/shared/interfaces.ts` 统一导出：

```typescript
import type {
  ConcreteContent,
  PictorialContent,
  SymbolicContent,
  ConjectureContent,
  VerificationContent,
  ApplicationContent,
  ObservationExample,
  VariantItem,
  VerificationTestCase,
  CompletionCriteria,
  StepComponentProps,
} from '@/shared/interfaces';
```

---

## 文档版本历史

| 版本 | 日期 | 修改内容 |
|------|------|----------|
| 1.0.0 | 2026-10-06 | 初始版本，定义所有步骤类型接口 |
