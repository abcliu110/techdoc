<div id="chap-call-bind"></div>

[⬆️ 返回目录](#catalog)

## call && bind

理解 `call` 和 `bind` 的原理，最简单的方式是尝试**手动实现（手写）**它们。它们的底层核心逻辑其实就是对 JavaScript 中 `this` 指向规则的应用。

---

### 1. `call` 的原理：隐式绑定

`call` 的原理可以概括为一句话：**将函数设置为目标对象的一个临时属性，通过对象调用该函数，最后删除该属性。**

还记得我们说过的吗？“谁调用函数，`this` 就指向谁”。

#### 手写模拟 `myCall`：

```javascript
Function.prototype.myCall = function (context, ...args) {
  // 1. 如果 context 是 null 或 undefined，默认指向 window
  context = context || window;

  // 2. 核心：将当前函数（this）变成 context 的一个临时属性
  // 这里的 this 就是我们要执行的那个函数
  const fnSymbol = Symbol("fn"); // 使用 Symbol 防止属性重名
  context[fnSymbol] = this;

  // 3. 执行函数。此时函数是通过 context.xxx() 调用的
  // 根据 JS 规则，此时函数内部的 this 就会指向 context
  const result = context[fnSymbol](...args);

  // 4. 用完之后删除这个临时属性，不污染原对象
  delete context[fnSymbol];

  // 5. 返回执行结果
  return result;
};
```

**原理总结：** `call` 利用了“对象方法调用”这一规则，动态地把函数“塞”进目标对象里运行，运行完再踢出来。

---

### 2. `bind` 的原理：闭包与柯里化

`bind` 的原理比 `call` 稍微复杂一点，因为它不立即执行，而是返回一个**新函数**。它核心利用了 **闭包 (Closure)**。

#### `bind` 的三个核心要点：

1.  **保存环境**：利用闭包保存 `this` 目标和初始参数。
2.  **返回函数**：返回一个等待执行的包装函数。
3.  **参数合并**：支持在 `bind` 时传一部分参数，在执行新函数时再传剩余参数（这就是所谓的柯里化）。

#### 手写模拟 `myBind`：

```javascript
Function.prototype.myBind = function (context, ...args1) {
  // 1. 保存当前的函数（this）
  const self = this;

  // 2. 返回一个新函数
  return function (...args2) {
    // 3. 当新函数被执行时，利用 apply 把 this 指向 context
    // 并且把 bind 时的参数 (args1) 和执行时的参数 (args2) 合并
    return self.apply(context, [...args1, ...args2]);
  };
};
```

**原理总结：** `bind` 像是一个“包装袋”。它把原函数、目标对象、预设参数统统装进袋子里封好（闭包），然后把这个袋子交给你。当你以后拆开袋子（调用函数）时，它在内部自动帮你完成 `apply` 的动作。

---

### 3. 深度对比：`call` vs `bind` 的底层逻辑

| 特性         | `call` 的底层逻辑           | `bind` 的底层逻辑          |
| :----------- | :-------------------------- | :------------------------- |
| **执行时机** | **立即触发** 对象的调用流程 | **返回闭包**，等待未来触发 |
| **内部机制** | 临时改变对象的属性结构      | 利用闭包持久化存储上下文   |
| **参数处理** | 一次性传入                  | 分段接收，利用数组合并     |
| **返回值**   | 原函数的**执行结果**        | 一个**全新的函数**         |

---

### 4. 进阶细节（面试加分项）

在真实的 JS 引擎（如 V8）中，`bind` 还有一个更复杂的特性：**作为构造函数调用**。

如果 `bind` 返回的函数被当作 `new` 操作符调用（例如 `new boundFunc()`），那么当初 `bind` 绑定的那个 `this` 会**失效**，`this` 反而会指向新创建的实例。

- **简单的 `bind` 实现**：只考虑改变 `this`。
- **完整的 `bind` 实现**：还需要判断返回的函数是否被 `new` 调用了（通过 `this instanceof` 检查），如果是，则不强制绑定 context。

### 总结

- **`call` 的本质**：是“**移花接木**”。强行把函数变成对象的方法来执行。
- **`bind` 的本质**：是“**记忆封装**”。利用闭包把 `this` 和参数锁死在一个新函数里送回给你。

在 JavaScript 中，`call` 和 `bind`（以及 `apply`）的存在，主要是为了解决 **“如何手动控制函数内部 `this` 的指向”** 以及 **“实现代码复用”** 这两个核心问题。

以下是需要这两个方法的具体原因：

---

### 1. 解决 `this` 指向丢失的问题（最常见的原因）

在 JavaScript 中，`this` 的指向是**动态**的，取决于函数如何被调用，而不是如何被定义。这经常导致在回调函数或异步操作中 `this` 指向错误（通常指向全局对象 `window` 或 `undefined`）。

**场景举例：**

```javascript
const person = {
  name: "阿强",
  sayHi: function () {
    setTimeout(function () {
      console.log("你好, 我是" + this.name);
    }, 1000);
  },
};

person.sayHi(); // 输出：你好, 我是undefined
```

- **问题**：`setTimeout` 内部的匿名函数是在全局作用域执行的，此时 `this` 不再指向 `person`。
- **解决（使用 `bind`）**：
  ```javascript
  sayHi: function() {
    setTimeout(function() {
      console.log('你好, 我是' + this.name);
    }.bind(this), 1000); // 强制将 person 对象的 this 绑定给这个函数
  }
  ```

---

### 2. 方法借用 (Method Borrowing)

如果你有一个对象想使用另一个对象的方法，但又不想通过继承来实现，就可以使用 `call`。这体现了 JavaScript 的灵活性，避免了重复定义代码。

**场景举例：**
假设你有一个类数组对象（例如函数的 `arguments` 或 DOM 节点列表），你想对它使用数组的 `map` 方法。由于它不是真正的数组，它没有 `map` 方法。

```javascript
function listArgs() {
  // 借用 Array 原型上的 slice 方法，将 arguments 转为真正的数组
  const args = Array.prototype.slice.call(arguments);
  console.log(args);
}

listArgs(1, 2, 3); // [1, 2, 3]
```

---

### 3. 函数柯里化与预设参数 (仅限 `bind`)

`bind` 不仅可以绑定 `this`，还可以预设函数的参数。它会返回一个新的函数，这个新函数已经“记住”了你传进去的初始参数。

**场景举例：**

```javascript
function multiply(a, b) {
  return a * b;
}

// 创建一个永远乘以 2 的函数
const double = multiply.bind(null, 2);

console.log(double(5)); // 10 (相当于调用 multiply(2, 5))
console.log(double(10)); // 20
```

---

### 4. 显式调用父类构造函数 (类继承)

在 ES6 的 `class` 语法出现之前，开发者使用构造函数实现继承时，必须依靠 `call`。

```javascript
function Animal(name) {
  this.name = name;
}

function Dog(name, breed) {
  // 借用 Animal 的构造函数来初始化 Dog 实例的 name 属性
  Animal.call(this, name);
  this.breed = breed;
}

const myDog = new Dog("旺财", "金毛");
```

---

### 总结：`call` 与 `bind` 的区别

| 方法       | 执行时机     | 返回值             | 参数传递                   |
| :--------- | :----------- | :----------------- | :------------------------- |
| **`call`** | **立即执行** | 函数执行的结果     | 逐个列举 (`arg1, arg2...`) |
| **`bind`** | **延迟执行** | 返回一个**新函数** | 逐个列举 (可分多次传)      |

_(注：还有个 **`apply`**，它和 `call` 唯一的区别是接收参数的方式：`apply` 接收数组 `[arg1, arg2]`)_

### 现代 JS 的变化

虽然 `call` 和 `bind` 非常重要，但在现代开发中，它们的使用频率有所下降，原因如下：

1.  **箭头函数**：箭头函数不绑定 `this`，它会自动捕获定义时所在上下文的 `this`，解决了大部分 `this` 丢失的问题。
2.  **展开运算符 (`...`)**：`func(...args)` 很大程度上替代了 `apply`。
3.  **Class 语法**：`super()` 替代了手动 `Parent.call(this)`。

**一句话总结：** 它们是 JavaScript 灵活性的体现，让你能够**跨越对象边界复用代码**，并**精准锁定函数运行时的环境**。

这两个问题是 JavaScript 初学者最容易困惑的地方，我们用最直白的逻辑和生活中的例子来拆解：

### 1. 为什么 `setTimeout` 的内部函数 `this` 指向全局？

**一句话总结：因为调用这个函数的人是“浏览器系统”，而不是你的对象。**

在 JS 中，`this` 的指向遵循一个金科玉律：**谁调用它，它就指向谁。**

- **常规调用：** 当你执行 `obj.sayHi()` 时，是 `obj` 在调用函数，所以 `this` 指向 `obj`。
- **setTimeout 调用：** 当你执行 `setTimeout(person.sayHi, 1000)` 时，你只是把 `sayHi` 这个函数的“代码地址”告诉了浏览器。1 秒钟时间到了，浏览器引擎会自己在后台默默地执行这段代码。此时，**调用者不再是 `person` 对象，而是全局环境（Window 或 Global）**。

**底层逻辑：**
根据官方规范，`setTimeout` 调用的回调函数，如果没指定 `this`，默认就会被当作普通函数直接执行（类似 `func()` 这样直接喊名字调用），而普通函数直接调用的默认 `this` 就是全局对象。

---

### 2. 什么是“方法借用” (Method Borrowing)？

**生活例子：**
你家里没有梯子，但你邻居王大爷家有。你不需要为了修个灯泡专门去买个梯子（这叫**继承**，太重了），你只需要跟王大爷说：“大爷，**借**你家梯子用一下，在我家支起来。”

**代码里的“借”：**
有些对象（比如“类数组对象”）本身没有数组的方法（如 `map`、`filter`），但我又想用，怎么办？我“借”一个过来。

```javascript
// 一个长得像数组但不是数组的对象
const fakeArray = { 0: "a", 1: "b", length: 2 };

// fakeArray.map(...) 会报错，因为它没这个功能
// 于是我们去数组原型（Array.prototype）借一个
const result = Array.prototype.map.call(fakeArray, (item) =>
  item.toUpperCase(),
);

console.log(result); // ["A", "B"] 成功借用！
```

**为什么要借？** 为了省代码。不需要每个对象都写一遍相同的方法。

---

### 3. 什么是“预设参数” (Currying/Partial Application)？

**生活例子：**
想象一个**自动咖啡机**。

- 普通的函数调用：你每次都要放“豆子”和“水”，按开始，才出咖啡。
- `bind` 的预设：你先把“豆子”倒进去封好（这叫**绑定参数**）。现在这台机器变成了一个“只需要加水就能出咖啡”的**专用机器**。

**代码里的预设：**
`bind` 不仅能绑定 `this`，还能偷偷塞几个参数进去，返回一个功能更具体的新函数。

```javascript
function add(a, b) {
  return a + b;
}

// 我想创造一个专门用来“加10”的函数
const addTen = add.bind(null, 10); // 第一个参数是this(这里不需要填null)，第二个参数10被“锁死”在第一个位置

console.log(addTen(5)); // 15 (相当于执行了 add(10, 5))
console.log(addTen(100)); // 110 (相当于执行了 add(10, 100))
```

**为什么需要它？**
它能帮你把一个“通用的工具”改装成“专门的工具”，让代码更简洁、更语义化。比如在 React 中，你经常需要给不同的按钮绑定同一个点击函数，但每个按钮传的 ID 不同，这时 `bind(this, id)` 就派上用场了。

这是一个非常深刻的问题，触及了 JavaScript 中最核心的两个概念：**`this` 的指向规则** 和 **闭包 (Closure)**。

简单来说：**如果不使用 `self` 而直接写 `this`，这个 `this` 就不再是你要绑定的那个函数了。**

以下是详细的原因拆解：

---

### 1. `this` 的“背叛”：作用域丢失

在 JavaScript 的普通函数中，`this` 是动态绑定的，它永远指向 **“谁最后调用了我”**。

当我们执行 `Function.prototype.myBind` 时：

- 此时的 `this` 确实指向我们要绑定的原函数（比如 `person.sayHi`）。
- 但是，`myBind` 内部**返回了一个新的匿名函数** `return function(...args2) { ... }`。

**关键点来了：**
当你在几秒钟后，甚至在另一个文件里调用这个**返回的新函数**时，这个新函数内部的 `this` 会根据当时的调用环境重新计算。它通常会指向全局对象 `window` 或者 `undefined`（严格模式），而**不再指向你最初想绑定的那个原函数**。

---

### 2. 代码对比：如果不用 `self` 会发生什么？

假设我们不用 `self`，直接写 `this`：

```javascript
Function.prototype.myBind = function (context, ...args1) {
  // 假设不保存 self = this
  return function (...args2) {
    // 这里的 this 是谁？
    // 当你执行 bound() 时，这里的 this 指向的是 window！
    return this.apply(context, [...args1, ...args2]);
    // 报错：window.apply is not a function
  };
};

function originalFunc() {
  console.log("执行原函数");
}
const bound = originalFunc.myBind({ name: "obj" });
bound(); // 报错！因为此时内部的 this 已经变成了 window
```

---

### 3. `self` 的作用：利用闭包“锚定”原函数

为了解决上面的问题，我们需要在 `this` 还是指向“原函数”的时候，把它**存起来**。

- `const self = this;` 这行代码就像是在当前作用域做了一个**快照**。
- 内部返回的函数形成了一个 **闭包**。它像一个背包，把 `self` 变量永远地带在了身边。
- 无论这个新函数以后在哪里被调用、被谁调用，它都能通过这个“背包”（闭包）找到当时存进去的那个 `self`（即原函数）。

---

### 4. 生活中的类比

想象你在办一场婚礼：

1.  **`myBind` (策划师)**：婚礼策划师。
2.  **`this` (新娘)**：在策划婚礼的时候，策划师指着身边的人说：“这位是**新娘**（`this`）”。
3.  **`return function` (婚礼当天的仪式)**：策划师写了一份流程单，说等到婚礼当天（异步调用），我们要给**新娘**戴戒指。
4.  **如果不存 `self`**：到了婚礼那天，流程单上写着“给**现场的新娘**戴戒指”。结果伴娘站在旁边，戒指可能就戴错人了。
5.  **如果存了 `self`**：策划师在策划那天就拿出一张新娘的照片（`const self = this`）贴在流程单上。无论婚礼那天谁在现场，大家都知道：“戒指要戴给**照片上的这个人**”。

---

### 5. 补充：如果是箭头函数呢？

如果你使用 ES6 的**箭头函数**编写 `myBind`，确实可以不用 `self`，因为箭头函数没有自己的 `this`，它会直接捕获外层的 `this`。

```javascript
Function.prototype.myBind = function (context, ...args1) {
  // 箭头函数直接捕获外层的 this（即原函数）
  return (...args2) => {
    return this.apply(context, [...args1, ...args2]);
  };
};
```

但在手写 `bind` 的面试题中，面试官通常考察的是你对**闭包和传统函数作用域**的理解，所以使用 `const self = this` 的写法最为经典且稳健。

是的，你说得完全正确。在 JavaScript 中，函数处理参数的方式非常灵活，主要有以下三种情况：

### 1. 只使用声明的参数

这是最常见的写法。代码可读性最高，别人一看就知道这个函数需要什么。

```javascript
function sum(a, b) {
  return a + b;
}
console.log(sum(1, 2)); // 3
```

### 2. 不声明参数，直接使用 `arguments` 对象

即使你定义函数时括号里是空的，你依然可以给它传参数。JavaScript 会自动把所有传进来的参数存入一个名为 **`arguments`** 的伪数组（类数组对象）中。

**适用场景：** 当你不确定用户会传多少个参数进来时（例如：计算所有传入数字的和）。

```function sumAll() {
  let total = 0;
  // arguments 包含了所有传进来的参数
  for (let i = 0; i < arguments.length; i++) {
    total += arguments[i];
  }
  return total;
}

console.log(sumAll(1, 2, 3, 4)); // 10
```

### 3. 混合使用

你可以声明一部分固定参数，同时用 `arguments` 获取剩余的参数。

```javascript
function greet(message) {
  // message 对应第一个参数
  // arguments[1], arguments[2]... 对应后面的参数
  console.log(message + arguments[1] + " 和 " + arguments[2]);
}

greet("你好：", "张三", "李四"); // "你好：张三 和 李四"
```

---

### 需要注意的坑（非常重要）：

#### 1. 箭头函数里没有 `arguments`

这是初学者最容易犯的错。如果你用箭头函数 `const func = () => {}`，它是**没有** `arguments` 对象的。如果你在箭头函数里用它，会报错或指向外层作用域。

#### 2. `arguments` 不是真正的数组

它是一个“伪数组”。它有 `length` 属性，也可以通过下标 `[0]` 访问，但它**没有**数组的 `map`、`filter`、`forEach` 等方法。

- 如果你想把它当数组用，需要转换：`const args = Array.from(arguments);`

#### 3. 现代 JS 的替代方案：剩余参数 (Rest Parameters)

在 ES6 之后，比起使用 `arguments`，现在官方和社区更推荐使用 **`...args`**。因为它是一个真正的数组，且在箭头函数中也能使用。

```javascript
// 推荐写法：剩余参数
function sumAll(...numbers) {
  // numbers 是一个真正的数组，可以直接用 reduce
  return numbers.reduce((prev, curr) => prev + curr, 0);
}

console.log(sumAll(1, 2, 3)); // 6
```

### 总结

- **声明参数**：适合参数数量固定、含义明确的情况（推荐）。
- **`arguments`**：适合老旧代码或需要处理不定数量参数的情况（不推荐在箭头函数用）。
- **`...args` (剩余参数)**：现代 JS 处理不定参数的最佳实践。

JavaScript 的类继承（Class Inheritance）表面上看起来像 Java 或 C++ 的类，但本质上它是**基于原型（Prototype）的委托模型**。ES6 引入的 `class` 关键字其实是**语法糖**，它的底层逻辑依然是原型链。

要深入理解继承，我们需要从以下三个维度拆解：

---

### 一、 核心概念：原型与原型链

在 JS 中，继承的本质就是：**当我在对象 A 上找不到某个属性时，去对象 B 里面找。**

1.  **`prototype`（显式原型）**：每一个**函数**都有一个 `prototype` 属性，它指向一个对象。这个对象包含了由该函数创建的所有实例共享的方法。
2.  **`__proto__`（隐式原型）**：每一个**对象**（包括函数）都有一个 `__proto__` 属性，它指向创建它的构造函数的 `prototype`。
3.  **原型链**：通过 `__proto__` 将对象连接起来的链路，就叫原型链。

---

### 二、 ES6 `extends` 继承的本质

当我们写下 `class Child extends Parent` 时，JavaScript 引擎在底层实际上做了**两步原型链的链接**：

#### 1. 实例方法的继承（子类实例 -> 父类实例）

为了让子类的实例能够调用父类的方法（如 `toString()` 或自定义方法），JS 将子类的原型对象连接到了父类的原型对象上。

```javascript
// 底层逻辑
Object.setPrototypeOf(Child.prototype, Parent.prototype);

// 结果是：
Child.prototype.__proto__ === Parent.prototype;
```

**意义**：如果你调用 `childInstance.sayHello()`，JS 先在 `childInstance` 找，找不到去 `Child.prototype` 找，再找不到去 `Parent.prototype` 找。

#### 2. 静态方法的继承（子类类本身 -> 父类类本身）

在 JS 中，类也是对象。为了让子类能直接调用父类的静态方法（`static` 方法），JS 将子类的构造函数连接到了父类的构造函数上。

```javascript
// 底层逻辑
Object.setPrototypeOf(Child, Parent);

// 结果是：
Child.__proto__ === Parent;
```

**意义**：这解释了为什么子类可以直接调用父类的静态方法：`Child.staticMethod()`。

---

### 三、 `super` 的原理

在子类的 `constructor` 中，必须先调用 `super()` 才能使用 `this`。这是 JS 继承与传统面向对象语言的一个重大区别：

- **传统语言（如 Java）**：先创建子类实例的 `this`，再调用父类构造函数修饰它。
- **JavaScript (ES6)**：**先由父类构造函数创建实例 `this`**，然后将这个 `this` 传递给子类，由子类进一步加工。

**`super(...args)` 的底层操作：**
相当于执行了：`Parent.call(this, ...args)`，但它还额外处理了原型绑定。

---

### 四、 深度图解：原型链结构

假设我们有：

```javascript
class Animal {
  eat() {}
}
class Dog extends Animal {
  bark() {}
}
const myDog = new Dog();
```

它们的完整链条如下：

1.  **实例层面的寻找路径：**
    `myDog`
    ➜ `myDog.__proto__` (即 `Dog.prototype`)
    ➜ `Dog.prototype.__proto__` (即 `Animal.prototype`)
    ➜ `Animal.prototype.__proto__` (即 `Object.prototype`)
    ➜ `null`

2.  **类层面的寻找路径（静态方法）：**
    `Dog`
    ➜ `Dog.__proto__` (即 `Animal`)
    ➜ `Animal.__proto__` (即 `Function.prototype`)
    ➜ `Function.prototype.__proto__` (即 `Object.prototype`)
    ➜ `null`

---

### 五、 手写模拟：如何用 ES5 实现继承？

理解了原理，我们可以手动实现一个接近 `extends` 效果的继承（这常被称为 **寄生组合式继承**）：

```javascript
function Parent(name) {
  this.name = name;
}
Parent.prototype.sayName = function () {
  console.log(this.name);
};

function Child(name, age) {
  // 1. 继承属性：借用构造函数
  Parent.call(this, name);
  this.age = age;
}

// 2. 继承方法：设置原型链
// 不要使用 Child.prototype = new Parent()，因为那会执行父类构造函数
// 使用 Object.create 创建一个新对象，其 __proto__ 指向 Parent.prototype
Child.prototype = Object.create(Parent.prototype);

// 3. 修复构造函数指向
// 因为上一步把 Child.prototype 覆盖了，我们需要手动指回 Child
Child.prototype.constructor = Child;

const kid = new Child("小明", 10);
kid.sayName(); // "小明"
```

### 总结

1.  **继承属性**：在子类构造函数中使用 `Parent.call(this)`（或 ES6 的 `super`）。
2.  **继承方法**：通过原型链 `Child.prototype.__proto__ = Parent.prototype`。
3.  **继承静态成员**：通过原型链 `Child.__proto__ = Parent`。
4.  **本质**：JS 的继承不是“拷贝”父类的代码，而是通过**指针（`__proto__`）**在原型链上进行动态查找。
5.

你的直觉非常敏锐，**你的理解 `Student.prototype.__proto__ === Person.prototype` 是完全正确的！**

之所以你会感到困惑，是因为 **Chrome 控制台的“显示标签”逻辑稍微有点绕**。让我们对照你那张截图，把“显示的文字”和“真实的物理对象”一一对应起来，你就彻底通透了。

### 1. 拆解截图中的每一行

我们按照截图的顺序，把 Chrome 打印的每一行翻译成代码：

- **第一行：`Student {name: "小张", ...}`**
  - 这是：**实例对象**（`小张`）。
- **第二行：`__proto__: Person`**（这就是让你困惑的地方）
  - 它的真实身份：**`Student.prototype`**。
  - **为什么 Chrome 标记它为 `Person`？**
    因为在 ES6 继承中，`Student.prototype` 是由 `Person` 体系“衍生”出来的。Chrome 认为这个对象（Student 的原型）本质上属于 `Person` 家族的成员，所以打了个标签叫 `Person`。
  - **证据**：你看它下面紧跟着一行 `constructor: class Student`。这足以证明这一层就是 **`Student` 的原型仓库**。

- **第三行：`__proto__:`**（在 `constructor: class Student` 下面的那个）
  - 它的真实身份：**`Person.prototype`**（也就是你说的 `Student.prototype.__proto__`）。
  - **证据**：你看它下面紧跟着 `constructor: class Person` 和 `speak: f speak()`。

---

### 2. 验证你的公式

让我们用代码验证你的公式：

```javascript
class Person {
  speak() {}
}
class Student extends Person {}
const 小张 = new Student();

// 你的公式：Student的原型 的 隐式原型 等于 Person的原型
console.log(Student.prototype.__proto__ === Person.prototype); // 结果是 true！
```

**所以，你那张截图里的层级关系实际上是：**

1.  **小张**（实例）
2.  `小张.__proto__` （这是 **`Student.prototype`**）
3.  `小张.__proto__.__proto__` （这是 **`Person.prototype`**）—— **也就是你写的 `Student.prototype.__proto__`**。

---

### 3. 为什么 Chrome 要在第一层 `__proto__` 后面写 `Person`？

这是 Chrome 开发者工具的一个 **UI 优化（或者说干扰）**。

在 Chrome 看来：

- 如果一个对象的 `__proto__` 指向 `Person.prototype`，它就会在前面显示 `Person`。
- 因为 `Student.prototype.__proto__ === Person.prototype`，所以 Chrome 在显示 `Student.prototype` 这个对象时，顺手给它贴了个 `Person` 的标签。

**你可以把 Chrome 的显示规则看作是：**
`__proto__ : [这个对象的构造函数是谁]` 或者是 `[这个对象继承自谁]`。

### 总结

- **你的理论：** `Student.prototype.__proto__ === Person.prototype` —— **满分，完全正确！**
- **截图显示：** 只是 Chrome 把 `Student.prototype` 这一层贴了个 `Person` 的分类标签，导致看起来像是跳了一层。

**看图的小技巧：**
不要看 `__proto__:` 后面跟着的那个单词，要看它展开后里面的 **`constructor`** 是谁。

- `constructor` 是 `Student`，这一层就是 `Student.prototype`。
- `constructor` 是 `Person`，这一层就是 `Person.prototype`。

这样看，原型链的清爽感是不是又回来了？

你的直觉非常敏锐，**你的理解 `Student.prototype.__proto__ === Person.prototype` 是完全正确的！**

之所以你会感到困惑，是因为 **Chrome 控制台的“显示标签”逻辑稍微有点绕**。让我们对照你那张截图，把“显示的文字”和“真实的物理对象”一一对应起来，你就彻底通透了。

### 1. 拆解截图中的每一行

我们按照截图的顺序，把 Chrome 打印的每一行翻译成代码：

- **第一行：`Student {name: "小张", ...}`**
  - 这是：**实例对象**（`小张`）。
- **第二行：`__proto__: Person`**（这就是让你困惑的地方）
  - 它的真实身份：**`Student.prototype`**。
  - **为什么 Chrome 标记它为 `Person`？**
    因为在 ES6 继承中，`Student.prototype` 是由 `Person` 体系“衍生”出来的。Chrome 认为这个对象（Student 的原型）本质上属于 `Person` 家族的成员，所以打了个标签叫 `Person`。
  - **证据**：你看它下面紧跟着一行 `constructor: class Student`。这足以证明这一层就是 **`Student` 的原型仓库**。

- **第三行：`__proto__:`**（在 `constructor: class Student` 下面的那个）
  - 它的真实身份：**`Person.prototype`**（也就是你说的 `Student.prototype.__proto__`）。
  - **证据**：你看它下面紧跟着 `constructor: class Person` 和 `speak: f speak()`。

---

### 2. 验证你的公式

让我们用代码验证你的公式：

```javascript
class Person {
  speak() {}
}
class Student extends Person {}
const 小张 = new Student();

// 你的公式：Student的原型 的 隐式原型 等于 Person的原型
console.log(Student.prototype.__proto__ === Person.prototype); // 结果是 true！
```

**所以，你那张截图里的层级关系实际上是：**

1.  **小张**（实例）
2.  `小张.__proto__` （这是 **`Student.prototype`**）
3.  `小张.__proto__.__proto__` （这是 **`Person.prototype`**）—— **也就是你写的 `Student.prototype.__proto__`**。

---

### 3. 为什么 Chrome 要在第一层 `__proto__` 后面写 `Person`？

这是 Chrome 开发者工具的一个 **UI 优化（或者说干扰）**。

在 Chrome 看来：

- 如果一个对象的 `__proto__` 指向 `Person.prototype`，它就会在前面显示 `Person`。
- 因为 `Student.prototype.__proto__ === Person.prototype`，所以 Chrome 在显示 `Student.prototype` 这个对象时，顺手给它贴了个 `Person` 的标签。

**你可以把 Chrome 的显示规则看作是：**
`__proto__ : [这个对象的构造函数是谁]` 或者是 `[这个对象继承自谁]`。

### 总结

- **你的理论：** `Student.prototype.__proto__ === Person.prototype` —— **满分，完全正确！**
- **截图显示：** 只是 Chrome 把 `Student.prototype` 这一层贴了个 `Person` 的分类标签，导致看起来像是跳了一层。

**看图的小技巧：**
不要看 `__proto__:` 后面跟着的那个单词，要看它展开后里面的 **`constructor`** 是谁。

- `constructor` 是 `Student`，这一层就是 `Student.prototype`。
- `constructor` 是 `Person`，这一层就是 `Person.prototype`。

这样看，原型链的清爽感是不是又回来了？

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-call-bind)
