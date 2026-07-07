package com.lowcode.metamodel.domain.schema;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 发布状态机最小骨架。
 *
 * <p>当前实现只验证状态推进和 `taskNo` 幂等；DB 行锁、fencing token、resume/abandon 后续替换为持久化实现。
 */
public class PublishStateMachine {

  private final SchemaSyncExecutor executor;
  private final Map<String, PublishTask> tasks = new LinkedHashMap<>();

  public PublishStateMachine(SchemaSyncExecutor executor) {
    this.executor = executor;
  }

  public PublishTask submit(String taskNo, DdlPlan plan) {
    PublishTask existing = tasks.get(taskNo);
    if (existing != null) {
      return existing;
    }
    List<PublishTaskStatus> history = new ArrayList<>();
    enter(history, PublishTaskStatus.VALIDATING);
    enter(history, PublishTaskStatus.PLANNING);
    enter(history, PublishTaskStatus.LOCKED);
    enter(history, PublishTaskStatus.EXECUTING);
    DdlExecutionReport report = executor.execute(plan);
    String fencingToken = "fence-" + UUID.randomUUID();
    String traceId = "trace-" + UUID.randomUUID();
    PublishTaskStatus finalStatus;
    String errorCode = null;
    String recoveryHint = null;
    if (report.success()) {
      enter(history, PublishTaskStatus.SNAPSHOTTING);
      enter(history, PublishTaskStatus.ACTIVATING);
      enter(history, PublishTaskStatus.DONE);
      finalStatus = PublishTaskStatus.DONE;
    } else {
      enter(history, PublishTaskStatus.FAILED_AT);
      finalStatus = PublishTaskStatus.FAILED_AT;
      errorCode = failedErrorCode(report);
      recoveryHint = "从第 " + report.failedStepNo() + " 步失败点恢复前必须先运行 Reconciler 对账";
    }
    PublishTask task = new PublishTask(taskNo, finalStatus, history, report, plan, fencingToken, errorCode, traceId, recoveryHint, null);
    tasks.put(taskNo, task);
    return task;
  }

  public PublishTask resume(String taskNo, SchemaReconciler reconciler, SchemaSyncCommand command, SchemaSyncExecutor resumeExecutor) {
    PublishTask existing = tasks.get(taskNo);
    if (existing == null || existing.status() != PublishTaskStatus.FAILED_AT) {
      return existing;
    }
    List<PublishTaskStatus> history = new ArrayList<>(existing.history());
    enter(history, PublishTaskStatus.RECONCILING);
    ReconcileReport reconcileReport = reconciler.detect(command);
    enter(history, PublishTaskStatus.EXECUTING);
    DdlExecutionReport report = resumeExecutor.execute(existing.plan());
    PublishTaskStatus finalStatus = report.success() ? PublishTaskStatus.DONE : PublishTaskStatus.FAILED_AT;
    if (report.success()) {
      enter(history, PublishTaskStatus.SNAPSHOTTING);
      enter(history, PublishTaskStatus.ACTIVATING);
      enter(history, PublishTaskStatus.DONE);
    } else {
      enter(history, PublishTaskStatus.FAILED_AT);
    }
    PublishTask task =
        new PublishTask(
            taskNo,
            finalStatus,
            history,
            report,
            existing.plan(),
            "fence-" + UUID.randomUUID(),
            report.success() ? null : failedErrorCode(report),
            existing.traceId(),
            report.success() ? null : "恢复执行仍失败，请人工检查 DDL 日志和 Reconciler 报告",
            reconcileReport);
    tasks.put(taskNo, task);
    return task;
  }

  public PublishTask abandon(String taskNo, String reason) {
    PublishTask existing = tasks.get(taskNo);
    if (existing == null) {
      return null;
    }
    List<PublishTaskStatus> history = new ArrayList<>(existing.history());
    enter(history, PublishTaskStatus.ABANDONED);
    PublishTask task =
        new PublishTask(
            taskNo,
            PublishTaskStatus.ABANDONED,
            history,
            existing.executionReport(),
            existing.plan(),
            existing.fencingToken(),
            existing.errorCode(),
            existing.traceId(),
            reason,
            existing.reconcileReport());
    tasks.put(taskNo, task);
    return task;
  }

  public PublishTask continueWithToken(String taskNo, String fencingToken, PublishTaskStatus nextStatus) {
    PublishTask existing = tasks.get(taskNo);
    if (existing == null) {
      return null;
    }
    if (!existing.fencingToken().equals(fencingToken)) {
      List<PublishTaskStatus> history = new ArrayList<>(existing.history());
      enter(history, PublishTaskStatus.FAILED_AT);
      PublishTask task =
          new PublishTask(
              taskNo,
              PublishTaskStatus.FAILED_AT,
              history,
              existing.executionReport(),
              existing.plan(),
              existing.fencingToken(),
              "LC-META-PUBLISH-FENCING",
              existing.traceId(),
              "旧 fencing token 不得继续推进发布任务",
              existing.reconcileReport());
      tasks.put(taskNo, task);
      return task;
    }
    List<PublishTaskStatus> history = new ArrayList<>(existing.history());
    enter(history, nextStatus);
    PublishTask task =
        new PublishTask(
            taskNo,
            nextStatus,
            history,
            existing.executionReport(),
            existing.plan(),
            existing.fencingToken(),
            existing.errorCode(),
            existing.traceId(),
            existing.recoveryHint(),
            existing.reconcileReport());
    tasks.put(taskNo, task);
    return task;
  }

  private static void enter(List<PublishTaskStatus> history, PublishTaskStatus status) {
    history.add(status);
  }

  private static String failedErrorCode(DdlExecutionReport report) {
    return report.logs().stream()
        .filter(log -> log.stepNo() == report.failedStepNo())
        .map(DdlExecutionLog::errorCode)
        .filter(code -> code != null && !code.isBlank())
        .findFirst()
        .orElse("LC-META-PUBLISH-FAILED");
  }
}
