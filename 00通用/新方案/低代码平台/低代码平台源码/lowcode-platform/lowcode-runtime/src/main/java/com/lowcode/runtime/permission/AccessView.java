package com.lowcode.runtime.permission;

import java.util.Map;
import java.util.Set;

/**
 * 运行态统一权限视图。
 *
 * <p>动态数据 API、状态动作、suggest、导入导出只能消费这个不可变结果，不能重新组合权限。
 */
public record AccessView(
    String objectCode,
    Set<Operation> operations,
    Map<String, FieldAccess> fieldView,
    DataScope dataScope,
    Set<String> actionSet,
    String metaHash,
    Long permVersion,
    AccessExplain explain) {

  public boolean can(Operation operation) {
    return operations.contains(operation);
  }

  public FieldAccess fieldAccess(String fieldCode) {
    return fieldView.getOrDefault(fieldCode, FieldAccess.NONE);
  }
}
