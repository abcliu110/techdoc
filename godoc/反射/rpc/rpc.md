<div id="chap-rpc"></div>

[⬆️ 返回目录](#catalog)


## rpc
为了让你彻底理解 `net/rpc` 的内部运作机制，我写了一个**极简版**的模拟实现。

这个代码去掉了所有的错误处理边缘情况、HTTP 支持、JSON 支持等杂项，**只保留了最核心的三个技术点**：
1.  **Gob 序列化**：如何传输数据。
2.  **Reflect 反射**：服务端如何动态调用函数。
3.  **Map + Channel**：客户端如何实现异步转同步。

你可以将以下代码保存为 `main.go` 直接运行。

### 完整模拟代码

```go
package main

import (
	"encoding/gob"
	"fmt"
	"io"
	"log"
	"net"
	"reflect"
	"strings"
	"sync"
	"time"
)

// ======================================================================
// 1. 协议定义 (Protocol)
// ======================================================================
// 传输数据的基本单位：Header + Body

type RequestHeader struct {
	ServiceMethod string // 格式 "Service.Method"
	Seq           uint64 // 序列号，用于匹配响应
}

type ResponseHeader struct {
	Seq   uint64 // 原样返回请求的序列号
	Error string // 错误信息，为空则成功
}

// ======================================================================
// 2. 服务端实现 (Server) - 核心技术：反射 (Reflection)
// ======================================================================

type Server struct {
	addr  string
	// services 存储注册的服务实例
	// Key: 服务名 (如 "Calculator"), Value: 实例的反射值
	services map[string]reflect.Value
}

func NewServer(addr string) *Server {
	return &Server{
		addr:     addr,
		services: make(map[string]reflect.Value),
	}
}

// Register 注册服务
// 原理：保存结构体实例的反射 Value，以便后续通过 MethodByName 查找方法
func (s *Server) Register(rcvr interface{}) {
	val := reflect.ValueOf(rcvr)
	name := reflect.Indirect(val).Type().Name() // 获取结构体名称，如 "Calculator"
	s.services[name] = val
	log.Printf("[Server] Registered service: %s", name)
}

func (s *Server) Run() {
	ln, _ := net.Listen("tcp", s.addr)
	log.Printf("[Server] Listening on %s...", s.addr)
	for {
		conn, _ := ln.Accept()
		go s.handleConn(conn)
	}
}

// handleConn 处理单个连接
func (s *Server) handleConn(conn net.Conn) {
	defer conn.Close()
	dec := gob.NewDecoder(conn)
	enc := gob.NewEncoder(conn)

	for {
		// --- 步骤 A: 读取 Header ---
		var reqH RequestHeader
		if err := dec.Decode(&reqH); err != nil {
			if err != io.EOF { log.Println("Decode error:", err) }
			return
		}

		// --- 步骤 B: 查找方法 (Reflection) ---
		// 格式: "Calculator.Add"
		dots := strings.Split(reqH.ServiceMethod, ".")
		serviceName, methodName := dots[0], dots[1]

		// 1. 找到服务实例
		svcVal, ok := s.services[serviceName]
		if !ok { log.Println("Service not found"); return }

		// 2. 找到具体方法 (核心反射逻辑)
		method := svcVal.MethodByName(methodName)
		if !method.IsValid() { log.Println("Method not found"); return }

		// --- 步骤 C: 准备参数 (Reflection) ---
		// 获取方法的参数类型: func (recv, arg, reply)
		// method.Type().In(0) 是第一个参数 (Args)
		// method.Type().In(1) 是第二个参数 (Reply 指针)
		argType := method.Type().In(0)
		replyType := method.Type().In(1)

		// 创建新的实例来接收数据
		argVal := reflect.New(argType.Elem())   // Args
		replyVal := reflect.New(replyType.Elem()) // Reply

		// --- 步骤 D: 读取 Body ---
		// 将网络中的二进制数据解码到 argVal 中
		if err := dec.Decode(argVal.Interface()); err != nil {
			log.Println("Decode body error:", err)
			return
		}

		// --- 步骤 E: 函数调用 (Reflection Call) ---
		// 相当于调用: rcvr.Add(arg, reply)
		returnValues := method.Call([]reflect.Value{argVal, replyVal})

		// 处理返回的 error
		errStr := ""
		if errInter := returnValues[0].Interface(); errInter != nil {
			errStr = errInter.(error).Error()
		}

		// --- 步骤 F: 发送响应 ---
		respH := ResponseHeader{Seq: reqH.Seq, Error: errStr}
		enc.Encode(respH)              // 写 Header
		enc.Encode(replyVal.Interface()) // 写 Body (Reply)
	}
}

// ======================================================================
// 3. 客户端实现 (Client) - 核心技术：Map + Channel
// ======================================================================

type Call struct {
	Seq   uint64
	Reply interface{} // 用于接收结果的指针
	Done  chan *Call  // 完成通知
	Error error
}

type Client struct {
	conn    net.Conn
	enc     *gob.Encoder
	dec     *gob.Decoder
	seq     uint64
	// pending 存储所有发出去但还没回来的请求
	pending map[uint64]*Call
	mu      sync.Mutex
}

func NewClient(addr string) *Client {
	conn, _ := net.Dial("tcp", addr)
	client := &Client{
		conn:    conn,
		enc:     gob.NewEncoder(conn),
		dec:     gob.NewDecoder(conn),
		pending: make(map[uint64]*Call),
	}
	// 启动后台接收循环 (核心逻辑)
	go client.input()
	return client
}

// Call 用户调用的入口
func (c *Client) Call(serviceMethod string, args interface{}, reply interface{}) error {
	// 1. 封装 Call 对象
	call := &Call{
		Reply: reply,
		Done:  make(chan *Call, 1),
	}

	// 2. 注册到 pending map (加锁)
	c.mu.Lock()
	c.seq++
	call.Seq = c.seq
	c.pending[call.Seq] = call
	c.mu.Unlock()

	// 3. 发送请求 (编码)
	// 这里简化处理，未加锁 encode，实际 net/rpc 会加锁
	h := RequestHeader{ServiceMethod: serviceMethod, Seq: call.Seq}
	if err := c.enc.Encode(h); err != nil { return err }
	if err := c.enc.Encode(args); err != nil { return err }

	// 4. 阻塞等待 (同步点)
	// 直到 input 协程收到结果并向 channel 发送信号
	<-call.Done
	return call.Error
}

// input 后台接收循环
func (c *Client) input() {
	for {
		// A. 读取响应头
		var h ResponseHeader
		if err := c.dec.Decode(&h); err != nil { return }

		// B. 查找对应的 Call
		c.mu.Lock()
		call, ok := c.pending[h.Seq]
		delete(c.pending, h.Seq) // 移除
		c.mu.Unlock()

		if !ok {
			// 可能是请求被取消了，读取 Body 并丢弃
			// (这里简化处理，直接 panic 或者 return)
			log.Println("Call not found for seq", h.Seq)
			return
		}

		// C. 读取 Body (填充到 call.Reply 中)
		if h.Error != "" {
			call.Error = fmt.Errorf(h.Error)
			// 如果出错，也要读出 body 丢弃，保证流的顺序，这里简化略过
			var dummy interface{}
			c.dec.Decode(&dummy)
		} else {
			// 真正的数据填充发生在这里
			err := c.dec.Decode(call.Reply)
			if err != nil { call.Error = err }
		}

		// D. 通知主线程 (唤醒 Call 方法)
		call.Done <- call
	}
}

// ======================================================================
// 4. 测试用例 (Main)
// ======================================================================

// 定义业务对象
type Calculator struct{}
type Args struct{ A, B int }
type Reply struct{ Value int }

// 符合 RPC 规范的方法: (args, reply) error
func (c *Calculator) Add(args *Args, reply *Reply) error {
	reply.Value = args.A + args.B
	return nil
}

func main() {
	// 1. 启动服务端
	go func() {
		server := NewServer(":9988")
		server.Register(new(Calculator)) // 注册服务
		server.Run()
	}()

	time.Sleep(1 * time.Second) // 等待服务端启动

	// 2. 启动客户端
	client := NewClient(":9988")

	// 3. 发起调用
	args := &Args{A: 10, B: 20}
	reply := &Reply{}

	fmt.Println("[Client] Calling Calculator.Add(10, 20)...")
	
	// 这一步在内部经历了: Encode -> Net -> Decode -> Reflect -> Encode -> Net -> Decode -> Channel
	err := client.Call("Calculator.Add", args, reply)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("[Client] Result: %d\n", reply.Value)
}
```

### 代码原理深度解析

#### 1. 反射部分 (Server 端)
在 `handleConn` 中，最神奇的代码是这一段：

```go
// 1. 拿方法
method := svcVal.MethodByName("Add")

// 2. 拿类型
argType := method.Type().In(0) // 知道第一个参数是 *Args 类型

// 3. 造对象
argVal := reflect.New(argType.Elem()) // 相当于 new(Args)

// 4. 填数据
dec.Decode(argVal.Interface()) // 把网络字节流填进这个新对象

// 5. 调函数
method.Call(...) 
```
**原理**：服务端在编译的时候，根本不知道客户端会传 `Args` 还是 `UserReq`。只有在运行的时候，通过反射分析注册的方法，才能动态创建出正确的结构体来接收 Gob 数据流。

#### 2. 异步转同步 (Client 端)
Go 的 RPC 客户端是线程安全的，支持并发调用。这靠的是 **Seq + Map + Channel**。

*   **发送时**：
    1.  生成一个唯一的单号 `Seq = 1`。
    2.  创建一个单子 `Call`，里面有个 `Done` 通道。
    3.  把单子贴在墙上 `pending[1] = call`。
    4.  发货，然后坐在 `Done` 通道前死等。

*   **接收时 (`input` 协程)**：
    1.  收到回信，看信封上的单号 `Seq = 1`。
    2.  去墙上撕下 `pending[1]` 的单子。
    3.  把回信里的内容（Body）填到单子的 `Reply` 里。
    4.  敲一下 `Done` 通道，告诉发送者“货到了”。

#### 3. 序列化 (Gob)
代码中使用了 `encoding/gob`。
*   `Encoder.Encode(h)`：不需要我们手动去拼字节（比如前4个字节是长度，后4个字节是ID）。
*   Gob 会自动处理结构体的字段边界。
*   这就解决了 TCP 的粘包问题（Gob 内部有自己的长度界定机制）。

这个模拟代码虽然只有 100 多行，但它完整复刻了 Go 标准库 `net/rpc` 的核心灵魂。

这是一个非常经典的并发编程死锁隐患！你的担心完全正确。

如果直接像你那样写，一旦 `c.enc.Encode` 报错并 `return`，**锁永远不会被释放**。下一次有其他协程想调用 `Call` 时，就会卡死在 `Lock()` 处。

为了既能享受 `defer` 的安全性，又不扩大锁的粒度（避免锁住 `<-call.Done`），我们通常有 **3 种标准的写法**。

---

### 写法 1：使用匿名函数（推荐，最优雅）

利用 **匿名函数（闭包）** 的作用域特性。我们将“加锁-发送-解锁”这一套逻辑封装在一个小函数里，在这个小函数内部放心使用 `defer`。

```go
func (c *Client) Call(...) error {
    // ... 注册 seq 等逻辑 ...

    // 【核心技巧】：定义一个立即执行的匿名函数
    // 这样 defer 只会作用于这个小函数的作用域，函数一结束，锁立刻解开
    err := func() error {
        c.sendMutex.Lock()
        defer c.sendMutex.Unlock() // 放心用 defer，只会锁这一小段

        if err := c.enc.Encode(h); err != nil {
            return err
        }
        if err := c.enc.Encode(args); err != nil {
            return err
        }
        return nil
    }()

    // 如果发送出错，直接返回，此时锁已经解开了
    if err != nil {
        c.removeCall(seq) // 记得清理 pending map
        return err
    }

    // ... 等待结果 (无锁状态) ...
    <-call.Done
    return call.Error
}
```
*   **优点**：代码结构最清晰，`defer` 保证了无论如何锁都会释放，且不会锁住后面的等待操作。
*   **缺点**：多了一次函数调用的开销（在网络 IO 面前几乎可以忽略不计）。

---

### 写法 2：抽取独立方法（最规范）

这本质上和写法 1 一样，只是把匿名函数提取成了结构体的私有方法。这也是**面向对象设计**中推荐的做法：单一职责。

```go
func (c *Client) Call(...) error {
    // ...
    
    // 调用封装好的发送方法
    if err := c.sendRequest(h, args); err != nil {
        c.removeCall(seq)
        return err
    }
    
    // ... 等待结果 ...
    <-call.Done
    return call.Error
}

// 独立的发送方法
func (c *Client) sendRequest(h Header, args interface{}) error {
    c.sendMutex.Lock()
    defer c.sendMutex.Unlock() // 这里的 defer 也是安全的，函数结束就解锁

    if err := c.enc.Encode(h); err != nil {
        return err
    }
    return c.enc.Encode(args)
}
```

---

### 写法 3：手动解锁（Go 标准库的做法，追求极致性能）

Go 标准库为了避免函数调用的微小开销（以及让代码看起来平铺直叙），经常选择**“笨办法”**：在每一个 `return` 之前手动写 `Unlock()`。

这种写法虽然繁琐，但性能最高。

```go
func (c *Client) Call(...) error {
    // ...
    
    c.sendMutex.Lock()
    
    if err := c.enc.Encode(h); err != nil {
        // 【痛点】必须记得手动解锁，否则死锁
        c.sendMutex.Unlock() 
        c.removeCall(seq)
        return err
    }
    
    if err := c.enc.Encode(args); err != nil {
        // 【痛点】每个错误分支都要写一遍
        c.sendMutex.Unlock()
        c.removeCall(seq)
        return err
    }
    
    c.sendMutex.Unlock() // 正常流程解锁

    // ... 等待结果 ...
    <-call.Done
    return call.Error
}
```

### 总结

1.  **你指出的代码确实有 Bug**：中间 `return` 会导致死锁。
2.  **最佳实践**：
    *   如果你在写业务代码或简单的框架：**请使用“写法 1 (匿名函数)”**，它最不容易出错，可读性最好。
    *   如果你在写像 Go 标准库那样底层的库，且对纳秒级性能有要求：使用“写法 3 (手动解锁)”。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-rpc)