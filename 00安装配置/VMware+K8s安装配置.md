# 单节点 K3s 个人开发服务器安装手册

本文用于 VMware 中的单节点个人开发服务器。目标是在保证 K3s 和基础设施稳定运行的前提下，尽量降低基础设施自身的 CPU、内存和后台组件占用，为后续业务应用保留资源。

## 一、强制原则

以下要求必须遵守：

1. **必须优先保证 K3s 控制面、CoreDNS、存储和已声明服务健康，不能以 OOM、健康检查超时、频繁重启或数据未持久化为代价压缩资源。**
2. **必须关闭个人开发环境不需要的组件。** 本基线只为已明确需要的 Rancher 安装单副本服务，不安装 cert-manager、Ingress Controller 和镜像扫描器；K3s 禁用 Traefik 与 ServiceLB；Harbor 禁用 Trivy。
3. **必须为后续应用预留资源。** 本次虚拟机实际配置为 `12 vCPU / 16 GB` 总容量，基础设施空闲时至少保留 `4 vCPU` 调度余量和 `6 GiB` 可用内存。若宿主机资源紧张，最低可降到 `8 vCPU / 16 GB`，但必须重新执行本文全部验收。
4. 当前基础设施的 CPU requests 总和不得长期超过节点的 50%，内存 requests 总和不得长期超过节点的 60%。超过时先优化、按需停用组件或扩容，不能继续无约束安装。
5. 每个工作负载必须设置合理的 requests/limits；不得用极低 limit 制造 OOM，也不得完全不设限制。
6. K3s 必须由 systemd 管理并开机自启；安装完成必须通过一次虚拟机重启验收。
7. Jenkins、Nexus、Harbor、Rancher 必须使用独立 values 文件。禁止重新合并为一个顶层键重复的 YAML。
8. 密码明文只允许出现在创建或更新 Kubernetes Secret 的命令或脚本中；本文、values、Git、应用 YAML 和连接串只能引用 Secret。Chart 或 Deployment 支持现有 Secret 时必须显式引用，备份时必须加密且限制访问权限。
9. 禁止为解决安装问题直接删除 PVC。涉及持久化数据时先备份，再决定回滚或前向修复。
10. 远程执行必须返回真实退出码；任何一步非零立即停止，禁止在失败状态上继续安装后续组件。
11. Helm 只管理 Kubernetes 资源；应用账号、仓库、Project 和密码轮换由应用 API 的幂等任务管理，两者不得混为一次 Helm 安装。

Secret 的工作原理和有状态应用边界见 [Kubernetes-Secret密码管理原理与边界.md](Kubernetes-Secret密码管理原理与边界.md)。安装阶段门禁和最终验收按 [VMware+K8s安装门禁与验收SOP.md](VMware+K8s安装门禁与验收SOP.md) 执行。本文只保留实际安装和验收步骤。

### 1.1 业务应用复用与部署边界

当前开发服务器已经部署的 Rancher、Gitea、Jenkins、Nexus、Harbor、Nacos、MySQL 和 K3s 系统组件不得从应用整理目录重复安装。业务应用统一使用 `lgy` namespace；不得因为改 namespace 而复制 Nacos 或 MySQL。

业务候选入口为 `D:\mywork\techdoc\00安装配置\应用整理\bundles\lgy-business.yaml`。Kafka 排除；ClickHouse、RocketMQ、EMQX、ZooKeeper 和 XXL-JOB 必须在确认实际业务依赖后单独启用，禁止整包安装。当前 EMQX 使用单一 `emqx:5.4.1` Pod；供 Nginx WebSocket 反向代理的内部地址为 `emqx54.lgy.svc.cluster.local:8083`，不创建第二个 broker 或对物理机暴露 NodePort。

已在原服务器当前运行的 `nms4cloud/gateway` 容器中直接读取 `/app.jar` 的依赖索引，确认其基础框架为 Spring Cloud Gateway 4.1.0（包含 `spring-cloud-starter-gateway-4.1.0.jar` 和 `spring-cloud-gateway-server-4.1.0.jar`）。`yd4cloud-gateway` 是业务镜像/服务名，不是阿里巴巴 Gateway 产品。原运行镜像地址和 `latest` 标签只作为迁移核对依据，不能直接用于 `lgy`。

2026-08-14 已在 `lgy` 部署通用 Spring Cloud Gateway 4.1.0 启动器，Harbor 制品为 `library/yd4cloud-gateway:1`，并同步发布相同 digest 的 `latest` 便于人工核对；Deployment 只能引用 `:1`。它仅提供 Gateway 运行时与健康端点，不包含原服务器的业务路由、Nacos namespace 或任何凭据。资源为 requests `25m/128Mi`、limits `250m/256Mi`，JVM 为 `-Xms48m -Xmx128m -XX:MaxMetaspaceSize=96m`；实测运行内存约 `212Mi`，`256Mi` 是当前已验证的最小安全上限。后续接入业务前必须从当前 Nacos 实例读取、审查并最小化导入实际路由配置；历史导出 YAML 只能作为线索，不能替代运行态配置证据。

业务工作负载连接已有基础设施时使用跨 namespace Service 全名。受本环境 `localdomain` 搜索域影响，Nacos、Redis、RocketMQ 与 Nginx 上游必须使用带结尾点的绝对 FQDN：`nacos.nacos.svc.cluster.local.:8848`、`redis.lgy.svc.cluster.local.`、`rocketmq-nameserver.lgy.svc.cluster.local.:9876`、`gateway.lgy.svc.cluster.local.:8080`；MySQL 使用 `mysql.mysql.svc.cluster.local.:3306`。业务 Secret 必须在 `lgy` 预先创建，用户名和密码由受控 Secret 同步流程从当前平台约定来源提供并保持一致；密码不得写入 Deployment、ConfigMap、values、连接串、Git 或本文件。

应用安装前必须完成 Harbor 镜像映射、Nginx ConfigMap、业务 Service、Secret 和跨 namespace 配置的服务端 dry-run；任一依赖缺失不得继续。

## 二、固定版本与容量

### 2.1 版本基线

| 组件 | 固定版本 |
|---|---|
| Ubuntu | 24.04 LTS |
| K3s | `v1.36.3+k3s1` |
| Helm | `v3.21.3` |
| Jenkins Chart | `jenkins/jenkins` `5.9.53` |
| Jenkins | `2.568.2-jdk21` |
| Gitea Chart | `gitea-charts/gitea` `12.7.0` |
| Gitea | `1.27.0` |
| Nexus Chart | `stevehipwell/nexus3` `5.24.1` |
| Nexus | `3.94.1` |
| Harbor Chart | `harbor/harbor` `1.19.2` |
| Harbor | `2.15.2` |
| Rancher Chart | `rancher-latest/rancher` `2.15.0` |
| Rancher | `v2.15.0` |
| Nacos | `3.2.3-slim` |
| MySQL | `8.4.7` LTS |

Rancher `2.15.0` 是正式 GA 版本并声明支持 Kubernetes `<1.37.0-0`，可用于当前 K3s `1.36.3`。Rancher 官方 `stable` Chart 仓库当前最高 `2.14.3`，只支持 Kubernetes `<1.36.0-0`，因此本基线从官方 `latest` 仓库获取、但严格固定 `2.15.0`，禁止省略 `--version` 跟随仓库更新。

升级前必须先在测试环境执行 `helm template`、安装、登录、上传制品和重启回归，不得直接使用仓库未固定的最新版本。

### 2.2 VMware 配置

| 项目 | 配置 |
|---|---|
| CPU | 本次为 1 个处理器、12 个核心；最低可用基线为 1 个处理器、8 个核心，不要配置成多个单核插槽 |
| 内存 | 16 GB |
| 磁盘 | 350 GB，建议按需增长 |
| 网络 | NAT / VMnet8 |
| 目标 IP | `192.168.253.128/24` |
| 网关 | `192.168.253.2` |

系统还原后必须完整启动一次，再检查资源：

```bash
nproc
free -h
lsblk
ip -brief address
ip route
```

本次应看到 12 个在线 CPU、约 15 GiB 可用内存和 `192.168.253.128`；若采用最低基线，则应看到 8 个在线 CPU。如果 IP 不同，停止安装，先固定 DHCP 租约或同步修改所有配置中的 IP；不要盲目覆盖 Netplan 文件。

### 2.3 SSH 首次授权与密钥验收

系统还原或首次安装后，必须先确认目标 IP 和 SSH 端口属于当前虚拟机。虚拟机网卡 MAC 固定为 `00:0c:29:2e:80:ec`，当前目标地址为 `192.168.253.128`：

```powershell
Get-NetNeighbor -IPAddress 192.168.253.128
Test-NetConnection 192.168.253.128 -Port 22 -InformationLevel Detailed
```

虚拟机未启动时该地址仍可达、MAC 不一致、IP 不存在或 22 端口未监听时立即停止，先处理 IP 冲突、DHCP 租约、Netplan 或 SSHD；不得把其他主机的 SSH 响应当作当前虚拟机。

系统还原导致 SSH 主机密钥变化时，不得只删除旧记录后直接连接。先在 VMware 控制台登录虚拟机，执行以下命令并人工记录 ED25519 的 SHA256 指纹：

```bash
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub -E sha256
```

再在 Windows PowerShell 中扫描新主机密钥。必须确认扫描结果的 ED25519 SHA256 指纹与控制台记录逐字符一致，才能删除旧记录并登记本次已核验的主机密钥：

```powershell
$scan = New-TemporaryFile
ssh-keyscan -t ed25519 192.168.253.128 2>$null | Set-Content -LiteralPath $scan -Encoding ascii
ssh-keygen -lf $scan -E sha256
# 仅在上面显示的 SHA256 指纹与 VMware 控制台记录完全一致后继续
ssh-keygen -R 192.168.253.128
Get-Content -LiteralPath $scan -Encoding ascii | Add-Content -LiteralPath "$HOME\.ssh\known_hosts" -Encoding ascii
Remove-Item -LiteralPath $scan
```

