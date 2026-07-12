package com.lowcode.workflow.service;

import java.util.Map;

/**
 * Explicit demo/test-only workflow wiring.
 */
public final class WorkflowDemoFactory {

  private WorkflowDemoFactory() {}

  public static WorkflowHttpService createHttpService() {
    WorkflowRuntimeService runtimeService = new WorkflowRuntimeService(new InMemoryWorkflowRepository());
    runtimeService.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    return new WorkflowHttpService(runtimeService);
  }
}
