# CrmPointsRule 同步去除 Forest baseUrl 依赖 — 实施方案

> 状态：**已实现**，待审核
> 更新时间：2026-04-30

## 背景

`pos4cloud` 调用 `/sync/list` 同步 `CrmPointsRule` 时报错：

```
[Forest] Cannot resolve variable 'baseUrl'
```

**根因**：2026-04-27 提交 `dfee35bb7` 在 `Pos4cloudApplication` 添加了 `@ForestScan(basePackages = {"com.nms4cloud.pos2plugin.service.member.cloud"})`，导致 `Nms4CloudCrmService`（Forest 接口）在 pos4cloud 中被实例化。`Nms4CloudCrmService` 使用 `${baseUrl}` 变量，但 pos4cloud 本地资源没有此配置。

## 方案概述

**核心思路**：接口抽象 + 两端各自实现。

```
SyncBaseDataService.list()
    ↓ 注入接口
CrmPointsRuleSyncRemoteService（接口）
    ↓
    ├─ pos3boot: CrmPointsRuleForestServiceImpl    → Forest 调 CRM（复用原有 baseUrl 配置）
    └─ pos4cloud: CrmPointsRuleSyncRemoteServiceImpl (@Primary)
                    → ReactiveFeign + Nacos 服务发现调 nms4cloud-crm（不依赖 baseUrl）
```

## 依赖可行性验证

| 模块 | ReactiveFeign | RedisTemplatePlus | 说明 |
|------|---------------|-------------------|------|
| `pos2plugin-biz` | ❌ 无（被 `starter-cloud` 排除） | ✅ 有（via `pos1starter`） | 不能直接用 ReactiveFeign |
| `pos4cloud-feign` | ✅ 有（via `starter-cloud`） | ✅ 有 | 有完整 reactive 基础设施 |
| `pos3boot-biz` | ❌ 无 | ✅ 有 | 不需要，Forest 走拦截器 |

**结论**：ReactiveFeign 实现只能放在 `pos4cloud-feign`，不能放在 `pos2plugin-biz`（后者被 pos4cloud 排除了 `starter-cloud`）。

## 改动清单

### 1. 新增接口（CrmPointsRuleSyncRemoteService）

**路径**：
```
nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/service/CrmPointsRuleSyncRemoteService.java
```

```java
package com.nms4cloud.pos2plugin.api.service;

import com.nms4cloud.common.util.NmsResult;
import com.nms4cloud.pos2plugin.api.dto.member.CrmPointsRuleListDTO;
import com.nms4cloud.pos2plugin.api.vo.member.CrmPointsRuleSyncVO;
import java.util.List;

public interface CrmPointsRuleSyncRemoteService {

  NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request);
}
```

放置在 `pos2plugin-api`，与已有的 DTO/VO 同模块。

---

### 2. 新增 Forest 实现（pos3boot 侧）

**路径**：
```
nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/member/cloud/CrmPointsRuleForestServiceImpl.java
```

```java
package com.nms4cloud.pos2plugin.service.member.cloud;

import com.nms4cloud.common.util.NmsResult;
import com.nms4cloud.pos2plugin.api.dto.member.CrmPointsRuleListDTO;
import com.nms4cloud.pos2plugin.api.service.CrmPointsRuleSyncRemoteService;
import com.nms4cloud.pos2plugin.api.vo.member.CrmPointsRuleSyncVO;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CrmPointsRuleForestServiceImpl implements CrmPointsRuleSyncRemoteService {

  @Autowired private Nms4CloudCrmService nms4CloudCrmService;

  @Override
  public NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request) {
    return nms4CloudCrmService.listPointsRule(request);
  }
}
```

- `pos3boot` 唯一实现，无需 `@Primary`
- 委托给现有 `Nms4CloudCrmService`，pos3boot 侧完全无感知

---

### 3. 新增 ReactiveFeign 实现（pos4cloud 侧）

**路径**：
```
nms4cloud-pos4cloud-feign/src/main/java/com/nms4cloud/pos2plugin/api/sync/CrmPointsRuleSyncRemoteServiceImpl.java
```

