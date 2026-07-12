package com.lowcode.workflow.service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * M4/M5 工作流运行时最小商用内核。
 *
 * <p>它补齐定义版本冻结、任务并发认领、失败恢复、人工介入和实例时间线语义。
 */
public class WorkflowRuntimeService {

  private final WorkflowRepository repository;

  public WorkflowRuntimeService() {
    this(new InMemoryWorkflowRepository());
  }

  public WorkflowRuntimeService(WorkflowRepository repository) {
    this.repository = repository;
  }

  public void publish(WorkflowDefinition definition) {
    repository.latestDefinitions().put(definition.code(), definition);
    repository.definitionsByVersion()
        .computeIfAbsent(definition.code(), ignored -> new LinkedHashMap<>())
        .put(definition.version(), definition);
  }

  public String start(String workflowCode, String recordLid, String traceId) {
    return start("global", workflowCode, recordLid, traceId, "system", true);
  }

  public String start(String tenantId, String workflowCode, String recordLid, String traceId, String startedBy, boolean hasPermission) {
    if (!hasPermission) {
      throw new IllegalArgumentException("无权限启动流程");
    }
    WorkflowDefinition definition = repository.latestDefinitions().get(workflowCode);
    if (definition == null) {
      throw new IllegalArgumentException("工作流定义不存在");
    }
    String idemKey = tenantId + "|" + workflowCode + "|" + recordLid + "|" + traceId;
    String replay = repository.startIdempotency().get(idemKey);
    if (replay != null) {
      return replay;
    }
    String lid = "wf-" + UUID.randomUUID();
    WorkflowInstance instance = new WorkflowInstance(
        lid,
        tenantId,
        workflowCode,
        definition.version(),
        recordLid,
        traceId,
        false,
        startedBy,
        definition.schemaVersion(),
        definition.schemaVersion(),
        definition.schemaVersion(),
        definition);
    tenantInstances(tenantId).put(lid, instance);
    repository.startIdempotency().put(idemKey, lid);
    appendTimeline(tenantId, lid, "INSTANCE_STARTED", traceId, "workflow started");
    return lid;
  }

  public WorkflowTask createApprovalTask(String instanceLid, String nodeCode) {
    return createApprovalTask("global", instanceLid, nodeCode);
  }

  public WorkflowTask createApprovalTask(String tenantId, String instanceLid, String nodeCode) {
    WorkflowInstance instance = instance(tenantId, instanceLid);
    WorkflowDefinition definition = definition(instance);
    WorkflowTask task = new WorkflowTask(
        "task-" + UUID.randomUUID(),
        instanceLid,
        nodeCode,
        definition.nodeRoleMap().get(nodeCode),
        null,
        WorkflowTaskStatus.CREATED,
        null,
        tenantId);
    tenantTasks(tenantId).put(task.taskLid(), task);
    appendTimeline(tenantId, instanceLid, "TASK_CREATED", instance.traceId(), nodeCode);
    return task;
  }

  public WorkflowTask claimTask(String taskLid, String assigneeUser) {
    return claimTask("global", taskLid, assigneeUser, "trace-claim");
  }

  public WorkflowTask claimTask(String tenantId, String taskLid, String assigneeUser, String traceId) {
    WorkflowTask task = task(tenantId, taskLid);
    if (task.status() != WorkflowTaskStatus.CREATED) {
      throw new IllegalStateException("审批任务已被认领");
    }
    WorkflowTask claimed = new WorkflowTask(
        task.taskLid(),
        task.instanceLid(),
        task.nodeCode(),
        task.assigneeRole(),
        assigneeUser,
        WorkflowTaskStatus.CLAIMED,
        null,
        tenantId);
    tenantTasks(tenantId).put(taskLid, claimed);
    repository.metricEvents().add(new WorkflowMetricEvent("workflow.task_claimed", task.instanceLid(), task.nodeCode(), assigneeUser));
    appendTimeline(tenantId, task.instanceLid(), "TASK_CLAIMED", traceId, assigneeUser);
    return claimed;
  }

  public WorkflowTask completeTask(String taskLid, String assigneeUser, String decision) {
    return completeTask("global", taskLid, assigneeUser, decision, "trace-complete");
  }

