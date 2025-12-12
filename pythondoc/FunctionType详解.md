<div id="chap-function-type"></div>

[⬆️ 返回目录](#catalog)


## FunctionType

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-descriptor)

`types.FunctionType` 是 Python 中最核心的类型之一。

一句话概括：**它是 Python 解释器用来将“死”的字节码（Bytecode）与“活”的执行环境（Globals/Closure）结合在一起的胶水。**

当你写一个 `def` 语句时，Python 编译器会自动帮你做这件事；而直接使用 `types.FunctionType`，则是允许你**手动组装**一个函数。

---

### 一、 核心原理：解剖一个函数

在 Python 中，一个函数并不是单一的实体，它是由 **5 个核心部件** 组装而成的。`types.FunctionType` 的构造函数恰好暴露了这 5 个部件：

```python
class FunctionType(code, globals, name=None, argdefs=None, closure=None)
```

1.  **`code` (代码对象)**：
    *   这是函数的“灵魂”或“引擎”。
    *   它包含了编译后的字节码（指令）、常量表、变量名列表。
    *   它是只读的、不可变的。
    *   **关键点**：代码对象只知道“我要打印变量 `a`”，但它不知道 `a` 的值是多少。

2.  **`globals` (全局命名空间)**：
    *   这是函数的“环境”或“上下文”。
    *   通常就是定义该函数时的模块的 `__dict__`。
    *   **关键点**：当字节码执行 `LOAD_GLOBAL` 指令时，就要去这个字典里查值。

3.  **`name` (函数名)**：
    *   函数的 `__name__` 属性，主要用于调试和显示。

4.  **`argdefs` (默认参数)**：
    *   一个元组，存储了带有默认值的参数（例如 `def foo(x=1)` 中的 `1`）。

5.  **`closure` (闭包)**：
    *   如果函数嵌套在另一个函数里，并引用了外部变量，这些变量会被打包成 `cell` 对象存在这里。

---

### 二、 实战应用：手动“捏”一个函数

通常我们不需要手动用它，但在元编程中，它能实现一些常规语法做不到的事情。

#### 应用场景 1：沙箱执行 (Sandboxing) / 环境隔离

假设你有一段代码，你想让它运行，但**不想让它访问你当前的全局变量**（比如密码、配置），或者你想**偷梁换柱**，把 `print` 换成写日志。

你可以用 `FunctionType` 创建一个使用**自定义 `globals` 字典**的函数。

```python
import types

# 1. 定义一个普通函数作为模板
def template_func():
    return secret_key  # 这个变量在当前环境不存在，稍后我们注入

# 2. 获取它的代码对象 (只包含逻辑，不包含值)
code_obj = template_func.__code__

# 3. 准备一个“假”的环境
fake_globals = {
    'secret_key': '123456-Fake-Key',  # 注入变量
    '__builtins__': __builtins__      # 必须注入内置函数，否则连 print 都用不了
}

# 4. 手动组装新函数
sandboxed_func = types.FunctionType(code_obj, fake_globals, "sandboxed")

# 5. 运行
# print(template_func()) # 报错：NameError: name 'secret_key' is not defined
print(sandboxed_func())  # 输出: 123456-Fake-Key
```
**原理**：两个函数共用同一套字节码（逻辑），但指向了不同的查找字典（环境）。

#### 应用场景 2：彻底拷贝一个函数 (Deep Copy)

Python 的 `copy.deepcopy` 对函数通常是**浅拷贝**（直接返回原引用）。如果你想修改一个函数的属性（比如 `func.is_admin = True`）而不影响原始函数，或者想修改它的默认参数而不影响原版，你需要用 `FunctionType` 重建它。

```python
import types

def original_func(x, y=10):
    return x + y

# 复制函数的逻辑
def copy_function(func):
    new_func = types.FunctionType(
        func.__code__,       # 复用代码
        func.__globals__,    # 复用全局变量
        name=func.__name__,
        argdefs=func.__defaults__, # 复用默认参数
        closure=func.__closure__
    )
    # 复制元数据 (docstring, dict 等)
    new_func.__dict__.update(func.__dict__) 
    return new_func

# 创建副本
cloned_func = copy_function(original_func)

# 修改副本的默认参数
cloned_func.__defaults__ = (999,) 

print(original_func(1)) # 输出 11 (原版不受影响)
print(cloned_func(1))   # 输出 1000 (副本变了)
```

#### 应用场景 3：动态编译与逻辑注入 (Rule Engine)

结合 `compile()`，你可以将字符串（例如从数据库读取的业务规则）转化为可调用的函数。

```python
import types

source_code = """
def calculate_discount(price):
    if price > 100:
        return price * 0.8
    return price
"""

# 1. 编译字符串为字节码
# 'exec' 模式编译出的是 Module 级别的代码块
module_code = compile(source_code, filename="<string>", mode="exec")

# 2. 从 Module 代码块中找到我们在里面定义的那个函数的代码块
#通常 constant 列表里的第一个 code object 就是
func_code = [c for c in module_code.co_consts if isinstance(c, types.CodeType)][0]

# 3. 组装
discount_func = types.FunctionType(func_code, globals())

print(discount_func(200)) # 160.0
```

### 三、 进阶：闭包 (Closure) 的处理

