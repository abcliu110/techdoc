package com.lowcode.runtime.data;

import java.util.List;
import java.util.Map;

/**
 * JDBC 执行器最小边界。
 *
 * <p>运行态仓储只负责生成白名单 SQL 与参数列表，具体执行可以由 Spring JDBC、MyBatis 或测试记录器承接。
 */
public interface RuntimeJdbcExecutor {

  int update(String sql, List<Object> parameters);

  List<Map<String, Object>> query(String sql, List<Object> parameters);
}
