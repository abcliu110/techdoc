# VMware + K8s 安装门禁与验收 SOP

## 1. 使用边界

本 SOP 只负责当前单节点 VMware/K3s 环境的安装门禁、停止条件和验收记录。实际安装命令、固定版本、values、YAML 和脚本以 [VMware+K8s安装配置.md](VMware+K8s安装配置.md) 为唯一来源；本 SOP 不复制这些命令。

通用 Secret、namespace、PVC 和认证规则以 [Kubernetes应用安装标准SOP.md](Kubernetes应用安装标准SOP.md) 为准。

执行顺序固定为：

```text
虚拟机/IP门禁 -> SSH授权门禁 -> K3s 门禁 -> 文件门禁 -> namespace/Secret 门禁
-> 服务端预检 -> 分阶段安装 -> 资源验收 -> 认证验收
-> 业务验收 -> Jenkins 多分支流水线门禁 -> 重启验收
```

任一门禁失败立即停止。不得跳过失败步骤继续安装，不得删除 PVC 作为重试手段，不得在报告中把命令执行成功当作业务验收成功。

## 2. 门禁一：虚拟机、SSH 与 K3s

先执行主安装文档 2.2 和 2.3，确认虚拟机身份、IP 和 SSH 主机指纹。系统还原后，必须先从 VMware 控制台取得 ED25519 SHA256 主机指纹，按主安装文档与 `ssh-keyscan` 结果逐字符比对并登记 `known_hosts`；只有一致后才能执行下列授权和密钥复验命令。删除旧记录、交互接受未知指纹或仅凭 IP/22 端口可达均不能证明主机身份。

```powershell
Get-NetNeighbor -IPAddress 192.168.253.128
Test-NetConnection 192.168.253.128 -Port 22 -InformationLevel Detailed
& 'D:\mywork\techdoc\00安装配置\ssh-authorize-key.ps1'
Remove-Item Env:SSH_TOOL_PASSWORD -ErrorAction SilentlyContinue
python 'D:\mywork\techdoc\00安装配置\ssh_tool.py' cmd "id -un; hostname; ip -brief address show ens33"
```

SSH 门禁通过后，才在虚拟机内执行主安装文档的系统初始化和 K3s 安装步骤。满足以下条件后才能进入下一门禁：

首次公钥引导必须使用 `ssh-authorize-key.ps1` 的 `SecureString` 交互输入。不得在脚本、文档、命令行或持久环境变量中保存 SSH 密码；公钥引导通过后，后续操作必须使用 `ssh_tool.py` 的密钥认证。

```bash
set -Eeuo pipefail
command -v kubectl
command -v helm
command -v jq
command -v curl
command -v openssl
kubectl get nodes -o wide
kubectl wait --for=condition=Ready node --all --timeout=180s
kubectl get storageclass local-path
kubectl top node
df -h /var/lib/rancher/k3s/storage
```

通过条件：

- `192.168.253.128` 的 MAC、虚拟机身份和主安装文档一致，虚拟机停止时不得由其他设备继续占用该地址；
- 22 端口监听，`ssh_tool.py` 在未设置 `SSH_TOOL_PASSWORD` 时使用默认私钥成功登录为 `lgy`；
- `/home/lgy/.ssh` 权限为 `700`，`authorized_keys` 权限为 `600`，公钥指纹与本机 `id_rsa.pub` 一致；
- 所有节点为 `Ready`；
- `local-path` StorageClass 存在；
- Metrics 可用；
- K3s 存储目录有足够空间；
- 虚拟机 IP、默认路由、DNS 和时间同步符合主安装文档当前值。

停止条件：IP/MAC 不一致、22 端口未监听、密码引导失败、纯密钥复验失败或连接到了其他主机时立即停止。不得跳过 SSH 门禁继续上传或安装，也不得把登录密码、公钥内容或完整认证日志写入验收记录。

## 3. 门禁二：安装文件

按主安装文档上传文件后，在虚拟机内确认所有实际引用的文件存在。至少包括：

```text
k3s-rancher-values.yaml
k3s-rancher-nodeport.yaml
rancher-admin-password-sync.sh
k3s-jenkins-values.yaml
k3s-gitea-values.yaml
k3s-nexus-values.yaml
k3s-harbor-values.yaml
k3s-nexus-nodeport.yaml
k3s-nacos.yaml
k3s-mysql.yaml
k3s-registries.yaml
k3s-infra-secrets-init.sh
k3s-platform-check.sh
nacos-admin-password-sync.sh
nexus-application-bootstrap.sh
nexus-eula.json
jenkins-credential-upsert.sh
jenkins-home-backup.sh
harbor-application-bootstrap.sh
harbor-retention-library.json
```

在检查文件后统一设置脚本权限并确认文件非空：

```bash
for file in \
  k3s-infra-secrets-init.sh k3s-platform-check.sh \
  rancher-admin-password-sync.sh nacos-admin-password-sync.sh \
  nexus-application-bootstrap.sh jenkins-credential-upsert.sh jenkins-home-backup.sh harbor-application-bootstrap.sh; do
  test -s "/tmp/$file"
  chmod 700 "/tmp/$file"
done
```

通过条件：

