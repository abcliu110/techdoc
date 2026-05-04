# CrmPointsRule 同步链路与 Nacos 服务发现问题复盘

> 状态：已完成  
> 更新时间：2026-04-30  
> 相关模块：`nms4cloud-crm`、`nms4cloud-pos4cloud`、`nms4cloud-pos3boot`、`nms4cloud-pos2plugin`

---

## 一、问题背景

本次排查围绕 `CrmPointsRule`（积分权益规则）从云端同步到 POS 本地的链路展开，过程中连续出现了三类问题：

1. POS 本地同步提交阶段报错：

```text
Table 'nms.crm_points_rule' doesn't exist
```

2. `pos4cloud` 调 CRM 同步接口时报错：

```text
[Forest] Cannot resolve variable 'baseUrl'
```

3. 改为 `ReactiveFeign + Nacos` 后，`pos4cloud` 又出现调用超时：

```text
Request to POST http://nms4cloud-crm/crm_points_rule/listSync
connection timed out after 10000 ms: /172.18.0.6:18138
```

表面上看像是三个独立故障，实际属于同一条同步链路上的不同节点问题。

---

## 二、最终结论

### 2.1 积分权益同步接口是专用同步接口

`/crm_points_rule/listSync` 是专门给 POS 同步使用的内部接口，不是普通后台列表接口。

控制器定义：

- `@Inner`
- `@PostMapping("/listSync")`

因此，这条接口的过滤逻辑应该服务于“POS 全量/分页同步”，而不是后台管理页面按门店浏览的场景。

### 2.2 CrmPointsRule 同步应按商户维度过滤

本次确认后，已将 `CrmPointsRule` 同步逻辑改为：

- 同步查询只按 `mid` 过滤
- 不再按当前 POS 门店 `sid` 缩小范围
- `planLid` 仍可作为可选补充条件

原因：

1. 积分权益规则本质上是商户级会员规则配置，同一商户下的 POS 需要同步完整规则集。
2. 如果按 `sid` 查，容易只同步到当前门店归属的子集。
3. POS 本地提交前删除旧数据是按 `mid` 删除，不按 `sid` 删除；若查询阶段按 `sid` 缩小，最终会出现“先删商户全集，再写回门店子集”的不完整覆盖。

### 2.3 本次超时的根因不是同步代码，而是 Nacos 服务发现实例池被污染

`pos4cloud` 调 `nms4cloud-crm` 时，Nacos 返回了以下 CRM 实例：

```text
172.18.0.6:18138
172.19.16.1:18138
```

其中：

- `172.18.0.6` 是 Docker 容器网段地址
- `172.19.16.1` 是 WSL/Hyper-V 虚拟网卡地址

`pos4cloud` 在服务发现调用时随机命中 `172.18.0.6:18138`，而该地址对当前调用方不可达，因此超时。

将 `172.18.0.6:18138` 从 Nacos 下线后，同步立即恢复，说明：

1. `CrmPointsRule` 的同步调用逻辑已经通了
2. 本次网络超时的直接根因是错误实例进入了同一个服务池

---

## 三、CrmPointsRule 同步完整链路

### 3.1 POS 触发全量同步

POS 本地通过：

```text
POST /sync/all
```

进入：

```text
SyncDataController.syncAll()
  -> FullSyncDataService.handleAllTable()
```

`FullSyncDataService` 会遍历同步表，逐张下载，再统一提交本地数据库。

### 3.2 POS 下载 CrmPointsRule 分页数据

下载阶段，POS 本地会向 `pos4cloud` 发送：

```text
POST /sync/list
```

请求体中关键字段：

- `tableName=CrmPointsRule`
- `current`
- `pageSize`
- `isPlatform`

### 3.3 pos4cloud 进入 CrmPointsRule 特殊分支

`SyncBaseDataService.list()` 对普通表走本地 `mapper.paginate(...)`，但对 `CrmPointsRule` 走专门分支：

```text
SyncBaseDataService.list()
  -> if (CrmPointsRule.class.equals(clazz))
  -> crmPointsRuleSyncRemoteService.listPointsRule(...)
```

这里不会直接查 `pos4cloud` 自己的数据库，而是转调 CRM 服务。

### 3.4 pos4cloud 调 CRM 同步接口

当前实现已经不是 Forest，而是：

```text
ReactiveFeign + 服务名 nms4cloud-crm + /crm_points_rule/listSync
```

调用形态：

```text
reactiveFeign.post(
  "nms4cloud-crm/crm_points_rule/listSync",
  request,
  ...,
  saToken
)
```

也就是说：

