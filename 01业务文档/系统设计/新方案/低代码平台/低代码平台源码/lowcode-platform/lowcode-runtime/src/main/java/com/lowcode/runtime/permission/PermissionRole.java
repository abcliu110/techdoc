package com.lowcode.runtime.permission;

import java.util.Map;
import java.util.Set;

/**
 * 单角色权限定义。
 */
public record PermissionRole(
    String roleCode,
    Set<Operation> operations,
    DataScope dataScope,
    Map<String, FieldAccess> fieldPermissions,
    Set<String> actionCodes) {}