  public WorkflowTask completeTask(String tenantId, String taskLid, String assigneeUser, String decision, String traceId) {
    WorkflowTask task = task(tenantId, taskLid);
    if (!assigneeUser.equals(task.assigneeUser())) {
      throw new IllegalArgumentException("审批任务未由当前用户认领");
    }
    WorkflowTask completed = new WorkflowTask(
        task.taskLid(),
        task.instanceLid(),
        task.nodeCode(),
        task.assigneeRole(),
        assigneeUser,
        WorkflowTaskStatus.COMPLETED,
        decision,
        tenantId);
    tenantTasks(tenantId).put(taskLid, completed);
    repository.metricEvents().add(new WorkflowMetricEvent("workflow.task_completed", task.instanceLid(), task.nodeCode(), decision));
    appendTimeline(tenantId, task.instanceLid(), "TASK_COMPLETED", traceId, decision);
    return completed;
  }

  public int retryNode(String instanceLid, String nodeCode, String reason) {
    return retryNode("global", instanceLid, nodeCode, reason);
  }

  public int retryNode(String tenantId, String instanceLid, String nodeCode, String reason) {
    instance(tenantId, instanceLid);
    String key = nodeRetryKey(tenantId, instanceLid, nodeCode);
    int retryCount = repository.nodeRetryCounts().getOrDefault(key, 0) + 1;
    repository.nodeRetryCounts().put(key, retryCount);
    WorkflowFailureState state = failureStateOrDefault(tenantId, instanceLid, nodeCode).incrementRetry(reason);
    tenantFailures(tenantId).put(failureKey(instanceLid, nodeCode), state);
    repository.metricEvents().add(new WorkflowMetricEvent("workflow.node_retry", instanceLid, nodeCode, reason));
    appendTimeline(tenantId, instanceLid, "NODE_RETRIED", currentTraceId(tenantId, instanceLid), reason);
    return retryCount;
  }

  public int nodeRetryCount(String instanceLid, String nodeCode) {
    return nodeRetryCount("global", instanceLid, nodeCode);
  }

  public int nodeRetryCount(String tenantId, String instanceLid, String nodeCode) {
    return repository.nodeRetryCounts().getOrDefault(nodeRetryKey(tenantId, instanceLid, nodeCode), 0);
  }

  public void failNode(String instanceLid, String nodeCode, String reason) {
    failNode("global", instanceLid, nodeCode, reason);
  }

  public void failNode(String tenantId, String instanceLid, String nodeCode, String reason) {
    WorkflowInstance instance = instance(tenantId, instanceLid);
    tenantInstances(tenantId).put(instanceLid, instance.markFailed());
    tenantFailures(tenantId).put(failureKey(instanceLid, nodeCode), new WorkflowFailureState(WorkflowFailureStatus.FAILED, 0, reason, "人工处理后重放"));
    repository.metricEvents().add(new WorkflowMetricEvent("workflow.failed", instanceLid, nodeCode, reason));
    appendTimeline(tenantId, instanceLid, "NODE_FAILED", currentTraceId(tenantId, instanceLid), reason);
  }

  public void markManualIntervention(String instanceLid, String nodeCode, String reason) {
    markManualIntervention("global", instanceLid, nodeCode, reason);
  }

  public void markManualIntervention(String tenantId, String instanceLid, String nodeCode, String reason) {
    WorkflowInstance instance = instance(tenantId, instanceLid);
    WorkflowFailureState state = failureStateOrDefault(tenantId, instanceLid, nodeCode).withStatus(WorkflowFailureStatus.MANUAL_INTERVENTION, reason);
    tenantFailures(tenantId).put(failureKey(instanceLid, nodeCode), state);
    repository.metricEvents().add(new WorkflowMetricEvent("workflow.manual_intervention", instanceLid, nodeCode, reason));
    appendTimeline(tenantId, instanceLid, "MANUAL_INTERVENTION", instance.traceId(), reason);
  }

  public void recordNodeTimeout(WorkflowNodeTimeoutCommand command) {
    recordNodeTimeout(
        command.tenantId(),
        command.instanceLid(),
        command.nodeCode(),
        command.timeoutAt(),
        command.maxRetry());
  }

