package com.lowcode.workflow.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

final class InMemoryWorkflowRepository implements WorkflowRepository {

  private final Map<String, WorkflowDefinition> latestDefinitions = new LinkedHashMap<>();
  private final Map<String, Map<String, WorkflowDefinition>> definitionsByVersion = new LinkedHashMap<>();
  private final Map<String, Map<String, WorkflowInstance>> instancesByTenant = new LinkedHashMap<>();
  private final Map<String, Map<String, WorkflowTask>> tasksByTenant = new LinkedHashMap<>();
  private final Map<String, Map<String, WorkflowFailureState>> failuresByTenant = new LinkedHashMap<>();
  private final Map<String, List<WorkflowTimelineEvent>> timelinesByTenant = new LinkedHashMap<>();
  private final Map<String, String> startIdempotency = new LinkedHashMap<>();
  private final Map<String, Integer> nodeRetryCounts = new LinkedHashMap<>();
  private final List<WorkflowMetricEvent> metricEvents = new ArrayList<>();

  static InMemoryWorkflowRepository restore(List<WorkflowPersistenceSnapshot> snapshots) {
    InMemoryWorkflowRepository repository = new InMemoryWorkflowRepository();
    for (WorkflowPersistenceSnapshot snapshot : snapshots) {
      WorkflowDefinition definition = toDefinition(snapshot.instance().definitionSnapshot());
      repository.latestDefinitions().putIfAbsent(definition.code(), definition);
      repository.definitionsByVersion()
          .computeIfAbsent(definition.code(), ignored -> new LinkedHashMap<>())
          .put(definition.version(), definition);

      String tenantId = snapshot.tenantId();
      WorkflowInstanceSnapshot instance = snapshot.instance();
      repository.instancesByTenant()
          .computeIfAbsent(tenantId, ignored -> new LinkedHashMap<>())
          .put(instance.lid(), toInstance(instance, definition));

      Map<String, WorkflowTask> tenantTasks =
          repository.tasksByTenant().computeIfAbsent(tenantId, ignored -> new LinkedHashMap<>());
      for (WorkflowTaskSnapshot task : snapshot.tasks()) {
        tenantTasks.put(task.taskLid(), toTask(task));
      }

      Map<String, WorkflowFailureState> tenantFailures =
          repository.failuresByTenant().computeIfAbsent(tenantId, ignored -> new LinkedHashMap<>());
      for (WorkflowFailureSnapshot failure : snapshot.failures()) {
        tenantFailures.put(
            failure.instanceLid() + "|" + failure.nodeCode(),
            new WorkflowFailureState(
                failure.status(),
                failure.retryCount(),
                failure.lastReason(),
                failure.manualSuggestion()));
        repository.nodeRetryCounts().put(
            tenantId + "|" + failure.instanceLid() + "|" + failure.nodeCode(),
            failure.retryCount());
      }

      List<WorkflowTimelineEvent> tenantTimeline =
          repository.timelinesByTenant().computeIfAbsent(tenantId, ignored -> new ArrayList<>());
      for (WorkflowTimelineSnapshot event : snapshot.timeline()) {
        tenantTimeline.add(
            new WorkflowTimelineEvent(
                event.instanceLid(),
                event.eventType(),
                event.traceId(),
                event.detail()));
      }
    }
    return repository;
  }

  @Override
  public Map<String, WorkflowDefinition> latestDefinitions() {
    return latestDefinitions;
  }

  @Override
  public Map<String, Map<String, WorkflowDefinition>> definitionsByVersion() {
    return definitionsByVersion;
  }

  @Override
  public Map<String, Map<String, WorkflowInstance>> instancesByTenant() {
    return instancesByTenant;
  }

  @Override
  public Map<String, Map<String, WorkflowTask>> tasksByTenant() {
    return tasksByTenant;
  }

  @Override
  public Map<String, Map<String, WorkflowFailureState>> failuresByTenant() {
    return failuresByTenant;
  }

  @Override
  public Map<String, List<WorkflowTimelineEvent>> timelinesByTenant() {
    return timelinesByTenant;
  }

  @Override
  public Map<String, String> startIdempotency() {
    return startIdempotency;
  }

  @Override
  public Map<String, Integer> nodeRetryCounts() {
    return nodeRetryCounts;
  }

  @Override
  public List<WorkflowMetricEvent> metricEvents() {
    return metricEvents;
  }

  private static WorkflowDefinition toDefinition(WorkflowDefinitionSnapshot snapshot) {
    return new WorkflowDefinition(
        snapshot.code(),
        snapshot.version(),
        snapshot.nodeRoleMap(),
        snapshot.schemaVersion());
  }

  private static WorkflowInstance toInstance(
      WorkflowInstanceSnapshot snapshot,
      WorkflowDefinition definition) {
    return new WorkflowInstance(
        snapshot.lid(),
        snapshot.tenantId(),
        snapshot.workflowCode(),
        snapshot.definitionVersion(),
        snapshot.recordLid(),
        snapshot.traceId(),
        snapshot.failed(),
        snapshot.startedBy(),
        snapshot.workflowVersion(),
        snapshot.nodeVersion(),
        snapshot.schemaVersion(),
        definition);
  }

  private static WorkflowTask toTask(WorkflowTaskSnapshot snapshot) {
    return new WorkflowTask(
        snapshot.taskLid(),
        snapshot.instanceLid(),
        snapshot.nodeCode(),
        snapshot.assigneeRole(),
        snapshot.assigneeUser(),
        snapshot.status(),
        snapshot.decision(),
        snapshot.tenantId());
  }
}
