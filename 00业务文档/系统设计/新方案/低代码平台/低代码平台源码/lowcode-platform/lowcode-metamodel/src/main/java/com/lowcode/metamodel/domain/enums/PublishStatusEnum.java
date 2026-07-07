package com.lowcode.metamodel.domain.enums;

/**
 * 持久化发布任务状态机 code。
 *
 * <p>这些名称会存入 `lc_meta_publish_task`；修改 code 会破坏恢复和审计。
 */
public enum PublishStatusEnum implements CodeEnum {
  VALIDATING("validating"),
  PLANNING("planning"),
  LOCKED("locked"),
  EXECUTING("executing"),
  SNAPSHOTTING("snapshotting"),
  ACTIVATING("activating"),
  DONE("done"),
  FAILED_AT("failed_at"),
  ABANDONED("abandoned");

  private final String code;

  PublishStatusEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