  public void recordNodeTimeout(String tenantId, String instanceLid, String nodeCode, Instant timeoutAt, int maxRetry) {
    WorkflowInstance instance = instance(tenantId, instanceLid);
    WorkflowFailureState current = failureStateOrDefault(tenantId, instanceLid, nodeCode);
    WorkflowFailureState next = current.withStatus(WorkflowFailureStatus.TIMEOUT, "timeout@" + timeoutAt);
    if (current.retryCount() >= maxRetry) {
      next = new WorkflowFailureState(WorkflowFailureStatus.DEAD_LETTER, current.retryCount(), "timeout@" + timeoutAt, "人工处理后重放");
      repository.metricEvents().add(new WorkflowMetricEvent("workflow.node_dead_letter", instanceLid, nodeCode, "timeout@" + timeoutAt));
      repository.metricEvents().add(new WorkflowMetricEvent("workflow.manual_intervention", instanceLid, nodeCode, "人工处理后重放"));
      appendTimeline(tenantId, instanceLid, "NODE_DEAD_LETTER", instance.traceId(), "timeout@" + timeoutAt);
    }
    tenantFailures(tenantId).put(failureKey(instanceLid, nodeCode), next);
    repository.metricEvents().add(new WorkflowMetricEvent("workflow.node_timeout", instanceLid, nodeCode, timeoutAt.toString()));
    appendTimeline(tenantId, instanceLid, "NODE_TIMEOUT", instance.traceId(), timeoutAt.toString());
  }

  public WorkflowFailureState failureState(String tenantId, String instanceLid, String nodeCode) {
    WorkflowFailureState state = tenantFailures(tenantId).get(failureKey(instanceLid, nodeCode));
    if (state == null) {
      throw new IllegalArgumentException("节点失败状态不存在");
    }
    return state;
  }

  public WorkflowInstance instance(String instanceLid) {
    return instance("global", instanceLid);
  }

  public WorkflowInstance instance(String tenantId, String instanceLid) {
    WorkflowInstance instance = tenantInstances(tenantId).get(instanceLid);
    if (instance == null) {
      throw new IllegalArgumentException("工作流实例不存在");
    }
    return instance;
  }

  public WorkflowImpactReport impactReport(String workflowCode, String roleCode) {
    return impactReport("global", workflowCode, roleCode);
  }

  public WorkflowImpactReport impactReport(String tenantId, String workflowCode, String roleCode) {
    List<String> affected = tenantInstances(tenantId).values().stream()
        .filter(instance -> workflowCode.equals(instance.workflowCode()))
        .filter(instance -> definition(instance).nodeRoleMap().containsValue(roleCode))
        .map(WorkflowInstance::lid)
        .toList();
    return new WorkflowImpactReport(affected);
  }

  public WorkflowCompatibilityReport compatibilityReport(String tenantId, String instanceLid, String workflowCode) {
    WorkflowInstance instance = instance(tenantId, instanceLid);
    if (!instance.workflowCode().equals(workflowCode)) {
      throw new IllegalArgumentException("流程编码与实例不一致");
    }
    WorkflowDefinition pinned = definition(instance);
    WorkflowDefinition latest = repository.latestDefinitions().get(instance.workflowCode());
    List<String> risks = new ArrayList<>();
    if (latest != null) {
      for (String nodeCode : pinned.nodeRoleMap().keySet()) {
        if (!latest.nodeRoleMap().containsKey(nodeCode)) {
          risks.add("节点删除");
          break;
        }
      }
      if (!pinned.nodeRoleMap().equals(latest.nodeRoleMap())) {
        risks.add("角色变化");
      }
    }
    return new WorkflowCompatibilityReport("PINNED_OLD_VERSION", List.copyOf(risks));
  }

  public List<WorkflowTimelineEvent> timeline(String tenantId, String instanceLid) {
    return List.copyOf(repository.timelinesByTenant().getOrDefault(tenantId, List.of()).stream()
        .filter(event -> instanceLid.equals(event.instanceLid()))
        .toList());
  }

