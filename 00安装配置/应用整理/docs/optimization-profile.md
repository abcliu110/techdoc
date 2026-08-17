# 低资源优化 Profile

本目录只提供优化参数建议，不自动修改已部署应用，也不包含密码、Token 或运行时状态。建议通过 Kustomize overlay 对 `base/` 中的候选组件按需应用。

整理器已经将 `base/` 中每个容器（包括 initContainer）按职责和启动特征分档；这不是对当前已运行 Pod 的在线修改。业务档位是静态预估，不等于压测结果。

## 已应用的分类资源

| 分类 | requests | limits |
|---|---:|---:|
| 普通 Java 业务服务 | `100m/256Mi` | `500m/768Mi` |
| POS/微信轻量服务 | `100m/256Mi` | `500m/768Mi` |
| 商品/商城/支付/仓储 | `150m/320Mi` | `600m/768Mi` |
| 平台/订单/CRM | `150-200m/384Mi` | `750m/1Gi` |
| BI | `200m/512Mi` | `750m/1Gi` |
| 消息接入/Netty | `150m/256-320Mi` | `750m/768Mi-1Gi` |
| Gateway | `100m/256Mi` | `500m/512Mi` |
| Nacos 主容器 | `200m/768Mi` | `750m/1Gi` |
| MySQL | `250m/512Mi` | `750m/1536Mi` |
| Redis | `50m/128Mi` | `250m/384Mi` |
| ClickHouse | `250m/512Mi` | `1/1Gi` |
| Kafka | `150m/512Mi` | `500m/1Gi` |
| RocketMQ Broker | `250m/512Mi` | `500m/1Gi` |
| RocketMQ NameServer | `100m/256Mi` | `300m/512Mi` |
| ZooKeeper | `100m/128Mi` | `250m/384Mi` |
| EMQX | `100m/256Mi` | `500m/768Mi` |
| Jenkins | `250m/512Mi` | `1/1536Mi` |
| Nexus | `250m/768Mi` | `1/1536Mi` |
| Harbor Core | `200m/256Mi` | `500m/512Mi` |
| Harbor Registry | `200m/256Mi` | `500m/768Mi` |
| Harbor RegistryCtl | `25m/32Mi` | `100m/128Mi` |
| 普通 initContainer | `10m/16Mi` | `50m/64Mi` |

## 建议上限

| 组件类型 | requests | limits | 备注 |
|---|---:|---:|---|
| Nginx | `50m/64Mi` | `250m/256Mi` | 不使用 hostPort |
| 单个消息组件 | `250m/512Mi` | `500m/1Gi` | Kafka/RocketMQ/EMQX 三选一 |

JVM 参数也已配套收敛：Nacos Xmx `384m`、Jenkins Xmx `768m`、Nexus 堆 `768m` 加 DirectMemory `384m`；Gateway Xmx `384m`。这些值是低配启动基线，不能替代真实压测。

不要把 ClickHouse、Kafka、RocketMQ、EMQX、全部业务服务和平台组件作为一个 bundle 一次启动。当前目录的 `bundles/incremental.yaml` 是候选集合，不是低配虚拟机的一次性安装命令。
