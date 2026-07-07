package com.lowcode.workflow.service;

import java.time.Instant;
import java.util.List;
import java.util.Map;

/**
 * Public workflow facade for the app HTTP layer.
 *
 * <p>It keeps the package-private runtime records inside the workflow module while exposing only
 * stable DTOs needed by HTTP adapters.
 */
public class WorkflowHttpService {

  private final WorkflowRuntimeService runtimeService = new WorkflowRuntimeService();

  public WorkflowHttpService() {
    runtimeService.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
  }

  public WorkflowStartResult start(WorkflowStartCommand command) {
    String instanceLid = runtimeService.start(
        command.tenantId(),
        command.workflowCode(),
        command.recordLid(),
        command.traceId(),
        command.startedBy(),
        true);
    return new WorkflowStartResult(instanceLid, command.workflowCode());
  }

  public WorkflowTaskResult createTask(String tenantId, String instanceLid, String nodeCode) {
    return toResult(runtimeService.createApprovalTask(tenantId, instanceLid, nodeCode));
  }

  public WorkflowTaskResult claimTask(String tenantId, String taskLid, String assigneeUser, String traceId) {
    return toResult(runtimeService.claimTask(tenantId, taskLid, assigneeUser, traceId));
  }

  public WorkflowTaskResult completeTask(String tenantId, String taskLid, String assigneeUser, String decision, String traceId) {
    return toResult(runtimeService.completeTask(tenantId, taskLid, assigneeUser, decision, traceId));
  }

  public WorkflowTimelineResult timeline(String tenantId, String instanceLid) {
    return new WorkflowTimelineResult(
        runtimeService.timeline(tenantId, instanceLid).stream()
            .map(event -> new WorkflowTimelineItem(event.eventType(), event.traceId(), event.detail()))
            .toList());
  }

  public WorkflowCompatibilityResult compatibility(String tenantId, String instanceLid, String workflowCode) {
    WorkflowCompatibilityReport report =
        runtimeService.compatibilityReport(tenantId, instanceLid, workflowCode);
    return new WorkflowCompatibilityResult(report.strategy(), report.risks());
  }

  public WorkflowFailureResult recordTimeout(
      String tenantId,
      String instanceLid,
      String nodeCode,
      Instant timeoutAt,
      int maxRetry) {
    runtimeService.recordNodeTimeout(tenantId, instanceLid, nodeCode, timeoutAt, maxRetry);
    return failureState(tenantId, instanceLid, nodeCode);
  }

  public WorkflowFailureResult markManualIntervention(
      String tenantId,
      String instanceLid,
      String nodeCode,
      String reason) {
    runtimeService.markManualIntervention(tenantId, instanceLid, nodeCode, reason);
    return failureState(tenantId, instanceLid, nodeCode);
  }

  public WorkflowFailureResult failureState(String tenantId, String instanceLid, String nodeCode) {
    WorkflowFailureState state = runtimeService.failureState(tenantId, instanceLid, nodeCode);
    return new WorkflowFailureResult(
        state.status().name(),
        state.retryCount(),
        state.lastReason(),
        state.manualSuggestion());
  }

  private WorkflowTaskResult toResult(WorkflowTask task) {
    return new WorkflowTaskResult(
        task.taskLid(),
        task.instanceLid(),
        task.nodeCode(),
        task.assigneeRole(),
        task.assigneeUser(),
        task.status().name(),
        task.decision());
  }

  public record WorkflowTimelineResult(List<WorkflowTimelineItem> events) {}

  public record WorkflowTimelineItem(String eventType, String traceId, String detail) {}

  public record WorkflowCompatibilityResult(String strategy, List<String> risks) {}

  public record WorkflowFailureEnvelope(WorkflowFailureResult state) {}

  public record WorkflowFailureResult(
      String status,
      int retryCount,
      String lastReason,
      String manualSuggestion) {}
}
