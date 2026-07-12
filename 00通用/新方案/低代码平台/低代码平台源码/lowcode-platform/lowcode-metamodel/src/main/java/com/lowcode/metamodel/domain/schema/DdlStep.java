package com.lowcode.metamodel.domain.schema;

/**
 * DDL 计划步骤。
 *
 * <p>`executable=false` 表示必须阻断发布，不能被执行层静默跳过。
 */
public record DdlStep(
    int stepNo,
    DdlType type,
    String objectCode,
    String tableName,
    String columnName,
    String sql,
    boolean executable) {}
