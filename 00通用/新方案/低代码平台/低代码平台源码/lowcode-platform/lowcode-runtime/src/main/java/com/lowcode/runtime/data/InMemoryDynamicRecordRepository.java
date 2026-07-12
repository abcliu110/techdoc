package com.lowcode.runtime.data;

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 内存版动态记录仓储。
 *
 * <p>该实现用于单元测试和无数据库演示，保持原 M1 动态数据内核的历史行为。生产持久化路径应切到
 * {@link JdbcDynamicRecordRepository}，不要在内存实现上补生产特性。
 */
class InMemoryDynamicRecordRepository implements DynamicRecordRepository {

  private final Map<Long, Map<String, DynamicRecord>> recordsByTenant = new ConcurrentHashMap<>();

  @Override
  public void insert(DynamicObjectDefinition definition, RuntimeExecutionContext context, DynamicRecord record) {
    recordsByTenant.computeIfAbsent(context.tenantId(), ignored -> new LinkedHashMap<>()).put(record.lid(), record);
  }

  @Override
  public List<DynamicRecord> list(
      DynamicObjectDefinition definition,
      RuntimeExecutionContext context,
      List<Filter> filters,
      List<Sort> sorts,
      int pageNo,
      int pageSize) {
    return recordsByTenant.getOrDefault(context.tenantId(), Map.of()).values().stream()
        .filter(record -> !record.deleted())
        .filter(record -> matches(definition, record, filters))
        .sorted(sorter(sorts))
        .skip((long) (pageNo - 1) * pageSize)
        .limit(pageSize)
        .toList();
  }

  @Override
  public DynamicRecord require(DynamicObjectDefinition definition, RuntimeExecutionContext context, String recordLid) {
    DynamicRecord record = recordsByTenant.getOrDefault(context.tenantId(), Map.of()).get(recordLid);
    if (record == null || record.deleted()) {
      throw new RuntimeDataException(RuntimeDataErrorCode.RECORD_NOT_FOUND, "记录不存在");
    }
    return record;
  }

  @Override
  public void update(DynamicObjectDefinition definition, RuntimeExecutionContext context, DynamicRecord record) {
    recordsByTenant.getOrDefault(context.tenantId(), Map.of()).put(record.lid(), record);
  }

  @Override
  public void softDelete(DynamicObjectDefinition definition, RuntimeExecutionContext context, String recordLid, Long revision) {
    DynamicRecord record = require(definition, context, recordLid);
    if (!Objects.equals(record.revision(), revision)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.REVISION_CONFLICT, "记录版本冲突");
    }
    update(definition, context, new DynamicRecord(record.lid(), record.tenantId(), record.values(), record.stateCode(), record.revision() + 1, true));
  }

  private boolean matches(DynamicObjectDefinition definition, DynamicRecord record, List<Filter> filters) {
    for (Filter filter : filters) {
      Object current = record.values().get(filter.field());
      Object expected = definition.fields().get(filter.field()).convert(filter.value());
      if (!matches(filter.op(), current, expected)) {
        return false;
      }
    }
    return true;
  }

  private Comparator<DynamicRecord> sorter(List<Sort> sorts) {
    if (sorts.isEmpty()) {
      return Comparator.comparing(DynamicRecord::lid);
    }
    Comparator<DynamicRecord> comparator = null;
    for (Sort sort : sorts) {
      Comparator<DynamicRecord> next = (left, right) -> compare(left.values().get(sort.field()), right.values().get(sort.field()));
      if ("desc".equals(sortOrder(sort.order()))) {
        next = next.reversed();
      }
      comparator = comparator == null ? next : comparator.thenComparing(next);
    }
    return comparator;
  }

  private boolean matches(String op, Object current, Object expected) {
    return switch (filterOp(op)) {
      case "eq" -> Objects.equals(current, expected);
      case "gte" -> compare(current, expected) >= 0;
      case "lte" -> compare(current, expected) <= 0;
      case "contains" -> current != null && String.valueOf(current).contains(String.valueOf(expected));
      default -> throw new IllegalStateException("unreachable");
    };
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  private int compare(Object current, Object expected) {
    if (current instanceof Comparable comparable && expected != null) {
      return comparable.compareTo(expected);
    }
    return String.valueOf(current).compareTo(String.valueOf(expected));
  }

  private String filterOp(String op) {
    String normalized = op == null ? "" : op.toLowerCase(Locale.ROOT);
    if (List.of("eq", "gte", "lte", "contains").contains(normalized)) {
      return normalized;
    }
    throw new RuntimeDataException(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION, "查询操作不在白名单内");
  }

  private String sortOrder(String order) {
    String normalized = order == null ? "" : order.toLowerCase(Locale.ROOT);
    if (List.of("asc", "desc").contains(normalized)) {
      return normalized;
    }
    throw new RuntimeDataException(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION, "排序方向不在白名单内");
  }
}
