<div id="chap-method"></div>

[⬆️ 返回目录](#catalog)

## Method

这是一个非常深刻的问题。你感受到的那种“不便”，其实触及了 JavaScript 与 Go（以及 Python、Swift 等语言）在**底层设计哲学**上的根本差异。

简单来说：**在 Go 中，方法（Method）是绑定在类型上的；而在 JavaScript 中，方法只是恰好被赋值给对象属性的普通函数。**

以下是详细的原因分析：

---

### 1. 核心差异：绑定（Binding）的时机

#### Go：静态绑定 / 方法值 (Method Values)

在 Go 中，当你执行 `f := obj.Method` 时，Go 编译器会创建一个“方法值”。这个方法值实际上是一个**闭包**，它自动捕获了 `obj` 作为接收者（Receiver）。

- **结果**：无论你把 `f` 传递到哪里，它都记得它是属于 `obj` 的。

#### JavaScript：动态绑定 (Dynamic Binding)

在 JS 中，`obj.sayHi` 并不是一个绑定了对象的方法，它只是一个**内存地址**，指向一个函数对象。
当你说 `const f = obj.sayHi` 时，你只是把这个函数的地址给了 `f`。

- **结果**：`f` 只是一个孤立的函数，它失去了与 `obj` 的所有联系。`this` 的值直到函数**被运行的那一刻**，根据“谁调用它”来决定。

---

### 2. 为什么 JS 要设计成这样？（设计哲学）

#### A. 函数是一等公民（First-class Function）

JS 的初衷是借鉴 Scheme 这种函数式语言。在 JS 看来，函数应该独立于对象存在。

- **好处**：这带来了极大的灵活性。你可以实现**方法借用（Method Borrowing）**。
  ```javascript
  // 我可以把 A 的方法 借给 B 用，而不需要 B 继承 A
  Array.prototype.slice.call(arguments);
  ```
  如果方法在定义时就死死绑定了 `this`，这种灵活性就消失了。

#### B. 节省内存

在 JS 早期，如果在创建每个对象时都自动为它的所有方法创建一个“绑定了 `this` 的新函数”，会造成巨大的内存开销。

- 通过让 `this` 在运行时动态确定，数千个对象可以共享同一个原型链上的函数内存，而不需要为每个实例生成特定的绑定函数。

---

### 3. 历史包袱：JS 没有真正的“类”

Go 从设计之初就有明确的 Receiver 概念。而 JavaScript 早期根本没有 `class`，它只有对象和属性。

在 `obj.method()` 中，那个 `.` 操作符在 JS 里其实承担了两个任务：

1.  找到名为 `method` 的属性。
2.  **顺便**把 `obj` 传入函数作为 `this`。

一旦你把这两步拆开（比如 `const f = obj.method`），第二步的信息就丢失了。

---

### 4. 这种设计带来的痛苦：回调地狱中的 `this`

你可能在 React 或原生 JS 回调中经常遇到这种情况：

```javascript
button.addEventListener("click", obj.handleClick); // 这里的 this 丢了！
```

这是因为 `addEventListener` 内部是直接调用 `handleClick()` 的，没有用 `obj.` 去调用。

---

### 5. 现代 JS 是如何解决的？

虽然底层逻辑没变，但 JS 引入了两种方案来达到类似 Go 的效果：

#### 方案一：`bind()` 方法（手动绑定）

这相当于手动模拟 Go 的行为：

```javascript
const f = obj.method.bind(obj); // 强制返回一个绑定了 this 的新函数
```

#### 方案二：箭头函数（词法作用域绑定）

这是目前最流行的做法。箭头函数**没有自己的 `this`**，它会捕获定义时所在环境的 `this`。

```javascript
class MyClass {
  handleClick = () => {
    console.log(this); // 永远指向实例
  };
}
```

**注意**：箭头函数的原理其实就是闭包，它在创建实例时，通过闭包把 `this` 给“锁死”了。这在逻辑上非常接近 Go 的方法传递。

### 总结对照

| 语言           | 方法的本质             | 传递时的行为                  | 优点                             |
| :------------- | :--------------------- | :---------------------------- | :------------------------------- |
| **Go**         | 带有接收者的特殊函数   | 自动包装成闭包 (Method Value) | 安全、直观、不容易出错           |
| **JavaScript** | 对象属性指向的独立函数 | 只传递函数指针，丢失上下文    | 极度灵活、支持方法借用、节省内存 |

**一句话总结**：JS 的 `this` 是**“运行时调用者”决定**的，而 Go 的方法接收者是**“定义位置”绑定**的。JS 选择灵活性，Go 选择确定性。

理解箭头函数的原理，不能仅仅把它看作是普通函数的“缩写”。它的底层实现逻辑与普通函数有本质区别。

我们可以从 **“作用域链”**、**“编译转换”** 和 **“内部结构”** 三个维度来深入拆解。

---

### 1. 核心原理：词法作用域（Lexical Scope）

普通函数的 `this` 是 **动态绑定** 的（谁调用指向谁），而箭头函数的 `this` 是 **静态绑定** 的。

**原理：** 箭头函数内部根本没有 `this`。
当你访问箭头函数内部的 `this` 时，JavaScript 引擎会像查找普通变量一样，顺着 **作用域链（Scope Chain）** 向外层寻找。

- **普通函数**：像是一个带保险柜（有自己的 `this` 存储空间）的房间。
- **箭头函数**：像是一个透明的玻璃房，里面没有保险柜。如果你要在里面用保险柜（`this`），你必须去客厅（外层作用域）找。

---

### 2. 编译后的真相：Babel 转换

理解原理最直观的方法是看 ES6 代码如何被转换成 ES5。

**ES6 代码：**

```javascript
const obj = {
  name: "阿强",
  sayHi: function () {
    setTimeout(() => {
      console.log(this.name);
    }, 1000);
  },
};
```

**Babel 转换后的 ES5 代码（原理等价）：**

```javascript
var obj = {
  name: "阿强",
  sayHi: function () {
    var _this = this; // 1. 在外层作用域先捕获 this
    setTimeout(function () {
      console.log(_this.name); // 2. 内部函数通过闭包引用这个 _this
    }, 1000);
  },
};
```

**结论：** 箭头函数的 `this` 实际上是通过 **闭包** 机制实现的。它在定义的那一刻，就“捕获”了外层环境的 `this`，并永久引用它。

---

### 3. 内部结构的缺失：没有 `[[Construct]]`

在 JavaScript 引擎内部，普通函数具有复杂的结构，而箭头函数是“轻量化”的。

- **普通函数**：拥有内部方法 `[[Call]]`（用于直接调用）和 **`[[Construct]]`**（用于 `new` 调用）。
- **箭头函数**：**没有 `[[Construct]]` 方法**。

**这导致了以下三个底层特性：**

1.  **不能被 `new`**：因为没有 `[[Construct]]`，如果你尝试 `new () => {}`，JS 会直接抛出错误。
2.  **没有 `prototype` 属性**：既然不能被 `new`，也就不需要作为“模具”来产生实例，所以它干脆没有 `prototype` 属性，节省内存。
3.  **不能改变 `this`**：因为箭头函数内部根本没有自己的 `this` 变量，所以即使你使用 `call`、`apply` 或 `bind`，也无法强行塞入一个 `this`。它们会被忽略。

---

### 4. 为什么没有 `arguments`？

和 `this` 的原理一样，箭头函数内部也没有 `arguments` 对象。

如果你在箭头函数里用了 `arguments`，它其实拿的是**外层非箭头函数**的 `arguments`。

```javascript
function outer() {
  const inner = () => {
    console.log(arguments[0]); // 这里拿的是 outer 的参数
  };
  inner();
}
outer("Hello"); // 输出 'Hello'
```

**底层原因：** 同样是为了追求极致的轻量化和性能，避免为每个小函数都创建沉重的参数追踪对象。

---

### 5. 总结：箭头函数的“三无”身份

为了理解它的原理，你可以记住它是 **“三无产品”**：

1.  **无 `this`**：通过作用域链找外层的 `this`（闭包）。
2.  **无 `arguments`**：通过作用域链找外层的 `arguments`。
3.  **无 `prototype`（也就无 `new`）**：因为它不是设计用来当构造函数的。

### 什么时候用它？

- **用箭头函数**：当你希望函数内部的 `this` 与外部环境保持一致时（如定时器回调、Promise 回调、数组方法回调）。
- **不用箭头函数**：
  1.  定义对象的方法时（因为你通常希望 `this` 指向该对象本身）。
  2.  需要使用 `arguments` 时。
  3.  需要动态绑定 `this` 时。

**一句话本质：** 箭头函数是把 **函数** 和 **定义它时所在的环境** 强行“焊接”在了一起。

要理解 JavaScript 中 `this` 的原理，不能把它看作一个普通的变量，而要把它看作**执行上下文（Execution Context）的一个属性**。

`this` 的本质是：**它是函数在调用时，由 JavaScript 引擎传入的一个“隐式参数”，指向该函数执行时的环境对象。**

以下从底层逻辑、执行上下文和绑定规则三个层面深入探讨：

---

### 1. 核心底层逻辑：执行上下文（Execution Context）

每当 JavaScript 执行一段代码时，它都会创建一个“执行上下文”。每个执行上下文由三部分组成：

1.  **变量环境（Variable Environment）**：存储 `var` 声明。
2.  **词法环境（Lexical Environment）**：存储 `let`、`const` 声明和函数。
3.  **ThisBinding（This 绑定）**：**这就是 `this` 的来源。**

**关键结论：** `this` 是在函数**被调用（Call）**的时候，根据调用方式动态确定并存入 `ThisBinding` 的，而不是在编写代码（定义）时确定的。

---

### 2. 为什么需要 `this`？（设计意图）

如果没有 `this`，我们想让一个函数针对不同的对象工作，就必须显式地把对象作为参数传进去：

```javascript
function identify(context) {
  return context.name.toUpperCase();
}
identify(me); // 必须传参
identify(you);
```

`this` 提供了一种更优雅的方式：它允许**函数自动引用合适的上下文对象**。这让代码更简洁，且更易于在不同对象间复用函数。

---

### 3. `this` 的四种绑定规则（确定原理）

JS 引擎通过以下四种规则来决定执行上下文中的 `ThisBinding` 指向谁：

#### ① 默认绑定（Default Binding）

- **场景**：独立函数调用，如 `foo()`。
- **原理**：在非严格模式下，`this` 指向全局对象（浏览器里是 `window`）；严格模式下指向 `undefined`。
- **本质**：这是最底层的兜底机制。

#### ② 隐式绑定（Implicit Binding）

- **场景**：作为对象的方法调用，如 `obj.foo()`。
- **原理**：当函数引用有“上下文对象”时，`this` 绑定到这个对象。
- **注意**：它只看**最后一层**调用。比如 `obj1.obj2.foo()`，`this` 指向 `obj2`。

#### ③ 显式绑定（Explicit Binding）

- **场景**：使用 `call`、`apply`、`bind`。
- **原理**：JS 引擎在底层通过第一个参数强行指定执行上下文中的 `ThisBinding`。
- **本质**：直接插手引擎的赋值过程。

#### ④ `new` 绑定（new Binding）

- **场景**：`new MyClass()`。
- **原理**：当 `new` 发生时，引擎会：
  1. 创建一个新对象。
  2. **将这个新对象绑定到函数调用的 `this`。**
  3. 执行代码并返回新对象。

---

### 4. 深度进阶：ECMAScript 规范中的“引用类型”（Reference Type）

如果你想知道“最底层”的真相，`this` 是通过规范中的一个内部类型 **Reference Type** 来确定的。

当你调用 `obj.foo()` 时，`obj.foo` 的结果其实是一个 Reference Type，它由三部分组成：

- `base`: `obj` (所属对象)
- `name`: `foo` (属性名)
- `strict`: `false`

**原理：** 当 JS 引擎看到后面有 `()` 执行符时，它会检查左侧是不是 Reference Type。如果是，它就提取 `base` 的值（即 `obj`），并将其作为 `this` 传入函数。

_如果你写 `(var f = obj.foo)();`，赋值操作会导致 Reference Type 丢失，变成孤立的函数值，`this` 就变成了默认绑定。_

---

### 5. 异类：箭头函数（Arrow Functions）

**箭头函数不遵循以上任何规则。**

- **原理**：箭头函数在创建时，不会在执行上下文中生成 `ThisBinding`。
- **查找机制**：它内部的 `this` 完全取决于**词法作用域（Lexical Scope）**。JS 引擎会顺着作用域链向外层查找，直到找到第一个拥有 `this` 的普通函数执行上下文，然后“借用”它。
- **不可更改性**：因为它根本没有 `ThisBinding` 属性，所以 `call`、`bind` 对它完全无效。

---

### 总结

`this` 的原理可以总结为：

1.  **动态性**：它是函数调用时的“现场快照”。
2.  **上下文属性**：它是执行上下文对象里的一个 key。
3.  **调用者决定**：JS 引擎根据“谁发起了这次调用”来动态给 `this` 赋值（除了箭头函数）。
4.  **对象关联**：它存在的意义是建立函数与数据对象之间的逻辑纽带，实现代码的高度复用。
5.  要理解 `bind` 是如何解决 `this` 指向问题的，以及那个 `this` 到底存在哪里，我们需要从 **“闭包机制”** 和 **“引擎内部结构”** 两个层面来看。

### 1. `bind` 的解决思路：包装与硬绑定

`bind` 并不是修改了原函数，而是**产生了一个全新的函数（包装函数）**。

当你执行 `const boundFunc = obj.sayHi.bind(obj)` 时，`bind` 在内部做了一件事：
它把原函数 `sayHi` 和你指定的 `obj` 像**焊接**一样焊在了一起，返回给你一个全新的函数。

**这个新函数的逻辑伪代码如下：**

```javascript
// boundFunc 内部大概长这样：
function boundFunc() {
  // 无论谁调用我，我都强制用 apply 把 this 指向当初绑定的那个 obj
  return originalFunc.apply(obj, arguments);
}
```

所以，即便你把 `boundFunc` 传给 `setTimeout` 或者丢到全局执行，它内部执行的依然是 `apply(obj)`。这就是为什么 `bind` 能“锁死” `this`。

---

### 2. 绑定的 `this` 保存在哪里？

这里有两种解释：一种是看得见的**代码层面**，一种是看不见的**引擎底层**。

#### A. 代码层面：保存在“闭包”里（Closure）

如果你手动实现一个 `bind`，你会发现绑定的 `this` 实际上变成了**闭包变量**。

```javascript
Function.prototype.myBind = function (targetThis) {
  const self = this; // 原函数
  return function () {
    // targetThis 就是传进来的那个对象
    // 它被保存在了外层函数的作用域里，形成了一个闭包
    return self.apply(targetThis, arguments);
  };
};
```

在这种情况下，`targetThis` 保存在**返回函数的词法环境（Lexical Environment）**中。只要 `boundFunc` 还在，这个 `targetThis` 就一直存在内存里。

#### B. 引擎底层：保存在“内部槽”里（Internal Slots）

在现代 JavaScript 引擎（如 V8）中，`bind` 返回的函数被称作 **“绑定函数异质对象” (Bound Function Exotic Object)**。

它不像普通函数那样去查找执行上下文，它在内存结构中拥有专门的**内部槽（Internal Slots）**：

- **`[[BoundThis]]`**：存储你传进去的第一个参数（即锁死的 `this`）。
- **`[[BoundTargetFunction]]`**：存储被绑定的原函数。
- **`[[BoundArguments]]`**：存储预设的参数。

当你调用这个绑定函数时，引擎会直接从这些内部槽里把 `[[BoundThis]]` 取出来，作为该函数执行时的 `this`。

---

### 3. 为什么 bind 之后 call 就失效了？

这也是面试常考题。如果你写 `const f = func.bind(obj1).call(obj2)`，结果 `this` 依然是 `obj1`。

**原因就在于 `bind` 的原理：**
由于 `bind` 返回的是一个包装函数，内部已经写死了 `func.apply(obj1)`。
当你尝试用 `call(obj2)` 去调用这个包装函数时，你改变的是**包装函数本身**的 `this`。但是包装函数内部根本没用到它自己的 `this`，它依然执行的是 `func.apply(obj1)`。

**就像这样：**

```javascript
function boundFunc() {
  // 你改包装函数的 this 没用，因为我里面手动指定了用 obj1
  return originalFunc.apply(obj1);
}
```

---

### 4. 总结：bind 解决问题的本质

1.  **本质**：通过**闭包**（代码层）或**内部槽**（引擎层）将目标对象持久化。
2.  **位置**：存储在返回函数的可访问作用域中，或者专门的 `[[BoundThis]]` 属性里。
3.  **结果**：将原本动态的 `this` 变成了**静态**的配置，从而解决了函数在传递过程中丢失上下文的问题。

这就是为什么 `bind` 被称为“硬绑定”。它通过一个中间层，阻断了 `this` 的动态查找过程。

这个概念其实非常有用，它是 `bind` 除了绑定 `this` 之外的第二个大招：**参数预设（Partial Application，偏函数应用）**。

简单来说，`bind` 不仅可以帮你“锁死” `this`，还可以帮你**“锁死”一部分参数**。

---

### 1. 举个直观的例子

假设你有一个求和函数：

```javascript
function sum(a, b) {
  return a + b;
}
```

现在，你想创建一个专门用来“加 10”的函数。你不需要重新写逻辑，只需要用 `bind`：

```javascript
// 第一个参数 null 是因为我们不需要绑定 this
// 第二个参数 10，就是预设的参数，它会被存入 [[BoundArguments]]
const addTen = sum.bind(null, 10);

// 调用时，我们只传一个参数
console.log(addTen(5)); // 输出 15
```

### 2. 执行流程：它是怎么工作的？

当你执行 `addTen(5)` 时，JS 引擎内部发生了以下合并动作：

1.  **取出预设参数**：引擎从 `addTen` 的 `[[BoundArguments]]` 槽位里取出 `[10]`。
2.  **获取新参数**：引擎拿到你调用时传进去的参数 `[5]`。
3.  **合并参数列表**：引擎把它们拼在一起，变成 `[10, 5]`。
4.  **最终执行**：引擎执行原函数 `sum`，并把合并后的参数传进去：`sum(10, 5)`。

**所以，`[[BoundArguments]]` 就像是一个“预装包”，你每次调用新函数时，它都会自动把包里的东西塞在最前面。**

---

### 3. 生活中的类比：自动咖啡机

想象一个自动咖啡机函数 `makeCoffee(beanType, sugarAmount)`。

- **普通调用**：你每次都要选“蓝山豆”和“两勺糖”。
- **使用 `bind` 预设**：
  - 你买了一台“常客机器”，设置好了 `beanType` 永远是“蓝山”。
  - 这个“蓝山”设置就存放在机器的 **`[[BoundArguments]]`** 存储位里。
- **最终调用**：你以后只需要按一下“加几勺糖”的按钮（传剩余参数），咖啡机就会自动结合预设的“蓝山”给你出咖啡。

---

### 4. 这个特性有什么用？

在实际开发中，这非常有用：

#### A. 简化重复调用

如果你经常调用一个函数，且前几个参数总是一样的，你可以用 `bind` 封装一个更简单的版本。

#### B. 在循环/回调中传参

比如在 React 或原生 JS 的事件监听中：

```javascript
// 假设有 10 个删除按钮，点击时需要传对应的 ID
buttons.forEach((btn) => {
  // 预设好当前按钮的 ID
  btn.onclick = deleteItem.bind(null, item.id);
});

function deleteItem(id) {
  console.log("正在删除：", id);
}
```

如果没有 `bind` 的参数预设功能，你可能需要写很麻烦的匿名函数。

### 总结

- **`[[BoundThis]]`**：帮你记住了 **“谁”** 来执行（上下文）。
- **`[[BoundArguments]]`**：帮你记住了 **“先传哪几个参数”**（预设值）。

这两者结合，让 `bind` 变成了一个非常强大的**函数工厂**，可以根据一个通用函数，“批量定制”出各种功能略有不同的专用函数。

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-method)
