# RKE2 Kubernetes 部署文件格式详解

## 一、基本结构

### 声明式 API 原理

Kubernetes 采用**声明式（Declarative）**而非命令式（Imperative）的配置方式：
- **命令式**：告诉系统"做什么操作"（如 `docker run`、`kubectl run`）
- **声明式**：告诉系统"期望的最终状态"，由系统自动协调当前状态与期望状态的差距

这种设计的好处：
- **幂等性**：多次 `kubectl apply` 同一文件，结果相同，不会重复创建
- **自愈能力**：Pod 崩溃后，Controller 自动重建，使实际状态回归期望状态
- **版本控制**：YAML 文件可存入 Git，实现 GitOps 工作流

### 四个顶级字段

每个 Kubernetes 资源文件都包含四个顶级字段：

```yaml
apiVersion: apps/v1    # API 版本
kind: Deployment       # 资源类型
metadata:              # 元数据（对象身份）
  name: my-app
spec:                  # 规格（期望状态）
  ...
```

**字段技术说明：**

| 字段 | 作用 | 技术原理 |
|------|------|---------|
| `apiVersion` | 指定 API 组和版本 | K8s API 按组管理：核心资源（Pod/Service）用 `v1`，扩展资源用 `apps/v1`、`networking.k8s.io/v1` 等。版本号表示稳定性（v1=稳定，v1beta1=测试中） |
| `kind` | 资源类型 | API Server 根据 kind 路由到对应的 Controller；Controller 监听（Watch）该类型资源的变化并执行协调逻辑 |
| `metadata` | 对象身份信息 | 以 `name + namespace` 作为唯一键存储在 etcd 中；labels 用于选择器匹配，annotations 存储非结构化元数据 |
| `spec` | 期望状态描述 | Controller 持续对比 `spec`（期望状态）与 `status`（实际状态），驱动系统收敛到期望状态（Reconcile Loop） |

---

## 二、常用资源类型

### Controller 模式原理

Kubernetes 通过 **Controller Pattern** 管理所有资源：
1. **Watch**：Controller 通过 etcd Watch 机制监听资源变化
2. **Diff**：对比期望状态（spec）与实际状态（status）
3. **Act**：执行操作使实际状态收敛到期望状态
4. **Update Status**：将实际状态写回 API Server

这种模式实现了**最终一致性**：即使操作失败，Controller 会不断重试直到成功。

| 资源类型 | 用途 | 技术原理 |
|---------|------|---------|
| `Deployment` | 无状态应用部署（最常用） | 管理 ReplicaSet → ReplicaSet 管理 Pod；支持滚动更新、回滚、扩缩容 |
| `StatefulSet` | 有状态应用（数据库、中间件） | 为每个 Pod 分配稳定的网络标识和持久化存储；按序号顺序创建/删除 Pod |
| `DaemonSet` | 每个节点运行一个 Pod | 监听节点变化，自动在新节点上创建 Pod；常用于日志收集、监控 Agent |
| `Service` | 网络访问入口 | kube-proxy 生成 iptables/ipvs 规则实现负载均衡；Endpoints Controller 维护 Pod IP 列表 |
| `ConfigMap` | 配置文件 | 以键值对存储非敏感配置；挂载时通过 kubelet Volume 插件实现，更新后 60s 内同步 |
| `Secret` | 敏感信息（密码、证书） | base64 编码存储在 etcd（非加密，需启用 etcd 加密才安全）；挂载到 tmpfs 内存文件系统 |
| `PersistentVolumeClaim` | 持久化存储申请 | StorageClass 动态创建 PV 并绑定；Volume 插件负责实际挂载到节点 |
| `Ingress` | HTTP 路由规则 | Ingress Controller（如 Nginx）监听 Ingress 资源，动态生成反向代理配置并重载 |
| `Namespace` | 命名空间隔离 | 提供资源隔离、权限隔离（RBAC）、资源配额；不提供网络隔离（需 NetworkPolicy） |

---

## 三、Deployment 完整字段详解

### 滚动更新原理

```
Deployment Controller
    ↓ 创建新版本 ReplicaSet（副本数=0）
    ↓ 逐步增加新 RS 副本数，同时减少旧 RS 副本数
    ↓ 由 maxSurge / maxUnavailable 控制速度
    ↓ 旧 RS 保留（副本数=0），用于回滚
```

**QoS 等级（由 resources 配置决定）：**
- **Guaranteed**：requests = limits → 最高优先级，最后被驱逐
- **Burstable**：requests < limits → 中等优先级
- **BestEffort**：未设置 requests/limits → 最低优先级，资源紧张时最先被驱逐

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app                    # 资源名称（必填）
  namespace: default              # 命名空间（不填默认 default）
  labels:                         # 标签（用于选择器匹配）
    app: my-app
    version: v1.0
    env: production
  annotations:                    # 注解（存储额外信息，不用于选择）
    description: "我的应用"
    deploy-time: "2024-01-01"
    # annotations 不参与选择器匹配，常用于：
    # - 构建信息（Git commit、CI/CD 流水线 ID）
    # - 第三方工具配置（Prometheus 监控、Istio 注入）

