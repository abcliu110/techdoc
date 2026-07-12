package com.lowcode.runtime.data;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * JDBC/MySQL 动态记录仓储。
 *
 * <p>SECURITY: SQL 中出现的表名和列名只允许来自已发布元数据，并且必须通过标识符白名单校验；请求输入只能进入参数列表。
 * 所有读写固定注入 {@code tenant_id = ?} 与 {@code deleted = 0}，防止跨租户读取和软删除数据回流。
 */
public class JdbcDynamicRecordRepository implements DynamicRecordRepository {

  private final RuntimeJdbcExecutor executor;

  public JdbcDynamicRecordRepository(RuntimeJdbcExecutor executor) {
    this.executor = executor;
  }

  RuntimeJdbcExecutor executor() {
    return executor;
  }

  @Override
  public void insert(DynamicObjectDefinition definition, RuntimeExecutionContext context, DynamicRecord record) {
    requireTenantAndWorkspace(context);
    List<Object> parameters = new ArrayList<>();
    parameters.add(context.tenantId());
    parameters.add(context.workspaceId());
    parameters.add(record.lid());
    parameters.add(record.revision());
    parameters.add(record.deleted() ? 1 : 0);
    parameters.add(record.stateCode());
    definition.fields().keySet().forEach(field -> parameters.add(record.values().get(field)));

    executor.update(DynamicSqlAssembler.insertSql(definition), parameters);
  }

  @Override
  public List<DynamicRecord> list(
      DynamicObjectDefinition definition,
      RuntimeExecutionContext context,
      List<Filter> filters,
      List<Sort> sorts,
      int pageNo,
      int pageSize) {
    requireTenantAndWorkspace(context);
    List<Object> parameters = new ArrayList<>();
    parameters.add(context.tenantId());
    parameters.add(context.workspaceId());

    int safePageSize = Math.max(1, Math.min(pageSize, 200));
    int safePageNo = Math.max(1, pageNo);
    String sql = DynamicSqlAssembler.listSql(definition, filters, sorts, parameters);
    parameters.add(safePageSize);
    parameters.add((safePageNo - 1) * safePageSize);

    return executor.query(sql, parameters).stream()
        .map(row -> toRecord(definition, row))
        .toList();
  }

  @Override
  public DynamicRecord require(DynamicObjectDefinition definition, RuntimeExecutionContext context, String recordLid) {
    requireTenantAndWorkspace(context);
    List<DynamicRecord> rows = executor.query(
            DynamicSqlAssembler.requireSql(definition),
            List.of(context.tenantId(), context.workspaceId(), recordLid)).stream()
        .map(row -> toRecord(definition, row))
        .toList();
    if (rows.isEmpty()) {
      throw new RuntimeDataException(RuntimeDataErrorCode.RECORD_NOT_FOUND, "记录不存在");
    }
    return rows.getFirst();
  }

  @Override
  public void update(DynamicObjectDefinition definition, RuntimeExecutionContext context, DynamicRecord record) {
    requireTenantAndWorkspace(context);
    List<String> assignments = new ArrayList<>();
    List<Object> parameters = new ArrayList<>();
    parameters.add(record.stateCode());
    for (String field : definition.fields().keySet()) {
      parameters.add(record.values().get(field));
    }
    parameters.add(record.revision());
    parameters.add(context.tenantId());
    parameters.add(context.workspaceId());
    parameters.add(record.lid());
    parameters.add(record.revision() - 1);

    int updated = executor.update(DynamicSqlAssembler.updateSql(definition, assignments), parameters);
    if (updated == 0) {
      throw new RuntimeDataException(RuntimeDataErrorCode.REVISION_CONFLICT, "记录版本冲突");
    }
  }

  @Override
  public void softDelete(DynamicObjectDefinition definition, RuntimeExecutionContext context, String recordLid, Long revision) {
    requireTenantAndWorkspace(context);
    int updated = executor.update(
        DynamicSqlAssembler.softDeleteSql(definition),
        List.of(context.tenantId(), context.workspaceId(), recordLid, revision));
    if (updated == 0) {
      throw new RuntimeDataException(RuntimeDataErrorCode.REVISION_CONFLICT, "记录版本冲突");
    }
  }

  private DynamicRecord toRecord(DynamicObjectDefinition definition, Map<String, Object> row) {
    Map<String, Object> values = new LinkedHashMap<>();
    definition.fields().keySet().forEach(field -> values.put(field, row.get(field)));
    return new DynamicRecord(
        String.valueOf(row.get("lid")),
        toLong(row.get("tenant_id")),
        values,
        row.get("state_code") == null ? null : String.valueOf(row.get("state_code")),
        toLong(row.get("revision")),
        toBoolean(row.get("deleted")));
  }

  private void requireTenantAndWorkspace(RuntimeExecutionContext context) {
    if (context.tenantId() == null) {
      throw new RuntimeDataException(RuntimeDataErrorCode.TENANT_REQUIRED, "租户不能为空");
    }
    if (context.workspaceId() == null) {
      throw new RuntimeDataException(RuntimeDataErrorCode.TENANT_REQUIRED, "工作区不能为空");
    }
  }

  private Long toLong(Object value) {
    if (value instanceof Number number) {
      return number.longValue();
    }
    return Long.valueOf(String.valueOf(value));
  }

  private boolean toBoolean(Object value) {
    if (value instanceof Boolean bool) {
      return bool;
    }
    if (value instanceof Number number) {
      return number.intValue() != 0;
    }
    return Boolean.parseBoolean(String.valueOf(value));
  }
}
