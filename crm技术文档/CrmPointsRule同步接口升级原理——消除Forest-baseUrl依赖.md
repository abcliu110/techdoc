# CrmPointsRule 同步接口升级原理——Forest baseUrl 依赖消除

> 状态：已完成
> 更新日期：2026-04-30
> 相关模块：pos2plugin-api、pos2plugin-biz、pos4cloud-feign、pos3boot-biz

---

## 一、背景

### 问题现象

`pos4cloud` 调用 `/sync/list` 同步 `CrmPointsRule` 时报错：

```
[Forest] Cannot resolve variable 'baseUrl'
```

### 根因分析

2026-04-27 提交 `dfee35bb7` 在 `Pos4cloudApplication` 中添加了：

```java
@ForestScan(basePackages = {"com.nms4cloud.pos2plugin.service.member.cloud"})
```

这一行导致 `Nms4CloudCrmService`（Forest 接口）在 pos4cloud 应用中被实例化。`Nms4CloudCrmService` 的 `listPointsRule` 方法使用了 `${baseUrl}` 变量：

```java
@BaseRequest(baseURL = "${baseUrl}/api/scrm")
public interface Nms4CloudCrmService {
    @Post("/crm_points_rule/listSync")
    NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(@JSONBody CrmPointsRuleListDTO request);
}
```

`${baseUrl}` 变量在 pos4cloud 的配置文件中不存在，因此 Forest 框架在实例化接口时报错。

**注意**：pos4cloud 没有 `${baseUrl}` 配置是正确的——pos4cloud 使用 Nacos 服务发现调 CRM，不走固定 baseUrl。

---

## 二、方案设计

### 2.1 核心思路

接口抽象 + 两端各自实现。通过 Spring 依赖注入优先级机制，让 pos4cloud 和 pos3boot 使用不同的网络客户端调用同一个接口，互不感知。

```
SyncBaseDataService.list()
    ↓ 注入接口（不知道具体实现）
CrmPointsRuleSyncRemoteService（接口）
    ↓
    ├─ pos3boot: CrmPointsRuleForestServiceImpl   → Forest + baseUrl 调 CRM
    └─ pos4cloud: CrmPointsRuleSyncRemoteServiceImpl（@Primary）
                  → ReactiveFeign + Nacos 服务发现调 nms4cloud-crm
```

### 2.2 依赖可行性验证

| 模块 | ReactiveFeign | RedisTemplatePlus | 说明 |
|------|:---:|:---:|------|
| `pos2plugin-biz` | ❌ 无 | ✅ 有 | 被 pos4cloud 排除了 `starter-cloud`，不能直接用 ReactiveFeign |
| `pos4cloud-feign` | ✅ 有 | ✅ 有 | 已有完整 reactive 基础设施 |
| `pos3boot-biz` | ❌ 无 | ✅ 有 | 不需要，Forest 通过拦截器处理认证 |

**结论**：ReactiveFeign 实现只能放在 `pos4cloud-feign`，不能放在 `pos2plugin-biz`。

---

## 三、实现详解

### 3.1 新增接口——CrmPointsRuleSyncRemoteService

**位置**：`nms4cloud-pos2plugin-api/.../service/CrmPointsRuleSyncRemoteService.java`

```java
public interface CrmPointsRuleSyncRemoteService {
    NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request);
}
```

放在 `pos2plugin-api` 模块，与已有的 DTO/VO 同模块，无需新增任何依赖。

### 3.2 新增 Forest 实现——pos3boot 侧

**位置**：`nms4cloud-pos2plugin-biz/.../service/member/cloud/CrmPointsRuleForestServiceImpl.java`

```java
@Service
public class CrmPointsRuleForestServiceImpl implements CrmPointsRuleSyncRemoteService {
    @Autowired private Nms4CloudCrmService nms4CloudCrmService;

    @Override
    public NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request) {
        return nms4CloudCrmService.listPointsRule(request);
    }
}
```

- pos3boot 唯一实现，无需标注 `@Primary`
- 委托给现有 `Nms4CloudCrmService`，pos3boot 侧完全无感知
- 原有 Forest 拦截器（添加商户签名）自动生效

### 3.3 新增 ReactiveFeign 实现——pos4cloud 侧

**位置**：`nms4cloud-pos4cloud-feign/.../sync/CrmPointsRuleSyncRemoteServiceImpl.java`

```java
@Slf4j
@Service
@Primary  // 覆盖 pos2plugin-biz 中的 Forest 实现
public class CrmPointsRuleSyncRemoteServiceImpl implements CrmPointsRuleSyncRemoteService {

    private static final String CRM_SERVICE_NAME = "nms4cloud-crm";
    private static final String SYNC_URI = "/crm_points_rule/listSync";

    @Override
    public NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request) {
        String saToken = redisTemplatePlus.get("nms4token:var:same-token");
        Mono<NmsResult<List<CrmPointsRuleSyncVO>>> mono = reactiveFeign.post(
            CRM_SERVICE_NAME + SYNC_URI,
            request,
            new TypeReference<NmsResult<List<CrmPointsRuleSyncVO>>>() {},
            saToken);
        return mono.block();
    }

    @Autowired private ReactiveFeign reactiveFeign;
    @Autowired private RedisTemplatePlus redisTemplatePlus;
}
```

