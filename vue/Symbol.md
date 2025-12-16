<div id="chap-symbol"></div>

[⬆️ 返回目录](#catalog)


## Symbol

我们要搞清楚三个东西的区别：
1.  **变量名**：`Symbol.iterator`
2.  **字符串**：`"Symbol.iterator"`
3.  **真实的值（那个 Key）**：？？？

让我们用最直观的代码和比喻来拆解。

---

### 1. 那个 Key 到底长什么样？

你可以把 `Symbol.iterator` 想象成浏览器内部定义的一个**全局常量**。

如果浏览器把这个常量打印出来（虽然实际上打印出来是隐藏的），它大概长这样：

```javascript
// 伪代码：浏览器内部大概是这么定义的
const Symbol = {
  // iterator 属性存了一个独一无二的 ID
  iterator: Symbol('Symbol.iterator') 
};
```

所以，当我们说“用 `Symbol.iterator` 做 key”时，实际上是在用那个**独一无二的 ID**（类似 UUID）。

我们来验证一下：

```javascript
// 1. 这是一个字符串 key
const stringKey = "Symbol.iterator";

// 2. 这是一个 Symbol key (这是系统内置的一个特殊值)
const symbolKey = Symbol.iterator;

console.log(stringKey); // 输出: "Symbol.iterator"
console.log(symbolKey); // 输出: Symbol(Symbol.iterator)
console.log(typeof symbolKey); // 输出: "symbol"

console.log(stringKey === symbolKey); // false！它俩完全不是同一个东西
```

**结论：** 那个 Key 就是一个类型为 `symbol` 的、独一无二的数据值。它不是字符串，不等于任何文字。

---

### 2. 为什么要用 `[]` 包起来？

这涉及到 JS 的语法规则：**如何在对象字面量里，使用“变量的值”作为 key？**

假设我们有一个变量：
```javascript
const myKey = Symbol.iterator; // 假设这个值是 0x123456 (内存地址概念)
```

#### 写法 A（错误）：不加括号
```javascript
const obj = {
  myKey: "hello" // JS 会认为你想把字符串 "myKey" 当作名字
};
console.log(obj.myKey); // "hello"
// 真正的 Symbol 根本没被用到！
```

#### 写法 B（错误）：用字符串
```javascript
const obj = {
  "Symbol.iterator": "hello" // 这只是一个普通的字符串 key
};
// 迭代器协议根本不认这个字符串，它只认那个 Symbol 值
```

#### 写法 C（正确）：加括号 `[]`
这是 ES6 的**计算属性名**语法。意思是：“不要把括号里的字当成字符串，请**运行**它，把它的**值**拿出来，作为 Key”。

```javascript
const obj = {
  [Symbol.iterator]: function() { ... }
  // 等价于：
  // [0x123456]: function() { ... }
};
```

---

### 3. 终极比喻：指纹锁 vs 门牌号

想象你有一个保险箱（对象 `obj`）。

*   **字符串 Key (`"Symbol.iterator"`)**：
    就像你在保险箱门上贴了一张纸条，上面写着“Symbol.iterator”。
    *   谁都能看见。
    *   谁都能再贴一张一样的纸条（命名冲突）。
    *   **JS 引擎（安检员）根本不看纸条。**

*   **Symbol Key (`Symbol.iterator`)**：
    这就像是一个**指纹录入**。
    *   `Symbol.iterator` 这个变量保存的就是那个**特定的指纹数据**。
    *   当你写 `[Symbol.iterator]: ...` 时，你是在告诉保险箱：“录入这个指纹，当有人用这个指纹按压时，打开这个功能。”
    *   **JS 引擎（安检员）只认这个指纹。**

### 总结

那个 Key 是什么？
它是一个**没有任何人能猜到的、内存中唯一的、系统分配的 ID**。

我们之所以写 `[Symbol.iterator]`，是因为我们不知道那个 ID 具体是多少（也写不出来），所以我们通过引用 `Symbol.iterator` 这个官方提供的变量来**指向**那个 ID。

### Symbol 的本质

一句话概括：**Symbol 的本质是一个全局唯一的 UUID（通用唯一识别码）。**

在 JavaScript 引擎内部（例如 V8），当你调用 `Symbol('desc')` 时，引擎会生成一个 **独一无二的内存地址** 或 **极其复杂的随机哈希值**。这个值就是 Symbol 的本体。

因为它本质上是唯一的，所以：
1.  **作为 Key 时**：它不会和任何字符串 Key 冲突。
2.  **作为私有属性时**：除非你有这个 Symbol 的引用（句柄），否则你无法轻易猜出这个 Key 是什么。

---

### 如何模拟实现 Symbol？

由于我们无法在 JS 层面真正创建一个新的“原始类型”（Primitive Type），所以我们只能用 **“对象 + 唯一字符串”** 的方式来模拟它的核心行为。

这是一个用于理解原理的 **最小化实现 (Polyfill)**，它实现了 Symbol 的三个核心特征：
1.  不能使用 `new`。
2.  独一无二（即便是相同的描述，也不相等）。
3.  拥有全局注册表 (`Symbol.for`)。

#### 1. 基础骨架：唯一性

```javascript
(function() {
  // 1. 生成唯一 ID 的工厂
  // 用来确保每一次调用生成的字符串绝对不会重复
  const generateName = (function() {
    let postfix = 0;
    return function(descString) {
      postfix++;
      return `@@${descString}_${postfix}_${Math.random()}`; 
    };
  })();

  // 2. 主函数
  const MySymbol = function(description) {
    // 特征 A: 禁止使用 new
    if (this instanceof MySymbol) {
      throw new TypeError("Symbol is not a constructor");
    }

    // 准备描述信息 (如果是 undefined 就设为 '')
    const descString = description === undefined ? '' : String(description);

    // 3. 核心：生成一个独一无二的内部 ID (类似于 UUID)
    // 比如：@@MySymbol_1_0.123456
    const __uuid__ = generateName(descString);

    // 4. 返回一个对象来模拟 Symbol
    // 为了模拟原始类型，我们利用 Object 的 toString 方法
    const symbolObj = Object.create({
      toString: function() {
        return this.__uuid__; // 实际上作为 key 时，用的是这个唯一字符串
      },
      valueOf: function() {
        return this; // 或者抛出错误，模拟原生 Symbol 不能运算的特性
      }
    });

    // 将内部 ID 挂载到对象上（为了演示，实际上应该隐藏）
    // 使用 defineProperty 让他不可枚举，更像原生一点
    Object.defineProperty(symbolObj, '__uuid__', {
      value: __uuid__,
      writable: false,
      enumerable: false,
      configurable: false
    });

    return symbolObj;
  };

  // 挂载到全局
  window.MySymbol = MySymbol;
})();

// --- 测试 ---
const s1 = MySymbol('foo');
const s2 = MySymbol('foo');

console.log(s1 === s2); // false (原理：因为每次 generateName 都会自增)
console.log(s1.toString()); // 输出类似：@@foo_1_0.453...
console.log(s2.toString()); // 输出类似：@@foo_2_0.892...
```

#### 2. 进阶：实现全局注册表 (`Symbol.for`)

原生 Symbol 有一个全局池，如果你用 `Symbol.for('key')`，它会先检查池子里有没有，有就返回旧的，没有就创建新的。

```javascript
// 在上面的 MySymbol 上挂载静态属性

// 模拟全局注册表
const globalRegistry = {};

MySymbol.for = function(key) {
  const keyString = String(key);
  
  // 1. 如果注册表中已经有了，直接返回
  if (globalRegistry[keyString]) {
    return globalRegistry[keyString];
  }

  // 2. 如果没有，创建一个新的，并存入注册表
  const newSymbol = MySymbol(keyString);
  globalRegistry[keyString] = newSymbol;
  
  return newSymbol;
};

MySymbol.keyFor = function(sym) {
  // 遍历注册表找到对应的 key
  for (let key in globalRegistry) {
    if (globalRegistry[key] === sym) {
      return key;
    }
  }
  return undefined;
};

// --- 测试 Symbol.for ---
const a = MySymbol.for('uid');
const b = MySymbol.for('uid');

console.log(a === b); // true (模拟成功！)
```

---

### 这个模拟实现揭示了什么？

#### 1. 所谓的“唯一性”其实是内部字符串的唯一性
在我们的模拟中，`s1` 和 `s2` 之所以不相等，是因为它们内部持有的 `__uuid__` 字符串不同（加了随机数和计数器）。
*   原生 Symbol 虽然是基本类型，但在底层 C++ 代码中，也是通过内存地址或生成的 Hash 码来保证不相等的。

#### 2. 作为对象 Key 的原理
当我们模拟 `obj[s1] = 123` 时，因为 `s1` 是个对象，JS 引擎会自动调用它的 `toString()` 方法。
*   我们的模拟：`toString` 返回了 `@@foo_1_0.453...`。
*   **结果**：`obj` 实际上有了一个叫 `"@@foo_1_0.453..."` 的字符串属性。
*   **为什么你看不到？** 原生 Symbol 对这一步做了特殊处理，不暴露这个内部字符串。而我们的模拟由于必须转换成字符串 Key，所以如果你用 `Object.keys(obj)` 其实是能看到的（这是 Polyfill 无法完美模拟的地方，除非劫持 `Object.keys`）。

#### 3. 为什么要有 `Symbol.for`？
看模拟代码就懂了，它就是一个**单例模式 (Singleton)** 的缓存对象。为了让不同的模块（文件）能共享同一个 Symbol。

### 总结

`Symbol` 并不神秘：
1.  **概念上**：它是一个没有任何属性、不可改变的**标签**。
2.  **实现上**：它就是一个**生成器**，每次吐出一个带随机数的、极长无比的字符串，并告诉你：“用这个做 key，绝对不会和别人撞车”。
3.  **语法上**：JS 引擎给它开了后门，让它可以作为属性名，并且让循环语句（`for...in`）故意忽略它。


首先，纠正一个小细节：正确的写法是 **`Symbol.iterator`**（全部小写），而不是 `Symbol.Iterate`。

关于你的问题：**它是全局的吗？**

答案是：**是，但它是作为 `Symbol` 构造函数的一个“静态属性”存在的，而不是一个全局变量。**

我们可以从以下三个层面来精确理解它的“全局性”：

### 1. 访问层面的全局性
`Symbol` 是 JavaScript 的一个内置全局对象（就像 `Array`, `Object`, `Date` 一样）。
因为 `Symbol` 随处可见，所以挂在它身上的 `Symbol.iterator` 自然也是随处可用的。

无论你在代码的哪个文件、哪个函数里，只要你写 `Symbol.iterator`，你引用的都是**同一个**值。

```javascript
// A.js
const sym1 = Symbol.iterator;

// B.js
const sym2 = Symbol.iterator;

console.log(sym1 === sym2); // true (它们是同一个东西)
```

### 2. 定义层面的全局性 (Well-Known Symbols)
`Symbol.iterator` 属于 **“知名符号” (Well-Known Symbols)**。

它不是通过 `Symbol.for()` 注册在全局注册表里的，而是**由 ECMA 标准直接定义死在 JS 引擎里的常量**。

你可以把它想象成物理学中的 **“π (3.14...)”**：
*   它不需要你去定义。
*   它在宇宙（JS 运行环境）的任何角落都代表同一个特殊的数值。
*   所有实现了迭代协议的对象（Array, String, Map），都在内部默认使用了这个常量作为 Key。

### 3. 特殊情况：跨域/跨窗口 (Realms) 的坑 —— **非常重要**

这是面试或高阶开发中常遇到的坑。

虽然在同一个页面里它是全局唯一的，但在 **iframe** 或 **Web Worker** 中，情况就不一样了。

JavaScript 的每个运行环境（称为一个 **Realm**）都有自己的一套内置对象（自己的 `Array`，自己的 `Object`，自己的 `Symbol`）。

**这意味着：**
父页面的 `Symbol.iterator` 和 iframe 里的 `Symbol.iterator` **是不相等的！**

```javascript
const iframe = document.createElement('iframe');
document.body.appendChild(iframe);

const iframeSymbol = iframe.contentWindow.Symbol;

console.log(Symbol.iterator === iframeSymbol.iterator); 
// 输出: false (震惊吗？)
```

**为什么会这样？**
就像“美国法律”和“英国法律”都规定了“杀人偿命”（都有 iterator 概念），但这是两套独立的法律体系（两个不同的 Realm）。

**但这会影响使用吗？**
通常**不会**。因为：
1.  当你把一个数组从 iframe 传给父页面时，你通常是在父页面的环境里遍历它，使用的是父页面的 `Symbol.iterator`。
2.  现代 JS 引擎做了一些兼容处理，或者我们通常不混合使用不同 realm 的 Symbol 做底层逻辑判断。

---

### 总结

1.  **它是全局的常量**：在你的当前页面（Realm）里，`Symbol.iterator` 永远指向同一个独一无二的 Symbol 值。
2.  **它是标准的锚点**：它是连接“用户代码”和“JS 引擎内部迭代机制”的统一接口。
3.  **它不是全局变量**：你不能直接访问 `iterator`，必须通过 `Symbol.iterator` 访问。

这是一个非常好的实践！

要在我们之前的 `MySymbol` 模拟代码基础上增加 `Symbol.iterator` 的功能，我们需要理解两件事：

1.  **定义标准**：我们需要在 `MySymbol` 上挂载一个静态属性 `iterator`，它只是一个普通的、预先定义好的 `MySymbol` 实例。
2.  **模拟消费**：因为浏览器的原生 `for...of` 循环只认**原生**的 `Symbol.iterator`，它不认我们模拟的 `MySymbol.iterator`。所以，我们必须**手写一个函数来模拟 for...of 的行为**，让它去寻找我们定义的这个特殊 Key。

下面是完整的代码实现：

### 1. 模拟 MySymbol 及其 Iterator

```javascript
// --- 第一部分：MySymbol 的模拟实现 (复用之前的逻辑) ---
const MySymbol = (function() {
  const generateName = (function() {
    let postfix = 0;
    return function(desc) {
      postfix++;
      return `@@${desc}_${postfix}_${Math.random().toString(36).slice(2)}`;
    };
  })();

  const MySymbol = function(description) {
    if (this instanceof MySymbol) throw new TypeError("Symbol is not a constructor");
    
    const __uuid__ = generateName(description);

    const symbolObj = Object.create({
      toString: function() { return this.__uuid__; },
      valueOf: function() { return this; }
    });

    Object.defineProperty(symbolObj, '__uuid__', {
      value: __uuid__,
      writable: false, enumerable: false, configurable: false
    });

    return symbolObj;
  };

  return MySymbol;
})();

// --- 第二部分：增加 "Well-Known Symbol" ---

// 核心点：Symbol.iterator 只是一个预先创建好的、大家都知道的 Symbol 实例
// 我们把它挂载到构造函数上作为静态属性
MySymbol.iterator = MySymbol('Symbol.iterator');

console.log('模拟的 iterator key:', MySymbol.iterator.toString()); 
// 输出类似: @@Symbol.iterator_1_kx9s...
```

### 2. 使用模拟的 Iterator 定义可迭代对象

现在，我们创建一个对象，并使用 `[MySymbol.iterator]` 作为 Key 来定义它的迭代逻辑。这完全模拟了原生 JS 中 `[Symbol.iterator]` 的写法。

```javascript
// 定义一个“教室”对象，里面有学生
const classRoom = {
  name: '三年二班',
  students: ['小明', '小红', '小刚'],

  // 1. 使用计算属性名语法，把我们的模拟 Symbol 作为 Key
  [MySymbol.iterator]: function() {
    // 2. 这里是迭代器的标准实现逻辑
    let index = 0;
    const items = this.students; // 保存数据引用

    // 3. 返回一个迭代器对象 (Iterator)
    return {
      next: () => {
        if (index < items.length) {
          return { value: items[index++], done: false };
        } else {
          return { value: undefined, done: true };
        }
      }
    };
  }
};
```

### 3. 模拟引擎的 `for...of` 循环

因为原生的 `for (const item of classRoom)` 实际上是在找 `Symbol.iterator` (原生的)，它找不到我们的 `MySymbol.iterator`。

所以我们需要写一个函数，模拟 JS 引擎在遇到 `for...of` 时在底层做的事情：

```javascript
// 这是一个模拟 JS 引擎处理 for...of 的函数
function fakeForOf(iterableObject, callback) {
  // 1. 引擎首先尝试查找有没有 [Symbol.iterator] 这个方法
  // 这里我们查找的是我们模拟的 MySymbol.iterator
  const iteratorMethod = iterableObject[MySymbol.iterator];

  if (typeof iteratorMethod !== 'function') {
    throw new TypeError('Object is not iterable (cannot find MySymbol.iterator method)');
  }

  // 2. 执行这个方法，获取 迭代器(iterator)
  const iterator = iteratorMethod.call(iterableObject);

  // 3. 开始循环调用 next()
  let result = iterator.next();
  
  while (!result.done) {
    // 4. 将 value 交给用户代码 (callback)
    callback(result.value);
    
    // 5. 继续下一次迭代
    result = iterator.next();
  }
}

// --- 运行测试 ---

console.log('--- 开始模拟 for...of 循环 ---');

fakeForOf(classRoom, (student) => {
  console.log(`点名：${student}`);
});

// 输出：
// --- 开始模拟 for...of 循环 ---
// 点名：小明
// 点名：小红
// 点名：小刚
```

---

### 这段代码揭示了什么原理？

1.  **Symbol.iterator 并不神奇**：
    它真的只是一个**变量名**（静态属性），保存了一个**独一无二的 ID**。
    `MySymbol.iterator` 本质上和我们自己定义的 `const myKey = MySymbol('myKey')` 没有区别，只是大家都约定好了“如果要迭代，就找这个名字的 Key”。

2.  **协议的分离**：
    *   **数据提供者 (`classRoom`)**：只要它在一个特定的 Key (`MySymbol.iterator`) 下挂了一个符合标准的函数，它就是“可迭代的”。
    *   **数据消费者 (`fakeForOf`)**：只要它知道去哪个 Key 找函数，并且知道怎么调用 `next()`，它就能遍历任何对象。

3.  **为什么需要 Symbol？**
    试想一下，如果我们规定用字符串 `"iterator"` 做 Key：
    ```javascript
    classRoom["iterator"] = function() { ... }
    ```
    如果 `classRoom` 里原本就有一个属性叫 `iterator` (比如这是一个数学班级，里面有个变量叫 `iterator` 表示迭代次数)，那代码就崩了。
    使用 `MySymbol.iterator` 生成的类似 `@@Symbol.iterator_1_xyz` 这种 Key，绝对安全，不会覆盖对象原有的数据。




<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-symbol)