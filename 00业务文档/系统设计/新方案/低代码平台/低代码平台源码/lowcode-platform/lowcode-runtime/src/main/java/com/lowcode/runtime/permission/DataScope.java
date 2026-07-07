package com.lowcode.runtime.permission;

/**
 * 数据范围 AST 的最小承载。
 */
public record DataScope(DataScopeType scope, String ast) {

  public static DataScope self() {
    return new DataScope(DataScopeType.SELF, "owner_user_lid = $user");
  }

  public static DataScope all() {
    return new DataScope(DataScopeType.ALL, "tenant_id = $tenant");
  }
}
