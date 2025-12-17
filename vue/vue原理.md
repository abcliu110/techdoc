<div id="chap-concept"></div>

[⬆️ 返回目录](#catalog)


## vue原理

这是一个非常经典且核心的前端面试题，也是理解 Vue 框架演进的关键。

你提到的“Descriptor 协议”实际上指的是 ES5 中的 **属性描述符 (Property Descriptor)**，主要是通过 `Object.defineProperty` 来实现；而“Proxy 协议”则是 ES6 中的 **代理 (Proxy)** 对象。

以下是它们在 Vue 2 和 Vue 3 响应式原理中的详细对比：

---

### 1. Vue 2 基础：Object.defineProperty (Descriptor 协议)

Vue 2 的响应式系统是建立在 **ES5** 的 `Object.defineProperty` API 之上的。

#### 技术原理
`Object.defineProperty` 允许你精确地定义或修改对象的属性。它使用“属性描述符”来控制属性的行为。描述符分为两种：
1.  **数据描述符**：控制 `value`（值）、`writable`（可写性）、`enumerable`（可枚举性）、`configurable`（可配置性）。
2.  **存取描述符**：控制 `get`（读取时触发）和 `set`（写入时触发）。

**Vue 2 主要是利用“存取描述符”中的 `get` 和 `set`。**

#### Vue 2 如何实现响应式
当 Vue 初始化实例时，它会递归遍历 `data` 对象的所有属性，并使用 `Object.defineProperty` 把这些属性全部转化为 **getter/setter**。

*   **Getter (依赖收集)**：当你访问 `this.message` 时，触发 `get`，Vue 会记录“谁（哪个组件/Watcher）在用我”，把它加入依赖列表。
*   **Setter (派发更新)**：当你修改 `this.message = 'new'` 时，触发 `set`，Vue 会通知依赖列表中所有的 Watcher 去更新视图。

```javascript
// Vue 2 简易原理模拟
function defineReactive(obj, key, val) {
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get() {
      console.log(`读取 ${key}`);
      // 这里进行依赖收集 (Dep.depend())
      return val;
    },
    set(newVal) {
      if (newVal === val) return;
      console.log(`设置 ${key} 为 ${newVal}`);
      val = newVal;
      // 这里通知视图更新 (Dep.notify())
    }
  });
}
```

#### 致命缺陷 (Vue 2 的痛点)
1.  **无法检测对象属性的添加或删除**：
    *   `Object.defineProperty` 只能劫持**已经存在**的属性。
    *   如果你执行 `this.obj.newProp = 123`，Vue 2 无法感知，视图不会更新。
    *   **解决方案**：必须使用 `Vue.set(obj, 'newProp', 123)` 或 `this.$set`。
2.  **数组索引修改无法拦截**：
    *   出于性能考虑，Vue 2 没有重写数组索引的 `defineProperty`（因为数组可能很长）。
    *   执行 `this.list[0] = 100` 不会触发更新。
    *   **解决方案**：Vue 2 重写（Monkey Patch）了数组的 7 个变异方法（push, pop, splice...）来实现拦截。
3.  **初始化性能问题**：
    *   必须在启动时**一次性递归**遍历整个对象树。如果对象层级很深、数据量很大，页面加载会明显变慢。

---

### 2. Vue 3 基础：Proxy (代理协议)

Vue 3 彻底重构了响应式系统，使用了 **ES6** 的 `Proxy` 和 `Reflect`。

#### 技术原理
`Proxy` 可以理解为在目标对象之前架设了一层“拦截”。外界对该对象的访问，都必须先通过这层拦截。

与 `defineProperty` 只能监听属性不同，**`Proxy` 监听的是整个对象**。

#### Vue 3 如何实现响应式
Vue 3 使用 `new Proxy(target, handler)` 来创建响应式对象。

*   **拦截操作更多**：不仅能拦截读写（`get`/`set`），还能拦截删除（`deleteProperty`）、判断是否存在（`has`，即 `in` 操作符）等 13 种操作。
*   **配合 Reflect**：通常与 `Reflect` API 配合使用，以确保 `this` 指向正确并保留对象的默认行为。

```javascript
// Vue 3 简易原理模拟
function reactive(target) {
  return new Proxy(target, {
    get(target, key, receiver) {
      console.log(`Proxy 读取 ${key}`);
      // 依赖收集 (track)
      // 懒代理：如果属性值是对象，才递归调用 reactive
      const res = Reflect.get(target, key, receiver);
      return typeof res === 'object' ? reactive(res) : res; 
    },
    set(target, key, value, receiver) {
      console.log(`Proxy 设置 ${key}`);
      const res = Reflect.set(target, key, value, receiver);
      // 派发更新 (trigger)
      return res;
    },
    deleteProperty(target, key) {
      console.log(`Proxy 删除 ${key}`);
      return Reflect.deleteProperty(target, key);
    }
  });
}
```

#### 核心优势 (Vue 3 的改进)
1.  **全方位监听**：
    *   可以直接监听对象属性的**新增**和**删除**。不再需要 `Vue.set` 或 `Vue.delete`。
2.  **完美支持数组**：
    *   可以直接监听数组索引的变化和长度的变化，不再需要重写数组方法。
3.  **懒加载 (Lazy Observation)**：
    *   Vue 3 不会在初始化时递归处理所有嵌套属性。只有当你真正**访问**某个嵌套对象时，它才会被转化为 Proxy。这极大地提升了大数据量下的初始化性能。

---

### 总结对比表

| 特性 | Vue 2 (Object.defineProperty) | Vue 3 (Proxy) |
| :--- | :--- | :--- |
| **拦截层级** | 针对对象的**属性**进行拦截 | 针对**整个对象**进行拦截 |
| **新增/删除属性** | **不支持** (需用 `Vue.set` / `Vue.delete`) | **支持** (原生拦截 `set` / `deleteProperty`) |
| **数组支持** | **不支持**索引/长度修改 (需重写数组方法) | **支持** |
| **嵌套对象处理** | 初始化时**递归遍历** (性能开销大) | 访问时**按需处理** (懒代理，性能好) |
| **兼容性** | 支持 IE9+ | 不支持 IE (且无法 Polyfill) |
| **拦截操作种类** | 仅 get, set | get, set, deleteProperty, has, ownKeys 等 13 种 |

**比喻总结：**

*   **Vue 2 (defineProperty)** 就像是给房子里的**每一扇门**单独安装了一个报警器。如果后来把墙砸了开了个新门（新增属性），因为没装报警器，系统就不知道了。而且建房子时就要把所有门的报警器装好，很累。
*   **Vue 3 (Proxy)** 就像是在房子门口设立了一个**安检站**。不管你从哪个门进、或者你是新开了门、或者是搬走家具（删除属性），只要经过这个安检站（对象本身），都会被拦截和记录。而且如果你只是在门口看看不进去（未访问深层数据），安检员就不会去检查里面的房间。

好的，为了让你直观地理解这两种技术原理，我们将抛开 Virtual DOM、模板编译等复杂功能，**只保留最核心的“响应式系统”**。

下面我将分别实现一个极简版的 **Mini-Vue2** 和 **Mini-Vue3**。

---

### 1. Mini-Vue 2 (基于 `Object.defineProperty`)

Vue 2 的核心在于“依赖收集”和“数据劫持”。我们需要一个 `Dep` 类来专门管理依赖（观察者模式）。

#### 代码实现

```javascript
// === 1. 依赖收集器 Dep ===
class Dep {
  constructor() {
    this.subscribers = new Set(); // 存放依赖（Watcher）
  }

  depend() {
    // 如果当前有正在运行的函数（Watcher），把它加入订阅列表
    if (activeUpdate) {
      this.subscribers.add(activeUpdate);
    }
  }

  notify() {
    // 数据变化时，执行所有订阅的函数
    this.subscribers.forEach(updateFn => updateFn());
  }
}

let activeUpdate = null; // 全局变量，指向当前正在执行的更新函数

// 这是一个简化版的 Watcher，用于自动运行函数
function autorun(updateFn) {
  function wrappedUpdate() {
    activeUpdate = wrappedUpdate; // 标记当前正在运行我
    updateFn();                   // 执行函数（触发 getter）
    activeUpdate = null;          // 执行完重置
  }
  wrappedUpdate();
}

// === 2. 核心：数据劫持 ===
function observe(obj) {
  if (!obj || typeof obj !== 'object') return;

  Object.keys(obj).forEach(key => {
    let internalValue = obj[key];
    const dep = new Dep(); // 每个属性都有一个专属的 Dep 实例

    // 递归遍历子对象
    observe(internalValue);

    Object.defineProperty(obj, key, {
      enumerable: true,
      configurable: true,
      get() {
        // 【关键】依赖收集：谁在读取我，我就把谁记下来
        dep.depend();
        return internalValue;
      },
      set(newVal) {
        if (newVal === internalValue) return;
        // 【关键】派发更新：值变了，通知所有人
        internalValue = newVal;
        observe(newVal); // 如果新值是对象，也要监听
        dep.notify();
      }
    });
  });
}

// === 3. 模拟 Vue 2 实例 ===
class MiniVue2 {
  constructor(options) {
    this.$data = options.data;
    observe(this.$data); // 开启响应式
    
    // 模拟挂载和渲染
    autorun(() => {
      options.render.call(this);
    });
  }
}
```

#### 测试运行
```javascript
const app = new MiniVue2({
  data: {
    count: 0,
    info: { name: 'Vue2' }
  },
  render() {
    console.log(`[渲染 View] count: ${this.$data.count}, name: ${this.$data.info.name}`);
  }
});

// 测试 1: 修改基本类型 -> 触发更新
app.$data.count = 1; 
// 输出: [渲染 View] count: 1, name: Vue2

// 测试 2: 修改嵌套对象 -> 触发更新
app.$data.info.name = 'React'; 
// 输出: [渲染 View] count: 1, name: React

// 测试 3: 缺陷演示 —— 新增属性
app.$data.newProp = 'oops'; 
// (无输出，因为 defineProperty 无法拦截新增属性)
```

---

### 2. Mini-Vue 3 (基于 `Proxy`)

Vue 3 不需要手动遍历所有属性，而是使用一个全局的 `targetMap` 来存储所有对象的依赖关系。

#### 代码实现

```javascript
// === 1. 全局依赖管理 ===
// 结构: target(对象) -> key(属性) -> dep(Set: 存放副作用函数)
const targetMap = new WeakMap();

let activeEffect = null; // 类似于 Vue2 的 activeUpdate

function effect(fn) {
  const effectFn = () => {
    activeEffect = effectFn;
    fn();
    activeEffect = null;
  };
  effectFn();
}

// 收集依赖 (对应 get)
function track(target, key) {
  if (!activeEffect) return;
  
  let depsMap = targetMap.get(target);
  if (!depsMap) {
    depsMap = new Map();
    targetMap.set(target, depsMap);
  }
  
  let dep = depsMap.get(key);
  if (!dep) {
    dep = new Set();
    depsMap.set(key, dep);
  }
  
  dep.add(activeEffect);
}

// 触发更新 (对应 set)
function trigger(target, key) {
  const depsMap = targetMap.get(target);
  if (!depsMap) return;
  
  const dep = depsMap.get(key);
  if (dep) {
    dep.forEach(effectFn => effectFn());
  }
}

// === 2. 核心：Proxy 代理 ===
function reactive(target) {
  // 如果不是对象，直接返回
  if (!target || typeof target !== 'object') return target;

  const handler = {
    get(target, key, receiver) {
      // 收集依赖
      track(target, key);
      
      const result = Reflect.get(target, key, receiver);
      // 【关键】懒代理：只有当访问到了嵌套对象时，才把它转为响应式
      return typeof result === 'object' ? reactive(result) : result;
    },
    set(target, key, value, receiver) {
      const oldValue = target[key];
      const result = Reflect.set(target, key, value, receiver);
      
      // 值变化时触发更新
      if (oldValue !== value) {
        trigger(target, key);
      }
      return result;
    },
    // Vue3 的优势：还可以拦截 deleteProperty, has 等
    deleteProperty(target, key) {
      const result = Reflect.deleteProperty(target, key);
      trigger(target, key); // 删除属性也能触发更新
      return result;
    }
  };

  return new Proxy(target, handler);
}
```

#### 测试运行
```javascript
// 模拟组件状态
const state = reactive({
  count: 0,
  list: ['a']
});

// 模拟视图渲染函数
effect(() => {
  console.log(`[渲染 View] count: ${state.count}, list: ${state.list.join(',')}`);
});

// 测试 1: 修改基本属性 -> 触发
state.count = 1; 
// 输出: [渲染 View] count: 1, list: a

// 测试 2: 数组操作 (Vue2 的痛点) -> 触发
state.list.push('b'); 
// 输出: [渲染 View] count: 1, list: a,b

// 测试 3: 优势演示 —— 新增属性
// 假设我们在 effect 里用到了 state.newProp (虽然上面没写，但逻辑上支持)
// 动态给对象增加属性，Proxy 是能感知到的，只要 effect 里有访问该属性的逻辑，就能触发。
```

---

### 总结与核心区别

1.  **闭包 vs 全局 Map**:
    *   **Mini-Vue2**: 依赖关系保存在闭包中的 `dep` 实例里（`defineReactive` 函数作用域内）。
    *   **Mini-Vue3**: 依赖关系保存在全局的 `targetMap` 中，对象和依赖是分离的。

2.  **递归 vs 懒代理**:
    *   **Mini-Vue2**: `observe` 函数一开始就必须递归遍历整个对象（看 `observe(internalValue)` 的位置）。
    *   **Mini-Vue3**: 在 `get` 拦截中，只有返回值是对象时，才临时把它变成 `reactive`（`return reactive(result)`），这叫懒代理。

3.  **拦截能力**:
    *   **Mini-Vue2**: 只能拦截已经定义的 key。
    *   **Mini-Vue3**: `Proxy` 拦截的是对象本身的操作，所以 `push`、`delete`、`state.newProp = x` 都能被拦截到。
*   
**是的，Vue 2 和 Vue 3 都完美支持嵌套对象。**

但是在实现“如何支持嵌套”这个逻辑上，两者采用了截然不同的策略，这对性能有很大的影响。

以下是详细的实现原理对比：

---

### 1. Vue 2 的实现：递归遍历 (一次性完成)

在 Vue 2 中，支持嵌套对象是通过**递归调用**来实现的。

**原理：**
当 Vue 初始化 `data` 时，它会遍历对象的所有属性。如果发现某个属性的值仍然是一个对象（例如 `user` 是个对象），它会立即把这个子对象也拿去执行 `observe()`。这个过程会一直递归下去，直到所有深层的属性都被 `Object.defineProperty` 加上了 getter/setter。

**代码回看（基于上一条回复的 Mini-Vue2）：**

```javascript
function observe(obj) {
  if (!obj || typeof obj !== 'object') return;

  Object.keys(obj).forEach(key => {
    let internalValue = obj[key];

    // 【重点在这里】
    // 在定义当前属性之前，先递归遍历它的值
    // 如果 internalValue 是对象，它内部的属性也会被监听
    observe(internalValue); 

    Object.defineProperty(obj, key, {
      // ... get / set ...
      set(newVal) {
        if (newVal === internalValue) return;
        internalValue = newVal;
        // 【还有这里】
        // 如果用户赋值了一个新对象 this.info = { a: 1 }
        // 必须对新来的对象再次开启递归监听
        observe(newVal); 
        dep.notify();
      }
    });
  });
}
```

**特点与代价：**
*   **深层监听**：支持无限层级的嵌套。
*   **性能隐患**：如果在 `data` 中定义了一个非常庞大的深层对象（比如几千行的 JSON 数据），Vue 2 会在组件初始化（`created` 之前）就**一次性递归遍历完所有层级**。这会导致页面加载时的 JS 执行时间变长，也就是所谓的“白屏时间”可能增加。

---

### 2. Vue 3 的实现：惰性代理 (用到才监听)

Vue 3 同样支持嵌套对象，但它是**懒惰（Lazy）**的。它不会在初始化时递归遍历整个对象。

**原理：**
`Proxy` 只能拦截当前这一层对象。当你尝试访问一个深层属性时（例如 `state.user.name`）：
1.  先拦截 `state.user` 的读取操作（`get`）。
2.  检测到 `user` 是一个对象。
3.  **此时此刻**，才将这个 `user` 对象包装成一个新的 `Proxy` 并返回。
4.  如果你永远不访问 `state.user.name`，那么 `user` 内部永远不会被代理，这就是原生的普通对象。

**代码回看（基于 Mini-Vue3）：**

```javascript
const handler = {
  get(target, key, receiver) {
    const result = Reflect.get(target, key, receiver);
    
    // 【重点在这里】
    // 只有当 result 是对象时，才递归调用 reactive
    // 这叫 "Lazy Reactivity" (惰性响应式)
    if (typeof result === 'object' && result !== null) {
      return reactive(result); 
    }

    return result;
  }
  // ...
};
```

**特点与优势：**
*   **按需加载**：只有当你通过点语法（`.`）读取深层数据时，Vue 3 才会去代理那一层。
*   **性能提升**：对于庞大的嵌套数据，Vue 3 的初始化速度比 Vue 2 快得多，因为它不需要在一开始就遍历整棵树。

---

### 3. 总结

| 特性 | Vue 2 (defineProperty) | Vue 3 (Proxy) |
| :--- | :--- | :--- |
| **嵌套支持** | **支持** (通过递归) | **支持** (通过递归代理) |
| **执行时机** | **初始化时**一次性递归到底 | **访问属性时**才把下一级转为 Proxy |
| **性能表现** | 数据量大/层级深时，启动慢 | 启动快，运行时有极其微小的代理开销 |
| **新对象赋值** | Setter 中需要手动调用 `observe(newVal)` | Proxy 的 getter 自动处理，无需特殊逻辑 |

**一句话回答：**
两者都支持。Vue 2 是**“勤奋模式”**，一开始就把所有层级都干完（初始化慢）；Vue 3 是**“偷懒模式”**，读到哪一层才把哪一层变成响应式（初始化快）。

**是的，Vue 2 和 Vue 3 都完美支持嵌套对象。**

但是在实现“如何支持嵌套”这个逻辑上，两者采用了截然不同的策略，这对性能有很大的影响。

以下是详细的实现原理对比：

---

### 1. Vue 2 的实现：递归遍历 (一次性完成)

在 Vue 2 中，支持嵌套对象是通过**递归调用**来实现的。

**原理：**
当 Vue 初始化 `data` 时，它会遍历对象的所有属性。如果发现某个属性的值仍然是一个对象（例如 `user` 是个对象），它会立即把这个子对象也拿去执行 `observe()`。这个过程会一直递归下去，直到所有深层的属性都被 `Object.defineProperty` 加上了 getter/setter。

**代码回看（基于上一条回复的 Mini-Vue2）：**

```javascript
function observe(obj) {
  if (!obj || typeof obj !== 'object') return;

  Object.keys(obj).forEach(key => {
    let internalValue = obj[key];

    // 【重点在这里】
    // 在定义当前属性之前，先递归遍历它的值
    // 如果 internalValue 是对象，它内部的属性也会被监听
    observe(internalValue); 

    Object.defineProperty(obj, key, {
      // ... get / set ...
      set(newVal) {
        if (newVal === internalValue) return;
        internalValue = newVal;
        // 【还有这里】
        // 如果用户赋值了一个新对象 this.info = { a: 1 }
        // 必须对新来的对象再次开启递归监听
        observe(newVal); 
        dep.notify();
      }
    });
  });
}
```

**特点与代价：**
*   **深层监听**：支持无限层级的嵌套。
*   **性能隐患**：如果在 `data` 中定义了一个非常庞大的深层对象（比如几千行的 JSON 数据），Vue 2 会在组件初始化（`created` 之前）就**一次性递归遍历完所有层级**。这会导致页面加载时的 JS 执行时间变长，也就是所谓的“白屏时间”可能增加。

---

### 2. Vue 3 的实现：惰性代理 (用到才监听)

Vue 3 同样支持嵌套对象，但它是**懒惰（Lazy）**的。它不会在初始化时递归遍历整个对象。

**原理：**
`Proxy` 只能拦截当前这一层对象。当你尝试访问一个深层属性时（例如 `state.user.name`）：
1.  先拦截 `state.user` 的读取操作（`get`）。
2.  检测到 `user` 是一个对象。
3.  **此时此刻**，才将这个 `user` 对象包装成一个新的 `Proxy` 并返回。
4.  如果你永远不访问 `state.user.name`，那么 `user` 内部永远不会被代理，这就是原生的普通对象。

**代码回看（基于 Mini-Vue3）：**

```javascript
const handler = {
  get(target, key, receiver) {
    const result = Reflect.get(target, key, receiver);
    
    // 【重点在这里】
    // 只有当 result 是对象时，才递归调用 reactive
    // 这叫 "Lazy Reactivity" (惰性响应式)
    if (typeof result === 'object' && result !== null) {
      return reactive(result); 
    }

    return result;
  }
  // ...
};
```

**特点与优势：**
*   **按需加载**：只有当你通过点语法（`.`）读取深层数据时，Vue 3 才会去代理那一层。
*   **性能提升**：对于庞大的嵌套数据，Vue 3 的初始化速度比 Vue 2 快得多，因为它不需要在一开始就遍历整棵树。

---

### 3. 总结

| 特性 | Vue 2 (defineProperty) | Vue 3 (Proxy) |
| :--- | :--- | :--- |
| **嵌套支持** | **支持** (通过递归) | **支持** (通过递归代理) |
| **执行时机** | **初始化时**一次性递归到底 | **访问属性时**才把下一级转为 Proxy |
| **性能表现** | 数据量大/层级深时，启动慢 | 启动快，运行时有极其微小的代理开销 |
| **新对象赋值** | Setter 中需要手动调用 `observe(newVal)` | Proxy 的 getter 自动处理，无需特殊逻辑 |

**一句话回答：**
两者都支持。Vue 2 是**“勤奋模式”**，一开始就把所有层级都干完（初始化慢）；Vue 3 是**“偷懒模式”**，读到哪一层才把哪一层变成响应式（初始化快）。

在 Vue 2 中，`watch` 的 `deep: true` 实现原理其实非常“简单粗暴”。

它的核心逻辑就是：**既然我不知道你里面哪一层会变，那我就把你里面所有的属性都“看”（读取）一遍。**

因为在 Vue 2 中，只有**读取（Access）**数据才会触发 `getter`，进而将当前的 Watcher（观察者）加入到该属性的依赖列表（Dep）中。

以下是实现 `deep: true` 的具体步骤和代码模拟：

### 1. 核心原理：递归遍历（Traverse）

当你设置了 `deep: true`，Vue 的 Watcher 在读取了顶层对象（比如 `obj`）之后，会额外调用一个 `traverse` 函数。

这个 `traverse` 函数的作用就是**递归地读取对象内部的所有子属性**。

*   **读取 `obj`** -> 触发 `obj` 的 getter -> 收集依赖。
*   **读取 `obj.a`** -> 触发 `obj.a` 的 getter -> 收集依赖。
*   **读取 `obj.a.b`** -> 触发 `obj.a.b` 的 getter -> 收集依赖。

通过这种“地毯式”的读取，当前的 Watcher 就成功地混入了 `obj` 内部**每一层、每一个属性**的依赖列表中（订阅了所有的 Dep）。

只要其中任何一个属性发生变化（Setter 触发），都会通知这个 Watcher，从而触发回调。

### 2. 简易代码模拟

让我们回到 Mini-Vue2 的上下文，给 Watcher 增加深度监听的能力。

```javascript
// Vue 2 源码中类似的 traverse 逻辑简化版
const seenObjects = new Set(); // 防止循环引用导致的死循环

function traverse(val) {
  // 如果不是对象或数组，或者是被冻结的对象，就不用遍历了
  if ((!val || typeof val !== 'object') || Object.isFrozen(val)) {
    return;
  }
  
  // 防止循环引用（比如 a.b = a）
  if (seenObjects.has(val)) {
    return;
  }
  seenObjects.add(val);

  // 【核心操作】
  // 遍历对象的所有属性，或者数组的所有元素
  // 这里的 val[key] 就是一次“读取”操作，会触发 Getter
  if (Array.isArray(val)) {
    for (let i = 0; i < val.length; i++) {
      traverse(val[i]);
    }
  } else {
    const keys = Object.keys(val);
    for (let i = 0; i < keys.length; i++) {
      // 递归调用：读取 val[keys[i]]，触发 Getter，然后继续往深处走
      traverse(val[keys[i]]);
    }
  }
}

// Watcher 类的修改（伪代码）
class Watcher {
  constructor(vm, expOrFn, cb, options) {
    this.getter = parsePath(expOrFn); // 比如获取 'obj'
    this.deep = !!options.deep;       // 标记是否开启深度监听
    
    this.value = this.get();          // 初始化取值
  }

  get() {
    // 1. 设置当前 Watcher 为全局目标
    window.target = this;
    
    // 2. 读取顶层对象，触发最外层的 Getter
    let value = this.getter.call(this.vm, this.vm);
    
    // 3. 【关键点】如果开启了 deep，就手动去把里面全摸一遍
    if (this.deep) {
      traverse(value);
    }
    
    // 4. 清空全局目标
    window.target = null;
    return value;
  }
  
  update() {
    // ... 触发回调 ...
  }
}
```

### 3. 性能代价

理解了这个原理，你就明白了为什么面试官或官方文档通常建议**“慎用 `deep: true`”**。

*   **性能开销大**：当你开启 `deep: true` 时，Vue 必须遍历该对象的所有嵌套属性。如果对象结构很深、数据量很大（比如一个包含 1000 个 item 的列表），遍历过程会消耗大量的 CPU 时间。
*   **全量订阅**：Watcher 会订阅该对象树中**每一个**属性的 Dep。这不仅占用内存，而且任何微小的变动都会通知这个 Watcher。

### 4. 总结

**`deep: true` 是如何工作的？**

1.  **触发读取**：Watcher 在获取到顶层对象的值后。
2.  **地毯式访问**：检查 `deep` 标记，如果为真，则调用 `traverse` 方法。
3.  **递归 Getter**：`traverse` 递归遍历对象的所有子属性。因为 JavaScript 中访问属性（`val[key]`）会触发 getter，而此时 Watcher 正处于“收集依赖”的状态。
4.  **全面订阅**：最终，对象树中每一个属性的 `Dep` 里都记录了这个 Watcher。无论修改哪一层，都能通知到它。

这是一个非常深刻且触及响应式系统**灵魂**的问题。

简单来说，`activeUpdate`（在 Vue 源码中叫 `Dep.target`）的作用是：**解决“Getter 被触发时，到底是谁在读取我？”这个问题。**

如果没有这个变量，响应式系统就无法工作。下面我通过三个层面来解释为什么必须需要它。

---

### 1. 核心矛盾：Getter 是“被动”的

在 `Object.defineProperty` 或 `Proxy` 中，`get` 拦截器是非常“傻”的。

当 `get` 被触发时，它只知道两件事：
1.  有人读了我的值。
2.  我要返回这个值。

**它根本不知道“读取者”是谁。**

*   是组件的 **渲染函数 (Render)** 在读？（如果是，数据变了要刷新页面）
*   是 **计算属性 (Computed)** 在读？（如果是，数据变了要重新计算）
*   是用户的 **Watch** 在读？（如果是，数据变了要执行回调）
*   还是你仅仅在控制台敲了一行 `console.log(app.count)`？（如果是，数据变了**什么都不用做**）

**`activeUpdate` 就是那个“身份牌”。**

### 2. 场景演示：没有它会怎样？

假设我们没有 `activeUpdate`，代码大概是这样：

```javascript
get() {
  // 问题来了：我应该把谁加入订阅列表？
  // 我没有任何变量指向当前的 Watcher
  dep.depend( ??? ); 
  return val;
}
```

为了解决这个问题，我们需要一个**全局共享的变量**来传递信息。由于 JavaScript 是单线程的，我们可以安全地利用全局变量在函数调用栈之间传递上下文。

**有了 `activeUpdate` 后的流程：**

1.  **开始渲染前**：Vue 说：“现在轮到 `组件A` 渲染了”。于是执行 `activeUpdate = 组件A的Watcher`。
2.  **执行渲染**：代码运行到 `return this.message`。
3.  **触发 Getter**：`message` 的 `get` 方法触发。
4.  **检查身份**：`get` 内部看了一眼全局变量：“哦！现在 `activeUpdate` 是 `组件A`！看来是 `组件A` 需要我。”
5.  **记录依赖**：把 `组件A` 加入 `message` 的订阅列表。
6.  **渲染结束**：Vue 执行 `activeUpdate = null`。

### 3. 防止“误收集” (非常重要)

这是 `activeUpdate` 的另一个关键作用：**并不是所有的读取操作都需要被监听。**

试想以下场景：

```javascript
// 场景：开发者只是在控制台调试
console.log(app.count); 
```

这行代码会读取 `count`，触发 `get`。

*   **如果没有 `activeUpdate` 机制**（或者机制设计得不好）：系统可能会报错，或者试图绑定一个不存在的依赖。
*   **有了 `activeUpdate` 机制**：
    1.  运行 `console.log` 时，并没有任何 Watcher 在运行，所以 `activeUpdate` 是 `null`。
    2.  触发 `get`。
    3.  `get` 检查：`if (activeUpdate) { ... }`。
    4.  发现是 `null`，于是**只返回值，不收集依赖**。

这保证了只有 Vue 内部管理的副作用函数（Render/Computed/Watch）才会被追踪，外部随意的读取不会导致内存泄漏或错误的更新。

### 4. 总结

可以将 `activeUpdate` 想象成一个**“接力棒”**或者**“令牌”**。

1.  **Watcher 准备干活时**：先把令牌拿在手里（赋值给全局变量）。
2.  **去读取数据时**：数据（属性）看到你有令牌，就把你的名字记在小本本上（收集依赖）。
3.  **干完活后**：把令牌扔掉（重置为 null）。

这样，数据就能精确地知道，每一次读取操作背后，真正的“雇主”是谁。

**完全不一样。** 这两个名字非常容易让人混淆，尤其是如果你了解经典的“观察者模式”（Observer Pattern）。

在 Vue 的源码架构中，它们的职责是截然不同的：

*   **Observer (观察者类)**：它是**数据的加工者**（负责“监听”数据变化）。
*   **Watcher (订阅者类)**：它是**指令的执行者**（负责“做出”反应）。

---

### 1. 核心区别一览

| 特性 | Observer (加工者) | Watcher (执行者) |
| :--- | :--- | :--- |
| **主要职责** | 把普通对象变成响应式对象。 | 当数据变了，执行具体的业务逻辑（如刷新页面）。 |
| **核心动作** | 遍历对象属性，使用 `Object.defineProperty` 添加 Getter/Setter。 | 也就是 `render` 函数、`computed`、`$watch` 的背后实体。 |
| **存在数量** | 只有 data 中的**对象/数组**才会生成 Observer 实例。 | 每个组件、每个 computed、每个 watch 都会生成 Watcher 实例。 |
| **它认识谁？** | 它创建 **Dep**。 | 它订阅 **Dep**。 |

---

### 2. 它们是如何协作的？（一条龙服务）

为了让你理解它们的关系，我们需要引入第三者 **Dep**。

#### 第一阶段：初始化（Observer 出场）
Vue 启动时，**Observer** 会像一个“装修队”一样进场：
1.  它遍历 `data` 中的所有属性。
2.  给每个属性安装“传感器”（Getter/Setter）。
3.  **注意**：在安装“传感器”的时候，Observer 会为每个属性创建一个 **Dep**（专门用来存电话号码的通讯录）。

> **Observer 的任务到此基本结束**，它把数据改造好了。

#### 第二阶段：使用数据（Watcher 出场）
当组件开始渲染时，**Watcher** 像一个“访客”一样进场：
1.  Watcher 读取数据（触发 Getter）。
2.  数据中的 **Dep** 发现有人读它，就把这个 Watcher 记在小本本上（收集依赖）。

#### 第三阶段：数据变化
1.  你修改数据（触发 Setter）。
2.  **Dep** 通知 Watcher。
3.  **Watcher** 执行 `update` 更新视图。

---

### 3. 为什么名字这么乱？（设计模式视角的解释）

这可能是最让你困惑的地方。

在经典的**设计模式（Observer Pattern）**中：
*   **Subject（目标）**：负责被观察，发生改变时通知观察者。
*   **Observer（观察者）**：负责接收通知并更新。

**但在 Vue 的源码命名中：**

1.  **Vue 的 `Observer` 类**：
    *   它**不是**经典模式里的“观察者”。
    *   它的作用更像是**“Subject 工厂”**，它负责把数据转换成可以被观察的 Subject（即 Dep）。

2.  **Vue 的 `Watcher` 类**：
    *   它才是经典模式里真正的**“观察者 (Observer)”**。

### 4. 生活类比

为了彻底分清，我们可以把 Vue 的系统想象成一个**大楼安防系统**：

*   **Observer（安装工人）**：
    *   他的工作是把大楼里的每一扇窗户都装上**报警器**。
    *   他只负责**安装**，装完就走，不负责后面的监控。

*   **Dep（报警器本身）**：
    *   装在窗户上。如果窗户被打破（数据修改），它会响。
    *   它里面存着保安室的电话号码。

*   **Watcher（保安）**：
    *   坐在监控室里的人。
    *   一旦报警器（Dep）响了，他负责**冲出去抓人**（更新 DOM）或者**报警**（触发回调）。

### 总结

*   **Observer** 是**“建设者”**：它利用 `Object.defineProperty` 递归地把数据变成响应式的。
*   **Watcher** 是**“使用者”**：它依赖数据，数据变了它就干活。

所以在 Vue 中：**如果没有 Observer，Watcher 就没法监听到数据的变化；如果没有 Watcher，Observer 就算监测到了变化也没人去处理。**

这是一个非常好的实战题目。要实现一个极简版的 Vue2，我们需要将代码拆解为几个核心模块：

1.  **Observer (响应式)**：劫持数据。
2.  **Dep & Watcher (依赖收集)**：连接数据和视图的桥梁。
3.  **Compiler (模拟)**：这里我们不写复杂的正则解析器，而是直接手写 `render` 函数（生成虚拟 DOM），这是 Vue 最终编译出来的样子。
4.  **VDOM & Patch (虚拟 DOM 与 渲染)**：将虚拟 DOM 变为真实 DOM。
5.  **Vue Class (主类)**：整合以上所有逻辑。

下面是不到 100 行代码的核心逻辑实现：

### 1. 核心代码实现

```javascript
// ==========================================
// 1. VDOM & h函数 (模拟虚拟DOM)
// ==========================================
function h(tag, props, children) {
    return { tag, props, children }; // 返回一个 VNode 对象
}

// ==========================================
// 2. Dep & Watcher (发布订阅模式)
// ==========================================
class Dep {
    constructor() {
        this.subs = []; // 存放 Watcher
    }
    depend() {
        if (Dep.target) {
            this.subs.push(Dep.target); // 收集依赖
        }
    }
    notify() {
        this.subs.forEach(watcher => watcher.update()); // 派发更新
    }
}
Dep.target = null; // 全局变量，记录当前正在计算的 Watcher

class Watcher {
    constructor(vm, renderFunc) {
        this.vm = vm;
        this.getter = renderFunc;
        this.get(); // 实例化时立即执行一次，触发依赖收集
    }
    get() {
        Dep.target = this; // 标记当前 watcher
        this.getter.call(this.vm); // 执行渲染函数 -> 触发数据的 getter -> 收集依赖
        Dep.target = null; // 清除标记
    }
    update() {
        this.get(); // 重新渲染
    }
}

// ==========================================
// 3. Observer (响应式劫持)
// ==========================================
function defineReactive(obj, key, val) {
    const dep = new Dep(); // 每个 key 对应一个 Dep
    
    // 递归处理嵌套对象
    observe(val);

    Object.defineProperty(obj, key, {
        enumerable: true,
        configurable: true,
        get() {
            // 依赖收集：如果在 Watcher 上下文中读取，则收集
            if (Dep.target) dep.depend();
            return val;
        },
        set(newVal) {
            if (newVal === val) return;
            val = newVal;
            observe(newVal); // 新值也要响应式
            dep.notify(); // 派发更新 -> 触发 Watcher.update
        }
    });
}

function observe(data) {
    if (!data || typeof data !== 'object') return;
    Object.keys(data).forEach(key => defineReactive(data, key, data[key]));
}

// ==========================================
// 4. Vue Class (主流程)
// ==========================================
class Vue {
    constructor(options) {
        this.$options = options;
        this.$data = options.data;
        this.$el = document.querySelector(options.el);

        // 1. 数据代理：让 this.msg 能访问到 this.$data.msg
        this._proxyData(this.$data);

        // 2. 响应式处理
        observe(this.$data);

        // --- 生命周期：created ---
        if (options.created) options.created.call(this);

        // 3. 挂载
        this.$mount();
    }

    _proxyData(data) {
        Object.keys(data).forEach(key => {
            Object.defineProperty(this, key, {
                get() { return data[key]; },
                set(val) { data[key] = val; }
            });
        });
    }

    $mount() {
        // 创建“渲染 Watcher”
        // 这里的逻辑是：Watcher 执行 getter -> 调用 render -> 读取数据 -> 收集依赖
        new Watcher(this, () => {
            this._update(this._render());
        });
        
        // --- 生命周期：mounted (简化版，仅首次触发) ---
        if (this.$options.mounted && !this._isMounted) {
            this.$options.mounted.call(this);
            this._isMounted = true;
        }
    }

    _render() {
        // 调用用户传入的 render 函数，生成 VNode
        return this.$options.render.call(this, h);
    }

    _update(vnode) {
        // 简化版 Patch：不做复杂的 Diff，直接清空旧 DOM 重新生成
        // 真实 Vue 这里会进行 diff 算法比对
        const realDom = this._createEl(vnode);
        this.$el.innerHTML = ''; 
        this.$el.appendChild(realDom);
    }

    _createEl(vnode) {
        // 简单处理：如果是文本节点（children 是字符串）
        if (typeof vnode === 'string' || typeof vnode === 'number') {
            return document.createTextNode(vnode);
        }
        // 创建元素
        const el = document.createElement(vnode.tag);
        // 处理 props (简单处理事件和属性)
        if (vnode.props) {
            Object.keys(vnode.props).forEach(key => {
                if (key.startsWith('on')) {
                    el.addEventListener(key.slice(2).toLowerCase(), vnode.props[key].bind(this));
                } else {
                    el.setAttribute(key, vnode.props[key]);
                }
            });
        }
        // 递归处理 children
        if (vnode.children) {
            vnode.children.forEach(child => {
                el.appendChild(this._createEl(child));
            });
        }
        return el;
    }
}
```

### 2. 测试代码 (HTML 使用示例)

你可以直接把上面的代码复制到浏览器的 Console 或者一个 HTML 文件中运行。

```html
<div id="app"></div>

<script>
    // --- 这里粘贴上面的 Vue 实现代码 ---

    const vm = new Vue({
        el: '#app',
        data: {
            msg: 'Hello Vue 2!',
            count: 0
        },
        // 模拟 Vue 的 created 生命周期
        created() {
            console.log('生命周期: created 触发');
        },
        // 模拟 Vue 的 mounted 生命周期
        mounted() {
            console.log('生命周期: mounted 触发');
            // 模拟异步更新
            setTimeout(() => {
                this.count = 100;
                console.log('异步修改了 count');
            }, 1000);
        },
        // 为了简化解析器逻辑，我们直接写 render 函数 (相当于编译后的代码)
        render(h) {
            return h('div', { id: 'container' }, [
                h('h1', { style: 'color: red' }, [this.msg]),
                h('p', {}, [`当前计数: ${this.count}`]),
                h('button', { onClick: this.add }, ['点击 +1'])
            ]);
        },
        // 方法
        methods: { // 注意：上面的简化代码没处理 methods 混入，这里简单扩充一下思路
            // 实际 Vue 会把 methods 混入到 this
        } 
    });
    
    // 手动挂载方法演示
    vm.add = function() {
        this.count++;
        console.log('Count 更新为:', this.count);
    }
</script>
```

### 3. 代码核心逻辑解析

#### 1. 响应式系统 (`Object.defineProperty`)
*   **代码位置**：`defineReactive` 函数。
*   **原理**：利用闭包保存一个 `Dep` 实例。Getter 中调用 `dep.depend()` 收集依赖，Setter 中调用 `dep.notify()` 通知更新。

#### 2. 依赖收集流程 (`Dep` & `Watcher`)
*   **Watcher (渲染 Watcher)**：在 `$mount` 时创建。它负责调用 `_render`。
*   **Dep.target**：这是一个精妙的全局开关。
    1.  Watcher 开始执行 `render` 前，把自己赋值给 `Dep.target`。
    2.  `render` 函数读取 `this.msg`。
    3.  `this.msg` 的 Getter 触发，看到 `Dep.target` 有值，就把这个 Watcher 加入自己的订阅列表。
    4.  Watcher 执行完毕，将 `Dep.target` 置空。

#### 3. 虚拟 DOM (`h` 和 VNode)
*   `h` 函数就是 Vue 中的 `createElement`。它不操作 DOM，只返回一个纯 JS 对象（VNode），描述节点长什么样。
*   例如：`{ tag: 'div', children: [...] }`。

#### 4. 挂载与更新 (`_update` & `patch`)
*   **代码位置**：`Vue.prototype._update`。
*   在真实的 Vue2 中，这里包含复杂的 **Diff 算法**（同层比较、双端指针等）。
*   **简化**：为了演示核心流程，我这里的 `_createEl` 直接把旧的 `innerHTML` 清空，全部用新的 VNode 创建一遍 DOM。这性能很差，但逻辑闭环了：
    *   **Setter** -> **Dep.notify** -> **Watcher.update** -> **_render (生成新 VNode)** -> **_update (暴力替换 DOM)**。

### 总结
这个极简版 Vue 涵盖了 Vue2 最本质的逻辑闭环：
**Data -> Observer -> Dep -> Watcher -> Render -> VDOM -> View**。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-concept)