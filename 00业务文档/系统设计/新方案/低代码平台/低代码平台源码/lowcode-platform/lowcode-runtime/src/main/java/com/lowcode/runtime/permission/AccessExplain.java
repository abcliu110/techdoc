package com.lowcode.runtime.permission;

import java.util.List;

/**
 * 权限解释结果。
 */
public record AccessExplain(boolean allowed, List<String> reasons) {

  public static AccessExplain allow(String reason) {
    return new AccessExplain(true, List.of(reason));
  }
}
