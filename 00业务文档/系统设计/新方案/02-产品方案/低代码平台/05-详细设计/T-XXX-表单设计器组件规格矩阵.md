# 表单设计器组件规格矩阵

> 版本：v1.0
> 制定日期：2026-07-08
> 依据：T-207 组件库设计、FieldRenderer.tsx 实现、PropertyPanel.tsx 实现
> 状态：**已实现规格** / **待补充** / **设计缺失**

---

## 一、组件能力总览

### 1.1 已实现 vs 待实现

| 分类 | T-207 设计 | 实际实现 | 差距 |
|------|-----------|---------|------|
| 基础表单组件 | 11 | **9** (缺 Grid, Space) | 22% |
| 布局容器组件 | 6 | **3** (缺 Grid, Space, Table/List/Descriptions/Statistic) | 50% |
| 高级输入组件 | 8 | **12** (含 subTable/richText/tree) | +50% |
| 数据展示组件 | 4 | **0** (Table→subTable 已归入高级) | -100% |
| 业务组件 | 3 | **0** | -100% |
| 辅助组件 | 5 | **0** (Text, Link, Alert, Image, Button→基础) | -100% |
| **总计** | **37** | **29** | **22% 缺失** |

**结论**：设计文档定义了 37 个组件，但实际只实现了 29 个。缺失 8 个组件的设计（Grid, Space, Table, List, Descriptions, Statistic, UserSelector, DeptSelector, OrgSelector, Text, Link, Alert, Image）。

### 1.2 组件分类

| 类别 | 数量 | 组件 |
|------|------|------|
| 基础 | 9 | input, inputNumber, select, datePicker, checkbox, radio, switch, button, textarea |
| 高级 | 12 | upload, cascader, timePicker, rangePicker, autoComplete, rate, subTable, richText, tree, transfer, slider, colorPicker |
| 布局 | 3 | card, tabs, collapse |
| 展示 | 2 | tag, divider |
| 特殊 | 1 | calendar |

---

## 二、组件规格矩阵（29 组件）

### 2.1 基础组件

#### 2.1.1 Input - 单行输入框

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 文本输入，支持 CRUD 表单编辑 | ✅ | T-207 2.1 | |
| **外观** | 单行输入框，placeholder 灰色提示 | ✅ | T-207 2.1 | |
| **属性-props** | placeholder, defaultValue, disabled, readonly | ✅ | T-207 | **缺失**：prefix, suffix, addonBefore, addonAfter, size, allowClear, maxLength, minLength |
| **属性-panel** | prop-label, prop-field-id, prop-placeholder, prop-default-value, prop-required, prop-disabled, prop-readonly, prop-min-length, prop-max-length, prop-pattern, prop-error-message | ✅ | PropertyPanel | **缺失**：prefix/suffix 输入框、size 选项、allowClear 开关 |
| **事件** | onChange | ⚠️ | T-207 | **待补充**：FieldRenderer 未导出事件；PropertyPanel 未暴露事件绑定 |
| **E2E 抓手** | data-testid="palette-input", canvas-node[data-node-type="input"], prop-label | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface InputSpec {
  // 缺失属性（设计有，代码无）
  prefix?: ReactNode;           // 前缀图标
  suffix?: ReactNode;            // 后缀图标
  addonBefore?: string;         // 前置标签
  addonAfter?: string;          // 后置标签
  size?: 'large' | 'default' | 'small';
  allowClear?: boolean;
  maxLength?: number;           // 注意：panel 有 minLength/maxLength 但 FieldRenderer 未透传
  minLength?: number;
}
```

---

#### 2.1.2 InputNumber - 数字输入

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 数字输入，支持步进 | ✅ | T-207 2.3 | |
| **外观** | 带增减按钮的数字输入框 | ✅ | T-207 2.3 | |
| **属性-props** | defaultValue, min, max, step, precision | ⚠️ | T-207 | **缺失**：min/max/step/precision 未透传到 Ant InputNumber |
| **属性-panel** | 通用属性 + 尺寸配置 | ✅ | PropertyPanel | **缺失**：min/max/step/precision 输入框 |
| **事件** | onChange | ⚠️ | T-207 | **待补充**：事件未导出 |
| **E2E 抓手** | data-testid="palette-inputNumber" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface InputNumberSpec {
  // 缺失属性
  min?: number;                 // 最小值
  max?: number;                 // 最大值
  step?: number;                // 步长
  precision?: number;          // 小数精度
  controls?: boolean;          // 是否显示增减按钮
  formatter?: (value: number) => string;
  parser?: (value: string) => number;
}
```

---

