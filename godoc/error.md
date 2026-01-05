<div id="chap-error"></div>

[⬆️ 返回目录](#catalog)


## error

在 Go 语言中，`defer` 调用的函数如果有返回值，这些返回值默认是会被**丢弃（忽略）**的。

如果 `client.Close()` 返回的 error 很重要（例如文件写入、数据库事务提交），你需要显式地处理它。通常有以下 **3 种** 常见的处理方式，根据你的业务严格程度来选择：

### 方法 1：使用匿名函数记录日志（最常用）

如果你不希望 `Close` 的错误影响主业务逻辑的返回值，但又想知道有没有出错，可以将其包装在一个匿名函数中进行日志记录。

**适用场景：** 网络读取操作、非强数据一致性场景。

```go
if client != nil {
    defer func() {
        if err := client.Close(); err != nil {
            // 记录日志，但不中断程序，也不返回错误给调用者
            log.Printf("failed to close client: %v", err)
        }
    }()
}
```

---

### 方法 2：使用“具名返回值”将错误返回（最严谨）

如果你正在进行**写操作**（如写入文件、数据库事务），`Close` 失败意味着数据可能没有持久化成功，这时**必须**把错误返回给调用方。

这需要使用 Go 的 **具名返回值 (Named Return Values)**。

**适用场景：** 文件写入、数据库事务、关键业务。

```go
// 注意：返回值必须命名为 err
func DoSomething() (err error) {
    client := NewClient()
    
    if client != nil {
        defer func() {
            closeErr := client.Close()
            // 处理逻辑：
            // 1. 如果业务逻辑本来就出错了 (err != nil)，通常保留业务错误，记录 Close 错误。
            // 2. 如果业务逻辑成功 (err == nil)，但 Close 失败了，则应该返回 Close 的错误。
            if err == nil {
                err = closeErr
            } else if closeErr != nil {
                // 这里的处理看个人喜好，可以用 log，也可以用 Go 1.20+ 的 errors.Join 合并两个错误
                log.Printf("error closing client: %v", closeErr)
            }
        }()
    }

    // 模拟业务逻辑
    // return errors.New("business error") 
    return nil
}
```

**Go 1.20+ 进阶写法 (合并错误):**
使用 `errors.Join` 可以同时保留业务错误和 Close 错误。

```go
func DoSomething() (err error) {
    // ... 初始化 ...
    defer func() {
        err = errors.Join(err, client.Close())
    }()
    
    // ... 业务代码 ...
    return nil
}
```

---

### 方法 3：直接忽略（不推荐，除非你很确定）

在很多简单的只读场景下（例如读取一个配置文件的 `os.Open`），开发者经常直接忽略 Close 的错误，因为读取时的 Close 错误通常不影响已经读到的数据。

```go
if client != nil {
    defer client.Close() // 这里的 error 被静默丢弃了
}
```
**警告：** 许多代码静态检查工具（如 `golangci-lint` 中的 `errcheck`）会对此报错。如果你确实想忽略，建议显式地赋值给 `_` 以表明意图（虽然 defer 不支持直接赋值，还是得用匿名函数）：

```go
defer func() { _ = client.Close() }()
```

---

### 总结建议

1.  **读操作/非关键资源**：使用 **方法 1**（打印日志），防止资源泄漏的错误被掩盖。
2.  **写操作/关键资源**：必须使用 **方法 2**（具名返回值），确保数据完整性。
3.  **永远不要**以为 `defer client.Close()` 是绝对安全的，一旦发生磁盘满或网络断开，`Close` 里的错误可能是你唯一的线索。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-error)