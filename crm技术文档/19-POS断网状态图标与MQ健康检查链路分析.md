# POS断网状态图标与MQ健康检查链路分析

## 1. 问题背景

现场在 POS 登录页右上角看到红色 WiFi/断网图标，同时 DevTools 中可以看到部分接口请求返回 HTTP 200。

典型现象包括：

- `POST http://127.0.0.1:9180/api/merchant/sys_timed/network` 返回 HTTP 200。
- 云端 CRM 接口例如 `http://bosswx.gzjjzhy.com:30080/api/scrm/crm_coupon/update` 也能返回 HTTP 200。
- 但 POS 页面顶部仍显示红色断网图标。

这个现象容易被误判为“浏览器网络没有问题，所以 POS 断网图标一定是前端显示错误”。从代码链路看，这个判断不成立。

## 2. 结论

POS 顶部断网图标不是简单判断浏览器能否访问任意云端接口，也不是只判断本地 `127.0.0.1:9180` 是否可访问。

当前代码中，POS 网络状态的核心判断链路是：

```text
POS 前端 useNetworkStatus
  -> POST /api/merchant/sys_timed/network
    -> 本地 POS 服务 SysTimedControl.network()
      -> 本地 POS 服务调用云端 MQ 健康检查
        -> ${baseUrl}/api/mq/health-check
```

只有本地接口返回的 `data.network` 等于 `CONNECTED`，前端才会显示绿色在线图标。只要不是 `CONNECTED`，前端都会按离线/异常状态显示红色 WiFi 图标。

因此：

- CRM 接口 `api/scrm/crm_coupon/update` 返回 200，只能证明 CRM 服务链路可达。
- 本地接口 `/api/merchant/sys_timed/network` 返回 200，只能证明本地 POS 服务可达。
- POS 顶部 WiFi 是否绿色，最终取决于本地 POS 服务探测云端 `api/mq/health-check` 的结果。

## 3. 前端代码链路

### 3.1 网络状态初始化为不可达

文件：

```text
D:\mywork\nms4pos-ui\app\pos4desktop\src\hooks\useNetworkStatus.ts
```

关键逻辑：

```ts
const [networkStatusData, setNetworkStatusData] = useState<ISysNetwork | undefined>({
  network: 'UNREACHABLE',
  dateTimeName: currentTime,
} as any);
```

含义：

- 页面初始状态就是 `UNREACHABLE`。
- 如果后续接口没有成功把状态更新为 `CONNECTED`，页面会继续显示断网图标。

### 3.2 前端调用本地网络状态接口

文件：

```text
D:\mywork\nms4pos-ui\api\pos4plugin\src\services\NetworkStatusService.ts
```

关键逻辑：

```ts
export async function networkStatus() {
  const _request = getRequest();
  return _request<API.PublicResultData<any>>('/api/merchant/sys_timed/network', {
    method: 'POST',
  });
}
```

含义：

- 前端不是直接访问云端 MQ。
- 前端只访问本地 POS 服务暴露的 `/api/merchant/sys_timed/network`。

### 3.3 页面只把 CONNECTED 视为在线

文件：

```text
D:\mywork\nms4pos-ui\app\pos4desktop\src\pages\Login\index.tsx
```

关键逻辑：

```tsx
<NetworkStatus
  size={`0.8rem`}
  color={`#199439`}
  isOnline={networkStatusData?.network === 'CONNECTED'}
