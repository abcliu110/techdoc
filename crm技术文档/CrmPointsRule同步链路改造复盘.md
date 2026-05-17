# CrmPointsRule 同步链路改造复盘

更新时间：2026-05-04

## 1. 问题背景

### 1.1 完整同步链路

```
pos3boot /sync/all
  -> pos4cloud /sync/list
  -> CRM /crm_points_rule/listSync
  -> POS 本地落库 crm_points_rule
```

`CrmPointsRule`（积分权益规则）从云端 CRM 同步到 POS 本地的链路上，存在多处调用方式混用的问题，本次改造聚焦于 `pos4cloud -> CRM` 这一跳。

### 1.2 排查过程中暴露的三类现象

| 序号 | 现象 | 根因 |
|------|------|------|
| ① | POS 本地缺表或缺结构导致提交失败 | POS 本地表结构未同步 |
| ② | `[Forest] Cannot resolve variable 'baseUrl'` | pos4cloud 错误依赖了 Forest `${baseUrl}` 配置 |
| ③ | 改为服务发现调用后 Nacos 返回不可达实例导致超时 | Nacos 实例池中混入了 Docker/WSL/虚拟网卡等不可达地址 |

---

## 2. 代码现状确认

以下事实已通过代码直接确认。

### 2.1 CRM 侧提供专用同步接口

`CrmPointsRuleController` 暴露了：

```
POST /crm_points_rule/listSync
@Inner  // 内部同步接口，不是后台普通列表接口
```

**代码位置**：
```
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\
  ms4cloud-crm-app\src\main\java\com\nms4cloud\crm\app\controller\pointsrule\
  CrmPointsRuleController.java
```

关键代码：
```java
@Inner
@PostMapping("/listSync")
public NmsResult<List<CrmPointsRuleSyncVO>> listCrmPointsRuleSync(
    @Valid @RequestBody CrmPointsRuleListSyncDTO request) {
  return crmPointsRuleServicePlus.listSync(request);
}
```

### 2.2 同步口径按商户维度（mid）下发

`CrmPointsRuleServicePlus.listSync()` 当前按 `mid` 查询，`planLid` 作为可选条件，**不再按 `sid` 缩小范围**。

这与 POS 全量同步语义一致：商户级规则需要完整下发，而不是只同步当前门店子集。

**代码位置**：
```
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\
  ms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\pointsrule\
  CrmPointsRuleServicePlus.java
```

关键代码：
```java
// CrmPointsRuleServicePlus.java (行 115-129)
@Transactional(propagation = Propagation.SUPPORTS, rollbackFor = Exception.class)
public NmsResult<List<CrmPointsRuleSyncVO>> listSync(CrmPointsRuleListSyncDTO request) {
  final LambdaQueryWrapper<CrmPointsRule> query = new QueryWrapper<CrmPointsRule>().lambda();
  // POS 同步按商户维度下发积分权益规则，不按当前门店缩小范围。
  query.eq(CrmPointsRule::getMid, request.getMid());
  query.eq(request.getPlanLid() != null, CrmPointsRule::getPlanLid, request.getPlanLid());
  query.orderByAsc(CrmPointsRule::getLid);
  final Page<CrmPointsRule> page = new Page<>(request.getCurrent(), request.getPageSize());
  iCrmPointsRuleService.page(page, query);
  List<CrmPointsRuleSyncVO> data = page.getRecords().stream().map(this::toSyncVO).toList();
  ...
}
```

### 2.3 会员日两个字段已经进入同步 VO

`CrmPointsRuleSyncVO` 当前已包含：

```java
// CRM 侧 VO
// D:\mywork\nms4cloud\...\CrmPointsRuleSyncVO.java
/** 会员日按周生效星期(JSON数组字符串)。 */
private String memberDayDaysOfWeek;
/** 会员日按月生效日期(JSON数组字符串)。 */
private String memberDayDaysOfMonth;
```

POS 侧接收 VO 也同步包含这两个字段（`CrmPointsRuleSyncVO` in pos4cloud）。

### 2.4 CRM 本身已启用 Nacos 服务发现

