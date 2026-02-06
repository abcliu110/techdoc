<div id="chap-state"></div>

[⬆️ 返回目录](#catalog)

## state

在 React 和现代 JavaScript (ES2022+) 中，这种在类体中直接写赋值语句的语法被称为 **类属性（Class Fields）**。

下面详细回答你的三个问题：

### 1. 为什么类里面可以直接写赋值语句？

这得益于 JavaScript 的新特性：**公共实例字段 (Public Instance Fields)**。

- **历史背景**：在早期的 ES6 标准中，类（class）里面只能定义方法，不能直接定义属性。所有的属性初始化必须写在 `constructor`（构造函数）里，通过 `this.state = ...` 来赋值。
- **现状**：为了简化代码，TC39 提案引入了类属性语法（Class Fields）。现在，Babel 等转译工具和现代浏览器（Chrome 72+）都已支持这种写法。
- **React 习惯**：在 React 开发中，大家习惯于把 `state` 和需要绑定 `this` 的方法直接写在类体里，这样代码更简洁，省去了写 `constructor` 和 `super(props)` 的麻烦。

---

### 2. 这个时候是类属性还是实例属性？

**它是实例属性。**

虽然它写在类的大括号里，且没有写在 `constructor` 内部，但它在逻辑上**等同于**在构造函数中通过 `this` 赋值。

- **实例属性**：每个通过 `new Weather()` 创建出来的对象（实例）都会拥有一份独立的 `state` 和 `changeWeather` 函数。
- **类属性（静态属性）**：如果你在前面加上 `static` 关键字（例如 `static x = 1`），那它才是属于类本身的（通过 `Weather.x` 访问）。你代码中的写法不带 `static`，所以是实例属性。

---

### 3. 为什么（原理是什么）？

当你使用这种写法时，JavaScript 引擎（或 Babel 编译器）在执行时会将其**“移动”到构造函数的最顶部**。

你的代码：

```javascript
class Weather extends React.Component {
  state = { isHot: false, wind: "微风" };

  changeWeather = () => { ... };
}
```

在底层执行时，实际上相当于变成了这样：

```javascript
class Weather extends React.Component {
  constructor(props) {
    super(props); // 自动调用父类构造函数

    // 类字段被初始化为实例属性
    this.state = { isHot: false, wind: "微风" };

    // 箭头函数也会变成实例上的一个属性
    this.changeWeather = () => { ... };
  }
}
```

#### 关于箭头函数的特殊说明：

你定义的 `changeWeather = () => { ... }` 也是一个类属性。

- **普通方法**（如 `render()`）是定义在类的**原型（prototype）**上的，所有实例共享同一个函数定义。
- **箭头函数属性**（如 `changeWeather`）是直接定义在**每个实例**上的。
- **优点**：箭头函数不会创建自己的 `this`，它会捕获定义时所处的环境（即当前的实例对象）。这就是为什么你不需要在构造函数里写 `bind(this)` 也能正常运行的原因。

---

### 💡 额外的小提醒

在你提供的代码中，有一行代码存在**性能隐患**：

```javascript
render() {
  // 这一行在每次 render 时都会执行！
  this.changeWeather = this.changeWeather.bind(this);
  return ( ... );
}
```

1.  **重复绑定**：`render` 函数在组件每次更新时都会运行。这意味着每次渲染都会创建一个新的函数并重新赋值给 `this.changeWeather`，这会消耗额外内存。
2.  **冲突**：你上面的 `changeWeather` 已经定义为**箭头函数**了，箭头函数是不需要（也不能）被 `bind` 的。

**建议做法：**
既然你已经使用了类属性写法定义了箭头函数 `changeWeather = () => { ... }`，请**删掉** `render` 函数里 `bind` 的那一行。这样代码既简洁又高效。

你的观察非常敏锐！**你说得完全正确：从纯粹的内存占用角度来看，箭头函数作为实例属性确实比原型方法更占内存。**

我们可以从底层原理来对比一下两种写法的差异：

### 1. 原型方法 (Prototype Method)

```javascript
class Weather extends React.Component {
  // 定义在原型上
  changeWeather() {
    console.log(this.state);
  }
}
```

- **内存表现**：无论你创建了 100 个还是 1000 个 `Weather` 实例，`changeWeather` 函数在内存中**只存在一份**，存放在 `Weather.prototype` 上。
- **缺点**：在 JS 中，类方法默认不会绑定 `this`。当你把这个方法传给 `onClick` 时，`this` 会丢失（指向 undefined），所以你必须在构造函数里手动 `bind(this)`。

---

### 2. 箭头函数属性 (Class Fields + Arrow Function)

```javascript
class Weather extends React.Component {
  // 定义在实例上
  changeWeather = () => {
    console.log(this.state);
  };
}
```

- **内存表现**：每创建一个 `Weather` 实例，JS 引擎都会为这个实例**新创建一个函数对象**。如果你有 1000 个实例，内存里就会有 1000 个功能完全一样的 `changeWeather` 函数拷贝。
- **优点**：写法极其简洁，且永远自动绑定了正确的 `this`。

---

### 3. 既然更占内存，为什么大家还都这么写？

主要有以下几个原因：

#### A. `bind(this)` 也会占用同样的内存

在 React 中，如果你使用原型方法，为了处理 `this`，你通常会在构造函数里这样做：

```javascript
constructor() {
  super();
  this.changeWeather = this.changeWeather.bind(this);
}
```

**重点来了：** `.bind(this)` 实际上会返回一个**新的函数**。
当你执行这行代码时，你依然在每个实例上创建了一个新的函数。也就是说，**为了修正 `this`，原型方法写法最终在内存占用上和箭头函数写法是基本一样的。**

#### B. 现代 JS 引擎的优化

现代 V8 引擎（Chrome/Node.js）非常聪明。对于这种结构完全相同的闭包函数，它在底层会尽量共享函数的代码逻辑部分（Code Space），只让每个实例持有不同的上下文引用。因此，这点内存差异在绝大多数 Web 应用中是**微乎其微**的。

#### C. 开发效率与可读性

- **避免 Bug**：忘记写 `bind` 导致 `this` 指向错误是 React 初学者最常见的错误。箭头函数直接规避了这个问题。
- **代码简洁**：省去了冗长的 `constructor` 结构，代码更清晰，阅读体验更好。

---

### 总结

- **性能上**：箭头函数属性确实比“纯原型方法”多占一点内存。
- **工程上**：考虑到原型方法通常也需要配合 `bind`（从而产生同样的内存开销），箭头函数写法因为**语法简洁**和**安全**，成为了目前 React 开发的主流推荐写法。

**除非**你的页面上需要同时渲染**成千上万个**该组件的实例（比如一个超大的虚拟列表），否则这种内存差异完全可以忽略不计。在那种极端场景下，最好的优化方案通常是“避免创建这么多组件”，而不是把箭头函数改回普通函数。

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-state)
