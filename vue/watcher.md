<div id="chap-watcher"></div>

[⬆️ 返回目录](#catalog)


## watcher

**是的，肯定还有！** 而且非常重要。

在 Vue 2 的源码中（Vue 3 的概念类似但实现不同），`Watcher` 是一个通用的类。**渲染 Watcher** 只是其中的一种用法。

Vue 内部其实共有 **三种** 主要的 Watcher。根据它们的用途和构造参数不同，表现行为也不同。它们分别是：

1.  **Computed Watcher**（计算属性 Watcher / Lazy Watcher）
2.  **User Watcher**（用户 Watcher）
3.  **Render Watcher**（渲染 Watcher）

---

### 1. Computed Watcher (计算属性 Watcher)
这是最容易被忽视，但也是最精妙的一个。
当你定义一个 `computed: { ... }` 属性时，Vue 会在内部为每一个计算属性创建一个 Watcher。

*   **它的特点：** **`lazy: true`**（懒执行）。
*   **原理：**
    *   普通的 Watcher 建立后会立即求值。但在创建 Computed Watcher 时，Vue 传入了 `{ lazy: true }`。
    *   这意味着它创建后**不会立刻求值**，而是把内部的一个 `dirty` 标志设为 `true`。
    *   **缓存机制**：只有当你在模板里或者其他地方**读取**这个计算属性时，它才会去计算。计算完后，把 `dirty` 设为 `false`。
    *   如果它依赖的数据（Dep）没有变，下次读取时，因为它不脏（`dirty` 为 `false`），就直接返回缓存的值，不重新计算。
    *   一旦依赖的数据变了，它不会立即重新计算，而是把 `dirty` 变回 `true`，通知引用它的人（通常是渲染 Watcher）：“我脏了，下次你要用我的时候记得让我重算。”

### 2. User Watcher (用户 Watcher)
这就是你在组件里写的 `watch: { ... }`，或者调用的 `this.$watch(...)`。

*   **它的特点：** **`user: true`**。
*   **原理：**
    *   Vue 在初始化 `watch` 选项时创建。
    *   它主要用于执行**副作用**（Side Effects），比如异步请求、操作 DOM、打日志等。
    *   它支持一些特殊选项，比如 `deep`（深度监听）和 `immediate`（立即执行）。
    *   **容错**：源码中对 User Watcher 的回调函数做了 `try...catch` 处理。如果你的 `watch` 回调报错了，Vue 会捕获错误并提示你，而不会让整个应用崩掉。这是内部 Watcher 和用户 Watcher 的一个重要区别。

### 3. Render Watcher (渲染 Watcher)
这个就是你已经知道的那个。每个组件实例对应一个。

*   **它的特点：** 负责 UI 更新。
*   **原理：**
    *   它在组件挂载（`mount`）阶段创建。
    *   它的回调函数就是组件的 `updateComponent` 方法（调用 `render` 函数生成 VNode 并 patch 到 DOM）。

---

### 深度对比与执行顺序

既然有三种 Watcher，那么当一个数据发生变化时，它们的执行顺序是怎样的？

**答案是：Computed -> User -> Render**

这在 Vue 的调度器（Scheduler）源码中是通过 Watcher 的 `id` 来控制的。

1.  **创建顺序决定 ID**：
    *   Vue 初始化时，先初始化 `computed`（创建 Computed Watcher）。
    *   然后初始化 `watch`（创建 User Watcher）。
    *   最后执行 `mount`（创建 Render Watcher）。
    *   所以 ID 大小：**Computed < User < Render**。

2.  **刷新队列**：
    *   当数据变化，Watcher 们被推入更新队列。
    *   Vue 在执行更新前，会把队列里的 Watcher 按照 `id` **从小到大排序**。

**为什么要这个顺序？**
1.  **Computed 先于 Render**：确保渲染组件时，计算属性已经是最新的值（或者已经标记为 dirty 准备重算），这样渲染出来的视图才是对的。
2.  **User 先于 Render**：如果你的 `watch` 回调里修改了其他数据，最好在渲染发生**之前**改好，这样可以合并更新，避免渲染两次，或者避免渲染出中间状态。

### 总结

在 Vue 2 的世界里，`Watcher` 是一个打工人类：

*   **Computed Watcher**：负责**缓存**，可以偷懒（Lazy），为了性能。
*   **User Watcher**：负责**业务逻辑**，你是老板，你让它干啥它干啥。
*   **Render Watcher**：负责**刷墙**（更新 DOM），它是最终呈现结果的人。

这三者共同构成了 Vue 响应式系统的闭环。

**是的，绝对会！**

这正是 Vue 响应式系统能够处理**嵌套依赖**的核心机制。

在 Vue 的源码中，这种“切换”是通过一个全局变量 `Dep.target` 和一个**栈（Stack）**结构来实现的。

### 核心机制：Dep.target 栈

Vue 维护了一个栈（Stack），用来记录当前正在“干活”的 Watcher。
*   **入栈 (`pushTarget`)**：当一个 Watcher 准备开始计算或渲染时，它要把自己设为当前的 `Dep.target`，以便数据能收集到它。
*   **出栈 (`popTarget`)**：当它干完活了，就把自己移出，把控制权还给上一个 Watcher。

下面我们具体看看这三种 Watcher 是怎么发生“切换”的。

---

### 最经典的切换场景：渲染 Watcher 嵌套 计算属性 Watcher

假设你有一个模板，它用到了一个计算属性：

```javascript
data() { return { count: 1 } },
computed: {
  double() { return this.count * 2 } // 计算属性 Watcher
}
// 模板: <div>{{ double }}</div>  // 渲染 Watcher
```

**切换过程如下（就像接力赛）：**

1.  **Render Watcher 上场**
    *   Vue 开始渲染组件。
    *   调用 `pushTarget(RenderWatcher)`。
    *   **当前主角：Render Watcher**。

2.  **遇到 computed，发生切换**
    *   渲染代码运行到 `{{ double }}`，需要读取 `double` 的值。
    *   `double` 是一个计算属性，且它是脏的（第一次运行），需要重新计算。
    *   计算属性调用 `double` 的 getter 方法。
    *   **关键点**：调用 `pushTarget(ComputedWatcher)`。
    *   **切换发生！** Render Watcher 被“暂停”（压入栈底），**当前主角变成了 ComputedWatcher**。

3.  **依赖收集**
    *   `double` 的内部代码执行：`return this.count * 2`。
    *   读取了 `this.count`。
    *   `count` 的 Dep 发现当前主角是 **ComputedWatcher**，于是把 ComputedWatcher 记在小本本上。
    *   （注意：此时 Render Watcher 正在休息，`count` 不知道 Render Watcher 的存在，只知道 Computed Watcher）。

4.  **计算完毕，切回原主**
    *   `double` 计算完成，得到值 2。
    *   调用 `popTarget()`。
    *   ComputedWatcher 下场。
    *   **切换发生！** 栈顶弹出了，**当前主角又变回了 Render Watcher**。

5.  **手动补票（这一步很关键）**
    *   `double` 的逻辑结束前，Vue 会做一步操作：如果 ComputedWatcher 发现自己依然被 Render Watcher 关注着，它会告诉 `this.count`：“嘿，除了我，刚才那个 Render Watcher 也要依赖你，你也把它记下来。”
    *   于是，`count` 把 Render Watcher 也记下来了。

### User Watcher 也会切换吗？

**会。**

当你写 `watch: { 'a.b': handler }` 时：

1.  **初始化阶段**：Vue 创建这个 User Watcher。
2.  **求值阶段**：为了知道 `'a.b'` 当前的值是多少（以便后续对比变了没），User Watcher 必须去读取一次 `this.a.b`。
3.  **切换**：在读取 `this.a.b` 之前，Vue 执行 `pushTarget(UserWatcher)`。
4.  **收集**：`a` 和 `b` 的 Dep 收集到这个 User Watcher。
5.  **恢复**：读取完后，`popTarget()`，切回原来的状态。

### 为什么必须“切换”？

如果不切换，就会乱套：

如果 Render Watcher 在渲染时调用了 Computed 属性，而没有把 `Dep.target` 切换成 Computed Watcher，那么：
*   `count` 就会直接把 **Render Watcher** 收集走。
*   `Computed Watcher` 就变成了“孤儿”，它不会被 `count` 收集。
*   结果：当 `count` 变化时，它通知 Render Watcher 更新，但 Computed Watcher 不知道自己过期了（`dirty` 状态没变），Render Watcher 重新渲染时读到的 Computed 值还是旧的缓存。

### 总结

这三种 Watcher 都会进行 **“上台 -> 成为主角(Dep.target) -> 收集依赖 -> 下台”** 的操作。

正是因为有了这个**栈**的设计，Vue 才能完美处理 **渲染组件 -> 依赖计算属性 -> 依赖数据** 这种层层嵌套的关系，保证不管多少层，依赖关系都不会乱。

这是一个非常敏锐的问题！

Vue 之所以能“知道”谁是渲染 Watcher（或者更准确地说，谁是**外层**调用者），靠的正是我们刚才提到的 **栈（Stack）** 结构。

**核心秘密在于：** “补票”这个动作，不是发生在 ComputedWatcher 计算的过程中，而是在它**计算完成并退场（出栈）之后**。

让我们用慢动作回放一下这个过程，你就能看清 Vue 是怎么“变魔术”的。

### 场景重现

假设栈是 `targetStack`，当前正在工作的 Watcher 指针是 `Dep.target`。

#### 第一阶段：渲染 Watcher 进场
1.  开始渲染组件。
2.  **入栈**：RenderWatcher 进场。
    *   `targetStack`: `[RenderWatcher]`
    *   `Dep.target`: **RenderWatcher**

#### 第二阶段：读取 Computed 属性（发生切换）
3.  模板里读到了 `{{ double }}`。
4.  `double` 是脏的，需要重算。
5.  **入栈**：ComputedWatcher 进场计算。
    *   `targetStack`: `[RenderWatcher, ComputedWatcher]`
    *   `Dep.target`: **ComputedWatcher**
6.  **收集**：计算代码执行 `this.count * 2`。`count` 的 Dep 收集了当前的 `Dep.target`（即 ComputedWatcher）。

#### 第三阶段：Computed 计算完毕（关键时刻！）
7.  计算出结果 `2`。
8.  **出栈（popTarget）**：ComputedWatcher 说：“我算完了，我撤了。”
    *   它把自己从栈顶移走。
    *   **系统自动把 `Dep.target` 指回栈里的上一个元素**。
    *   此时的状态变成了：
        *   `targetStack`: `[RenderWatcher]`
        *   `Dep.target`: **RenderWatcher** （看！RenderWatcher 又回来了）

#### 第四阶段：手动补票（答案就在这里）
9.  在 `double` 的 getter 函数最后，源码里有这样一段逻辑（简化版）：

```javascript
// double 的 getter 函数
function computedGetter() {
  const watcher = this._computedWatchers['double'];

  if (watcher.dirty) {
    watcher.evaluate(); // 这里面发生了上面的 5-8 步：计算 -> 入栈 -> 出栈
  }

  // === 重点来了 ===
  // 此时 watcher.evaluate() 已经执行完了，ComputedWatcher 已经出栈了。
  // 现在的 Dep.target 是谁？是刚才被压在下面的 RenderWatcher！
  
  if (Dep.target) { 
    watcher.depend(); // 这句就是“补票”
  }
  
  return watcher.value;
}
```

10. **执行 `watcher.depend()`**：
    *   ComputedWatcher 虽然下台了，但它内部记住了：“刚才计算的时候，我用到了 `count`。”
    *   它会对 `count` 的 Dep 说：“嘿，`count`，现在的 `Dep.target`（也就是 **RenderWatcher**）也是你的粉丝，快把它加上。”
    *   因为此时 `Dep.target` 恰好指回了 **RenderWatcher**，所以 `count` 就成功把 RenderWatcher 收集进去了。

---

### 总结

Vue 并不是通过“名字”或“标记”来识别 RenderWatcher 的。

它只是利用了**栈的恢复机制**：

1.  ComputedWatcher **入栈**（挡住了 RenderWatcher）。
2.  ComputedWatcher **干活**（收集底层数据依赖）。
3.  ComputedWatcher **出栈**（**RenderWatcher 重新暴露出来，变回了当前的 `Dep.target`**）。
4.  ComputedWatcher 利用自己手里拿着的依赖列表，指挥底层数据：**“把现在台上站着的那个人（RenderWatcher），也加到你们的订阅列表里！”**

所以，不管外层是 RenderWatcher，还是 User Watcher，甚至是另一个 Computed Watcher，只要它在栈里等着，Computed 属性计算完一退场，外层那个自然就露出来了，也就自然被收集了。



<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-watcher)