指纹不一致、扫描不到 ED25519 密钥或无法从可信控制台取得指纹时立即停止；不得接受交互提示中的未知新指纹，也不得运行公钥授权脚本。

首次需要安装本机公钥时，在 Windows PowerShell 中执行本目录的引导脚本：

```powershell
& 'D:\mywork\techdoc\00安装配置\ssh-authorize-key.ps1'
```

`ssh-authorize-key.ps1` 通过 `SecureString` 交互读取一次 SSH 密码，临时传给本机 SSH 工具后立即清除，并在结束前执行纯密钥登录验证。脚本、文档、命令行和持久环境配置中不得保存 SSH 明文密码。

授权完成后必须在未设置密码环境变量的会话中再次验证：

```powershell
Remove-Item Env:SSH_TOOL_PASSWORD -ErrorAction SilentlyContinue
python 'D:\mywork\techdoc\00安装配置\ssh_tool.py' cmd "id -un; hostname; ip -brief address show ens33"
```

只有返回用户 `lgy`、目标虚拟机主机名及 `192.168.253.128/24`，且命令退出码为零，才允许进入系统准备。`ssh_tool.py` 默认使用 `C:\Users\16555\.ssh\id_rsa`；需要更换密钥时通过 `SSH_TOOL_KEY_FILE` 显式指定，不得在脚本中增加第二份私钥。

## 三、系统准备

以下命令在虚拟机的 Bash 中执行。进入安装会话后开启失败即停：

```bash
set -euo pipefail
```

### 3.1 更新系统并安装工具

```bash
sudo apt-get update
sudo apt-get install -y curl ca-certificates tar openssl jq
```

### 3.2 关闭 Swap

```bash
sudo cp -a /etc/fstab /etc/fstab.pre-k3s
sudo swapoff -a
sudo sed -ri '/^[[:space:]]*#/!{/[[:space:]]swap[[:space:]]/s/^/#/}' /etc/fstab
```

验收结果必须为空：

```bash
swapon --show
```

### 3.3 保留防火墙和 sudo 安全边界

不要执行 `ufw disable`，不要配置 `NOPASSWD: ALL`。如果 UFW 已启用，只允许 NAT 网段访问需要的端口：

```bash
sudo ufw allow from 192.168.253.0/24 to any port 22 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 30080 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 30087 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 30088 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 30081 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 30083 proto tcp
# Harbor HTTP 30082 仅作重定向入口，默认不放行；直接使用 HTTPS 30083
sudo ufw allow from 192.168.253.0/24 to any port 30085 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 30086 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 30089 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 31089 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 31090 proto tcp
sudo ufw allow from 192.168.253.0/24 to any port 30306 proto tcp
```

VMware NAT 默认不等于生产网络隔离。不要配置外网端口转发。

## 四、安装 K3s

### 4.1 systemd 安装

```bash
curl -sfL https://get.k3s.io -o /tmp/k3s-install.sh
sudo env \
  INSTALL_K3S_VERSION='v1.36.3+k3s1' \
  INSTALL_K3S_EXEC='server --disable=traefik --disable=servicelb --write-kubeconfig-mode=600' \
  bash /tmp/k3s-install.sh
```

本基线保留 K3s 必需组件、CoreDNS、local-path 存储和 metrics-server；禁用不使用的 Traefik 与 ServiceLB。

### 4.2 配置当前用户的 kubeconfig

```bash
sudo install -d -m 700 -o "$USER" -g "$USER" "$HOME/.kube"
sudo install -m 600 -o "$USER" -g "$USER" \
  /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
grep -qxF 'export KUBECONFIG="$HOME/.kube/config"' "$HOME/.bashrc" || \
  printf '%s\n' 'export KUBECONFIG="$HOME/.kube/config"' >> "$HOME/.bashrc"
export KUBECONFIG="$HOME/.kube/config"
```

禁止把 `/etc/rancher/k3s/k3s.yaml` 修改为 `644`。

### 4.3 K3s 验收

```bash
systemctl is-enabled k3s
systemctl is-active k3s
kubectl wait --for=condition=Ready node --all --timeout=180s
kubectl get pods -A
kubectl top node
```

必须满足：

- `k3s` 为 `enabled` 和 `active`；
- 节点为 `Ready`，本次容量显示 12 CPU 和约 15 GiB 内存（采用最低基线时为 8 CPU）；
- `kube-system` 必需 Pod 为 `Running`；
- 不应出现 Traefik 和 `svclb-*` Pod。

## 五、安装 Helm

```bash
cd /tmp
curl -fLO https://get.helm.sh/helm-v3.21.3-linux-amd64.tar.gz
curl -fLO https://get.helm.sh/helm-v3.21.3-linux-amd64.tar.gz.sha256sum
sha256sum -c helm-v3.21.3-linux-amd64.tar.gz.sha256sum
tar -xzf helm-v3.21.3-linux-amd64.tar.gz
sudo install -m 0755 linux-amd64/helm /usr/local/bin/helm
helm version --short
```

添加固定来源：

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo add stevehipwell https://stevehipwell.github.io/helm-charts/
helm repo add harbor https://helm.goharbor.io
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
```

## 六、上传部署文件

先确认 2.3 的纯密钥登录门禁已经通过，再在 Windows PowerShell 中执行：

```powershell
$src = 'D:\mywork\techdoc\00安装配置'
scp "$src\k3s-rancher-values.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-rancher-nodeport.yaml" lgy@192.168.253.128:/tmp/
scp "$src\rancher-admin-password-sync.sh" lgy@192.168.253.128:/tmp/
scp "$src\k3s-jenkins-values.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-gitea-values.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-nexus-values.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-nexus-nodeport.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-harbor-values.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-registries.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-nacos.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-mysql.yaml" lgy@192.168.253.128:/tmp/
scp "$src\k3s-infra-secrets-init.sh" lgy@192.168.253.128:/tmp/
scp "$src\nacos-admin-password-sync.sh" lgy@192.168.253.128:/tmp/
scp "$src\nexus-application-bootstrap.sh" lgy@192.168.253.128:/tmp/
scp "$src\nexus-eula.json" lgy@192.168.253.128:/tmp/
scp "$src\jenkins-credential-upsert.sh" lgy@192.168.253.128:/tmp/
scp "$src\jenkins-home-backup.sh" lgy@192.168.253.128:/tmp/
scp "$src\harbor-application-bootstrap.sh" lgy@192.168.253.128:/tmp/
scp "$src\harbor-retention-library.json" lgy@192.168.253.128:/tmp/
scp "$src\k3s-platform-check.sh" lgy@192.168.253.128:/tmp/
```

## 七、部署基础设施

应用安装顺序固定为：`Rancher -> Gitea -> Jenkins -> Nexus -> Harbor -> Nacos -> MySQL`。K3s、Helm、文件、namespace/Secret 和服务端预检通过后，必须先安装并验收 Rancher；后续章节按此顺序选择执行，不能按章节编号并行安装。

每次安装或升级前，先用与正式部署相同的版本和 values 完成渲染；任一命令失败即停止：

```bash
helm template rancher rancher-latest/rancher -n cattle-system --version 2.15.0 \
  -f /tmp/k3s-rancher-values.yaml >/dev/null
helm template jenkins jenkins/jenkins -n jenkins --version 5.9.53 \
  -f /tmp/k3s-jenkins-values.yaml >/dev/null
helm template gitea gitea-charts/gitea -n gitea --version 12.7.0 \
  -f /tmp/k3s-gitea-values.yaml >/dev/null
helm template nexus stevehipwell/nexus3 -n nexus --version 5.24.1 \
  -f /tmp/k3s-nexus-values.yaml >/dev/null
helm template harbor harbor/harbor -n harbor --version 1.19.2 \
  -f /tmp/k3s-harbor-values.yaml >/dev/null