spec:
  replicas: 3                     # Pod 副本数量（默认 1）
                                  # ReplicaSet Controller 通过 Watch 监控 Pod 数量
                                  # 少于 3 个则创建，多于 3 个则删除，实现自愈

  selector:                       # 选择器（必填，用于关联 Pod）
    matchLabels:
      app: my-app                 # 必须与 template.metadata.labels 匹配
    # selector 一旦创建不可修改（immutable）
    # 如果 Pod 的 label 被手动修改导致不匹配，会被视为"孤儿 Pod"

  strategy:                       # 更新策略
    type: RollingUpdate           # RollingUpdate（滚动更新）或 Recreate（先删后建）
    rollingUpdate:
      maxSurge: 1                 # 更新时最多多出几个 Pod（可以是数字或百分比）
                                  # replicas=3, maxSurge=1 → 更新时最多 4 个 Pod
      maxUnavailable: 0           # 更新时最多不可用几个 Pod
                                  # 设为 0 保证更新过程中始终有 3 个 Pod 可用（零停机）
    # maxSurge=1, maxUnavailable=0 → 先启新 Pod，再停旧 Pod（最安全）
    # maxSurge=0, maxUnavailable=1 → 先停旧 Pod，再启新 Pod（节省资源）
    # Recreate → 先删所有旧 Pod，再创建新 Pod（有停机，适合不支持多版本共存的应用）

  minReadySeconds: 10             # Pod 就绪后等待多少秒才认为可用
                                  # 防止 Pod 启动后立即崩溃导致的"抖动"

  revisionHistoryLimit: 10        # 保留多少个历史版本（用于回滚）
                                  # 保留旧的 ReplicaSet（副本数为 0）
                                  # kubectl rollout undo 时会恢复旧 ReplicaSet 的副本数

  template:                       # Pod 模板（必填）
    metadata:
      labels:                     # Pod 标签（必须包含 selector 中的标签）
        app: my-app
        version: v1.0
      annotations:
        prometheus.io/scrape: "true"   # Prometheus 监控注解
        # Prometheus 通过 Service Discovery 发现 Pod，读取这些 annotations 决定是否抓取

    spec:                         # Pod 规格
      # ===== 调度相关 =====
      nodeSelector:               # 节点选择器（简单版）
        kubernetes.io/os: linux
        disktype: ssd
        # Scheduler 只会将 Pod 调度到同时满足所有标签的节点（硬性要求）
        # 不满足则 Pod 一直 Pending

      affinity:                   # 亲和性（高级调度）
        nodeAffinity:             # 节点亲和性
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                - amd64
          # requiredDuringScheduling：调度时必须满足（硬性）
          # preferredDuringScheduling：调度时优先满足（软性，有权重）
          # IgnoredDuringExecution：Pod 运行后节点标签变化不影响已调度的 Pod
        podAntiAffinity:          # Pod 反亲和性（避免同一节点）
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: my-app
              topologyKey: kubernetes.io/hostname
          # topologyKey=kubernetes.io/hostname → 节点级别隔离
          # topologyKey=topology.kubernetes.io/zone → 可用区级别隔离（高可用）

      tolerations:                # 容忍度（允许调度到有污点的节点）
      - key: "node-role"
        operator: "Equal"
        value: "worker"
        effect: "NoSchedule"
      # Taint（污点）：节点属性，阻止 Pod 调度
      # Toleration（容忍）：Pod 属性，允许调度到有特定污点的节点
      # NoSchedule：不调度新 Pod，已有 Pod 不受影响
      # NoExecute：不调度新 Pod，且驱逐已有 Pod（除非有对应 toleration）

      # ===== 安全相关 =====
      serviceAccountName: my-sa   # 使用的 ServiceAccount
                                  # Pod 通过 ServiceAccount 的 Token 访问 K8s API
                                  # Token 自动挂载到 /var/run/secrets/kubernetes.io/serviceaccount/token

      securityContext:            # Pod 级别安全上下文
        runAsUser: 1000           # 以指定用户运行（UID）
        runAsGroup: 3000
        fsGroup: 2000             # 文件系统组（挂载的 Volume 的文件属主）
        runAsNonRoot: true        # 禁止以 root 运行（镜像的 USER 必须非 root）
        # fsGroup：Volume 中的文件会被 chown 为 fsGroup
        # runAsNonRoot：如果镜像 USER 是 root，Pod 会启动失败

      imagePullSecrets:           # 私有镜像仓库认证
      - name: harbor-registry-secret
      # kubelet 拉取镜像时使用此 Secret 中的认证信息
      # Secret 类型必须是 kubernetes.io/dockerconfigjson

      # ===== 初始化容器 =====
      initContainers:             # 在主容器启动前运行，按顺序执行
      - name: init-db
        image: busybox:latest
        command: ['sh', '-c', 'until nc -z db-service 5432; do sleep 1; done']
        # initContainers 按顺序串行执行，一个成功后才执行下一个
        # 所有 initContainers 成功后才启动主容器
        # 常用于：等待依赖服务就绪、初始化数据、下载配置文件

      # ===== 主容器 =====
      containers:
      - name: my-app              # 容器名称（必填）
        image: harbor-core.harbor/library/my-app:v1.0   # 镜像地址（必填）
        imagePullPolicy: IfNotPresent   # Always / Never / IfNotPresent
        # Always：每次都拉取（tag=latest 时默认）
        # IfNotPresent：本地有则用本地（tag 为具体版本时默认，推荐）
        # Never：只用本地，不拉取

        # ===== 端口 =====
        ports:
        - name: http              # 端口名称（可选，用于 Service 引用）
          containerPort: 8080     # 容器监听端口
          protocol: TCP           # TCP / UDP / SCTP
        # ports 仅作声明，不影响实际网络（容器仍可监听未声明的端口）
        # Service 的 targetPort 可以引用端口名称（如 targetPort: http）

        # ===== 环境变量 =====
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "production"
        - name: DB_PASSWORD       # 从 Secret 读取
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        - name: APP_NAME          # 从 ConfigMap 读取
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.name
        - name: POD_NAME          # 从 Pod 元数据读取（Downward API）
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        # 环境变量在容器启动时注入，运行中修改 ConfigMap/Secret 不会自动更新
        # 如需热更新，使用 Volume 挂载方式（kubelet 会定期同步，约 60s）
        # fieldRef 可引用：metadata.name, metadata.namespace, status.podIP, spec.nodeName 等

        envFrom:                  # 批量导入环境变量
        - configMapRef:
            name: app-config      # 把 ConfigMap 所有键值对作为环境变量
        - secretRef:
            name: app-secret      # 把 Secret 所有键值对作为环境变量

        # ===== 资源限制 =====
        resources:
          requests:               # 调度时保证的最小资源
            cpu: 500m             # 0.5 核（1000m = 1核）
            memory: 512Mi         # 512 MB
          limits:                 # 最大可用资源（超出会被限制/OOM Kill）
            cpu: 2000m            # 2 核（超出会被 CPU throttle，不会被杀）
            memory: 2Gi           # 2 GB（超出会触发 OOM Kill，容器被重启）
        # requests：Scheduler 根据此值选择节点（节点剩余资源 >= requests）
        # limits：通过 cgroup 限制，CPU 超出限流，内存超出 OOM Kill
        # QoS 等级：
        #   Guaranteed（requests=limits）→ 最高优先级，最后被驱逐
        #   Burstable（requests<limits）→ 中等优先级
        #   BestEffort（未设置）→ 最低优先级，最先被驱逐

        # ===== 健康检查 =====
        livenessProbe:            # 存活探针（失败则重启容器）
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 60   # 容器启动后等待多少秒开始探测
          periodSeconds: 10         # 探测间隔
          timeoutSeconds: 5         # 超时时间
          failureThreshold: 3       # 连续失败多少次才重启
        # kubelet 执行探测，失败后重启容器（不是重建 Pod）
        # 重启次数过多会触发 CrashLoopBackOff（指数退避重启）
        # 适用场景：检测死锁、内存泄漏等导致应用无响应的情况

        readinessProbe:           # 就绪探针（失败则从 Service 摘除）
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        # 失败后将 Pod 从 Service 的 Endpoints 中移除（不重启容器）
        # 恢复后自动重新加入负载均衡
        # 适用场景：应用启动中、依赖服务不可用、正在处理大量请求

        startupProbe:             # 启动探针（慢启动应用用这个）
          httpGet:
            path: /actuator/health
            port: 8080
          failureThreshold: 30    # 最多等 30 * 10 = 300 秒
          periodSeconds: 10
        # startupProbe 成功前，livenessProbe 和 readinessProbe 不会执行
        # 适用于启动时间长的应用（如 Java 应用、大型数据库）
        # 避免 livenessProbe 在启动阶段误杀容器

        # 探针类型（四选一）：
        # httpGet:      HTTP GET 请求（返回 200-399 为成功）
        # tcpSocket:    TCP 连接（能连接为成功）
        # exec:         执行命令（退出码 0 为成功）
        # grpc:         gRPC 健康检查（需应用实现 gRPC Health Checking Protocol）

        # ===== 挂载 =====
        volumeMounts:
        - name: config-volume
          mountPath: /app/config    # 挂载到容器内的路径
          readOnly: true
        - name: data-volume
          mountPath: /app/data
        - name: log-volume
          mountPath: /app/logs
          subPath: my-app           # 只挂载卷中的子目录
        # subPath：挂载 Volume 的子目录而非整个 Volume
        # 如果 mountPath 已存在文件，会被 Volume 内容覆盖（除非用 subPath）

        # ===== 生命周期钩子 =====
        lifecycle:
          postStart:              # 容器启动后执行
            exec:
              command: ["/bin/sh", "-c", "echo started > /tmp/started"]
          preStop:                # 容器停止前执行（优雅关闭）
            exec:
              command: ["/bin/sh", "-c", "sleep 5"]
        # postStart：与容器 ENTRYPOINT 异步执行，不保证顺序
        # preStop：收到 SIGTERM 前执行，完成后才发送 SIGTERM
        # 常用于：注册服务、优雅关闭（等待请求处理完）

        # ===== 安全上下文 =====
        securityContext:
          allowPrivilegeEscalation: false  # 禁止提权（防止通过 setuid 等方式提权）
          readOnlyRootFilesystem: true     # 根文件系统只读（防止容器写入文件系统）
          capabilities:
            drop:
            - ALL                 # 移除所有 Linux Capabilities
            add:
            - NET_BIND_SERVICE    # 添加绑定 1024 以下端口的能力

        # ===== 工作目录 =====
        workingDir: /app

        # ===== 启动命令 =====
        command: ["java"]         # 覆盖 Dockerfile 的 ENTRYPOINT
        args:                     # 覆盖 Dockerfile 的 CMD
        - "-jar"
        - "-Xmx2g"
        - "/app/app.jar"
        # command 未设置：使用镜像的 ENTRYPOINT
        # args 未设置：使用镜像的 CMD
        # 都设置：完全覆盖镜像的启动命令

      # ===== 终止宽限期 =====
      terminationGracePeriodSeconds: 30   # 优雅关闭等待时间（默认 30 秒）
      # 终止流程：
      # 1. Pod 标记为 Terminating，从 Service Endpoints 移除
      # 2. 执行 preStop 钩子
      # 3. 发送 SIGTERM 信号给容器主进程
      # 4. 等待 terminationGracePeriodSeconds 秒
      # 5. 超时后发送 SIGKILL 强制杀死

      # ===== DNS 配置 =====
      dnsPolicy: ClusterFirst     # ClusterFirst / Default / None
      dnsConfig:
        nameservers:
        - 8.8.8.8
        searches:
        - my-namespace.svc.cluster.local
      # ClusterFirst：使用集群 DNS（CoreDNS），默认值
      # Default：使用节点的 DNS 配置
      # None：不配置 DNS，必须手动指定 dnsConfig

      # ===== 重启策略 =====
      restartPolicy: Always       # Always / OnFailure / Never（Deployment 只能用 Always）

      # ===== 卷定义 =====
      volumes:
      - name: config-volume       # ConfigMap 挂载
        configMap:
          name: app-config
          items:
          - key: application.yml
            path: application.yml
        # ConfigMap 更新后，kubelet 会在 60 秒内同步到 Pod（通过 symlink）
        # 如果不指定 items，会挂载所有 key（key 作为文件名）

      - name: secret-volume       # Secret 挂载
        secret:
          secretName: app-secret
        # Secret 挂载时会自动 base64 解码
        # 存储在 tmpfs 中（内存文件系统），不写入磁盘，更安全

      - name: data-volume         # PVC 挂载
        persistentVolumeClaim:
          claimName: my-pvc
        # PVC 必须与 Pod 在同一 namespace
        # 挂载前 PVC 必须已绑定到 PV（Status: Bound）

      - name: log-volume          # 空目录（Pod 内共享）
        emptyDir: {}
        # emptyDir 随 Pod 生命周期存在，Pod 删除后数据丢失
        # 同一 Pod 内多个容器可共享（如日志收集 sidecar）
        # medium: Memory 使用 tmpfs，适合临时缓存，但会占用内存 limits

      - name: host-volume         # 宿主机目录挂载
        hostPath:
          path: /var/log
          type: Directory
        # 直接挂载节点目录，Pod 重新调度到其他节点后数据不可用
        # 安全风险：容器可访问节点文件系统，谨慎使用

      - name: docker-config       # Secret 中特定 key 挂载
        secret:
          secretName: harbor-registry-secret
          items:
          - key: .dockerconfigjson
            path: config.json