这是 `FunctionType` 最难的部分。如果你的代码引用了外部作用域的变量（Non-local），你需要手动构建 `cell` 对象。

这也是为什么 `pickle` 很难序列化带有闭包的函数的原因，因为重建闭包状态非常复杂。

```python
import types

def maker(n):
    def inner(x):
        return x + n  # 引用了外部的 n
    return inner

# 获取一个闭包函数作为参考
ref_func = maker(10)
print(ref_func(5)) # 15

# 获取它的闭包单元 (cell)
cells = ref_func.__closure__ 

# 假设我们有一个没有闭包的普通代码对象（通常很难手动拿到闭包代码而不带闭包，这里仅作演示概念）
# 在实际黑魔法中，这里通常用于替换现有闭包的值

# 我们可以创建一个新函数，强行复用这个闭包
new_func = types.FunctionType(
    ref_func.__code__,
    globals(),
    "hacked_closure",
    None,
    cells # 把 n=10 的环境塞进去
)

print(new_func(20)) # 30
```

### 四、 装饰器

```python
import types

def make_cell(value):
    return (lambda: value).__closure__[0]


def aop_log_time(func):
    def wrapper(*args, **kwargs):
        import time

        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(
            f"Function '{func.__name__}' executed in {end_time - start_time:.4f} seconds"
        )
        return result

    func_cell = make_cell(func)
    closure = (func_cell,)
    aop_func = types.FunctionType(
        wrapper.__code__,  # 切面逻辑的字节码
        func.__globals__,  # 复用原函数的全局作用域
        func.__name__,  # 保留原函数名
        func.__defaults__,  # 保留原函数默认参数
        closure,  # 保留原函数闭包（如果有）
    )

    aop_func.__doc__ = func.__doc__
    aop_func.__annotations__ = func.__annotations__
    return aop_func



@aop_log_time
def add(x, y):  
    """Adds two numbers and returns the result."""      
    return x + y


result = add(5, 7)
print(f"Result of add: {result}")
print(add.__doc__)

```

```python
import types


def add(x, y=10):
    return x + y


def copy_function(func):
    # Create a new function with the same code, globals, defaults, and closure
    new_func = types.FunctionType(
        func.__code__,
        func.__globals__,
        name=func.__name__,
        argdefs=func.__defaults__,
        closure=func.__closure__,
    )
    new_func.__doc__ = func.__doc__  # Copy docstring
    new_func.__dict__.update(func.__dict__)  # Copy function attributes
    return new_func


new_add = copy_function(add)
new_add.__defaults__ = (20,)  # 修改默认参数
result = new_add(3)
print(result)

```

```python
import types

def create_calc_func(operator):
    if operator == "add":

        def add(a, b):
            return a + b

        template = add

    elif operator == "subtract":

        def sub(a, b):
            return a - b

        template = sub

    elif operator == "multiply":

        def multiply(a, b):
            return a * b

        template = multiply

    elif operator == "divide":

        def divide(a, b):
            if b == 0:
                raise ValueError("Cannot divide by zero")
            return a / b

        template = divide

    func = types.FunctionType(
        template.__code__,
        globals(),
        name="calc",
        argdefs=template.__defaults__,
        closure=template.__closure__,
    )
    return func


def create_calc_func2(operator):
    template = None
    if operator == "add":
        template = lambda a, b: a + b
    elif operator == "subtract":
        template = lambda a, b: a - b
    elif operator == "multiply":
        template = lambda a, b: a * b
    elif operator == "divide":
        template = lambda a, b: (
            a / b
            if b != 0
            else (_ for _ in ()).throw(ValueError("Cannot divide by zero"))
        )
    fun = types.FunctionType(
        template.__code__,
        globals(),
        name="calc",
        argdefs=template.__defaults__,
        closure=template.__closure__,
    )
    return fun


print(create_calc_func("add")(10, 5))  # 输出: 15
print(create_calc_func("divide")(10, 2))  # 输出: 5.0
# create_calc_func2("divide")(10, 0)  # 抛出 Value    Error: Cannot divide by zero
print(create_calc_func("multiply")(10, 5))  # 输出: 50
print(create_calc_func("subtract")(10, 5))  # 输出: 5


# calc_add = create_calc_func2("add")
# print(calc_add(10, 5))  # 输出: 15
# calc_divide = create_calc_func2("divide")
# print(calc_divide(10, 2))  # 输出: 5.0
# create_calc_func2("divide")(10, 0)  # 抛出 ValueError: Cannot divide by zero
# create_calc_func2("multiply")(10, 5)  # 输出: 50
# print(create_calc_func2("multiply")(10, 5))  # 输出: 50
# calc_subtract = create_calc_func2("subtract")
# print(calc_subtract(10, 5))  # 输出: 5

```



### 总结

`types.FunctionType` 是 Python 对象模型的**基石**之一。

*   **平时开发**：你不需要碰它，`def` 关键字和 `lambda` 会自动帮你调用它。
*   **架构开发**：当你需要做 **AOP（面向切面编程）**、**热加载**、**沙箱隔离**、或者**RPC 框架（远程函数调用还原）**时，它是唯一能让你把“逻辑（Code）”和“数据（Globals/Closure）”手动缝合起来的工具。
*   
<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-function-type)