```

### 7.1 namespace 与管理员 Secret

K3s 本身不依赖应用 Secret。正确顺序固定为：

```text
安装 K3s -> 创建各产品 namespace -> 在对应 namespace 创建 Secret -> 安装应用
```

平台组件固定使用已批准的独立 namespace：Rancher 使用官方要求的 `cattle-system`，Jenkins 使用官方安装指南推荐的 `jenkins`，Harbor、Nexus、Nacos 和 MySQL 分别使用企业约定的 `harbor`、`nexus`、`nacos`、`mysql`。平台组件不得共用笼统的 `infra` 或省略 namespace 落入 `default`。只有同环境、同责任团队、同安全等级和同生命周期的业务应用才共享业务 namespace。

通用判断规则和安装门禁见 [Kubernetes应用安装标准SOP.md](Kubernetes应用安装标准SOP.md)。本节只保留当前环境的执行入口。

安装任何应用前，必须先一次性创建并校验以下 Secret：

| 应用 | Namespace | 命名依据 | 必须预建的 Secret | 原因 |
|---|---|---|---|---|
| Rancher | `cattle-system` | 官方要求 | `cattle-system/rancher-admin` | Chart 不传密码；同步脚本在 Rancher Ready 后通过 API 设置管理员密码 |
| Jenkins | `jenkins` | 官方安装指南推荐 | `jenkins/jenkins-admin` | Chart 启动时挂载管理员账号和密码 |
| Gitea | `gitea` | 独立代码服务 | `gitea/gitea-admin` | Chart 初始化管理员账号和密码 |
| Nexus | `nexus` | 企业约定 | `nexus/nexus-admin` | 空数据目录首次启动时初始化管理员密码 |
| Harbor | `harbor` | 企业约定 | `harbor/harbor-admin` | Chart 初始化 Harbor 管理员密码 |
| Nacos | `nacos` | 企业约定 | `nacos/nacos-auth`、`nacos/nacos-admin`、首次 `nacos/nacos-bootstrap-admin` | 服务认证由 Pod 引用；同步脚本设置控制台密码后删除 bootstrap Secret |
| MySQL | `mysql` | 企业约定 | `mysql/mysql-auth` | 空数据目录首次启动时初始化账号密码 |

Rancher Chart `2.15.0` 不支持直接引用管理员 Secret；本基线不向 values 传密码，而是在安装后通过 `rancher-admin-password-sync.sh` 从 `cattle-system/rancher-admin` 同步并验证管理员密码。

```bash
chmod 700 /tmp/k3s-infra-secrets-init.sh
/tmp/k3s-infra-secrets-init.sh
```

首次创建管理员 Secret 时，`k3s-infra-secrets-init.sh` 按本环境明确批准的例外使用统一管理员密码；受控自动化可用进程环境变量 `PLATFORM_ADMIN_PASSWORD` 注入或覆盖，执行后必须立即清除。明文例外仅限这个创建或更新 Kubernetes Secret 的脚本/命令，不得复制到本文档、Helm values、工作负载 YAML、连接串或其他配置。脚本将该值分别写入 `jenkins-admin/chart-admin-password`、`gitea-admin/password`、`harbor-admin/HARBOR_ADMIN_PASSWORD`、`nexus-admin/password`、`nacos-admin/password`、`mysql-auth/MYSQL_ROOT_PASSWORD`、`mysql-auth/MYSQL_PASSWORD` 和 `rancher-admin/password`。已有 Secret 全部有效时不会重新创建，但会在不解码、不回显值的前提下校验这些键完全一致。脚本全部成功后才能继续；任一 Secret 缺失且应用状态已存在时立即停止，不会生成新密码。Nacos 服务认证 Token、Harbor Robot Token、Jenkins 外部凭据以及 Rancher/Nacos 的一次性 bootstrap Secret 不属于长期应用管理员密码，不使用该统一值。随后使用正式安装的相同版本、values 和原生清单执行 Kubernetes 服务端预检，任何一项失败都不得进入 7.2：

```bash
helm template rancher rancher-latest/rancher -n cattle-system --version 2.15.0 \
  -f /tmp/k3s-rancher-values.yaml | kubectl apply --dry-run=server -f - >/dev/null
kubectl apply --dry-run=server -f /tmp/k3s-rancher-nodeport.yaml >/dev/null
helm template jenkins jenkins/jenkins -n jenkins --version 5.9.53 \
  -f /tmp/k3s-jenkins-values.yaml | kubectl apply --dry-run=server -f - >/dev/null
helm template gitea gitea-charts/gitea -n gitea --version 12.7.0 \
  -f /tmp/k3s-gitea-values.yaml | kubectl apply --dry-run=server -f - >/dev/null
helm template nexus stevehipwell/nexus3 -n nexus --version 5.24.1 \
  -f /tmp/k3s-nexus-values.yaml | kubectl apply --dry-run=server -f - >/dev/null
helm template harbor harbor/harbor -n harbor --version 1.19.2 \
  -f /tmp/k3s-harbor-values.yaml | kubectl apply --dry-run=server -f - >/dev/null
kubectl apply --dry-run=server -f /tmp/k3s-nexus-nodeport.yaml >/dev/null
kubectl apply --dry-run=server -f /tmp/k3s-nacos.yaml >/dev/null
kubectl apply --dry-run=server -f /tmp/k3s-mysql.yaml >/dev/null
```

### 7.2 Rancher

本个人开发环境不安装 Ingress Controller 和 cert-manager。Rancher 使用单副本、固定 NodePort，并设置 `tls=external`；这只适用于 VMware NAT 内的个人开发环境，不能作为生产 TLS 方案。

Rancher 会自动安装 Fleet 控制器以管理本地集群和系统 Chart，这是 Rancher 的必要组件，不能在保留 Rancher 管理功能的同时单独删除。首次初始化时 Fleet 可能在 CRD 创建完成前短暂重启，最终必须恢复为 Ready 且重启计数不再增长。

```bash
helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --create-namespace \
  --version 2.15.0 \
  --values /tmp/k3s-rancher-values.yaml \
  --atomic --timeout 20m

kubectl apply -f /tmp/k3s-rancher-nodeport.yaml
```

Chart `2.15.0` 没有可引用已有 Secret 的 `existingSecret` 参数。不得设置明文 `bootstrapPassword`；Chart 生成的一次性 `bootstrap-secret` 只由同步脚本读取，不显示、不写入 values，也不作为日常管理员密码来源。

```bash
bash /tmp/rancher-admin-password-sync.sh
```

脚本以 `rancher-admin` Secret 的值调用 Rancher API，认证成功后删除一次性 `bootstrap-secret`。保留 K3s/Rancher 数据时重启或 Helm 升级不会改变已同步的密码；全新初始化时必须重新执行本步骤。Rancher、Fleet、本地集群和管理员真实认证全部通过后，才能安装 Gitea。

### 7.3 Gitea

Gitea 是 K3s 内部的正式代码服务器。当前基线使用 Gitea Chart `12.7.0`、Gitea `1.27.0`、单副本、SQLite 和一个 `20Gi` 的 `local-path` PVC；不部署 PostgreSQL、Valkey、Ingress 或 Actions。管理员账号由 `gitea/gitea-admin` Secret 提供，Chart 使用 `initialOnlyNoReset`，Helm 升级不会用 values 重置密码。

```bash
helm upgrade --install gitea gitea-charts/gitea \
  --namespace gitea \
  --create-namespace \
  --version 12.7.0 \
  --values /tmp/k3s-gitea-values.yaml \
  --atomic --timeout 20m

kubectl rollout status deployment/gitea -n gitea --timeout=15m
kubectl get pods,pvc,svc,endpointslice -n gitea -o wide
```

访问地址：

| 用途 | 地址 |
|---|---|
| Web/API | `http://192.168.253.128:30087` |
| Git SSH | `ssh://git@192.168.253.128:30088` |
| Jenkins 集群内访问 | `http://gitea-http.gitea.svc.cluster.local.:3000` |

必须确认 Web 页面可以使用 `admin` 登录，PVC 为 `Bound`，HTTP/SSH NodePort 只指向 Gitea Pod，且没有 PostgreSQL、Valkey 或持续失败事件。管理员密码只从 `gitea/gitea-admin` 获取，不写入本文或 Jenkins 配置。

上游源码服务器只做一次人工迁移，不配置长期 Pull Mirror。迁移前冻结上游写入，在 Gitea 创建普通仓库并导入完整历史、全部分支和标签；迁移后核对默认分支、分支/标签数量和最新提交，再把 Gitea 作为正式代码源。也可在受控终端使用 `git clone --mirror` 和 `git push --mirror` 完成一次迁移，禁止把上游 Token 写入脚本、日志或 Git。

Gitea 仓库迁移验收通过后，才允许把 Jenkins Branch Source 改为 Gitea；Jenkins 不再直接访问上游源码服务器。

### 7.4 Jenkins

Jenkins 管理密码以 Kubernetes Secret `jenkins/jenkins-admin` 为配置来源。不要只在 Jenkins 页面修改密码；本基线的 JCasC 会在 Pod 重启或 Helm 升级时按 Secret 重新同步管理员密码。

Jenkins Chart `5.9.53` 必须保持 `controller.admin.createSecret: true`、`controller.admin.existingSecret: jenkins-admin`、`controller.admin.userKey: chart-admin-username` 和 `controller.admin.passwordKey: chart-admin-password`。在本版本中，`createSecret: true` 同时控制管理员 Secret 的挂载；与 `existingSecret` 配合时使用已有 Secret，不代表每次重新生成密码。改成 `false` 会导致管理员 Secret 未挂载、JCasC 变量无法解析。

当前项目仓库不保存 Jenkinsfile，但需要自动发现分支，因此 Jenkins 固定安装 `remote-file:1.24`，使用 Remote Jenkinsfile Provider + Multibranch Pipeline。该插件版本必须写入 `k3s-jenkins-values.yaml` 的 `controller.installPlugins`，不得通过网页临时安装未固定版本。现有 Jenkins 使用持久化 PVC，稳定运行时必须保持 `controller.initializeOnce: true` 和 `controller.overwritePlugins: false`；Chart 会在首次初始化成功后写入 `${JENKINS_HOME}/initialization-completed`，后续 Pod 重建直接复用 PVC 中已经验证的插件、Job、凭据和配置。不得把 `initializeOnce` 改为 `false` 作为普通插件升级手段：Chart 5.9.53 的 init 脚本固定使用交互式 `yes n | cp -i` 复制插件，init 容器异常重启后其 `emptyDir` 中已有插件会导致复制命令非零退出并 CrashLoop。`installLatestPlugins` 和 `installLatestSpecifiedPlugins` 继续保持 `false`。

新增或升级插件属于受控变更：先完成 Helm 渲染、服务端 dry-run 和 `bash /tmp/jenkins-home-backup.sh backup`，再在独立测试 Jenkins/PVC 验证固定插件版本；通过后安排维护窗口，停止 Controller，以完整外部备份为回滚点，按 Chart 官方升级流程执行并验证插件版本、旧 Job 与凭据。不得删除生产 PVC、手工清空插件目录或依赖 init 容器重试来恢复。升级前备份脚本会停止 Controller，通过临时 Pod 挂载同一 PVC，把包括插件、Job、`credentials.xml`、`secrets/`、用户和主配置在内的完整 Jenkins Home 备份到节点 `/var/backups/jenkins`，生成 SHA-256 校验文件并将权限设为 `600`。

#### 构建缓存基线