```

---


## 四、Service 字段详解

### Service 网络原理

kube-proxy 在每个节点上运行，监听 Service 和 Endpoints 变化，生成 iptables/ipvs 规则：

- **iptables 模式**（默认）：为每个 Service 创建规则链，随机选择后端 Pod
- **ipvs 模式**（推荐）：使用内核 IPVS 模块，支持更多负载均衡算法（rr/lc/dh/sh），大规模集群性能更好
- **ClusterIP 原理**：虚拟 IP，不绑定任何网络接口，只存在于 iptables/ipvs 规则中
- **DNS 解析**：CoreDNS 提供，完整域名 `<service>.<namespace>.svc.cluster.local`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-svc
  namespace: default

spec:
  selector:                       # 选择哪些 Pod（通过标签匹配）
    app: my-app
    # Endpoints Controller 监听 Pod 变化，维护匹配 Pod 的 IP 列表
    # Pod 就绪（readinessProbe 通过）才会加入 Endpoints
    # Pod 删除或不就绪时自动从 Endpoints 移除

  type: NodePort                  # 服务类型（见下方说明）

  ports:
  - name: http
    port: 80                      # Service 暴露的端口（ClusterIP:80）
    targetPort: 8080              # 转发到 Pod 的端口（可以是端口名或数字）
    nodePort: 30080               # NodePort 类型时的节点端口（30000-32767）
    protocol: TCP
    # 流量路径（NodePort）：外部请求 → 节点IP:30080 → iptables DNAT → PodIP:8080

  sessionAffinity: None           # None / ClientIP（会话保持）
  # ClientIP：同一客户端 IP 的请求总是转发到同一个 Pod

  clusterIP: None                 # 设为 None 则为 Headless Service（StatefulSet 用）
  # Headless Service：不分配 ClusterIP，DNS 直接返回所有 Pod 的 IP 列表
```

