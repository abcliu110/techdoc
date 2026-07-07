package com.lowcode.metamodel.domain.schema;

/**
 * 物理列登记快照。
 *
 * <p>M0 计划层只使用登记表等价信息，不直接依赖 information_schema。
 */
public record PhysicalColumn(String name, String typeName, Integer length, Integer precision, Integer scale) {}
