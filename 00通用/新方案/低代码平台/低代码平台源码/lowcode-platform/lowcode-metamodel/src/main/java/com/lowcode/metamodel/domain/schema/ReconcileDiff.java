package com.lowcode.metamodel.domain.schema;

/**
 * Reconciler 差异项。
 */
public record ReconcileDiff(ReconcileDiffType type, String tableName, String columnName, String message) {}
