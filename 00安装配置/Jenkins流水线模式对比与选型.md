# Jenkins 流水线模式对比与选型

本文比较当前可选的 Jenkins 流水线组织方式，并结合“项目仓库不保存 Jenkins 文件”的约束给出选型建议。

## 一、先看结论

```text
项目仓库允许 Jenkinsfile
    -> 原生 Multibranch Pipeline

项目仓库禁止 Jenkinsfile，但需要自动发现分支
    -> Remote Jenkinsfile Provider + Multibranch

项目仓库禁止 Jenkinsfile，分支数量少且受控
    -> Job DSL 创建 Pipeline Job

多个项目共享构建逻辑
    -> Shared Library（可与以上任一模式组合）
```

Shared Library 不是分支发现方式，而是公共流水线代码库，可以与 Multibranch、Remote Jenkinsfile Provider 或 Job DSL 一起使用。

## 二、四种模式总图

```text
                           +----------------------+
                           |  项目仓库             |
                           |  源码 / pom / Dockerfile|
                           +----------+-----------+
                                      |
                    +-----------------+-----------------+
                    |                                   |
                    v                                   v
       +---------------------------+       +---------------------------+
       | 原生 Multibranch          |       | Remote Jenkinsfile         |
       | 分支中必须有 Jenkinsfile   |       | 分支由项目仓库发现          |
       +-------------+-------------+       | 脚本从平台仓库加载          |
                     |                     +-------------+-------------+
                     v                                   |
              每个分支一个子 Job                         |
                                                         v
                                               每个分支一个子 Job

       +---------------------------+       +---------------------------+
       | Job DSL Pipeline Job       |       | Shared Library              |
       | 平台创建 Job 和分支映射     |       | 被其他模式调用的公共代码     |
       | 不依赖项目 Jenkinsfile      |       | 不负责扫描分支或创建 Job     |
       +---------------------------+       +---------------------------+
```

## 三、模式一：原生 Multibranch Pipeline

```text
Jenkins
  |
  +-- 扫描 Gitea 仓库
        |
        +-- master/Jenkinsfile  -> master 子 Job
        +-- develop/Jenkinsfile -> develop 子 Job
        +-- feature/a/Jenkinsfile -> feature/a 子 Job
```

特点：

- Jenkins 自动发现分支；
- 每个分支必须有可执行的 Jenkinsfile；
- 适合项目团队自己维护构建入口；
- 项目提交者可以修改 Jenkinsfile，必须配合受信任 Shared Library 和平台门禁；
- 分支删除后可以自动清理子 Job。

当前项目不满足“仓库没有 Jenkinsfile”的前提，因此不能直接采用。

## 四、模式二：Remote Jenkinsfile Provider

```text
Gitea 项目仓库                           Gitea 平台流水线仓库
  master                                企业流水线.Jenkinsfile
  develop              +--------------> Shared Library
  feature/a            |                 分支发布策略
                       |
                       v
               Remote Jenkinsfile Provider
                       |
                       v
             Multibranch 子 Job 执行平台脚本
```

特点：

- 分支仍由项目仓库自动发现；
- 项目仓库不保存 Jenkinsfile；
- Jenkins 从受保护的平台仓库加载统一脚本；
- 最符合当前项目约束；
- 依赖额外插件，必须固定版本并验证与 Jenkins 版本兼容；
- 插件配置、平台仓库权限和脚本路径必须纳入备份和审计。

安全边界：

- 项目仓库只能提供源码和分支；
- Nexus/Harbor 地址、Credential ID、发布规则由平台脚本或 Shared Library 控制；
- 平台脚本仓库必须限制写权限；
- 不能允许项目提交覆盖远程脚本地址。

## 五、模式三：Job DSL 创建 Pipeline Job

```text
平台配置仓库
  |
  +-- 项目映射
  |     demo-springboot -> Gitea URL
  |     分支 master      -> 构建策略
  |
  +-- Job DSL / Seed Job
          |
          +-- demo-springboot-master Job
          +-- demo-springboot-develop Job
          +-- demo-springboot-release Job
```

特点：

- 项目仓库不需要 Jenkinsfile；
- 分支、项目地址、权限和 Job 名称都由平台控制；
- 适合项目数量少、分支集合明确的个人或受控环境；
- 新分支需要重新执行 Seed Job 或配置扫描；
- 不是真正的自动分支发现，分支管理成本随分支数量增长。

当前测试项目使用的是这个方向的临时验证版本：`old-project-platform-pipeline`。正式使用时应改为 Job DSL + Seed Job，不能长期依赖手工 API 创建的内联脚本。

## 六、模式四：Shared Library

Shared Library 不负责发现分支，而是负责复用公共逻辑：

