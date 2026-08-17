# Kubernetes Secret 密码管理原理与边界

## 一、结论

Kubernetes Secret 是当前个人 K3s 环境唯一允许持久化应用密码的部署输入。密码明文只允许出现在创建或更新 Secret 的命令或脚本中；每个应用安装前必须在其自身 namespace 创建 Secret，values 或工作负载清单只保存 Secret 名称与键名，不保存密码值。

Secret 不是所有应用的运行时密码数据库。应用首次初始化后，密码可能写入自身数据库、PVC 或系统表；此时修改 Secret 不会自动修改应用中的账号密码。

## 二、三种接入方式

### 2.1 直接引用

应用每次启动都从 Secret 获取配置，常见形式是：

```yaml
env:
  - name: APP_PASSWORD
    valueFrom:
      secretKeyRef:
        name: app-auth
        key: password
```

Helm Chart 可能提供 `existingSecret`、`existingSecretAdminPassword` 或类似参数。只能使用 Chart 明确支持的引用参数，不能凭名称猜测不存在的 values；Chart 不支持外部 Secret 时，不得以 values 明文或 `--set` 传入密码。

### 2.2 首次初始化

MySQL、Harbor、Nexus 等组件会在空数据目录或空数据库中使用 Secret 初始化账号，之后把密码状态保存在自己的持久化数据中。

```text
Secret -> 首次启动 -> 应用数据库或 PVC
```

保留 PVC 时，Pod 重启和 Helm 升级通常不会重新设置密码。删除 PVC 后，应用才会按当时的 Secret 重新初始化。

### 2.3 应用状态协调

需要轮换有状态应用密码时，必须同时维护应用状态和 Secret：

```text
通过应用 API、页面或 SQL 修改密码
        -> 验证新密码可用
        -> 仅当该凭据有对应 Secret 时更新 Secret
        -> 重启或运行配置 Job
        -> 再次验证
```

不能先单独修改 Secret 后重启应用。这样容易造成应用数据库中的密码与 Secret 不一致。Rancher 日常管理员密码和 Nacos 控制台密码没有对应的部署 Secret，不应写入它们的引导或服务认证 Secret。

## 三、values 与 Secret 的职责

values 可以保存：

- Secret 名称和键名；
- 是否启用已有 Secret；
- 非敏感的用户名、端口和资源配置。

values 不得保存：

- 密码、Token、私钥；
- Base64 编码后的密码；
- 带密码的连接字符串；
- `--set`、`stringData` 或环境变量字面量中的密码；
- 用于临时绕过 Secret 的默认密码。

Base64 只是编码，不是加密。Secret 的安全性依赖 Kubernetes API 权限、etcd 保护、备份访问控制和日志脱敏。

## 四、namespace 与权限

Pod 原生只能引用同一 namespace 中的 Secret：

```text
jenkins 工作负载     -> jenkins/jenkins-admin
harbor 工作负载      -> harbor/harbor-admin
nexus 工作负载       -> nexus/nexus-admin
nacos 工作负载       -> nacos/nacos-auth
mysql 工作负载       -> mysql/mysql-auth
cattle-system Rancher -> cattle-system/bootstrap-secret
```

平台组件采用官方要求、官方推荐或企业批准的独立 namespace，不共用 `infra` 或 `default`：Rancher 使用官方要求的 `cattle-system`，Jenkins 使用官方安装指南推荐的 `jenkins`，Harbor、Nexus、Nacos 和 MySQL 使用企业约定的产品同名 namespace。应用只能引用自身 namespace 的 Secret，不得复制一个管理员 Secret 给整个集群使用。应按应用、用途和最小权限拆分，Jenkins 构建凭据继续放在 Jenkins Credentials 中，构建 Agent 不获得读取整个 namespace Secret 的权限。业务应用只有在同环境、同责任团队、同安全等级和同生命周期时才共享业务 namespace。

## 五、创建和轮换要求

- 密码明文只允许出现在创建或更新 Secret 的命令或脚本中；该命令或脚本不得把值输出到日志、文档、values、普通 YAML 或 Git。
- 可通过标准输入或受控脚本创建 Secret，不生成含密码的应用配置文件。
- 普通重部署必须复用现有 Secret；Secret 缺失但对应 PVC、数据库或 Release 仍存在时必须停止，不能生成新密码。
- 复用前检查必需键存在且非空，但不输出或解码值；最终以真实认证结果判断是否发生漂移。
- 修改前确认应用是否直接读取、仅首次初始化，还是需要 API/SQL 协调。
- Secret 与对应 PVC、数据库备份必须成组恢复。
- 验收只检查 Secret 名称、引用关系、键名和认证结果，不输出 Secret 值。
- 当前个人开发环境的六个应用长期管理员密码来自同一次隐藏输入，分别保存在各产品 namespace 的独立 Secret 中；校验时只比较编码数据是否一致，不解码或输出密码。
- Nacos 服务认证 Token、Harbor Robot Token、Jenkins 外部凭据及 Rancher/Nacos 的一次性 bootstrap Secret 不属于长期管理员密码，不复用统一密码。

## 六、当前组件边界

| 应用 | Secret 作用 | 修改 Secret 是否直接修改登录密码 |
|---|---|---|
| Jenkins | 管理员配置输入，JCasC 同步 | 是，但需要受控重启和登录验证 |
| Harbor | 部署和空数据库初始化 | 否，现有密码在 Harbor 数据库中 |
| Nexus | 空数据目录初始密码 | 否，现有密码在 Nexus PVC 中 |
| Rancher | `rancher-admin` 管理员密码来源，`bootstrap-secret` 仅首次同步使用 | Chart 不传密码；同步脚本调用 Rancher API 后删除 bootstrap Secret |
| Nacos | `nacos-auth` 服务认证，`nacos-admin` 控制台密码来源 | 同步脚本调用 Nacos API 后删除 `nacos-bootstrap-admin` |
| MySQL | 空数据目录初始化 root 和应用用户 | 否，现有密码在 MySQL 系统表中 |

## 七、适用范围

该方案适合单节点个人开发环境，优点是组件少、恢复路径短、与 Kubernetes 原生集成。它不提供集中审计、自动轮换或多集群同步。出现这些明确需求后，再评估外部密钥平台，不应提前增加常驻控制器。
