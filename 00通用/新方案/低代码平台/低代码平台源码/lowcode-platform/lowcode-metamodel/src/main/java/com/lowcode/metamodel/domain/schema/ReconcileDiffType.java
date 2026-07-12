package com.lowcode.metamodel.domain.schema;

/**
 * Reconciler 差异类型。
 */
public enum ReconcileDiffType {
  MISSING_TABLE,
  MISSING_COLUMN,
  EXTRA_COLUMN,
  TYPE_NARROWED,
  TYPE_WIDENED,
  TYPE_CHANGED,
  COLLATION_CHANGED,
  REGISTRY_DRIFT
}
