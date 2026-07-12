package com.lowcode.metamodel.domain.graph;

import java.util.List;
import java.util.Map;

/**
 * Minimal JDBC boundary for published metamodel reads.
 */
public interface MetaJdbcExecutor {

  List<Map<String, Object>> query(String sql, List<Object> parameters);
}
