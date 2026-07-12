package com.lowcode.metamodel.domain.schema;

/**
 * 期望物理列定义。
 *
 * <p>这里只保存生成 DDL Plan 需要的最小信息，真实 information_schema 对账由后续执行层补齐。
 */
public record ColumnDefinition(String name, String typeName, Integer length, Integer precision, Integer scale, String sqlFragment) {}
