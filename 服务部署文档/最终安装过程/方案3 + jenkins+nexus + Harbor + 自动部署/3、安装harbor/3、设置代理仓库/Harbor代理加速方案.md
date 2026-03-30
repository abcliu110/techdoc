# Harbor 代理加速方案

## 适用范围

本文档适用于以下环境：

- RKE2 集群
- Jenkins 在集群内执行构建任务
- Kaniko 负责镜像构建与推送
- Harbor 作为内网镜像仓库
- 业务镜像推送到 Harbor
- 基础镜像通过 Harbor 代理缓存获取

本文档不包含任何 Docker daemon 相关操作。

## 目标

让 Jenkins 中的 Kaniko 在构建镜像时，优先通过 Harbor 代理缓存获取基础镜像，而不是直接访问公网镜像站。

## 实际链路

```text
Jenkins -> Kaniko -> Harbor 代理缓存项目 -> 上游镜像源
                    -> Harbor 本地缓存
```

## 前提说明

### 1. 当前流水线机制

当前 Jenkins 日志显示，基础镜像拉取走的是 registry remap 机制，而不是构建参数传入基础镜像地址。

典型日志如下：

```text
Retrieving image manifest eclipse-temurin:21-jre
Retrieving image eclipse-temurin:21-jre from mapped registry harbor.harbor
```

这说明当前方案的关键不在应用代码，而在 Harbor 代理缓存配置是否正确。

### 2. 当前不需要改应用仓库

在现有方案下：

- 不需要修改业务模块源码
- 不需要修改应用镜像构建文件中的基础镜像写法
- 不需要增加额外构建参数

优先修复 Harbor 代理缓存配置，再重新触发 Jenkins 构建。

## 正确配置步骤

### 步骤1：在 Harbor 中创建上游仓库目标

进入：

`系统管理 -> 仓库管理`

创建一个上游仓库目标，例如：

- 名称：`dockerhub-proxy`
- 提供者：`Docker Registry`
- 目标 URL：`https://docker.m.daocloud.io`

说明：

- 如果服务器可以稳定访问官方源，也可以使用官方上游地址
- 如果服务器无法稳定访问公网，优先使用可访问的国内镜像源
- 这一步创建的是“上游仓库目标”，不是业务项目

### 步骤2：在 Harbor 中创建代理缓存项目

进入：

`项目 -> 新建项目`

创建项目时需要满足以下条件：

- 项目名称：`dockerhub-proxy`
- 访问级别：按实际需要设置，通常可设为公开
- 项目类型：代理缓存项目
- 上游仓库：绑定步骤1中创建的 `dockerhub-proxy`

注意：

- 这里不能只创建普通项目
- 如果只创建普通项目，Harbor 只会把它当成本地空项目处理
- 普通项目会导致这类错误：

```text
NOT_FOUND: repository dockerhub-proxy/library/eclipse-temurin not found
```

### 步骤3：确认代理缓存项目已生效

项目创建完成后，重点确认以下几点：

- Harbor 中存在项目 `dockerhub-proxy`
- 该项目是“代理缓存项目”，不是普通项目
- 该项目已经正确绑定到上游仓库目标 `dockerhub-proxy`

如果这一步未配置正确，Jenkins 构建时通常会出现下面两类错误：

项目不存在：

```text
project dockerhub-proxy not found
```

项目存在但不是可用的代理缓存项目：

```text
repository dockerhub-proxy/library/eclipse-temurin not found
```

### 步骤4：重新触发 Jenkins 构建验证

重新执行构建后，重点看 Kaniko 日志中的基础镜像拉取阶段。

期望日志特征：

```text
Retrieving image manifest eclipse-temurin:21-jre
Retrieving image eclipse-temurin:21-jre from mapped registry harbor.harbor
```

如果 Harbor 代理缓存正常，后续不应再出现：

- `project dockerhub-proxy not found`
- `repository dockerhub-proxy/library/eclipse-temurin not found`
- 回退到 `index.docker.io`

如果日志仍然出现：

```text
Retrieving image eclipse-temurin:21-jre from registry index.docker.io
```

说明 Harbor 代理缓存仍未正确命中，Kaniko 又回退到了公网镜像站。

## 故障含义对照

### 1. `project dockerhub-proxy not found`

含义：

- Harbor 中没有 `dockerhub-proxy` 这个项目
- 或项目尚未创建完成

### 2. `repository dockerhub-proxy/library/eclipse-temurin not found`

含义：

- `dockerhub-proxy` 项目已经存在
- 但该项目不是正确的代理缓存项目
- 或者该项目没有正确绑定上游仓库目标

### 3. `index.docker.io ... i/o timeout`

含义：

- Harbor 代理缓存未命中或不可用
- Kaniko 回退到公网镜像站
- 当前构建环境无法访问 Docker Hub

这通常是 Harbor 代理配置失败后的连带结果，不是首要修复点。

## 本次环境的正确判断

结合当前实际日志，问题演进如下：

1. 最初报错：`project dockerhub-proxy not found`
   说明 Harbor 中还没有这个项目

2. 后续报错：`repository dockerhub-proxy/library/eclipse-temurin not found`
   说明项目已经建了，但建成了普通项目，或者没有正确配置为代理缓存项目

3. 最后回退到 `index.docker.io` 超时
   说明 Harbor 没接住请求，构建环境又不能稳定访问公网

因此，当前优先级最高的工作是修正 Harbor 代理缓存项目配置，而不是修改业务代码。

## 建议的检查清单

在重新构建前，先确认以下内容：

1. `系统管理 -> 仓库管理` 中已存在上游仓库目标 `dockerhub-proxy`
2. `项目` 中已存在项目 `dockerhub-proxy`
3. 该项目类型是代理缓存项目，而不是普通项目
4. 该项目已绑定上游仓库目标 `dockerhub-proxy`
5. Jenkins 当前使用的 Harbor 域名与实际一致
   例如：`harbor.harbor`

## 预期结果

修正完成后，Jenkins 构建基础镜像时应优先命中 Harbor，而不是回退到公网镜像站。

这样可以避免：

- 公网超时
- 基础镜像反复拉取失败
- 多模块构建连续失败

同时保持当前应用仓库和构建流程不做额外改动。
