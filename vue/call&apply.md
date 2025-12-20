<div id="chap-call"></div>

[⬆️ 返回目录](#catalog)


## call&apply

`call` 和 `apply` 的核心原理非常简单，一句话总结就是：

**把函数挂载到目标对象上，执行完再删掉。**

这就好比：你是（函数），你自己没有家（没有 `this` 指向该对象），你想去小明家（对象）吃饭。怎么办？你暂时认小明当干爹，进了小明家的户口本（成为他的属性），吃完饭（执行完），再从小明家户口本上把自己划掉。

这一过程利用了 JavaScript 的 **隐式绑定** 规则：当函数作为对象的方法被调用时（`obj.method()`），`this` 指向该对象。

---

### 1. 核心思路推导

假设我们有：
```javascript
function foo() {
    console.log(this.name);
}

var obj = {
    name: "小明"
};
```

我们要实现 `foo.call(obj)`，其实就是想让引擎执行类似这样的操作：

```javascript
// 1. 给 obj 临时加个属性，指向 foo
obj.fn = foo;

// 2. 执行 obj.fn，此时 this 指向 obj（隐式绑定生效！）
obj.fn();

// 3. 用完删掉，不留痕迹
delete obj.fn;
```

### 2. 手写实现 `call`

下面是符合现代规范（考虑到 Symbol 防止属性冲突）的手写实现：

```javascript
Function.prototype.myCall = function(context, ...args) {
    // 1. 边界判断：如果 context 是 null 或 undefined，
    // 在非严格模式下通常指向 window (或 global)，严格模式下是 null/undefined。
    // 这里为了演示通用情况，我们兜底到 window/globalThis。
    // 如果传入的是基本类型(如 1, 'str')，需要用 Object() 包装成对象。
    if (context === null || context === undefined) {
        context = globalThis; // 浏览器里是 window
    } else {
        context = Object(context);
    }

    // 2. 这里的 this 就是我们要调用的函数（因为是 foo.myCall 这样调用的）
    // 我们需要给 context 添加一个属性，值就是这个函数。
    
    // 使用 Symbol 创建一个独一无二的属性名，防止覆盖 context 原有的属性
    const fnSymbol = Symbol('fn');
    
    // 3. 【核心步骤】挂载函数
    context[fnSymbol] = this;

    // 4. 【核心步骤】执行函数
    // 利用隐式绑定，此时函数内部的 this 就指向了 context
    const result = context[fnSymbol](...args);

    // 5. 删除属性（清理现场）
    delete context[fnSymbol];

    // 6. 返回结果
    return result;
};
```

#### 测试一下 `myCall`：
```javascript
var name = "全局";
var obj = { name: "小明" };

function say(age, hobby) {
    console.log(`我叫${this.name}, 今年${age}, 喜欢${hobby}`);
    return "执行完毕";
}

// 这里的 this 是 say 函数
say.myCall(obj, 18, "编程"); 
// 输出: "我叫小明, 今年18, 喜欢编程"
```

---

### 3. 手写实现 `apply`

`apply` 的原理完全一样，唯一的区别在于**参数的处理**。`call` 接收散列的参数，`apply` 接收一个数组。

```javascript
Function.prototype.myApply = function(context, argsArr) {
    // 1. 处理 context (同 call)
    if (context === null || context === undefined) {
        context = globalThis;
    } else {
        context = Object(context);
    }

    // 2. 这里的 this 是原函数
    const fnSymbol = Symbol('fn');
    context[fnSymbol] = this;

    // 3. 执行函数
    let result;
    // 判断有没有传参数数组
    if (argsArr && Array.isArray(argsArr)) {
        // 展开数组传参
        result = context[fnSymbol](...argsArr); 
    } else {
        // 没传参直接执行
        result = context[fnSymbol](); 
    }

    // 4. 删除属性
    delete context[fnSymbol];

    // 5. 返回结果
    return result;
};
```

#### 测试一下 `myApply`：
```javascript
say.myApply(obj, [18, "游泳"]); 
// 输出: "我叫小明, 今年18, 喜欢游泳"
```

---

### 4. 关键细节解析 (面试加分项)

在实现过程中，有几个容易被忽略的细节，如果你能回答出来，说明你理解得很深：

1.  **为什么要用 `Symbol`？**
    *   如果不作为临时属性名，用普通的字符串（比如 `context.fn = this`），万一 `context` 对象里原本就有一个属性叫 `fn`，那你就会把它覆盖掉，导致原数据丢失。`Symbol` 保证了属性名的唯一性，绝对安全。

2.  **为什么要用 `Object(context)`？**
    *   因为 `call` 可以接收基本类型，比如 `foo.call(1)`。
    *   此时 `this` 应该指向 `Number(1)` 这个包装对象。如果直接在数字 `1` 上赋值 `1.fn = ...` 会报错或无效。必须把它转成对象才能挂载属性。

3.  **箭头函数怎么处理？**
    *   **这是一个坑。** 箭头函数没有自己的 `this`，它的 `this` 是词法作用域决定的（写代码时就定死了）。
    *   如果你对箭头函数使用 `.call()` 或 `.apply()`，**强行绑定是无效的**。JS 引擎会忽略传入的 `context`，依然使用原来的 `this`。这一点在 polyfill 里是无法通过 JS 模拟改变的（这是语言层面的硬性限制）。

### 总结
原理四步走：
1.  **包装对象**：确保目标是对象。
2.  **挂载属性**：把函数变成目标对象的一个属性（借尸还魂）。
3.  **调用执行**：执行这个属性方法（隐式绑定生效）。
4.  **删除属性**：抹去痕迹。
<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-call)