当前个人开发环境只保留一个长期 Maven 缓存：Nexus 的 `maven-public` group 仓库。临时 Kubernetes Agent 的 Maven 本地目录只属于本次构建，构建 Pod 销毁后可以丢弃；未命中的依赖由 `maven-public` 从其成员仓库代理并持久化到 Nexus，再由 Agent 下载。不要为 Maven 另建 `maven-cache` PVC，也不要把 Nexus Blob Store 目录直接挂载为 Maven 本地仓库。平台 Jenkinsfile 必须通过 `settings.xml` 或等效参数将依赖解析指向 `http://nexus.nexus.svc.cluster.local.:8081/repository/maven-public/`。

Maven 缓存链路固定为：

```text
临时 Jenkins Agent -> Nexus maven-public -> Nexus 成员仓库/上游
```

Helm revision 不能回滚写入 Jenkins PVC 的插件和 Job。失败时先禁用新建 Multibranch Job，再以 `JENKINS_RESTORE_CONFIRM=RESTORE_JENKINS_HOME bash /tmp/jenkins-home-backup.sh restore <archive>` 恢复完整备份，随后回滚 Helm revision并重启验证。恢复脚本保持 Controller 停止、校验归档、清空精确挂载点、完整解压并恢复 `1000:1000` 属主后才启动 Controller。若没有可恢复的外部备份，不得在现有实例试装插件，应先使用独立测试 Jenkins/PVC 验证。

修改 Jenkins 密码时先更新 Secret，再重启 Jenkins，并进行实际网页登录验证：

```bash
read -rsp 'New Jenkins admin password: ' JENKINS_ADMIN_PASSWORD; echo
if (( ${#JENKINS_ADMIN_PASSWORD} < 12 )); then
  echo 'Jenkins password must be at least 12 characters' >&2
  unset JENKINS_ADMIN_PASSWORD
  exit 1
fi
printf 'chart-admin-username=admin\nchart-admin-password=%s\n' "$JENKINS_ADMIN_PASSWORD" | \
  kubectl create secret generic jenkins-admin -n jenkins \
    --from-env-file=/dev/stdin --dry-run=client -o yaml | \
  kubectl apply -f -
unset JENKINS_ADMIN_PASSWORD
kubectl rollout restart statefulset/jenkins -n jenkins
kubectl rollout status statefulset/jenkins -n jenkins --timeout=180s
```

```bash
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins \
  --version 5.9.53 \
  --values /tmp/k3s-jenkins-values.yaml \
  --wait --timeout 20m
```

常规 Jenkins 升级不使用 `--atomic` 作为 PVC 恢复机制：Helm 回滚不能回滚 Jenkins Home 中已经写入的插件、Job 或凭据。升级失败时保留失败现场，先检查 init 容器日志和 PVC 外部备份，再执行明确的前向修复或完整 Jenkins Home 恢复。

#### Jenkins 流水线凭据前置条件

基础设施必须严格按 `Rancher -> Gitea -> Jenkins -> Nexus -> Harbor -> Nacos -> MySQL` 完成阶段验收；以下流水线凭据和 Multibranch Job 只能在 Harbor 真实推送验收通过后配置。凭据 ID 必须完全一致，凭据值不写入本文、Git 或 Job XML：

| Credential ID | 类型 | 用途 |
|---|---|---|
| `gitea-scm-readonly` | Gitea 专用只读 Token 或 Username with password | 从内部 Gitea 拉取业务代码 |
| `jenkins-platform-readonly` | Username with password 或 Git 服务支持的只读 Token | 平台流水线仓库 checkout |
| `nexus-deployer` | Username with password | Maven 发布到 Nexus |
| `harbor-robot` | Username with password | Kaniko 推送 Harbor |

创建后先验证四个 ID 存在，再由真实构建验证其最小权限。Jenkins 只使用内部 Gitea 服务 `http://gitea-http.gitea.svc.cluster.local.:3000/<组织>/<仓库>.git` 拉取业务代码，不再直接访问上游源码服务器；FQDN 必须保留结尾的 `.`，防止 Jenkins Pod 的搜索域把名称解析到集群外地址。浏览器和开发人员使用 NodePort `http://192.168.253.128:30087`。流水线中的 Nexus 地址 `nexus.nexus.svc.cluster.local:8081` 只在集群内可解析；浏览器管理 Nexus 使用 NodePort `30081`。项目仓库 URL 和分支由 Multibranch Branch Source 维护，不能依赖项目仓库中的 Jenkinsfile 或项目配置文件。

项目仓库不需要 `Jenkinsfile` 或 `.ci/pipeline.properties`。流水线脚本放在受保护的平台配置仓库；项目仓库 URL 由 Multibranch Branch Source 配置，当前构建分支必须来自 Jenkins 提供的 `scm` 与 `BRANCH_NAME`，不能再从 properties 读取或固定为 `master`。应用名、Dockerfile 和构建上下文等非敏感差异，可以直接由每个项目的受保护平台 Jenkinsfile 声明，或由该脚本显式 checkout 平台配置仓库后读取；Remote Jenkinsfile Provider 只提供 Jenkinsfile，不会自动把同仓库的旁路配置文件放入工作区。流水线通过 Jenkins 布尔参数 `SKIP_TESTS` 控制测试，默认值为 `true`（跳过测试），不从项目仓库读取或覆盖；准备发布或验收前必须在构建参数中改为 `false` 并确认测试通过。Nexus/Harbor 地址、仓库和 Credential ID 也只能由平台流水线控制。

#### Remote Jenkinsfile Provider 多分支配置

配置前必须先将平台 Jenkinsfile 提交到 Jenkins 可访问的受保护 Git 仓库；本机未提交文件、Jenkins 工作区临时文件和内联 Job XML 均不能作为正式来源。平台仓库固定使用只读 Credential ID `jenkins-platform-readonly`，目标分支禁止直接提交和 force-push，所有变更必须通过 Pull Request 并遵循当时已批准的分支保护策略。当前授权策略的 `required_approvals=0`，仅允许 `admin` 合并；不得通过直接 push 或 force-push 绕过保护。能够固定不可变 tag 或 commit 时优先使用已审核版本；必须跟踪受保护分支时，每次平台脚本变更都要重新执行流水线门禁。

创建 Multibranch Job 时固定以下边界：

- Branch Source 指向 Gitea 中已经完成一次性迁移的项目代码仓库，凭据使用 `gitea-scm-readonly`，启用分支发现并限制扫描范围；
- Project Recognizer 选择 Remote Jenkinsfile Provider，远程仓库指向 Gitea 平台仓库 `http://gitea-http.gitea.svc.cluster.local.:3000/admin/jenkins-platform.git`，凭据使用 `jenkins-platform-readonly`，以 `jenkins-platform-v1` 获取对象但在 SCM Branch Spec 固定到审核提交 SHA；测试项目 Job 名为 `build-demo-springboot-artifacts`，脚本路径为 `demo-springboot/Jenkinsfile`。Codeup 只在迁移阶段作为源地址使用；
- 平台脚本分支使用固定受保护分支，不跟随项目分支切换，不允许项目提交覆盖远程仓库地址或脚本路径；
- 分支删除后按保留策略清理子 Job，扫描间隔和同时构建数必须适配单节点资源；
- 当前七个 Multibranch Job 均使用 SCM Head wildcard filter，仅包含 `master`；扫描后只能存在 `master` 子 Job，直接触发项目构建也必须指向 `master`。
- 云服务 Job 当前在成功构建后执行发布阶段；由于其分支发现已限制为 `master`，运行时只有 `master` 可触发发布。其他 Job 的发布条件以各自受保护 Jenkinsfile 为准，不能以旧的 `feature/*`、`release/*` 通用规则覆盖。
- PR、fork 和 `feature/*` 构建不得绑定任何发布凭据；编译测试与发布拆成独立阶段，Nexus/Harbor 写凭据只能在可信发布分支通过测试和授权后，以最小命令作用域绑定。

创建后必须执行一次“立即扫描 Multibranch Pipeline”，确认至少发现 `master`，并分别核对扫描日志、子 Job 的 `BRANCH_NAME`、平台脚本来源和代码 checkout 提交。只有真实构建完成且 Nexus/Harbor 可回查时，才算配置成功。

Jenkins Agent 的 `rbac.readSecrets: false` 是有意限制：当前流水线只通过 Jenkins Credentials 读取凭据，不直接读取 Kubernetes Secret。若后续流水线新增 Secret API、ConfigMap 或部署操作，必须重新评审并最小化授权，不能直接放开整个 Secret 读取权限。

### 7.5 Nexus

Nexus Chart `5.24.1` 从预先创建的 `nexus/nexus-admin` 初始化管理员密码。确认 7.1 已成功后执行：

```bash
helm upgrade --install nexus stevehipwell/nexus3 \
  --namespace nexus \
  --version 5.24.1 \
  --values /tmp/k3s-nexus-values.yaml \
  --atomic --timeout 15m

kubectl apply -f /tmp/k3s-nexus-nodeport.yaml
```

以后升级必须同时保留 `nexus-admin` 和 Nexus PVC，禁止单独修改 Nexus 管理员密码或单独删除其中一个。发现 Secret 缺失或密码失配时立即停止认证重试，保留 Release 和 PVC，先确认 Nexus 运行时密码来源并恢复与现有 PVC 匹配的 `nexus-admin`；只允许一次认证复验。无法恢复时先备份，再走明确批准的数据重建流程，禁止把直接重装作为密码失配处理手段。

#### Nexus 应用配置初始化

Helm 只安装 Nexus 的 Pod、Service、PVC 和 JVM 资源，不会自动创建 Maven 仓库、部署用户或权限角色。首次登录后使用本目录脚本完成以下最小初始化：

1. 创建并确认 `maven-releases` hosted 仓库、`maven-snapshots` hosted 仓库、`maven-central` proxy 仓库和 `maven-public` group 仓库。
2. 创建权限仅限发布仓库的 `nexus-deployer` 用户或角色；不要让 Jenkins 使用 Nexus 管理员账号。
3. 将 `nexus-deployer` 的凭据只保存到 Jenkins Credentials，并验证一次 `mvn deploy`。