**Service 类型说明：**

| 类型 | 说明 | 访问方式 |
|------|------|---------|
| `ClusterIP` | 集群内部访问（默认） | `service-name.namespace.svc.cluster.local` |
| `NodePort` | 通过节点 IP + 端口访问 | `<节点IP>:<nodePort>` |
| `LoadBalancer` | 云厂商负载均衡器 | 外部 IP |
| `ExternalName` | 映射到外部域名 | DNS CNAME |

---

## 五、ConfigMap 字段详解

### ConfigMap 工作原理

- **存储**：以键值对存储在 etcd 中，大小限制 1MB
- **挂载为文件**：kubelet 将内容写入 tmpfs，通过 symlink 实现热更新（约 60s）
- **注入为环境变量**：容器启动时注入，之后修改不会自动更新
- **热更新限制**：subPath 挂载和环境变量方式均不支持热更新

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default

data:                             # 字符串数据（存储在 etcd 中）
  app.name: "my-application"
  app.port: "8080"
  application.yml: |             # 多行文本（| 保留换行）
    server:
      port: 8080
    spring:
      profiles:
        active: production

binaryData:                       # 二进制数据（base64 编码）
  logo.png: <base64-encoded-data>
```

---

## 六、Secret 字段详解

### Secret 安全说明

- **存储**：base64 编码存储在 etcd（不是加密！需启用 etcd EncryptionConfiguration 才真正安全）
- **挂载**：以 tmpfs（内存文件系统）挂载，不写入节点磁盘
- **访问控制**：通过 RBAC 限制哪些 ServiceAccount 可以读取 Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: default

type: Opaque                      # 类型（见下方说明）

data:                             # base64 编码的数据
  username: YWRtaW4=              # echo -n "admin" | base64
  password: SGFyYm9yMTIzNDU=

stringData:                       # 明文数据（自动 base64 编码，优先级高于 data）
  api-key: "my-secret-key"
```

**Secret 类型说明：**

| 类型 | 说明 |
|------|------|
| `Opaque` | 通用（默认） |
| `kubernetes.io/dockerconfigjson` | 镜像仓库认证 |
| `kubernetes.io/tls` | TLS 证书 |
| `kubernetes.io/service-account-token` | ServiceAccount Token |

---

## 七、PersistentVolumeClaim 字段详解

### 存储供应原理

```
开发者创建 PVC → StorageClass Provisioner 动态创建 PV → PVC 绑定 PV（Bound）
    → Pod 挂载 PVC → kubelet 调用 Volume 插件挂载到节点 → 容器可访问
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: default

spec:
  accessModes:
  - ReadWriteOnce                 # 访问模式（见下方说明）

  storageClassName: local-path    # StorageClass 名称
  # local-path：RKE2 内置，在节点本地磁盘创建目录
  # 注意：local-path 绑定到特定节点，Pod 只能调度到该节点

  resources:
    requests:
      storage: 10Gi               # 申请的存储大小

  volumeMode: Filesystem          # Filesystem / Block
```

