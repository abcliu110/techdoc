package com.lowcode.runtime.permission;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * M1 AccessView 合并服务。
 */
public class AccessViewService {

  /**
   * 合并多角色权限。字段权限采用显式拒绝优先，数据范围采用最小授权优先。
   */
  public AccessView merge(String objectCode, String metaHash, Long permVersion, PermissionRole... roles) {
    if (roles == null || roles.length == 0) {
      // 安全默认值：通用合并器不能把“无角色”解释为全量数据范围，避免后续调用方误用。
      return new AccessView(
          objectCode,
          Set.of(),
          Map.of(),
          DataScope.self(),
          Set.of(),
          metaHash,
          permVersion,
          new AccessExplain(false, List.of("角色为空，默认拒绝")));
    }

    Set<Operation> operations = EnumSet.noneOf(Operation.class);
    Set<String> actions = new java.util.HashSet<>();
    Map<String, FieldAccess> fields = new HashMap<>();
    List<String> reasons = new ArrayList<>();
    DataScope dataScope = DataScope.all();

    for (PermissionRole role : roles) {
      operations.addAll(role.operations());
      actions.addAll(role.actionCodes());
      if (role.dataScope().scope() == DataScopeType.SELF) {
        dataScope = role.dataScope();
      }
      role.fieldPermissions().forEach((field, access) -> {
        FieldAccess merged = mergeFieldAccess(fields.get(field), access);
        fields.put(field, merged);
        if (merged == FieldAccess.NONE) {
          reasons.add("字段 " + field + " 被显式拒绝");
        }
      });
    }

    if (reasons.isEmpty()) {
      reasons.add("角色权限合并通过");
    }
    return new AccessView(
        objectCode,
        Set.copyOf(operations),
        Map.copyOf(fields),
        dataScope,
        Set.copyOf(actions),
        metaHash,
        permVersion,
        new AccessExplain(true, List.copyOf(reasons)));
  }

  private static FieldAccess mergeFieldAccess(FieldAccess current, FieldAccess next) {
    if (current == FieldAccess.NONE || next == FieldAccess.NONE) {
      return FieldAccess.NONE;
    }
    if (current == FieldAccess.WRITE || next == FieldAccess.WRITE) {
      return FieldAccess.WRITE;
    }
    if (current == FieldAccess.READ || next == FieldAccess.READ) {
      return FieldAccess.READ;
    }
    return next == null ? current : next;
  }
}