- 文件名、路径和主安装文档引用完全一致；
- 上述 Shell 脚本存在、非空，权限必须为 `700`，group/other 不得拥有任何权限；
- values 和 YAML 使用主安装文档固定版本；
- 不存在密码、Token、Base64 密码值或连接串明文；
- 不得用未审核的最新 Chart 或镜像替换固定版本。

## 4. 门禁三：namespace 与 Secret

运行主安装文档 7.1 的 Secret 初始化步骤。`k3s-infra-secrets-init.sh` 按本环境明确批准的例外使用统一管理员密码；受控自动化可临时使用 `PLATFORM_ADMIN_PASSWORD` 注入或覆盖，执行后必须清除。该明文例外仅限创建或更新 Kubernetes Secret 的脚本/命令，本文档、values、工作负载 YAML、连接串和普通配置仍禁止保存密码：

```bash
bash /tmp/k3s-infra-secrets-init.sh
bash /tmp/k3s-platform-check.sh preflight
```

通过条件：

- 存在 `jenkins`、`gitea`、`harbor`、`nexus`、`nacos`、`mysql`、`cattle-system` 七个 namespace；
- 七个长期管理员密码来自脚本内获批的默认值或受控的临时 `PLATFORM_ADMIN_PASSWORD` 覆盖值，Secret 中对应键的编码值必须一致；
- Secret 必需键存在且非空，验收过程不解码、不回显值；
- Nacos 服务认证 Token、Harbor Robot Token、Jenkins 外部凭据和一次性 bootstrap Secret 保持独立；
- Secret 缺失但对应 PVC、数据库或 Release 已存在时，脚本必须失败并停止；
- 所有应用使用显式 namespace，不得落入 `default`。

## 5. 门禁四：Kubernetes 服务端预检

在 Secret 门禁通过后，执行主安装文档 7.1 末尾的完整预检块。该预检必须同时覆盖：

- Jenkins、Gitea、Nexus、Harbor、Rancher 五个固定版本 Helm 渲染结果；
- Nexus NodePort、Rancher NodePort、Nacos 和 MySQL 四个原生 YAML；
- Secret 引用、namespace、PVC、Service、探针、资源限制和安全上下文。

通过条件：

- 所有 `helm template` 管道和 `kubectl apply --dry-run=server` 返回零；
- 不存在未知 namespace、缺失 Secret、无效字段、端口冲突或 API 版本错误；
- 任一预检失败时，不得运行任何应用安装命令。

### 5.1 已部署组件与业务 namespace 门禁

执行应用整理前，必须确认以下组件已有且只复用一份：Rancher、Gitea、Jenkins、Nexus、Harbor、Nacos、MySQL 和 K3s 系统组件。发现同名 Release、PVC 或 Service 时，禁止再次 apply 对应 `base/` 文件。

本次业务应用只允许进入 `lgy` namespace，使用 `应用整理/bundles/lgy-business.yaml` 作为候选入口。Kafka 永不部署；ClickHouse、RocketMQ、EMQX、ZooKeeper、XXL-JOB 需要单独依赖确认后才能启用。

Gateway 的产品归属必须以运行镜像二进制为准，不能依据历史 YAML、镜像仓库域名或服务名推断。已核对的原服务器运行镜像在 `/app.jar` 中包含 `spring-cloud-starter-gateway-4.1.0.jar` 和 `spring-cloud-gateway-server-4.1.0.jar`，因此其基础框架为 Spring Cloud Gateway 4.1.0，而非阿里巴巴 Gateway 产品。该事实不授权直接复用原腾讯 CCR 地址或 `latest` 标签。`lgy` 已部署通用启动器，Deployment 使用 Harbor 的 `library/yd4cloud-gateway:1`；`latest` 只用于确认同一 digest，不得部署。

通过条件：

- `lgy` namespace 已存在且业务 Deployment 的 `metadata.namespace`、Pod template namespace 和 Secret 引用均属于 `lgy`；
- Nacos 只引用现有 `nacos.nacos.svc.cluster.local:8848`，MySQL 只引用现有 `mysql.mysql.svc.cluster.local:3306`，不存在第二套 Nacos/MySQL；
- Harbor、Jenkins、Nexus、Gitea 的现有 PVC、Release 和 Service 未被业务清单覆盖；
- 所有密码只来自 `lgy` namespace 的预建 Secret，Secret 键名与现有平台约定一致；YAML、ConfigMap、values、连接串和 Git 中不存在密码明文；
- 所有业务镜像均来自 Harbor，官方基础镜像通过 Harbor Proxy Cache；不存在腾讯 CCR、旧 `10.43.*` 地址或公网直拉地址；
- Nginx 所需 ConfigMap、`/home/lgy/nginx-static` hostPath 和 NodePort Service 已独立声明，并通过 `kubectl apply --dry-run=server`；该目录挂载到 `/usr/share/nginx/html`，初始化容器固定设置目录权限为 `755`，并仅在 `index.html` 缺失时初始化默认页面。物理机通过 SFTP 以 `lgy` 用户上传静态文件；此 hostPath 只适用于当前单节点个人开发虚拟机，不得复制到多节点或生产集群。现有 `nginx-static` PVC 暂不删除。Nginx 仅在 VMware NAT 开发网段通过 `30090` 提供 HTTP 访问，不创建 hostPort，使用 Harbor Proxy Cache 中的固定官方版本，不得使用 `latest`。
- Redis、EMQX 和 RocketMQ 如需启用，必须使用 `lgy` namespace、ClusterIP Service 和资源 requests/limits。当前 EMQX 5.4.1 复用单一 `emqx` Pod，`emqx54:8083` 仅作为其 WebSocket 内部 Service；不得部署第二个 broker 或暴露 NodePort。Redis 密码只允许引用 `lgy/redis-auth`，不得使用旧 YAML 的明文密码或 `hostPort`；RocketMQ 按 NameServer、Broker、Console 顺序部署，并验证 Broker 已注册到 NameServer。
- 通用 Gateway 的运行时安装已完成：`25m/128Mi` requests、`250m/256Mi` limits，实测运行内存约 `212Mi`。验收必须包含服务端 dry-run、rollout、Ready Endpoint、`/actuator/health/readiness` 返回 `UP`、Pod 零重启和节点资源复核。启动阶段的探针告警必须在 Pod Ready 后再次核对，不能单独作为持续故障结论。
- Gateway 业务路由仍保持后置，直至同时满足：当前 Nacos 路由配置已从运行实例读取并完成业务路由核对；配置中所有凭据仍只引用 `lgy` Secret；最小业务路由请求通过。历史配置导出、腾讯 CCR 地址或 `latest` 镜像均不能替代这些验收项。