- `@Primary` 标注：确保 pos4cloud 优先使用本实现
- 通过 Nacos 服务发现寻址 `nms4cloud-crm`，不依赖 `forest.variables.baseUrl`
- same-token 模式沿用 pos4cloud 现有封装（Redis key `nms4token:var:same-token`）
- `.block()` 将 `Mono` 转为同步结果，与现有 `WmsProductSyncReactiveFeign` 模式一致

### 3.4 修改 SyncBaseDataService

**文件**：`nms4cloud-pos2plugin-biz/.../service/sync/SyncBaseDataService.java`

```diff
- import com.nms4cloud.pos2plugin.service.member.cloud.Nms4CloudCrmService;
+ import com.nms4cloud.pos2plugin.api.service.CrmPointsRuleSyncRemoteService;

  ...

- @Autowired private Nms4CloudCrmService nms4CloudCrmService;
+ @Autowired private CrmPointsRuleSyncRemoteService crmPointsRuleSyncRemoteService;

  ...

- NmsResult<List<CrmPointsRuleSyncVO>> result = nms4CloudCrmService.listPointsRule(crmRequest);
+ NmsResult<List<CrmPointsRuleSyncVO>> result = crmPointsRuleSyncRemoteService.listPointsRule(crmRequest);
```

调用方行为不变，仅注入对象从具体类改为接口。

---

## 四、架构行为对照

| | pos3boot | pos4cloud |
|--|---------|----------|
| 实现类 | `CrmPointsRuleForestServiceImpl`（Forest） | `CrmPointsRuleSyncRemoteServiceImpl`（ReactiveFeign，@Primary） |
| 调用目标 | `${baseUrl}/api/scrm/crm_points_rule/listSync` | `nms4cloud-crm/crm_points_rule/listSync`（Nacos 服务发现） |
| 认证方式 | Forest Interceptor 自动添加商户/终端签名 | Redis key `nms4token:var:same-token` |
| 依赖 | `forest.variables.baseUrl` | `ReactiveFeign` + `RedisTemplatePlus`（via `starter-cloud`） |
| pos4cloud 改动 | 无 | 仅新增 2 个文件 |

---

## 五、调用链对比

### pos3boot 全量同步调用链

```
FullSyncDataService.handleAllTable()
  → downloadTableToFile(CrmPointsRule.class)
    → mapper.paginate()          // 直接查本地 DB（无 mid/-2）
    [CrmPointsRule 不走特殊分支]

FullSyncDataService.handleAllTable()
  → commitTableFromFile(CrmPointsRule.class, crmPointsRuleMapper)
    → mapper.deleteByQuery()     // DELETE FROM crm_points_rule WHERE mid in (...)
    → mapper.insertBatch()
```

> 注意：全量同步不走 `SyncBaseDataService.list()`，直接用 mapper 读写本地数据库表。本方案不改变此行为。

### pos4cloud 增量同步调用链

```
POST /api/pos4cloud/sync/list
  → SyncBaseDataService.list()
    → crmPointsRuleSyncRemoteService.listPointsRule(crmRequest)
      → CrmPointsRuleSyncRemoteServiceImpl (ReactiveFeign, @Primary)
        → ReactiveFeign.post("nms4cloud-crm/crm_points_rule/listSync", ...)
          → Nacos 服务发现 → nms4cloud-crm → CRM 数据库
    → toCrmPointsRule()          // VO → Entity 映射
    → Page 返回
```

---

## 六、不改的文件

| 文件 | 说明 |
|------|------|
| `Pos4cloudApplication.java` | 保持 `@ForestScan`，其他 Forest 会员操作不受影响 |
| `Nms4CloudCrmService.java` | 保留所有 Forest 方法，完全不动 |
| `SyncBaseDataService.list()` 内部逻辑 | 只改 1 行注入 + 1 行调用 |
| pos3boot 任何配置 | 无感知 |

---

## 七、常见问题

### Q1：pos4cloud 中 `CrmPointsRuleForestServiceImpl` 仍然被实例化，会报错吗？

不会。`CrmPointsRuleForestServiceImpl` 本身不持有 `${baseUrl}` 变量，`${baseUrl}` 仅在 `Nms4CloudCrmService`（Forest 接口）实例化时才解析。由于 `SyncBaseDataService` 现在注入的是接口，`CrmPointsRuleForestServiceImpl` 中的 `Nms4CloudCrmService` 字段不会被调用，不会触发变量解析。

### Q2：为什么不用 ReactiveFeign 替代 Forest？

`pos2plugin-biz` 被 pos4cloud 排除了 `nms4cloud-starter-cloud`（含 ReactiveFeign），不能在其中直接使用 ReactiveFeign。放在 `pos4cloud-feign` 是最小侵入方案。

### Q3：`.block()` 在同步方法中是否合适？

`SyncBaseDataService.list()` 是同步方法，`CrmPointsRuleSyncRemoteServiceImpl` 使用 `.block()` 将 `Mono` 转为同步结果，与现有 `pos4cloud-feign` 中的 `WmsProductSyncReactiveFeign` 模式一致。

### Q4：全量同步（pos3boot）和增量同步（pos4cloud）走的逻辑一样吗？

不一样：

- **pos3boot 全量同步**：通过 `FullSyncDataService` 遍历 `classMapper`，直接用 `CrmPointsRuleMapper` 操作本地数据库。下载阶段走 Forest（因为本地 mapper.paginate 无 mid 数据），提交阶段写本地 DB。
- **pos4cloud 增量同步**：通过 `SyncBaseDataService.list()`，特殊分支走接口调用 → ReactiveFeign → CRM → 返回 VO → 写入本地 DB。