**访问模式说明：**

| 模式 | 缩写 | 说明 |
|------|------|------|
| `ReadWriteOnce` | RWO | 单节点读写 |
| `ReadOnlyMany` | ROX | 多节点只读 |
| `ReadWriteMany` | RWX | 多节点读写（需要 NFS 等） |
| `ReadWriteOncePod` | RWOP | 单 Pod 读写 |

---

## 八、Ingress 字段详解

### Ingress 工作原理

Ingress Controller（如 Nginx）监听 Ingress 资源变化，将规则转换为 Nginx 配置并动态重载。TLS 在 Ingress Controller 处终止，后端 Service 接收 HTTP 请求。

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"

spec:
  ingressClassName: nginx         # 使用哪个 Ingress Controller

  tls:                            # HTTPS 配置
  - hosts:
    - my-app.example.com
    secretName: tls-secret        # TLS 证书 Secret（类型：kubernetes.io/tls）

  rules:
  - host: my-app.example.com      # 域名（不填则匹配所有）
    http:
      paths:
      - path: /api                # 路径
        pathType: Prefix          # Prefix / Exact / ImplementationSpecific
        backend:
          service:
            name: my-app-svc
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
```

---

## 九、StatefulSet 字段详解

### StatefulSet vs Deployment

| 特性 | Deployment | StatefulSet |
|------|-----------|-------------|
| Pod 名称 | 随机（my-app-7d4f8b-xxx） | 有序（mysql-0, mysql-1） |
| 网络标识 | 随机 IP | 稳定 DNS（mysql-0.mysql.ns.svc.cluster.local） |
| 存储 | 共享 PVC 或 emptyDir | 每个 Pod 独立 PVC |
| 创建顺序 | 并行创建 | 按序号顺序创建（0→1→2） |
| 删除顺序 | 并行删除 | 逆序删除（2→1→0） |

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql

spec:
  serviceName: mysql              # 必须指定 Headless Service 名称
  # 为每个 Pod 提供稳定 DNS：mysql-0.mysql.default.svc.cluster.local
  replicas: 3
  selector:
    matchLabels:
      app: mysql

  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql

  volumeClaimTemplates:           # 每个 Pod 自动创建独立的 PVC
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: local-path
      resources:
        requests:
          storage: 20Gi
  # 创建的 PVC 名称：data-mysql-0, data-mysql-1, data-mysql-2
  # Pod 删除后 PVC 不会自动删除（保护数据），需手动删除

  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0                # 只更新序号 >= partition 的 Pod
      # partition=2 → 只更新 mysql-2，用于灰度发布验证
```

---

## 十、RBAC 相关资源

### RBAC 权限验证流程

```
请求到达 API Server
    ↓ Authentication（认证）：验证身份（Token/证书）
    ↓ Authorization（授权）：RBAC 检查是否有权限
    ↓ Admission Control（准入控制）：策略检查
    ↓ 执行操作
```

### ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
# Pod 通过 ServiceAccount 的 Token 访问 K8s API
# Token 自动挂载到 /var/run/secrets/kubernetes.io/serviceaccount/token
```

### Role（命名空间级别权限）

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins-role
  namespace: jenkins

rules:
- apiGroups: [""]                 # "" 表示核心 API 组
  resources: ["pods", "pods/log", "pods/exec"]
  verbs: ["get", "list", "watch", "create", "delete", "patch", "update"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "update", "patch"]
```

### ClusterRole（集群级别权限）

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```

### RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-binding
  namespace: jenkins

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role                      # Role 或 ClusterRole
  name: jenkins-role

subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
```

---

## 十一、资源单位说明

### CPU 单位

| 写法 | 含义 |
|------|------|
| `1` | 1 核 |
| `0.5` | 0.5 核 |
| `500m` | 0.5 核（m = millicores，毫核） |
| `2000m` | 2 核 |

**CPU 限制原理（cgroup）：**
- `requests`：通过 `cpu.shares` 设置相对权重，保证最低 CPU 时间
- `limits`：通过 `cpu.cfs_quota_us` 设置配额，超出则限流（throttle，不杀容器）

### 内存单位

| 写法 | 含义 |
|------|------|
| `128Mi` | 128 MiB（1Mi = 1024 * 1024 字节） |
| `1Gi` | 1 GiB |
| `512M` | 512 MB（1M = 1000 * 1000 字节） |
| `1G` | 1 GB |

**内存限制原理（cgroup）：**
- `limits`：通过 `memory.limit_in_bytes` 设置上限，超出触发 OOM Kill，容器重启

---

## 十二、常用标签约定

```yaml
labels:
  app: my-app                     # 应用名称（最重要，用于 selector）
  version: v1.0.0                 # 版本
  component: backend              # 组件（frontend / backend / database）
  part-of: my-system              # 所属系统
  managed-by: helm                # 管理工具
  env: production                 # 环境（dev / test / staging / production）
  tier: web                       # 层级（web / app / cache / db）
```

---

## 十三、多资源文件合并

一个 YAML 文件可以包含多个资源，用 `---` 分隔：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  key: value

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  ...

---

apiVersion: v1
kind: Service
metadata:
  name: my-app-svc
spec:
  ...
```

---

## 十四、常用 kubectl 操作

```bash
# 应用配置
kubectl apply -f deployment.yaml
kubectl apply -f ./k8s/              # 应用目录下所有文件

# 查看资源
kubectl get deployment my-app -n default
kubectl describe deployment my-app -n default
kubectl get deployment my-app -o yaml   # 查看完整配置

# 更新镜像
kubectl set image deployment/my-app my-app=harbor-core.harbor/library/my-app:v2.0 -n default

# 扩缩容
kubectl scale deployment my-app --replicas=5 -n default

