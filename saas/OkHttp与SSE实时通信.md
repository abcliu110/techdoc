# OkHttp 与 SSE 实时通信

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 最后更新：2026-04-30

---

## 一、组件概述

**OkHttp**（`com.squareup.okhttp3:okhttp`）是 Square 开发的轻量 HTTP 客户端，相比 Spring 默认的 `RestTemplate`，OkHttp 在以下场景有明显优势：
- **连接复用**（HTTP/2 支持）：减少 TCP 握手开销
- **更精细的超时控制**：读写超时独立配置
- **流式响应**：支持 Server-Sent Events（SSE）实时推送

nms4pos 中 pos4cloud 使用 OkHttp 4.12.0 调用第三方 AI 服务（通义千问、百度 OCR 等）和支付通道，以及通过 SSE 实现 KDS（厨房显示系统）的实时更新推送。

---

## 二、Maven 依赖

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- OkHttp HTTP 客户端 -->
<dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>okhttp</artifactId>
    <version>4.12.0</version>
</dependency>
<!-- OkHttp SSE（Server-Sent Events） -->
<dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>okhttp-sse</artifactId>
    <version>4.12.0</version>
</dependency>
```

---

## 三、核心使用方式

### 3.1 OkHttpClient 单例配置

```java
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import java.util.concurrent.TimeUnit;

public class OkHttpClientSingleton {

    private static final OkHttpClient CLIENT;

    static {
        CLIENT = new OkHttpClient.Builder()
            .connectTimeout(10, TimeUnit.SECONDS)    // 连接超时
            .readTimeout(30, TimeUnit.SECONDS)       // 读取超时
            .writeTimeout(30, TimeUnit.SECONDS)      // 写入超时
            .retryOnConnectionFailure(true)           // 连接失败自动重试
            .build();
    }

    public static OkHttpClient getClient() {
        return CLIENT;
    }
}
```

### 3.2 GET 请求

```java
public String get(String url, Map<String, String> headers) {
    Request.Builder builder = new Request.Builder().url(url).get();

    if (headers != null) {
        headers.forEach(builder::addHeader);
    }

    try (Response response = OkHttpClientSingleton.getClient()
            .newCall(builder.build()).execute()) {

        if (!response.isSuccessful()) {
            throw new BizException("HTTP 请求失败: " + response.code());
        }
        return response.body().string();
    } catch (IOException e) {
        throw new BizException("网络请求异常", e);
    }
}
```

### 3.3 POST JSON 请求（调用 AI 服务）

```java
import okhttp3.MediaType;
import okhttp3.RequestBody;

public String postJson(String url, Object body) {
    MediaType JSON = MediaType.parse("application/json; charset=utf-8");

    String jsonBody = JSON.toJSONString(body);

    Request request = new Request.Builder()
        .url(url)
        .post(RequestBody.create(jsonBody, JSON))
        .addHeader("Authorization", "Bearer " + token)
        .addHeader("Content-Type", "application/json")
        .build();

    try (Response response = CLIENT.newCall(request).execute()) {
        return response.body().string();
    } catch (IOException e) {
        throw new BizException("POST 请求异常", e);
    }
}
```

### 3.4 SSE 实时推送（KDS 显示更新）

```java
import okhttp3.sse.EventSource;
import okhttp3.sse.EventSourceListener;
import okhttp3.sse.EventSources;

public void subscribeKDSEvents(String kdsUrl, String orderId) {

    Request request = new Request.Builder()
        .url(kdsUrl + "?orderId=" + orderId)
        .header("Accept", "text/event-stream")
        .build();

    EventSourceListener listener = new EventSourceListener() {

        @Override
        public void onOpen(EventSource eventSource, Response response) {
            log.info("SSE 连接建立: orderId={}", orderId);
        }

        @Override
        public void onEvent(EventSource eventSource, String id, String type, String data) {
            log.debug("SSE 事件: type={}, data={}", type, data);

            // 解析事件数据，刷新 KDS 显示
            KDSEvent event = JSON.parseObject(data, KDSEvent.class);
            if ("dish_ready".equals(type)) {
                kdsService.showDishReady(event);
            } else if ("call_number".equals(type)) {
                kdsService.callNumber(event.getTableNo());
            }
        }

        @Override
        public void onClosed(EventSource eventSource) {
            log.info("SSE 连接关闭: orderId={}", orderId);
        }

        @Override
        public void onFailure(EventSource eventSource, Throwable t, Response response) {
            log.warn("SSE 连接失败，尝试重连: {}", t.getMessage());
            // 自动重连机制由 OkHttp EventSources 处理
        }
    };

    // 创建并启动 SSE 连接（自动处理重连）
    EventSources.createFactory(CLIENT)
        .newEventSource(request, listener);
}
```

---

## 四、在 nms4pos 中的典型使用场景

| 场景 | 方式 | 说明 |
|------|------|------|
| 调用通义千问 API | POST JSON | 智能客服 AI 回复 |
| 调用百度 OCR | POST + Multipart | 图片文字识别 |
| 调用阿里云 OSS 上传 | POST | 小票图片上传 |
| KDS 实时显示更新 | SSE | 厨房菜品状态推送 |
| 支付结果轮询 | GET | 扫码支付状态查询 |

---

## 五、OkHttp vs RestTemplate 对比

| 特性 | OkHttp | RestTemplate |
|------|--------|-------------|
| 连接池 | ✅ 内置，支持 HTTP/2 | ✅ 支持（需配置） |
| 连接复用 | ✅ 自动 | ❌ 默认不开启 |
| SSE 支持 | ✅ okhttp-sse | ❌ 不支持 |
| 超时控制 | ✅ 读写超时独立 | ⚠️ 统一超时 |
| 异步请求 | ✅ 支持 | ❌ 同步 |
| 重试机制 | ✅ 内置 | ❌ 需手动实现 |

---

## 六、注意事项

1. **保持单例**：`OkHttpClient` 应作为单例，共享连接池，频繁创建新实例会导致连接泄漏
2. **SSE 重连**：`EventSources` 内置自动重连，适合 KDS 等需要长期保持连接的场景
3. **超时配置**：调用外部 AI 服务时，读取超时建议设长一些（30s+），大模型推理耗时较长
4. **响应体关闭**：`Response.body()` 必须关闭（使用 try-with-resources），否则连接不会归还连接池

---

## 七、相关文档

- [通义千问DashScope-SDK使用](./通义千问DashScope-SDK使用.md)
- [阿里云NLSTTS语音合成](./阿里云NLSTTS语音合成.md)
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)