```java
// D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\
//   ms4cloud-crm-app\src\main\java\com\nms4cloud\crm\CrmApplication.java
@EnableDiscoveryClient  // CRM 已注册到 Nacos
```

---

## 3. 改造前后代码对照

### 3.1 改造前的调用方式（pos4cloud 走 Forest）

**问题代码**：

pos4cloud 在启动时通过 `@ForestScan` 扫描了 `pos2plugin` 的 Forest 接口：

```java
// Pos4cloudApplication.java (行 55-56)
@ForestScan(basePackages = {"com.nms4cloud.pos2plugin.service.member.cloud"})
```

这导致 pos4cloud 加载了 `Nms4CloudCrmService`（Forest 接口），其 baseURL 配置为：

```java
// Nms4CloudCrmService.java (行 13-14)
@BaseRequest(
    baseURL = Nms4cloudInterceptor.DEF_BASE_URL + "scrm", // 默认域名
    headers = {"Accept:application/json"},
    sslProtocol = "TLS",
    interceptor = {Nms4cloudInterceptor.class}
)
public interface Nms4CloudCrmService {
  @Post(value = "/crm_points_rule/listSync")
  NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(@JSONBody CrmPointsRuleListDTO request);
}
```

其中 `DEF_BASE_URL` 定义为：

```java
// Nms4cloudInterceptor.java (行 16)
public static final String DEF_BASE_URL = "${baseUrl}/api/";
```

**问题根因**：`${baseUrl}` 是为 **POS 本地通过网关访问云端**设计的配置（如 `http://cloud.example.com`），在 **pos4cloud（云端内部）** 环境下此变量无法解析，表现为：

```
[Forest] Cannot resolve variable 'baseUrl'
```

### 3.2 改造后的调用方式（pos4cloud 走 ReactiveFeign + Nacos）

通过策略模式解耦调用方式，在 pos4cloud 中用 `@Primary` 覆盖 Forest 实现：

**抽象接口**（pos2plugin-api）：

```java
// CrmPointsRuleSyncRemoteService.java
public interface CrmPointsRuleSyncRemoteService {
  NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request);
}
```

**pos3boot 实现（保持 Forest 不变）**：

```java
// CrmPointsRuleForestServiceImpl.java (pos3boot 侧)
@Service
public class CrmPointsRuleForestServiceImpl implements CrmPointsRuleSyncRemoteService {
  @Autowired private Nms4CloudCrmService nms4CloudCrmService;

  @Override
  public NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request) {
    return nms4CloudCrmService.listPointsRule(request);  // 走 Forest 网关
  }
}
```

**pos4cloud 实现（Nacos 服务发现）**：

```java
// CrmPointsRuleSyncRemoteServiceImpl.java (pos4cloud 侧，@Primary 覆盖)
@Slf4j
@Service
@Primary  // 在 pos4cloud 环境优先级高于 Forest 实现
public class CrmPointsRuleSyncRemoteServiceImpl implements CrmPointsRuleSyncRemoteService {

  private static final String CRM_SERVICE_NAME = "nms4cloud-crm";
  private static final String SYNC_URI = "/crm_points_rule/listSync";

  @Override
  public NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request) {
    String saToken = redisTemplatePlus.get("nms4token:var:same-token");
    Mono<NmsResult<List<CrmPointsRuleSyncVO>>> mono =
        reactiveFeign.post(
            CRM_SERVICE_NAME + SYNC_URI,   // 服务名 + 路径，不依赖 baseUrl
            request,
            new TypeReference<NmsResult<List<CrmPointsRuleSyncVO>>>() {},
            saToken);
    return mono.block();
  }

  @Autowired private ReactiveFeign reactiveFeign;
  @Autowired private RedisTemplatePlus redisTemplatePlus;
}
```

### 3.3 对照表

| 对比维度 | 改造前（Forest） | 改造后（ReactiveFeign + Nacos） |
|---------|-----------------|------------------------------|
| **调用目标** | `${baseUrl}/api/scrm/crm_points_rule/listSync` | `nms4cloud-crm` + `/crm_points_rule/listSync` |
| **服务发现** | ❌ 依赖配置中心变量 `${baseUrl}` | ✅ Nacos 动态服务发现 |
| **pos3boot** | Forest 通过网关访问 | 不变，仍走 Forest |
| **pos4cloud** | 错误依赖 `${baseUrl}`，解析失败 | `@Primary` 覆盖，服务名直调 |
| **可用性** | 依赖配置稳定性 | 依赖 Nacos 实例健康度 |

