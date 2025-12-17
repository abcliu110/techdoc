<div id="chap-thread"></div>

[⬆️ 返回目录](#catalog)


## js线程



这是一个非常经典且触及前端核心原理的问题。要真正理解 Vue 的渲染机制和 `nextTick` 原理，必须先彻底吃透 JavaScript 的**单线程（Single Thread）**和**事件循环（Event Loop）**。

下面我将分三部分深入讲解：
1.  **JS 运行机制：** 单线程与事件循环的底层逻辑。
2.  **宏任务与微任务：** 执行顺序的关键差异。
3.  **Vue 的结合：** 异步更新队列与 `nextTick` 的源码级原理。

---

### 第一部分：JavaScript 的单线程与事件循环

#### 1. 为什么是单线程？
JavaScript 最初是为了浏览器交互而设计的。假设 JS 是多线程的，一个线程在删除 DOM 节点，另一个线程在编辑该节点，浏览器该听谁的？为了避免复杂的同步问题，JS 选择了单线程。

**这意味着：在同一时间，只能执行一段代码。**

#### 2. 浏览器是多线程的
虽然 JS 引擎（如 V8）是单线程的， but 浏览器宿主环境是多线程的。它包含：
*   **GUI 渲染线程**（负责绘图，与 JS 线程互斥）
*   **JS 引擎线程**
*   **定时器触发线程**
*   **HTTP 请求线程**
*   **事件触发线程**

#### 3. 运行模型
1.  **调用栈 (Call Stack)**：所有同步代码都在这里执行，后进先出。
2.  **任务队列 (Task Queue)**：异步操作（如 `setTimeout`、`Promise`）完成后，回调函数会放入这里等待。
3.  **事件循环 (Event Loop)**：JS 引擎不停地检查：
    *   *“调用栈空了吗？”*
    *   *“如果空了，去任务队列拿一个任务放到栈里执行。”*

---

### 第二部分：宏任务 (Macro) vs 微任务 (Micro)

为了更精细地控制执行顺序，任务队列被分为两类。这是理解 Vue 优化的关键。

| 类型 | 代表 API | 执行时机 |
| :--- | :--- | :--- |
| **微任务 (MicroTask)** | `Promise.then`, `process.nextTick`(Node), `MutationObserver`, `queueMicrotask` | **当前同步代码执行完，渲染之前**，立即执行所有微任务。 |
| **宏任务 (MacroTask)** | `setTimeout`, `setInterval`, `setImmediate`, I/O, UI Rendering | **微任务清空后**，取出一个宏任务执行。 |

**执行顺序口诀：**
1.  执行同步代码（清空调用栈）。
2.  执行**所有**微任务（MicroTasks）。
3.  **尝试进行 UI 渲染**（浏览器决定是否需要更新屏幕）。
4.  执行**一个**宏任务（MacroTask）。
5.  回到第 1 步。

**代码演示：**
```javascript
console.log('1. 同步开始');

setTimeout(() => {
  console.log('5. setTimeout (宏任务)');
}, 0);

Promise.resolve().then(() => {
  console.log('3. Promise (微任务)');
});

console.log('2. 同步结束');

// 输出顺序：1 -> 2 -> 3 -> 5
// 注意：UI 渲染通常发生在 3 和 5 之间
```

---

### 第三部分：Vue 框架中的深度结合

Vue 的核心特性之一是**响应式系统**。当你修改数据时（`this.message = 'hello'`），视图并不会立即更新。Vue 利用事件循环机制实现了**异步批量更新**。

#### 1. Vue 的痛点：性能与重复计算
假设你有如下代码：
```javascript
// data: { count: 0 }
this.count = 1;
this.count = 2;
this.count = 3;
```
如果没有异步更新策略，每次赋值都会触发 Setter -> 通知 Watcher -> 触发 Render -> 修改 DOM。这会导致 DOM 被连续修改 3 次，极度消耗性能。

#### 2. Vue 的解决方案：异步更新队列
Vue 内部有一个 **Scheduler（调度器）**。

1.  **侦测变化**：当数据变化，Setter 通知 Dep，Dep 通知 Watcher。
2.  **入队**：Watcher 并不立即执行更新，而是将自己推入一个**队列**。
3.  **去重**：如果同一个 Watcher 被多次触发（如上面的 `count` 变了 3 次），队列中只保留一次该 Watcher。
4.  **Flush（刷新）**：Vue 会在内部调用一个 `nextTick` 方法，将“刷新队列”这个操作注册为异步任务。

#### 3. 为什么 Vue 优先使用微任务？
**关键点来了：**
Vue 优先使用 `Promise.then` (微任务) 来执行队列刷新。

*   **流程**：
    1.  JS 修改数据（同步）。
    2.  Vue 将 Watcher 推入队列（同步）。
    3.  Vue 注册微任务 `flushSchedulerQueue`（同步）。
    4.  JS 主线程结束。
    5.  **事件循环检查微任务队列 -> 执行 `flushSchedulerQueue` -> 计算 Virtual DOM -> 更新真实 DOM。**
    6.  **浏览器进行 UI 渲染。**

*   **好处**：微任务会在**UI 渲染之前**执行。这意味着 JS 计算完 DOM 差异并更新 DOM 树后，浏览器才开始绘制。用户只会看到最终结果（`count = 3`），不会看到中间态，且避免了不必要的重绘（Repaint）和回流（Reflow）。

*   **如果用宏任务（如 setTimeout）会怎样？**
    浏览器可能会先渲染一次旧数据（或空白），然后再执行宏任务更新 DOM，导致 UI 闪烁。

#### 4. 深入 `Vue.nextTick` / `this.$nextTick`

`nextTick` 本质就是对事件循环机制的封装。它的作用是：**将回调函数推入到微任务队列（优先）中。**

**源码逻辑简述 (Vue 2/3 通用概念)：**

```javascript
let callbacks = [];
let pending = false;

function flushCallbacks() {
  pending = false;
  const copies = callbacks.slice(0);
  callbacks.length = 0;
  // 执行所有排队的回调
  for (let i = 0; i < copies.length; i++) {
    copies[i]();
  }
}

// 降级策略（Vue 2 中较复杂，Vue 3 主要用 Promise）
let timerFunc;
if (typeof Promise !== 'undefined') {
  const p = Promise.resolve();
  timerFunc = () => {
    p.then(flushCallbacks); // 使用微任务
  };
} else {
  // 降级到 setTimeout (宏任务)
  timerFunc = () => {
    setTimeout(flushCallbacks, 0);
  };
}

export function nextTick(cb) {
  callbacks.push(cb);
  if (!pending) {
    pending = true;
    timerFunc(); // 触发异步执行
  }
}
```

#### 5. 实战场景分析

请看下面的 Vue 代码，结合事件循环分析：

```javascript
<template>
  <div id="text">{{ message }}</div>
</template>

<script>
export default {
  data() {
    return { message: '旧消息' };
  },
  methods: {
    updateMessage() {
      // 1. 修改数据
      this.message = '新消息'; 
      // 此时：DOM 还没变！Watcher 刚进入 Vue 的更新队列。
      
      console.log(this.$el.textContent); 
      // 输出：'旧消息'
      // 原因：同步代码还没执行完，Vue 的微任务还没运行。

      // 2. 使用 nextTick
      this.$nextTick(() => {
        // 这个回调被加到了微任务队列的末尾（在 Vue 内部更新 DOM 的微任务之后）
        console.log(this.$el.textContent);
        // 输出：'新消息'
      });
    }
  }
}
</script>
```

**时间轴解析：**
1.  **Call Stack**: `this.message = '新消息'` 执行。Vue 侦测到变化，将“更新组件”的任务 push 到内部队列。Vue 注册一个微任务 M1 来处理这个队列。
2.  **Call Stack**: `console.log` (同步) -> 打印 '旧消息'。
3.  **Call Stack**: `this.$nextTick(callback)` 执行。Vue 将用户的 `callback` 包装后，push 到内部回调列表。注意，通常这会复用同一个微任务 M1，或者追加一个微任务 M2（取决于实现细节，通常是维护一个 callbacks 数组，都在 M1 中执行）。
4.  **Call Stack**: 清空。
5.  **MicroTask Queue**:
    *   执行 M1（Vue 的 flush）：Watcher 工作，Virtual DOM Patch，**真实 DOM 节点被更新**（此时 DOM 树变了，但还没画到屏幕上）。
    *   执行 `nextTick` 的回调：`console.log` -> 打印 '新消息'。
6.  **UI Render**: 浏览器将更新后的 DOM 画到屏幕上。

### 总结

1.  **JS 单线程**：决定了必须通过异步队列处理耗时任务。
2.  **事件循环**：决定了 **微任务(Promise)** 优于 **宏任务(setTimeout)** 执行，且微任务在 **UI 渲染前**。
3.  **Vue 的策略**：
    *   利用 **微任务** 缓冲数据变更，实现**批量去重更新**，保证高性能。
    *   **`nextTick`** 让你有机会插入代码到这个“更新后，渲染前”的时间缝隙中（或者紧随更新之后），从而操作最新的 DOM。

理解了这一点，你就明白了为什么在 Vue 中修改数据后不能立马获取 DOM 高度，以及为什么 `nextTick` 是解决此类问题的唯一标准答案。

这是一个非常核心的计算机科学概念在前端领域的具体体现。要彻底搞懂 JS 的运行机制，我们可以把它想象成一家**“非常繁忙但只有一名厨师的餐厅”**。

下面我将拆解每一个组件：**调用栈（Call Stack）**、**Web APIs**、**任务队列（Task Queue）** 以及 **事件循环（Event Loop）**。

---

### 一、 核心组件图解

#### 1. 调用栈 (Call Stack) —— 唯一的“厨师”
JavaScript 引擎（如 V8）是单线程的，这意味着它只有一个调用栈。
*   **特性**：**LIFO**（Last In, First Out，后进先出）。
*   **作用**：记录当前代码执行到了哪里。
*   **工作方式**：
    *   当进入一个函数时，把这个函数“推入”（Push）栈顶。
    *   当函数执行结束（return），把它从栈顶“弹出”（Pop）。
*   **形象比喻**：这是厨房里唯一的**厨师**。他一次只能切一个菜，必须切完这个才能切下一个。

#### 2. Web APIs —— “服务员/外包团队”
如果厨师遇到一道需要炖 1 小时的汤（比如 `setTimeout` 或 `AJAX` 请求），如果他在那儿干等 1 小时，整个餐厅就瘫痪了（页面卡死）。
所以，浏览器（宿主环境）提供了额外的线程来处理这些耗时操作。
*   **包含**：`setTimeout`、`DOM Events`、`Fetch/XHR`。
*   **作用**：在后台处理异步任务，**不占用主线程**。
*   **形象比喻**：厨师把炖汤的任务交给**帮厨（Web APIs）**，自己立刻去切下一个菜。

#### 3. 任务队列 (Task Queue) —— “点单列表”
当 Web APIs 完成任务（比如定时器时间到了，或者接口数据回来了），回调函数不会立马回到调用栈（怕打断厨师正在切菜），而是去队列里排队。
*   **宏任务队列 (Macro Task Queue)**：存放 `setTimeout`, `setInterval`, UI 渲染等。
*   **微任务队列 (Micro Task Queue)**：存放 `Promise.then`, `MutationObserver` 等。
*   **形象比喻**：帮厨把做好的汤的单子贴在**“待上菜列表”**上，等待厨师空闲时来取。

#### 4. 事件循环 (Event Loop) —— “领班/调度员”
这是连接“调用栈”和“任务队列”的桥梁。
*   **原理**：它是一个无限循环的机制。
*   **工作流程**：
    1.  检查**调用栈**是不是空的？
    2.  如果**不是空的**：什么都不做，继续等（同步代码优先）。
    3.  如果**是空的**：
        *   先看看**微任务队列**有没有任务？有就全部执行完。
        *   再看看**宏任务队列**有没有任务？拿出一个来执行。

---

### 二、 深度运行流程演示

让我们通过一段经典代码来演示这个过程：

```javascript
console.log('1. Start'); // 同步

setTimeout(() => {
    console.log('2. Timeout'); // 宏任务
}, 0);

Promise.resolve().then(() => {
    console.log('3. Promise'); // 微任务
});

console.log('4. End'); // 同步
```

#### 详细步骤分析：

**Step 1: 同步代码入栈**
*   `console.log('1. Start')` 入栈 -> 执行打印 -> 出栈。
*   **输出：`1. Start`**

**Step 2: 遇到 setTimeout**
*   `setTimeout` 入栈。
*   JS 引擎识别出这是异步操作，通知 **Web APIs**：“起一个 0ms 的定时器”。
*   `setTimeout` 立刻出栈（任务移交了）。
*   **Web APIs**：定时器立即结束，将回调函数 `() => { console.log('2. Timeout') }` 放入 **宏任务队列**。

**Step 3: 遇到 Promise**
*   `Promise.resolve().then(...)` 入栈。
*   JS 引擎识别出这是 Promise，将 `.then` 里的回调函数 `() => { console.log('3. Promise') }` 放入 **微任务队列**。
*   代码出栈。

**Step 4: 同步代码继续**
*   `console.log('4. End')` 入栈 -> 执行打印 -> 出栈。
*   **输出：`4. End`**

**Step 5: 此时调用栈空了！事件循环介入**
*   **领班（Event Loop）** 看到厨师（Call Stack）闲下来了。
*   **第一优先级**：检查**微任务队列**。
    *   发现有个 Promise 回调。
    *   把它推入调用栈执行。
    *   **输出：`3. Promise`**
    *   微任务队列清空。
*   **第二优先级**：(浏览器尝试渲染 UI)。
*   **第三优先级**：检查**宏任务队列**。
    *   发现有个 setTimeout 回调。
    *   把它推入调用栈执行。
    *   **输出：`2. Timeout`**

---

### 三、 关键难点：栈溢出与阻塞

#### 1. 栈溢出 (Stack Overflow)
既然栈的大小是有限的，如果一直 Push 不 Pop，就会炸。
最典型的就是**死循环递归**：

```javascript
function foo() {
    foo(); // 无限调用自己
}
foo();
```
浏览器报错：`Maximum call stack size exceeded`。就像盘子叠太高倒塌了。

#### 2. 阻塞 (Blocking)
如果栈里有一个同步任务执行时间极长，会发生什么？

```javascript
// 假设这里有个耗时 10 秒的同步循环
function heavyTask() {
    let i = 0;
    while(i < 10000000000) { i++ } 
}
heavyTask();
```
*   因为 `heavyTask` 在栈里没出来，Event Loop 无法把任何点击事件、渲染任务放入栈中。
*   **结果**：网页点击没反应，无法滚动，这就叫“卡死”。
*   **解决**：把耗时任务拆分成小块，利用 `setTimeout` 或 `Promise` 放到异步队列里，让主线程有机会喘息（处理渲染）。

---

### 四、 总结：Event Loop 的标准模型

心中要始终有一张图：

1.  **Main**：所有同步代码都在主线程（调用栈）执行。
2.  **Async**：遇到异步，交给 Web API，完成后放入队列。
3.  **Loop**：
    *   主线程空了？
    *   **NO** -> 继续干活。
    *   **YES** ->
        1.  清空**所有**微任务 (Microtasks)。
        2.  (可选) 渲染页面 (UI Rendering)。
        3.  执行**一个**宏任务 (Macrotask)。
        4.  回到第 1 步。

这就是为什么 `Promise` (微任务) 总是比 `setTimeout` (宏任务) 快，也是 Vue `nextTick` 能精准控制 DOM 更新时机的底层原理。


**你说得非常到位！本质上就是这样一个过程。**

简单来说，**浏览器的主线程（或者 Node.js 主线程）就是一个由宿主环境提供的“死循环”**。

为了让你对这个“死循环”有更透彻的理解，我们可以从**底层实现**（浏览器是用 C++ 写的）和**逻辑表现**两个层面来剖析。

---

### 1. 底层伪代码：它长什么样？

如果我们把浏览器的源码简化成一段伪代码，它大概是这样的：

```javascript
// 浏览器主线程的“心脏”
while (true) {
  // 1. 如果任务队列里有任务，取出来执行
  if (taskQueue.hasTask()) {
    const task = taskQueue.pop();
    execute(task); // 这里就是执行你的 JS 代码
  }
  
  // 2. 检查并清空微任务（Vue 的 nextTick 就在这里）
  while (microTaskQueue.hasTask()) {
    const microTask = microTaskQueue.pop();
    execute(microTask);
  }

  // 3. 到了该渲染的时候吗？（通常一秒 60 次）
  if (shouldRender()) {
    renderUI(); // 重绘页面
  }

  // 4. 关键点：如果上面都没事干，线程会“休眠”等待，而不是空转烧 CPU
  if (noTasksLeft()) {
    waitForTask(); // 挂起，等待新的事件（点击、网络回调等）唤醒
  }
}
```

### 2. 这个“死循环”的三个关键特征

#### 特征一：它是“有节奏”的
这个循环运行一圈，被称为一个 **Tick**。
*   你写的同步代码，是在步骤 1 里执行的。
*   `Promise.then`，是在步骤 2 里执行的。
*   `setTimeout`，是下一圈（或几圈后）的步骤 1 里执行的。

#### 特征二：它是“阻塞式”的等待（并非疯狂空转）
当你理解“死循环”时，可能会担心 CPU 占用率 100%。
其实不会。
*   **当队列为空时**：主线程会进入**休眠状态**（Sleep），几乎不消耗 CPU 资源。
*   **当有新事件时**：比如用户点了个按钮，或者 Ajax 请求回来了，网卡/操作系统会发送信号，“唤醒”主线程，继续下一圈循环。

#### 特征三：你的代码不能写死循环
正因为**Event Loop 本身就是一个死循环**，所以**你的代码必须执行完并退出**，交还控制权。

如果你在 `execute(task)` 这一步里写了：
```javascript
while(true) { console.log(1) }
```
**后果**：
代码卡在了第 1 步，永远走不到第 3 步（渲染页面）。
**现象**：
浏览器页面“卡死”，点击没反应，无法滚动，最后浏览器弹出“页面无响应”的提示。

---

### 3. 为什么 Vue 需要在这个循环里“插队”？

结合你刚才的理解，Vue 的渲染机制就更好懂了。

Vue 的逻辑是：
1.  你修改了数据 `this.count = 2`。
2.  Vue **不会**立刻修改 DOM（因为太慢了，且可能你后面还要改）。
3.  Vue 开启一个 **微任务**（通过 `Promise.resolve().then(...)`）。
4.  主线程继续跑你的后续代码。
5.  **当前宏任务结束，准备渲染前**（也就是伪代码的第 2 步）：
    *   事件循环检查微任务队列。
    *   发现 Vue 存了一个“更新 DOM”的任务。
    *   执行它 -> **DOM 变了**。
6.  进入伪代码第 3 步：浏览器渲染 UI，用户看到新数字。

### 总结

你的理解完全正确：
**主线程就是一个一直在转圈的调度器。**

*   **你的代码（同步）**：是它路上捡到的第一个包袱，必须扛着走完。
*   **微任务**：是它走完这段路后，必须马上清理掉鞋上的泥（必须清空）。
*   **宏任务**：是它下一圈或者下几圈要捡的包袱。
*   **渲染**：是它每隔几圈就要停下来整理一下仪容（绘制页面）。
*   
你的理解已经非常接近真相了，但为了精准起见，我们需要厘清 **“进程（Process）”** 和 **“线程（Thread）”** 的区别，以及它们在浏览器中的层级关系。

简单的结论是：
**一个 Tab 页面（通常）对应一个“渲染进程”。**
**在这个“渲染进程”里，包含着你常听说的“JS 引擎线程”和“GUI 渲染线程”等。**

为了彻底讲清楚，我们用一个**“工厂与车间”**的比喻。

---

### 一、 宏观架构：工厂（进程）与工人（线程）

1.  **进程 (Process) = 工厂**
    *   操作系统分配资源的最小单位。
    *   每个工厂有独立的资源（内存空间），工厂之间相互隔离，一个工厂炸了（崩溃），通常不会影响另一个工厂。
2.  **线程 (Thread) = 工人**
    *   CPU 调度的最小单位。
    *   一个工厂里有多个工人，他们共享工厂的资源，协同工作。

#### 浏览器的多进程架构（以 Chrome 为例）
现代浏览器不仅仅是一个程序，它更像是一个**集团公司**。当你打开一个 Chrome，并在里面开了 3 个 Tab 页，系统里通常会多出好几个进程：

1.  **Browser 进程（主控进程）**：集团总部。负责协调、主控，管理浏览器窗口、地址栏、书签，负责协调其他进程。
2.  **GPU 进程**：负责 3D 绘制加速。
3.  **网络进程**：负责加载网络资源。
4.  **渲染进程（Renderer Process）**：**【重点】这就是你说的“一个 Web 页面”**。
    *   默认情况下，Chrome 会为每个 Tab 页开启一个新的渲染进程。
    *   **JS 的执行、HTML 的解析、页面的渲染，全都在这个进程里。**

---

### 二、 微观剖析：渲染进程内部的“工人们”

当你打开一个页面，系统启动了一个**渲染进程**（工厂）。这个工厂里有几个关键的“工人”（线程）在干活：

#### 1. GUI 渲染线程（装修工）
*   负责解析 HTML、CSS，构建 DOM 树，布局和绘制页面。
*   **注意**：它和 JS 引擎线程是**互斥**的！

#### 2. JS 引擎线程（核心逻辑工）
*   **这就是我们常说的“单线程”的主角**（如 V8 引擎）。
*   负责执行 JavaScript 脚本。
*   在一个渲染进程中，**无论什么时候，只有一个 JS 线程在运行**。

#### 3. 事件触发线程（接待员）
*   归属于浏览器，用来控制事件循环。
*   当鼠标点击、键盘输入时，这个线程会将任务添加到 JS 引擎的任务队列中，等待 JS 线程空闲时处理。

#### 4. 定时触发器线程（闹钟）
*   `setTimeout` 和 `setInterval` 所在线程。
*   因为 JS 线程太忙了，计时的活儿不能让它干。计时完毕后，这个线程把回调扔进任务队列。

#### 5. 异步 HTTP 请求线程（外卖员）
*   处理 AJAX / Fetch 请求。请求回来后，将回调扔进任务队列。

---

### 三、 核心矛盾：JS 线程与 GUI 线程的“互斥关系”

这是前端最需要理解的重点：**JS 引擎线程和 GUI 渲染线程不能同时工作。**

*   **为什么？**
    *   JS 可以操作 DOM（比如把 `width` 从 100px 改成 200px）。
    *   GUI 负责把 DOM 画在屏幕上。
    *   如果两者同时进行：JS 刚改了一半，GUI 正在画，那画出来的页面就是错乱的。
*   **机制**：
    *   当 JS 引擎执行时，GUI 线程会被**挂起**（冻结），GUI 更新会被保存在一个队列中。
    *   只有当 JS 引擎空闲（脚本执行完），GUI 线程才会被激活执行更新。

#### 这个机制带来的后果：
**如果 JS 执行时间过长（死循环或超大计算），GUI 就会一直被挂起，页面就“卡死”了，渲染不出来，动画也不动了。**

这也是为什么 Vue 要搞异步更新，为什么 React 要搞 Fiber（时间切片），本质上都是为了**避免 JS 线程长时间霸占 CPU，让 GUI 线程有机会喘口气去渲染页面**。

---

### 四、 总结：一张图看懂关系

想象你在玩一个**单人**通关的游戏（这就是 JS 主线程）：

1.  **Web 页面** $\approx$ **渲染进程**（一个封闭的游戏房间）。
2.  **JS 线程** = **你（玩家）**。你一次只能做一个动作（单线程）。
3.  **GUI 线程** = **屏幕显示器**。只有当你停下操作（JS 执行结束），屏幕才会刷新显示最新画面。
4.  **其他线程（定时器、网络）** = **助手**。
    *   你说：“助手，3秒后提醒我。”（`setTimeout`）
    *   你继续打怪（执行同步代码）。
    *   助手在旁边计时（定时器线程）。
    *   3秒到了，助手在你手边的清单上写下：“该喝药了”（回调推入任务队列）。
    *   你打完当前的怪（栈空了），看一眼清单，执行喝药操作。

### 回答你的问题

> **“所以一个web页面对应一个浏览器的主线程？”**

更严谨的说法是：
**一个 Web 页面对应一个“渲染进程”。**
在这个进程里，有一个**“主线程（Main Thread）”**，它非常繁忙，既要负责执行 **JS**，又要负责 **DOM 布局**和**绘制**（虽然它们互斥，但都在这个主线程的调度范围内）。

所以当我们说“不要阻塞主线程”时，指的就是：**不要让 JS 运行太久，否则 GUI 没法渲染，用户觉得卡。**


这是一个非常好的想法！为了彻底搞懂，我们不要只看理论，我们来**手写一个简化版的“JS 引擎”类**。

这个类将模拟：
1.  **宏任务队列 (Macro Task Queue)**
2.  **微任务队列 (Micro Task Queue)**
3.  **事件循环 (Event Loop)** 的调度逻辑

我们将完全用同步代码来模拟这个异步过程，这样你就能清晰地看到“谁先谁后”以及“为什么”。

### 1. 模拟代码实现

你可以直接把这段代码复制到浏览器的控制台或者 Node.js 中运行。

```javascript
class MiniBrowserEngine {
  constructor() {
    this.macroTaskQueue = []; // 宏任务队列 (setTimeout)
    this.microTaskQueue = []; // 微任务队列 (Promise, nextTick)
  }

  // 1. 模拟 setTimeout (注册宏任务)
  // 在真实浏览器中，这里会调用 Web API 定时，时间到了才放入队列
  // 为了简化，我们假设时间设为 0，直接放入队列
  mySetTimeout(callback) {
    console.log('【入队】检测到 setTimeout，放入宏任务队列 🐢');
    this.macroTaskQueue.push(callback);
  }

  // 2. 模拟 Promise.then / Vue.nextTick (注册微任务)
  myPromiseThen(callback) {
    console.log('【入队】检测到 Promise/nextTick，放入微任务队列 ⚡');
    this.microTaskQueue.push(callback);
  }

  // 3. 核心：模拟事件循环 (Event Loop)
  // 这是一个简化的模型：执行完所有微任务 -> 渲染 -> 执行一个宏任务
  startEventLoop() {
    console.log('\n🚀 --- 事件循环启动 (Event Loop Start) ---');

    // 只要队列里还有任务，就一直循环
    // 注意：真实浏览器是死循环(while true)，这里为了演示，任务跑完就停
    while (this.macroTaskQueue.length > 0 || this.microTaskQueue.length > 0) {
      
      // A. 阶段一：疯狂清空微任务队列
      // 只要微任务队列不为空，就一直取出来执行，直到清空
      if (this.microTaskQueue.length > 0) {
        const microTask = this.microTaskQueue.shift(); // 取出队头
        console.log('  ⚡ [执行微任务]');
        microTask(); 
        // 关键点：执行完一个微任务后，循环会继续检查微任务队列
        // 如果微任务里又产生新的微任务，会在这里接着执行，绝不让步
        continue; 
      }

      // B. 阶段二：模拟 GUI 渲染 (微任务清空后，宏任务执行前)
      console.log('  🎨 [浏览器尝试 UI 渲染...]');

      // C. 阶段三：执行单个宏任务
      if (this.macroTaskQueue.length > 0) {
        const macroTask = this.macroTaskQueue.shift(); // 取出队头
        console.log('  🐢 [执行宏任务]');
        macroTask();
      }
    }

    console.log('💤 --- 队列空了，主线程休眠 (Event Loop Idle) ---\n');
  }
}

// ==========================================
//              开始测试 (Test Case)
// ==========================================

const browser = new MiniBrowserEngine();

console.log('1. [同步代码] 脚本开始执行');

// 模拟 setTimeout
browser.mySetTimeout(() => {
  console.log('   🐢 宏任务1 (setTimeout) 被执行');
  
  // 宏任务里又产生了一个微任务
  browser.myPromiseThen(() => {
    console.log('   ⚡ 宏任务1里的微任务 (Promise) 被执行');
  });
});

// 模拟 Promise
browser.myPromiseThen(() => {
  console.log('   ⚡ 微任务1 (Promise) 被执行');
});

console.log('2. [同步代码] 脚本执行结束，准备进入循环');

// 启动引擎！
browser.startEventLoop();
```

---

### 2. 运行结果解析

如果你运行上面的代码，输出将会非常清晰地展示执行顺序：

```text
1. [同步代码] 脚本开始执行
【入队】检测到 setTimeout，放入宏任务队列 🐢
【入队】检测到 Promise/nextTick，放入微任务队列 ⚡
2. [同步代码] 脚本执行结束，准备进入循环

🚀 --- 事件循环启动 (Event Loop Start) ---
  ⚡ [执行微任务]
   ⚡ 微任务1 (Promise) 被执行
  🎨 [浏览器尝试 UI 渲染...]
  🐢 [执行宏任务]
   🐢 宏任务1 (setTimeout) 被执行
【入队】检测到 Promise/nextTick，放入微任务队列 ⚡
  ⚡ [执行微任务]
   ⚡ 宏任务1里的微任务 (Promise) 被执行
  🎨 [浏览器尝试 UI 渲染...]
💤 --- 队列空了，主线程休眠 (Event Loop Idle) ---
```

### 3. 代码中的关键原理对应

#### A. 为什么微任务最快？ (Vue nextTick 原理)
看代码中的 `while` 循环逻辑：
```javascript
if (this.microTaskQueue.length > 0) {
    // ...执行微任务
    continue; // 直接跳过后面的渲染和宏任务，回到循环开头再次检查微任务
}
```
这意味着：**只要微任务队列里还有东西，宏任务就永远别想执行，UI 也别想渲染。**
这就是为什么 Vue 把 DOM 更新放在微任务里 —— 它保证了在浏览器画每一帧之前，所有的数据计算和 DOM 变动都已经处理完了。

#### B. 嵌套任务的处理
注意测试代码中的这一段：
```javascript
// 宏任务里又加了一个微任务
browser.mySetTimeout(() => {
    browser.myPromiseThen(...) 
});
```
在模拟器输出中，这个新产生的微任务并没有等到下一个“宏任务周期”，而是**紧接着当前宏任务执行完后，在下一轮渲染前立马执行了**。
这是因为代码回到了 `while` 循环的顶部，再次命中了 `if (this.microTaskQueue.length > 0)`。

#### C. 渲染时机
```javascript
console.log('  🎨 [浏览器尝试 UI 渲染...]');
```
代码展示了渲染发生在 **所有微任务清空之后**，**下一个宏任务开始之前**。
这就是为什么你在 `setTimeout` (宏任务) 里修改 DOM 可能会导致页面闪烁，而在 `Promise` (微任务) 里修改 DOM 则不会。

### 4. 总结

这个简单的 Class 其实就是浏览器 C++ 源码逻辑的 JS 翻译版：

1.  **Call Stack (调用栈)**：就是代码执行的地方（上面的 `microTask()` 和 `macroTask()` 被调用的时刻）。
2.  **Event Loop**：就是那个 `while` 循环。
3.  **Vue 的介入**：Vue 只是简单地调用了 `browser.myPromiseThen(() => updateDOM())`，利用了这个 `while` 循环的特性，实现了插队更新。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-thread)