#### 2.1.3 Textarea - 多行文本

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 多行文本输入 | ✅ | T-207 2.2 | |
| **外观** | 多行文本框，默认 3 行 | ✅ | FieldRenderer | |
| **属性-props** | placeholder, defaultValue, rows, disabled, readonly, maxLength | ⚠️ | T-207 2.2 | **缺失**：rows (硬编码 3), autoSize, showCount, allowClear |
| **属性-panel** | 通用属性 | ✅ | PropertyPanel | **缺失**：rows 滑块, autoSize 开关, showCount 开关 |
| **事件** | onChange | ⚠️ | T-207 | **待补充** |
| **E2E 抓手** | data-testid="palette-textarea" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface TextareaSpec {
  rows?: number;               // 默认 3，可配置 1-10
  autoSize?: boolean | { minRows?: number; maxRows?: number };
  showCount?: boolean;          // 显示字数统计
  allowClear?: boolean;
  maxLength?: number;           // FieldRenderer 未透传
}
```

---

#### 2.1.4 Select - 下拉选择

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 从预定义选项中选择 | ✅ | T-207 2.4 | |
| **外观** | 下拉选择框，默认显示 3 个选项 | ✅ | FieldRenderer | |
| **属性-props** | placeholder, defaultValue, options, disabled | ✅ | T-207 2.4 | **缺失**：mode (multiple/tags), dataSource, allowClear, showSearch, filterOption |
| **属性-panel** | 通用属性 + 多选开关 | ⚠️ | PropertyPanel | **缺失**：options 可视化编辑器、mode 选择、allowClear 开关、showSearch 开关 |
| **事件** | onChange, onSelect | ⚠️ | T-207 2.4 | **待补充** |
| **E2E 抓手** | data-testid="palette-select" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface SelectSpec {
  mode?: 'default' | 'multiple' | 'tags';
  options?: Array<{ label: string; value: string | number; disabled?: boolean }>;
  dataSource?: string;           // 数据源 ID
  dataSourceParams?: any;
  allowClear?: boolean;
  showSearch?: boolean;
  filterOption?: boolean;
}
```

**⚠️ 关键缺失**：PropertyPanel 缺少 options 可视化编辑器（动态添加/删除选项）。需要补充 `prop-options` 控件，支持增删改选项。

---

#### 2.1.5 Checkbox - 复选框

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 单个勾选或多选 | ✅ | T-207 2.6 | |
| **外观** | 单个 Checkbox 或 Checkbox.Group | ✅ | FieldRenderer | 单个选项渲染 Checkbox，多选项渲染 Checkbox.Group |
| **属性-props** | defaultValue, options, disabled | ⚠️ | T-207 2.6 | **缺失**：layout (horizontal/vertical) |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：options 编辑器、layout 选择 |
| **事件** | onChange | ⚠️ | T-207 | **待补充** |
| **E2E 抓手** | data-testid="palette-checkbox" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface CheckboxSpec {
  defaultValue?: string[] | number[] | boolean;
  options?: Array<{ label: string; value: string | number; disabled?: boolean }>;
  layout?: 'horizontal' | 'vertical';  // 默认 horizontal
}
```

---

#### 2.1.6 Radio - 单选框

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 单选 | ✅ | T-207 2.5 | |
| **外观** | Radio.Group 横向展示 | ✅ | FieldRenderer | |
| **属性-props** | defaultValue, options, disabled | ⚠️ | T-207 2.5 | **缺失**：optionType (default/button), buttonStyle |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：options 编辑器、optionType 选择、buttonStyle 选择 |
| **事件** | onChange | ⚠️ | T-207 | **待补充** |
| **E2E 抓手** | data-testid="palette-radio" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface RadioSpec {
  defaultValue?: string | number;
  options?: Array<{ label: string; value: string | number; disabled?: boolean }>;
  optionType?: 'default' | 'button';
  buttonStyle?: 'outline' | 'solid';
}
```

---

#### 2.1.7 DatePicker - 日期选择

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 日期选择 | ✅ | T-207 2.7 | |
| **外观** | 日期选择器 | ✅ | FieldRenderer | |
| **属性-props** | placeholder, disabled | ✅ | T-207 2.7 | **缺失**：format, picker (date/week/month/quarter/year), showTime, disabledDate, allowClear |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：format 输入、picker 选择、showTime 开关、disabledDate 表达式 |
| **事件** | onChange | ⚠️ | T-207 | **待补充** |
| **E2E 抓手** | data-testid="palette-datePicker" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface DatePickerSpec {
  format?: string;               // 默认 YYYY-MM-DD
  picker?: 'date' | 'week' | 'month' | 'quarter' | 'year';
  showTime?: boolean;
  disabledDate?: string;         // 表达式
  allowClear?: boolean;
  defaultValue?: string | Date;
}
```

---

#### 2.1.8 TimePicker - 时间选择

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 时间选择 | ✅ | T-207 2.8 | |
| **外观** | 时间选择器 | ✅ | FieldRenderer | |
| **属性-props** | placeholder, disabled | ✅ | T-207 2.8 | **缺失**：format, hourStep, minuteStep, secondStep, use12Hours |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：format 输入、hourStep/minuteStep/secondStep 步长、use12Hours 开关 |
| **事件** | onChange | ⚠️ | T-207 | **待补充** |
| **E2E 抓手** | data-testid="palette-timePicker" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface TimePickerSpec {
  format?: string;               // 默认 HH:mm:ss
  hourStep?: number;             // 默认 1
  minuteStep?: number;          // 默认 1
  secondStep?: number;           // 默认 1
  use12Hours?: boolean;
  defaultValue?: string;
}
```