### 3.4 验证方法

改造完成后，可通过以下方式验证：

```
1. pos4cloud 日志中无 [Forest] Cannot resolve variable 'baseUrl' 错误
2. 调用链路变为：pos4cloud -> ReactiveFeign -> nms4cloud-crm -> /crm_points_rule/listSync
3. CRM Nacos 注册实例列表中可见 nms4cloud-crm 健康实例
4. POS 同步后 crm_points_rule 表有数据
```

---

## 4. Nacos 实例污染问题详解

### 4.1 现象

改为服务发现调用后，出现了新的问题：服务名解析成功，但随机命中了不可达实例，导致连接超时。

```
服务名 nms4cloud-crm 解析成功
→ 随机选中一个实例（可能是 Docker/WSL/虚拟网卡地址）
→ 连接超时
```

### 4.2 根因分析

Nacos 实例池中混入了以下类型的不可达地址：

| 实例类型 | 典型地址 | 不可达原因 |
|---------|---------|-----------|
| Docker 容器实例 | 172.17.x.x（Docker 网桥） | 跨主机网络隔离 |
| WSL 虚拟机实例 | 172.19.x.x（WSL 网卡） | Windows/Linux 网络隔离 |
| 测试/旧实例 | 已停止但未从 Nacos 注销 | 实例已下线 |
| 重复注册 | 同一服务多个端口注册 | 负载不均 |

**为什么会随机命中**：Nacos 默认使用加权随机负载均衡，实例列表中同时包含健康和不健康的实例时，会随机选中不健康实例。

### 4.3 排查命令

```bash
# 1. 查看 Nacos 注册实例列表（检查是否有异常 IP）
curl "http://<nacos-server>:8848/nacos/v1/ns/instance/list?serviceName=nms4cloud-crm"

# 2. 检查 pos4cloud 日志中的实例选择情况
grep "nms4cloud-crm" logs/pos4cloud.log | grep -E "instance|reachable|timeout"

# 3. 检查本地网络是否有 Docker/WSL 虚拟网卡
# Windows:
ipconfig | findstr "172."
# Linux:
ip addr | grep "172."

# 4. 检查 Nacos 实例健康状态
curl "http://<nacos-server>:8848/nacos/v1/ns/instance/healthList?serviceName=nms4cloud-crm"
```

### 4.4 防护方案

| 方案 | 描述 | 优先级 |
|------|------|--------|
| **Nacos 层面过滤** | 在 Nacos 控制台将 Docker/WSL 实例标记为不健康或下线 | 🔴 必须 |
| **客户端重试** | ReactiveFeign 配置超时重试（建议 2 次，超时 3s） | 🟡 推荐 |
| **连接超时配置** | 设置合理的 connectTimeout（默认 3s）和 readTimeout（15s） | 🟡 推荐 |
| **心跳检测** | 确保 CRM 服务正确配置了心跳，不健康实例及时剔除 | 🟡 推荐 |
| **监控告警** | 对「服务发现成功但连接超时」设置告警 | 🟡 推荐 |

代码层面可配置重试：

```java
// ReactiveFeign 配置示例（需确认 framework 是否支持）
reactiveFeign.post(
    CRM_SERVICE_NAME + SYNC_URI,
    request,
    new TypeReference<NmsResult<List<CrmPointsRuleSyncVO>>>() {},
    saToken
);
// 建议在 Feign 配置类中设置：
// - connectTimeout: 3000ms
// - readTimeout: 15000ms
// - retry: 2次
```

---

## 5. 最终收敛结论

### 5.1 `listSync` 是专用同步接口，不是后台列表接口

`@Inner` 注解明确标识这是 POS 同步专用内部接口，与后台管理页面的列表查询接口（`/list`）语义完全不同：
- `/list`：按当前登录用户（门店级）的权限范围查询
- `/listSync`：按 `mid` 全量下发，不受当前门店限制