```java
package com.nms4cloud.pos2plugin.api.sync;

import com.alibaba.fastjson2.TypeReference;
import com.nms4cloud.cloud.feign.ReactiveFeign;
import com.nms4cloud.cloud.util.RedisTemplatePlus;
import com.nms4cloud.common.util.NmsResult;
import com.nms4cloud.pos2plugin.api.dto.member.CrmPointsRuleListDTO;
import com.nms4cloud.pos2plugin.api.service.CrmPointsRuleSyncRemoteService;
import com.nms4cloud.pos2plugin.api.vo.member.CrmPointsRuleSyncVO;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Slf4j
@Service
@Primary
public class CrmPointsRuleSyncRemoteServiceImpl implements CrmPointsRuleSyncRemoteService {

  private static final String CRM_SERVICE_NAME = "nms4cloud-crm";
  private static final String SYNC_URI = "/crm_points_rule/listSync";

  @Override
  public NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(CrmPointsRuleListDTO request) {
    String saToken = redisTemplatePlus.get("nms4token:var:same-token");
    Mono<NmsResult<List<CrmPointsRuleSyncVO>>> mono =
        reactiveFeign.post(
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

- `@Primary`：确保 pos4cloud 优先使用本实现
- same-token 模式沿用 pos4cloud 现有 WMS/BizUser 封装
- 不依赖 `forest.variables.baseUrl`

**pom.xml 无需改动**：`pos4cloud-feign` → `pos4cloud-api` → `pos2plugin-api`（DTO/VO）+ `starter-cloud`（ReactiveFeign + RedisTemplatePlus），所有类型均已满足。

---

### 4. 修改 SyncBaseDataService（pos2plugin-biz）

**路径**：
```
nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/sync/SyncBaseDataService.java
```

**改动点**：

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

## 架构行为对照

| | pos3boot | pos4cloud |
|--|---------|----------|
| 实现类 | `CrmPointsRuleForestServiceImpl`（Forest） | `CrmPointsRuleSyncRemoteServiceImpl`（ReactiveFeign，`@Primary`） |
| 调用目标 | `${baseUrl}/api/scrm/crm_points_rule/listSync` | `nms4cloud-crm/crm_points_rule/listSync`（Nacos 服务发现） |
| Same-Token | Forest Interceptor 自动处理 | Redis key `nms4token:var:same-token` |
| pos4cloud 改动 | 无 | 仅新增 2 个文件 |

## 不改的文件

- `Pos4cloudApplication.java`（保持 `@ForestScan`，其他 Forest 会员操作不受影响）
- `Nms4CloudCrmService.java`（保留所有 Forest 方法，完全不动）
- `SyncBaseDataService` 内部逻辑（只改 1 行注入 + 1 行调用）
- `pos3boot` 任何配置（无感知）

## 验证步骤

### 1. 验证 pos4cloud 同步出口（核心验证）

```bash
POST /api/pos4cloud/sync/list
Content-Type: application/json

{
  "body": {
    "current": 1,
    "pageSize": 100,
    "tableName": "CrmPointsRule",
    "isPlatform": false
  }
}
```

预期：
- 不再报 `[Forest] Cannot resolve variable 'baseUrl'`
- pos4cloud 通过 Nacos 服务发现调通 `nms4cloud-crm/crm_points_rule/listSync`
- 不出现 CRM `@Inner` token 校验失败

### 2. 验证 pos3boot 全量同步（回归）

```bash
POST /sync/all
```

预期：
- 下载阶段正常
- POS 本地 `crm_points_rule` 有数据

### 3. 回归验证

执行普通同步表（如 `BizDiscount`、`PtDish`），确认 `mapper.paginate(...)` 通用能力不受影响。

## 方案边界

本方案只解决：

```
pos4cloud 调 CRM 下载积分权益表时，不依赖 Forest baseUrl
```

不改变：
- POS 全量同步入口
- CRM 数据库归属
- CRM `/crm_points_rule/listSync` 查询逻辑
- 其他 Forest CRM 客户端方法（会员操作等）

## 潜在问题

### Q1：pos4cloud 中 `CrmPointsRuleForestServiceImpl` 仍然被实例化，会报错吗？

不会。`CrmPointsRuleForestServiceImpl` 本身不持有 `${baseUrl}` 变量，`${baseUrl}` 仅在 `Nms4CloudCrmService`（Forest 接口）实例化时才解析。由于 `SyncBaseDataService` 现在注入的是接口，`CrmPointsRuleForestServiceImpl` 中的 `Nms4CloudCrmService` 字段不会被调用，不会触发变量解析。

### Q2：为什么不用 `ReactiveFeign` 替代 Forest？

`pos2plugin-biz` 被 `pos4cloud` 排除了 `nms4cloud-starter-cloud`（含 ReactiveFeign），不能在其中直接使用 ReactiveFeign。放在 `pos4cloud-feign` 是最小侵入方案。

### Q3：`.block()` 在同步方法中是否合适？

`SyncBaseDataService.list()` 是同步方法，`CrmPointsRuleSyncRemoteServiceImpl` 使用 `.block()` 将 `Mono` 转为同步结果，与现有 `pos4cloud-feign` 中的 `WmsProductSyncReactiveFeign` 模式一致。