---

#### 2.1.9 Switch - 开关

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 布尔值开关 | ✅ | T-207 2.9 | |
| **外观** | Switch 开关组件 | ✅ | FieldRenderer | |
| **属性-props** | defaultValue, disabled | ✅ | T-207 2.9 | **缺失**：checkedChildren, unCheckedChildren, size |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：checkedChildren/unCheckedChildren 输入、size 选择 |
| **事件** | onChange | ⚠️ | T-207 | **待补充** |
| **E2E 抓手** | data-testid="palette-switch" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface SwitchSpec {
  defaultValue?: boolean;
  checkedChildren?: ReactNode;   // 选中时文字
  unCheckedChildren?: ReactNode;  // 未选中时文字
  size?: 'default' | 'small';
}
```

---

#### 2.1.10 Button - 按钮

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 操作按钮 | ✅ | T-207 7.2 | |
| **外观** | type=primary 的按钮 | ✅ | FieldRenderer | |
| **属性-props** | text (label), disabled | ✅ | T-207 7.2 | **缺失**：type (primary/default/dashed/text/link), size, icon, loading, danger, onClick |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：type 选择、size 选择、icon 选择、loading 开关、danger 开关、onClick 表达式 |
| **事件** | onClick | ⚠️ | T-207 7.2 | **待补充**：按钮点击事件需要绑定表达式 |
| **E2E 抓手** | data-testid="palette-button" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface ButtonSpec {
  text?: string;                 // 显示文字，默认使用 label
  type?: 'primary' | 'default' | 'dashed' | 'text' | 'link';
  size?: 'large' | 'middle' | 'small';
  icon?: ReactNode;
  loading?: boolean;
  danger?: boolean;
  onClick?: string;              // 点击表达式
}
```

---

### 2.2 高级组件

#### 2.2.1 Upload - 文件上传

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 文件上传 | ✅ | T-207 4.1 | |
| **外观** | 上传按钮 + 文件列表 | ✅ | FieldRenderer | |
| **属性-props** | action, listType, disabled | ⚠️ | T-207 4.1 | **缺失**：accept, maxCount, maxSize, multiple, directory, beforeUpload, onSuccess |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：action 输入、accept 输入、maxCount 输入、maxSize 输入、multiple 开关、listType 选择、beforeUpload 表达式 |
| **事件** | onSuccess, onError | ⚠️ | T-207 4.1 | **待补充** |
| **E2E 抓手** | data-testid="palette-upload" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface UploadSpec {
  action?: string;               // 上传地址，默认 /api/upload
  accept?: string;               // 接受的文件类型，如 .jpg,.png
  listType?: 'text' | 'picture' | 'picture-card';
  maxCount?: number;             // 最大文件数
  maxSize?: number;              // 最大文件大小(bytes)
  multiple?: boolean;
  directory?: boolean;
  beforeUpload?: string;         // 上传前表达式
  onSuccess?: string;
  onError?: string;
}
```

---

#### 2.2.2 Cascader - 级联选择

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 级联选择 | ✅ | T-207 4.3 | |
| **外观** | 级联下拉选择器 | ✅ | FieldRenderer | |
| **属性-props** | placeholder, options (treeData), disabled | ⚠️ | T-207 4.3 | **缺失**：dataSource, showSearch, changeOnSelect, expandTrigger |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：treeData 可视化编辑器、showSearch 开关、changeOnSelect 开关、expandTrigger 选择 |
| **事件** | onChange | ⚠️ | T-207 4.3 | **待补充** |
| **E2E 抓手** | data-testid="palette-cascader" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface CascaderSpec {
  defaultValue?: string[];
  options?: Array<{
    label: string;
    value: string;
    children?: Array<any>;
  }>;
  dataSource?: string;
  placeholder?: string;
  showSearch?: boolean;
  changeOnSelect?: boolean;
  expandTrigger?: 'click' | 'hover';
}
```

**⚠️ 关键缺失**：PropertyPanel 缺少 treeData 树形数据编辑器。

---

