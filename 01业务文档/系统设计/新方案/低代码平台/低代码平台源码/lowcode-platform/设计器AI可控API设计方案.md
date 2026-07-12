# 设计器AI可操作性设计方案

## 核心原则

**人能做的所有操作，AI 也必须能做。**

这里的“AI 能做”不是通过内部 Controller、Reducer、隐藏测试 API、直接改 schema、直接写 localStorage 等代码侵入手段完成，而是和人完全一样，通过真实浏览器交互完成：

- 点击
- 双击
- 悬停
- 键盘输入
- 快捷键
- 鼠标按下、移动、释放
- 拖拽
- 滚动
- 聚焦、失焦
- 选择菜单项
- 调整尺寸

一个设计器功能只有同时满足以下三点，才算真正实现：

1. 人可以在页面上完成这个操作。
2. AI 可以通过真实浏览器鼠标、键盘和拖拽完成同一个操作。
3. 操作结果可以通过可见 UI、DOM 属性、可访问性结构或元素位置尺寸断言出来。

## 明确禁止的方案

以下方式不能作为 AI 自动化测试和验收的主路径：

- 暴露 `window.__designerController` 给测试直接调用。
- 在测试里直接调用 `addField()`、`moveField()`、`updateField()`、`setProps()` 等内部方法。
- 在测试里直接 dispatch reducer/action 绕过 UI。
- 在测试里直接修改表单 schema、全局 store、IndexedDB 或 localStorage 来制造状态。
- 为 AI 单独提供人看不到、点不到、拖不到的隐藏命令入口。
- 只断言内部状态变化，不验证页面上真实可见的结果。

内部 API 可以用于开发调试和单元测试，但不能替代端到端交互验收。端到端验收必须证明“真实用户界面可操作”。

## 允许的 AI 抓手

AI 需要稳定抓手来定位页面元素。允许提供的抓手本质上是可测试性和可访问性契约，不是业务后门：

- `data-testid`
- `aria-label`
- `role`
- 可见文本标签
- 稳定 DOM 层级
- 稳定的节点 ID 映射属性，例如 `data-node-id`
- 非零尺寸、可命中的拖拽手柄和放置区域

示例：

```html
<button data-testid="palette-input" aria-label="添加输入框">输入框</button>

<div data-testid="canvas-root" role="application">
  <div
    data-testid="canvas-node"
    data-node-id="node_001"
    aria-label="字段：客户名称"
  >
    <button
      data-testid="drag-handle"
      aria-label="拖动字段：客户名称"
    >
      拖动
    </button>
  </div>
</div>

<input data-testid="prop-label" aria-label="字段标题" />
<input data-testid="prop-height" aria-label="字段高度" />
```

## 组件功能定义要求

每一种组件都必须先定义“人可以操作什么”，再实现和测试。组件功能定义至少包含：

| 功能类别 | 必须定义的内容 |
| --- | --- |
| 添加 | 从组件面板如何添加到画布、默认插入位置、默认属性 |
| 选中 | 单击、双击、键盘选择后的选中状态 |
| 拖动 | 是否可拖动、拖动手柄位置、可放置目标、排序规则 |
| 调整尺寸 | 是否支持宽度、高度、列宽、行高、最小值、最大值 |
| 属性配置 | 属性面板中有哪些输入项、选择项、开关项 |
| 数据绑定 | 字段名、默认值、校验规则、选项数据来源 |
| 容器能力 | 是否允许子组件、允许哪些子组件、布局方式 |
| 复制删除 | 复制规则、删除确认、删除后选中状态 |
| 撤销重做 | 哪些操作进入历史栈，撤销后 UI 如何恢复 |
| 预览渲染 | 设计态和预览态的差异、提交值结构 |

没有进入功能定义矩阵的能力，不能算作已实现能力。

当前工程中的元素能力矩阵由以下文件维护：

```text
lowcode-web/packages/demo/src/elementCapabilities.ts
```

该文件是设计器元素能力的唯一事实源，测试、文档和后续 Playwright 用例都必须以它为准。新增组件时必须先补矩阵，再补 UI 抓手和自动化测试。

当前已定义的 27 个元素：

| 分类 | 元素 |
| --- | --- |
| basic | input, inputNumber, select, datePicker, checkbox, radio, switch, button, textarea |
| advanced | upload, cascader, timePicker, rangePicker, autoComplete, rate, subTable, richText, tree, transfer, slider, colorPicker |
| layout | card, tabs, collapse |
| display | tag, divider, calendar |

每个元素都必须定义以下操作能力：

| 操作 | AI 验收要求 |
| --- | --- |
| add | 通过 `palette-{type}` 和 `canvas-root` 完成真实点击或拖拽添加 |
| select | 点击 `canvas-node` 选中元素，属性面板显示对应属性 |
| drag | 通过 `drag-handle` 进行真实拖拽排序或拖入容器 |
| configureProps | 通过属性面板真实 input/select/switch 修改属性 |
| resize | 通过 `prop-width`、`prop-height` 或 resize handle 修改尺寸 |
| delete | 点击 `delete-node-button` 删除节点 |
| preview | 切换预览模式后操作真实组件控件并断言可见结果 |

