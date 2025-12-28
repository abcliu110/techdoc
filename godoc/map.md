<div id="chap-map"></div>

[⬆️ 返回目录](#catalog)


## map

这是一个非常棒的疑惑！这句话里包含了两层逻辑，如果不拆开看，确实容易晕。

让我们把这两个概念拆解开来：
1.  **为什么用 Map 可以模拟 Set？**
2.  **为什么 `struct{}` 不占内存，而且能节省空间？**

---

### 1. 为什么用 Map 可以模拟 Set？

首先，什么是 **Set（集合）**？
Set 的核心特性是：**元素唯一**（不能重复），且通常我们只关心“某个元素**在不在**集合里”，而不关心它对应的值是什么。

Go 语言里没有 `set` 这个关键字，但 Go 有 `map`。
`map` 的结构是 `key-value`（键值对）。
*   **Key（键）**：必须是唯一的。
*   **Value（值）**：可以是任意东西。

如果我们把 `map` 的 **Key** 当作 Set 的元素，那 `map` 天然就拥有了“元素唯一”的特性。

*   **常规 Map**：`map[string]int` -> 存 "Tom": 18岁。我们关心 Key 也关心 Value。
*   **Set 变体**：`map[string]???` -> 存 "Tom"。我们**只关心 Key 存在不存在**，完全不在乎 Value 是什么。

那么问题来了，这个 `Value` 选什么类型最划算？

---

### 2. 为什么选 `struct{}` 而不是 `bool`？

通常新手会这样定义 Set：
```go
// 方案 A：使用 bool 作为 value
mySet := make(map[string]bool)
mySet["apple"] = true
```
这完全没问题，也很好理解。但是从**极致优化**的角度看，它浪费了内存。

#### 核心对比：`bool` vs `struct{}`

1.  **bool 类型**：
    *   虽然 bool 只有 `true` 和 `false` 两种状态，但在计算机内存中，它**至少占用 1 个字节（1 byte）**。
    *   如果你存 100 万个元素，光是这些 value 就要占用 **1MB** 的内存。

2.  **struct{} 类型**（空结构体）：
    *   Go 语言对空结构体做了特殊优化。**它的宽度（Width）是 0 字节。**
    *   无论你存多少个空结构体，它们**完全不占任何额外的内存空间**。

我们可以用代码验证一下：

```go
package main

import (
    "fmt"
    "unsafe"
)

func main() {
    var b bool
    var s struct{}

    fmt.Println(unsafe.Sizeof(b)) // 输出: 1 (byte)
    fmt.Println(unsafe.Sizeof(s)) // 输出: 0 (byte)
}
```

#### 底层原理图解

当 Go 的 `map` 在内存中分配空间（Bucket）来存储数据时，它是成块存储的。

*   **Map with bool (`map[string]bool`) 的内存布局：**
    ```text
    [ Key1 ][ Value1(1byte) ]  [ Key2 ][ Value2(1byte) ] ...
    ```
    这里每个 Key 后面都必须留 1 个字节的位置给 bool 值，哪怕你根本不看它。

*   **Map with struct{} (`map[string]struct{}`) 的内存布局：**
    ```text
    [ Key1 ][ (0byte) ]  [ Key2 ][ (0byte) ] ...
    ```
    实际上变成了：
    ```text
    [ Key1 ] [ Key2 ] ...
    ```
    Go 编译器看到 value 的大小是 0，它在计算内存偏移量时，直接就会忽略 value 的位置。**它只存 Key，完全不给 Value 分配空间。**

这就是为什么说它是“完美的 Set”：它实现了 Set 的功能，且没有因为借用 Map 而产生多余的 Value 内存开销。

---

### 3. 如何读写这种代码？

很多同学看不懂，是因为语法看起来有点怪。

#### 定义与赋值
```go
// 1. 定义一个 Set
set := make(map[string]struct{})

// 2. 添加元素 (Add)
// struct{}{} 的意思是：
// 第一个 struct{} 表示类型
// 第二个 {} 表示实例化一个对象
set["apple"] = struct{}{} 
set["banana"] = struct{}{}

// 3. 判断元素是否存在 (Contains)
// map 返回两个值：value, exists
// 我们不需要 value，用下划线 _ 丢弃
// 只看 exists (bool 类型)
if _, exists := set["apple"]; exists {
    fmt.Println("苹果在集合里！")
}
```

### 总结

*   **Map 的 Key 是唯一的** -> 所以可以用 Key 来代表 Set 的元素。
*   **Map 必须有 Value** -> 我们需要填充一个 Value 占位。
*   **`bool` 占 1 字节** -> 浪费空间。
*   **`struct{}` 占 0 字节** -> 完美。

所以，`map[string]struct{}` 的意思是：**一个利用 Map 的 Key 唯一性特性，同时利用空结构体零内存特性，组合出来的、最高效的 Set 实现。**

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-map)