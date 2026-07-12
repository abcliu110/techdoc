package com.lowcode.workflow.service;

import java.time.Instant;

record WorkflowNodeTimeoutCommand(
    String tenantId,
    String instanceLid,
    String nodeCode,
    Instant timeoutAt,
    int maxRetry) {}