## 6. 门禁五：分阶段安装

严格按主安装文档的当前章节逐个执行，不得并行安装。每阶段完成后先通过资源门禁，再进入下一阶段：

| 阶段 | 应用 | 必须完成的动作 |
|---|---|---|
| 1 | Rancher | Helm 安装、NodePort、管理员密码 API 同步、Rancher/Fleet/本地集群 Ready、真实管理员认证 |
| 2 | Gitea | Helm 安装、HTTP/SSH NodePort、PVC、管理员登录、仓库导入验收 |
| 3 | Jenkins | Helm 安装、init 容器成功、StatefulSet Ready、网页登录 |
| 4 | Nexus | Helm 安装、NodePort、EULA `accepted=true`、应用配置初始化、`nexus-deployer` 真实制品发布与查询 |
| 5 | Harbor | Helm 安装、Registry 配置、Project/Robot/保留策略初始化、Robot 自动导入 Jenkins、真实镜像推送与查询、临时凭据删除 |
| 6 | Nacos | 原生 YAML 安装、管理员密码 API 同步 |
| 7 | MySQL | 原生 YAML 安装、Deployment Ready、数据库认证 |

每个阶段完成后必须立即执行当前应用的阶段门禁，不得等到全部应用安装后再统一发现失败：

```bash
kubectl get pods,pvc,svc -n <namespace> -o wide
kubectl get events -n <namespace> --field-selector type=Warning --sort-by=.lastTimestamp
kubectl top node
```

Helm 应用还必须确认对应 Release 为 `deployed`，并对该阶段的 StatefulSet/Deployment 执行 `kubectl rollout status`；原生 YAML 应用直接执行对应 Deployment 的 rollout。通过条件固定为：当前应用长期 Pod 全部 `Running` 且 Ready，PVC 全部 `Bound`，Service/Endpoint 指向当前应用，没有持续增加的 Warning、探针失败、OOMKilled、挂载或调度失败，节点无压力且资源余量仍满足主文档要求。资源通过后还必须完成阶段表中的真实认证和业务动作；任何一项未通过都不得进入下一阶段。

Nginx 作为无状态独立工作负载，验收必须同时确认 `deployment/nginx` rollout 成功、Pod `1/1 Ready`、Service 的 EndpointSlice 指向 Ready Pod，以及 Nginx 访问日志存在 kubelet 对 `/` 的 HTTP `200` 探针记录。官方精简镜像不保证包含 `curl` 或 `wget`，容器内诊断命令缺失不构成 HTTP 验收失败；但不得以此替代前述四项证据。

Jenkins 使用持久化 PVC 时，`k3s-jenkins-values.yaml` 必须固定 `controller.initializeOnce: true` 和 `controller.overwritePlugins: false`。首次初始化成功后，PVC 根目录必须存在 `initialization-completed`；Pod 重新创建时 init 容器必须因该标记以 exit code `0` 结束，且 Pod 状态同时满足 `Initialized=True`、`Ready=True` 和 `2/2 Ready`。不得把 `initializeOnce` 改为 `false` 来重复安装插件：Chart 5.9.53 的 `apply_config.sh` 会以 `yes n | cp -i` 复制插件，init 容器重启时保留的 `emptyDir` 可使其因拒绝覆盖而退出非零并进入 CrashLoopBackOff。插件变更必须走主安装文档规定的测试 Jenkins、PVC 外部备份和受控升级流程。

Jenkins Helm 升级完成后立即执行：

```bash
kubectl rollout status statefulset/jenkins -n jenkins --timeout=20m
kubectl get pod jenkins-0 -n jenkins
kubectl get pod jenkins-0 -n jenkins -o jsonpath='{.status.conditions[?(@.type=="Initialized")].status}{" "}{.status.conditions[?(@.type=="Ready")].status}{"\\n"}'
kubectl logs jenkins-0 -n jenkins -c init --previous 2>/dev/null || true
kubectl get events -n jenkins --field-selector type=Warning --sort-by=.lastTimestamp
```