```text
company-jenkins-library/
├─ vars/
│  └─ javaArtifactPipeline.groovy
├─ src/
│  └─ com/company/ci/BranchPolicy.groovy
└─ resources/

javaArtifactPipeline()
  +-- checkout
  +-- 测试门禁
  +-- Maven/Nexus
  +-- Kaniko/Harbor
  +-- 分支发布策略
  +-- 元数据和清理
```

调用关系：

```text
Multibranch / Remote Jenkinsfile / Job DSL Job
                         |
                         v
              @Library('company-pipeline@v1')
                         |
                         v
                   Shared Library
```

企业要求：

- Shared Library 放在受保护的平台 Git 仓库；
- 使用固定版本或标签，例如 `@v1.2.0`；
- 密码、Token 和私钥不能放入库中；
- 分支发布策略集中维护，不能由项目配置文件覆盖；
- 修改公共库必须经过测试和版本审核。

## 七、对比表

| 项目 | 原生 Multibranch | Remote Jenkinsfile | Job DSL Pipeline Job | Shared Library |
|---|---|---|---|---|
| 自动发现分支 | 是 | 是 | 否，需重新生成 Job | 不负责 |
| 项目需要 Jenkinsfile | 是 | 否 | 否 | 否 |
| 项目提交者可改构建入口 | 可以 | 通常不可以 | 不可以 | 不可以 |
| 是否需要额外插件 | 基础插件 | 需要 Provider 插件 | 需要 Job DSL | 基础 Shared Library 支持 |
| 分支权限集中控制 | 中 | 高 | 高 | 高 |
| 新分支接入成本 | 低 | 低 | 中到高 | 不适用 |
| 适合当前项目 | 否 | 是 | 是，分支少时 | 应该配套 |
| 运维复杂度 | 中 | 高 | 中 | 中 |

## 八、当前环境的推荐架构

```text
Gitea 项目仓库
  源码 / pom.xml / Dockerfile
          |
          v
Remote Jenkinsfile Provider（安装后验证）
          |
          v
Multibranch Pipeline
          |
          v
Shared Library @v1（平台维护）
          |
          +--> 测试和分支门禁
          +--> Nexus 发布
          +--> Harbor 推送
```

当前推荐实施路径为：

```text
Remote Jenkinsfile Provider 1.24（固定版本）
    -> Multibranch 自动发现项目分支
    -> 从受保护的平台仓库加载 Jenkinsfile
    -> Shared Library 执行公共逻辑（后续抽取）
```

插件必须先在当前 Jenkins `2.568.2` 上完成真实扫描和构建验证。现有 PVC 增加插件时使用固定插件清单并将 `initializeOnce` 设为 `false`；升级前在 PVC 外备份插件和 Job 配置。若出现插件加载、配置持久化或分支扫描兼容性问题，先恢复 Jenkins Home 备份，再回滚 Helm revision，并使用 Job DSL + Seed Job 作为过渡方案；Helm rollback 本身不能撤销 PVC 中的插件和 Job，回退也不要求项目仓库增加 Jenkinsfile。

## 九、分支发布策略建议

```text
Pull Request / feature/*
    -> 编译、测试、静态检查
    -> 不发布 Nexus release，不推送正式镜像

main/master
    -> 默认发布 Snapshot 或开发镜像

release/*
    -> 测试必须开启
    -> 发布候选制品

Tag / 正式发布 Job
    -> 权限校验、审批、测试和扫描通过后发布
```

`SKIP_TESTS` 可以作为构建参数存在，但正式发布策略应在平台库中强制为 `false`，不能仅依赖用户手工选择。

## 十、实施顺序

1. 固定平台配置仓库权限，将 Jenkinsfile 和项目映射提交到受保护分支。
2. 在 Helm values 中固定 `remote-file:1.24`，完成渲染、服务端 dry-run 和回滚基线记录。
3. 升级 Jenkins，验证插件加载、登录、凭据和现有 Job 无回归。
4. 创建 Remote Jenkinsfile Provider 类型的 Multibranch Job，首次只扫描 `master`。
5. 验证 `master`、`feature/*`、`release/*` 的构建和发布规则。
6. 验证成功后将该 Multibranch Job 作为正式入口，旧的 Codeup Job 禁用并保留审计记录。
7. 仅当 Provider 兼容性失败时，安装固定版本 Job DSL 并用 Seed Job 创建过渡 Job。

## 十一、当前验证状态

`build-demo-springboot-artifacts` 已完成正式链路验证：

- Gitea 项目仓库分支发现和 checkout 成功；
- 平台 Jenkinsfile 从 Gitea `admin/jenkins-platform` 的固定审核提交加载成功；
- `feature/pipeline-check` 构建成功；
- `master` 在 `SKIP_TESTS=false` 下测试、Maven 发布和镜像构建均成功；
- `release/pipeline-check` 因项目版本为 `SNAPSHOT` 按发布门禁预期阻断；
- 旧的 `old-project-platform-pipeline` 已禁用，Codeup 仅保留迁移阶段凭据。
