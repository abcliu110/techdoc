<div id="chap-RKE2"></div>

[⬆️ 返回目录](#catalog)

## RKE2

这段脚本是安装 **RKE2 (Rancher Next Generation Multicluster Kubernetes)** 的核心流程。针对你这台“会移动、IP会变”的服务器，该脚本在技术设计上采取了**“身份与位置解耦”**的策略。

以下是每一部分的详细技术原理说明：

---

### 第一阶段：脚本行为拆解

#### 1. 下载与安装 (`curl ... | sh -`)

- **动作**：从 Rancher 官方下载安装脚本并执行。
- **技术原理**：
  - 它并不直接安装 Kubernetes 组件，而是下载 RKE2 的**二进制文件**（包含 `containerd`, `kubelet`, `kubectl` 等）和 **systemd 服务单元文件**。
  - 它会将文件放置在 `/usr/local/bin` 和 `/usr/lib/systemd/system/`。
  - **此时并不会生成任何证书或启动任何进程**，只是把“工具箱”准备好。

#### 2. 创建配置目录 (`mkdir -p /etc/rancher/rke2`)

- **动作**：在系统级配置目录下建立 RKE2 专用的文件夹。
- **技术原理**：RKE2 启动时默认会读取这个路径下的 `config.yaml`。手动创建是为了在服务启动前灌入我们的“移动优化”配置。

#### 3. 核心配置文件 (`config.yaml`) 的技术内幕

这是支持“移动”的关键，每一行都有深刻用意：

- **`write-kubeconfig-mode: "0644"`**：
  - **原理**：默认 `kubeconfig` 只有 root 能读（0600）。改为 0644 让普通用户也能读取 `/etc/rancher/node/rke2/rke2.yaml`。
  - **初衷**：方便你直接在终端操作 `kubectl` 而不需要频繁切换 root。

- **`tls-san` (Subject Alternative Name)**：
  - **原理**：这是 **X.509 证书** 里的“别名白名单”。当 `kubectl` 访问服务器时，会检查服务器出示的证书里是否包含它正在访问的那个地址。
  - **移动优化逻辑**：
    - 我们加入了 `"jjtestserver"`（主机名）、`"localhost"`、`"127.0.0.1"`。
    - **重点**：我们**没有**写入 `192.168.x.x` 这种具体的物理 IP。
    - **效果**：只要你通过 `jjtestserver` 这个名字访问，证书校验永远通过。即便物理 IP 变了，只要名字没变，证书就是合法的。

- **`cluster/service-cidr`**：
  - **原理**：定义集群内部 Pod 和 Service 的虚拟网络范围。这些是内部逻辑网络，与外部物理网络（192.x.x.x）完全隔离，因此**外部 IP 变动不会影响容器间的内部通信**。

#### 4. 启动服务 (`systemctl enable/start`)

- **动作**：注册开机自启并立即运行 RKE2 引擎。
- **技术原理**：
  - **首次启动魔法**：这是最关键的时刻。RKE2 发现 `/var/lib/rancher/rke2/server/tls` 目录为空，于是它会**生成一套属于你这台机器的 CA（根证书）**，然后根据 `config.yaml` 里的 `tls-san` 列表，签发对应的服务端证书。
  - **组件运行**：它会启动一个内嵌的 `containerd`，并在其中以静态 Pod 或进程形式运行 Kubernetes 的核心组件（Etcd, API Server, Scheduler 等）。

---

### 第二阶段：移动服务器导致 IP 变化的深度解析

#### 1. 为什么集群不会“原地爆炸”？

在传统的 Kubernetes 安装中，IP 变了会导致 API Server 无法启动。但 RKE2 在你的脚本下表现如下：

- **监听机制**：RKE2 默认监听 `0.0.0.0`（所有网卡）。当机器移动到新环境，拿到新 IP 后，API Server 依然会在新 IP 的 6443 端口上张开双臂等待。
- **身份识别**：因为你在证书里预留了 `jjtestserver`，当你通过主机名连接时，握手依然成功。

#### 2. 证书修复技术原理（如果必须要认新 IP）

如果你发现必须通过新 IP 访问，而之前的证书里没写这个 IP，导致 `kubectl` 报错，你可以执行“证书翻新”。

**技术逻辑：**
Kubernetes 的证书体系分为 **CA（公安局）** 和 **Server Cert（身份证）**。

- 只要 **CA** 不动，你就可以随时撕掉旧的“身份证”，让“公安局”重新发一张。

**具体动作对应的原理：**

1.  **修改 `config.yaml`**：在 `tls-san` 里加入新 IP。
2.  **删除旧证书**：`rm .../tls/serving-kube-apiserver.*`
    - _原理_：RKE2 启动代码中有一个判断逻辑：`if !cert.Exists(); then GenerateNew();`。
3.  **重启服务**：
    - _原理_：RKE2 重启时发现证书文件消失了，它会调用内存里的 CA 私钥，读取 `config.yaml` 里的新 IP 列表，**重新签发一份包含新 IP 的证书**。

---

### 第三阶段：总结你的配置优势

1.  **解耦性**：你的脚本将“服务器的逻辑身份（jjtestserver）”与“物理位置（动态 IP）”分离了。
2.  **容灾性**：即使物理网卡被禁用、换成 Wi-Fi、或者搬到另一个城市，只要主机名不变，内部的 Etcd 数据库和 API 通信逻辑都能自愈。
3.  **零重装**：你不需要因为搬家而执行 `rke2-uninstall.sh`。对于 K8s 来说，这只是经历了一次短暂的“网络闪断”和重启。

**一句话总结：这套脚本把 K8s 从一台“固定基站”变成了一个“移动电台”，只要名字（jjtestserver）对得上，信号永远能连通。**

你的理解偏差在这里：**“服务器”不仅是一个硬件，它在 Kubernetes 里还扮演了“公安局（签发机构）”的角色。**

答案是：**是的，它们完全是由同一台服务器产生的。**

为了让你彻底明白，我们把这台 `jjtestserver` 拆解成三个逻辑身份：

---

### 1. 角色拆解

在一个单机 RKE2 环境中，这台机器同时扮演三个角色：

1.  **公安局 (CA - 证书颁发机构)**：负责刻公章，给别人发证。
2.  **办事大厅 (Server - API Server)**：负责提供服务。
3.  **办事员 (Client - kubectl)**：负责发起请求。

---

### 2. 证书产生全过程（技术时间线）

当你第一次执行 `systemctl start rke2-server` 时，这台机器内部发生了以下动作：

#### 第一步：给自己刻个公章 (生成 CA)

RKE2 启动，发现没证。它做的第一件事就是先给自己生成一对 **根证书 (CA)**。

- **文件**：`server-ca.crt` 和 `server-ca.key`。
- **原理**：这是最高权力，后面所有的证件都要盖这个章。

#### 第二步：给自己发个“营业执照” (生成服务端证书)

“公安局”给自己内部的“办事大厅”发证。

- **文件**：`serving-kube-apiserver.crt`。
- **原理**：这个证件里写了你的主机名 `jjtestserver` 和 `127.0.0.1`。这就是为什么你搬家后，只要主机名不变，这张执照就一直有效。

#### 第三步：给管理员发个“工作证” (生成客户端证书)

“公安局”给你要用的 `kubectl` 具现化一个身份。

- **文件**：这就是嵌入在 `/etc/rancher/rke2/rke2.yaml` 里的那段数据。
- **原理**：它也是用刚才第一步刻的那个公章盖的。

---

### 3. 为什么需要“两个证”？（关键区别）

既然都是同一台机器生成的，为什么不能用同一个证？**因为“验证方向”不同：**

| 证件名称       | 谁拿着它？             | 给谁看？         | 证明了什么？                                            |
| :------------- | :--------------------- | :--------------- | :------------------------------------------------------ |
| **服务端证书** | API Server (系统后台)  | 给 `kubectl` 看  | 证明：“我真的是 `jjtestserver` 的 API 接口，不是黑客。” |
| **客户端证书** | `kubectl` (你用的工具) | 给 API Server 看 | 证明：“我是这台服务器的超级管理员，请听我的指令。”      |

---

### 4. 形象类比：你自己给自己开证明

想象你是一个老板，你在公司里：

1.  你刻了一个**公司公章 (CA)**。
2.  你给你的**办公室大门**贴了一张执照，上面盖了章，写着“总经理办公室” (服务端证书)。
3.  你又给自己印了一张**出入证**，上面也盖了章，写着“老板本人” (客户端证书)。

- 当你走向办公室时，你先看门上的执照，确定没走错屋（**验证服务端证书**）。
- 你推门进去，办公室的安保系统（API Server）检查你的出入证，确定你是老板（**验证客户端证书**）。

**虽然公章、执照、出入证都是你自己印的，但它们的用途和查验的对象是不一样的。**

---

### 5. 总结

- **同一台服务器产生的吗？** 是的，都在 `/var/lib/rancher/rke2/server/tls` 目录下。
- **它们一样吗？** 不一样。服务端证书带有 **“我是服务器”** 的标识；客户端证书带有 **“我是管理员”** 的标识。
- **它们有关系吗？** 有，它们都是由同一个 **CA（根证书）** 签发出来的，所以它们互相之间天然信任。

这下明白了吗？**RKE2 就像一个自给自足的小王国，它在启动的一瞬间，既当了签发官，又当了服务器，还顺便给你这个管理员发了通行证。**

这条命令是使用 **Helm**（Kubernetes 的包管理器）来正式部署 Rancher 管理面板。

针对你只有 **一台测试服务器** 且 **IP 会变动** 的特殊情况，直接运行你给出的这条命令会遇到几个问题。我们需要根据你的实际环境进行“精准调优”。

---

### 1. 针对你单机环境的修正建议

#### 问题 A：`replicas=3`（副本数）

- **你的情况**：你只有一台服务器。
- **后果**：如果你设置 `replicas=3`，Rancher 会尝试启动 3个 Pod。虽然它们能跑在一台机器上，但会浪费资源。更重要的是，如果设置了反亲和性，另外两个 Pod 会一直显示 `Pending`（无法调度）。
- **建议**：单机测试请改为 `--set replicas=1`。

#### 问题 B：`hostname=rancher.example.com`

- **你的情况**：你的服务器主机名是 `jjtestserver`，且 IP 经常变。
- **建议**：为了和你之前的证书配置（`tls-san`）保持一致，建议改为你的主机名：`--set hostname=jjtestserver`。

#### 问题 C：缺少 `cert-manager`

- **原理**：Rancher 默认需要 `cert-manager` 来自动生成内部 HTTPS 证书。如果你没装 `cert-manager`，这条命令会卡住或报错。

---

### 2. 修正后的完整执行步骤

请按照以下顺序操作，确保安装成功：

#### 第一步：安装 Helm（如果还没装）

```bash
sudo snap install helm --classic
```

#### 第二步：添加 Rancher 仓库

```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
```

#### 第三步：安装 cert-manager (前提条件)

Rancher 强烈依赖它来处理 TLS 证书：

```bash
# 安装 cert-manager 的 CustomResourceDefinitions
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml

# 安装 cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.3
```

#### 第四步：执行 Rancher 安装（优化版）

```bash
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --create-namespace \
  --set hostname=jjtestserver \
  --set replicas=1 \
  --set bootstrapPassword=admin \
  --set ingress.tls.source=rancher
```

---

### 3. 这条命令的技术原理深度解析

- **`helm install rancher`**：
  - **原理**：Helm 会读取 Rancher 的“蓝图”（Chart），将其翻译成 Kubernetes 能理解的几十个资源对象（Deployment, Service, Ingress, RBAC 等），并一次性推送到 API Server。

- **`--namespace cattle-system`**：
  - **原理**：指定将 Rancher 的所有组件安装到我们之前创建的这个“逻辑领地”里。

- **`--set hostname=jjtestserver`**：
  - **核心作用**：
    1.  **Ingress 规则**：它会告诉 Kubernetes 的入口控制器（Ingress Controller），只有当访问请求的域名是 `jjtestserver` 时，才转发给 Rancher。
    2.  **生成证书**：`cert-manager` 会根据这个名字签发一张自签名证书。

- **`--set bootstrapPassword=admin`**：
  - **原理**：设置你第一次登录网页时的“初始开门密码”。

---

### 4. 移动服务器后，如何访问这个 Rancher？

既然你把 `hostname` 设为了 `jjtestserver`：

1.  **服务器搬家**，IP 变成了 `10.0.0.88`。
2.  **在你的笔记本上**，修改 `hosts` 文件，添加：`10.0.0.88 jjtestserver`。
3.  **浏览器访问**：`https://jjtestserver`。

**为什么这样最稳？**

- 因为 Rancher 内部生成的证书是给 `jjtestserver` 的。
- 因为你 RKE2 的 `tls-san` 里也写了 `jjtestserver`。
- **结果**：整个链路（从底层 K8s 到上层 Rancher UI）的身份标识是统一的，无论 IP 怎么变，只要名字对，就能秒开界面。

### 总结

你提供的命令是 **生产环境集群** 的标准写法。
对于你这台 **单机移动测试机**，请务必把副本数改回 **1**，并把域名改回 **主机名**。这样才能发挥你那 377G 内存的最大价值，同时避免网络变动带来的证书麻烦。

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-RKE2)
