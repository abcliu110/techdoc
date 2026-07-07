package com.lowcode.metamodel.domain.schema;

/**
 * 发布任务状态。
 *
 * <p>M0 先固定状态语义，后续持久化状态机必须保持这些状态的含义兼容。
 */
public enum PublishTaskStatus {
  VALIDATING,
  PLANNING,
  LOCKED,
  RECONCILING,
  EXECUTING,
  SNAPSHOTTING,
  ACTIVATING,
  DONE,
  FAILED_AT,
  ABANDONED
}