#### 2.2.3 TreeSelect - 树形选择

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 树形结构选择 | ✅ | T-207 4.4 (TreeSelect) | |
| **外观** | 树形下拉选择 | ✅ | FieldRenderer (tree) | |
| **属性-props** | placeholder, treeData, disabled | ⚠️ | T-207 4.4 | **缺失**：dataSource, multiple, treeCheckable, showSearch, treeDefaultExpandAll |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：treeData 可视化编辑器、multiple 开关、treeCheckable 开关、showSearch 开关、expandAll 开关 |
| **事件** | onChange | ⚠️ | T-207 4.4 | **待补充** |
| **E2E 抓手** | data-testid="palette-tree" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface TreeSelectSpec {
  defaultValue?: string | string[];
  treeData?: Array<{
    title: string;
    value: string;
    children?: Array<any>;
  }>;
  dataSource?: string;
  multiple?: boolean;
  treeCheckable?: boolean;
  showSearch?: boolean;
  treeDefaultExpandAll?: boolean;
}
```

---

#### 2.2.4 Transfer - 穿梭框

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 双栏穿梭选择 | ✅ | T-207 4.5 | |
| **外观** | 左右两栏，带箭头按钮 | ✅ | FieldRenderer | |
| **属性-props** | dataSource (options), disabled | ⚠️ | T-207 4.5 | **缺失**：titles, showSearch, oneWay, operations |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：titles 输入、showSearch 开关、oneWay 开关、operations 输入 |
| **事件** | onChange | ⚠️ | T-207 4.5 | **待补充** |
| **E2E 抓手** | data-testid="palette-transfer" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface TransferSpec {
  defaultValue?: string[];
  dataSource?: string;
  titles?: [string, string];     // 默认 ['源', '目标']
  showSearch?: boolean;
  oneWay?: boolean;
  operations?: [string, string]; // 默认 ['>', '<']
}
```

---

#### 2.2.5 AutoComplete - 自动完成

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 输入建议 | ✅ | T-207 4.8 | |
| **外观** | 带建议的输入框 | ✅ | FieldRenderer | |
| **属性-props** | placeholder, options, disabled | ⚠️ | T-207 4.8 | **缺失**：dataSource, filterOption, allowClear |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：dataSource 输入、filterOption 开关、allowClear 开关 |
| **事件** | onChange, onSearch | ⚠️ | T-207 4.8 | **待补充** |
| **E2E 抓手** | data-testid="palette-autoComplete" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface AutoCompleteSpec {
  defaultValue?: string;
  placeholder?: string;
  dataSource?: string;
  filterOption?: boolean;
  allowClear?: boolean;
}
```

---

#### 2.2.6 Rate - 评分

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 评分/打星 | ✅ | T-207 2.10 | |
| **外观** | 5 个星星 | ✅ | FieldRenderer | |
| **属性-props** | defaultValue, disabled | ⚠️ | T-207 2.10 | **缺失**：count, allowHalf, allowClear, character, tooltips |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：count 输入、allowHalf 开关、allowClear 开关、character 输入、tooltips 编辑器 |
| **事件** | onChange | ⚠️ | T-207 2.10 | **待补充** |
| **E2E 抓手** | data-testid="palette-rate" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface RateSpec {
  defaultValue?: number;        // 默认 0
  count?: number;               // 星星总数，默认 5
  allowHalf?: boolean;
  allowClear?: boolean;
  character?: ReactNode;
  tooltips?: string[];           // 每个星级的提示文字
}
```

---

#### 2.2.7 Slider - 滑块

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 数值滑动选择 | ✅ | T-207 2.11 | |
| **外观** | 水平滑块 | ✅ | FieldRenderer | |
| **属性-props** | defaultValue, disabled | ⚠️ | T-207 2.11 | **缺失**：min, max, step, marks, range, vertical |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：min/max/step 输入、marks 编辑器、range 开关、vertical 开关 |
| **事件** | onChange | ⚠️ | T-207 2.11 | **待补充** |
| **E2E 抓手** | data-testid="palette-slider" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface SliderSpec {
  defaultValue?: number | [number, number];
  min?: number;                  // 默认 0
  max?: number;                  // 默认 100
  step?: number;                 // 默认 1
  marks?: Record<number, string>; // 刻度标记 { 0: '0', 50: '50', 100: '100' }
  range?: boolean;               // 双滑块
  vertical?: boolean;
}
```

---

#### 2.2.8 ColorPicker - 颜色选择

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 颜色选择 | ✅ | T-207 4.6 | |
| **外观** | 颜色块 + SketchPicker 弹窗 | ✅ | FieldRenderer | |
| **属性-props** | defaultValue, disabled | ⚠️ | T-207 4.6 | **缺失**：format (hex/rgb/hsb), showText, presets |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：format 选择、showText 开关、presets 编辑器 |
| **事件** | onChange | ⚠️ | T-207 4.6 | **待补充** |
| **E2E 抓手** | data-testid="palette-colorPicker", color-preview-{id} | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface ColorPickerSpec {
  defaultValue?: string;         // 默认 #1890ff
  format?: 'hex' | 'rgb' | 'hsb';
  showText?: boolean;            // 显示颜色值文本
  presets?: Array<{
    label: string;
    colors: string[];
  }>;
}
```