# 回滚
kubectl rollout undo deployment/my-app -n default
kubectl rollout history deployment/my-app -n default

# 重启
kubectl rollout restart deployment/my-app -n default

# 删除
kubectl delete -f deployment.yaml
kubectl delete deployment my-app -n default
```

---

## 十五、Spring Boot 应用完整示例

```yaml
# ============================================================
# Deployment：负责管理 Pod 的创建、更新、扩缩容
# ============================================================
apiVersion: apps/v1       # Deployment 使用 apps/v1 API 版本
kind: Deployment
metadata:
  name: nms4cloud-platform        # Deployment 名称，kubectl 操作时使用
  namespace: nms4cloud            # 所在命名空间，不同命名空间资源互相隔离
  labels:
    app: nms4cloud-platform       # 标签，用于 kubectl get/select 筛选
    version: "1.0"

spec:
  replicas: 2                     # 运行 2 个 Pod 副本，保证高可用
                                  # 一个 Pod 挂掉，另一个仍然提供服务

  selector:
    matchLabels:
      app: nms4cloud-platform     # Deployment 通过此标签找到它管理的 Pod
                                  # 必须与下方 template.metadata.labels 一致

  strategy:
    type: RollingUpdate           # 滚动更新：先启动新 Pod，再停旧 Pod
                                  # 保证更新过程中服务不中断
    rollingUpdate:
      maxSurge: 1                 # 更新时最多额外多出 1 个 Pod
                                  # 即 2 个副本更新时，最多同时存在 3 个 Pod
      maxUnavailable: 0           # 更新时不允许有不可用的 Pod
                                  # 设为 0 保证更新过程中始终有 2 个 Pod 在运行

  template:                       # Pod 模板，Deployment 按此模板创建 Pod
    metadata:
      labels:
        app: nms4cloud-platform   # Pod 标签，必须包含 selector.matchLabels 中的标签
        version: "1.0"            # 额外标签，用于版本区分

    spec:
      # -------------------------------------------------------
      # 镜像拉取认证
      # 从私有 Harbor 仓库拉取镜像时需要提供认证信息
      # Secret 由以下命令创建：
      # kubectl create secret docker-registry harbor-registry-secret \
      #   --docker-server=harbor-core.harbor \
      #   --docker-username=admin \
      #   --docker-password=Harbor12345 \
      #   -n nms4cloud
      # -------------------------------------------------------
      imagePullSecrets:
      - name: harbor-registry-secret

      containers:
      - name: nms4cloud-platform  # 容器名称，同一 Pod 内必须唯一
                                  # kubectl logs/exec 时用于指定容器

        image: harbor-core.harbor/library/nms4cloud-platform:latest
        # 镜像地址格式：<仓库地址>/<项目>/<镜像名>:<tag>
        # harbor-core.harbor     → Harbor 在 K8s 内的 Service 域名
        # library                → Harbor 项目名
        # nms4cloud-platform     → 镜像名
        # latest                 → 镜像标签（生产环境建议用具体版本号）

        imagePullPolicy: IfNotPresent
        # Always       → 每次都从仓库拉取（开发环境用）
        # IfNotPresent → 本地有就用本地，没有才拉取（推荐，节省带宽）
        # Never        → 只用本地镜像，不拉取

        ports:
        - name: http              # 端口名称，Service 的 targetPort 可以引用此名称
          containerPort: 8080     # Spring Boot 应用监听的端口

        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "k8s"            # 激活 k8s 配置文件（application-k8s.yml）
                                  # 可在该文件中配置 K8s 环境专用参数

        - name: JAVA_OPTS
          value: "-Xmx1g -Xms512m"
          # -Xmx1g  → JVM 最大堆内存 1GB（不能超过 limits.memory）
          # -Xms512m → JVM 初始堆内存 512MB
          # 建议 Xmx 设为 limits.memory 的 75% 左右，留出 JVM 非堆内存空间

        envFrom:
        - configMapRef:
            name: nms4cloud-config
            # 例如 ConfigMap 中有 DB_HOST=mysql，则容器内可直接用 $DB_HOST

        resources:
          requests:
            cpu: 500m             # 调度时保证 0.5 核 CPU
            memory: 1Gi           # 调度时保证 1GB 内存
          limits:
            cpu: 2000m            # 最多使用 2 核 CPU（超出会被限速，不会被杀）
            memory: 2Gi           # 最多使用 2GB 内存（超出会触发 OOM Kill）
                                  # 注意：JAVA_OPTS 的 Xmx 不能超过此值

        livenessProbe:
          httpGet:
            path: /actuator/health/liveness   # Spring Boot Actuator 存活端点
            port: 8080
          initialDelaySeconds: 90   # 容器启动后等 90 秒再开始探测
                                    # Spring Boot 启动较慢，需要足够的等待时间
                                    # 太短会导致应用还没启动完就被重启
          periodSeconds: 10         # 每 10 秒探测一次
          timeoutSeconds: 5         # 探测超时时间 5 秒
          failureThreshold: 3       # 连续失败 3 次（30 秒）才重启容器

        readinessProbe:
          httpGet:
            path: /actuator/health/readiness  # Spring Boot Actuator 就绪端点
            port: 8080
          initialDelaySeconds: 60   # 等 60 秒再开始探测（比存活探针短）
          periodSeconds: 5          # 每 5 秒探测一次（比存活探针频繁）
          timeoutSeconds: 3
          failureThreshold: 3       # 连续失败 3 次（15 秒）才摘除流量
                                    # 恢复后会自动重新加入负载均衡

        volumeMounts:
        - name: app-config          # 对应下方 volumes 中的名称
          mountPath: /app/config    # 挂载到容器内的路径
          readOnly: true            # 配置文件只读，防止应用意外修改

        - name: app-logs
          mountPath: /app/logs      # 日志目录，使用 emptyDir 临时存储
                                    # Pod 重启后日志会丢失
                                    # 生产环境建议用 PVC 或日志收集器（如 Filebeat）

      terminationGracePeriodSeconds: 60
      # K8s 发送 SIGTERM 信号后，等待 60 秒再强制 SIGKILL
      # Spring Boot 需要时间处理完正在进行的请求
      # 建议设置为比 Spring Boot 的 server.shutdown.timeout 大一些

      volumes:
      - name: app-config
        configMap:
          name: nms4cloud-platform-config   # 引用已存在的 ConfigMap
                                            # ConfigMap 中的内容会以文件形式挂载

      - name: app-logs
        emptyDir: {}              # 空目录，随 Pod 生命周期存在
                                  # 同一 Pod 内多个容器可以共享此目录
                                  # 常用于日志收集 sidecar 容器读取主容器日志

