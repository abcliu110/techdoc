# CrmPointsRule 同步去除 Forest baseUrl 依赖方案

更新时间：2026-04-30

## 结论

积分权益表 `CrmPointsRule` 下载到 POS 本地时，建议继续复用现有同步链路：

```text
pos3boot /sync/all
  -> pos4cloud /sync/list
  -> pos4cloud 调 CRM 内部接口 /crm_points_rule/listSync
  -> pos3boot 写入本地 crm_points_rule
```

但 `pos4cloud -> CRM` 这一段不建议复用 Forest 的 `Nms4CloudCrmService`，因为它依赖：

```text
forest.variables.baseUrl
```

当前 `pos3boot` 的 profile 里有这个配置，`pos4cloud` 本地资源里没有。为了避免给 `pos4cloud` 新增网关 baseUrl 配置，推荐改为使用 `pos4cloud` 已有先例中的 `ReactiveFeign + 服务名 + same-token` 模式。

## 为什么不用 Forest baseUrl

`Nms4CloudCrmService` 当前定义：

```java
@BaseRequest(baseURL = Nms4cloudInterceptor.DEF_BASE_URL + "scrm")
```

其中：

```java
public static final String DEF_BASE_URL = "${baseUrl}/api/";
```

所以最终请求依赖 `${baseUrl}` 变量，形态是：

```text
{baseUrl}/api/scrm/crm_points_rule/listSync
```

这适合 POS 本地 `pos3boot` 通过网关访问云端服务；但 `pos4cloud` 本身已经在云端服务集群内，调用 CRM 不需要绕外部网关，也不应该为了这一条同步链路新增 Forest baseUrl 依赖。

## pos4cloud 现有先例

`pos4cloud` 已经有服务名内部调用的写法，不依赖 Forest baseUrl。

### 调 pos5sync

文件：

```text
D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-biz\src\main\java\com\nms4cloud\pos4cloud\controller\sync\CanalEventController.java
```

代码形态：

```java
reactiveFeign.post(
    "nms4cloud-pos5sync/platform/canal_event/list",
    request,
    new TypeReference<>() {});
```

### 调 WMS 内部接口

文件：

```text
D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-feign\src\main\java\com\nms4cloud\pos2plugin\api\admin\wms_product\WmsProductSyncReactiveFeign.java
```

代码形态：

```java
String saToken = redisTemplatePlus.get("nms4token:var:same-token");
String url = "nms4cloud-wms/inner/wms_sync/";
return reactiveFeign.post(url + uri, body, typeReference, saToken);
```

这类写法的关键点是：

1. URI 使用 Nacos 服务名，例如 `nms4cloud-wms`。
2. 内部接口鉴权使用 `nms4token:var:same-token`。
3. `ReactiveFeign` 自动通过负载均衡 WebClient 调服务名。

`CrmPointsRule` 同步可以照这个模式新增 CRM 内部调用封装。

## 推荐改动

### 1. 新增 CRM 积分权益规则内部调用封装

建议放在 `pos2plugin-biz`，避免 `pos2plugin-biz` 反向依赖 `pos4cloud-feign`：

```text
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\cloud\CrmPointsRuleReactiveFeign.java
```

职责：

```text
POST nms4cloud-crm/crm_points_rule/listSync
```

建议结构：

```java
@Slf4j
@Service
public class CrmPointsRuleReactiveFeign {

  public NmsResult<List<CrmPointsRuleSyncVO>> listSync(CrmPointsRuleListDTO request) {
    String saToken = redisTemplatePlus.get("nms4token:var:same-token");
    return reactiveFeign
        .post(
            "nms4cloud-crm/crm_points_rule/listSync",
            request,
            new TypeReference<NmsResult<List<CrmPointsRuleSyncVO>>>() {},
            saToken)
        .block();
  }

  @Autowired private ReactiveFeign reactiveFeign;
  @Autowired private RedisTemplatePlus redisTemplatePlus;
}
```

说明：

- 不使用 `Nms4CloudCrmService`。
- 不需要 `forest.variables.baseUrl`。
- 不需要新增 `Nms4CloudCrmExecuteProvider`。
- 使用 CRM 服务名 `nms4cloud-crm`。
- 使用 same-token 通过 CRM `@Inner` 校验。

### 2. 修改 SyncBaseDataService 的 CrmPointsRule 分支

文件：

```text
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\sync\SyncBaseDataService.java
```

恢复同步注册：

```java
classMapper.put(CrmPointsRule.class, crmPointsRuleMapper);
```

当前源码中这行被注释：

```java
// 暂时禁用积分权益规则同步
// classMapper.put(CrmPointsRule.class, crmPointsRuleMapper);
```

需要恢复，否则 `pos4cloud /sync/list` 收到：

```text
tableName=CrmPointsRule
```