/>
```

含义：

- `CONNECTED`：绿色在线图标。
- `UNREACHABLE`、`DISCONNECTED`、`UNKNOWN`、空值：都不是在线，显示红色异常图标。

### 3.4 WebSocket 可触发刷新

登录页和 SaaS 页会监听 `RefreshNetwork` 消息：

```ts
if (message.type === 'RefreshNetwork') {
  updateNetwork();
}
```

含义：

- 后端定时检查发现网络状态、餐段、打印机故障数变化时，会通过消息触发前端刷新网络状态。
- 这解释了为什么图标可能在运行过程中自动变化。

## 4. 后端代码链路

### 4.1 本地接口定义

文件：

```text
D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\controller\app\SysTimedControl.java
```

关键逻辑：

```java
@PostMapping(value = "/network")
public NmsResult<NetCheckVO> network() {
  NetworkStateEnum network = networkCheck();
  ...
  return NmsResult.data(
      new NetCheckVO()
          ...
          .setNetwork(network)
          .setFault(printerWorkerService.getFault()));
}
```

含义：

- 本地接口会正常返回业务响应。
- 其中 `data.network` 来自 `networkCheck()`。

### 4.2 真正的网络探测点

同一文件：

```java
private NetworkStateEnum networkCheck() {
  ...
  try {
    NmsResult<?> result = nms4cloudMqService.healthCheck();
    if (result.isSuccess()) {
      netWorkStateTmp = NetworkStateEnum.CONNECTED;
    } else {
      netWorkStateTmp = NetworkStateEnum.UNREACHABLE;
      log.error("检测网络状态服务器[{}]不可达:{}=>{}", apiServer, netWorkStateTmp, result.getErrorMessage());
    }
  } catch (Exception e) {
    log.error("检测网络状态异常{}", ExceptionUtils.getStackTrace(e));
    netWorkStateTmp = NetworkStateEnum.DISCONNECTED;
  }
  networkState = netWorkStateTmp;
  lastCheckTimestamp = SystemClock.now();
  ...
}
```

含义：

- 云端 MQ 健康检查成功：`CONNECTED`。
- 云端 MQ 返回业务失败：`UNREACHABLE`。
- 请求异常、连接异常、超时等：`DISCONNECTED`。

### 4.3 云端 MQ 健康检查接口

文件：

```text
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\cloud\Nms4cloudMqService.java
```

关键逻辑：

```java
@BaseRequest(
    baseURL = Nms4cloudInterceptor.DEF_BASE_URL + "/mq",
    ...
)
public interface Nms4cloudMqService {
  @Get(url = "/health-check")
  NmsResult<?> healthCheck();
}
```

结合：

```java
public static final String DEF_BASE_URL = "${baseUrl}/api/";
```

最终探测地址为：

```text
${baseUrl}/api/mq/health-check
```

例如当前环境如果 `baseUrl = http://bosswx.gzjjhy.com:30080` 或类似网关地址，则应重点验证：

```text
http://bosswx.gzjjhy.com:30080/api/mq/health-check
```

现场截图里的 CRM 请求是：

```text
http://bosswx.gzjjzhy.com:30080/api/scrm/crm_coupon/update
```

这两个接口属于不同服务路径：

- `/api/scrm/...`：CRM 服务。
- `/api/mq/health-check`：MQ 服务健康检查。

因此 CRM 接口正常，不代表 MQ 健康检查正常。

## 5. 网络状态枚举含义

文件：

```text
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\enums\NetworkStateEnum.java
```

枚举：

```java
public enum NetworkStateEnum {
  DISCONNECTED, // 网络异常
  CONNECTED,    // 网络连接正常
  UNREACHABLE,  // 服务器网络不可达
  UNKNOWN       // 网络状态未知
}
```

前端当前只把 `CONNECTED` 当作在线。

| 后端 `data.network` | 前端表现 | 含义 |
|---|---|---|
| `CONNECTED` | 绿色 WiFi / 网络正常 | 本地 POS 服务访问云端 MQ 健康检查成功 |
| `UNREACHABLE` | 红色 WiFi | 云端 MQ 健康检查返回业务失败 |
| `DISCONNECTED` | 红色 WiFi | 本地 POS 服务请求云端 MQ 发生异常或超时 |
| `UNKNOWN` | 红色 WiFi | 初始或未知状态 |
| 空值 / 未更新 | 红色 WiFi | 前端保持初始化状态或响应解析未更新 |

## 6. 现场排查步骤

### 6.1 先看本地网络状态接口完整响应

在 DevTools 中选中：

```text
POST http://127.0.0.1:9180/api/merchant/sys_timed/network
```

重点看 Response 是否包含：

```json
{
  "success": true,
  "code": 0,
  "data": {
    "network": "CONNECTED"
  }
}
```

判断：

- 如果 `data.network = CONNECTED` 但图标仍红，优先查前端状态更新、请求包装、页面缓存。
- 如果 `data.network = UNREACHABLE`，优先查云端 MQ 健康检查是否业务失败。
- 如果 `data.network = DISCONNECTED`，优先查本地服务到云端 MQ 的网络、DNS、证书、超时、代理或防火墙。
- 如果没有 `success: true`，前端 `useNetworkStatus` 可能直接 return，导致状态保持初始化 `UNREACHABLE`。