---

#### 2.2.9 RangePicker - 日期范围选择

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 日期范围选择 | ✅ | T-207 4.7 | |
| **外观** | 日期范围选择器 | ✅ | FieldRenderer | |
| **属性-props** | disabled | ⚠️ | T-207 4.7 | **缺失**：format, separator, disabledDate, allowEmpty |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：format 输入、separator 输入、disabledDate 表达式、allowEmpty 开关 |
| **事件** | onChange | ⚠️ | T-207 4.7 | **待补充** |
| **E2E 抓手** | data-testid="palette-rangePicker" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface RangePickerSpec {
  defaultValue?: [string, string];
  format?: string;
  separator?: string;            // 默认 '~'
  disabledDate?: string;
  allowEmpty?: [boolean, boolean]; // 控制两端是否可为空
}
```

---

#### 2.2.10 SubTable - 子表格

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 表格内嵌编辑 | ✅ | T-207 5.1 (Table) | 简化版 Table |
| **外观** | 表格 + 添加行按钮 | ✅ | FieldRenderer | |
| **属性-props** | disabled | ⚠️ | T-207 5.1 | **缺失**：columns 定义、pagination、rowSelection、bordered、size |
| **属性-panel** | 通用属性 | ⚠️ | PropertyPanel | **缺失**：columns 可视化编辑器、pagination 配置、bordered 开关、size 选择 |
| **事件** | onAddRow, onDeleteRow, onRowChange | ⚠️ | T-207 5.1 | **待补充** |
| **E2E 抓手** | data-testid="palette-subTable" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface SubTableSpec {
  columns?: Array<{
    key: string;
    title: string;
    dataIndex: string;
    width?: number;
    type?: 'text' | 'select' | 'number' | 'date';
    options?: Array<{ label: string; value: string }>;
  }>;
  pagination?: {
    pageSize?: number;
    showSizeChanger?: boolean;
  };
  rowSelection?: {
    type?: 'checkbox' | 'radio';
  };
  bordered?: boolean;
  size?: 'large' | 'middle' | 'small';
  addRowText?: string;           // 添加行按钮文字，默认 '添加行'
  deleteRowText?: string;
  rowActions?: Array<{ type: 'edit' | 'delete' | 'custom'; label: string }>;
}
```

**⚠️ 关键缺失**：PropertyPanel 缺少 columns 可视化编辑器（增删列、配置列属性）。

---

#### 2.2.11 RichText - 富文本编辑器

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 富文本编辑 | ⚠️ | T-207 4.2 | 当前是 TextArea 简化版 |
| **外观** | 工具栏 + 文本区 | ✅ | FieldRenderer | |
| **属性-props** | placeholder, defaultValue, disabled, height | ⚠️ | T-207 4.2 | **缺失**：toolbar 配置数组、maxLength |
| **属性-panel** | 通用属性 + height | ⚠️ | PropertyPanel | **缺失**：toolbar 可视化配置（增删工具按钮）、maxLength 输入 |
| **事件** | onChange | ⚠️ | T-207 4.2 | **待补充** |
| **E2E 抓手** | data-testid="palette-richText" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface RichTextSpec {
  defaultValue?: string;
  placeholder?: string;
  height?: number | string;      // 默认 120px
  maxLength?: number;
  toolbar?: Array<{
    key: string;                 // bold, italic, underline, link, image, etc.
    label: string;
    icon?: string;
  }>;
  // 默认工具栏
  defaultToolbar?: string[];     // ['bold', 'italic', 'underline', 'link', 'image']
}
```

---

### 2.3 布局组件

#### 2.3.1 Card - 卡片容器

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 容器，接收子组件 | ✅ | T-207 3.2 | |
| **外观** | 带标题的卡片 | ✅ | FieldRenderer | |
| **属性-props** | label (title), children | ✅ | T-207 3.2 | **缺失**：extra, bordered, hoverable, size |
| **属性-panel** | 基础属性 + CSS 布局 | ⚠️ | PropertyPanel | **缺失**：extra 输入、bordered 开关、hoverable 开关、size 选择 |
| **事件** | - | N/A | T-207 3.2 | 纯容器，无事件 |
| **E2E 抓手** | data-testid="palette-card", drop-zone-card | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface CardSpec {
  title?: string;                // 使用 label 字段
  extra?: ReactNode;
  bordered?: boolean;             // 默认 true
  hoverable?: boolean;
  size?: 'default' | 'small';
  children?: DesignerFieldData[];
}
```

