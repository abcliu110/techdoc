package com.lowcode.workflow.service;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

record WorkflowPersistenceSnapshot(
    String tenantId,
    WorkflowInstanceSnapshot instance,
    List<WorkflowTaskSnapshot> tasks,
    List<WorkflowFailureSnapshot> failures,
    List<WorkflowTimelineSnapshot> timeline) implements Serializable {

  WorkflowPersistenceSnapshot {
    tasks = List.copyOf(tasks);
    failures = List.copyOf(failures);
    timeline = List.copyOf(timeline);
  }
}

record WorkflowInstanceSnapshot(
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
    WorkflowDefinitionSnapshot definitionSnapshot) implements Serializable {}

record WorkflowDefinitionSnapshot(
    String code,
    String version,
    Map<String, String> nodeRoleMap,
    int schemaVersion) implements Serializable {

  WorkflowDefinitionSnapshot {
    nodeRoleMap = Map.copyOf(nodeRoleMap);
  }
}

record WorkflowTaskSnapshot(
    String taskLid,
    String instanceLid,
    String nodeCode,
    String assigneeRole,
    String assigneeUser,
    WorkflowTaskStatus status,
    String decision,
    String tenantId) implements Serializable {}

record WorkflowFailureSnapshot(
    String instanceLid,
    String nodeCode,
    WorkflowFailureStatus status,
    int retryCount,
    String lastReason,
    String manualSuggestion) implements Serializable {}

record WorkflowTimelineSnapshot(
    String instanceLid,
    String eventType,
    String traceId,
    String detail) implements Serializable {}