通过条件：StatefulSet rollout 成功，init 容器的最新一次结束状态为 `0`，不出现持续增加的 `BackOff` 或 `cp: overwrite`，且 Jenkins NodePort 登录页可访问。任一项失败时停止后续平台安装，保留 PVC 和日志；禁止通过删除 PVC 或无限重启 Pod 规避失败。

若历史 Release 在首次初始化完成前因上述复制缺陷 CrashLoop，且已确认 PVC 中同时存在 `secrets/master.key` 和 `plugins/`，可使用本目录的 `jenkins-pvc-repair-pod.yaml` 进行一次受控恢复：先将 `statefulset/jenkins` 缩容到 `0` 并确认原 Pod 已删除，再 apply 该修复 Pod。修复 Pod 只创建 `initialization-completed`，成功后必须删除该 Pod，升级 values 并重新执行本节验收。该步骤不得用于跳过真正的首次安装、插件升级、丢失配置或 PVC 损坏；任一前置检查失败即保留现场并停止。

分阶段停止条件：

- Helm `--atomic` 失败；
- Pod 不是 `Running` 且 Ready；
- PVC 不是 `Bound`；
- 探针持续失败、OOMKilled、调度失败或事件持续增加；
- Secret 与应用运行时密码不一致；
- 任何密码同步脚本验证失败。
- 当前阶段真实认证、业务动作或阶段资源门禁失败。

Nexus 初始化不得通过 Windows PowerShell 到远程 Bash 的 stdin 管道传密码。`nexus-application-bootstrap.sh` 启动时从 `nexus/nexus-admin` Secret 读取一次管理员密码；首次创建部署用户时只允许受控临时环境变量 `NEXUS_DEPLOYER_PASSWORD`，导入 Jenkins Credential 后立即清除。已认证请求不得自动重试。资源存在性检查只有 `200` 表示存在、`404` 表示不存在；出现 `401`、`403`、`429` 或其他非预期状态立即停止，不得修改资源或循环重试。

Nexus CE 的 EULA 是独立业务门禁。负责人明确授权后，按主安装文档使用 `NEXUS_ACCEPT_EULA=true` 和经过版本审核的 `/tmp/nexus-eula.json` 执行初始化脚本；脚本必须先 GET `/service/rest/v1/system/eula`，必要时 POST 固定 payload，再次 GET 并由 `jq -e '.accepted == true'` 验证。只有 EULA、应用初始化以及 `nexus-deployer` 的真实发布和查询全部通过，才能进入 Harbor；不得通过反复认证、删除 PVC 或重装规避。

Harbor Robot Account 初始化必须全程非交互，不得等待人工按回车。新建 Robot 后，一次性用户名和 Token 只能短暂保存在权限为 `600` 的 `/tmp/harbor-robot-credential.json`；自动化步骤必须立即将其导入 Jenkins Username with password 凭据 `harbor-robot`，使用该凭据完成真实登录、测试镜像推送和查询，然后删除临时文件。以下任一情况立即停止，不得进入 Nacos：Jenkins Credential 导入失败、真实推送/查询失败、临时文件未删除、Token 出现在日志或命令行、已有 Robot 但 Jenkins Credential 缺失或不可用。

### 6.0 Gitea 阶段验收

Gitea 安装完成后必须执行：

```bash
helm status gitea -n gitea
kubectl rollout status deployment/gitea -n gitea --timeout=15m
kubectl get pods,pvc,svc,endpointslice -n gitea -o wide
kubectl exec deployment/gitea -n gitea -- gitea --version | grep -F 'gitea version 1.27.0'
```

通过条件：

- Release 为 `deployed`，Gitea Deployment 和 Pod 为 Ready；
- `gitea-shared-storage` PVC 为 `Bound`，容量为 `20Gi`；
- HTTP `30087` 和 SSH `30088` 的 Service/Endpoint 只指向 Gitea Pod；
- `gitea-admin` Secret 的 `username/password` 存在且未回显，使用受控临时认证配置完成一次管理员 API 认证后立即删除该配置；
- Web 页面可使用 `admin` 登录，公开注册和匿名访问关闭；
- PostgreSQL、Valkey、Ingress 和 Actions 未部署；
- 从上游源码服务器完成一次完整迁移后，Gitea 中的默认分支、全部分支、标签和最新提交与上游一致；
- 迁移后不配置长期 Pull Mirror，Gitea 成为正式代码源。

任一项失败时停止 Jenkins 安装，保留 Gitea Release、PVC 和 Secret，先修复或回滚 Gitea。

## 6.1 Jenkins 多分支流水线门禁

平台服务、Jenkins 四项流水线凭据和 Nexus/Harbor 真实业务验收全部通过后，才能配置流水线。当前项目仓库没有 Jenkinsfile，推荐模式固定为 Remote Jenkinsfile Provider + Multibranch Pipeline；Job DSL + Seed Job 仅在 Provider 兼容性验证失败时作为回退，不得同时维护两套正式 Job 来源。

执行前确认：