POS 前端构建使用 Nexus npm 缓存：`npmjs-proxy` 代理 `https://registry.npmjs.org`，`npm-public` group 仅聚合该 proxy。Jenkins Pod 必须使用集群内地址 `http://nexus.nexus.svc.cluster.local:8081/repository/npm-public/`，不得把 npmjs.org 直连地址写入 Jenkinsfile。POS Node 构建容器挂载 `jenkins/jenkins-pnpm-cache` PVC 到 `/home/jenkins/.pnpm-store`，并使用 `pnpm install --frozen-lockfile --store-dir /home/jenkins/.pnpm-store`；该卷仅用于 CI 依赖缓存，不得挂载到业务工作负载。首次调度前 local-path PVC 显示 `Pending` 属于延迟绑定，构建 Agent 调度后必须变为 `Bound`。
脚本只创建缺失对象，发现同名仓库、角色或用户时不会覆盖其配置和密码；它是可重复执行的引导脚本，不是完整的期望状态控制器。Blob Store、清理策略和匿名访问策略需要另行评审后配置。不要把 Nexus 初始密码、API Authorization 或用户密码写入 values、Git 或流水线脚本。

本目录提供幂等初始化脚本。管理员密码由脚本启动时从 `nexus/nexus-admin` Secret 读取一次，不通过 stdin、PowerShell 管道或命令行传递。首次创建部署用户时，必须在受控进程环境中临时提供 `NEXUS_DEPLOYER_PASSWORD`；已有用户重跑时不需要该变量。管理员认证只尝试一次，失败立即停止，避免触发 Nexus `429` 账号锁定。负责人已授权当前环境接受随本目录固定版本 Nexus CE 对应的 EULA 后，执行：

```bash
chmod 700 /tmp/nexus-application-bootstrap.sh
NEXUS_URL=http://127.0.0.1:30081 \
NEXUS_ACCEPT_EULA=true \
NEXUS_EULA_FILE=/tmp/nexus-eula.json \
  /tmp/nexus-application-bootstrap.sh
unset NEXUS_DEPLOYER_PASSWORD
```

脚本创建部署用户后，应立即把用户名 `nexus-deployer` 和本次受控输入的密码保存为 Jenkins Credentials 的 `nexus-deployer`，随后清除环境变量。若用户已存在，脚本不会修改密码，必须继续使用已有 Jenkins Credential。禁止使用 `printf`、`echo` 管道、命令行参数或文件明文向该脚本传密码。

Nexus Repository Community Edition 首次部署还必须完成 EULA 门禁。脚本先 `GET /service/rest/v1/system/eula`；仅在返回的 `.accepted` 不是 `true` 且负责人已通过 `NEXUS_ACCEPT_EULA=true` 明确授权时，才把经过版本审核的 `/tmp/nexus-eula.json` 原样 `POST` 到同一接口；随后再次 GET 并确认 `.accepted == true`。脚本只把已认证资源查询的 `404` 判定为不存在；`401`、`403`、`429` 或其他非预期状态立即停止且不自动重试，不得删除 PVC、重装或继续 Harbor。EULA 确认后还必须使用 `nexus-deployer` 完成一次真实制品发布和查询。

### 7.6 Harbor

```bash
helm upgrade --install harbor harbor/harbor \
  --namespace harbor \
  --version 1.19.2 \
  --values /tmp/k3s-harbor-values.yaml \
  --atomic --timeout 20m
```

Harbor 管理员密码初始化后保存在 Harbor 数据库中，`harbor/harbor-admin` Secret 用于部署和全新数据库初始化。只修改 Secret 不会修改已运行 Harbor 的管理员密码。

修改 Harbor 管理员密码时必须按以下顺序执行：

1. 在 Harbor 页面或受支持的 API 中修改当前 `admin` 密码；当前版本要求密码包含大写字母、小写字母和数字。
2. 使用相同的新密码更新 `harbor/harbor-admin` 的 `HARBOR_ADMIN_PASSWORD`。
3. 立即验证 Harbor 页面或 `/api/v2.0/users/current` 认证成功。
4. 不要通过直接修改 Harbor 数据库密码哈希绕过密码策略。

轮换前必须确认旧密码仍可用，并保持当前管理会话。若第 2 步更新 Secret 失败，立即重试；仍失败时在当前会话中把 Harbor 密码恢复为旧值。只有新密码登录和 Secret 更新都验证成功后，才结束旧会话。

保留 Harbor 数据库 PVC、Registry PVC 和 `harbor-admin` Secret 时，Pod 重建、Helm 升级或 Release 重装不会改变密码。若恢复了旧数据库，则必须同时恢复与该数据库状态对应的 Secret。

#### 镜像出口与缓存基线

当前 VMware 开发环境由物理机 Clash Verge Rev 提供外网出口。Clash 的 TUN/fake-IP 模式会把 Docker Hub 域名解析为 `198.18.0.0/15` 内的虚拟地址，再在物理机网络层还原域名并转发。浏览器、`curl` 或 BusyBox `wget` 成功，只能证明透明代理对这些客户端可用，不能证明 Kaniko 的 Go Registry 客户端可用。

已复现的故障特征为：节点和普通 Pod 访问 `https://index.docker.io/v2/` 返回正常的 `401 Unauthorized`，但相同 Pod 网络中的 Kaniko 拉取 `eclipse-temurin:21-jre` 时返回：

```text
Get "https://index.docker.io/v2/": EOF
```

Harbor `dockerhub` Proxy Cache 是 Docker Hub 基础镜像的正式入口。Jenkins Agent 的 Docker Hub 镜像和业务 Dockerfile 的 Java 基础镜像都必须使用 Harbor 地址；Harbor 缓存未命中时，由 Harbor Core 通过物理机 Clash 的显式 mixed proxy 从 Docker Hub 拉取并缓存：

```text
Jenkins Kaniko registry map -> Harbor dockerhub Proxy Cache -> HTTP CONNECT -> Clash -> Docker Hub
Jenkins/Kaniko -> NO_PROXY -> Harbor、Nexus、Kubernetes Service 和本机内网
```

业务源码保持 Dockerfile 原文不变，例如 `FROM eclipse-temurin:21-jre`。受保护平台 Jenkinsfile 的每次 Kaniko 调用必须使用 Kaniko 1.23.2 支持的 Registry Map：

```text
--registry-map="index.docker.io=192.168.253.128:30083/dockerhub"
--skip-default-registry-fallback
```

这会将 Docker Hub 镜像请求映射到 Harbor Proxy Cache，且 Harbor 未命中或代理失败时不允许回退为直连 Docker Hub。禁止为了代理缓存而修改业务 Dockerfile、Java 版本或基础镜像内容。Kaniko 的 `gcr.io/kaniko-project/executor` 不属于 Docker Hub Proxy 范围，必须单独镜像同步或配置对应上游后才能变更其来源；禁止伪造为 `dockerhub` 路径。

本机已验证值为物理机 VMware NAT 网卡 `192.168.253.1`、Clash mixed port `7897`。这两个值是环境参数，不得复制到其他机器后直接宣称可用。部署前必须从虚拟机验证端口连通和 Docker Hub `401` 响应，再写入 Kaniko 容器：

```yaml
env:
  - name: HTTP_PROXY
    value: http://192.168.253.1:7897
  - name: HTTPS_PROXY
    value: http://192.168.253.1:7897
  - name: NO_PROXY
    value: 127.0.0.1,localhost,.cluster.local,.svc,10.42.0.0/16,10.43.0.0/16,192.168.253.128
```

`NO_PROXY` 必须覆盖实际的 Pod CIDR、Service CIDR、集群域名、K3s 节点以及 Harbor/Nexus 地址，避免内部制品流量绕到物理机代理。Jenkins Maven Agent 从 Harbor Proxy 拉取 Docker Hub 镜像后，不应再为 Maven 容器无差别注入公网代理；Kaniko 只有在仍需访问非 Docker Hub 上游时才保留显式代理。

Harbor Docker Hub Proxy 与 Kaniko 远程构建层缓存是两项独立能力。当前 `nms4pos` 流水线使用 Harbor `library/kaniko-cache`，启用时必须配置最小权限凭据和保留/回收策略。

Kaniko 1.23.2 对未显式指定 Registry 的 Docker Hub 镜像使用内部名称 `index.docker.io`，因此 Registry Map 的左侧必须写为 `index.docker.io`，不能写为 `docker.io`。在修改平台流水线前，必须在 Jenkins Agent 同网络中验证 Harbor Proxy 可拉取至少一个 Docker Hub 镜像，并确认 Harbor 中的对应 Proxy Cache 制品可查询。验证成功后，检查 Jenkinsfile 同时包含 `--registry-map="index.docker.io=<Harbor>/dockerhub"` 和 `--skip-default-registry-fallback`，且构建日志不再显示从 `index.docker.io` 拉取 Java 基础镜像。任一不满足时停止，不得以 Docker Hub 直连成功替代 Proxy 验收。

Harbor 使用开发环境自签名证书。为允许本机 K3s 从 Harbor 拉取镜像，创建：

```bash
sudo install -m 600 /tmp/k3s-registries.yaml /etc/rancher/k3s/registries.yaml
sudo systemctl restart k3s
```

`insecure_skip_verify` 只允许用于该 NAT 内的个人开发环境，不能复制到生产环境。

#### Harbor 应用配置初始化

Helm 只安装 Harbor 的 Kubernetes 资源和持久化组件，不会自动创建业务 Project、Robot Account 或保留策略。首次安装完成后，必须通过受控的 Harbor API 初始化任务完成以下检查：

1. `library` Project 存在，且可见性和存储配额符合当前环境要求。
2. 为 Jenkins 创建权限最小化的 Project Robot Account，并将其凭据只保存到 Jenkins Credentials 的 `harbor-robot`。
3. 按项目名称查询 Project ID 后再应用 `harbor-retention-library.json`；禁止直接假设 Project ID 为 `1`。
4. 用 Robot Account 实际推送一次测试镜像，再从 Harbor 查询该镜像。

