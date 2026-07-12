# ADR-LOWCODE-ID-001: 内部雪花 ID + 外部 ULID 逻辑 ID

> 状态：accepted
> 日期：2026-07-05

## 背景

平台同时需要数据库高性能主键、跨环境导入导出、API 外部引用、页面 schema 和插件稳定引用。单一自增或单一字符串 ID 不能同时满足这些约束。

## 决策

采用双 ID：

| 标识 | 类型 | 用途 |
|---|---|---|
| `id` | bigint，雪花 ID | 数据库内部主键、索引、事务更新 |
| `lid` | varchar(26)，ULID | 运行时业务记录跨环境/API/导入导出引用 |
| `code` | varchar(64) | 元模型对象、字段、动作、状态、插件等设计态编码 |

link 字段默认存目标记录 `lid`，列名为 `{field_code}_lid`。

## 理由

- 雪花 ID 是 bigint，MySQL 索引紧凑，适合内部主键。
- ULID 不依赖 workerId，适合跨环境迁移和外部引用。
- 元模型配置更适合人定义的稳定 code。

## 否决方案

- 只用雪花 ID：导入导出和跨环境引用容易断。
- 只用 ULID：MySQL 主键和索引成本更高。
- 自增 ID：分布式、多租户、导入导出不友好。

## 后果

- 所有动态业务表必须同时包含 `id` 和 `lid`。
- API、导入导出、页面 schema、插件不得长期引用数据库 `id`。
- 如维护 `{field_code}_id`，它只能作为可重建派生列。

## 验证

- T-002 `IdGeneratorTest` 验证雪花 ID 和 ULID。
- T-004 link 字段 DDL 必须生成 `{field_code}_lid varchar(26)`。