- 地址不是写死的
- 不是从本地配置拼 `baseUrl`
- 而是通过 Nacos 服务发现找到 `nms4cloud-crm` 的实例列表

### 3.5 CRM 查询积分权益规则

CRM 端接口：

```text
POST /crm_points_rule/listSync
```

是内部接口，控制器上带 `@Inner`。

服务层查询逻辑最终为：

```text
mid = request.mid
and plan_lid = request.planLid（如果有）
order by lid asc
```

本次已明确：同步专用逻辑不再按 `sid` 过滤。

### 3.6 CRM 返回同步 VO

CRM 返回 `CrmPointsRuleSyncVO`，其中包含：

- `mid`
- `sid`
- `lid`
- `planLid`
- 各种积分获取、抵扣、清零规则字段
- JSON 数组字段序列化后的字符串

### 3.7 pos4cloud 转成本地 POS 实体结构

`SyncBaseDataService.toCrmPointsRule()` 会把 CRM 同步 VO 转为 POS 本地实体 `CrmPointsRule`。

当前字段映射已包含：

- `memberDayDaysOfWeek`
- `memberDayDaysOfMonth`

因此“会员日字段丢失”这一问题在当前代码里已经补齐。

### 3.8 POS 提交本地数据库

下载完成后，POS 本地统一执行提交：

```text
FullSyncDataService.commitTableFromFile()
```

对商户数据的处理逻辑是：

1. 先删除本地旧数据
2. 再批量插入新数据

删除条件：

```sql
mid in (-2, 当前商户mid)
```

因此 `CrmPointsRule` 同步如果查询阶段只返回某个 `sid` 的子集，就会造成数据不完整，这也是本次改成“只按 `mid` 查”的直接理由。

---

## 四、本地 `crm_points_rule` 表为什么会不存在

### 4.1 本地表不是通过同步自动创建的

POS 本地 `crm_points_rule` 表结构来自 POS 代码里的本地实体：

```text
com.nms4cloud.pos2plugin.dal.entity.CrmPointsRule
```

不是 CRM 云端数据库把表结构直接复制下来。

### 4.2 建表依赖 POS 启动升级器

POS 启动时会执行：

```text
MybatisFlexBootstrap.start()
new VerMgrServer().upgrade(false)
```

升级器会扫描 `com.nms4cloud.pos2plugin.dal.entity` 下的实体类，如果本地数据库缺表，则自动 `CREATE TABLE`。

### 4.3 为什么没有自动建表

根因在版本门禁。

升级器先比较：

- `verInfo.ini` 中的 `POS_VERSION`
- 本地数据库 `sys_config_data` 中的 `POS_VERSION`

如果版本一致，则：

```text
upgrade(false) 直接返回
```

不会再扫描实体，也不会建新表。

本次实查结果：

- `verInfo.ini` = `2026-04-27 18:34:47`
- 本地 DB `POS_VERSION` = `2026-04-27 18:34:47`

所以虽然代码里已经有 `CrmPointsRule` 实体，本地库仍然不会自动补建表。

### 4.4 正确处理方式

先执行：

```text
POST /systemSetting/upgrade
```

该接口会调用：

```text
verMgrServer.upgrade(true)
```

即强制升级，跳过版本一致检查，重新扫描实体并建表。

---

## 五、Nacos 在本系统中的作用

Nacos 在这套系统中承担两类能力：

### 5.1 配置中心（Config）

服务启动时从 Nacos 拉取配置，例如：

- `nms4cloud-shared.yaml`
- `nms4cloud-crm.yaml`
- `nms4cloud-pos4cloud.yaml`

代码里的配置入口是：

```yaml
spring:
  cloud:
    nacos:
      config:
        server-addr: 192.168.1.216:8848
        namespace: 56a75109-dbdc-4c5a-8fc1-b2300cef7f4a
```

### 5.2 服务发现（Discovery）

服务启动后把自己注册到 Nacos，其他服务通过服务名调用，例如：

```text
nms4cloud-crm
nms4cloud-pos4cloud
```

代码里的入口是：

```yaml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: 192.168.1.216:8848
```

---

## 六、这次 Nacos 问题的本质

### 6.1 代码层面的配置现状

`crm` 和 `pos4cloud` 的 `bootstrap.yml` 都是：

- `config` 配了 `namespace`
- `discovery` 没配 `namespace`

这意味着：

1. 配置读取会去 `nms4cloud` 命名空间
2. 服务实例注册会落到默认的 `public` 命名空间

### 6.2 实查结果

直接查 Nacos API 后得到：

#### `public` 命名空间中有实例

`nms4cloud-crm`：

- `172.18.0.6:18138`
- `172.19.16.1:18138`

