# Jenkins 多项目流水线标准方案

本文说明如何将当前的单项目 Jenkins Job 演进为适用于多项目的标准化方案。目标是：公共构建逻辑和项目映射集中维护，项目仓库不需要 Jenkins 专用文件，密码和 Token 不进入 Git。

本文适用于本目录的 K3s、Jenkins、Nexus 和 Harbor 基线。它描述的是个人开发环境可逐步采用的企业常见模式，不要求一次性安装扫描平台、审批平台或生产部署系统。

## 一、结论

推荐组合为：

```text
Jenkins Configuration as Code (JCasC) / Helm values
    管理 Jenkins 自身和基础配置

Remote Jenkinsfile Provider
    让 Multibranch 从受保护的平台仓库加载 Jenkinsfile

Multibranch Pipeline Job
    自动发现项目分支，由 Remote Jenkinsfile Provider 从平台仓库加载脚本

Jenkins Shared Library
    统一 Maven、Nexus、Harbor、镜像标签和构建清理逻辑

项目仓库
    只保留源码、pom.xml、Dockerfile 等业务构建输入
```

这些职责不能互相替代。JCasC 不应保存业务构建步骤；Shared Library 不应保存密码；Remote Provider Multibranch Job 负责加载受保护的平台脚本；项目仓库不承担 Jenkins 配置；Multibranch Pipeline 不负责安装 Jenkins。Shared Library 是公共逻辑稳定后的目标组件，不是本次单项目 Multibranch 验收的前置条件。

## 二、为什么不能只用一个 Jenkinsfile

当前单项目模板可以构建并发布制品，但如果每个项目都复制一份完整 Jenkinsfile，会出现：

1. 修复公共问题时必须修改每个仓库。
2. Maven、Kaniko、Harbor 标签和凭据处理会逐渐漂移。
3. 手工导入 Job XML 与 Git 中的定义容易不同步。
4. 新增项目、分支或 PR 时需要人工创建 Job。

标准做法是把稳定、可复用的流程放到 Shared Library；各项目只声明“构建什么”和“项目差异”。

## 三、整体运行图

### 3.1 八层企业流水线架构总览

