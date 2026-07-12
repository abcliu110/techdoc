# ADR-LOWCODE-FIELDTYPE-SPI-001: 字段类型处理器 SPI

> 状态：accepted for M0
> 日期：2026-07-06

## Context

低代码平台首版有 22 种 `field_type`。字段类型行为会同时影响元模型校验、DDL 映射、API 输入转换、查询能力、前端渲染和插件扩展。如果这些行为散落在多个 `switch(field_type)` 中，新增第 23 种字段类型时需要同步修改多处核心代码，极易造成 DDL、运行时和前端语义漂移。

## Decision

引入 `FieldTypeHandler` SPI。每个字段类型必须由一个处理器声明完整能力：

```text
FieldTypeHandler:
  typeCode()
  ddlMapping(FieldDef) -> ColumnSpec
  compare(FieldDef, PhysicalColumn) -> ColumnCompatibility
  convert(ApiValue, FieldDef) -> ConvertedValue
  validateOptions(FieldDef) -> ValidationResult
  queryCapability() -> filter/sort/aggregate capability
  rendererKey()
  capabilities()
```

核心引擎只依赖处理器注册表，不直接散落字段类型分支。M0 可以先实现内置 22 种处理器，不开放第三方插件注册；但接口形态必须稳定，后续 M3 插件字段类型扩展沿用同一 SPI。

## Consequences

- T-003 元模型校验通过 `FieldTypeHandler.validateOptions` 判断字段配置合法性。
- T-004 Schema Sync 通过 `FieldTypeHandler.ddlMapping` 和 `compare` 生成 DDL Plan。
- 规范 23 的字段类型真值表必须逐步迁移为处理器契约测试资产。
- `multilink`、`formula.persisted=true` 等 M0 不支持能力由处理器返回阻断能力，不由 Schema Sync 硬编码判断。
- 禁止业务代码直接新增 `switch(field_type)`；确需分支时必须说明为什么不能放入 SPI。

## Rejected

Rejected: 继续使用集中式 `FieldColumnMapper` + 多处 switch | 短期简单，但类型语义会在转换、DDL、前端和查询层漂移。

Rejected: M0 直接开放第三方字段类型插件 | 插件隔离、兼容矩阵和安全评审尚未完成，M0 只冻结 SPI 形状。

## Verification

- 22 种内置字段类型均有处理器注册测试。
- 每种字段类型至少有 options 校验、DDL 映射、非法输入拒绝、NULL/空串语义测试。
- ArchUnit 或静态扫描禁止运行时核心散落 `switch(field_type)`。
