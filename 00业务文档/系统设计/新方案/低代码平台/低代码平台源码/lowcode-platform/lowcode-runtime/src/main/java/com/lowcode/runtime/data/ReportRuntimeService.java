package com.lowcode.runtime.data;

import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 报表运行时服务。
 *
 * <p>首版仅覆盖字段权限裁剪后的聚合和导出数据集，不暴露底层表名等内部细节。
 */
public class ReportRuntimeService {

  public ReportAggregateResult aggregate(
      InMemoryDynamicDataService service,
      RuntimeExecutionContext context,
      AccessView accessView,
      ListRecordCommand command,
      java.util.Set<String> sumFields) {
    requireRead(accessView);
    List<Map<String, Object>> rows = service.list(context, accessView, command);
    Map<String, BigDecimal> sums = new LinkedHashMap<>();
    for (String field : sumFields) {
      if (accessView.fieldAccess(field) != FieldAccess.NONE) {
        BigDecimal total = BigDecimal.ZERO;
        for (Map<String, Object> row : rows) {
          Object value = row.get(field);
          if (value instanceof BigDecimal decimal) {
            total = total.add(decimal);
          }
        }
        sums.put(field, total);
      }
    }
    return new ReportAggregateResult(rows.size(), sums);
  }

  public ReportDataset export(
      InMemoryDynamicDataService service,
      RuntimeExecutionContext context,
      AccessView accessView,
      ListRecordCommand command) {
    requireRead(accessView);
    if (!accessView.can(Operation.EXPORT)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "无权限导出报表");
    }
    List<Map<String, Object>> rows = service.list(context, accessView, command).stream()
        .map(this::escapeCsvFormula)
        .toList();
    return new ReportDataset(rows);
  }

  private Map<String, Object> escapeCsvFormula(Map<String, Object> row) {
    Map<String, Object> escaped = new LinkedHashMap<>();
    row.forEach((key, value) -> {
      if (value instanceof String stringValue && isFormulaCandidate(stringValue)) {
        escaped.put(key, "'" + stringValue);
      } else {
        escaped.put(key, value);
      }
    });
    return escaped;
  }

  private boolean isFormulaCandidate(String value) {
    return !value.isEmpty() && "=+-@".indexOf(value.charAt(0)) >= 0;
  }

  private void requireRead(AccessView accessView) {
    if (!accessView.can(Operation.READ)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "无权限读取报表数据");
    }
  }
}

record ReportAggregateResult(int rowCount, Map<String, BigDecimal> sums) {

  ReportAggregateResult {
    sums = Map.copyOf(sums);
  }
}

record ReportDataset(List<Map<String, Object>> rows) {

  ReportDataset {
    rows = List.copyOf(rows);
  }
}