- `k3s-jenkins-values.yaml` 固定包含 `remote-file:1.24`，Helm 渲染和服务端 dry-run 通过；
- 平台 Jenkinsfile 已提交到禁止直推和 force-push、强制双人审批的受保护 Git 分支或不可变版本，不是本机未提交文件；
- `jenkins-platform-readonly`、`gitea-scm-readonly`、`nexus-deployer` 和 `harbor-robot` 四项凭据均存在，检查时不得输出凭据值；
- Jenkins Pod 能通过 `http://gitea-http.gitea.svc.cluster.local.:3000/` 访问 Gitea；FQDN 末尾的 `.` 不得省略，避免搜索域导致解析到错误地址；
- Maven 与 POS 前端依赖解析必须使用从 Jenkins Agent 实测可达的 Nexus 地址。当前单节点 K3s 基线为 NodePort `http://192.168.253.128:30081/repository/maven-public/` 与 `http://192.168.253.128:30081/repository/npm-public/`；不得假定 `nexus.nexus.svc.cluster.local:8081` 在每个临时 Agent 中可用。验证 `npmjs-proxy` 与 `npm-public` 存在，查询 `pnpm` 元数据返回 `200`。当前基线不得创建或挂载独立 `maven-cache` PVC，临时 Agent 的 `.m2` 只作为本次构建目录；Node 容器只可挂载 `jenkins-pnpm-cache` 到 `/home/jenkins/.pnpm-store`，不得把缓存卷挂入业务 Deployment；
- 若物理机使用 Clash TUN/fake-IP 为虚拟机共享代理，必须单独验证 Kaniko 的 Registry 客户端；普通浏览器、`curl` 或 `wget` 成功不能替代该验证；
- 当前环境 Kaniko 使用物理机 VMware 网卡上的 Clash mixed proxy。`HTTP_PROXY` 和 `HTTPS_PROXY` 指向经虚拟机实测的显式代理地址，`NO_PROXY` 覆盖 Pod CIDR、Service CIDR、`.svc`、`.cluster.local`、K3s 节点、Harbor 和 Nexus；代理不得无差别注入所有 Jenkins 容器；
- Harbor Docker Hub Proxy 与 Kaniko 远程构建层缓存是两项独立能力。使用 Harbor Proxy 时验证基础镜像确实经过 Proxy；使用 `--cache=true` 时验证专用 cache 仓库、最小权限凭据和保留策略，禁止把两种链路混写；
- 业务 Dockerfile 保持原文，Java 基础镜像仍可写为 `FROM eclipse-temurin:21-jre`。Kaniko 1.23.2 对该写法使用 `index.docker.io`，受保护 Jenkinsfile 的每次 Kaniko 调用必须使用 `--registry-map="index.docker.io=192.168.253.128:30083/dockerhub"` 和 `--skip-default-registry-fallback`，由 Kaniko 将 Docker Hub 请求映射到 Harbor Proxy Cache；禁止为此修改业务源码或回退为 Docker Hub 直连。
- `gcr.io/kaniko-project/executor` 不属于 Docker Hub Proxy；未完成受控镜像同步或相应上游 Proxy 验证前，保持其现有来源。禁止把 `gcr.io` 镜像改写为 `dockerhub` 地址。
- `controller.initializeOnce: true`、`controller.overwritePlugins: false`，两个 latest 开关为 `false`，确保已有 PVC 只复用已验证的固定插件；首次成功初始化后必须存在 `initialization-completed` 标记；
- 已记录 Jenkins 当前 Helm revision、插件列表及校验值、现有 Job 和凭据 ID，并通过 `jenkins-home-backup.sh backup` 在 Controller 停止期间将完整 Jenkins Home 备份到 PVC 外；归档和 SHA-256 文件存在、校验通过、权限为 `600`。
- 平台 Jenkinsfile 的新增、恢复或迁移只能从远端目标分支克隆后创建候选分支和 PR；严禁对 Gitea 已有仓库使用 `git push --mirror`、`git push --all --force` 或其他会镜像删除远端 ref 的推送方式。
- 推送前已输出并审核 `git diff --name-status <remote-base>...<candidate>` 与目标分支 Jenkinsfile 清单；除已审批的删除外，不得存在 `D` 项、既有脚本路径丢失或文件数减少。
- 推送仅允许候选分支的精确 refspec；确认目标分支禁止直接 push 与 force-push，并按当前分支保护要求合并。当前授权策略的 `required_approvals=0`，仅允许 `admin` 合并；不得伪造审批、直接推送或 force-push。
- 业务镜像发布必须在同一次构建中产生不可变构建标签和同摘要的移动别名；Deployment 只允许引用不可变标签。移动别名缺失、两个标签 digest 不一致或流水线删除历史 artifact 均为 FAIL。标签语法以受保护 Jenkinsfile 为准：云服务为数字构建号与 `latest`，订单为 `<git-short-sha>-<build-number>` 与 `master-latest`。

### 6.1.1 `nms4cloud-order` 专用流水线验收

订单 Job 为 `build-nms4cloud-order-images`，项目仓库为 `admin/nms4cloud-order`，远程 Jenkinsfile 为 `admin/jenkins-platform` 的 `nms4cloud-order/Jenkinsfile`。订单流水线变更必须使用平台仓库 PR；当前已验证的删除逻辑修复为 PR #9，合并提交 `7e9b11f48aed83018bed46c810a3224e485c09f4`。

验收时必须确认订单 Jenkinsfile 不包含 `Retain Latest Harbor Artifact` 阶段、`retainLatestHarborArtifact` 函数或 Harbor artifact `DELETE` 请求。Harbor artifact 的清理只允许由项目级 Retention Policy 执行；发现流水线主动删除 artifact 时判定为 FAIL，并停止发布。

