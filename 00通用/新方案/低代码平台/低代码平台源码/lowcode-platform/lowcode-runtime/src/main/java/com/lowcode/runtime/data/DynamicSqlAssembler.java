package com.lowcode.runtime.data;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * 动态业务表 SQL 组装器。
 *
 * <p>动态 SQL 只允许在这个类中出现。表名、字段名、排序方向和过滤操作必须来自元数据白名单；
 * 请求值只能进入参数列表，不能拼进 SQL 文本。
 */
final class DynamicSqlAssembler {

  private static final Pattern IDENTIFIER = Pattern.compile("[a-z][a-z0-9_]{0,63}");

  private DynamicSqlAssembler() {
  }

  static String insertSql(DynamicObjectDefinition definition) {
    List<String> columns = systemAndBusinessColumns(definition);
    return "insert into " + table(definition)
        + " (" + String.join(", ", columns) + ") values ("
        + String.join(", ", java.util.Collections.nCopies(columns.size(), "?")) + ")";
  }

  static String listSql(
      DynamicObjectDefinition definition,
      List<Filter> filters,
      List<Sort> sorts,
      List<Object> parameters) {
    StringBuilder sql = new StringBuilder(selectPrefix(definition));
    sql.append(" where tenant_id = ? and workspace_id = ? and deleted = 0");
    for (Filter filter : filters) {
      appendFilter(definition, sql, parameters, filter);
    }
    appendOrderBy(definition, sorts, sql);
    sql.append(" limit ? offset ?");
    return sql.toString();
  }

  static String requireSql(DynamicObjectDefinition definition) {
    return selectPrefix(definition) + " where tenant_id = ? and workspace_id = ? and deleted = 0 and lid = ?";
  }

  static String updateSql(DynamicObjectDefinition definition, List<String> assignments) {
    assignments.add("state_code = ?");
    for (String field : definition.fields().keySet()) {
      assignments.add(field(definition, field) + " = ?");
    }
    assignments.add("revision = ?");
    return "update " + table(definition)
        + " set " + String.join(", ", assignments)
        + " where tenant_id = ? and workspace_id = ? and lid = ? and deleted = 0 and revision = ?";
  }

  static String softDeleteSql(DynamicObjectDefinition definition) {
    return "update " + table(definition)
        + " set deleted = 1, revision = revision + 1 where tenant_id = ? and workspace_id = ? and lid = ? and deleted = 0 and revision = ?";
  }

  static List<String> systemAndBusinessColumns(DynamicObjectDefinition definition) {
    List<String> columns = new ArrayList<>(List.of("tenant_id", "workspace_id", "lid", "revision", "deleted", "state_code"));
    definition.fields().keySet().forEach(field -> columns.add(field(definition, field)));
    return columns;
  }

  private static void appendFilter(
      DynamicObjectDefinition definition,
      StringBuilder sql,
      List<Object> parameters,
      Filter filter) {
    String column = field(definition, filter.field());
    Object value = definition.fields().get(filter.field()).convert(filter.value());
    switch (filterOp(filter.op())) {
      case "eq" -> {
        sql.append(" and ").append(column).append(" = ?");
        parameters.add(value);
      }
      case "gte" -> {
        sql.append(" and ").append(column).append(" >= ?");
        parameters.add(value);
      }
      case "lte" -> {
        sql.append(" and ").append(column).append(" <= ?");
        parameters.add(value);
      }
      case "contains" -> {
        sql.append(" and ").append(column).append(" like ?");
        parameters.add("%" + value + "%");
      }
      default -> throw new IllegalStateException("unreachable");
    }
  }

  private static void appendOrderBy(DynamicObjectDefinition definition, List<Sort> sorts, StringBuilder sql) {
    if (!sorts.isEmpty()) {
      List<String> orderBy = new ArrayList<>();
      for (Sort sort : sorts) {
        orderBy.add(field(definition, sort.field()) + " " + sortOrder(sort.order()));
      }
      sql.append(" order by ").append(String.join(", ", orderBy));
    } else {
      sql.append(" order by lid asc");
    }
  }

  private static String selectPrefix(DynamicObjectDefinition definition) {
    return "select " + String.join(", ", systemAndBusinessColumns(definition)) + " from " + table(definition);
  }

  private static String table(DynamicObjectDefinition definition) {
    return identifier(definition.tableName());
  }

  private static String field(DynamicObjectDefinition definition, String field) {
    if (!definition.fields().containsKey(field)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION, "字段不在元数据白名单内");
    }
    return identifier(field);
  }

  private static String identifier(String value) {
    if (value == null || !IDENTIFIER.matcher(value.toLowerCase(Locale.ROOT)).matches()) {
      throw new RuntimeDataException(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION, "SQL 标识符不在白名单内");
    }
    return value;
  }

  private static String filterOp(String op) {
    String normalized = op == null ? "" : op.toLowerCase(Locale.ROOT);
    if (List.of("eq", "gte", "lte", "contains").contains(normalized)) {
      return normalized;
    }
    throw new RuntimeDataException(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION, "查询操作不在白名单内");
  }

  private static String sortOrder(String order) {
    String normalized = order == null ? "" : order.toLowerCase(Locale.ROOT);
    if (List.of("asc", "desc").contains(normalized)) {
      return normalized;
    }
    throw new RuntimeDataException(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION, "排序方向不在白名单内");
  }
}