### 6.2 直接验证 MQ 健康检查

根据当前 POS 服务配置中的 `baseUrl`，访问：

```text
${baseUrl}/api/mq/health-check
```

以截图环境推测，可以重点尝试：

```text
http://bosswx.gzjjzhy.com:30080/api/mq/health-check
```

注意：

- 不能只测 `/api/scrm/crm_coupon/update`。
- CRM 通不等于 MQ 通。
- 需要确认 POS 本地进程实际使用的 `baseUrl`，不要只看浏览器当前请求域名。

### 6.3 查本地 POS 后端日志

搜索关键日志：

```text
检测网络状态服务器
检测网络状态异常
```

对应代码：

```java
log.error("检测网络状态服务器[{}]不可达:{}=>{}", apiServer, netWorkStateTmp, result.getErrorMessage());
log.error("检测网络状态异常{}", ExceptionUtils.getStackTrace(e));
```

日志会说明：

- 实际访问的 `apiServer` 是什么。
- 是业务失败还是异常。
- 异常栈里是否有连接超时、DNS、SSL、拒绝连接等信息。

## 7. 常见误判

### 7.1 误判：本地 network 接口 200 就说明在线

不对。

`/api/merchant/sys_timed/network` 是本地 POS 服务接口。HTTP 200 只说明本地服务响应了。真正在线与否看响应体里的 `data.network`。

### 7.2 误判：CRM update 接口 200 就说明 POS 网络正常

不对。

代码里的网络状态检查走的是 MQ：

```text
/api/mq/health-check
```

不是 CRM：

```text
/api/scrm/crm_coupon/update
```

### 7.3 误判：浏览器能访问云端，所以本地 POS 服务也一定能访问

不一定。

浏览器请求和本地 POS Java 进程请求可能存在差异：

- 使用的域名或端口不同。
- 使用的配置 `baseUrl` 不同。
- Java 进程运行环境的 DNS、代理、证书、网络权限不同。
- 防火墙可能允许浏览器但限制本地服务进程。

## 8. 建议的最小确认清单

1. 在 `/api/merchant/sys_timed/network` Response 中确认 `data.network` 的真实值。
2. 确认响应中是否包含 `success: true`。
3. 用 POS 后端实际配置的 `baseUrl` 测试 `${baseUrl}/api/mq/health-check`。
4. 查 POS 本地日志中的 `检测网络状态服务器` 或 `检测网络状态异常`。
5. 对比浏览器能访问的 CRM 地址和 POS 后端实际访问的 MQ 地址是否一致。

## 9. 快速判断模板

| 现象 | 优先结论 | 下一步 |
|---|---|---|
| `/network` HTTP 200，`data.network=CONNECTED`，图标红 | 前端状态更新或响应解析问题 | 查 `useNetworkStatus`、请求包装、页面缓存 |
| `/network` HTTP 200，`data.network=UNREACHABLE` | 云端 MQ 健康检查业务失败 | 访问 `${baseUrl}/api/mq/health-check`，查网关/MQ服务 |
| `/network` HTTP 200，`data.network=DISCONNECTED` | 本地 POS 请求云端 MQ 异常 | 查本地日志、DNS、端口、防火墙、SSL、超时 |
| CRM 接口 200，但 WiFi 红 | 不能证明网络状态正常 | 改查 MQ 健康检查 |
| `/network` 响应无 `success:true` | 前端可能不更新状态 | 查响应结构和请求包装逻辑 |

## 10. 本次分析涉及的关键文件

```text
D:\mywork\nms4pos-ui\app\pos4desktop\src\hooks\useNetworkStatus.ts
D:\mywork\nms4pos-ui\api\pos4plugin\src\services\NetworkStatusService.ts
D:\mywork\nms4pos-ui\app\pos4desktop\src\pages\Login\index.tsx
D:\mywork\nms4pos-ui\app\pos4desktop\src\components\NetworkStatus\index.tsx
D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\controller\app\SysTimedControl.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\cloud\Nms4cloudMqService.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\cloud\Nms4cloudInterceptor.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\enums\NetworkStateEnum.java
```

