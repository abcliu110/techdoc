<div id="chap-tsx"></div>

[⬆️ 返回目录](#catalog)

## tsx

React 使用 JSX（JavaScript XML）并不是强制的，但它是 React 生态系统中**最重要、最天才的设计选择之一**。

简单来说，React 选择 JSX 的核心原因可以概括为：**为了让“关注点分离”更符合现代组件化的逻辑，同时提供极致的开发体验。**

以下是具体的四个深度理由：

### 1. 重新定义了“关注点分离” (Separation of Concerns)

在传统的 Web 开发（如早期 HTML + JS + CSS）中，我们习惯把**结构**（HTML）和**逻辑**（JS）分开放在不同的文件里。这被称为“关注点分离”。

但 React 团队认为：**组件（Component）才是现代前端的基本单元。**

- **传统观点**：把 HTML 和 JS 分开，叫做分离技术（Separation of Technologies），而不是分离关注点。
- **React 观点**：一个按钮的 UI 长什么样（HTML）和它点击后做什么（JS）是紧密耦合的。**它们本来就应该在一起**。
- **结果**：JSX 允许你在 JS 中写 HTML 结构，实现了**组件内部的高内聚**。你修改一个组件时，不需要在 HTML 文件和 JS 文件之间来回切换。

### 2. 声明式 UI：所见即所得 (Readability)

这是最直观的原因。JSX 是 `React.createElement` 的**语法糖**。如果没有 JSX，写代码会变成一场噩梦。

**对比一下：**

**使用 JSX（清晰、像 HTML 结构）：**

```jsx
const element = (
  <div className="card">
    <h1 className="title">Hello, React!</h1>
    <p>This is a paragraph.</p>
  </div>
);
```

**不使用 JSX（原生写法，这是浏览器实际运行的代码）：**

```javascript
const element = React.createElement(
  "div",
  { className: "card" },
  React.createElement("h1", { className: "title" }, "Hello, React!"),
  React.createElement("p", null, "This is a paragraph."),
);
```

**结论**：一旦涉及嵌套，`React.createElement` 的写法极其繁琐且难以阅读。JSX 让我们能用熟悉的 HTML 树状结构来描述 UI，大脑的认知负担最小。

### 3. 发挥 JavaScript 的完全能力 (Full Power of JS)

Vue 或 Angular 的早期版本使用**模板（Templates）**，它们引入了许多自定义语法（如 `v-for`, `ng-repeat`, `v-if`）。你必须去学这些框架特有的语法。

React 使用 JSX，本质上还是 **JavaScript**。

- **循环**：不需要 `v-for`，直接用 JS 的 `.map()`。
- **判断**：不需要 `v-if`，直接用 JS 的 `if` 或三元运算符 `? :`。

这意味着：**你的 JavaScript 功底越好，你写 React 就越溜。** React 没有创造新的模板语言，只是利用了 JS 本身的能力。

### 4. 安全性与工具支持 (Security & Tooling)

- **防止 XSS 攻击**：
  JSX 在渲染之前，默认会转义所有输入的内容。这意味着你无法通过注入 `<script>` 标签来攻击网站，React 自动帮你处理了大部分跨站脚本攻击的风险。

- **强大的静态类型检查 (TypeScript)**：
  因为 JSX 本质是 JS 表达式，IDE（如 VS Code）和编译器（如 TypeScript）可以非常精准地检查代码。
  - 比如：你给一个组件传错了属性类型，TS 在你写代码时就能报错。如果是传统的字符串模板，这种检查会难得多。

### 总结

React 使用 JSX 是为了：

1.  **高内聚**：让 UI 结构和逻辑紧密结合。
2.  **高可读性**：告别繁琐的函数调用，回归树状结构。
3.  **利用 JS 能力**：不需要学奇怪的模板语法，只写 JavaScript。

它是 React 能够统治现代前端开发体验的关键武器。

好，同行。既然我们要以资深前端的视角来探讨这个问题，那我们就必须剥离掉“语法糖”这种表层的解释，直接深入到 **编译器（Compiler）**、**运行时（Runtime）** 以及 **数据结构（Data Structure）** 的层面来剖析 JSX。

React 选择 JSX，本质上是在做一件事：**将 UI 的描述权，从字符串模版（String Templates）手中夺过来，完全交给 JavaScript 的运行时能力。**

以下是深层原理的硬核拆解：

### 1. 编译层：从 DSL 到 AST 再到 JS 对象

JSX 本质上是一种 **领域特定语言 (DSL)**。浏览器是不认识 `<div />` 这种东西的。

在工程化链路中（通常是 Babel 或 SWC），JSX 会经过以下深度处理：

1.  **词法分析与语法分析**：Babel 将 JSX 代码解析成 **AST（抽象语法树）**。
2.  **代码生成（Codegen）**：AST 被转换成标准的 JavaScript 函数调用。

**React 17 之前**，它被编译为 `React.createElement(...)`。
**React 17 之后**（新的 JSX Transform），它被编译为 `_jsx(...)`，从 `react/jsx-runtime` 引入。

**为什么要这么做？**
这不仅仅是为了少写代码，而是为了**静态分析能力**。因为 JSX 是标准 JS 语法树的一部分，工具链（TypeScript, ESLint, Prettier）可以在构建阶段就对 UI 结构进行极其严格的检查。而传统的字符串模版（如早期的 Vue 或 Angular）需要框架自己实现一套 Parser 才能理解模版里的变量，这大大增加了工具链集成的复杂度。

### 2. 运行时：VNode 的内存表达与不可变性

当编译后的 JS 代码在浏览器运行时，`_jsx()` 函数被执行。这一步是关键。

**它返回的不是 DOM 节点，而是一个普通的 JavaScript 对象（Plain Object）。** 这个对象，就是我们常说的 Virtual DOM 节点（ReactElement）。

在源码层面，一个 JSX 元素被创建出来时，大概长这样（简化版）：

```javascript
const element = {
  // 1. 身份标识：防止 XSS 的关键（后面细说）
  $$typeof: Symbol.for("react.element"),

  // 2. 核心属性
  type: "div", // 或者是组件函数 App
  key: null,
  ref: null,

  // 3. 数据载体
  props: {
    className: "container",
    children: [
      /* 其他 ReactElement 对象 */
    ],
  },

  // ...其他内部字段 (_owner 等)
};
```

**资深视角解读：**
React 选择 JSX，是为了让开发者能直观地通过声明式语法，构建出这个**轻量级的对象树**。

- **内存开销低**：创建这个对象比创建一个真实的 DOM 节点（几百个属性）快好几个数量级。
- **不可变性（Immutability）**：一旦创建，React 往往视其为不可变的。当状态更新时，我们重新执行组件函数，生成一棵新的对象树。React 的 **Reconciliation（协调）算法**（Diff 算法）就是通过对比新旧两棵对象树的差异，来决定如何操作真实 DOM。

JSX 是生产这棵树最高效的“模具”。

### 3. 安全性设计：`$$typeof` 与 XSS 防御

你可能在面试中背过“JSX 防御 XSS”，但原理是什么？

在上面的对象结构中，有一个 `$$typeof: Symbol.for('react.element')`。这是一个极其精妙的设计。

**攻击场景**：假设服务器被黑了，返回了一个恶意的 JSON 数据，里面伪造了一个类似 React Element 的结构：

```json
{
  "type": "div",
  "props": { "dangerouslySetInnerHTML": { "__html": "<script>..." } }
}
```

如果你直接把这个 JSON 传给 React 渲染，如果没有防护，就会执行恶意脚本。

**React 的防线**：
`Symbol` 类型是 ES6 引入的，它的特性是**无法被 JSON 序列化**。
当你从服务器拉取 JSON 数据时，里面是不可能包含 `Symbol` 的。
React 在渲染（Render）阶段，会检查这个对象有没有合法的 `$$typeof` 属性。如果是来自服务器的伪造 JSON，由于缺失这个 Symbol，React 会拒绝渲染它。

**结论**：JSX 配合 `React.createElement` 的内部实现，从数据结构底层堵住了“伪造组件”的漏洞。

### 4. 逻辑控制：利用 JS 的“词法作用域” (Lexical Scope)

这是 React 区别于 Vue/Angular 模版语法的核心哲学。

- **Vue 模版**：`v-if`, `v-for` 是框架定义的指令。框架必须在运行时解析字符串，去查找当前作用域里有没有 `user` 这个变量。这涉及到一个**动态作用域查找**的过程，或者是框架在编译时生成的 `with` 语句或复杂的代理。
- **JSX**：完全利用 JavaScript 的**词法作用域**。

```jsx
// JSX
<div>{isLoggedIn && <AdminPanel />}</div>
```

当你写 `{isLoggedIn && ...}` 时，这完全是原生 JS 的逻辑。Babel 不需要懂 `&&` 是什么意思，它只需要把花括号里的内容当成 JS 表达式处理。
这意味着：**React 实际上“外包”了 DSL 的逻辑控制能力给 JS 引擎本身。**

这样做的好处是：

1.  **调试体验**：你在 JSX 里写的逻辑，断点可以直接打进去，变量值可以直接看。模版语言的调试往往非常痛苦。
2.  **类型推导**：TypeScript 可以完美推导 JSX 里的变量类型，因为这就是 JS 代码。

### 5. 复合模式（Composition）：函数式编程的体现

在资深开发者眼中，JSX 描述的 UI 结构，本质上是 **函数调用的嵌套**。

`<A><B /></A>` 等价于 `h(A, { children: h(B) })`。

这种结构天然契合**函数式编程（Functional Programming）** 的思想：

- **UI = f(state)**
- 组件是函数。
- JSX 是函数的执行。
- Props 是函数的参数。

React 通过 JSX 强迫开发者用“组合”的思维去构建 UI，而不是用“继承”或“模版拼接”。这种**数据自顶向下流动（Unidirectional Data Flow）** 的机制，在 JSX 的嵌套结构中表现得最为自然。

### 总结

作为资深前端，我们理解 JSX 不应止步于“它像 HTML”。

React 使用 JSX 的深层原理是：
它需要一种**编译时友好**（AST分析）、**运行时高效**（生成轻量对象）、**安全性高**（Symbol 标记）、且能**完全利用 JavaScript 词法作用域**（无需新造模版引擎）的 DSL，来描述 UI 的**对象树结构**。

它是 React 将“UI 编程”彻底纳入“JavaScript 编程”范畴的关键桥梁。

是的，你的直觉非常准确！**JSX 的全称就是 JavaScript XML。**

这个公式可以拆解为：**用 XML 的语法来写 JavaScript 的对象。**

虽然它看起来像 HTML，但从技术底层和语法规则来看，它更接近 **XML**。我们可以从以下三个层面来彻底理解这个等式：

### 1. 为什么是 XML 而不是 HTML？

JSX 采纳了 XML 严谨的语法规则，这使得解析器（如 Babel）能够毫无歧义地将其转换为 JavaScript 代码。它与普通 HTML 的主要区别（也是 XML 的特征）包括：

- **必须自闭合**：在 HTML 中 `<img src="...">` 是合法的，但在 JSX 中必须写成 `<img src="..." />`。
- **单一根元素**：就像一个 XML 文档只能有一个顶层标签一样，一个 JSX 块必须包裹在一个父元素（或 `Fragment`）里。
- **标签严格区分大小写**：JSX 利用这一点来区分原生 HTML 标签（小写，如 `<div>`）和 React 组件（大写，如 `<MyComponent />`）。

### 2. 这个“等式”在代码中如何体现？

#### **XML 部分：负责“长相”（UI 结构）**

它让你可以用声明式的方式描述界面，而不是用冗长的 JS 命令：

```jsx
// XML 风格的代码
const box = (
  <div className="container">
    <span>Hello World</span>
  </div>
);
```

#### **JS 部分：负责“灵魂”（逻辑处理）**

通过花括号 `{ }`，你可以在 XML 结构中直接插入 JavaScript 的逻辑：

```jsx
const name = "React";
// 在 XML 中嵌入 JS 表达式
const element = <h1>Hello, {name.toUpperCase()}</h1>;
```

### 3. 最终的转化：JSX → JS

浏览器其实**完全不认识**这些 XML 标签。当你运行代码时，编译工具（Babel）会把这个“伪 XML”翻译成真正的 JavaScript 函数调用。

**你写的（JSX）：**

```jsx
<div id="abc">Hi</div>
```

**Babel 翻译后的（纯 JS）：**

```javascript
// 这就是为什么说 JSX 只是 JavaScript 的语法糖
React.createElement("div", { id: "abc" }, "Hi");
```

### 4. 为什么要搞出这个“混血儿”？

在 JSX 出现之前，前端界流行的是“逻辑与模板分离”（JS 文件写逻辑，HTML 文件写结构）。但 React 认为：

1.  **渲染逻辑与 UI 本质上是耦合的**（比如：点击按钮、数据的增删改查都会直接改变 UI）。
2.  **开发效率更高**：在一个文件里既能看到结构，又能写逻辑，不需要在文件间跳来跳去。
3.  **更安全**：因为 JSX 本质是 JS，编译器可以在打包阶段就发现语法错误，而不是等到用户打开网页才报错。

### 总结

- **JS** 提供了**动态能力**（变量、循环、判断）。
- **XML** 提供了**可视化结构**（直观、易读）。
- **JSX** 就是把这两者缝合在一起的**语法糖**，最终它会回归为**纯 JavaScript 对象**。

所以，你说 **JSX = JS + XML** 是完全正确的！

在 React 和 TypeScript 结合开发中，`.tsx` 文件有一套严格的“规定”（语法规则与最佳实践）。由于 TSX 既要遵循 JSX 的视图逻辑，又要遵循 TypeScript 的类型检查，因此它有一些特定的限制和写法。

作为资深开发者，我将 TSX 的规定分为 **基础语法规范**、**TS 专有特性限制**、以及 **组件类型标注** 三个维度来深入讲解：

---

### 1. 基础语法规定（继承自 JSX）

这些是 TSX 必须遵守的基本结构规则：

- **单一根元素**：每个 TSX 表达式必须有一个根元素。可以使用 Fragment `<>...</>` 或 `<React.Fragment>...</React.Fragment>`。
- **标签必须闭合**：自闭合标签必须带斜杠，例如 `<img src="..." />` 或 `<br />`。
- **驼峰命名**：属性名使用驼峰式（CamelCase），例如 `onClick` 而非 `onclick`，`className` 而非 `class`。
- **表达式嵌入**：在 TSX 中使用 JavaScript 表达式必须包裹在花括号 `{ }` 中。

---

### 2. TypeScript 特有的“冲突绕过”规定

这是 `.tsx` 与普通 `.ts` 文件最大的区别。由于 `< >` 符号在 TSX 中被优先解析为 HTML/组件标签，因此会产生两个主要的语法冲突：

#### A. 类型断言（Type Assertion）

- **规定**：在 `.tsx` 中，禁止使用 `<Type>` 格式的类型断言。
- **原因**：编译器会把 `<User>` 误认为是 JSX 标签。
- **正确写法**：必须使用 `as` 关键字。

  ```tsx
  // ❌ 错误
  const user = <User>data;

  // ✅ 正确
  const user = data as User;
  ```

#### B. 泛型箭头函数（Generic Arrow Functions）

- **规定**：在 `.tsx` 中定义泛型箭头函数时，单泛型参数会导致解析歧义。
- **写法技巧**：

  ```tsx
  // ❌ 错误：编译器会认为 <T> 是一个标签
  const identity = <T>(arg: T): T => arg;

  // ✅ 正确方式 1：加一个逗号（最常用技巧）
  const identity = <T,>(arg: T): T => arg;

  // ✅ 正确方式 2：使用 extends
  const identity = <T extends unknown>(arg: T): T => arg;
  ```

---

### 3. 组件与 Props 的类型定义

TSX 强制要求对组件的输入（Props）和输出进行类型约束。

#### A. 为 Props 定义接口

```tsx
interface ButtonProps {
  label: string;
  disabled?: boolean; // 可选属性
  onClick: () => void;
  children?: React.ReactNode; // 显式声明子元素类型
}

const MyButton = ({ label, onClick }: ButtonProps) => (
  <button onClick={onClick}>{label}</button>
);
```

#### B. 使用 `React.FC` (Functional Component)

虽然现在社区对 `React.FC` 有争议（主要是它在早期版本自动包含 `children`），但在很多项目中仍是规定：

```tsx
const Header: React.FC<{ title: string }> = ({ title }) => {
  return <h1>{title}</h1>;
};
```

---

### 4. 事件处理与 DOM 元素的规定

TSX 要求对事件对象进行精确的类型标注，以获得智能提示。

- **事件类型**：

  ```tsx
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    console.log(e.target.value);
  };

  <input onChange={handleChange} />;
  ```

- **Ref 类型**：

  ```tsx
  // 必须指定具体的 HTML 元素类型，初始值为 null
  const inputRef = useRef<HTMLInputElement>(null);

  <input ref={inputRef} />;
  ```

---

### 5. 编译配置规定 (`tsconfig.json`)

要让 `.tsx` 正常工作，必须在 `tsconfig.json` 中配置 `jsx` 选项：

- **`"jsx": "react-jsx"`**：JavaSript 运行时使用新的 JSX 转换器（React 17+），不需要在每个文件中 `import React`。
- **`"jsx": "preserve"`**：保留 JSX 不动，交给后续工具（如 Babel 或 Esbuild）处理。
- **`"jsx": "react"`**：编译为旧版的 `React.createElement`。

---

### 6. 避坑指南（资深建议）

1.  **不要滥用 `any`**：在 TSX 中使用 `any` 会丧失模板检查的所有优势。如果类型极其复杂，优先考虑 `unknown`。
2.  **默认值与可选属性**：在 TSX 解构 Props 时设置默认值，比使用 `defaultProps` 更符合现代 TypeScript 习惯。
    ```tsx
    const UserCard = ({ role = "guest" }: { role?: string }) => { ... }
    ```
3.  **内联样式的规定**：`style` 属性必须是一个对象，且其属性符合 `React.CSSProperties` 类型。
    ```tsx
    // ✅ 有类型提示的样式
    const style: React.CSSProperties = { marginTop: "10px" };
    <div style={style} />;
    ```

### 总结

TSX 的本质是：**JSX 的结构 + 严格的类型擦除 + 避开 `<>` 歧义的特殊写法**。掌握了 `as` 断言、泛型逗号技巧以及 React 专有事件类型，就掌握了 TSX 的核心。

在 React 中，`<>...</>` 是 **`React.Fragment` 的简写语法**。

它的核心作用是：**允许你将多个子元素组合在一起，而不在 DOM 中添加额外的节点。**

作为资深开发者，我从以下几个维度为你深度解读：

---

### 1. 为什么需要它？（解决“Div 堆叠”痛点）

React 要求每个组件必须返回**唯一的一个根元素**。如果你的组件逻辑上需要返回两个并列的标签（比如一个 `<h1>` 和一个 `<p>`），在没有 Fragment 之前，你必须这么写：

```tsx
// ❌ 产生无效的 DOM 结构
function MyComponent() {
  return (
    <div>
      <h1>标题</h1>
      <p>内容</p>
    </div>
  );
}
```

**后果：**

- **DOM 污染**：页面上充满了为了满足 React 语法而存在的 `<div>`，导致 HTML 结构臃肿。
- **布局破坏**：额外的 `<div>` 会破坏 CSS 的 **Flexbox** 或 **Grid** 布局。例如，父容器设置了 `display: flex`，原本希望 `<h1>` 和 `<p>` 是直接子项，结果中间多出来的 `div` 成了唯一的子项，导致布局失效。

---

### 2. 简写语法 `<>...</>` 的用法

```tsx
// ✅ 使用 Fragment 简写
function MyComponent() {
  return (
    <>
      <h1>标题</h1>
      <p>内容</p>
    </>
  );
}
```

**渲染结果：**

```html
<!-- DOM 中直接显示，没有任何包装层 -->
<h1>标题</h1>
<p>内容</p>
```

---

### 3. 简写语法 vs 完整写法（关键区别）

虽然 `<>...</>` 很方便，但它有一个**重大限制**：**它不能接收任何属性（Props），包括 `key`。**

#### 情况 A：使用简写 `<>...</>`

适用于大多数静态包装场景。

#### 情况 B：使用完整写法 `<React.Fragment>`

**唯一必须使用完整写法的场景：循环渲染列表。**
当你通过 `map` 渲染一组 Fragment 时，你需要给每个 Fragment 绑定 `key`，这时简写语法就不管用了。

```tsx
// ✅ 必须使用完整写法，因为需要 key
function BlogList({ posts }) {
  return (
    <dl>
      {posts.map((post) => (
        <React.Fragment key={post.id}>
          <dt>{post.title}</dt>
          <dd>{post.content}</dd>
        </React.Fragment>
      ))}
    </dl>
  );
}
```

---

### 4. 资深开发者的技术洞察

#### A. 对 CSS 布局的意义

在现代前端开发中，`gap` 属性（用于 Flex/Grid）非常流行。如果中间夹杂了无意义的 `div`，`gap` 的计算就会出错。Fragment 保证了 DOM 树的“洁净”，让 CSS 选择器（如 `parent > child`）能按预期工作。

#### B. 语义化与无障碍（Accessibility）

屏幕阅读器会解析 DOM 结构。不必要的嵌套会干扰语义化标签的层级。使用 Fragment 能确保 HTML 结构完全符合语义化要求（例如在 `<table>` 中返回多行 `<tr>`，中间绝对不能有 `div`）。

#### C. 内存与性能

虽然微乎其微，但 Fragment 不需要创建真实的 DOM 实例，相比于 `createElement('div')`，它在内存占用和渲染性能上是更优的。

### 总结

- **`<>...</>`** 是 **`React.Fragment`** 的语法糖。
- **目的**：包裹多个元素，但不增加 DOM 层级。
- **限制**：简写形式不支持 `key` 属性；如果循环渲染，必须用 `<React.Fragment key={...}>`。
- **原则**：除非有明确的样式或逻辑需要 `div`，否则**优先使用 Fragment** 以保持 DOM 纯净。
  在 React 的 JSX 中不能直接写 `for` 循环或 `if` 语句，最核心的原因只有一句话：

**JSX 最终会被转换成普通的 JavaScript 函数调用，而函数调用的参数只能是“表达式（Expression）”，不能是“语句（Statement）”。**

为了让你彻底理解，我们把这个问题拆开来看：

### 1. 表达式 vs 语句（编程基础）

这是理解这个问题的关键。

- **表达式 (Expression)**：会**返回一个值**的代码。
  - 例如：`1 + 1`、`myArray.map(...)`、`isTrue ? 'yes' : 'no'`。
  - 因为它们有返回值，所以你可以把它们赋值给变量，或者作为函数的参数。
- **语句 (Statement)**：执行一个**动作**，但**不返回值**。
  - 例如：`if (abc) { ... }`、`for (let i=0; i<10; i++) { ... }`。
  - 你不能写出 `const a = if (true) { 1 };` 这样的代码，因为 `if` 没有返回值。

### 2. JSX 的本质是函数调用

正如我们前面提到的，JSX 只是 `React.createElement()` 的语法糖。

**如果你写 map（表达式）：**

```jsx
<ul>
  {[1, 2].map((i) => (
    <li key={i}>{i}</li>
  ))}
</ul>
```

编译后变成：

```javascript
React.createElement(
  "ul",
  null,
  [1, 2].map((i) => React.createElement("li", { key: i }, i)),
);
// 这里的 map 返回一个数组，作为 createElement 的第三个参数（children）。这合法！
```

**如果你写 for（语句）：**

```jsx
<ul>
  {
    for (let i = 0; i < 3; i++) { <li>{i}</li> } // ❌ 错误！
  }
</ul>
```

编译后会变成：

```javascript
React.createElement("ul", null, for (let i = 0; i < 3; i++) { ... });
// ❌ 语法错误！你不能把一个 for 循环放在函数的参数位置上。
```

### 3. React 怎么处理循环和条件？

虽然不能直接在 `{}` 里写 `for` 和 `if`，但 React 提供了非常优雅的替代方案：

#### (1) 使用 `.map()` 代替循环

`.map()` 是一个表达式，它返回一个新数组。React 会自动把数组里的每个虚拟 DOM 渲染出来。

```jsx
{
  items.map((item) => <div key={item.id}>{item.name}</div>);
}
```

#### (2) 使用三元运算符或逻辑与代替 `if`

- **三元运算符**（相当于 if-else）：
  `{isLoggedIn ? <Logout /> : <Login />}`
- **逻辑与 `&&`**（相当于只有 if）：
  `{showModal && <Modal />}`

### 4. 如果非要写复杂的逻辑怎么办？

如果你有一段非常复杂的逻辑，非要用 `for` 或 `if-else`，通常有三种做法：

**方式一：在 return 之前处理好**

```javascript
function MyComponent() {
  const list = [];
  for (let i = 0; i < 5; i++) {
    list.push(<li key={i}>{i}</li>);
  }

  return <ul>{list}</ul>; // 这里只放处理好的变量
}
```

**方式二：封装成子组件**
把复杂的逻辑抽离成另一个小组件。

**方式三：使用 IIFE（立即执行函数表达式）**
虽然不推荐，但在某些极端情况下可以这么写，因为 IIFE 是一个表达式：

```jsx
<div>
  {(() => {
    let rows = [];
    for (let i = 0; i < 3; i++) {
      rows.push(<p key={i}>Row {i}</p>);
    }
    return rows; // 返回一个值
  })()}
</div>
```

### 总结

React 禁止在 JSX 内部使用循环语句，是为了保证 **JSX 的语法纯粹性**。既然 JSX 最终要变成函数调用，那么 `{}` 内部就必须是**能产生结果的值**。

**口诀：JSX 内部只放“值”，不放“动作”。**

JSX 转换的核心是由 **Babel** 提供的。它遵循一个简单的公式：
**`<标签名 属性>子元素</标签名>`** $\rightarrow$ **`React.createElement(标签名, 属性, 子元素)`**

以下是 6 个典型的转换案例，涵盖了从简单到复杂的各种场景：

---

### 1. 最简单的单层标签

这是最基础的形态。

- **JSX:**
  ```jsx
  const element = <h1>Hello World</h1>;
  ```
- **编译后的 JS:**
  ```javascript
  const element = React.createElement("h1", null, "Hello World");
  ```
  _解释：第一个参数是标签名（字符串），第二个是属性（无属性则为 null），第三个是内容。_

---

### 2. 带有属性和样式的标签

注意 `class` 会变成 `className`，因为在 JS 中 `class` 是关键字。

- **JSX:**
  ```jsx
  const element = (
    <div id="main" className="container" style={{ color: "red" }}>
      Content
    </div>
  );
  ```
- **编译后的 JS:**
  ```javascript
  const element = React.createElement(
    "div",
    {
      id: "main",
      className: "container",
      style: { color: "red" },
    },
    "Content",
  );
  ```

---

### 3. 多层嵌套（递归转换）

这是 Babel 处理“多个虚拟 DOM”的方式：将子元素作为后续参数依次传入。

- **JSX:**
  ```jsx
  const element = (
    <nav>
      <ul>
        <li>Home</li>
      </ul>
    </nav>
  );
  ```
- **编译后的 JS:**
  ```javascript
  const element = React.createElement(
    "nav",
    null,
    React.createElement(
      "ul",
      null,
      React.createElement("li", null, "Home"), // 嵌套调用
    ),
  );
  ```

---

### 4. 自定义组件（变量 vs 字符串）

Babel 通过**首字母大小写**来区分是原生 HTML 还是 React 组件。

- **JSX:**
  ```jsx
  const element = <MyButton color="blue">Click Me</MyButton>;
  ```
- **编译后的 JS:**
  ```javascript
  const element = React.createElement(
    MyButton, // 注意：这里没有引号，是一个变量名（引用）
    { color: "blue" },
    "Click Me",
  );
  ```
  _解释：如果是 `<mybutton>`（小写），则会变成 `"mybutton"`（字符串）。_

---

### 5. 带有 JavaScript 表达式

当你在 JSX 内部使用 `{}` 时，Babel 会直接把里面的内容拿出来。

- **JSX:**
  ```jsx
  const name = "Alice";
  const element = <h1>Hello, {name}</h1>;
  ```
- **编译后的 JS:**
  ```javascript
  const name = "Alice";
  const element = React.createElement("h1", null, "Hello, ", name);
  ```
  _解释：`createElement` 可以接受任意数量的参数，从第三个开始全都是子元素。_

---

### 6. 列表渲染（Map）

这是最常见的“循环”实现方式。

- **JSX:**
  ```jsx
  const users = ["A", "B"];
  const element = (
    <ul>
      {users.map((u) => (
        <li key={u}>{u}</li>
      ))}
    </ul>
  );
  ```
- **编译后的 JS:**
  ```javascript
  const users = ["A", "B"];
  const element = React.createElement(
    "ul",
    null,
    users.map((u) => React.createElement("li", { key: u }, u)), // map 返回一个数组作为子元素
  );
  ```

---

### 进阶：React 17+ 的新转换机制

如果你观察最新的脚手架项目（Vite/Create React App），Babel 不再转换成 `React.createElement`，而是转换成一种更高效的 `_jsx` 函数。

- **现代转换（自动导入）：**

  ```javascript
  import { jsx as _jsx } from "react/jsx-runtime";

  const element = _jsx("h1", { children: "Hello" });
  ```

  _这种方式不需要你在每个文件手动 `import React`，而且生成的文件体积更小。_

### 总结

Babel 的转换逻辑非常机械：

1.  **遇到 `<`** $\rightarrow$ 开启一个函数调用。
2.  **遇到属性** $\rightarrow$ 变成一个对象作为第二个参数。
3.  **遇到子元素** $\rightarrow$ 递归调用函数，作为后续参数。
4.  **遇到 `{}`** $\rightarrow$ 停止 JSX 解析，直接把 JS 内容填进去。
5.  这是一个非常经典的困惑！其实 `{{ }}` 并不是一个特殊的运算符，而是**两层含义叠加**的结果。

我们可以把它拆解开来看：

### 1. 第一层（外层）花括号 `{ }`：告诉 JSX “我要写 JS 了”

在 JSX 语法中，默认是像 HTML 一样的字符串环境。如果你想在属性里传一个变量、数字、函数或者对象，你就必须使用一对花括号来**逃离字符串环境，进入 JavaScript 环境**。

- 如果是字符串：`id="main"`
- 如果是变量或表达式：`id={variable}`

### 2. 第二层（内层）花括号 `{ }`：这是一个“对象字面量”

在 React 中，`style` 属性要求的格式不是字符串（不像 HTML 里的 `style="color:red"`），而是一个 **JavaScript 对象**。

在 JS 中，定义一个对象是这么写的：`{ color: 'red' }`。

### 3. 合在一起：表达式 + 对象

当你把一个对象传给 style 属性时，就变成了：

1.  **外层**：告诉 React，“括号里是一个 JS 表达式”。
2.  **内层**：这个 JS 表达式本身正好是一个“对象”。

```jsx
//    外层：进入JS环境
//    ↓
style={ { color: 'red' } }
//          ↑
//          内层：JS对象本身的花括号
```

---

### 通过对比更容易理解

如果我们不写在一行，你就能一眼看出区别：

**写法 A（拆开写）：**

```javascript
const myStyle = { color: "red" }; // 这是一个普通的 JS 对象

// 在 JSX 中引用这个变量，只需要一层花括号
const element = <div style={myStyle}>Hello</div>;
```

**写法 B（写在一起）：**
如果你不想定义变量，想直接把对象扔进去，你就得把 `{ color: 'red' }` 整个放进 `{ }` 里，于是就形成了 `{{ }}`。

---

### 为什么 React 要强制 style 使用对象？

传统的 HTML 字符串 style 有很多缺点：

1.  **解析麻烦**：动态修改某个样式时需要复杂的字符串拼接（比如 `"color:" + myColor + "; font-size:" + size + "px"`）。
2.  **安全性**：对象格式更容易防止跨站脚本攻击（XSS）。
3.  **操作方便**：在 JS 里操作对象（修改 `obj.color = 'blue'`）比操作字符串容易得多。

### 总结

- **第一个 `{`**：代表“我要开始写 JavaScript 了”。
- **第二个 `{`**：代表“这是一个对象的开始”。

这不仅仅适用于 `style`。如果你给组件传一个对象作为 Props，也会看到这种写法：

```jsx
<UserCard info={{ name: "Alice", age: 25 }} />
```

这里也是同样道理：外层是 JSX 语法，内层是你要传的数据对象。

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-tsx)
