<div id="chap-netplan"></div>

[⬆️ 返回目录](#catalog)


## netplan

作为一个资深的程序员和网络管理员，理解 Netplan 不仅仅要会写 YAML，更要理解它在 Linux 网络协议栈中所处的**位置**和**工作流**。

简单来说，Netplan 并不是一个真正的“网络管理器”，它是一个**配置抽象层（Abstraction Layer）**。

以下是 Netplan 的核心技术原理深度拆解：

---

### 1. 核心架构：前端 + 后端（Frontend & Renderers）

Netplan 的设计哲学是：**“一套配置，多处运行”**。

*   **前端（Frontend）：** 用户编写的 YAML 文件（位于 `/etc/netplan/*.yaml`）。
*   **后端（Renderers，也叫渲染器）：** 真正的网络管理执行者。
    *   **`systemd-networkd`**：通常用于服务器，轻量级、高性能。
    *   **`NetworkManager`**：通常用于桌面版，支持复杂的 Wi-Fi、热点、VPN 等。

**原理：** Netplan 本身不负责拨号、不负责分发 IP，它只负责把你的 YAML “翻译”成这些后端能听懂的格式。

---

### 2. 工作流：从 YAML 到内核（Step-by-Step）

当你执行 `sudo netplan apply` 时，底层发生了以下链式反应：

#### 第一步：读取与合并（Load & Merge）
Netplan 会扫描 `/etc/netplan/`、`/lib/netplan/` 和 `/run/netplan/` 下所有的 `.yaml` 文件。它按**文件名字母顺序**读取。
*   *这就是为什么之前说 `99-xxx.yaml` 会覆盖 `50-xxx.yaml` 的原因。*

#### 第二步：生成（Generate）
Netplan 运行 `netplan generate` 命令。这一步最关键：
*   如果你的 `renderer` 是 `networkd`，Netplan 会在 **`/run/systemd/network/`** 目录下生成一堆 `.network` 文件。
*   如果你的 `renderer` 是 `NetworkManager`，它会在 **`/run/NetworkManager/conf.d/`** 生成配置文件。

**核心知识点：** 这些生成的文件存放在 `/run` 目录中。在 Linux 中，`/run` 是存储在内存中的（tmpfs），**重启即消失**。这就是为什么每次启动时，系统必须重新跑一遍生成逻辑（这也解释了为什么 `cloud-init` 能在启动时篡改配置）。

#### 第三步：应用（Apply）
Netplan 调用后端的 API（比如 `busctl` 或 `systemctl`），通知 `systemd-networkd` 或 `NetworkManager` 重新加载 `/run` 目录下的新配置。
*   后端服务（如 `systemd-networkd`）接收到指令后，才会真正通过 **Netlink（Linux 内核接口）** 向内核申请 IP、配置路由表、设置 DNS。

---

### 3. 为什么 Netplan 要搞这么复杂？

作为老牌网管，你肯定记得以前的 `/etc/network/interfaces` (ifupdown)。对比之下，Netplan 的优势在于：

1.  **容错性（Netplan Try）：**
    Netplan 引入了 `netplan try` 命令。它会先应用配置，如果你在 120 秒内没有确认，它会自动回滚。这简直是**远程维护服务器网管的救命稻草**，防止把自己关在服务器外面。
2.  **声明式配置：**
    YAML 这种声明式语言能清晰表达“网络终态”，而不是像脚本那样一步步执行指令，减少了配置冲突。
3.  **统一 API：**
    无论底层是用服务器级的 `networkd` 还是桌面级的 `NetworkManager`，管理员只需要学一种 YAML 语法，大幅降低了学习成本。

---

### 4. 深度复盘：你之前遇到的问题

*   **为什么 `cloud-init` 能改你的文件？**
    因为 `cloud-init` 处于 Netplan 的上游。它在 Netplan 执行 `generate` 之前，先修改了源头的 YAML 文件。
*   **为什么手动改了 `/etc/resolv.conf` 会失效？**
    因为在 Netplan 体系下，DNS 的权威源头是 YAML。当 `netplan apply` 触发后端（如 `systemd-resolved`）时，它会动态刷新 `/etc/resolv.conf`。手动修改它是“治标不治本”。
*   **为什么会出现 `NO-CARRIER`？**
    Netplan 只能在软件层面“翻译”配置，但如果物理层（VMware 的虚拟网线）断了，内核会给 Netplan 的后端返回 `NO-CARRIER`。这时 Netplan 就像一个翻译官，虽然收到了翻译稿，但发现电话线被拔了，所以翻译得再好也传不出去。

### 总结
**Netplan = YAML 解析器 + 配置生成器 + 后端触发器。**

理解了它把配置转换到 `/run` 目录的机制，你就掌握了 Netplan 的灵魂。以后遇到网络不通，除了看 YAML，还可以去 `/run/systemd/network/` 下看看生成的底层文件对不对，那是 Netplan 真正“吐”给系统的内容。

这是一个非常经典且让人抓狂的“坑”。作为资深网管，我告诉你原因：**因为这个文件的名字里带有 `cloud-init`。**

### 1. 为什么它会变？
`cloud-init` 是 Linux 专门为云环境（和虚拟机）设计的初始化工具。
*   **它的逻辑是：** 每次系统启动时，它都会去检查虚拟机的元数据（Metadata）。
*   **它的霸道之处：** 它认为自己才是网络配置的“主宰”。它会根据从 VMware 或云平台获取的信息，**强行重写** `/etc/netplan/50-cloud-init.yaml`。
*   **证据：** 你打开那个文件，开头第一行通常就写着：`# This file is generated from information provided by the datasource. Changes to it will not persist...`（本文件由数据源生成，手动修改在重启后不会保留）。

---

### 2. 彻底破局：如何让配置“固若金汤”？

你有两个方案，方案 A 是最正宗的“手术法”。

#### 方案 A：禁用 cloud-init 的网络管理功能（最推荐）
我们要告诉 `cloud-init`：“以后网络这块你别管了，我亲自来。”

1.  **创建一个禁用文件：**
    在终端输入以下命令：
    ```bash
    echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    ```
2.  **然后再修改你的 Netplan 文件：**
    这时候你再去改 `/etc/netplan/50-cloud-init.yaml`，重启后它就不会被覆盖了。

---

#### 方案 B：取巧法——利用 Netplan 的加载顺序
Netplan 会按照字母顺序读取 `/etc/netplan/` 下的所有 `.yaml` 文件，**后读的文件会覆盖先读的文件**。

1.  **新建一个文件：** 不要改 `50-cloud-init.yaml` 了。
2.  **创建一个名为 `99-manual-config.yaml` 的文件：**
    ```bash
    sudo nano /etc/netplan/99-manual-config.yaml
    ```
3.  **把你的配置写进去：**
    由于 `99` 大于 `50`，系统会优先采用 `99` 里的配置。即便 `50-cloud-init.yaml` 重启后变回去了，你的 `99` 文件依然稳如泰山。

---

### 3. 现在的操作建议

为了彻底解决你的“死循环”，请按以下步骤操作：

1.  **执行禁用命令：**
    ```bash
    sudo bash -c 'echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg'
    ```
2.  **修改 Netplan 文件：**
    把你的静态 IP、网关（192.168.80.2）和 DNS 重新写进去。
3.  **应用并测试：**
    ```bash
    sudo netplan apply
    ```
4.  **重启测试：**
    ```bash
    sudo reboot
    ```

**重启后，你会发现 IP 依然是 146，网络依然是通的。**

### 总结网管经验：
在 Ubuntu Server 环境下，看到 `50-cloud-init.yaml` 就要留个心眼。它是系统的“自动配置”，不是给人类长期修改准备的。**禁用它的网络接管**是每个资深网管装机后的“第一动作”。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-netplan)