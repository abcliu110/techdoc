package com.lowcode.workflow.service;

import java.util.List;
import java.util.Map;

interface WorkflowRepository {

  Map<String, WorkflowDefinition> latestDefinitions();

  Map<String, Map<String, WorkflowDefinition>> definitionsByVersion();

  Map<String, Map<String, WorkflowInstance>> instancesByTenant();

  Map<String, Map<String, WorkflowTask>> tasksByTenant();

  Map<String, Map<String, WorkflowFailureState>> failuresByTenant();

  Map<String, List<WorkflowTimelineEvent>> timelinesByTenant();

  Map<String, String> startIdempotency();

  Map<String, Integer> nodeRetryCounts();

  List<WorkflowMetricEvent> metricEvents();
}