  public List<WorkflowPersistenceSnapshot> exportPersistenceSnapshots(String tenantId) {
    return tenantInstances(tenantId).values().stream()
        .map(instance -> new WorkflowPersistenceSnapshot(
            tenantId,
            toSnapshot(instance),
            taskSnapshots(tenantId, instance.lid()),
            failureSnapshots(tenantId, instance.lid()),
            timelineSnapshots(tenantId, instance.lid())))
        .toList();
  }

  public List<WorkflowMetricEvent> metricEvents() {
    return List.copyOf(repository.metricEvents());
  }

  private Map<String, WorkflowInstance> tenantInstances(String tenantId) {
    return repository.instancesByTenant().computeIfAbsent(tenantId, ignored -> new LinkedHashMap<>());
  }

  private Map<String, WorkflowTask> tenantTasks(String tenantId) {
    return repository.tasksByTenant().computeIfAbsent(tenantId, ignored -> new LinkedHashMap<>());
  }

  private Map<String, WorkflowFailureState> tenantFailures(String tenantId) {
    return repository.failuresByTenant().computeIfAbsent(tenantId, ignored -> new LinkedHashMap<>());
  }

  private WorkflowDefinition definition(String workflowCode, String version) {
    WorkflowDefinition exact = repository.definitionsByVersion().getOrDefault(workflowCode, Map.of()).get(version);
    if (exact != null) {
      return exact;
    }
    return new WorkflowDefinition(workflowCode, version, Map.of("approve", "manager"), 1);
  }

  private WorkflowDefinition definition(WorkflowInstance instance) {
    if (instance.definitionSnapshot() != null) {
      return instance.definitionSnapshot();
    }
    return definition(instance.workflowCode(), instance.definitionVersion());
  }

  private WorkflowTask task(String tenantId, String taskLid) {
    WorkflowTask task = tenantTasks(tenantId).get(taskLid);
    if (task == null) {
      throw new IllegalArgumentException("审批任务不存在");
    }
    return task;
  }

  private WorkflowFailureState failureStateOrDefault(String tenantId, String instanceLid, String nodeCode) {
    return tenantFailures(tenantId).getOrDefault(
        failureKey(instanceLid, nodeCode),
        new WorkflowFailureState(WorkflowFailureStatus.NONE, 0, "", "人工处理后重放"));
  }

  private WorkflowInstanceSnapshot toSnapshot(WorkflowInstance instance) {
    return new WorkflowInstanceSnapshot(
        instance.lid(),
        instance.tenantId(),
        instance.workflowCode(),
        instance.definitionVersion(),
        instance.recordLid(),
        instance.traceId(),
        instance.failed(),
        instance.startedBy(),
        instance.workflowVersion(),
        instance.nodeVersion(),
        instance.schemaVersion(),
        toSnapshot(definition(instance)));
  }

  private WorkflowDefinitionSnapshot toSnapshot(WorkflowDefinition definition) {
    return new WorkflowDefinitionSnapshot(
        definition.code(),
        definition.version(),
        definition.nodeRoleMap(),
        definition.schemaVersion());
  }

  private List<WorkflowTaskSnapshot> taskSnapshots(String tenantId, String instanceLid) {
    return tenantTasks(tenantId).values().stream()
        .filter(task -> instanceLid.equals(task.instanceLid()))
        .map(task -> new WorkflowTaskSnapshot(
            task.taskLid(),
            task.instanceLid(),
            task.nodeCode(),
            task.assigneeRole(),
            task.assigneeUser(),
            task.status(),
            task.decision(),
            task.tenantId()))
        .toList();
  }

  private List<WorkflowFailureSnapshot> failureSnapshots(String tenantId, String instanceLid) {
    return tenantFailures(tenantId).entrySet().stream()
        .filter(entry -> entry.getKey().startsWith(instanceLid + "|"))
        .map(entry -> {
          String nodeCode = entry.getKey().substring(instanceLid.length() + 1);
          WorkflowFailureState state = entry.getValue();
          return new WorkflowFailureSnapshot(
              instanceLid,
              nodeCode,
              state.status(),
              state.retryCount(),
              state.lastReason(),
              state.manualSuggestion());
        })
        .toList();
  }