### 5.2 `CrmPointsRule` 同步应按 `mid` 过滤

当前代码已体现此结论：
- 同步查询按 `mid`
- `planLid` 作为可选条件
- 不按 `sid` 缩小范围

这避免了"先按商户删全量，再按门店回写子集"的不完整覆盖问题。

### 5.3 云端内部调用不应依赖 Forest `${baseUrl}`

| 调用场景 | 正确方式 |
|---------|---------|
| POS 本地 → 云端（通过网关） | Forest + `${baseUrl}` |
| pos4cloud → CRM（云端内部） | ReactiveFeign + Nacos 服务发现 |
| 其他云端服务间调用 | OpenFeign / ReactiveFeign + Nacos |

### 5.4 区分代码问题与运行环境问题

| 问题类型 | 示例 | 处理方式 |
|---------|------|---------|
| **代码问题** | Forest baseUrl 误用到云端内部调用 | 改为服务发现调用 |
| **运行环境问题** | Nacos 实例池混入不可达地址 | 清理/标记异常实例 + 客户端重试 |

---

## 6. 现在仍然有效的结论清单

1. CRM 侧同步出口是 `/crm_points_rule/listSync`
2. 该接口是 `@Inner` 内部接口，非后台查询接口
3. 同步口径是商户级 `mid`
4. 会员日两个同步字段（`memberDayDaysOfWeek`、`memberDayDaysOfMonth`）已补齐
5. 云端内部调用不应再依赖 Forest `${baseUrl}`
6. 若再次出现超时，优先检查 Nacos 实例池是否混入不可达地址

---

## 7. 后续监控建议

| 监控项 | 描述 | 告警阈值 |
|--------|------|---------|
| 同步成功率 | `pos4cloud -> CRM /crm_points_rule/listSync` 成功率 | < 95% 告警 |
| 同步耗时 | 从 pos4cloud 发起到 CRM 返回的耗时 | P99 > 5s 告警 |
| Nacos 实例健康率 | nms4cloud-crm 可达实例数 / 注册实例数 | < 50% 告警 |
| 服务发现超时 | 服务名解析成功但连接超时的次数 | 连续 3 次告警 |

---

## 8. 附录：相关代码文件索引

| 分类 | 文件路径 |
|------|---------|
| **CRM 侧** | |
| 同步 Controller | `D:\mywork\nms4cloud\...\ms4cloud-crm-app\...\CrmPointsRuleController.java` |
| 同步 Service | `D:\mywork\nms4cloud\...\ms4cloud-crm-service\...\CrmPointsRuleServicePlus.java` |
| 同步 VO | `D:\mywork\nms4cloud\...\ms4cloud-crm-api\...\CrmPointsRuleSyncVO.java` |
| 同步 DTO | `D:\mywork\nms4cloud\...\ms4cloud-crm-api\...\CrmPointsRuleListSyncDTO.java` |
| **POS 侧** | |
| 抽象接口 | `D:\mywork\nms4pos\nms4cloud-pos2plugin\...\CrmPointsRuleSyncRemoteService.java` |
| Forest 实现（pos3boot） | `D:\mywork\nms4pos\nms4cloud-pos2plugin\...\CrmPointsRuleForestServiceImpl.java` |
| ReactiveFeign 实现（pos4cloud） | `D:\mywork\nms4pos\nms4cloud-pos4cloud\...\CrmPointsRuleSyncRemoteServiceImpl.java` |
| Forest 接口定义 | `D:\mywork\nms4pos\nms4cloud-pos2plugin\...\Nms4CloudCrmService.java` |
| Interceptor（baseUrl 来源） | `D:\mywork\nms4pos\nms4cloud-pos2plugin\...\Nms4cloudInterceptor.java` |
| 同步入口 | `D:\mywork\nms4pos\nms4cloud-pos2plugin\...\SyncBaseDataService.java` |
| **配置** | |
| pos4cloud Nacos 配置 | `D:\mywork\nms4pos\nms4cloud-pos4cloud\...\bootstrap.yml` |
| pos4cloud 启动类 | `D:\mywork\nms4pos\nms4cloud-pos4cloud\...\Pos4cloudApplication.java` |