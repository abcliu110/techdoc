# K3s 基础设施 Values 说明

Helm values 必须保持 Chart 专属，Jenkins、Nexus、Harbor 和 Rancher 分别使用以下配置：

| Chart/对象 | Namespace | 配置文件 | 版本或用途 |
|---|---|---|---|
| Jenkins | `jenkins` | `k3s-jenkins-values.yaml` | `jenkins/jenkins` `5.9.53` |
| Nexus | `nexus` | `k3s-nexus-values.yaml` | `stevehipwell/nexus3` `5.24.1` |
| Nexus NodePort | `nexus` | `k3s-nexus-nodeport.yaml` | Kubernetes Service 清单 |
| Nexus 应用初始化 | `nexus` | `nexus-application-bootstrap.sh` | REST API 可重复创建缺失的 Maven 仓库、角色和部署用户 |
| Harbor | `harbor` | `k3s-harbor-values.yaml` | `harbor/harbor` `1.19.2` |
| Harbor 应用初始化 | `harbor` | `harbor-application-bootstrap.sh` | REST API 幂等创建 Project、Robot Account 和保留策略 |
| 平台验收 | 全部产品 namespace | `k3s-platform-check.sh` | 固定版本、Pod、PVC 和资源状态检查 |
| Rancher | `cattle-system` | `k3s-rancher-values.yaml` | `rancher-latest/rancher` `2.15.0` |
| Rancher NodePort | `cattle-system` | `k3s-rancher-nodeport.yaml` | Kubernetes Service 清单 |
| Nacos | `nacos` | `k3s-nacos.yaml` | Nacos `3.2.3-slim` standalone 清单 |
| MySQL | `mysql` | `k3s-mysql.yaml` | MySQL `8.4.7` LTS 单实例清单 |

Namespace 命名依据必须区分：Rancher 的 `cattle-system` 是官方要求，Jenkins 的 `jenkins` 是官方安装指南推荐；Harbor、Nexus、Nacos 和 MySQL 的产品同名 namespace 是本环境批准的企业约定，不是 Chart 强制的产品默认值。所有安装命令仍须显式指定 namespace，禁止因 Chart 未强制而落入 `default`。

禁止创建跨 Chart 的合并 values 文件，也不得把多个 Chart 的顶层键合并到同一个 YAML；重复的 `persistence`、`serviceAccount` 等键会互相覆盖。

本个人开发基线保留 K3s、CoreDNS、local-path、metrics-server，以及用户明确需要的单副本 Rancher；关闭 cert-manager、Traefik、ServiceLB、Ingress 和 Harbor Trivy。Rancher 通过固定 NodePort 访问，不恢复 Ingress 链路。本次虚拟机实际为 `12 vCPU / 16 GB`；资源紧张时最低可用基线为 `8 vCPU / 16 GB`。当前基础设施必须设置 requests/limits，为后续应用保留至少 4 vCPU 和 6 GiB 的稳定余量。

Nacos 只使用一个 standalone Pod 和一个 `5Gi` PVC，保留 Web 控制台、8848 HTTP API 和 9848/9849 gRPC 端口；Nacos 自身不依赖 MySQL，也不安装集群副本、监控或 Ingress。Nacos 认证 token 通过 `nacos-auth` Secret 注入。

共享 MySQL 独立使用一个单实例 Pod 和一个 `10Gi` PVC，通过 NodePort `30306` 提供外部 TCP 访问，关闭 Performance Schema 并限制连接数与缓冲池；不安装 MySQL 集群、Exporter、phpMyAdmin 或 Ingress。应用密码与 root 密码通过 `mysql-auth` Secret 注入。

K3s 控制面不依赖应用 Secret。K3s 和 Helm 就绪后、安装任何应用前，运行 `k3s-infra-secrets-init.sh` 创建 `jenkins`、`harbor`、`nexus`、`nacos`、`mysql`、`cattle-system` namespace，并在各产品 namespace 创建和校验对应 Secret。六个应用的长期管理员密码来自同一次隐藏输入，分别保存到各自 Secret；脚本只比较编码数据是否一致，不解码或回显密码。Nacos 服务认证 Token、Harbor Robot Token、Jenkins 外部凭据和一次性 bootstrap Secret 保持独立。密码明文只允许出现在创建或更新该 Secret 的命令或脚本中；应用只能引用同 namespace 的预建 Secret。密码不写入 values、Deployment、普通 YAML、`--set`、文档或 Git，values 和 Deployment 只保存 Secret 名称与键名。Chart 不支持外部 Secret 时不得用 values 明文绕过，必须选择支持该能力的版本或在部署后通过受支持 API 同步。

