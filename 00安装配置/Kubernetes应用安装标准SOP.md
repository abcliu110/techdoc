# Kubernetes 应用安装标准 SOP

## 1. 核心结论

K3s 控制面不需要提前知道应用密码。密码明文只允许出现在创建或更新 Kubernetes Secret 的命令或脚本中；每个应用密码必须先写入该应用 namespace 中的 Kubernetes Secret。Helm values 和工作负载清单只能引用该 Secret 的名称和键名。应用清单引用了某个 Secret 时，该 Secret 必须在 Pod 或 Helm 配置 Job 创建前存在，否则工作负载会启动失败。

固定安装顺序：

```text
K3s/Helm 就绪
  -> namespace 与平台前置资源
  -> 必需的 Secret/ConfigMap
  -> 模板与服务端校验
  -> 安装应用
  -> 资源、认证和业务验收
  -> 备份与恢复验证
```

## 2. 安装前对象决策

| 对象 | 何时创建 | 判断规则 |
|---|---|---|
| Namespace | 应用前 | 平台组件使用官方要求、官方推荐或企业批准的独立 namespace；只有同环境、同责任团队、同安全与生命周期边界的业务应用才共享 namespace |
| Secret | 视引用方式决定 | `existingSecret`、`secretKeyRef`、私有镜像、外部 TLS 引用必须预建 |
| ConfigMap | 应用前 | Deployment/Chart 引用且不会自行创建时预建 |
| CRD | 应用前 | 安装 Operator 或包含自定义资源前先建立 CRD |
| ServiceAccount/RBAC | 应用前 | 应用需要访问 Kubernetes API 时按最小权限创建 |
| StorageClass | 应用前 | PVC 使用的 StorageClass 必须存在；PVC 通常由 Chart/清单创建 |
| TLS Secret | 应用前或由控制器创建 | 外部证书预建；cert-manager 等控制器管理时由控制器创建 |
| ImagePullSecret | 应用前 | 镜像仓库需要认证时预建并绑定 ServiceAccount/Pod |
| Service/Ingress/NodePort | 随应用安装 | 由 Chart/清单声明，安装前先确认端口、域名和证书 |
| 应用内部账号、仓库、Project | 应用启动后 | 通过应用 API 或管理页面创建，不属于 Kubernetes 资源 |

不要为“以后可能用到”预建 Secret。只有清单明确引用、镜像拉取需要或恢复方案要求时才创建。

## 3. Secret 三类模型

### 3.1 必须预建

Chart/Deployment 通过 `existingSecret` 或 `secretKeyRef` 引用。Secret 不存在时，Pod 会进入 `CreateContainerConfigError`，或 Helm 配置 Job 失败。

要求：

- Secret 与工作负载位于同一 namespace；
- values 只保存 Secret 名称和键名；
- 密码明文仅允许出现在创建或更新该 Secret 的命令或脚本中；禁止在 values、普通 YAML、`--set` 参数或连接串中写入密码明文或 Base64 值；
- 安装前校验 Secret、必需键和非空状态，不输出值；
- 普通升级同时保留 Secret 与 PVC。

### 3.2 应用或 Chart 自动创建

Chart 不支持外部 Secret 引用时，禁止改在 values 中传入密码。应选择支持已有 Secret 的 Chart/版本，或通过部署后的受支持 API 从预建 Secret 同步；不能满足时，该安装方案不合规，不得上线。

### 3.3 应用启动后创建

Harbor Robot、Nexus 部署用户、Jenkins Credentials 等对象位于应用自身数据库中。必须等待应用 Ready 后通过 API 或管理页面创建，不能提前伪装成 Kubernetes Secret。

## 4. 标准执行步骤

### 4.1 盘点

1. 固定应用、Chart、镜像和 Kubernetes 版本。
2. 确认 namespace、资源预算、端口、DNS、TLS 和网络访问范围。
3. 确认 PVC、StorageClass、备份路径和删除后的数据影响。
4. 从 Chart 官方 values 和模板确认 Secret 参数，禁止按名称猜测。

### 4.2 创建前置资源

1. 创建 namespace。
2. 创建应用明确引用的 Secret、ConfigMap、RBAC、TLS 和 ImagePullSecret。
3. 只输出资源名、键名和检查结果，不输出 Secret 值。
4. 已有 PVC/数据库但对应 Secret 缺失时停止，不生成新密码。

### 4.3 安装前校验

Helm 应用：

```bash
helm template <release> <chart> -n <namespace> --version <version> -f <values> \
  | kubectl apply --dry-run=server -f - >/dev/null
```

原生清单：

```bash
kubectl apply --dry-run=server -f <manifest>
```

必须同时检查：固定版本、Secret 引用、资源限制、PVC、Service、探针和安全上下文。

### 4.4 安装

```bash
helm upgrade --install <release> <chart> \
  -n <namespace> \
  --version <version> -f <values> \
  --atomic --timeout 15m
```