初始化任务必须幂等，不能把管理员密码、Robot Token 或 API Authorization 写入 Git、values 或构建日志。Harbor 的 API 地址使用当前部署的 HTTPS 入口；集群内服务名、端口和证书校验方式必须与当前 Helm values 一起验证。

本目录提供 Harbor API 初始化脚本模板。当前 Harbor 使用开发环境自签名证书，执行时显式允许跳过客户端证书校验：

```bash
chmod 700 /tmp/harbor-application-bootstrap.sh
HARBOR_INSECURE=true /tmp/harbor-application-bootstrap.sh
```

脚本首次创建 Robot Account 时会显示完整 Robot 用户名，并把用户名和一次性 Token 写入权限为 `600` 的 `/tmp/harbor-robot-credential.json`，不再等待人工按回车。紧接着必须由自动化脚本把该文件导入 Jenkins Username with password 凭据 `harbor-robot`；导入后使用该 Jenkins Credential 完成一次 Harbor 登录、测试镜像推送和查询，验证成功后立即删除临时文件。

Harbor 阶段的固定顺序为：

```text
创建或查询 Project -> 创建 Robot -> 自动导入 Jenkins Credentials
-> 使用 harbor-robot 真实推送并查询 -> 删除临时凭据文件 -> 应用保留策略
```

禁止输出临时文件内容、等待人工按回车、把 Robot Token 写入命令行或在临时文件仍存在时结束安装。自动导入、真实推送/查询或文件删除任一步失败，必须停在 Harbor，不能继续 Nacos。若 Robot Account 已存在，脚本不得假定原 Token 可取回；必须先确认 Jenkins 中 `harbor-robot` 已存在并通过真实推送验证，否则走 Harbor 支持的 Token 轮换流程，再自动更新 Jenkins Credential。

### 7.7 Nacos

本基线只安装 Nacos 单节点 standalone、Web 控制台、配置/注册中心 API 和客户端 gRPC 端口。关闭 Nacos 集群、MySQL、监控、Ingress 和额外副本；数据使用一个 `5Gi` local-path PVC。认证 token 与服务间身份写入 Secret，不写入清单。

PVC 只挂载到 Nacos 的 `/home/nacos/data`。升级或重装前必须确认当前镜像确实将需要保留的配置/注册数据写入该路径，并先备份 PVC；不要仅凭 PVC `Bound` 就视为备份完成。

```bash
kubectl apply -f /tmp/k3s-nacos.yaml
bash /tmp/nacos-admin-password-sync.sh
```

Nacos 控制台密码由 `nacos-admin-password-sync.sh` 从 `nacos/nacos-admin` 设置并验证，成功后删除 `nacos-bootstrap-admin`。访问端口：

| 用途 | 地址 |
|---|---|
| Web 控制台 | `http://192.168.253.128:30086` |
| HTTP API/客户端 | `192.168.253.128:30089` |
| 客户端 gRPC | `192.168.253.128:31089` |
| 客户端 gRPC TLS | `192.168.253.128:31090` |

### 7.8 MySQL

MySQL 仅作为后续应用的共享数据库，使用单实例 `mysql:8.4.7`、一个 `10Gi` local-path PVC，并通过固定 NodePort `30306` 提供外部 TCP 访问。为节省资源，关闭 Performance Schema，限制最大连接数和 InnoDB 缓冲池；不安装 MySQL 集群、Exporter、phpMyAdmin 或 Ingress。数据库凭据只写入 Secret，不写入本文。

```bash
kubectl apply -f /tmp/k3s-mysql.yaml
kubectl rollout status deployment/mysql -n mysql --timeout=15m
```

应用连接地址为 `mysql.mysql.svc.cluster.local:3306`（只有同在 `mysql` namespace 时才能简写为 `mysql:3306`），外部连接使用 `192.168.253.128:30306`，默认数据库和用户为 `app`。只允许可信网段访问该端口，禁止暴露到公网。

`mysql-auth` Secret 只在 MySQL 数据目录首次初始化时创建账号密码。已有 MySQL PVC 中的系统表才是运行时账号密码来源；修改 Secret 不会自动修改已有 MySQL 用户。保留 PVC 时重启或重新部署不会改变密码，删除 PVC 后才会按当时的 Secret 重新初始化。

### 7.9 密码与重新部署规则

| 操作 | Jenkins | Gitea | Harbor | Nexus | Rancher | MySQL |
|---|---|---|---|---|---|
| Pod 重启 | 从原 Secret/JCasC 恢复，不变 | PVC 保留，不变 | 数据库保留，不变 | PVC 保留，不变 | 持久化状态保留，不变 | PVC 保留，不变 |
| Helm 升级 | 保留 Secret/PVC 时不变 | 保留 Secret/PVC 时不变 | 保留 Secret/PVC 时不变 | 保留 PVC 时不变 | 保留状态时不变 | 不适用 Helm，保留 PVC 时不变 |
| Release 删除后重装 | 复用原 Secret/PVC 时不变 | 复用原 Secret/PVC 时不变 | 复用原 Secret/PVC 时不变 | 复用原 PVC 时不变 | 复用原状态时不变 | 复用原 PVC 时不变 |
| 删除 Secret | 可能启动失败或被错误配置覆盖 | 现有账号状态不变；必须恢复与 Gitea PVC 匹配的原 Secret，禁止按默认值新建 | 可能与数据库密码失配 | 当前账号状态不变；必须从受控备份恢复与现有 PVC 运行时密码完全匹配的原 Secret，禁止按默认值新建；无法恢复则停止并走已批准的数据重建流程 | 引导 Secret 不会重置现有密码 | 不会修改已有用户，但全新初始化会缺少凭据 |
| 删除 PVC/数据库 | 重新初始化 | 重新初始化 | 重新初始化 | 重新生成首次密码 | 重新进入初始化流程 | 按 Secret 重新初始化 |

个人开发环境只执行 Pod 重启或固定版本的升级，不删除 Secret、PVC、Namespace 或应用数据库。需要全新重装时，先备份并成组恢复对应 Secret 与持久化数据，不能只恢复其中一项。

Jenkins Credentials 存储在 Jenkins 持久化数据中，不由 Kubernetes Secret 自动重建。若 Jenkins PVC 丢失，恢复流水线前必须从受控备份或原凭据系统重新创建 `gitea-scm-readonly`、`jenkins-platform-readonly`、`nexus-deployer` 和 `harbor-robot`，并分别验证 Gitea 代码拉取、Gitea 平台脚本拉取、Maven 发布和镜像推送。`aliyun-codeup-token` 仅用于一次性迁移，不属于正式运行时凭据。

## 八、验收

### 8.1 工作负载与数据

`lgy` namespace 中单独部署的 Nginx 使用 Harbor Docker Hub Proxy Cache 的固定镜像 `192.168.253.128:30083/dockerhub/library/nginx:1.25.3`，不使用 `latest` 或 hostPort。静态文件使用单节点开发环境专用的 `/home/lgy/nginx-static` hostPath，并挂载到 `/usr/share/nginx/html`；物理机通过 SFTP 以 `lgy` 用户上传文件，初始化容器固定设置目录权限为 `755`，并只在 `index.html` 不存在时写入默认页面，后续 Pod 重建不会覆盖已有静态文件。该 hostPath 不得复制到多节点或生产集群，现有 `nginx-static` PVC 暂不删除。其单副本资源为 requests `25m/32Mi`、limits `150m/128Mi`，并以 NodePort Service `nginx:30090` 在 VMware NAT 开发网段提供 HTTP 访问；物理机通过 `http://192.168.253.128:30090/` 访问。部署或升级时必须先对独立清单执行服务端预检，再验收 rollout、Ready Endpoint 和 HTTP 200 探针：

```bash
kubectl apply --dry-run=server -n lgy -f /tmp/lgy-nginx.yaml
kubectl apply -n lgy -f /tmp/lgy-nginx.yaml
kubectl rollout status deployment/nginx -n lgy --timeout=3m
kubectl get deployment,pod,svc -n lgy -l app=nginx -o wide
kubectl get endpointslice -n lgy -l kubernetes.io/service-name=nginx
kubectl logs -n lgy deployment/nginx --tail=30
```

Nginx 官方镜像可能不含 `curl` 或 `wget`，不得把容器内命令缺失误判为 HTTP 服务失败；以 `Running`、Ready Endpoint 和 Nginx 访问日志中的 kubelet 探针 `GET /` 返回 `200` 共同验收。2026-08-14 已按此标准完成首次部署。

```bash
bash /tmp/k3s-platform-check.sh verify
kubectl get deployment -n cattle-system -o name | xargs -r -n1 kubectl rollout status -n cattle-system --timeout=20m
kubectl rollout status statefulset/jenkins -n jenkins --timeout=20m
kubectl rollout status deployment/gitea -n gitea --timeout=20m
kubectl rollout status statefulset/nexus -n nexus --timeout=20m
kubectl get deployment -n harbor -o name | xargs -r -n1 kubectl rollout status -n harbor --timeout=20m
kubectl get statefulset -n harbor -o name | xargs -r -n1 kubectl rollout status -n harbor --timeout=20m
kubectl rollout status deployment/nacos -n nacos --timeout=20m
kubectl rollout status deployment/mysql -n mysql --timeout=20m
kubectl get pods -n cattle-system -o wide
kubectl get pods -n cattle-fleet-system -o wide
kubectl get svc -n cattle-system
kubectl get pods,pvc,svc -n jenkins -o wide
kubectl get pods,pvc,svc -n gitea -o wide
kubectl get pods,pvc,svc -n nexus -o wide
kubectl get pods,pvc,svc -n harbor -o wide
kubectl get pods,pvc,svc -n nacos -o wide
kubectl get pods,pvc,svc -n mysql -o wide
kubectl get endpointslice -n cattle-system
kubectl get endpointslice -n jenkins
kubectl get endpointslice -n gitea
kubectl get endpointslice -n nexus
kubectl get endpointslice -n harbor
kubectl get endpointslice -n nacos
kubectl get endpointslice -n mysql
kubectl get events -A --field-selector type=Warning --sort-by=.lastTimestamp
```