订单发布构建完成后，从 Harbor API 列出 `library/nms4cloud-order` 的 artifact 和标签，并分别对本次不可变标签与 `master-latest` 执行 Harbor API artifact 查询和 Registry manifest `HEAD` 查询。两个 API 路径均须返回 `200`，并且 `Docker-Content-Digest` 必须相同；任一 `404`、标签缺失或 digest 不同均为 FAIL。只看到 Kaniko 的 `Pushed` 日志不能替代该验收。

2026-08-16 已完成 `master #7` 回归：`fd2584554777-7` 和 `master-latest` 均指向 `sha256:d58743d94d80ecb9d8cd0a9a97a99f95dd1a64dc937512de447fb7395a158915`，Harbor API 与 Registry manifest 均返回 `200`，构建结果为 `SUCCESS`。该构建使用 `SKIP_TESTS=true`，Maven 测试未执行，不得把它记录为测试门禁通过。

当前 `library` 项目保留策略每日执行且只保留最新 `1` 个 artifact。该设置满足当前存储清理配置，但不提供多个历史构建的回滚窗口；需要保留更多可部署版本时，必须先批准并修改项目级 Retention Policy，再重新执行本节标签与 manifest 验收。

### 6.1.2 平台流水线固定提交与模块边界

每个 Multibranch Job 的 Remote Jenkinsfile 固定提交必须是 `admin/jenkins-platform` 目标分支可达的完整提交。Job 配置中的短 SHA 也必须通过一次真实脚本 checkout 验证；出现 `Couldn't find any revision to build` 时，先核对该固定提交是否仍可由目标分支获取，修复 Job 配置后重跑原失败分支。不得将 Jenkinsfile 复制回项目仓库绕过该检查。

云服务 Job 只构建和发布其明确列出的云服务应用模块。独立仓库已拥有专用流水线的服务不得同时由云服务 Job 发布；如仍被其他已选模块依赖，只允许通过 Maven `-am` 构建其所需 API/依赖模块，不得编译或发布该服务实现。验收必须确认构建日志未出现被隔离服务实现的 Maven 模块，也未出现其 Harbor destination。

2026-08-16 已验证：云服务 `master #12` 的固定提交 `964bd03` 不可达；修复后 `master #14` 为 `SUCCESS`，未编译 `nms4cloud-order-service`。PR #12 移除了云服务镜像发布的分支条件，`master #15` 为 `SUCCESS`，并发布 11 个云服务镜像；每个构建标签 `:15` 和 `:latest` 都经 Harbor API 与 Registry manifest 验证为同一 digest。PR #13 将 POS 编排、BI、WMS 与维护脚本中的旧 `jujiao_master` 引用改为 `master`。全部七个 Multibranch Job 已启用仅包含 `master` 的 SCM Head wildcard filter，重新索引后均只存在 `master` 子 Job。`build-nms4pos-images` 的 Remote Jenkinsfile 已更新为不含 Harbor artifact 删除逻辑的版本。对维护、WMS 与 POS Job 的索引可验证 Remote Jenkinsfile 可解析；维护 Job 不得因索引而替代其实际快照保留验收。

### 6.1.3 POS 安装包串行链路验收（2026-08-16）

`pos-install-package` 的正式顺序固定为 `00-clean -> 01-nms4cloud -> 02-nms4pos-ui -> 03-nms4pos`。每次只允许一个 Jenkins Agent 构建 Pod 运行；在前一 Pod 彻底删除、ResourceQuota 使用量释放前，不得手工启动下一步。该限制用于避免单节点 VMware 虚拟机发生并发构建内存耗尽。

各步骤的输出边界如下：`00-clean` 只清空并重建 `/var/lib/jenkins-package-output` 中的 POS UI 与 Java 输出目录，不得清空 Jenkins Home、K3s 数据、业务 PVC 或整台虚拟机；`01-nms4cloud` 编译云端依赖；`02-nms4pos-ui` 构建 `member-test` 前端并发布静态文件；`03-nms4pos` 注入静态文件、编译 `jujiao_master` POS Java 模块并发布 Java 输入包。

本次验收中确认并修复的直接问题：

- `01-nms4cloud #5` 与 `03-nms4pos #3` 的 Maven settings 使用不可达的 Nexus 集群内部地址，父 POM 解析失败；改为当前 Agent 可达的 Nexus NodePort 后，`01-nms4cloud #6` 成功。
- `02-nms4pos-ui #4` 的 Node 容器在 `pnpm install` 时被 cgroup OOMKilled（退出码 `137`）；容器资源改为 request `2Gi`、limit `4Gi` 后，`02-nms4pos-ui #5` 成功。
- `03-nms4pos #4` 的 Maven 构建已成功，但发布阶段因主机挂载目录由清理步骤以 root 创建、容器以 UID `1000` 运行而被拒绝写入；仅 Maven 容器设置 `runAsUser: 0` 后，`03-nms4pos #5` 成功。

最终验收：`00-clean #8`、`01-nms4cloud #6`、`02-nms4pos-ui #5`、`03-nms4pos #5` 均为 `SUCCESS`。全量递归盘点的 13 条可见流水线最新构建均为 `SUCCESS`，无运行中或排队任务。以上是构建与产物发布验收；使用 `SKIP_TESTS=true` 的 Maven 构建不构成单元测试通过证明。

