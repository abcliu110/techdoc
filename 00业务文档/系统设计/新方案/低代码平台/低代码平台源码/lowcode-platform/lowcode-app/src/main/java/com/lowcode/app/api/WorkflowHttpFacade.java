package com.lowcode.app.api;

import com.lowcode.workflow.service.WorkflowHttpService;
import com.lowcode.workflow.service.WorkflowStartCommand;
import com.lowcode.workflow.service.WorkflowStartResult;
import com.lowcode.workflow.service.WorkflowTaskResult;
import java.time.Instant;
import org.springframework.stereotype.Component;

@Component
class WorkflowHttpFacade {

  private final WorkflowHttpService workflowService;

  WorkflowHttpFacade(WorkflowHttpService workflowService) {
    this.workflowService = workflowService;
  }

  WorkflowStartResult start(
      AuthenticatedRuntimeContext context,
      String workflowCode,
      WorkflowStartRequest request) {
    return workflowService.start(new WorkflowStartCommand(
        String.valueOf(context.tenantId()),
        workflowCode,
        request.recordLid(),
        defaultText(request.traceId(), context.traceId()),
        defaultText(request.startedBy(), context.userLid())));
  }

  WorkflowStartResult start(String workflowCode, WorkflowStartRequest request) {
    return workflowService.start(new WorkflowStartCommand(
        request.tenantId(),
        workflowCode,
        request.recordLid(),
        request.traceId(),
        request.startedBy()));
  }

  WorkflowTaskResult createTask(
      AuthenticatedRuntimeContext context,
      String tenantId,
      String instanceLid,
      WorkflowCreateTaskRequest request) {
    return workflowService.createTask(requireContextTenant(context, tenantId), instanceLid, request.nodeCode());
  }

  WorkflowTaskResult createTask(String tenantId, String instanceLid, WorkflowCreateTaskRequest request) {
    return workflowService.createTask(tenantId, instanceLid, request.nodeCode());
  }

  WorkflowTaskResult claimTask(
      AuthenticatedRuntimeContext context,
      String tenantId,
      String taskLid,
      WorkflowClaimTaskRequest request) {
    return workflowService.claimTask(
        requireContextTenant(context, tenantId),
        taskLid,
        requireContextUser(context, request.assigneeUser()),
        defaultText(request.traceId(), context.traceId()));
  }

  WorkflowTaskResult claimTask(String tenantId, String taskLid, WorkflowClaimTaskRequest request) {
    return workflowService.claimTask(tenantId, taskLid, request.assigneeUser(), request.traceId());
  }

  WorkflowTaskResult completeTask(
      AuthenticatedRuntimeContext context,
      String tenantId,
      String taskLid,
      WorkflowCompleteTaskRequest request) {
    return workflowService.completeTask(
        requireContextTenant(context, tenantId),
        taskLid,
        requireContextUser(context, request.assigneeUser()),
        request.decision(),
        defaultText(request.traceId(), context.traceId()));
  }

  WorkflowTaskResult completeTask(String tenantId, String taskLid, WorkflowCompleteTaskRequest request) {
    return workflowService.completeTask(tenantId, taskLid, request.assigneeUser(), request.decision(), request.traceId());
  }

  WorkflowHttpService.WorkflowTimelineResult timeline(
      AuthenticatedRuntimeContext context,
      String tenantId,
      String instanceLid) {
    return workflowService.timeline(requireContextTenant(context, tenantId), instanceLid);
  }

  WorkflowHttpService.WorkflowCompatibilityResult compatibility(
      AuthenticatedRuntimeContext context,
      String tenantId,
      String instanceLid,
      String workflowCode) {
    try {
      return workflowService.compatibility(requireContextTenant(context, tenantId), instanceLid, workflowCode);
    } catch (IllegalArgumentException ex) {
      if ("流程编码与实例不一致".equals(ex.getMessage())) {
        throw invalidRequest(ex.getMessage());
      }
      throw ex;
    }
  }

  WorkflowHttpService.WorkflowFailureEnvelope recordTimeout(
      AuthenticatedRuntimeContext context,
      String tenantId,
      String instanceLid,
      String nodeCode,
      WorkflowNodeTimeoutRequest request) {
    if (request.timeoutAt() == null) {
      throw invalidRequest("超时时间不能为空");
    }
    if (request.maxRetry() < 0) {
      throw invalidRequest("最大重试次数不能为负数");
    }
    return new WorkflowHttpService.WorkflowFailureEnvelope(
        workflowService.recordTimeout(
            requireContextTenant(context, tenantId),
            instanceLid,
            nodeCode,
            request.timeoutAt(),
            request.maxRetry()));
  }

  WorkflowHttpService.WorkflowFailureEnvelope markManualIntervention(
      AuthenticatedRuntimeContext context,
      String tenantId,
      String instanceLid,
      String nodeCode,
      WorkflowManualInterventionRequest request) {
    return new WorkflowHttpService.WorkflowFailureEnvelope(
        workflowService.markManualIntervention(
            requireContextTenant(context, tenantId),
            instanceLid,
            nodeCode,
            request.reason()));
  }

  private String requireContextTenant(AuthenticatedRuntimeContext context, String tenantId) {
    String contextTenantId = String.valueOf(context.tenantId());
    if (!contextTenantId.equals(tenantId)) {
      throw new com.lowcode.common.error.BizException(
          com.lowcode.common.error.ErrorCode.PARAM_INVALID,
          "租户与网关上下文不一致");
    }
    return contextTenantId;
  }

  private String requireContextUser(AuthenticatedRuntimeContext context, String assigneeUser) {
    if (assigneeUser != null && !assigneeUser.isBlank() && !context.userLid().equals(assigneeUser.trim())) {
      throw new com.lowcode.common.error.BizException(
          com.lowcode.common.error.ErrorCode.PARAM_INVALID,
          "用户与网关上下文不一致");
    }
    return context.userLid();
  }

  private com.lowcode.common.error.BizException invalidRequest(String message) {
    return new com.lowcode.common.error.BizException(
        com.lowcode.common.error.ErrorCode.PARAM_INVALID,
        message);
  }

  private String defaultText(String value, String defaultValue) {
    return value == null || value.isBlank() ? defaultValue : value.trim();
  }
}

record WorkflowStartRequest(String tenantId, String recordLid, String traceId, String startedBy) {}

record WorkflowCreateTaskRequest(String nodeCode) {}

record WorkflowClaimTaskRequest(String assigneeUser, String traceId) {}

record WorkflowCompleteTaskRequest(String assigneeUser, String decision, String traceId) {}

record WorkflowNodeTimeoutRequest(Instant timeoutAt, int maxRetry) {}

record WorkflowManualInterventionRequest(String reason) {}