---

#### 2.3.2 Tabs - 标签页容器

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 标签页切换，接收子组件 | ✅ | T-207 3.4 | |
| **外观** | 3 个固定标签页 | ⚠️ | FieldRenderer | Tabs 数量硬编码为 3 |
| **属性-props** | label (第一个标签标题), children | ⚠️ | T-207 3.4 | **缺失**：type (line/card/editable-card), size, tabPosition, tabs 数组配置 |
| **属性-panel** | 基础属性 + CSS 布局 | ⚠️ | PropertyPanel | **缺失**：type 选择、size 选择、tabPosition 选择、tabs 可视化编辑器 |
| **事件** | onTabChange | ⚠️ | T-207 3.4 | **待补充** |
| **E2E 抓手** | data-testid="palette-tabs", drop-zone-tabs | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface TabsSpec {
  defaultActiveKey?: string;
  type?: 'line' | 'card' | 'editable-card';
  size?: 'large' | 'default' | 'small';
  tabPosition?: 'top' | 'right' | 'bottom' | 'left';
  tabs?: Array<{
    key: string;
    label: string;
    children?: DesignerFieldData[];
  }>;
}
```

**⚠️ 关键缺失**：当前 tabs 硬编码为 3 个固定标签页，tabs 配置能力需补充。

---

#### 2.3.3 Collapse - 折叠面板

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 可折叠面板，接收子组件 | ✅ | T-207 3.3 | |
| **外观** | 2 个固定面板 | ⚠️ | FieldRenderer | Panel 数量硬编码为 2 |
| **属性-props** | label (第一个面板标题), children | ⚠️ | T-207 3.3 | **缺失**：defaultActiveKey, accordion, bordered, panels 数组配置 |
| **属性-panel** | 基础属性 + CSS 布局 | ⚠️ | PropertyPanel | **缺失**：accordion 开关、bordered 开关、panels 可视化编辑器 |
| **事件** | onChange | ⚠️ | T-207 3.3 | **待补充** |
| **E2E 抓手** | data-testid="palette-collapse", drop-zone-collapse | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface CollapseSpec {
  defaultActiveKey?: string[];
  accordion?: boolean;           // 手风琴模式
  bordered?: boolean;             // 默认 true
  panels?: Array<{
    key: string;
    header: string;
    children?: DesignerFieldData[];
  }>;
}
```

---

### 2.4 展示组件

#### 2.4.1 Tag - 标签

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 展示静态标签列表 | ✅ | T-207 7.1 (Text 变体) | |
| **外观** | 彩色 Ant Tag 列表 | ✅ | FieldRenderer | 颜色在 blue/green/red/orange 间循环 |
| **属性-props** | options | ⚠️ | 无专门设计 | **缺失**：tagColor 映射、closable、onClose |
| **属性-panel** | options 编辑器 | ⚠️ | PropertyPanel | **缺失**：closable 开关、color 选择 |
| **事件** | onClose | ⚠️ | 无专门设计 | **待补充** |
| **E2E 抓手** | data-testid="palette-tag" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface TagSpec {
  options?: Array<{
    label: string;
    value: string;
    color?: string;
    closable?: boolean;
  }>;
  // 默认 4 种颜色循环: blue, green, red, orange
  defaultColors?: string[];
}
```

---

#### 2.4.2 Divider - 分割线

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 内容分割 | ✅ | T-207 3.5 | |
| **外观** | 水平分割线，中间可带标题 | ✅ | FieldRenderer | |
| **属性-props** | label (作为标题文本) | ⚠️ | T-207 3.5 | **缺失**：orientation, orientationMargin, type, dashed |
| **属性-panel** | 基础属性 | ⚠️ | PropertyPanel | **缺失**：orientation 选择、type 选择、dashed 开关 |
| **事件** | - | N/A | T-207 3.5 | 纯展示，无事件 |
| **E2E 抓手** | data-testid="palette-divider" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface DividerSpec {
  text?: string;                 // 使用 label 字段
  orientation?: 'left' | 'center' | 'right';  // 标题位置
  orientationMargin?: number;
  type?: 'horizontal' | 'vertical'; // 默认 horizontal
  dashed?: boolean;
}
```

---

### 2.5 特殊组件

#### 2.5.1 Calendar - 日历

