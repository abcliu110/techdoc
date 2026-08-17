# Kubernetes 中 MySQL 外部访问方式对比

本文针对单节点 K3s 个人开发服务器，说明从物理机或其他外部客户端访问 K3s 内 MySQL 的常见方式。示例环境：虚拟机地址 `192.168.253.128`，MySQL Service 端口 `3306`，当前清单使用 NodePort `30306`。

## 一、先理解通信链路

Pod IP 会随着 Pod 重建而变化，不应直接作为客户端地址。稳定访问应依赖 Service、节点地址、虚拟网络地址或代理：

```text
外部客户端
  -> 节点 IP / VPN IP / 本地转发地址
  -> Service 或代理
  -> 当前 MySQL Pod IP:3306
```

Service 会通过 selector 和 EndpointSlice 自动跟踪新的 Pod IP。只要 Pod 标签不变，Pod IP 变化不会影响 NodePort 或 ClusterIP 的使用。

## 二、方式总览

| 方式 | 外部访问地址 | 稳定性 | 安全性 | 复杂度 | 适用场景 |
|---|---|---|---|---|---|
| NodePort | `192.168.253.128:30306` | 高 | 中 | 低 | 个人开发，最简单 |
| NodePort + 防火墙白名单 | `192.168.253.128:30306` | 高 | 较高 | 低 | 当前环境推荐 |
| NodePort + 专用数据库用户 | NodePort 地址 | 高 | 中高 | 低 | 外部工具长期连接 |
| SSH 本地端口转发 | `127.0.0.1:13306` | 中 | 高 | 中 | 临时开发、调试 |
| SSH 隧道常驻 | 本地固定端口 | 较高 | 高 | 中 | 长期使用但不开放端口 |
| WireGuard VPN | 虚拟机 VPN IP | 高 | 很高 | 中高 | 多设备、长期开发 |
| Tailscale/ZeroTier | 虚拟网络 IP | 高 | 高 | 低中 | 不想手动配置 VPN |
| Ingress TCP | Ingress 地址和 TCP 端口 | 高 | 中 | 高 | 已有统一 TCP 网关 |
| MetalLB/LoadBalancer | 局域网虚拟 IP | 高 | 中 | 高 | 局域网多服务正式暴露 |
| hostPort | 节点 IP:3306 | 高 | 中低 | 中 | 单节点临时开发 |
| hostNetwork | 节点 IP:3306 | 高 | 低 | 中 | 特殊网络需求 |
| 虚拟机端口代理 | 虚拟机 IP:3306 | 高 | 中 | 中 | 需要固定虚拟机端口 |
| MySQL 部署在虚拟机宿主机 | 虚拟机 IP:3306 | 高 | 取决于防火墙 | 中 | 数据库独立于 K3s |
| MySQL 部署在物理机 | 物理机 IP:3306 | 高 | 取决于网络 | 低中 | 数据库不需跟随 K3s |
| 数据库客户端运行在 K3s 内 | `mysql.mysql.svc.cluster.local:3306` | 高 | 高 | 低 | 只有集群内应用访问 |
| Rancher/kubectl 临时转发 | 本地临时端口 | 低 | 高 | 低 | 偶尔管理数据库 |

## 三、NodePort

### 3.1 工作方式

```text
192.168.253.128:30306
  -> Kubernetes NodePort Service
  -> mysql Service:3306
  -> MySQL Pod:3306
```

NodePort 是 Kubernetes 的 Service 类型，不是 MySQL 自身的端口。NodePort 由节点 IP 和固定端口组成；Pod IP 变化时，Service 自动更新 EndpointSlice。

连接示例：

```text
jdbc:mysql://192.168.253.128:30306/app?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
```

### 3.2 优点和风险

- 优点：配置简单、地址固定、适合个人开发工具；
- 风险：节点端口可被网络上其他主机探测；不应直接暴露到公网；
- 约束：虚拟机 IP 必须固定，NodePort 必须固定，防火墙应限制来源。

### 3.3 推荐加固

```bash
sudo ufw deny 30306/tcp
sudo ufw allow from <物理机IP> to any port 30306 proto tcp
```

业务应用不应使用 root，应使用仅拥有目标数据库权限的专用账号。

## 四、SSH 本地端口转发

SSH 转发把物理机本地端口映射到虚拟机或 K3s Service。它不会改变 MySQL 的 Service 类型，适合临时连接。

示例（先在虚拟机上运行端口转发）：

```bash
kubectl -n mysql port-forward svc/mysql 13306:3306 --address 127.0.0.1
```

然后物理机连接：

```text
jdbc:mysql://127.0.0.1:13306/app
```

优点是外部不开放 MySQL 端口；缺点是命令退出后连接中断，不适合无人值守服务。