`nms4cloud-pos4cloud`：

- `172.18.0.4:9722`
- `192.168.1.66:9722`
- `172.19.16.1:9722`

#### `nms4cloud` 命名空间中没有实例

`namespaceId=56a75109-dbdc-4c5a-8fc1-b2300cef7f4a` 下：

- `nms4cloud-crm.hosts=[]`
- `nms4cloud-pos4cloud.hosts=[]`

### 6.3 为什么会注册成这些地址

服务发现注册时，如果没有显式指定注册 IP，Spring Cloud Alibaba Nacos 会自动挑一个本机可用网卡地址。

本机网卡实查结果：

- `192.168.1.222`：Wi-Fi 局域网地址
- `172.19.16.1`：WSL / Hyper-V 虚拟网卡地址

因此本地启动的 `crm` 很可能被自动识别成：

```text
172.19.16.1
```

而不是开发者直觉中的 `192.168.1.222`。

至于 `172.18.0.6`，则明显来自 Docker 容器网络。

### 6.4 为什么会超时

`pos4cloud` 调用：

```text
nms4cloud-crm/crm_points_rule/listSync
```

不是直接访问某个固定 IP，而是：

1. 先向 Nacos 要 `nms4cloud-crm` 的实例列表
2. 再从实例池里选一个实例去调用

如果选中了不可达的容器地址：

```text
172.18.0.6:18138
```

就会超时。

下线该实例后恢复，证明故障点就在服务实例池，而不在接口实现。

---

## 七、为什么“我本地连到了 Nacos，却没注册成预期地址”

因为“连到 Nacos”包含两个不同阶段：

### 7.1 配置中心连接成功

服务可以从 Nacos 拉到：

- `nms4cloud-crm.yaml`
- `nms4cloud-shared.yaml`

这说明 `config` 成功。

### 7.2 服务发现注册成功，但注册地址不是预期的 Wi-Fi 地址

本地 `crm` 实际监听正常：

- `127.0.0.1:18138`
- `172.19.16.1:18138`
- `192.168.1.222:18138`

这些地址本机都能访问。

但 Nacos 里注册出来的是：

```text
172.19.16.1:18138
```

而不是：

```text
192.168.1.222:18138
```

这不是“没注册”，而是“注册到了错误网卡地址”。

---

## 八、短期处理建议

本次在不改代码、不改配置的前提下，最有效的处理方式是：

1. 到 Nacos `public` 命名空间
2. 找到 `nms4cloud-crm`
3. 下线不可达的容器实例 `172.18.0.6:18138`
4. 保留当前可达实例
5. 再次验证同步

这一步已经验证有效。

---

## 九、长期治理建议

### 9.1 隔离配置中心和注册中心命名空间

当前最大问题不是 Nacos 本身，而是：

- 配置读取走 `nms4cloud` 命名空间
- 服务注册却落到 `public`

这会导致本地、容器、测试环境实例混在一起。

### 9.2 隔离本地调试与容器环境实例池

至少要隔离一个维度：

1. `namespace`
2. `group`
3. 显式注册 IP

否则只要服务名相同，实例就会进入同一个服务池。

### 9.3 明确调试环境注册 IP

如果本地调试希望让其他机器访问，建议注册明确的局域网地址，而不是依赖自动网卡选择。

否则很容易注册成：

- Docker 网卡
- WSL 网卡
- Hyper-V 网卡
- VPN 网卡

---

## 十、本次排查结论汇总

1. `CrmPointsRule` 同步接口 `/crm_points_rule/listSync` 是专用同步接口。
2. 该接口应按商户 `mid` 维度同步，不应按 `sid` 缩小范围。
3. POS 本地 `crm_points_rule` 表缺失的原因是升级器被版本一致门禁跳过。
4. `pos4cloud -> crm` 调用超时的根因是 Nacos `public` 服务池里混入了不可达的 Docker 容器实例。
5. 本地服务不是没有注册，而是注册到了 `public`，且自动选成了虚拟网卡地址 `172.19.16.1`。
6. 本次问题本质上是“服务发现实例池污染”，不是业务同步代码本身的失败。

---

## 十一、最小闭环标准

这条链路真正稳定，需要同时满足：

1. `CrmPointsRule` 同步查询按 `mid` 执行
2. POS 本地 `crm_points_rule` 表已通过强制升级建出
3. `nms4cloud-crm` 在 Nacos 中只保留调用方可达实例
4. `pos4cloud` 调 `/crm_points_rule/listSync` 不再出现连接超时
5. `POST /sync/all` 后本地 `crm_points_rule` 有完整商户规则数据

