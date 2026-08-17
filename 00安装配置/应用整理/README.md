# 应用整理

本目录由 `D:\resources (1)\resources` 的静态 Deployment 定义整理生成。原始目录不修改；本目录不包含 Kubernetes `status`、`managedFields`、UID、资源版本、创建时间或 Rancher/Cattle 运行态注解。

## 目录

- `base/`：清理后的单应用 Deployment 定义。
- `bundles/already-present.yaml`：安装基线中已有的组件，仅作定义归档，不应重复 apply。
- `bundles/incremental.yaml`：不属于安装基线的增量组件集合，仍需逐项补齐 Service、PVC、ConfigMap、Secret 和镜像来源后才能部署。
- `bundles/default-enabled.yaml`：默认启用的增量组件集合。
- `bundles/default-disabled.yaml`：默认 `replicas: 0` 的按需组件集合；应用后不会创建 Pod。
- `bundles/data.yaml`、`messaging.yaml`、`business.yaml`、`platform.yaml`：按用途拆分的静态集合。
- `bundles/lgy-business.yaml`：开发服务器业务候选集合，统一目标 namespace 为 `lgy`；不包含已部署基础设施、gateway 和 Kafka。
- `overlays/lgy/`：第一批业务工作负载的可部署清单，包含 Service 与低资源配置；只使用 Harbor 中已存在的业务镜像，并复用现有 Nacos/MySQL。
- `inventory.yaml`：应用、镜像、PVC 和 Secret 引用清单。

## 安全约束

密码和 Token 不保存在本目录。敏感环境变量已改为 `<app>-secrets` 的 Secret 引用；Secret 必须由受控部署流程预先在目标 namespace 创建。

## 部署前必须补齐

1. 复核镜像地址和当前镜像仓库认证。
2. 为每个 PVC、ConfigMap、Secret、Service 建立独立清单。
3. 核对跨 namespace 的 MySQL/Nacos 服务地址。
4. 在低配虚拟机上按阶段启用，不能直接 apply 全部增量组件。
5. 使用 `kubectl apply --dry-run=server` 和实际回归验收。

## 当前开发服务器部署边界

- 已存在的 Nacos、MySQL、Harbor、Jenkins、Nexus、Gitea 和 K3s 基础组件不重复部署。
- Kafka 永不加入本次候选集合。
- 业务候选统一部署到 `lgy` namespace；基础设施继续保留在各自已批准 namespace。
- 业务应用访问已有基础设施必须使用跨 namespace Service 全名，例如 `nacos.nacos.svc.cluster.local:8848` 和 `mysql.mysql.svc.cluster.local:3306`，不得在 `lgy` 复制同名数据库或配置中心。
- `lgy` 的 Secret 只能由受控初始化脚本从现有平台凭据同步创建。用户名和密码必须与现有应用约定一致；密码不得写入本目录的 YAML、Kustomize values、连接串或 Git。
- `lgy-business.yaml` 只是候选入口。第一批业务安装使用 `overlays/lgy/`；Gateway 和任何缺失 Harbor 镜像的应用均不包含其中。Redis 已作为共享依赖启用；Nginx 已独立部署，不属于业务候选清单。
- Nginx 运行于 `lgy` namespace，使用 Harbor Docker Hub Proxy Cache 的固定镜像 `dockerhub/library/nginx:1.25.3`，配置为 1 个副本、`25m/32Mi` requests 和 `150m/128Mi` limits；仅提供 ClusterIP Service，不创建 PVC、NodePort 或 hostPort。2026-08-14 已完成服务端预检、Deployment rollout、Ready Endpoint 和 HTTP 200 探针验收。
- Gateway 运行于 `lgy` namespace，使用 Harbor 制品 `library/yd4cloud-gateway:1`。它是最小 Spring Cloud Gateway 4.1.0 启动器，只提供 ClusterIP `gateway:8080` 和健康端点，不含原服务器业务路由或凭据。资源为 `25m/128Mi` requests、`250m/256Mi` limits；实测内存约 `212Mi`。同 digest 的 `latest` 仅用于人工核对，Deployment 不得引用。2026-08-14 已完成服务端预检、rollout、Ready Endpoint 和 `/actuator/health/readiness` 返回 `UP` 的验收。
- `overlays/lgy/` 中七个业务 Deployment 当前固定为 `replicas: 0`。它们不创建 Pod，因而不消耗业务实例的 CPU 或内存；Service 保留，便于依赖和端口核对。
- Redis、EMQX 和 RocketMQ（NameServer、Broker、Console）是本环境已启用的共享依赖，运行在 `lgy` namespace。它们均使用 ClusterIP Service；Redis 的 AOF 数据使用 `redis-data` PVC，密码只保存在 `lgy/redis-auth` Secret。
- RocketMQ Console 的 Java 进程需要 `192Mi` 最大堆和 `384Mi` 容器内存上限；低于该限额会因 JVM 非堆内存被 OOMKilled，不能以 Pod 短暂 Ready 作为验收通过。
- 需要 Nacos 配置中心的业务工作负载除 `nacos-client` ConfigMap 外，还必须引用 `lgy/nacos-client-auth`。该 Secret 由受控命令从现有 `nacos/nacos-admin` 同步创建，YAML 不得保存凭据。
- `nms4cloud-mall`、`nms4cloud-product`、`nms4cloud-wechat`、`nms4cloud-pos4cloud` 的 Deployment 与 Service 已创建，当前固定为 `replicas: 0`。现有 Nacos 服务与这些旧版客户端的认证/配置协议未完成兼容验证，且缺少其 ShardingSphere 数据源配置；在该链路验收通过前不得扩容。
- 扩容前必须先创建 `lgy` namespace 中所需的外部 Secret，并以业务配置验证 Nacos、MySQL、Redis 等实际依赖可连通。仅设置 Nacos 地址不足以替代认证和业务数据源配置。
- K3s Deployment 只能引用 Harbor 的不可变纯数字标签，例如 `:12`；不得引用 `latest`。流水线同时发布相同摘要的数字标签和 `latest`，其中 `latest` 只用于人工检查或短期测试，不作为部署版本。
