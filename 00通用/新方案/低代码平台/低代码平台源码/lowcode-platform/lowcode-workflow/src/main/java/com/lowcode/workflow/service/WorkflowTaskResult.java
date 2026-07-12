package com.lowcode.workflow.service;

public record WorkflowTaskResult(
    String taskLid,
    String instanceLid,
    String nodeCode,
    String assigneeRole,
    String assigneeUser,
    String status,
    String decision) {}