原生清单使用 `kubectl apply -f`。任一步失败立即停止，先读事件和日志，不删除 PVC 重试。

### 4.5 验收

资源验收：

```bash
kubectl get deployment -n <namespace> -o name | xargs -r -n1 kubectl rollout status -n <namespace> --timeout=15m
kubectl get statefulset -n <namespace> -o name | xargs -r -n1 kubectl rollout status -n <namespace> --timeout=15m
kubectl get pods,pvc,svc -n <namespace>
kubectl get events -n <namespace> --field-selector type=Warning --sort-by=.lastTimestamp
```

业务验收必须另外完成：管理员登录、API 认证、制品上传下载、数据库查询或应用核心操作。Pod Ready 不能代替业务成功。

### 4.6 升级与重装

- 升级前重新执行模板、Secret、PVC 和备份检查；
- 固定版本升级，不使用未固定的 latest；
- 有状态应用同时保留 Secret 与 PVC；
- Secret 或持久化状态缺失时停止，备份后重装，不猜密码、不直接改数据库；
- 重装后重新执行资源和业务验收。

## 5. 当前环境映射

平台组件不共用笼统的 `infra` namespace，也不省略 `-n` 落入 `default`。Rancher 使用官方要求的 `cattle-system`，Jenkins 使用官方安装指南推荐的 `jenkins`，Harbor、Nexus、Nacos 和 MySQL 使用本环境批准的企业约定 namespace。业务应用只有在同环境、同责任团队、同安全等级和同生命周期时才可以共享业务 namespace。

| 应用 | Namespace | 命名依据 | 安装前必须存在 | 安装后创建 |
|---|---|---|---|---|
| Jenkins | `jenkins` | 官方安装指南推荐 | `jenkins/jenkins-admin` | Jenkins Credentials、Job |
| Harbor | `harbor` | 企业约定 | `harbor/harbor-admin` | Project、Robot Account、保留策略 |
| Nexus | `nexus` | 企业约定 | `nexus/nexus-admin` | Maven 仓库、角色、部署用户 |
| Nacos | `nacos` | 企业约定 | `nacos/nacos-auth`、`nacos/nacos-admin`、首次 `nacos/nacos-bootstrap-admin` | 控制台密码由同步脚本设置，成功后删除 bootstrap Secret |
| MySQL | `mysql` | 企业约定 | `mysql/mysql-auth` | 业务库表和额外用户 |
| Rancher | `cattle-system` | 官方要求 | `cattle-system/rancher-admin` | Chart 不传密码；部署后同步脚本通过受支持 API 写入该 Secret 的值并删除一次性 bootstrap Secret |

当前环境统一运行 `k3s-infra-secrets-init.sh`，创建六个产品 namespace，并通过一次隐藏输入把相同的长期管理员密码分别写入 Jenkins、Harbor、Nexus、Nacos、MySQL 和 Rancher 的管理员 Secret。脚本必须在不解码、不回显值的前提下确认各管理员密码键一致，才能继续安装。Nacos 服务认证 Token、Harbor Robot Token、Jenkins 外部凭据和一次性 bootstrap Secret 不属于长期管理员密码，必须保持独立。Rancher、Nacos 就绪后必须执行各自的 Secret-to-API 同步脚本并完成认证验收。

### 5.1 集群内服务地址与显式 Namespace

跨 namespace 依赖必须使用 Kubernetes Service 的绝对 FQDN，并在清单或命令中显式指定目标 namespace。对于本环境的 Nacos、Redis、RocketMQ，地址必须带结尾点，避免 `ndots` 和搜索域把完整名称解析为外部地址。应用 ConfigMap 单独执行 `kubectl apply -f` 时必须添加 `-n <namespace>`，或在清单中设置 `metadata.namespace`；不得依赖当前上下文，更不得误落入 `default`。

变更共享 ConfigMap 或 Nacos 配置后，先串行滚动重启依赖服务并等待每个 Deployment 可用，再继续下一个。出现服务发现、Redis 或 RocketMQ 连接失败时，先对比普通名称和带结尾点名称的 `getent hosts` 结果；不要重装 CoreDNS、删除 PVC 或反复重启作为替代修复。

## 6. 禁止事项

- 把 Jenkins、Harbor、Nexus、Nacos、MySQL 等独立平台组件统一放入 `infra` 或 `default` namespace；
- 仅因都属于“业务”就共享 namespace；共享前必须确认环境、责任团队、安全等级和生命周期一致；
- 在 values、YAML、文档、Git、`--set` 参数、连接串或 Base64 字段中写密码；
- 安装前未在应用同 namespace 创建 Secret，或让 values 直接保存密码而非只引用 Secret 名称与键名；
- 清单引用 Secret，但依赖应用启动后再补建；
- 只修改 Secret 后重启有状态应用；
- 为解决认证失败删除 PVC；
- 用 Pod Running/Ready 代替登录和业务验收；
- 未备份就重装有状态应用。