| 维度 | 规格 | 状态 | T-207 对应 | 备注 |
|------|------|------|-----------|------|
| **功能** | 日历展示 | ✅ | T-207 无专门设计 | 新增组件 |
| **外观** | Ant Calendar，月视图 | ✅ | FieldRenderer | |
| **属性-props** | 无 | ⚠️ | 无设计 | **缺失**：fullscreen、mode (month/year)、onChange、onPanelChange |
| **属性-panel** | 基础属性 | ⚠️ | PropertyPanel | **缺失**：fullscreen 开关、mode 选择 |
| **事件** | onChange, onPanelChange | ⚠️ | 无设计 | **待补充** |
| **E2E 抓手** | data-testid="palette-calendar" | ✅ | elementCapabilities.ts | |

**补充定义**：
```typescript
interface CalendarSpec {
  fullscreen?: boolean;          // 默认 false (紧凑模式)
  mode?: 'month' | 'year';
  value?: string;                 // 默认当天
}
```

---

## 三、缺失规格补充

### 3.1 PropertyPanel 缺失的控件

| 缺失控件 | 影响组件 | 优先级 | 备注 |
|---------|---------|--------|------|
| options 可视化编辑器 | select, checkbox, radio, autoComplete, tag | P0 | 必须支持动态增删选项 |
| treeData 可视化编辑器 | cascader, tree | P0 | 必须支持树形数据配置 |
| columns 可视化编辑器 | subTable | P0 | 必须支持子表列配置 |
| toolbar 配置器 | richText | P1 | 必须支持富文本工具栏配置 |
| tabs/panels 数组编辑器 | tabs, collapse | P1 | 必须支持多标签/多面板配置 |
| size 选项组 | input, textarea, button | P2 | 可使用快捷按钮替代 |
| prefix/suffix 输入 | input | P2 | |
| allowClear 开关 | 多个组件 | P2 | |
| dataSource 选择器 | 多个组件 | P3 | 后期接入数据源服务后实现 |

### 3.2 FieldRenderer 缺失的属性透传

| 缺失透传 | 影响组件 | 优先级 |
|---------|---------|--------|
| InputNumber min/max/step/precision | inputNumber | P1 |
| Textarea rows/autoSize/showCount | textarea | P1 |
| Slider min/max/step/marks/range | slider | P1 |
| Rate count/allowHalf/tooltips | rate | P1 |
| Upload accept/maxCount/maxSize | upload | P1 |
| DatePicker/TimePicker format | datePicker, timePicker | P2 |
| RangePicker format/separator | rangePicker | P2 |
| Button type/icon/loading/danger | button | P1 |
| Select mode/allowClear/showSearch | select | P1 |
| Checkbox/Radio layout | checkbox, radio | P2 |
| Switch checkedChildren/unCheckedChildren | switch | P2 |
| ColorPicker format/showText | colorPicker | P2 |
| Cascader showSearch/changeOnSelect | cascader | P2 |
| TreeSelect multiple/treeCheckable | tree | P1 |
| Transfer titles/oneWay | transfer | P2 |
| AutoComplete filterOption | autoComplete | P2 |
| DatePicker picker/showTime | datePicker | P2 |
| RichText toolbar/maxLength | richText | P1 |
| Card/Tabs/Collapse extra/bordered | card, tabs, collapse | P2 |
| Divider orientation/dashed | divider | P2 |
| Calendar fullscreen/mode | calendar | P2 |

### 3.3 缺失组件设计（T-207 有但未实现）

| 组件 | T-207 章节 | 状态 | 优先级 |
|------|-----------|------|--------|
| Grid | 3.1 | 未实现 | P1 |
| Space | 3.6 | 未实现 | P2 |
| Table (独立数据表格) | 5.1 | 仅作 subTable | P3 |
| List | 5.2 | 未实现 | P3 |
| Descriptions | 5.3 | 未实现 | P3 |
| Statistic | 5.4 | 未实现 | P3 |
| UserSelector | 6.1 | 未实现 | P3 |
| DeptSelector | 6.2 | 未实现 | P3 |
| OrgSelector | 6.3 | 未实现 | P3 |
| Text | 7.1 | 未实现 | P2 |
| Link | 7.3 | 未实现 | P3 |
| Alert | 7.4 | 未实现 | P3 |
| Image | 7.5 | 未实现 | P3 |

---

## 四、事件系统补充定义

### 4.1 当前事件能力

当前 FieldRenderer 和 PropertyPanel 均**未实现事件系统**。所有组件的 onChange/onClick 等事件均未透传和绑定。

### 4.2 事件接口设计

