# 静态部署文件评审

## 范围

本评审只基于 `D:\resources (1)\resources` 中的静态 YAML，不读取 Kubernetes 集群状态，也不把运行时对象导出作为部署源。`base/` 中的文件只保留 Deployment 定义，删除了 `status`、`managedFields`、UID、资源版本、创建时间和 Rancher/Cattle 注解。

## 文件分层

| 文件 | 用途 |
|---|---|
| `bundles/already-present.yaml` | 安装基线中已存在的定义归档，不应重复部署 |
| `bundles/incremental.yaml` / `bundles/default-enabled.yaml` | 默认启用的未纳入安装基线应用集合 |
| `bundles/default-disabled.yaml` | 默认 `replicas: 0` 的按需应用集合 |
| `bundles/data.yaml` | MySQL、Redis、ClickHouse |
| `bundles/messaging.yaml` | ZooKeeper、RocketMQ、EMQX（Kafka 已排除） |
| `bundles/business.yaml` | Gateway、Nginx 和业务服务 |
| `bundles/platform.yaml` | Jenkins、Nexus、Harbor、XXL-JOB |

## 主要静态问题

1. 目录只有 Deployment，缺少与之配套的 Service、PVC、ConfigMap、Secret、ServiceAccount/RBAC，不能直接作为完整安装包。
2. 仍有旧镜像仓库地址 `10.43.92.252/library/...`，迁移前必须映射到当前镜像仓库并验证拉取权限。
3. 若干定义仍声明 `hostPort`。删除它会改变外部访问契约，因此整理阶段保留并标记；部署 overlay 应改用 Service/NodePort。
4. 原始业务服务依赖名为 `nacos` 的 ConfigMap，且大量业务 Deployment 没有资源限制。整理器已为缺少 resources 的容器补低配默认值，但业务容量仍需压测后调整。
5. 原始 Nacos 定义含数据库 sidecar；在已有独立 MySQL 的环境中不应再次部署该 sidecar，需通过单独 overlay 删除并改为跨 namespace Service 地址。
6. 敏感环境变量不再保留值，已转换为 `<application>-secrets` 的 Secret 引用。Secret 只允许由受控初始化流程创建。

## 静态资源预算

按原始声明、排除安装基线中的重复组件后，候选应用的显式 requests 约为 CPU `4.124`、内存 `11 GiB`；另有 19 个业务容器原始未设置 resources，整理器为其补了 `100m/256Mi` requests、`500m/768Mi` limits。这个预算不能视为可直接部署预算，低配虚拟机应按阶段启用。

## 推荐顺序

1. 先建立 namespace、Secret、ConfigMap、Service 和 PVC。
2. Kafka 已从整理结果及所有部署集合排除；只在 RocketMQ、EMQX 中按实际依赖选择消息组件。
3. 优惠券 mock、POS 同步/预订/收银/报表，以及 yd4cloud-capital、yd4cloud-nms 归入默认停用组，Deployment 固定为 `replicas: 0`；ClickHouse、BI 和其他未使用服务也应按需启用。
4. 每次只启用一个业务服务，完成启动、Nacos 注册、数据库连接和接口验收后再继续。
5. 使用 `kubectl apply --dry-run=server` 验证完整依赖后，再进行实际部署。
