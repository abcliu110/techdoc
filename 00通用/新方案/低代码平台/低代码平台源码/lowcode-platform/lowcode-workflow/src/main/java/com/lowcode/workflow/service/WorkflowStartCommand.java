package com.lowcode.workflow.service;

public record WorkflowStartCommand(
    String tenantId,
    String workflowCode,
    String recordLid,
    String traceId,
    String startedBy) {}