---

# ============================================================
# Service：为 Pod 提供稳定的网络访问入口
# Pod 的 IP 会变化，Service 提供固定的 ClusterIP 和 DNS 名称
# ============================================================
apiVersion: v1
kind: Service
metadata:
  name: nms4cloud-platform        # Service 名称
  namespace: nms4cloud
  # K8s 内部 DNS 访问地址：
  # nms4cloud-platform.nms4cloud.svc.cluster.local:8080
  # 同命名空间内可简写为：nms4cloud-platform:8080

spec:
  selector:
    app: nms4cloud-platform       # 将流量转发到带有此标签的 Pod

  type: ClusterIP                 # 只在集群内部访问
                                  # 如需外部访问，改为 NodePort 或配置 Ingress

  ports:
  - name: http
    port: 8080                    # Service 暴露的端口（其他服务访问此端口）
    targetPort: 8080              # 转发到 Pod 的端口（对应容器的 containerPort）
    protocol: TCP
```

---

## 十六、Jenkins 完整部署示例（含原理说明）

### 整体架构说明

```
外部浏览器
    ↓ 30080（NodePort）
  K8s Node
    ↓ 8080（Service → Pod）
  Jenkins Pod（jenkins 命名空间）
    ↓ 读写
  PVC（jenkins-pvc）→ local-path StorageClass → 节点本地磁盘
    ↑
  ServiceAccount（jenkins）→ ClusterRole → 有权限在 K8s 中创建 Agent Pod
```

### 部署文件

```yaml
# ============================================================
# 1. Namespace：命名空间隔离
# 将 Jenkins 所有资源放在独立的 jenkins 命名空间
# 好处：资源隔离、权限控制、方便统一管理和删除
# ============================================================
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins

---

# ============================================================
# 2. PersistentVolumeClaim：持久化存储申请
# Jenkins 的所有数据（插件、配置、构建历史）都存在 /var/jenkins_home
# 必须持久化，否则 Pod 重启后数据全部丢失
# ============================================================
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce               # 单节点读写（Jenkins 只有 1 个副本，够用）
  resources:
    requests:
      storage: 30Gi               # 申请 30GB 存储空间
                                  # 包含：插件（~2GB）+ 构建缓存 + 历史记录
  storageClassName: local-path    # 使用 RKE2 自带的 local-path 存储类
                                  # 数据存储在节点本地磁盘（/var/lib/rancher/rke2/storage/）
                                  # 注意：节点故障时数据可能丢失，生产环境建议用 NFS

---

# ============================================================
# 3. ServiceAccount：Jenkins 的身份标识
# Jenkins 需要调用 K8s API 来动态创建/删除 Agent Pod
# ServiceAccount 是 Pod 访问 K8s API 的身份凭证
# ============================================================
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins

---

# ============================================================
# 4. ClusterRole：定义 Jenkins 需要的 K8s 权限
# ClusterRole 是集群级别的权限，适用于所有命名空间
# ============================================================
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins
rules:
  # 管理 Pod：Jenkins Kubernetes 插件需要动态创建和删除 Agent Pod
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update","watch"]

  # 进入 Pod 执行命令：用于调试和某些插件功能
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["create","delete","get","list","patch","update","watch"]

  # 查看 Pod 日志：Jenkins 需要读取 Agent Pod 的构建日志
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get","list","watch"]

  # 读取 Secret：Jenkins 需要读取镜像仓库认证 Secret（harbor-registry-secret）
  # 只给 get 权限，不允许修改，最小权限原则
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get"]

---

# ============================================================
# 5. ClusterRoleBinding：将 ClusterRole 绑定到 ServiceAccount
# 三者关系：ServiceAccount（谁）→ ClusterRoleBinding（绑定）→ ClusterRole（能做什么）
# ============================================================
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins                   # 引用上面创建的 ClusterRole
subjects:
  - kind: ServiceAccount
    name: jenkins                 # jenkins 命名空间下的 jenkins ServiceAccount
    namespace: jenkins

---

