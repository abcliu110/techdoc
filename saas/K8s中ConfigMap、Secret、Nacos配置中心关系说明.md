# K8s 中 ConfigMap、Secret、Nacos 配置中心关系说明

> 文档路径：`D:\mywork\techdoc\saas`
> 最后更新：2026-05-03

---

## 一、先说结论

这三个东西都和“配置”有关，但它们不在同一层，职责也不同。

- `ConfigMap`：保存普通配置
- `Secret`：保存敏感配置
- `Nacos Config`：保存应用层配置，并支持动态刷新和集中管理

最简单的理解是：

```text
K8s ConfigMap / Secret 负责把配置送进容器运行环境
Nacos Config 负责给应用提供集中配置和动态刷新能力
```

---

## 二、三者分别是什么

### 2.1 ConfigMap

`ConfigMap` 是 Kubernetes 用来保存**普通配置**的资源对象。

适合保存：

- 应用参数
- 启动配置
- yml / properties
- 非敏感环境变量

例如：

- `server.port=8080`
- `spring.profiles.active=prod`
- `LOG_LEVEL=INFO`

---

### 2.2 Secret

`Secret` 是 Kubernetes 用来保存**敏感配置**的资源对象。

适合保存：

- 数据库密码
- API Key
- Token
- 证书
- 私钥

例如：

- Redis 密码
- MySQL 账号密码
- JWT 密钥

注意：

`Secret` 并不是高等级加密保险箱，它只是 K8s 里“专门存敏感数据的对象”，比直接写在镜像或普通配置里更合适。

---

### 2.3 Nacos Config

`Nacos Config` 是应用层的配置中心。

它的特点是：

- 配置集中管理
- 有界面
- 支持 namespace / group / dataId
- 支持 Spring Boot 动态刷新

适合保存：

- 业务开关
- 应用参数
- 路由规则
- 限流开关
- 超时时间
- 业务配置模板

例如：

- `demo.order-timeout=30`
- `demo.enable-coupon=true`
- `spring.datasource.url=...`

---

## 三、它们的层次区别

### K8s 视角

K8s 只关心：

```text
怎么把配置交给容器
```

所以它提供：

- ConfigMap
- Secret

这两个更偏：

```text
容器运行环境层
```

---

### Nacos 视角

Nacos 关心的是：

```text
应用应该读什么配置
配置怎么集中管理
配置修改后怎么动态刷新
```

所以它更偏：

```text
应用配置治理层
```

---

## 四、图示：三者所在层次

```text
Kubernetes 集群
│
├─ ConfigMap
│   └─ 普通配置，注入容器
│
├─ Secret
│   └─ 敏感配置，注入容器
│
└─ Pod
    └─ Spring Boot 应用
         |
         | 运行后继续读取
         v
      Nacos Config
        └─ 应用层集中配置 + 动态刷新
```

---

## 五、ConfigMap 和 Secret 在 Spring Boot 中怎么用

### 5.1 ConfigMap 作为环境变量

例如：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  SPRING_PROFILES_ACTIVE: prod
  APP_ORDER_URL: http://order-service:8080
```

在 Pod 里引用：

```yaml
envFrom:
  - configMapRef:
      name: app-config
```

那么 Spring Boot 容器启动后就能读取：

- `SPRING_PROFILES_ACTIVE`
- `APP_ORDER_URL`

---

### 5.2 Secret 作为环境变量

例如：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:
  DB_USERNAME: root
  DB_PASSWORD: 123456
```

在 Pod 里引用：

```yaml
envFrom:
  - secretRef:
      name: db-secret
```

这样 Spring Boot 启动时就能拿到数据库账号密码。

---

## 六、Nacos Config 在 Spring Boot 中怎么用

Spring Boot 一般通过：

```yaml
spring:
  config:
    import:
      - optional:nacos:demo-service.yaml?group=DEFAULT_GROUP&refreshEnabled=true
```

再配合：

```yaml
spring:
  cloud:
    nacos:
      server-addr: 127.0.0.1:8848
      config:
        namespace: public
        group: DEFAULT_GROUP
        file-extension: yaml
```

这样应用启动后会：

1. 连接 Nacos
2. 拉取对应 Data ID 的配置
3. 注入到 Spring 环境
4. 如果开启刷新，后续修改还能动态生效

---

## 七、三者的典型分工

### 方案一：全用 K8s，不用 Nacos

适合：

- 完全云原生
- 配置简单
- 不要求 Spring 动态刷新

分工：

- 普通配置 -> ConfigMap
- 密码配置 -> Secret

---

### 方案二：K8s + Nacos 组合

这是最常见也最合理的方案之一。

分工建议：

- ConfigMap：放固定基础配置，例如 Nacos 地址、环境名、服务 URL
- Secret：放账号密码、token、数据库凭证
- Nacos：放业务配置、开关、可动态刷新配置

可以理解成：

```text
ConfigMap / Secret 负责让应用“先启动起来”
Nacos 负责让应用“启动后还能灵活改配置”
```

---

## 八、图示：推荐组合方式

```text
ConfigMap
  └─ Nacos 地址、环境名、固定基础参数

Secret
  └─ 用户名、密码、Token、密钥

Spring Boot Pod
  └─ 启动时先读取 ConfigMap / Secret
       |
       v
     连接 Nacos
       |
       v
     拉取业务配置、动态配置
```

---

## 九、什么时候该放到 ConfigMap，什么时候放到 Nacos

### 更适合放 ConfigMap 的

- Nacos 地址本身
- JVM 参数
- 固定启动参数
- 不常改的环境配置
- 集群内部服务地址

### 更适合放 Nacos 的

- 业务参数
- 动态开关
- 超时配置
- 限流配置
- 可在线调整的配置

### 更适合放 Secret 的

- 密码
- Token
- AccessKey
- 证书

---

## 十、动态刷新能力谁更强

### ConfigMap

ConfigMap 可以变，但对 Java 应用来说，通常不会自动把改动实时注入到运行中的 Spring Bean。

也就是说：

- K8s 对象改了
- 不代表 Spring Boot 里的 `@Value` 会自动变

很多时候还是要：

- 重启 Pod
- 或重新加载应用

### Nacos

Nacos 更擅长动态刷新。

配合：

- `refreshEnabled=true`
- `@RefreshScope`

就可以在应用运行中刷新配置。

所以：

```text
ConfigMap 更像启动配置
Nacos 更像运行期配置中心
```

---

## 十一、一句话总结

你可以这样记：

```text
ConfigMap = 普通配置
Secret = 敏感配置
Nacos = 应用配置中心 + 动态刷新
```

推荐组合是：

```text
K8s 用 ConfigMap / Secret 提供启动配置
Spring Boot 启动后连接 Nacos 读取业务配置
```