```typescript
// 事件定义接口（待实现）
interface FieldEventHandler {
  componentType: ElementType;
  eventName: string;
  expression: string;             // 表达式，如 ${console.log(value)}
  condition?: string;             // 触发条件表达式
}

interface FieldEvents {
  // 通用事件
  onChange?: FieldEventHandler;   // 值变化
  onFocus?: FieldEventHandler;    // 获得焦点
  onBlur?: FieldEventHandler;     // 失去焦点
  
  // 组件专属事件
  onPressEnter?: FieldEventHandler;       // input/textarea 回车
  onSearch?: FieldEventHandler;           // select/autoComplete 搜索
  onSelect?: FieldEventHandler;          // select/checkbox/radio 选中
  onDeselect?: FieldEventHandler;        // select/checkbox 取消选中
  onClick?: FieldEventHandler;           // button/link/tag
  onClose?: FieldEventHandler;           // tag 关闭
  onTabChange?: FieldEventHandler;       // tabs 切换
  onCollapseChange?: FieldEventHandler;// collapse 折叠
  onUploadSuccess?: FieldEventHandler;   // upload 成功
  onUploadError?: FieldEventHandler;     // upload 失败
  onDateChange?: FieldEventHandler;      // datePicker/rangePicker
  onSliderChange?: FieldEventHandler;    // slider
  onRateChange?: FieldEventHandler;      // rate
  onColorChange?: FieldEventHandler;     // colorPicker
  onTransferChange?: FieldEventHandler;  // transfer
}
```

---

## 五、E2E 测试规格映射

基于以上规格矩阵，E2E 测试应覆盖以下能力层级：

### 5.1 L1 - 基础 CRUD（每个组件）

| 测试项 | 测试方法 |
|-------|---------|
| 添加组件 | 点击 palette-{type}，验证画布出现 canvas-node[data-node-type="{type}"] |
| 选中组件 | 点击 canvas-node，验证属性面板显示 prop-* 控件 |
| 配置基础属性 | 修改 prop-label, prop-field-id, prop-placeholder，验证渲染结果 |
| 删除组件 | 点击 delete-node-button，验证节点消失 |
| 预览态 | 切换 preview 模式，验证组件可见且可交互 |

### 5.2 L2 - 组件专属属性

| 组件 | 测试项 |
|------|-------|
| input | prefix/suffix (补充后)、maxLength 显示字数 |
| inputNumber | min/max/step (补充后) |
| textarea | rows 显示行数 |
| select/checkbox/radio | options 渲染选项 |
| datePicker | 日期选择交互 |
| upload | 上传按钮显示 |
| slider | 滑块拖动 |
| rate | 星级点击 |
| colorPicker | 颜色选择弹窗 |
| subTable | 添加行按钮 |
| richText | 工具栏按钮 |
| tree/cascader | 树形下拉展开 |
| transfer | 穿梭操作 |
| card/tabs/collapse | 拖入子组件到 drop-zone |

### 5.3 L3 - CSS 布局

| 测试项 | 测试方法 |
|-------|---------|
| 容器组件 CSS | card/tabs/collapse 设置 flex/grid 布局 |
| 子组件嵌套 | 拖入子组件到容器，验证嵌套结构 |
| 尺寸配置 | 修改 width/height/minWidth/maxWidth，验证样式变化 |

---

## 六、附录

### 6.1 data-testid 完整列表

| data-testid | 用途 | 组件范围 |
|------------|------|---------|
| palette-{type} | 组件面板入口 | 所有 29 个组件 |
| canvas-root | 画布根节点 | 全局 |
| canvas-node | 画布节点 | 所有节点 |
| canvas-node[data-node-type="{type}"] | 按类型定位节点 | 所有 29 个组件 |
| drag-handle | 拖拽手柄 | 所有节点 |
| delete-node-button | 删除按钮 | 所有节点 |
| property-panel | 属性面板根 | 全局 |
| property-panel-empty | 属性面板空状态 | 空选择时 |
| prop-label | 标签输入 | 所有组件 |
| prop-field-id | 字段编码输入 | 所有组件 |
| prop-placeholder | 占位提示输入 | 所有组件 |
| prop-default-value | 默认值输入 | 所有组件 |
| prop-required/disabled/readonly | 开关控件 | 所有组件 |
| prop-width/height/min-width/etc. | 尺寸控件 | 所有组件 |
| prop-display/flex-direction/etc. | CSS 布局控件 | 容器组件 |
| prop-min-length/max-length | 校验控件 | 文本类组件 |
| prop-options | 选项编辑器 | select/checkbox/radio/tag |
| drop-zone-{type} | 容器放置区 | card/tabs/collapse |
| color-preview-{id} | 颜色预览块 | colorPicker |
| prop-duplicate-button | 复制按钮 | 属性面板 |
| prop-delete-button | 删除按钮 | 属性面板 |

### 6.2 修订记录

| 日期 | 版本 | 修订内容 |
|------|------|---------|
| 2026-07-08 | v1.0 | 初稿，分析 T-207 与实际实现的差距，补充缺失规格 |

---

**文档维护**：前端开发团队
**审核人**：前端负责人