## 五、SSH 隧道常驻

可以使用 Windows OpenSSH、autossh 或隧道管理工具自动重连 SSH 隧道。应用始终连接本机固定端口，隧道负责转发到虚拟机。

- 安全性高，不需要开放 NodePort；
- 需要维护 SSH 密钥、自动启动和断线重连；
- 不适合多人共享访问。

## 六、WireGuard、Tailscale 和 ZeroTier

这些方案在物理机和虚拟机之间建立私有网络。MySQL 可以保持 ClusterIP，也可以只绑定 VPN 网段访问。

```text
物理机 VPN IP -> 虚拟机 VPN IP:3306 -> MySQL
```

WireGuard 控制面更少、性能高，但需要手动配置密钥和路由。Tailscale/ZeroTier 配置更简单，适合个人多设备开发，但依赖额外客户端和控制面服务。

## 七、Ingress TCP

HTTP Ingress 不能直接代理 MySQL。必须使用支持 TCP stream 的 Ingress Controller，并单独配置 TCP 端口映射。

- 优点：可纳入统一网关、证书和访问控制；
- 缺点：配置复杂，会引入 Ingress Controller 常驻资源；
- 当前个人环境：不建议为单个 MySQL 安装此组件。

## 八、MetalLB / LoadBalancer

MetalLB 可以在局域网中为 Service 分配一个虚拟 IP。客户端访问的是稳定的局域网 IP，而不是 NodePort。

- 适合局域网中多个服务需要标准端口的场景；
- 需要规划地址池、ARP/BGP 和防火墙；
- 对当前单节点个人环境而言资源和维护成本偏高。

## 九、hostPort 与 hostNetwork

`hostPort` 让 Pod 占用节点指定端口；`hostNetwork` 让 Pod 直接使用节点网络栈。两者都绕开了一部分 Service 抽象：

- 地址看起来简单；
- 端口冲突和调度约束更强；
- 网络隔离变差；
- 单节点临时开发可以使用，但不建议长期采用。

## 十、虚拟机端口代理

可以在虚拟机上用 nftables、iptables、socat 或系统服务，把虚拟机 `3306` 转发到 K3s Service。外部客户端连接虚拟机固定 IP 的 `3306`。

这种方式需要额外维护系统转发规则，重启恢复和排障成本高，通常不如 NodePort 直接。

## 十一、把 MySQL 移出 K3s

MySQL 可以部署在虚拟机宿主机、物理机或企业数据库服务（例如 RDS）。这样数据库不随 K3s Pod 调度，但需要独立维护：

- 数据目录和备份；
- 开机自启；
- 升级和回滚；
- 防火墙和监听地址；
- 监控与故障恢复。

企业生产环境通常优先使用托管数据库或独立数据库集群，而不是在业务集群中运行单实例 MySQL。

## 十二、集群内访问

如果只有 K3s 内的应用访问 MySQL，应保持 `ClusterIP`：

```text
jdbc:mysql://mysql.mysql.svc.cluster.local:3306/app
```

这是安全性最高、资源和配置最少的方式。数据库客户端运行在 K3s 内时，不需要 NodePort、Ingress 或 VPN。

## 十三、Rancher/kubectl 临时访问

Rancher Shell 或 `kubectl port-forward` 适合偶尔执行 SQL、导入数据和故障排查。它们不提供稳定的长期服务地址，关闭终端后连接即断开。

## 十四、选择建议

### 当前个人开发服务器

推荐顺序：

1. NodePort + 虚拟机防火墙白名单；
2. Tailscale 或 WireGuard；
3. SSH 隧道常驻；
4. 普通 NodePort（仅临时使用）。

如果没有外部客户端需求，直接使用 ClusterIP。

### 企业生产环境

推荐：

- MySQL 使用 RDS 或独立数据库集群；
- 应用通过私网或 ClusterIP 访问；
- 运维人员通过 VPN、零信任和堡垒机访问；
- 使用专用账号和最小权限；
- 凭据放入受控的 Kubernetes Secret 或企业外部密钥服务；
- 配置备份、审计、TLS 和恢复演练。

## 十五、常见误区

- 直接使用 Pod IP：Pod 重建后地址会变化；
- 把 `30086` 当作 MySQL 端口：该端口是 Nacos Web；
- 认为修改 Kubernetes Secret 会修改 MySQL 用户：MySQL 初始化后不会自动同步；
- 认为 NodePort 只允许一个客户端：默认情况下节点可达网络都能尝试连接；
- 让业务应用使用 root：应创建独立业务账号；
- 用 HTTP Ingress 代理 3306：普通 HTTP Ingress 不支持 MySQL 协议。