当前已建立的测试：

```text
lowcode-web/packages/demo/src/__tests__/elementCapabilities.test.ts
lowcode-web/packages/demo/src/__tests__/designerInteractionHooks.test.tsx
```

这些测试负责验证：

1. 27 个元素必须全部进入能力矩阵。
2. 每个元素必须定义 add/select/drag/configureProps/resize/delete/preview。
3. AI 操作描述中不能出现内部 API、schema/localStorage 直改、reducer dispatch 等侵入方式。
4. 组件面板必须为每个元素提供 `palette-{type}`。
5. 画布节点必须提供 `canvas-node`、`data-node-id`、`data-node-type`。
6. 拖拽、删除、画布、容器 drop zone、属性面板宽高输入必须有稳定抓手。

## 画布交互契约

画布必须为 AI 和人提供同一套可操作界面：

1. 画布根节点必须有稳定抓手，例如 `data-testid="canvas-root"`。
2. 所有可选中节点必须有稳定抓手和 `data-node-id`。
3. 所有可拖拽节点必须有可见、非零尺寸的拖拽手柄。
4. 所有可放置位置必须有稳定 drop zone，拖拽过程中必须能被浏览器命中。
5. 容器、分栏、网格、标签页等组件内部必须暴露各自的 drop zone。
6. 调整宽高、列宽、栅格跨度等能力必须有可命中的 resize handle 或真实输入控件。
7. 右键菜单、浮动工具条、hover 工具条不能只依赖不可预测的视觉状态，必须可通过真实 hover/click 打开并稳定定位。
8. 画布滚动、嵌套容器滚动、长表单滚动必须支持真实滚轮或拖动滚动条操作。

## 属性面板交互契约

属性面板不能只有内部数据模型，必须有真实控件：

- 文本属性使用 `input` 或 `textarea`。
- 枚举属性使用 `select`、radio group、segmented control 或菜单。
- 布尔属性使用 checkbox 或 switch。
- 数值属性使用 input、slider、stepper 等可操作控件。
- 复杂配置使用可展开区域、弹窗或表格，并为每个操作提供稳定抓手。

AI 修改属性时，必须通过 `click`、`fill`、`press`、`selectOption` 等真实浏览器操作完成。

## 端到端测试示例

正确示例：

```typescript
test('通过真实交互添加输入框并设置高度', async ({ page }) => {
  await page.goto('/designer');

  await page.getByTestId('palette-input').click();
  await page.getByTestId('canvas-root').click();

  const node = page.getByTestId('canvas-node').filter({
    hasText: '输入框',
  });
  await expect(node).toBeVisible();

  await node.click();
  await page.getByTestId('prop-label').fill('客户名称');
  await page.getByTestId('prop-height').fill('80');
  await page.getByTestId('prop-height').press('Enter');

  await expect(node).toContainText('客户名称');

  const box = await node.boundingBox();
  expect(box?.height).toBe(80);
});
```

正确拖拽示例：

```typescript
test('通过真实拖拽把字段移动到分组容器内', async ({ page }) => {
  await page.goto('/designer');

  await page.getByTestId('palette-group').dragTo(page.getByTestId('canvas-root'));
  await page.getByTestId('palette-input').dragTo(page.getByTestId('canvas-root'));

  await page
    .getByTestId('drag-handle')
    .filter({ hasText: '输入框' })
    .dragTo(page.getByTestId('drop-zone-group-body'));

  await expect(page.getByTestId('group-body')).toContainText('输入框');
});
```

错误示例：

```typescript
test('错误示例：绕过UI直接改内部状态', async ({ page }) => {
  await page.evaluate(() => {
    window.__designerController.addField('input');
    window.__designerController.updateField('node_001', { height: 80 });
  });
});
```

## 验收标准

每个组件上线前必须通过以下验收：

1. 功能矩阵已定义。
2. 组件面板入口有稳定抓手。
3. 画布节点有稳定抓手。
4. 可拖拽能力有真实 drag handle。
5. 可放置能力有真实 drop zone。
6. 属性配置全部有真实表单控件。
7. AI 可以用 Playwright 或同等浏览器自动化工具完成该组件的主要人类操作。
8. 测试断言来自可见 UI、DOM、可访问性属性、元素位置或元素尺寸。
9. 不依赖内部状态修改来制造成功结果。

## 总结

设计器不是给 AI 另一套隐藏遥控器，而是把人类界面做成稳定、可访问、可自动化的真实操作面。

最终目标是：

**人怎么点、怎么拖、怎么填，AI 就怎么点、怎么拖、怎么填；人能看到什么结果，AI 就断言什么结果。**
