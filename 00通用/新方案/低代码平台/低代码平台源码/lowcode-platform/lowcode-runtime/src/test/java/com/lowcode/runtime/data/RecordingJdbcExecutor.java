package com.lowcode.runtime.data;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 测试用 JDBC 记录器。
 *
 * <p>它不连接真实数据库，只记录 SQL 和参数，专门验证动态 SQL 是否经过白名单和参数化边界。
 */
class RecordingJdbcExecutor implements RuntimeJdbcExecutor {

  private final List<String> sqlHistory = new ArrayList<>();
  private final List<List<Object>> parametersHistory = new ArrayList<>();
  private List<Map<String, Object>> nextQueryRows;

  @Override
  public int update(String sql, List<Object> parameters) {
    sqlHistory.add(sql);
    parametersHistory.add(List.copyOf(parameters));
    return 1;
  }

  @Override
  public List<Map<String, Object>> query(String sql, List<Object> parameters) {
    sqlHistory.add(sql);
    parametersHistory.add(List.copyOf(parameters));
    if (nextQueryRows != null) {
      List<Map<String, Object>> rows = nextQueryRows;
      nextQueryRows = null;
      return rows;
    }
    if (sql.contains(" from lc_rt_idempotency ")) {
      return List.of();
    }
    Map<String, Object> row = new LinkedHashMap<>();
    row.put("tenant_id", 1L);
    row.put("lid", "01ABCDEFGHABCDEFGHABCDEFGH");
    row.put("revision", 1L);
    row.put("deleted", 0);
    row.put("state_code", "draft");
    row.put("amount", new BigDecimal("12.30"));
    row.put("remark", "first");
    return List.of(row);
  }

  void nextQueryRows(List<Map<String, Object>> rows) {
    this.nextQueryRows = rows;
  }

  List<String> sqlHistory() {
    return List.copyOf(sqlHistory);
  }

  List<List<Object>> parametersHistory() {
    return List.copyOf(parametersHistory);
  }
}