```text
┌─ 第1层：环境配置仓库 ──────────────────────────────────────────────────────┐
│  Helm values / Kustomize 基准配置                                           │
│  ├─ dev/values.yaml  （副本数少、日志 debug、小资源）                        │
│  ├─ test/values.yaml （副本数中等、日志 info、中等资源）                     │
│  └─ prod/values.yaml（副本数多、日志 warn、大资源、HPA、PDB）                │
│  功能：声明各环境的基础设施差异，与项目代码分离管理                            │
└─────────────────────────────────────────────────────────────────────────────┘
         │
         │ 引用 Secret（不存明文）
         v
┌─ 第2层：凭据与密钥层 ──────────────────────────────────────────────────────┐
│  Jenkins Credentials / Kubernetes Secret / 外部密钥系统                       │
│  ├─ Harbor 机器人 Token（镜像读写）                                          │
│  ├─ Nexus 部署用户密码（制品读写）                                           │
│  ├─ Git 仓库 Deploy Key（代码拉取）                                         │
│  └─ 环境证书 / 域名 TLS                                                    │
│  功能：敏感信息与配置分离，不出现在 Git 仓库中                                │
└─────────────────────────────────────────────────────────────────────────────┘
         │
         │ 加载凭据引用
         v
┌─ 第3层：Jenkins 平台层（管理员维护的平台仓库） ───────────────────────────────┐
│  Jenkins Helm values / JCasC + Remote Provider + Shared Library             │
│  功能：定义 Jenkins 自身配置、Job 模板、流水线函数库                          │
│  ├─ JCasC：Jenkins 全局配置（插件、安全策略、Agent 模板）                    │
│  ├─ Remote Provider：项目分支发现与平台 Jenkinsfile 分离                    │
│  └─ Shared Library：封装构建、测试、部署的公共流水线函数                      │
│  * 不要在 JCasC 或 Helm values 中保存明文密码，由第2层提供                   │
└─────────────────────────────────────────────────────────────────────────────┘
         │
         │ Jenkins 启动时加载 JCasC 和固定插件
         │ Multibranch 发现项目分支，从平台仓库加载脚本并 checkout scm
         v
┌─ 第4层：项目仓库层 ────────────────────────────────────────────────────────┐
│  Gitea 项目仓库                                                             │
│  ├─ order-service                                                          │
│  │  ├─ pom.xml                                                             │
│  │  └─ Dockerfile                                                          │
│  └─ member-service                                                         │
│     ├─ pom.xml                                                             │
│     └─ Dockerfile                                                          │
│                                                                             │
│  Gitea 平台配置仓库 admin/jenkins-platform                                    │
│  ├─ <project>/Jenkinsfile  ← 各项目受保护的正式流水线                         │
│  └─ vars/、resources/        ← 后续稳定后引入的公共流水线能力                  │
│  功能：项目仓库不承担 Jenkins 配置，平台统一维护构建和项目映射                │
└─────────────────────────────────────────────────────────────────────────────┘
         │
         │ 每次构建创建临时 Kubernetes Agent Pod
         v
┌─ 第5层：构建与制品层 ──────────────────────────────────────────────────────┐
│  Kubernetes Agent Pod（临时、隔离）                                          │
│  ├─ Maven 容器 ────────────────────────────────> Nexus（JAR/SNAPSHOT）     │
│  ├─ Kaniko 容器（无需 Docker daemon）──────────> Harbor（容器镜像）          │
│  ├─ 单元测试 / 静态代码扫描 / 依赖检查                                      │
│  └─ 构建完成后 Pod 自动销毁                                                 │
│  功能：编译、打包、镜像构建、推送制品                                        │
└─────────────────────────────────────────────────────────────────────────────┘
         │
         │ 部署编排（Pipeline 中调用 Helm / Kustomize）
         v
┌─ 第6层：部署编排层 ────────────────────────────────────────────────────────┐
│  Helm / Kustomize                                                          │
│  ├─ 从第1层获取环境 values，从第5层获取镜像 Tag                             │
│  ├─ 渲染 Kubernetes 资源清单（Deployment、Service、Ingress、ConfigMap）      │
│  ├─ 注入环境差异（第1层提供）                                               │
│  └─ 生成最终 YAML 并提交到 GitOps 仓库                                      │
│  功能：把制品 + 环境配置 → 可部署的 Kubernetes 清单                          │
└─────────────────────────────────────────────────────────────────────────────┘
         │
         │ 提交清单到 GitOps 仓库（或直接由 Argo CD 监听）
         v
┌─ 第7层：GitOps 控制器层 ───────────────────────────────────────────────────┐
│  Argo CD / Flux                                                             │
│  ├─ 监听 Git 仓库中的期望状态（Deployment 的镜像版本、副本数等）              │
│  ├─ 自动同步到目标集群 / 命名空间                                           │
│  ├─ 差异检测：集群实际状态 vs Git 期望状态                                  │
│  └─ 异常时自动回滚或告警                                                   │
│  功能：Git 仓库是唯一真相来源（Single Source of Truth），控制器确保集群一致    │
└─────────────────────────────────────────────────────────────────────────────┘
         │
         │ 部署到不同环境
         v
┌─ 第8层：环境晋级层 ────────────────────────────────────────────────────────┐
│  dev ──> test ──> prod                                                      │
│                                                                             │
│  dev（开发环境）                                                            │
│  ├─ 自动部署：代码合并到 dev 分支即触发                                      │
│  ├─ 自动运行集成测试                                                        │
│  └─ 失败时阻塞下一次合并                                                    │
│                                                                             │
│  test（测试环境）                                                           │
│  ├─ 手动触发或定时部署                                                      │
│  ├─ 运行完整测试套件 + 性能/安全扫描                                        │
│  └─ 通过后生成测试报告，准备晋级                                            │
│                                                                             │
│  prod（生产环境）                                                           │
│  ├─ 需要审批（手动确认 + 变更审批）                                          │
│  ├─ 金丝雀发布：先切 10% 流量，观察无异常后全量                              │
│  └─ 支持蓝绿部署 / 快速回滚                                                │
│                                                                             │
│  功能：保证代码安全地逐级上线，不同环境有不同的准入标准和自动化程度              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 数据流简要说明

```
第1层（环境配置） ──── 第6层（部署编排）渲染时读取 values
第2层（凭据密钥） ──── 第3层（Jenkins）引用，第5层（构建）运行时注入
第3层（Jenkins）  ──── 第4层（项目仓库）扫描并触发构建
第4层（项目仓库） ──── 第5层（构建）生成制品
第5层（构建）    ──── 第6层（部署编排）消耗制品
第6层（部署编排） ──── 第7层（GitOps）提交/监听清单
第7层（GitOps）  ──── 第8层（环境晋级）控制部署目标
```

### 3.3 各层关键原则

| 层次 | 关键原则 |
|------|---------|
| 第1层 环境配置 | 与环境相关，不与项目耦合 |
| 第2层 凭据密钥 | 不存明文到 Git，只存引用 |
| 第3层 Jenkins 平台 | 只配置 Jenkins 自身，不包含业务逻辑 |
| 第4层 项目仓库 | 只声明"构建什么"，不关心"怎么构建" |
| 第5层 构建制品 | 每次构建在独立临时 Pod 中运行，环境隔离 |
| 第6层 部署编排 | 部署模板与配置分离，环境差异通过 values 注入 |
| 第7层 GitOps | Git 是唯一真相来源，集群状态自动同步 |
| 第8层 环境晋级 | 不同环境不同准入标准，逐级晋升，失败阻断 |

平台仓库中的 Jenkinsfile 或 Shared Library 调用公共函数；Nexus 和 Harbor 的用户名、密码或机器人 Token 只保存在 Jenkins Credentials 或外部密钥系统中。

## 四、各层职责

### 4.1 Helm values 和 JCasC

这一层只配置 Jenkins 平台本身，例如：

- Jenkins 版本、插件和 Kubernetes Agent Pod 模板；
- 管理员账号的 Secret 引用；
- Controller 的资源限制、持久化和 URL；
- Shared Library 的全局定义；
- 可通过 JCasC 管理的安全策略、全局工具和凭据引用。

不要在 JCasC 或 Helm values 中保存明文密码、Harbor Token、Nexus 密码或业务仓库私钥。Secret 由 Kubernetes Secret、Jenkins Credentials 或外部密钥系统提供。

本环境中 Jenkins Chart 的管理员 Secret 已由 `jenkins/jenkins-admin` 提供。该 Secret 的键和 Chart 配置必须保持一致，不能为了“统一配置”删除已有密码管理方式。

### 4.2 Job DSL

Job DSL 是 Jenkins 插件提供的 Groovy DSL，用来用代码创建 Job。它适合创建：

- 一个或多个 Multibranch Pipeline；
- 文件夹、默认构建保留策略和权限边界；
- 种子 Job（seed job）自身以外的 Job。

Job DSL 解决“谁创建 Jenkins Job”的问题。推荐把 DSL 保存到平台配置仓库，由一个受限的种子 Job 执行。不要把 Job XML 当作多项目的长期唯一来源；XML 导入只用于受控的一次性验证。

示意 DSL：

```groovy
multibranchPipelineJob('services/order-service') {
    branchSources {
        branchSource {
            source {
                git {
                    id('order-service')
                    remote('http://gitea.example.com/admin/order-service.git')
                    credentialsId('gitea-scm-readonly')
                }
            }
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
    orphanedItemStrategy {
        discardOldItems {
            numToKeep(1)
        }
    }
}
```

示例中的仓库地址和凭据 ID 必须替换为实际值；凭据值不写入 DSL。Job DSL 的具体语法依赖已安装插件版本，先在测试 Job 中生成并审核变更，再作用于正式 Job。

### 4.2.1 Job DSL 启用条件

`k3s-jenkins-values.yaml` 固定 Configuration as Code、Pipeline、Git 和 Multibranch 相关插件。启用 Job DSL 时，还必须同时提供固定版本的 `job-dsl` 插件、种子 Job、平台配置仓库和 Shared Library 全局配置；缺少任一项时不得宣称 Jenkins 能自动创建多项目 Job。

启用 Job DSL 前必须：

1. 在 Jenkins values 中增加经过验证且固定版本的 `job-dsl` 插件。
2. 通过 JCasC 或受控方式创建种子 Job。
3. 给种子 Job 配置平台仓库的只读凭据和最小 Job 管理权限。
4. 在测试 namespace 或测试 Jenkins 实例验证 DSL，再推广到当前实例。

不能只把 Job DSL Groovy 文件放进 Git 就认为 Jenkins 会自动执行它。

### 4.3 Multibranch Pipeline

Multibranch Pipeline 让 Jenkins 扫描一个代码仓库，并为符合识别条件的分支创建子 Job。原生模式要求项目分支包含 Jenkinsfile；Remote Jenkinsfile Provider 模式忽略该要求，改从独立平台仓库加载脚本。

本环境的项目仓库没有 Jenkinsfile，并且需要自动发现分支，因此当前采用 Remote Jenkinsfile Provider + Multibranch Pipeline：项目仓库只用于分支发现和源码 checkout，流水线脚本从受保护的平台配置仓库加载。插件固定为 `remote-file:1.24`，必须先在当前 Jenkins 版本完成兼容性、扫描和真实构建验证。Job DSL + Seed Job 只作为插件验证失败时的过渡方案，不能把不存在的 Jenkinsfile 当作已启用能力。

```text
services/order-service
├─ master        -> 自动创建 master 子 Job
├─ feature/pay   -> 自动创建 feature/pay 子 Job（若策略允许）
└─ release/1.2   -> 自动创建 release/1.2 子 Job
```

它的价值是：分支和 Jenkinsfile 由 Git 管理，创建分支后无需手工复制 XML。对于个人开发环境，应限制扫描范围和非活跃分支保留数量，避免临时分支耗尽资源。

建议策略：

- `master` 或 `main`：允许构建和发布开发制品；
- `release/*`：允许发布候选制品；
- `feature/*`：默认只编译和测试，不发布到 release 仓库；
- Pull Request：默认只验证，不发布制品或推送正式镜像；
- 删除分支后：保留有限构建历史，自动清理对应子 Job。

具体分支策略必须由团队确认，不能假定所有项目都使用 `master` 分支。

### 4.4 Jenkins Shared Library

Shared Library 是一个独立 Git 仓库，保存可复用的 Pipeline Groovy 代码。例如：

```text
company-jenkins-library/
├─ vars/
│  └─ javaArtifactPipeline.groovy
├─ src/
│  └─ com/company/ci/...
└─ resources/
   └─ ...
```

建议将以下稳定逻辑集中在 Shared Library：

- 配置校验；
- Maven 编译、测试、Nexus 发布；
- Kaniko 构建和 Harbor 推送；
- Git SHA 和构建号形成镜像标签；
- 临时文件清理、超时、并发和构建保留策略；
- 发布元数据、日志脱敏和通知。

目标架构中的平台 Jenkinsfile 只负责读取受保护的项目差异并调用 Shared Library：

```groovy
@Library('company-pipeline@v1') _

javaArtifactPipeline(
    platformConfig: 'projects/order-service.properties'
)
```

`@v1` 表示固定到经过验证的库版本或分支，而不是无条件跟随最新提交。Shared Library 的变更要通过测试和版本发布，避免一次公共修改影响所有项目。

### 4.5 环境配置仓库

环境配置仓库保存 dev、test、prod 的非敏感差异，不与构建逻辑混在项目 Jenkinsfile 中。例如：

```text
platform-environments/
├─ dev/
│  ├─ values.yaml
│  └─ kustomization.yaml
├─ test/
│  ├─ values.yaml
│  └─ kustomization.yaml
└─ prod/
   ├─ values.yaml
   └─ kustomization.yaml
```

这里可以保存 namespace、域名、资源规格、外部服务地址、副本数和发布策略；密码、Token、证书私钥仍由 Secret 管理系统提供。环境仓库不应保存构建出来的 JAR 或镜像二进制文件，而应引用经过验证的不可变版本，例如镜像 digest 或正式制品版本。

环境仓库的变更可以通过 Pull Request 审核和 Git 历史追踪。构建流水线负责生成和签名制品，环境变更流程负责决定哪个环境使用哪个已生成制品，两者职责分开。

### 4.6 Helm、Kustomize 和 GitOps 部署配置

Kubernetes 部署配置不应全部嵌入 Jenkinsfile。常见分工如下：

```text
Helm Chart
    公共 Deployment、Service、ConfigMap、探针和资源模板

Kustomize overlay 或 Helm values
    dev/test/prod 的环境差异

GitOps 控制器（例如 Argo CD 或 Flux）
    监听环境仓库，并将期望状态同步到 Kubernetes
```

如果当前个人环境暂时不安装 GitOps 控制器，也应先把 Helm values 或 Kustomize 清单放入版本库，由经过审核的发布步骤执行 `helm upgrade` 或 `kubectl apply`。不要让 Jenkinsfile 里散落大量内联 YAML 和不可审计的 `kubectl patch`。

当前目录的基础设施 values 文件属于平台安装配置，不等同于业务应用的环境仓库。Jenkins 使用官方安装指南推荐的 `jenkins` namespace；Harbor、Nexus、Nacos 和 MySQL 使用本环境批准的企业约定 namespace。未来部署业务应用时，应按环境、责任团队、安全等级和生命周期规划可共享的业务 namespace，并单独建立 Chart/Overlay 和环境配置。

## 五、为什么要分层

分层的核心不是增加文件数量，而是让每类变更由正确的责任边界管理：

| 变更内容 | 归属 | 主要收益 |
|---|---|---|
| Jenkins 版本、插件、Agent | Helm values / JCasC | 平台可重建，升级有版本记录 |
| Job 和分支发现 | Remote Provider + Multibranch | 新分支自动接入，构建入口由平台控制 |
| Maven、测试、镜像公共逻辑 | Shared Library | 修复一次，所有项目按版本复用 |
| 项目构建入口 | 平台仓库 Jenkinsfile / Shared Library | 项目代码不携带 Jenkins 配置 |
| 应用名、仓库 URL、分支和 Dockerfile 路径 | 平台项目映射文件 | 项目差异集中管理，不复制公共逻辑 |
| dev/test/prod 地址和副本数 | 环境配置仓库 | 同一制品可跨环境晋级，变更可审核 |
| 密码、Token、私钥 | Credentials / Secret | 防止凭据进入 Git 和构建日志 |
| Kubernetes 部署状态 | Helm/Kustomize/GitOps | 部署可回滚、可审计、可重复 |

这样可以实现“构建一次，多环境使用”：

```text
源码 -> 测试 -> 生成不可变 JAR/镜像
                  |
                  +-> dev 环境验证
                  +-> test 环境验证
                  +-> 审核后晋级 prod
```

如果把这些内容全部写进 Jenkinsfile，构建代码会同时承担平台管理、环境管理、凭据管理和部署状态管理，最终难以审计，也难以证明生产环境运行的确实是哪个制品。

## 六、项目仓库应该保存什么

以 Java Maven 项目为例：

```text
order-service/
├─ pom.xml
├─ Dockerfile
└─ src/
```

项目仓库不保存 Jenkinsfile、`.ci/pipeline.properties` 或发布凭据。平台 Jenkinsfile 为每个项目保存非敏感构建差异，例如：

```properties
app.name=order-service
container.dockerfile=Dockerfile
container.context=.
```

项目仓库 URL、凭据和分支发现规则属于 Multibranch Branch Source。当前分支必须使用 Jenkins 提供的 `scm` 与 `BRANCH_NAME`；不得在平台 properties 中固定 `app.repository.branch`，否则其他分支子 Job 会错误构建同一个分支。Remote Jenkinsfile Provider 只提供 Jenkinsfile，不会自动 checkout 同仓库的旁路配置文件；若脚本需要独立配置文件，必须显式 checkout 平台仓库并校验固定分支或提交。

Nexus/Harbor 地址、仓库、Credential ID 和 `SKIP_TESTS` 不从项目仓库读取；由平台流水线和 Jenkins Job 控制。密码、Token、私钥和数据库连接口令始终只保存在 Jenkins Credentials 或外部密钥系统中。实际发布环境的 registry 地址应使用受信任 TLS，不应长期沿用个人环境中的 `--skip-tls-verify-registry`。

## 七、首次引导顺序

先严格按基础设施 SOP 完成 `Rancher -> Jenkins -> Nexus -> Harbor -> Nacos -> MySQL`，并通过 Nexus/Harbor 真实制品验收；不得在 Jenkins 安装阶段提前创建或构建 Multibranch Job。平台流水线自举随后按以下顺序完成：

```text
1. 确认全部基础设施阶段和业务门禁通过
2. 创建 `gitea-scm-readonly`、`jenkins-platform-readonly`、`nexus-deployer`、`harbor-robot` 四项正式 Jenkins Credentials；仅在迁移阶段临时保留 `aliyun-codeup-token`
3. 将平台 Jenkinsfile 提交到受保护的平台 Git 分支或不可变版本
4. 在 Helm values 固定 Remote Jenkinsfile Provider 插件并完成升级验证
5. 创建 Multibranch Job：项目仓库发现分支，平台仓库提供 Jenkinsfile
6. Multibranch 子 Job 按 `BRANCH_NAME` checkout 对应项目分支
7. 项目提交、Webhook 或定时扫描触发构建
```

这不是“手工操作无法避免”，而是平台自举过程。首次 Multibranch Job 可通过受控管理流程创建；后续应将其配置纳入 JCasC、Job DSL 或备份恢复机制，不应重复手工导入 Job XML。

## 八、凭据与权限边界

建议使用最小权限、按用途拆分的凭据：

| 用途 | Jenkins Credential ID 示例 | 权限范围 |
|---|---|---|
| 读取代码 | `gitea-scm-readonly` | 只读指定 Gitea 组织或项目 |
| Maven 发布 | `nexus-deployer` | 仅发布所需 Maven 仓库 |
| 镜像推送 | `harbor-robot` | 仅推送指定 Harbor Project |
| 平台配置 | `jenkins-platform-readonly` | 只读平台配置仓库 |

不能把管理员账号或 Harbor 全局管理员账号用于日常构建。Token 轮换时先在 Jenkins Credentials 更新，再验证构建，不要把新 Token 提交进 Git。

当前 Jenkins Agent 不直接读取 Kubernetes Secret；它通过 Jenkins Credentials 使用发布凭据。这是有意的最小权限设计。未来如确实需要读取集群 Secret，必须单独审查 ServiceAccount、namespace 和只读范围。

## 九、个人开发环境的最小落地版本

当前环境资源有限，最小可行版本可以只做：

```text
Remote Jenkinsfile Provider
    + 一个 Multibranch Job
    + 受保护的平台 Jenkinsfile
    + Shared Library（公共逻辑稳定后抽取）
    + Nexus / Harbor / Kubernetes Agent
```

暂不引入 SonarQube、全量漏洞扫描、审批系统和生产部署控制器。待项目数量、团队协作或生产发布需求明确后，再逐步增加测试门禁、SBOM、镜像签名、扫描和环境晋级。

## 十、验收标准

完成最小落地后，应验证：

1. `remote-file:1.24` 能在当前 Jenkins 加载，升级可回滚。
2. Multibranch 能自动发现预期分支，并从受保护的平台仓库加载固定 Jenkinsfile。
3. 子 Job 能按 `BRANCH_NAME` checkout 对应项目分支，项目仓库无需 Jenkinsfile。
4. 测试分支不发布 release 制品或正式镜像。
5. 发布凭据未出现在 Git、构建日志或构建归档中。
6. Maven 制品可在 Nexus 的预期仓库查询到。
7. 镜像可在 Harbor 的预期 Project 查询到，并带有可追溯的 Git SHA 和构建号。
8. 删除临时分支后，对应子 Job 按保留策略清理，基础设施资源没有持续增长。

## 十一、当前文件职责

旧的 Codeup 单项目 Jenkinsfile、项目配置和手工 Job XML 已废弃并从本目录删除。当前正式平台脚本位于 Gitea `admin/jenkins-platform` 项目的各项目目录，例如 `demo-springboot/Jenkinsfile`；脚本使用 `checkout scm` 与 `BRANCH_NAME`，通过 Remote Provider + Multibranch 加载。Codeup 仅作为迁移历史，不得用于新建 Job。

本次 Remote Provider + Multibranch 最小验收必须具备：

- 平台仓库中的受保护 Jenkinsfile 和项目映射；
- 固定版本的 Remote Jenkinsfile Provider 和 Multibranch Job 配置；
- 项目 Branch Source、平台 Jenkinsfile SCM、脚本路径与保留策略；
- 对 Nexus 坐标、Harbor 镜像、凭据和分支发布策略的完整验收。

Shared Library 是多项目公共逻辑稳定后的目标组件；引入时按固定版本引用并单独验收，但不阻塞本次单项目 Multibranch 验证。

缺少上述配套资产时，本目录文件只承担单项目基础链路验证，不代表多项目自动化已经启用。
