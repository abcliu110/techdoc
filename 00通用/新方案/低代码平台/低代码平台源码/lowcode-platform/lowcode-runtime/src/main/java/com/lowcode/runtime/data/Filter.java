package com.lowcode.runtime.data;

/**
 * 动态查询过滤条件。
 */
public record Filter(String field, String op, Object value) {

  public static Filter eq(String field, Object value) {
    return new Filter(field, "eq", value);
  }

  public static Filter gte(String field, Object value) {
    return new Filter(field, "gte", value);
  }

  public static Filter lte(String field, Object value) {
    return new Filter(field, "lte", value);
  }

  public static Filter contains(String field, Object value) {
    return new Filter(field, "contains", value);
  }
}
