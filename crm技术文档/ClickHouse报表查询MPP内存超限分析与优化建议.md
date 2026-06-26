# ClickHouse 报表查询 MPP 内存超限分析与优化建议

## 1. 背景

2026-06-05 09:52 到 09:55 左右，报表服务出现多条 ClickHouse 查询异常，核心错误如下：

```text
DB::Exception: Memory limit (total) exceeded
maximum: 14.40 GiB
While executing AggregatingTransform
While executing LibraSource
OvercommitTracker
```

该异常表示 ClickHouse 在执行查询时超过了当前内存限制。Java 层的 `UncategorizedSQLException`、MyBatis 栈信息只是对底层 ClickHouse 异常的包装，不是 MyBatis 本身导致的错误。

## 2. MPP 含义

MPP 通常指 Massively Parallel Processing，即大规模并行处理。

在本问题中，MPP 可以理解为 ClickHouse 的并行查询执行能力。ClickHouse 会把查询拆成多个执行阶段并行处理，例如读数据、聚合、排序、合并结果等。当多个大范围聚合查询同时执行时，会共同竞争查询内存池，最终触发内存超限。

## 3. 日志中的主要错误

### 3.1 筛选项查询失败

以下 SQL 在 `xiaofeidan` 明细表上执行单字段分组：

```sql
SELECT `canduan`
FROM `xiaofeidan`
WHERE yingyeriqi BETWEEN ? AND ?
  AND `company_id` = ?
GROUP BY `canduan`
```

```sql
SELECT `taiming`
FROM `xiaofeidan`
WHERE yingyeriqi BETWEEN ? AND ?
  AND `company_id` = ?
GROUP BY `taiming`
```

```sql
SELECT `stationname`
FROM `xiaofeidan`
WHERE yingyeriqi BETWEEN ? AND ?
  AND `company_id` = ?
GROUP BY `stationname`
```

对应接口包括：

- `JdBaseDataController.periods`
- `JdBaseDataController.tbls`
- `JdBaseDataController.stations`

这些查询在 ClickHouse 聚合阶段触发 `MEMORY_LIMIT_EXCEEDED`。

### 3.2 主报表查询失败

主报表 `BusinessSummaryForJd.execute` 查询如下模式：

```sql
SELECT
  `shop_id` AS `sid`,
  COUNT(*) AS `billNum`,
  SUM(`renshu`) AS `personNum`,
  SUM(`shipingfei`) AS `foodAmount`,
  SUM(`shishoujine`) AS `paidAmount`,
  ...
FROM `xiaofeidan`
WHERE yingyeriqi BETWEEN ? AND ?
  AND `company_id` = ?
GROUP BY `shop_id`, `yingyeriqi`
ORDER BY `shop_id` ASC, `yingyeriqi` ASC
LIMIT 0, 50
```

虽然带了 `LIMIT 0, 50`，但 ClickHouse 仍然必须先完成扫描、聚合和排序，分页不能减少聚合阶段的内存占用。

### 3.3 同时出现的高风险查询

日志中还出现了 `xiaofeicaiping` 上的筛选项查询：

```sql
SELECT `diancairen`
FROM `xiaofeicaiping`
WHERE yingyeriqi BETWEEN '2026-06-04 00:00:00' AND '2026-06-04 23:59:59'
  AND `company_id` = 1978646278361620480
GROUP BY `diancairen`
```

同类字段还包括：

- `dalei`
- `bumen`
- `xiaolei`

这些 SQL 在本段日志中没有直接报出内存超限，但它们与失败查询处于同一时间窗口，也会消耗 ClickHouse 查询内存。

## 4. 请求特征

日志中的请求参数具有以下特征：

```json
{
  "beginDate": "2026-06-04",
  "endDate": "2026-06-04",
  "mid": "1978646278361620480",
  "sids": [],
  "pageNo": "1",
  "pageSize": "50",
  "onlySummary": false
}
```

关键点：

- 日期范围为 1 天。
- `mid` 指定了商户。
- `sids` 为空，意味着没有门店范围过滤。
- 页面同时触发多个筛选项接口和主报表接口。
- 每个筛选项接口都会独立扫描明细表并执行 `GROUP BY`。

因此，即使单个查询看起来只是查一天数据，多条明细聚合查询并发执行时仍然可能打满 ClickHouse 内存。

## 5. 根因判断

| 排名 | 根因 | 置信度 |
| --- | --- | --- |
| 1 | 同一页面同时触发多个筛选项接口和报表主查询，多个大表聚合并发竞争 ClickHouse 内存 | 高 |
| 2 | `sids` 为空，查询范围扩大到整个商户所有门店 | 高 |
| 3 | 筛选项实时从 `xiaofeidan`、`xiaofeicaiping` 明细表 `GROUP BY`，没有复用缓存或预汇总结果 | 高 |
| 4 | 主报表直接查明细表聚合，`LIMIT` 只能限制返回行数，不能降低聚合内存 | 高 |
| 5 | 定时计算关闭可能导致部分接口没有走预汇总结果 | 中 |
| 6 | ClickHouse 表排序键、分区、Projection 或物化视图不足，导致扫描和聚合成本偏高 | 中，需要结合表结构确认 |

## 6. 为什么分页不能解决

当前主报表 SQL 的执行顺序可以简化理解为：

```text
WHERE 过滤 -> GROUP BY 聚合 -> ORDER BY 排序 -> LIMIT 分页
```

