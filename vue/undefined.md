<div id="chap-undefined"></div>

[⬆️ 返回目录](#catalog)


## undefined

这段代码极其深刻地揭示了 JavaScript 中 `null` 和 `undefined` 在 **语言底层设计上的本质区别**。

### 预期输出结果

在 Node.js 环境（或者支持 `global` 的环境）中执行这段代码，输出如下：

```javascript
undefined
{
  value: undefined,
  writable: false,
  enumerable: false,
  configurable: false
}
```

---

### 深度解析：为什么结果天差地别？

这段代码揭露了一个冷知识：**`undefined` 是一个全局变量（属性），而 `null` 根本不是变量。**

#### 1. 解析 `print(Object.getOwnPropertyDescriptor(global, 'null'))`

*   **结果**：`undefined`
*   **原因**：
    *   **`null` 是一个字面量（Literal）/ 关键字（Keyword）**。
    *   就像 `true`、`false`、`if`、`class` 一样，`null` 是 JS 语法的一部分。
    *   它**不属于**全局对象（`global` 或 `window`）。你无法通过 `global.null` 访问它（会得到 `undefined`）。
    *   因此，`global` 对象上压根不存在名为 `'null'` 的属性，自然获取不到它的描述符。

    > **一句话总结**：`null` 是语言内置的“值”，而不是挂在全局对象上的“变量”。

#### 2. 解析 `print(Object.getOwnPropertyDescriptor(global, 'undefined'))`

*   **结果**：一个属性描述符对象（Descriptor Object）
    ```javascript
    {
      value: undefined,
      writable: false,     // ❌ 不可写
      enumerable: false,   // ❌ 不可枚举（遍历不到）
      configurable: false  // ❌ 不可配置（不能删，不能改描述符）
    }
    ```
*   **原因**：
    *   **`undefined` 是一个全局属性（Property）**。
    *   在 ECMAScript 规范中，`undefined` 被定义为全局对象的一个属性，它的初始值是原始值 `undefined`。
    *   **历史包袱**：在早期的 JavaScript（ES3 及之前），`undefined` 甚至是可以被修改的！你可以写 `undefined = "hahaha"`，这会导致整个程序崩溃。
    *   **现代修正**：为了安全，从 ES5 开始，规范强制将全局的 `undefined` 属性锁定：**不可写、不可配置**。

---

### 关键区别演示

理解了这个原理，你就能看懂下面这些看似奇怪的行为：

#### 1. 赋值尝试
*   **`null`**：因为它是关键字，直接报错。
    ```javascript
    null = 1; // ❌ Uncaught SyntaxError: Invalid left-hand side in assignment
    ```
*   **`undefined`**：因为它是只读属性，赋值静默失败（严格模式下报错）。
    ```javascript
    undefined = 1; 
    console.log(undefined); // 仍然输出 undefined
    ```

#### 2. 局部作用域（坑！）
*   **`null`**：永远不能作为变量名。
    ```javascript
    function test() {
        var null = 1; // ❌ SyntaxError
    }
    ```
*   **`undefined`**：**可以**作为局部变量名（因为它是标识符）。
    ```javascript
    function test() {
        var undefined = "我不是空值"; // ✅ 合法（但千万别这么做）
        console.log(undefined); // 输出 "我不是空值"
    }
    test();
    ```
    *这就是为什么很多压缩工具（如 UglifyJS）或者老手代码喜欢写 `void 0` 来代替 `undefined`，因为 `undefined` 在局部作用域可能被恶意篡改，而 `void 0` 永远返回纯正的 `undefined`。*

### 总结

你的这段代码证明了：
1.  **`null`** 是**系统级**的空（关键字），不在对象系统里。
2.  **`undefined`** 是**环境级**的空（全局只读变量），是对象系统的一部分。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-undefined)