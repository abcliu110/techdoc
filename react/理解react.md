<div id="chap-undstand"></div>

[⬆️ 返回目录](#catalog)

## 理解react

这是一个非常深刻的问题，理解了这个公式，你就真正跨过了 React 的门槛。

对于资深开发者来说，可以从**数学确定性**、**快照（Snapshot）思维**和**去副作用化**这三个维度来理解。

---

### 1. 核心定义：UI 是结果，数据是原因

在传统的命令式开发（如 jQuery）中，UI 的变化是由一系列“动作”累加而成的：

> **旧模式**：初始 UI $\rightarrow$ 点击 $\rightarrow$ 修改 DOM $\rightarrow$ 请求接口 $\rightarrow$ 再次修改 DOM。

在这种模式下，UI 的最终状态取决于你这一系列操作的**过程**是否正确。如果中间少了一行 `hide()`，UI 就会出错。

而在 React 的 **$UI = f(state, props)$** 模式下：

- **$state$ 和 $props$**：是自变量（输入）。
- **$f$**：是你的组件逻辑（处理函数）。
- **$UI$**：是因变量（输出）。

**理解点**：无论你经历了多么复杂的交互，只要现在的 $state$ 是 `{ count: 5 }`，那么渲染出来的 UI 永远是那个显示数字 5 的样子。**UI 是状态在某一时刻的投影。**

---

### 2. 快照（Snapshot）模型

你可以把组件的每一次渲染理解为一张“照片”。

- 当状态改变时，React **不是去修改**旧照片上的某个局部。
- React 是 **重新调用** 一次你的函数 $f$，传入新的数据，生成一张 **全新的照片**（虚拟 DOM 树）。

**资深开发者视角**：
你不再维护一个长寿的、不断被修改的实体，而是在编写一个**根据当前输入即时生成结构**的转换器。这极大降低了状态同步的复杂度。

---

### 3. “纯函数”的约束：可预测性

既然是 $UI = f(data)$，那么为了让这个公式牢靠，$f$ 必须尽量接近 **纯函数**。

- **相同的输入 $\rightarrow$ 相同的输出**：如果 $props$ 没变，输出的 UI 结构就不应该变。
- **无副作用**：在 $f$ 的执行过程中（即函数体里），不应该直接去修改全局变量、发起网络请求或手动操作 DOM。

**为什么这很重要？**
因为一旦 $f$ 是纯的，React 就可以做很多牛逼的优化：

1.  **跳过渲染**：如果 $props$ 没变，React 发现输入没变，就可以直接复用上一次的结果（`React.memo`）。
2.  **并发渲染**：React 可以在后台多次调用 $f$，因为它知道调用函数本身不会产生副作用。
3.  **时间旅行调试**：你可以记录下每一刻的 $state$，然后像倒带一样重放，UI 会精准地回到那一刻的样子。

---

### 4. 举个对比案例（直观理解）

假设有一个显示消息数量的图标：

#### **命令式逻辑 (jQuery 思维)**

```javascript
function updateCount(delta) {
  const current = parseInt($("#badge").text());
  const next = current + delta;
  $("#badge").text(next); // 手动修改 DOM
  if (next > 0) $("#badge").show();
  else $("#badge").hide();
}
```

_这种模式下，UI 的状态散落在各个修改动作中，很难保证一致性。_

#### **声明式逻辑 (React 思维)**

```tsx
const Badge = ({ count }) => {
  // UI 只是 count 的函数映射
  return <div style={{ display: count > 0 ? "block" : "none" }}>{count}</div>;
};
```

_无论 `count` 是怎么变的（加、减、乘、除），只要最终传进来的是 `5`，输出永远是那个显示的 Div。你只需要关注 **“现在的状态是什么”**，而不需要关注 **“怎么从上个状态变到这个状态”**。_

---

### 5. 总结：资深开发者的掌握精髓

理解 $UI = f(state, props)$ 后，你的开发关注点会发生以下偏移：

1.  **从“修改 UI” 转向 “描述 UI”**：你写的每一行 JSX，都是在描述某种状态下的“终点站”，而不是路上的“风景”。
2.  **核心难点在于“设计 State”**：既然 UI 是状态的函数，那么只要状态设计得简洁、无冗余，UI 逻辑自然就会变得非常稳固。
3.  **分离副作用**：既然 $f$ 是纯的，那么“请求数据”、“定时器”等不纯的操作，就必须被关进名为 `useEffect` 的笼子里，或者放在事件回调函数中。

**一句话：你不再是操作 DOM 的工匠，而是定义数据与 UI 映射规则的数学家。**

当你听到“JSX 的本质是对象数组”时，可以从两个层面来拆解：一个是**嵌套结构的本质**，另一个是**列表渲染的本质**。

作为资深开发者，你可以把 JSX 想象成一棵由 **JavaScript 对象** 组成的 **树**，而树的每一层子节点，在底层表现就是一个 **数组**。

---

### 1. 嵌套结构的本质：`children` 数组

在 JSX 中，当你写嵌套标签时：

```jsx
<div id="parent">
  <span>A</span>
  <span>B</span>
</div>
```

Babel 转换后的代码是这样的：

```javascript
React.createElement(
  "div",
  { id: "parent" },
  React.createElement("span", null, "A"), // 子元素 1
  React.createElement("span", null, "B"), // 子元素 2
);
```

**重点来了：** React 内部处理这些参数时，会将子元素存放在父元素的 `props.children` 属性中。如果子元素有多个，`props.children` 就是一个**对象数组**。

这个 `div` 对象在大脑中应该建模成这样：

```json
{
  "type": "div",
  "props": {
    "id": "parent",
    "children": [
      // 这里的本质就是一个对象数组
      { "type": "span", "props": { "children": "A" } },
      { "type": "span", "props": { "children": "B" } }
    ]
  }
}
```

---

### 2. 列表渲染的本质：直接操作对象数组

当你使用 `.map()` 渲染列表时，这一点表现得最明显：

```jsx
const items = ["苹果", "香蕉"];
const list = (
  <ul>
    {items.map((item) => (
      <li key={item}>{item}</li>
    ))}
  </ul>
);
```

看这里的执行逻辑：

1.  `items.map(...)` 执行完后，返回的是什么？
2.  它返回的是：`[<li/>, <li/>]`。
3.  根据我们之前学的本质，它其实就是一个 **纯 JavaScript 对象数组**：
    ```javascript
    [
      { type: "li", props: { children: "苹果" }, key: "苹果" },
      { type: "li", props: { children: "香蕉" }, key: "香蕉" },
    ];
    ```

**结论：** 在 React 眼里，**“渲染一个列表”等同于“处理一个存放了虚拟 DOM 对象的数组”**。

---

### 3. Fragment 的本质：绕过单一根节点的数组

React 要求组件只能返回一个根节点。如果你不想增加多余的 `div`，你会用 `<Fragment>` (或 `<>`)：

```jsx
<>
  <p>1</p>
  <p>2</p>
</>
```

在底层，这实际上是告诉 React：**“请直接接收这个对象数组，并把它们依次排开，不要在外面套壳了。”**

---

### 4. 深度理解：为什么这个“对象数组”的本质很重要？

理解了 UI = 对象数组后，你会发现很多高级操作变得理所当然：

#### **A. 动态过滤 UI**

既然是数组，我就可以在渲染前过滤它：

```jsx
const children = [<Header key="h" />, <Body key="b" />, <Footer key="f" />];

// 资深写法：根据权限剔除数组中的某个对象
return <div>{children.filter((c) => hasPermission(c.key))}</div>;
```

#### **B. 调换 UI 顺序**

既然是数组，我就可以直接用 `reverse()` 或 `sort()`：

```jsx
const list = [<li key="1">1</li>, <li key="2">2</li>];
return <ul>{list.reverse()}</ul>; // 直接反转 UI 数组
```

#### **C. 劫持并修改 UI**

你可以遍历这个对象数组，修改其中的属性（这是很多高级插件的原理）：

```javascript
const newChildren = React.Children.map(props.children, (child) => {
  // 克隆对象并混入新的 props
  return React.cloneElement(child, { extra: "data" });
});
```

---

### 总结

**“JSX 的本质是对象数组”** 是指：

1.  **结构上**：UI 是一棵树，父节点的 `children` 属性就是一个存放子节点对象的**数组**。
2.  **行为上**：我们在 React 中处理循环渲染，本质就是在**生成、过滤和操作一个存放虚拟 DOM 对象的数组**。

当你把眼前的 `<li>...</li>` 自动脑补成 `{ type: 'li', ... }`，并意识到你可以像操作普通数组一样操作这组 UI 时，你就已经掌握了 React 的精髓。

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-undstand)
