package com.lowcode.metamodel.domain.schema;

import java.util.List;

/**
 * 发布任务内存快照。
 */
public record PublishTask(
    String taskNo,
    PublishTaskStatus status,
    List<PublishTaskStatus> history,
    DdlExecutionReport executionReport,
    DdlPlan plan,
    String fencingToken,
    String errorCode,
    String traceId,
    String recoveryHint,
    ReconcileReport reconcileReport) {

  public PublishTask {
    history = List.copyOf(history);
  }

  public PublishTask(String taskNo, PublishTaskStatus status, List<PublishTaskStatus> history, DdlExecutionReport executionReport) {
    this(taskNo, status, history, executionReport, null, null, null, null, null, null);
  }
}