会在 `classNameMap` 中找不到类，返回：

```text
未找到对应的类:CrmPointsRule
```

将原来 Forest 调用：

```java
NmsResult<List<CrmPointsRuleSyncVO>> result = nms4CloudCrmService.listPointsRule(crmRequest);
```

改为：

```java
NmsResult<List<CrmPointsRuleSyncVO>> result = crmPointsRuleReactiveFeign.listSync(crmRequest);
```

并注入：

```java
@Autowired private CrmPointsRuleReactiveFeign crmPointsRuleReactiveFeign;
```

### 3. 保持 CRM listSync 接口不变

CRM 端已有接口：

```text
POST /crm_points_rule/listSync
```

文件：

```text
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-app\src\main\java\com\nms4cloud\crm\app\controller\pointsrule\CrmPointsRuleController.java
```

代码：

```java
@Inner
@PostMapping("/listSync")
public NmsResult<List<CrmPointsRuleSyncVO>> listCrmPointsRuleSync(
    @Valid @RequestBody CrmPointsRuleListSyncDTO request) {
  return crmPointsRuleServicePlus.listSync(request);
}
```

不需要让 `pos4cloud` 直连 CRM 数据库。

## 注意点

### DTO 类型是否复用

`pos2plugin` 侧当前已有：

```text
CrmPointsRuleListDTO
CrmPointsRuleSyncVO
```

CRM 侧接口参数是：

```text
CrmPointsRuleListSyncDTO
```

如果字段完全兼容，`ReactiveFeign` 直接传 `CrmPointsRuleListDTO` 也可以，因为 HTTP JSON 只看字段名。更严谨的做法是在 POS 侧新增一个专用 request DTO 或复用现有 DTO 时明确字段包含：

```text
mid
sid
planLid
current
pageSize
```

### same-token 来源

参考 pos4cloud 现有 WMS 封装，使用：

```java
redisTemplatePlus.get("nms4token:var:same-token")
```

这是现有 pos4cloud 跨服务内部调用模式。不要使用 POS 本地签名逻辑：

```text
merchantNo / terminalId / sign
```

因为 CRM `/crm_points_rule/listSync` 是 `@Inner` 接口，不是 POS 会员操作签名接口。

### 本地表结构

同步能请求成功不代表 POS 本地字段完整。仍需要检查：

```text
CrmPointsRuleSyncVO
CrmPointsRule 本地实体
SyncBaseDataService.toCrmPointsRule()
本地数据库升级
```

尤其注意 CRM 返回的：

```text
memberDayDaysOfWeek
memberDayDaysOfMonth
```

如果 POS 本地计算积分权益需要这两个字段，需要补齐 VO、实体字段、字段映射和本地表列。

## 验证步骤

### 1. 验证 CRM 内部接口

确认 CRM `/crm_points_rule/listSync` 能按以下字段返回数据：

```text
mid
sid
current
pageSize
```

返回结果需要包含分页信息：

```text
current
pageSize
total
pages
data
```

### 2. 验证 pos4cloud 同步出口

请求：

```text
POST /api/pos4cloud/sync/list
```

body 中：

```json
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

- 不再报 `未找到对应的类:CrmPointsRule`。
- 不再依赖 `${baseUrl}`。
- 不出现 CRM `@Inner` token 校验失败。
- 返回数据可被反序列化为 POS 本地 `CrmPointsRule`。

### 3. 验证 pos3boot 全量同步

执行：

```text
POST /sync/all
```

再查：

```text
POST /sync/progress
```

预期：

- 下载阶段成功。
- 提交阶段成功。
- POS 本地 `crm_points_rule` 有数据。

### 4. 验证本地数据

查询 POS 本地库：

```sql
select count(*) from crm_points_rule;
select lid, mid, sid, plan_lid, points_rule_enabled from crm_points_rule limit 10;
```

核对 CRM 返回的关键字段。

## 最小落地清单

1. 新增 `CrmPointsRuleReactiveFeign`，使用 `ReactiveFeign` 调 `nms4cloud-crm/crm_points_rule/listSync`。
2. `SyncBaseDataService` 恢复 `CrmPointsRule` 注册。
3. `SyncBaseDataService` 的积分权益分支改用新 ReactiveFeign，不再使用 Forest `Nms4CloudCrmService`。
4. 检查并补齐 POS 本地 `CrmPointsRule` 字段、VO 和转换。
5. 部署 CRM、pos4cloud、pos3boot 后执行全量同步验证。

## 方案边界

本方案只解决：

```text
pos4cloud 调 CRM 下载积分权益表时，不依赖 Forest baseUrl
```

不改变：

- POS 全量同步入口。
- CRM 数据库归属。
- CRM `/crm_points_rule/listSync` 查询逻辑。
- 普通 POS 表由 pos4cloud 直查 POS 云端库的同步方式。
