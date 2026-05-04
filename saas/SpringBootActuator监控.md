# Spring Boot Actuator 监控

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos3boot-app
> 最后更新：2026-04-30

---

## 一、组件概述

**Spring Boot Actuator**（`spring-boot-starter-actuator`）提供开箱即用的应用监控端点，包括健康检查、内存信息、线程 dump、审计日志等。pos3boot 通过 Actuator 暴露服务健康状态，供部署平台或运维系统定期探测。

---

## 二、Maven 依赖

**pos3boot-app**（`nms4cloud-pos3boot/nms4cloud-pos3boot-app/pom.xml`）：

```xml
<!-- Actuator 由 nms4cloud-starter-parent 提供，这里显式引入以确保可用 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

---

## 三、常用端点

| 端点 | 说明 | 典型用途 |
|------|------|---------|
| `/actuator/health` | 健康检查 | K8s 存活探针 / 负载均衡探测 |
| `/actuator/health/liveness` | 存活探针 | K8s livenessProbe |
| `/actuator/health/readiness` | 就绪探针 | K8s readinessProbe |
| `/actuator/metrics` | 指标列表 | Prometheus 抓取 |
| `/actuator/metrics/jvm.memory.used` | JVM 内存使用 | 内存监控 |
| `/actuator/metrics/hikaricp.connections.active` | 连接池活跃连接数 | 数据库连接监控 |
| `/actuator/info` | 应用信息 | 版本/Git 信息 |
| `/actuator/env` | 环境变量 | 排查配置问题 |

---

## 四、配置示例

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,info  # 暴露的端点
      base-path: /actuator           # 端点前缀
  endpoint:
    health:
      show-details: when_authorized  # 详细信息仅授权用户可见
      probes:
        enabled: true                # 启用 K8s 探针
  health:
    # 健康检查依赖
    db:
      enabled: true                  # 数据库连接池检查
    redis:
      enabled: true                  # Redis 连接检查
```

---

## 五、注意事项

1. **安全暴露**：生产环境应限制 `/actuator/env`、`/actuator/heapdump` 等敏感端点的访问
2. **K8s 集成**：开启 `management.endpoint.health.probes.enabled` 后支持 K8s 的 liveness/readiness 探针

---

## 六、相关文档

- [SpringWebFlux响应式编程](./SpringWebFlux响应式编程.md) — pos6monitor 技术栈
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)