通用的应用安装前置对象、Secret 分类和验收顺序见 [Kubernetes应用安装标准SOP.md](Kubernetes应用安装标准SOP.md)。

| 应用 | Kubernetes Secret | 配置引用 | 运行时密码状态 |
|---|---|---|---|
| Jenkins | `jenkins/jenkins-admin` | `controller.admin.existingSecret` | JCasC 按 Secret 同步管理员密码 |
| Harbor | `harbor/harbor-admin` | `existingSecretAdminPassword` | Secret 用于部署和全新数据库初始化；现有密码在 Harbor 数据库中 |
| Nexus | `nexus/nexus-admin` | `rootPassword.secret` 注入初始密码 | 初始化后管理员密码在 Nexus PVC 中；Secret 与 PVC 必须一起保留 |
| Rancher | `cattle-system/rancher-admin` | Chart 不传密码；`rancher-admin-password-sync.sh` 通过 API 同步 | 同步成功后删除 Chart 自动创建的 `bootstrap-secret` |
| Nacos | `nacos/nacos-auth`、`nacos/nacos-admin` | 服务认证通过 Deployment `secretKeyRef`；控制台密码由同步脚本通过 API 设置 | 同步成功后删除 `nacos-bootstrap-admin` |
| MySQL | `mysql/mysql-auth` | Deployment `secretKeyRef` | 只用于空数据目录初始化；现有用户密码在 MySQL 系统表中 |

因此，Kubernetes Secret 是部署输入和恢复材料的受控来源，但不是所有有状态应用的实时密码数据库。Harbor、Nexus 轮换管理员密码后必须同步各自的管理员 Secret；已有 MySQL 只有在未来全新初始化也应沿用该密码时才同步 `mysql-auth`。Rancher 和 Nacos 的管理员密码由独立管理员 Secret 与受支持 API 同步；不得错误覆盖 Rancher 的引导 Secret 或 Nacos 的服务认证 Secret。不能只修改 Secret 后重启 Pod。

工作原理、安全边界和轮换顺序见 [Kubernetes-Secret密码管理原理与边界.md](Kubernetes-Secret密码管理原理与边界.md)。

## 应用级配置与 Helm 的边界

Helm 只负责安装和升级 Nexus、Harbor 的 Kubernetes 资源、版本、Service、PVC 和资源限制；它不负责完整声明应用数据库中的仓库、用户、Project、Robot Account 或保留策略。当前 REST API 脚本用于可重复引导缺失对象，不等同于完整的期望状态控制器。

| 应用 | Helm values 管理 | 应用级初始化任务应管理 |
|---|---|---|
| Nexus | 镜像、PVC、Service、JVM、资源、管理员 Secret 引用 | 当前脚本创建缺失的 Maven hosted/group 仓库、部署用户和角色；Blob Store 与清理策略需另行评审 |
| Harbor | 版本、NodePort、TLS、PVC、资源、管理员 Secret 引用 | Project、Robot Account、项目权限、Proxy Cache、保留策略、配额 |

初始化任务只从 Jenkins Credentials 或 Kubernetes Secret 读取凭据；配置仓库只保存仓库名、Project 名和权限等非敏感期望状态。任务必须可重复执行：已存在对象执行更新或跳过，不得每次重新创建账号或覆盖运行时密码。

`harbor-retention-library.json` 是 Harbor API 请求体，不会被 Helm 自动应用。应用前必须通过 Harbor API 按项目名称查询当前 Project ID，不能假定 `scope.ref` 永远为 `1`。首次部署验收必须证明 `library` Project、推送 Robot Account、Nexus Maven 仓库和 Jenkins 使用的凭据 ID 均已存在并可完成一次真实发布。

Jenkins Chart `5.9.53` 的 `controller.admin.createSecret: true` 必须与 `existingSecret: jenkins-admin` 一起保留；在该版本中它还负责挂载管理员 Secret。详细的安装、密码变更、重部署行为矩阵、验收和资源门禁以 [VMware+K8s安装配置.md](VMware+K8s安装配置.md) 为准。
