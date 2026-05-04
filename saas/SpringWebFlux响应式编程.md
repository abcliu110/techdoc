# Spring WebFlux 响应式编程

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos6monitor
> 最后更新：2026-04-30

---

## 一、组件概述

**Spring WebFlux**（`spring-boot-starter-webflux`）是 Spring 5 引入的响应式 Web 框架，基于 Reactor（Project Reactor）实现完全异步非阻塞的请求处理。pos6monitor 是 nms4pos 中的系统监控模块，使用 WebFlux 作为核心技术栈。

**WebFlux vs Web MVC**：

| 维度 | WebFlux | Web MVC |
|------|---------|---------|
| 线程模型 | 少量线程处理大量并发 | 每请求一个线程 |
| 适用场景 | IO 密集（监控数据推送） | CPU 密集 |
| 编程模型 | 函数式 / 响应式 | 同步阻塞 |
| 数据库 | R2DBC（非阻塞驱动） | JDBC（阻塞） |

---

## 二、Maven 依赖

**pos6monitor**（`nms4cloud-pos6monitor/pom.xml`）：

```xml
<!-- Spring Boot 3.4.1 的 WebFlux -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>

<!-- WebClient（响应式 HTTP 客户端，替代 RestTemplate） -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
```

---

## 三、核心使用方式

### 3.1 函数式路由定义

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.ServerResponse;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.web.reactive.function.server.RequestPredicates.*;
import static org.springframework.web.reactive.function.server.RouterFunctions.*;

@Configuration
public class MonitorRouter {

    @Bean
    public RouterFunction<ServerResponse> monitorRoutes(
            MonitorHandler handler) {
        return nest(path("/api/monitor"),
            // 获取系统指标
            GET("/metrics").and(accept(APPLICATION_JSON))
                .andThen(handler::getMetrics)
            // 获取外设状态
            , GET("/peripherals").and(accept(APPLICATION_JSON))
                .andThen(handler::getPeripherals)
            // 串口状态详情
            , GET("/serial/{portName}").and(accept(APPLICATION_JSON))
                .andThen(handler::getSerialStatus)
        );
    }
}
```

### 3.2 Handler 处理（响应式）

```java
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.server.ServerRequest;
import org.springframework.web.reactive.function.server.ServerResponse;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Flux;

@Component
public class MonitorHandler {

    // 响应式获取监控指标
    public Mono<ServerResponse> getMetrics(ServerRequest request) {
        return Mono.fromCallable(() -> {
            // 同步调用（但不在 Web 线程）
            return collectMetrics();
        })
        .flatMap(metrics -> ServerResponse.ok()
            .contentType(APPLICATION_JSON)
            .bodyValue(metrics))
        .onErrorResume(e -> ServerResponse.status(500)
            .bodyValue(Map.of("error", e.getMessage())));
    }

    // SSE 实时推送（服务端发送事件）
    public Mono<ServerResponse> streamPeripherals(ServerRequest request) {
        Flux<PeripheralStatus> stream = Flux.interval(Duration.ofSeconds(5))
            .map(tick -> collectPeripheralStatus())
            .share();  // 多客户端共享同一数据源

        return ServerResponse.ok()
            .contentType(MediaType.TEXT_EVENT_STREAM)
            .body(stream, PeripheralStatus.class);
    }
}
```

### 3.3 WebClient（替代 RestTemplate）

```java
import org.springframework.web.reactive.function.client.WebClient;

@Service
public class ExternalMonitorClient {

    private final WebClient webClient;

    public ExternalMonitorClient() {
        this.webClient = WebClient.builder()
            .baseUrl("http://localhost:8081")  // pos3boot 的 Actuator 端口
            .defaultHeader("Accept", "application/json")
            .build();
    }

    // 异步获取外部服务健康状态
    public Mono<Map<String, Object>> getServiceHealth() {
        return webClient.get()
            .uri("/actuator/health")
            .retrieve()
            .bodyToMono(Map.class)
            .map(m -> (Map<String, Object>) m)
            .timeout(Duration.ofSeconds(3))
            .onErrorReturn(Map.of("status", "DOWN"));
    }

    // 批量请求
    public Mono<List<Map>> getAllMetrics() {
        return Flux.merge(
                webClient.get().uri("/actuator/metrics/jvm.memory.used").retrieve().bodyToMono(Map.class),
                webClient.get().uri("/actuator/metrics/hikaricp.connections.active").retrieve().bodyToMono(Map.class),
                webClient.get().uri("/actuator/metrics/system.cpu.usage").retrieve().bodyToMono(Map.class)
            )
            .collectList();
    }
}
```

### 3.4 串口监控（SSE 推送）

```java
// 串口外设状态实时推送
@GetMapping(value = "/api/monitor/serial/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public Flux<SerialStatusEvent> streamSerialStatus(
        @RequestParam String portName,
        @RequestParam(defaultValue = "2000") long intervalMs) {

    // 定时查询串口状态，SSE 推送到前端
    return Flux.interval(Duration.ofMillis(intervalMs))
        .flatMap(tick -> Mono.fromCallable(() -> querySerialStatus(portName)))
        .onErrorResume(e -> Mono.just(SerialStatusEvent.error(e.getMessage())));
}
```

---

## 四、pos6monitor 架构

```
pos6monitor（Spring WebFlux 独立部署）
├── /api/monitor/metrics     GET  →  系统指标（CPU/内存/磁盘）
├── /api/monitor/peripherals  GET  →  外设状态（打印机/钱箱/电子秤）
├── /api/monitor/serial/stream SSE → 串口状态实时推送
└── /api/monitor/alerts      GET  →  告警列表
```

---

## 五、注意事项

1. **blocking 调用隔离**：响应式方法中如有阻塞调用（如 JDBC、串口通信），必须使用 `Mono.fromCallable()` + `subscribeOn(Schedulers.boundedElastic())` 隔离
2. **背压处理**：SSE 流应设置合理的推送频率，避免客户端处理不过来
3. **线程模型**：WebFlux 默认使用少量事件循环线程（通常为 CPU 核心数），不要在事件循环中执行阻塞操作
4. **与 Web MVC 混用**：同一个应用可同时引入 WebFlux 和 Web MVC，但 Controller 和 Handler 不要混用

---

## 六、相关文档

- [jSerialComm与RXTX串口通信](./jSerialComm与RXTX串口通信.md) — 串口通信
- [SpringBootActuator监控](./SpringBootActuator监控.md) — 健康检查
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)