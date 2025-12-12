<div id="chap-lambda"></div>

[⬆️ 返回目录](#catalog)


## lambda表达式

我们一步步来拆解：

### 1. 可以直接使用 Lambda 表达式作为函数吗？
**是的，完全可以。**
在 Python 中，`lambda` 表达式本质上就是创建了一个**函数对象**。除了没有默认名字（`__name__` 是 `<lambda>`）之外，它和使用 `def` 定义的函数在底层几乎是一样的。

你可以通过以下几种方式直接使用它：

*   **立即调用（IIFE）：**
    ```python
    # 定义后立刻加括号调用
    result = (lambda x: x * 2)(5)
    print(result)  # 输出 10
    ```
*   **赋值给变量（像普通函数一样用）：**
    ```python
    add = lambda x, y: x + y
    print(add(3, 4))  # 输出 7
    ```
*   **作为参数传递（最常见用法）：**
    ```python
    nums = [1, 2, 3]
    mapped = map(lambda x: x ** 2, nums)
    ```

---

### 2. 可以直接访问 `__code__` 吗？
**是的，可以直接访问。**
Python 的函数（包括 `lambda` 函数）都有一个名为 `__code__` 的属性。这个属性是一个 **Code Object（代码对象）**，它包含了函数编译后的**字节码**、变量名、常量表等底层信息。

```python
func = lambda x, y: x + y

# 直接访问 __code__
code_obj = func.__code__

print(code_obj) 
# 输出类似: <code object <lambda> at 0x..., file "...", line ...>

# 查看具体的属性
print(code_obj.co_argcount)  # 参数个数: 2
print(code_obj.co_varnames)  # 变量名: ('x', 'y')
print(code_obj.co_code)      # 原始字节码（二进制串）
```

---

### 3. 那么 Python 对象可以使用 `__code__` 吗？

这里需要厘清概念：**并不是所有的 Python 对象都有 `__code__` 属性。**

只有 **“函数对象”**（Function Objects）和 **“代码对象”**（Code Objects）本身，以及部分通过描述符暴露该属性的对象才有 `__code__`。

#### 哪些对象有 `__code__`？
1.  **普通函数 (`def`)**: 有。
2.  **Lambda 函数**: 有。
3.  **方法 (Method)**: 方法本质上是绑定了实例的函数。你可以通过 `my_obj.my_method.__code__` 访问。

#### 哪些对象**没有** `__code__`？
1.  **普通实例对象**: 比如 `a = 1` (int), `s = "hello"` (str), 或者自定义类 `class A: pass; obj = A()`。它们没有 `__code__`。
2.  **生成器对象 (Generator)**: 它们使用 `gi_code`。
3.  **栈帧对象 (Frame)**: 它们使用 `f_code`。

#### 示例验证

```python
def my_func():
    pass

class MyClass:
    def method(self):
        pass

obj = MyClass()
a = 100

# 1. 函数：有
print(hasattr(my_func, '__code__'))  # True

# 2. Lambda：有
print(hasattr(lambda: 1, '__code__')) # True

# 3. 类实例的方法：有
print(hasattr(obj.method, '__code__')) # True

# 4. 普通对象（整数）：没有
print(hasattr(a, '__code__'))        # False
# print(a.__code__)  # 这会报错: AttributeError: 'int' object has no attribute '__code__'

# 5. 自定义类的实例：通常没有（除非你故意定义了这个属性）
print(hasattr(obj, '__code__'))      # False
```

### 进阶玩法：`__code__` 是可写的！

最“黑魔法”的地方在于，你不仅可以访问 `__code__`，你甚至可以将一个函数的 `__code__` 替换成另一个函数的，从而**偷梁换柱**改变函数的行为。

```python
def add(a, b):
    return a + b

def sub(a, b):
    return a - b

# 正常调用
print(add(5, 3))  # 8

# 黑魔法：把 sub 的代码给 add
add.__code__ = sub.__code__

# 再次调用 add，名字还是 add，但行为变成了减法
print(add(5, 3))  # 2
```

### 总结
1.  **Lambda** 就是函数，完全可以像函数一样使用。
2.  函数（含 Lambda）可以直接访问并读取 **`__code__`** 来获取编译后的元数据。
3.  **普通 Python 对象**（如 int, str, 自定义类的实例）默认**没有** `__code__` 属性，这个属性专属于可执行的函数/方法对象。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-lambda)