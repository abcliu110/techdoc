package com.lowcode.metamodel.domain.schema;

import java.util.List;

/**
 * DDL 执行报告。
 */
public record DdlExecutionReport(boolean success, int failedStepNo, List<DdlExecutionLog> logs) {

  public DdlExecutionReport {
    logs = List.copyOf(logs);
  }
}