升级 Jenkins 后，先验证 Controller Ready、网页登录、插件 `remote-file` 实际版本以及原有 `old-project-platform-pipeline` 仍可读取。任一失败时先禁用新 Job，恢复外部 Jenkins Home 备份，再回滚 Helm revision并复验旧状态；Helm rollback 不能替代 PVC 内容恢复。随后创建一个 Multibranch Job：项目仓库负责分支发现，平台仓库提供固定 Jenkinsfile，项目仓库不得增加 Jenkinsfile。

流水线通过条件：

- 扫描日志成功访问两个仓库，至少发现 `master`，无明文 Token 或密码；
- `master` 子 Job 的 `BRANCH_NAME`、Git SHA 和 `checkout scm` 的实际分支一致，平台配置不得固定或覆盖分支；
- 平台 Jenkinsfile 来源是 Gitea 的受保护平台项目 `admin/jenkins-platform`，路径为 `demo-springboot/Jenkinsfile`，项目提交不能覆盖其地址和路径；Codeup 只在迁移阶段使用；
- 当前受控云服务 Job 的分支发现仅包含 `master`，成功的 `master` 构建会执行发布阶段；其他 Job 的凭据和发布条件以各自受保护 Jenkinsfile 为准；
- 使用 `SKIP_TESTS=true` 的首次链路构建成功，并能在 Nexus 和 Harbor 回查制品；
- 构建日志证明 Maven 使用 Nexus `maven-public`，不得以创建第二个 Maven PVC 代替该验收；
- 在与 Jenkins Agent 相同的 Pod 网络中验证 `192.168.253.128:30083/dockerhub/library/eclipse-temurin:21-jre` 可由 Harbor Proxy 拉取，Harbor 中必须能查询对应 Proxy Cache 制品；
- Kaniko 无推送探测必须保持原 Dockerfile 并使用 `--registry-map="index.docker.io=192.168.253.128:30083/dockerhub"` 与 `--skip-default-registry-fallback` 构建成功；日志不得显示直连 `index.docker.io`。若出现 `Get "https://index.docker.io/v2/": EOF` 或 `unexpected EOF`，判定 Proxy 链路未生效，停止优化，不得回退为直连 Docker Hub；
- 验证 `NO_PROXY` 生效：Nexus、Harbor、Gitea 与 Kubernetes Service 仍从集群内网访问，不得经过物理机代理；
- 再用 `SKIP_TESTS=false` 完成一次测试门禁构建；
- `feature/*` 不发布制品，`release/*` 或正式发布不能跳过测试；
- 构建后临时 Agent 清理，现有 Job、凭据和平台服务无回归。
- 每个发布镜像仓库均可查询到本次纯数字标签和 `latest`，且两者解析为同一 digest；部署清单已经改为该数字标签，未引用 `latest`。

停止条件：插件不兼容、扫描不到分支、错误加载项目仓库脚本、分支身份不一致、发布规则可绕过、凭据泄露或真实制品回查失败。停止后保留日志和旧 Job，先恢复 Jenkins Home 外部备份，再执行 Helm 回滚；不得通过把 Jenkinsfile 放回项目仓库、写死单一分支或删除失败记录制造通过。

平台脚本变更后的附加验收：PR 已合并、目标分支重新克隆后 Jenkinsfile 清单完整、分支保护已恢复，并且仅对关联 Multibranch Job 请求索引扫描。任何脚本缺失、未授权删除、保护降级未恢复或索引路径不匹配，均为 FAIL；停止后从最近完整远端提交恢复，禁止再用 `git push --mirror` 覆盖仓库。

## 7. 资源验收

全部应用安装完成后执行：

```bash
bash /tmp/k3s-platform-check.sh verify
```

同时检查：

```bash
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get pvc -A
kubectl get svc -A
kubectl get events -A --sort-by=.lastTimestamp
```

通过条件：

- 固定版本 Helm Release 状态为 `deployed`；
- 长期运行 Pod 全部 `Running` 且 Ready；已完成的 Job 不计为长期工作负载；
- 所有应用 PVC 为 `Bound`；
- Secret 名称、必需键、统一管理员密码一致性检查通过；
- 没有持续增加的探针失败、OOMKilled、挂载失败或调度失败事件。

## 8. 认证与业务验收

资源验收通过后，按主安装文档的认证章节逐项执行，不得以 Pod Ready 代替登录：

| 应用 | 验收要求 |
|---|---|
| Rancher | 使用统一管理员密码登录；确认 Fleet 和本地集群状态正常 |
| Gitea | 使用统一管理员密码登录；确认仓库、分支、标签和 SSH/HTTP 访问正常 |
| Jenkins | 使用统一管理员密码网页登录，确认管理页面可用 |
| Nexus | 管理员登录；确认 Maven 仓库、部署用户和权限存在；完成一次发布验证 |
| Harbor | 管理员登录；确认 Jenkins 中存在 `harbor-robot`；Robot Account 实际推送并查询测试镜像；确认 `/tmp/harbor-robot-credential.json` 不存在 |
| Nacos | 使用统一管理员密码登录控制台；完成一次配置读取/写入或注册发现验证 |
| MySQL | 使用 root 和 app 账号分别执行认证查询；确认外部 NodePort 和集群内 Service 地址均符合文档 |