  private List<WorkflowTimelineSnapshot> timelineSnapshots(String tenantId, String instanceLid) {
    return timeline(tenantId, instanceLid).stream()
        .map(event -> new WorkflowTimelineSnapshot(
            event.instanceLid(),
            event.eventType(),
            event.traceId(),
            event.detail()))
        .toList();
  }

  private String failureKey(String instanceLid, String nodeCode) {
    return instanceLid + "|" + nodeCode;
  }

  private String nodeRetryKey(String tenantId, String instanceLid, String nodeCode) {
    return tenantId + "|" + instanceLid + "|" + nodeCode;
  }

  private String currentTraceId(String tenantId, String instanceLid) {
    return instance(tenantId, instanceLid).traceId();
  }

  private void appendTimeline(String tenantId, String instanceLid, String eventType, String traceId, String detail) {
    repository.timelinesByTenant().computeIfAbsent(tenantId, ignored -> new ArrayList<>())
        .add(new WorkflowTimelineEvent(instanceLid, eventType, traceId, detail));
  }
}

record WorkflowDefinition(String code, String version, Map<String, String> nodeRoleMap, int schemaVersion) {

  WorkflowDefinition {
    nodeRoleMap = Map.copyOf(nodeRoleMap);
  }

  WorkflowDefinition(String code, String version, Map<String, String> nodeRoleMap) {
    this(code, version, nodeRoleMap, 1);
  }
}

record WorkflowInstance(
    String lid,
    String tenantId,
    String workflowCode,
    String definitionVersion,
    String recordLid,
    String traceId,
    boolean failed,
    String startedBy,
    int workflowVersion,
    int nodeVersion,
    int schemaVersion,
    WorkflowDefinition definitionSnapshot) {

  WorkflowInstance(
      String lid,
      String tenantId,
      String workflowCode,
      String definitionVersion,
      String recordLid,
      String traceId,
      boolean failed,
      String startedBy,
      int workflowVersion,
      int nodeVersion,
      int schemaVersion) {
    this(
        lid,
        tenantId,
        workflowCode,
        definitionVersion,
        recordLid,
        traceId,
        failed,
        startedBy,
        workflowVersion,
        nodeVersion,
        schemaVersion,
        null);
  }

  WorkflowInstance markFailed() {
    return new WorkflowInstance(
        lid,
        tenantId,
        workflowCode,
        definitionVersion,
        recordLid,
        traceId,
        true,
        startedBy,
        workflowVersion,
        nodeVersion,
        schemaVersion,
        definitionSnapshot);
  }
}

record WorkflowTask(
    String taskLid,
    String instanceLid,
    String nodeCode,
    String assigneeRole,
    String assigneeUser,
    WorkflowTaskStatus status,
    String decision,
    String tenantId) {

  WorkflowTask(String taskLid, String instanceLid, String nodeCode, String assigneeRole, String assigneeUser, WorkflowTaskStatus status, String decision) {
    this(taskLid, instanceLid, nodeCode, assigneeRole, assigneeUser, status, decision, "global");
  }
}

enum WorkflowTaskStatus {
  CREATED,
  CLAIMED,
  COMPLETED
}

enum WorkflowFailureStatus {
  NONE,
  TIMEOUT,
  FAILED,
  MANUAL_INTERVENTION,
  DEAD_LETTER
}

record WorkflowFailureState(
    WorkflowFailureStatus status,
    int retryCount,
    String lastReason,
    String manualSuggestion) {

  WorkflowFailureState incrementRetry(String reason) {
    return new WorkflowFailureState(status == WorkflowFailureStatus.NONE ? WorkflowFailureStatus.TIMEOUT : status, retryCount + 1, reason, manualSuggestion);
  }

  WorkflowFailureState withStatus(WorkflowFailureStatus nextStatus, String reason) {
    return new WorkflowFailureState(nextStatus, retryCount, reason, manualSuggestion);
  }
}

record WorkflowImpactReport(List<String> affectedInstanceLids) {}

record WorkflowMetricEvent(String metricCode, String instanceLid, String nodeCode, String reason) {}

record WorkflowTimelineEvent(String instanceLid, String eventType, String traceId, String detail) {}

record WorkflowCompatibilityReport(String strategy, List<String> risks) {}
