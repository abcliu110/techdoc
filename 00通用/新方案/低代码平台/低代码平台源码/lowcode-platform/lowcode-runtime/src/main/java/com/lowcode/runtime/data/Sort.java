package com.lowcode.runtime.data;

/**
 * 动态查询排序条件。
 */
public record Sort(String field, String order) {

  public static Sort asc(String field) {
    return new Sort(field, "asc");
  }

  public static Sort desc(String field) {
    return new Sort(field, "desc");
  }
}