# ============================================================
# 6. Deployment：部署 Jenkins 主节点
# ============================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1                     # Jenkins 主节点只能运行 1 个副本
                                  # 多副本会导致数据冲突（共享同一个 PVC）

  selector:
    matchLabels:
      app: jenkins

  template:
    metadata:
      labels:
        app: jenkins

    spec:
      serviceAccountName: jenkins # 使用上面创建的 ServiceAccount
                                  # Pod 启动后会自动挂载对应的 Token
                                  # Jenkins Kubernetes 插件通过此 Token 调用 K8s API

      containers:
        - name: jenkins
          image: jenkins/jenkins:lts-jdk21
          # lts      → Long Term Support，长期支持版本，稳定性好
          # jdk21    → 内置 JDK 21，支持最新 Java 特性

          env:
            - name: JAVA_OPTS
              value: "-Xmx3072m -Xms1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
              # -Xmx3072m          → JVM 最大堆内存 3GB（不超过 limits.memory 的 75%）
              # -Xms1024m          → JVM 初始堆内存 1GB
              # -XX:+UseG1GC       → 使用 G1 垃圾回收器（大堆内存推荐）
              # -XX:MaxGCPauseMillis=200 → GC 最大停顿时间 200ms

            - name: JENKINS_OPTS
              value: "--sessionTimeout=1440"
              # --sessionTimeout=1440 → 会话超时时间 1440 分钟（24 小时）

          ports:
            - containerPort: 8080
              name: http          # Jenkins Web UI 端口
            - containerPort: 50000
              name: agent         # JNLP Agent 连接端口（TCP 模式使用）

          volumeMounts:
            - name: jenkins-storage
              mountPath: /var/jenkins_home
              # Jenkins 所有数据都存在这个目录：
              # /var/jenkins_home/
              # ├── plugins/              → 已安装的插件
              # ├── jobs/                 → 流水线配置和构建历史
              # ├── config.xml            → Jenkins 全局配置
              # └── credentials.xml       → 凭据（加密存储）

          resources:
            requests:
              memory: "2Gi"       # 调度时保证 2GB 内存
              cpu: "1000m"        # 调度时保证 1 核 CPU
            limits:
              memory: "4Gi"       # 最大 4GB 内存
              cpu: "3000m"        # 最大 3 核 CPU（构建时 CPU 消耗较高）

      volumes:
        - name: jenkins-storage
          persistentVolumeClaim:
            claimName: jenkins-pvc  # 引用上面创建的 PVC

---

# ============================================================
# 7. Service：暴露 Jenkins 访问端口
# ============================================================
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: jenkins
spec:
  type: NodePort                  # 在每个节点上开放指定端口
                                  # 访问方式：http://<任意节点IP>:30080

  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30080             # 节点对外暴露的端口（范围 30000-32767）
      name: http

    - port: 50000
      targetPort: 50000
      nodePort: 30050
      name: agent

  selector:
    app: jenkins
```

### 各资源的依赖关系

```
Namespace（jenkins）
    ├── PVC（jenkins-pvc）
    │     └── StorageClass（local-path）→ 节点本地磁盘
    ├── ServiceAccount（jenkins）
    │     └── ClusterRoleBinding（jenkins）→ ClusterRole（jenkins）
    ├── Deployment（jenkins）
    │     ├── 使用 ServiceAccount（jenkins）→ 获得 K8s API 权限
    │     ├── 挂载 PVC（jenkins-pvc）→ 持久化数据
    │     └── 创建 Pod → 运行 Jenkins 容器
    └── Service（jenkins）
          └── 将外部流量路由到 Jenkins Pod
```

### 部署顺序

```bash
# 一次性应用所有资源（K8s 会自动处理依赖顺序）
kubectl apply -f jenkins-deploy.yaml

# 查看部署状态
kubectl get all -n jenkins

# 查看 Jenkins 初始密码
kubectl logs -n jenkins deployment/jenkins | grep -A 3 "initialAdminPassword"
# 或者
kubectl exec -n jenkins deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## 十七、查看 PVC 实际存储位置

### 第一步：找到 PVC 绑定的 PV

```bash
kubectl get pvc -n jenkins
```

输出示例：
```
NAME          STATUS   VOLUME                                     CAPACITY   STORAGECLASS
jenkins-pvc   Bound    pvc-a1b2c3d4-xxxx-xxxx-xxxx-xxxxxxxxxxxx   30Gi       local-path
```

- `STATUS: Bound` → PVC 已成功绑定到 PV，可以正常使用
- `VOLUME` → 自动创建的 PV 名称

### 第二步：查看 PV 详情找到物理路径

```bash
kubectl get pv pvc-a1b2c3d4-xxxx-xxxx-xxxx-xxxxxxxxxxxx -o yaml
```

关键字段：
```yaml
spec:
  hostPath:
    path: /var/lib/rancher/k3s/storage/pvc-a1b2c3d4-xxxx   # 实际存储路径
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - jjtestserver    # 数据存储在哪个节点上
```

### 第三步：一条命令直接查看路径

```bash
# 查看路径
kubectl get pv $(kubectl get pvc jenkins-pvc -n jenkins -o jsonpath='{.spec.volumeName}') \
  -o jsonpath='{.spec.hostPath.path}'

# 查看存储在哪个节点
kubectl get pv $(kubectl get pvc jenkins-pvc -n jenkins -o jsonpath='{.spec.volumeName}') \
  -o jsonpath='{.spec.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0]}'
```

### 第四步：SSH 到节点查看实际文件

```bash
# SSH 到对应节点
ssh jjtestserver

# 查看存储目录内容
ls -lh /var/lib/rancher/rke2/storage/pvc-a1b2c3d4-xxxx/
```

---

### local-path 默认存储路径

| 环境 | 默认路径 |
|------|---------|
| RKE2 | `/var/lib/rancher/rke2/storage/` |
| K3s | `/var/lib/rancher/k3s/storage/` |
| 自定义 | 查看 local-path-config ConfigMap |

查看实际配置：

```bash
kubectl get configmap local-path-config -n kube-system -o yaml
```

输出中的 `paths` 字段就是实际存储路径：

```yaml
data:
  config.json: |
    {
      "nodePathMap": [
        {
          "node": "DEFAULT_PATH_FOR_NON_LISTED_NODES",
          "paths": ["/var/lib/rancher/rke2/storage"]
        }
      ]
    }
```

---

### PVC / PV / StorageClass 三者关系

```
StorageClass（local-path）
    ↓ 自动创建
PersistentVolume（PV）
    ↑ 绑定
PersistentVolumeClaim（PVC）
    ↑ 挂载
Pod（/var/jenkins_home）
```

- **StorageClass**：定义存储类型和创建方式（由管理员配置）
- **PV**：实际的存储资源（由 StorageClass 自动创建，或管理员手动创建）
- **PVC**：应用申请存储的请求（由开发者创建，K8s 自动匹配合适的 PV）