`LIMIT 0, 50` 位于执行链路后段。ClickHouse 在返回 50 行之前，已经完成了大范围扫描和聚合。因此分页只能减少网络返回和前端展示数据量，不能显著减少聚合内存。

## 7. 优化建议

### 7.1 立即止血措施

1. 限制空门店范围查询。

   对大商户，当 `sids` 为空时，不允许直接查询整个商户的明细报表；要求选择门店，或后端按门店拆批查询。

2. 限制页面并发。

   页面不要在进入报表时同时请求全部筛选项和主报表。筛选项应按需加载，或至少控制并发数量。

3. 增加接口级限流。

   对报表主查询和筛选项查询增加基于 `mid`、用户、接口维度的并发限制，避免单个商户或单个页面操作打满 ClickHouse。

4. 加缓存。

   对 `mid + 日期 + sids + 筛选项类型` 的筛选项结果缓存 1 到 5 分钟。筛选项一般变化不频繁，缓存收益明显。

5. 限制日期范围。

   明细报表同步查询应限制最大日期范围。超过范围时走异步导出或离线任务。

### 7.2 查询路径优化

1. 主报表优先走 DWS 日汇总表。

   `BusinessSummaryForJd` 这类按门店、日期汇总的报表，应优先查询 `dws_bill_by_day` 或等价日汇总表，不应每次从 `xiaofeidan` 明细表聚合。

2. 筛选项从维度快照或缓存表读取。

   以下筛选项不适合每次实时从明细表 `GROUP BY`：

   - 餐段
   - 台区
   - 房台
   - 设备
   - 收银员
   - 支付方式
   - 菜品大类
   - 菜品小类
   - 部门
   - 点菜人

   建议建立筛选项快照表，按以下维度存储：

   ```text
   company_id
   report_date
   shop_id
   dimension_type
   dimension_value
   ```

3. 避免多个字段各查一次明细表。

   当前模式是每个筛选项字段独立执行一次 `GROUP BY`。如果短期不能建快照表，可以考虑一次查询取多个低基数字段后在应用层拆分，但需评估返回数据量，不能把压力简单从 ClickHouse 转移到应用内存。

4. 对低基数字段可尝试 `DISTINCT`。

   例如：

   ```sql
   SELECT DISTINCT canduan
   FROM xiaofeidan
   WHERE ...
   ```

   但这只是小优化，不能从根本上解决大范围扫表问题。

### 7.3 ClickHouse 表结构与参数优化

1. 检查分区键。

   `xiaofeidan`、`xiaofeicaiping` 应能按营业日期有效裁剪分区，例如按月或按天分区。

2. 检查排序键。

   高频查询条件是：

   ```text
   company_id
   yingyeriqi
   shop_id
   ```

   排序键应尽量服务这些查询条件，例如：

   ```sql
   ORDER BY (company_id, yingyeriqi, shop_id)
   ```

   具体顺序需要结合现有表结构、查询模式和数据分布评估，不能直接在线重建。

3. 考虑 Projection 或物化视图。

   对固定聚合模式，可以建立 Projection 或物化视图，例如：

   - `company_id + yingyeriqi + shop_id` 的账单汇总
   - `company_id + yingyeriqi + shop_id + canduan`
   - `company_id + yingyeriqi + shop_id + taiming`
   - `company_id + yingyeriqi + shop_id + stationname`

4. 设置资源保护参数。

   可按用户、查询或会话控制资源：

   ```text
   max_memory_usage
   max_memory_usage_for_user
   max_threads
   max_bytes_before_external_group_by
   max_bytes_before_external_sort
   ```

   这些参数只能降低查询打爆集群的风险，不能代替查询路径优化。

## 8. 推荐落地顺序

1. 后端限制空 `sids` 的大范围明细查询。
2. 前端或网关控制筛选项并发，避免页面打开时同时打出十几个聚合请求。
3. 给筛选项接口加短 TTL 缓存。
4. `BusinessSummaryForJd` 优先改为查询 DWS 日汇总表。
5. 建筛选项维度快照表，替换实时 `GROUP BY xiaofeidan/xiaofeicaiping`。
6. 检查 ClickHouse 分区键、排序键、Projection、物化视图和资源参数。

## 9. 回滚与风险

### 9.1 回滚方案

- 接口限流、空 `sids` 限制、缓存可以通过配置开关控制。
- 主报表切换 DWS 查询路径时，应保留旧明细查询逻辑作为回退分支。
- 筛选项快照表上线初期建议与旧逻辑做并行校验，确认结果一致后再切换。

### 9.2 未覆盖风险

- 本文基于日志和代码调用链分析，未直接查看线上 ClickHouse 表结构、分区、排序键和实际数据量。
- 未确认定时计算关闭是否导致 DWS 汇总表不可用或数据延迟。
- 未确认前端是否存在重复请求、自动刷新或用户连续点击导致的额外并发。

## 10. 总结

本次问题不是单个 SQL 写法错误，而是报表页面在空门店范围下，同时触发多个 ClickHouse 明细表聚合查询，导致 ClickHouse 查询内存超过 14.40 GiB。

核心优化方向是：

```text
减少实时明细表 GROUP BY 次数
限制空 sids 的大范围查询
筛选项走缓存或快照
主报表走 DWS 日汇总
ClickHouse 侧补充分区、排序键、Projection 和资源保护
```