在不采集终端日志的受控终端执行真实认证；以下命令均交互提示密码，禁止把密码追加到命令行：

```bash
read -rsp 'Rancher admin password: ' RANCHER_PASSWORD; echo
printf '%s' "$RANCHER_PASSWORD" | \
  jq -Rs '{username:"admin",password:.,responseType:"json"}' | \
  curl -kfsS -H 'Content-Type: application/json' --data-binary @- \
    'https://127.0.0.1:30085/v3-public/localProviders/local?action=login' | \
  jq -e '.type == "token" and ((.token // "") | length > 0)' >/dev/null
unset RANCHER_PASSWORD

curl -fsS -u admin http://127.0.0.1:30080/whoAmI/api/json | jq -e '.authenticated == true'
curl -fsS -u admin http://127.0.0.1:30081/service/rest/v1/security/users >/dev/null
curl -kfsS -u admin https://127.0.0.1:30083/api/v2.0/users/current | jq -e '.username == "admin"'

read -rsp 'Nacos password: ' NACOS_PASSWORD; echo
printf '%s' "$NACOS_PASSWORD" | \
  curl -fsS -X POST --data-urlencode 'username=nacos' \
    --data-urlencode 'password@-' \
    http://127.0.0.1:30086/v3/auth/user/login | \
  jq -e '(((.accessToken // .data.accessToken // "") | length) > 0)' >/dev/null
unset NACOS_PASSWORD

kubectl exec -it deployment/mysql -n mysql -- mysql -uapp -p app -e 'SELECT 1;'
```

`k3s-platform-check.sh` 检查资源、Secret 名称、必需键是否非空，并直接比较各管理员密码键的编码数据是否一致；脚本不输出或解码 Secret 值，也不代替以上认证验收。七个应用认证均成功后，才能判定密码状态正确。

必须确认：

- 所有长期运行 Pod 为 `Running` 且 Ready；
- Rancher 和 Fleet 的长期运行 Pod 均为 Ready；已完成的 `helm-operation-*` Pod 不是常驻工作负载；
- Nacos Pod 为 Ready，Nacos PVC 为 `Bound`，且 Web 控制台返回 HTTP 200；
- MySQL Pod 为 Ready，MySQL PVC 为 `Bound`，并能通过 `192.168.253.128:30306` 执行认证查询；
- 所有 PVC 为 `Bound`；
- Jenkins `30080`、Gitea `30087/30088`、Nexus `30081`、Harbor HTTPS `30083`、Rancher HTTPS `30085`、Nacos `30086/30089/31089/31090`、MySQL `30306` 只有预期 Service；
- Nexus NodePort 的 Endpoint 只指向 Nexus Pod；
- 不存在持续增加的健康检查失败、OOMKilled 或调度失败事件。

访问地址：

| 服务 | 地址 | 用户名 | 密码来源/获取方式 |
|---|---|---|---|
| Rancher | `https://192.168.253.128:30085`（自签名证书） | `admin` | 首次引导从 `cattle-system/bootstrap-secret` 读取；修改后保存在 Rancher 状态中 |
| Jenkins | `http://192.168.253.128:30080` | `admin` | `jenkins/jenkins-admin` Secret 的 `chart-admin-password`，禁止写入文档 |
| Gitea | `http://192.168.253.128:30087` | `admin` | `gitea/gitea-admin` Secret 的 `password`，禁止写入文档 |
| Nexus | `http://192.168.253.128:30081` | `admin` | `nexus/nexus-admin` 必须与 Nexus PVC 中的当前密码一致；全新数据目录从该 Secret 初始化 |
| Harbor | `https://192.168.253.128:30083` | `admin` | Harbor 数据库为运行时状态，`harbor/harbor-admin` Secret 必须与其保持一致 |
| Nacos | `http://192.168.253.128:30086` | `nacos` | `nacos/nacos-admin` Secret 的 `password`，同步后必须与 Nacos 运行时状态一致 |
| MySQL | `192.168.253.128:30306` | `root` / `app` | `mysql/mysql-auth` Secret 的对应键，必须与现有 MySQL PVC 中的账号状态一致 |

### 8.2 强制资源余量验收

```bash
kubectl top node
kubectl top pods -A --containers
kubectl describe node | sed -n '/Allocated resources:/,/Events:/p'
free -h
```

系统空闲稳定 10 分钟后必须满足：

- 节点 `MemoryPressure=False`、`DiskPressure=False`、`PIDPressure=False`；
- 实际可用内存不少于 6 GiB；
- CPU requests 不超过 50%，内存 requests 不超过 60%；
- 空闲 CPU 使用不长期超过 50%；
- 如果余量不足，先关闭不需要的 Jenkins 构建、减少并发或检查异常进程，禁止继续安装新应用。

### 8.3 强制重启验收

Ubuntu 可能在重启时清理 `/tmp`。重启前必须把只读验收脚本复制到当前用户的持久化受限目录：

```bash
install -d -m 700 "$HOME/.local/lib/k3s-bootstrap"
install -m 700 /tmp/k3s-platform-check.sh "$HOME/.local/lib/k3s-bootstrap/k3s-platform-check.sh"
```

```bash
sudo reboot
```

重新连接后执行：

```bash
systemctl is-enabled k3s
systemctl is-active k3s
kubectl wait --for=condition=Ready node --all --timeout=180s
kubectl get deployment -n cattle-system -o name | xargs -r -n1 kubectl rollout status -n cattle-system --timeout=20m
kubectl rollout status statefulset/jenkins -n jenkins --timeout=20m
kubectl rollout status deployment/gitea -n gitea --timeout=20m
kubectl rollout status statefulset/nexus -n nexus --timeout=20m
kubectl get deployment -n harbor -o name | xargs -r -n1 kubectl rollout status -n harbor --timeout=20m
kubectl get statefulset -n harbor -o name | xargs -r -n1 kubectl rollout status -n harbor --timeout=20m
kubectl rollout status deployment/nacos -n nacos --timeout=20m
kubectl rollout status deployment/mysql -n mysql --timeout=20m
kubectl get pvc -A
kubectl get events -A --field-selector type=Warning --sort-by=.lastTimestamp
bash "$HOME/.local/lib/k3s-bootstrap/k3s-platform-check.sh" verify
```

重启后服务自动恢复、PVC 仍为 `Bound`、各 Web 页面仍能访问且 MySQL 认证查询成功，才算部署完成。

## 九、维护与回滚

查看状态：

```bash
systemctl status k3s --no-pager
kubectl get pods -A
helm list -A
```

Helm 升级失败时优先查看历史并回滚，不要卸载后重装：

```bash
helm history <release> -n <namespace>
helm rollback <release> <revision> -n <namespace> --wait --timeout 15m
```

### 9.1 Gitea 平台流水线脚本维护

`admin/jenkins-platform` 是 Jenkins Remote Jenkinsfile 的正式来源。该仓库的每个已引用脚本都是运行契约；迁移或补充脚本时必须采用普通分支、Pull Request 和受保护分支合并流程。

严禁对任何已有远程仓库执行 `git push --mirror`、`git push --all --force` 或以本地不完整镜像覆盖远端引用。`--mirror` 会同步删除远端中本地不存在的分支、标签和文件历史，不能用于 Gitea 仓库迁移、平台脚本恢复或日常发布。

推送前必须完成以下只读核对并留存脱敏结果：

- 从远端克隆目标基线分支，不得以本地 bundle 或缓存目录假定远端内容；
- 列出远端目标分支的 Jenkinsfile 清单，并与变更后的清单比较；除经审批的明确删除项外，文件数和既有路径不得减少；
- 使用 `git diff --name-status <remote-base>...<candidate>` 复核所有 `D` 删除项；存在未授权删除时停止；
- 确认目标分支的直接推送和 force-push 均被禁止，审批数符合当前保护策略；
- 仅推送候选分支的单个 refspec，例如 `refs/heads/<review-branch>:refs/heads/<review-branch>`，再创建 PR；禁止使用 `--mirror`。

合并后必须重新拉取目标分支，复核 Jenkinsfile 清单、PR 合并状态与分支保护设置；然后只触发关联 Multibranch Job 的索引扫描，确认 Remote Jenkinsfile 路径仍可解析。索引扫描不等于构建验收，未获明确授权不得触发应用构建、镜像推送或部署。

### 9.2 Harbor 业务镜像标签规范

每个业务镜像必须在同一次 Kaniko 推送中写入一个不可变构建标签和一个按分支/发布策略指定的移动别名，两个标签必须指向同一 digest。Deployment 只能引用已验证的不可变标签，禁止引用移动别名。标签语法以受保护 Jenkinsfile 为准，并在构建元数据中记录构建号、提交 SHA、分支和镜像摘要；当前云服务使用 `${BUILD_NUMBER}` 与 `latest`，`nms4cloud-order` 使用 `<git-short-sha>-<build-number>` 与 `master-latest`。

移动别名是最新成功构建的便捷引用，不是版本号；它不得用于 Deployment，也不得替代回滚所需的不可变标签。Harbor 保留策略负责按审批的数量清理历史构建产物；流水线不得调用 Harbor 删除 API 来删除其他构建或仅保留一个 artifact，否则会破坏回滚和审计。

变更标签逻辑必须作为独立平台 Jenkinsfile PR：先验证候选分支只修改预期脚本，再按当前受保护分支策略合并；禁止直接推送或 force-push 绕过保护。合并后必须执行一次可信发布分支构建，逐仓库验证不可变标签与移动别名的 digest 相同，随后将部署清单更新为该不可变标签。

