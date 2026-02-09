<div id="chap-ufw"></div>

[⬆️ 返回目录](#catalog)


## ufw

作为一个资深的程序员和网络管理员，你可能已经发现 Linux 下的工具链有一个共同的设计模式：**“前端抽象层 + 后端执行引擎”**。

`ufw` 也是这个模式的典型代表。

---

### 1. 为什么叫 `ufw`？

`ufw` 的全称是 **Uncomplicated Firewall**（不复杂的防火墙）。

*   **诞生的背景：** 在 `ufw` 出现之前，Linux 管理员直接操作的是 `iptables`。`iptables` 虽然强大，但语法极其晦涩、冗长且容易出错。比如允许 80 端口，`iptables` 可能要写一大串参数，还要考虑 INPUT 链和状态跟踪。
*   **设计初衷：** Ubuntu 开发 `ufw` 就是为了给管理员提供一个**“符合人类语言直觉”**的界面。它把复杂的防火墙逻辑简化成了 `allow`（允许）、`deny`（拒绝）、`limit`（限速）等几个简单的单词。

---

### 2. `ufw` 的技术原理

你要理解 `ufw`，不能把它看作一个独立的防火墙，它其实是一个**配置生成器和管理脚本**。

#### A. 核心层：Netfilter（内核空间）
Linux 真正的防火墙功能是由内核中的 **Netfilter** 模块实现的。Netfilter 挂载在内核的网络协议栈中，负责对经过的每一个数据包进行检查、修改、丢弃或转发。

#### B. 中间层：iptables / nftables（用户空间工具）
为了与内核的 Netfilter 通信，系统需要工具：
*   老牌工具是 `iptables`。
*   现代工具是 `nftables`。
它们负责把规则写入内核的表中。

#### C. 顶层：ufw（前端抽象）
`ufw` 就跑在 `iptables` 之上。当你输入 `sudo ufw allow 443` 时，发生了以下过程：
1.  **解析指令：** `ufw` 解析你的命令。
2.  **生成规则：** 它会查询自己的配置文件（通常在 `/etc/ufw/` 下的 `.rules` 文件）。
3.  **调用后端：** 它会把这个简单的 `allow 443` 转换成多条复杂的 `iptables` 指令，并调用 `iptables-restore` 将规则批量刷入内核。

**本质上：** `ufw` 是 `iptables` 的 **Python 包装器**。

---

### 3. `ufw` 的关键特性原理

*   **状态检测（Stateful Inspection）：**
    `ufw` 默认开启状态跟踪。这意味着如果你允许了“出去”的请求，内核会自动记住这个连接，并允许对应的“回来”的包通过，而不需要你额外配置。
*   **应用配置（Application Profiles）：**
    你可能见过 `sudo ufw allow 'Nginx Full'`。`ufw` 会去 `/etc/ufw/applications.d/` 目录下找对应的配置文件，里面记录了 Nginx 需要开启哪些端口。这是一种**解耦**的思想：管理员只需要记住服务的名字，不需要死记硬背端口号。
*   **默认策略：**
    `ufw` 的核心安全逻辑通常是：**“默认拒绝所有入站，默认允许所有出站”**（Default Deny Incoming, Default Allow Outgoing）。这符合“最小权限原则”。

---

### 4. 资深网管的纠错与避坑

#### (1) 关于 `sudo ufw stop`
**纠正：** 实际上 `ufw` 命令里没有 `stop` 这个子命令。
*   如果你想临时关闭防火墙，应该使用 `sudo ufw disable`。
*   `disable` 会卸载已加载的规则，并停止 `ufw` 服务，但它不会删除你已经定义的规则。当你 `enable` 时，旧规则会全部回来。

#### (2) `ufw` 与 Docker 的“背刺”
这是资深网管最容易栽跟头的地方：**Docker 会绕过 ufw！**
*   **原理：** Docker 在启动容器时，直接操作 `iptables` 并在 `FORWARD` 链中插入规则。由于 Docker 插入规则的优先级往往高于 `ufw` 生成的规则，即使你在 `ufw` 里禁用了某个端口，如果 Docker 映射了该端口，外网依然能访问。
*   **教训：** 在有 Docker 的环境下，不能完全信任 `ufw status` 的结果。

#### (3) 规则存储位置
如果你想看 `ufw` 真正生成的“大餐”，可以去看看：
*   `/lib/ufw/user.rules`：这里存的是你通过命令手动添加的规则。
*   `/etc/ufw/before.rules`：在处理你的自定义规则之前，系统先执行的规则（比如允许 loopback）。

### 总结
`ufw` 的原理和我们之前聊的 `Netplan` 异曲同工：
*   **Netplan** 是网络接口配置的“翻译官”。
*   **ufw** 是防火墙规则的“翻译官”。

它们的存在都是为了把**复杂的底层技术（Netfilter/iptables）**包装成**易维护的声明式配置**。作为网管，用 `ufw` 提高效率没问题，但当遇到 Docker 或复杂路由问题时，还是要拿起 `sudo iptables -L -n -v` 这个“放大镜”去内核里看个究竟。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-ufw)