业务验收必须记录实际结果，例如 HTTP 状态、SQL 查询成功、制品坐标、镜像名称和配置项名称；禁止记录密码、Token 或完整认证响应。

## 9. 重启验收

认证和业务验收通过后，先把验收脚本复制到不会被重启清理的受限目录，再执行一次受控虚拟机重启：

```bash
install -d -m 700 "$HOME/.local/lib/k3s-bootstrap"
install -m 700 /tmp/k3s-platform-check.sh "$HOME/.local/lib/k3s-bootstrap/k3s-platform-check.sh"
sudo reboot
```

虚拟机恢复后重新执行：

```bash
kubectl wait --for=condition=Ready node --all --timeout=180s
bash "$HOME/.local/lib/k3s-bootstrap/k3s-platform-check.sh" verify
kubectl get pods -A -o wide
kubectl get pvc -A
```

并重新完成七个应用的最小登录或数据库认证。通过条件：

- 节点、Pod 和 PVC 自动恢复；
- 持久化验收脚本存在、权限为 `700`，验收不依赖可能被清理的 `/tmp`；
- Secret 未丢失，统一管理员密码检查通过；
- 七个应用仍可完成真实认证；
- Gitea、Jenkins、Nexus、Harbor 的持久化对象和 MySQL/Nacos 数据仍存在。

## 10. K3s 业务 DNS 与网关验收

对使用 Nacos、Redis、RocketMQ 的 `lgy` 业务服务，配置地址必须为带结尾点的绝对 FQDN。此项是本环境的强制门禁，原因是未带结尾点时 resolver 会尝试 `localdomain` 搜索域并可能返回非集群地址。

```bash
kubectl exec -n lgy deploy/nms4cloud-biz -- sh -c \
  'getent hosts nacos.nacos.svc.cluster.local; getent hosts nacos.nacos.svc.cluster.local.; getent hosts redis.lgy.svc.cluster.local.; getent hosts rocketmq-nameserver.lgy.svc.cluster.local.'
kubectl get endpoints -n lgy nms4cloud-platform
kubectl get pods -n lgy
```

通过条件：带结尾点的 Nacos、Redis、RocketMQ 均解析为各自 Kubernetes Service ClusterIP；`nms4cloud-platform` 有 Ready endpoint；业务 Deployment 全部 `Available=1`，明确暂停的可选应用除外。普通名称与绝对名称解析不一致时为 FAIL，先修复 ConfigMap 和 Nacos 共享配置，不得仅靠反复重启掩盖问题。

随后使用真实、未过期的业务令牌调用权限接口，记录状态码但不得记录令牌或响应正文：

```bash
curl -fsS -o /dev/null -w '%{http_code}\n' \
  -H 'nms4token-biz: <redacted-valid-token>' \
  'http://192.168.253.128:30090/api/sys/merchant/queryPermissionRights?moduleId=3'
```

通过条件：接口不返回 503 或 502，并由业务人员确认权限结果符合预期。仅验证匿名请求、Pod Ready 或网关健康检查均不能替代此项验收。

### 10.1 ClickHouse 与报表验收

ClickHouse 仅在报表依赖确认后部署到 `lgy`，必须引用现有 `clickhouse-secrets` 的 `CLICKHOUSE_PASSWORD` 键，禁止在清单或文档写入密码。安装前先执行服务端 dry-run：

```bash
kubectl apply --dry-run=server -n lgy -f 应用整理/overlays/lgy/clickhouse.yaml
```

安装后执行：

```bash
kubectl get pod,pvc,svc -n lgy -l app=clickhouse
curl -fsS http://192.168.253.128:30793/ping
curl -fsS -o /dev/null -D - -X POST http://192.168.253.128:30090/api/report/businessIndicator
```

通过条件：ClickHouse Pod `1/1 Running`、`clickhouse-data` PVC 为 `Bound`、`/ping` 返回 `Ok.`、报表路由不返回 5xx。报表 Nacos 数据源必须指向 `clickhouse.lgy.svc.cluster.local.:8123`；修改后滚动重启 `nms4cloud-pos11report` 并复测。

导入 ClickHouse 备份时，先检查 `manifest.tsv` 的表清单和目标库表数。目标数据库非空时为 FAIL，禁止把备份直接追加到现有表。恢复脚本必须逐表校验备份清单中的行数；缺表、建表失败或行数不一致均为 FAIL，并保留脱敏错误摘要。

## 11. 失败处理与交付记录

任何失败必须保留以下脱敏证据后再处理：

```bash
kubectl get pods -A -o wide
kubectl get pvc -A
kubectl get events -A --sort-by=.lastTimestamp
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --all-containers --tail=200
```

失败处理规则：

- Secret 缺失但 PVC/数据库存在：停止，备份并恢复匹配的 Secret/PVC；
- 密码同步失败：保留引导 Secret，修复认证链路后重跑，不删除 PVC；
- Helm 安装失败：先查看事件和 Helm 状态，优先回滚或前向修复，不直接卸载重装；
- 任何密码、Token、响应正文和日志交付前必须脱敏。

安装记录至少包含：执行日期、K3s/Chart/镜像版本、每个门禁的 PASS/FAIL、失败证据路径、七个应用认证结果、重启验收结果和未覆盖风险。只有所有门禁及验收均为 PASS，才能标记本次安装完成。
