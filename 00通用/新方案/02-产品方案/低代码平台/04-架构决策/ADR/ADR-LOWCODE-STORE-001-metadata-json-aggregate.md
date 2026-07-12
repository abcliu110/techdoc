# ADR-LOWCODE-STORE-001: 元数据少表 + JSON 聚合

> 状态：accepted for M0
> 日期：2026-07-05

## 背景

元数据是读多写少、整体加载的数据。业务对象的字段、关系、状态、动作、规则强内聚，运行态通过 MetaGraph 全量加载，而不是频繁按字段行查询。

## 决策

元数据使用 9 张 `lc_meta_*` 表，子定义进入 JSON 聚合列：

- `lc_meta_tenant`
- `lc_meta_workspace`
- `lc_meta_app`
- `lc_meta_object`
- `lc_meta_page`
- `lc_meta_role`
- `lc_meta_datasource`
- `lc_meta_version`
- `lc_meta_plugin`

交叉引用通过可重建的 `lc_meta_ref` 索引表维护。

## 理由

- 减少元模型演进时的 DDL 变更。
- 对象定义天然是文档式聚合。
- 运行态热路径使用 MetaGraph，不依赖 SQL JOIN。

## 否决方案

- 字段、动作、状态、规则全部拆表：JOIN 多、保存事务复杂、演进成本高。
- 元数据完全存单个 JSON 大表：列表查询、唯一约束、权限和版本管理困难。

## 后果

- JSON DTO 必须有 `_v` 和 JsonUpgrader。
- 不允许业务 SQL 使用 `JSON_EXTRACT` 查询 JSON 内部字段。
- 需要 `lc_meta_ref` 支撑影响分析和引用完整性。

## 验证

- T-002 建表和 JSON DTO 序列化测试。
- T-003 引用索引重建。
- T-005 snapshot 加载兼容测试。