#### 9.2.1 `nms4cloud-order` 流水线验收记录（2026-08-16）

订单代码仓库 `admin/nms4cloud-order` 已配置 Jenkins Multibranch Job `build-nms4cloud-order-images`；项目代码负责分支发现，远程 Jenkinsfile 固定来自 `admin/jenkins-platform` 的 `nms4cloud-order/Jenkinsfile`。平台脚本通过 PR #9 合并至 `jenkins-platform-v1`，提交为 `7e9b11f48aed83018bed46c810a3224e485c09f4`。

此前 `jujiao_master` 构建后的 `Retain Latest Harbor Artifact` 阶段会调用 Harbor 删除 API，删除此前 `master` 构建的 artifact，导致被删除标签的 Harbor API 与 Registry manifest 查询返回 `404`。该阶段及其删除函数已从订单 Jenkinsfile 移除；清理由 Harbor 项目级 Retention Policy 单独执行，流水线不得再调用 Harbor artifact 删除 API。

本次可信构建为 Jenkins `master #7`，结果为 `SUCCESS`，使用 Job 默认 `SKIP_TESTS=true`，因此 Maven 测试未执行。Kaniko 在同一构建中发布了 `library/nms4cloud-order:fd2584554777-7` 和 `library/nms4cloud-order:master-latest`，二者均解析为 `sha256:d58743d94d80ecb9d8cd0a9a97a99f95dd1a64dc937512de447fb7395a158915`。Harbor API 查询两个标签均返回 `200`，Registry 的 manifest `HEAD` 查询两个标签也均返回 `200`。

当前 `library` 项目的 Retention Policy ID 为 `1`，计划为 `0 0 0 * * *`，匹配全部仓库和标签，保留最新推送的 `1` 个 artifact。该策略会在后续清理后移除旧 artifact；需要数字标签回滚窗口时，必须先由负责人批准并提高 `latestPushedK`，再更新策略和复验，不得恢复流水线删除逻辑。

2026-08-16 还完成了其他平台流水线的修复：`build-nms4cloud-images`、`maintenance-nexus-keep-latest-snapshots` 与 `publish-nms4cloud-wms-api` 曾固定到已不可达的 Remote Jenkinsfile 短提交 `964bd03`，云服务 `master #12` 因此在读取脚本前失败。三个 Job 及 `build-nms4pos-images` 已更新为当前已合并的平台提交。POS Jenkinsfile 中与订单同类的 Harbor artifact 删除阶段也已通过 PR #10 移除，POS 镜像清理同样只允许由 Harbor 项目级策略执行。

云服务 monorepo 中保留有与独立 `admin/nms4cloud-order` 仓库不一致的订单服务实现。云服务 Job 原先执行全 Reactor 构建，会编译该实现并因缺失 CRM/微信 API 类型而阻断所有云镜像。PR #11 将云服务构建限制为其 11 个实际发布应用模块及 Maven `-am` 依赖闭包，并移除该 Job 的订单镜像发布项；订单继续只由 `build-nms4cloud-order-images` 发布。回归 `build-nms4cloud-images/master #14` 为 `SUCCESS`，耗时约 182 秒，未编译 `nms4cloud-order-service`。

PR #12 已移除云服务镜像发布阶段的分支条件，所有成功分支构建均执行 Kaniko 发布。回归 `build-nms4cloud-images/master #15` 为 `SUCCESS`，向 Harbor 发布了 `nms4cloud-platform`、`nms4cloud-mq`、`nms4cloud-netty`、`nms4cloud-wechat`、`nms4cloud-biz`、`nms4cloud-crm`、`nms4cloud-mall`、`nms4cloud-payment`、`nms4cloud-pos`、`nms4cloud-product` 和 `nms4cloud-scm` 共 11 个镜像；每个 `:15` 与 `:latest` 标签均经 Harbor API 和 Registry manifest 验证，且解析为相同 digest。

#### 9.2.2 POS 安装包流水线运行基线（2026-08-16）

POS 安装包 Job 文件夹 `pos-install-package` 按 `00-clean -> 01-nms4cloud -> 02-nms4pos-ui -> 03-nms4pos` 串行执行。虚拟机内存有限，Jenkins Kubernetes Agent 并发数固定为 `1`；必须等待前一构建 Pod 删除且 `jenkins-build-memory-budget` ResourceQuota 释放后，才允许下一步创建 Agent。配额拒绝是并发保护信号，不得通过提高总配额或并发绕过。

当前临时 Agent 中 Nexus 集群内部服务地址不能作为依赖解析前提。Maven 与 pnpm 使用当前已验证的 Nexus NodePort：`http://192.168.253.128:30081/repository/maven-public/` 和 `http://192.168.253.128:30081/repository/npm-public/`。变更网络地址后必须重跑原失败构建，确认 Maven 能下载父 POM、pnpm 能解析依赖；不能只以浏览器访问或 Service 存在作为通过证据。

`02-nms4pos-ui` 的 Node 容器必须声明 requests `1 CPU/2Gi`、limits `4 CPU/4Gi`，并保持已验证的串行 Terser 压缩配置，避免构建期间 cgroup OOM。`03-nms4pos` 的 Maven 容器必须以 `runAsUser: 0` 写入单节点 hostPath `/var/lib/jenkins-package-output/backend/01-nms4pos-java`；Jenkins Agent 仍保持非 root。原因是 `00-clean` 以 root 重建该目录，普通 UID 无法创建发布子目录。该 hostPath 仅适用于当前单节点开发虚拟机。

2026-08-16 复验结果：`00-clean #8`、`01-nms4cloud #6`、`02-nms4pos-ui #5`、`03-nms4pos #5` 均为 `SUCCESS`。随后递归盘点的 13 条可见 Jenkins 流水线最新构建全部为 `SUCCESS`，无运行或排队任务。构建链路中使用 `SKIP_TESTS=true` 的步骤未运行 Maven 测试，不能作为测试质量验收。

`local-path` 数据位于单机磁盘，只能防止 Pod 重建丢失，不能防止虚拟机或磁盘损坏。安装重要业务应用前，必须建立虚拟机快照之外的定期数据备份。

### 9.3 业务 DNS 与重启恢复

K3s Pod 的 resolver 使用 `ndots:5` 且包含 `localdomain` 搜索域。未带结尾点的完整服务名会被追加搜索域，在本环境曾解析到 `198.18.*` 而非 Kubernetes Service IP。部署前和故障恢复时从业务 Pod 执行：

```bash
kubectl exec -n lgy deploy/nms4cloud-platform -- sh -c \
  'getent hosts nacos.nacos.svc.cluster.local.; getent hosts redis.lgy.svc.cluster.local.; getent hosts rocketmq-nameserver.lgy.svc.cluster.local.'
```

结果必须分别为对应 Service 的 ClusterIP。若不一致，停止重启业务应用，先修复 `lgy/nacos-client` ConfigMap 和 Nacos 共享配置中的地址；随后按 `platform -> gateway -> 其余业务服务` 串行滚动重启。回滚方式是恢复 ConfigMap 与 Nacos 配置中上一次已验证的地址，再按相同顺序重启。

本次虚拟机扩容后已验证总内存为 19Gi、可用内存大于 10Gi；`nms4cloud-mall`、`nms4cloud-wechat`、`rocketmq-console` 维持副本数 0 以保留业务核心服务余量。需要恢复时将相应 Deployment 副本数改回 1，并重新执行资源和业务验收。

`nms4cloud-pos11report` 当前通过单节点 `hostPath` 挂载 JAR 运行，属于临时交付方式；目标状态是 Harbor 中有可回滚的不可变数字镜像标签。报表依赖 ClickHouse；当前已在 `lgy` 部署单副本 ClickHouse，使用 `clickhouse-data` 20Gi `local-path` PVC、ClusterIP `8123` 和兼容物理机访问的 NodePort `30793`。报表服务必须使用 `clickhouse.lgy.svc.cluster.local.:8123`，不得从 Pod 访问物理机 NodePort。

ClickHouse 的部署资源为 `250m/512Mi` request、`1 CPU/1Gi` limit。安装后必须验证 `GET http://192.168.253.128:30793/ping` 返回 `Ok.`、PVC 为 `Bound`、报表路由返回非 5xx。该实例是单节点持久化部署，`local-path` 不提供节点或磁盘故障保护，重要报表数据需另行备份。

### 9.4 ClickHouse 备份恢复

`数据库备份/<timestamp>` 中的 `manifest.tsv` 是恢复清单，SQL 文件包含建表和数据。恢复目标库必须为空；恢复脚本会拒绝覆盖已有表。脚本会按清单逐表恢复并比对 `count()` 与备份行数，任何一张表不一致即停止：

```bash
tar -a -c -f clickhouse-backup.zip -C 数据库备份 <timestamp>
# 上传并在虚拟机解压后：
bash restore-clickhouse-backup.sh <unpacked-backup-dir>/<timestamp>
```

恢复 `20260814181609` 备份时，`bi` 与 `reportcenter` 共 72 张表均已完成行数校验。恢复脚本从 `lgy/clickhouse-secrets` 读取密码，不回显密码；不得把密码放入备份、SQL、命令记录或文档。

## 十、明确不安装的组件

当前个人开发基线不安装：

- cert-manager（Rancher 不使用由 cert-manager 管理的 Ingress 证书）；
- Traefik、ServiceLB 和 Ingress；
- Harbor Trivy；
- 集中式外部密钥服务及其 Kubernetes 同步控制器（当前由受控的 Kubernetes Secret 管理密码）；
- Prometheus、Grafana、日志平台和其他常驻可观测性套件；
- 未被实际使用的 Jenkins 插件、常驻构建 Agent 和额外 NodePort。

后续只有出现明确需求、计算过资源预算并保留 K3s 稳定余量后，才能新增常驻组件。
