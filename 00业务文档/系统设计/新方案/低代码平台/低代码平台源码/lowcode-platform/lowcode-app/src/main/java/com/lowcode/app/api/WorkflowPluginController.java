package com.lowcode.app.api;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
class WorkflowPluginController {

  private final WorkflowHttpFacade workflowHttpFacade;
  private final PackageManifestHttpFacade packageManifestHttpFacade;
  private final AuthenticatedRuntimeContextResolver contextResolver;
  private final ApiErrorResponseFactory errorResponseFactory;

  WorkflowPluginController(
      WorkflowHttpFacade workflowHttpFacade,
      PackageManifestHttpFacade packageManifestHttpFacade,
      AuthenticatedRuntimeContextResolver contextResolver,
      ApiErrorResponseFactory errorResponseFactory) {
    this.workflowHttpFacade = workflowHttpFacade;
    this.packageManifestHttpFacade = packageManifestHttpFacade;
    this.contextResolver = contextResolver;
    this.errorResponseFactory = errorResponseFactory;
  }

  @PostMapping("/api/workflow/{workflowCode}/start")
  Object startWorkflow(
      @PathVariable("workflowCode") String workflowCode,
      HttpServletRequest httpRequest,
      @RequestBody WorkflowStartRequest request) {
    return workflowHttpFacade.start(context(httpRequest, "workflow", workflowCode), workflowCode, request);
  }

  @PostMapping("/api/workflow/{tenantId}/instances/{instanceLid}/tasks")
  Object createTask(
      @PathVariable("tenantId") String tenantId,
      @PathVariable("instanceLid") String instanceLid,
      HttpServletRequest httpRequest,
      @RequestBody WorkflowCreateTaskRequest request) {
    return workflowHttpFacade.createTask(
        context(httpRequest, "workflow", "task"),
        tenantId,
        instanceLid,
        request);
  }

  @PostMapping("/api/workflow/{tenantId}/tasks/{taskLid}/claim")
  Object claimTask(
      @PathVariable("tenantId") String tenantId,
      @PathVariable("taskLid") String taskLid,
      HttpServletRequest httpRequest,
      @RequestBody WorkflowClaimTaskRequest request) {
    return workflowHttpFacade.claimTask(
        context(httpRequest, "workflow", "task"),
        tenantId,
        taskLid,
        request);
  }

  @PostMapping("/api/workflow/{tenantId}/tasks/{taskLid}/complete")
  Object completeTask(
      @PathVariable("tenantId") String tenantId,
      @PathVariable("taskLid") String taskLid,
      HttpServletRequest httpRequest,
      @RequestBody WorkflowCompleteTaskRequest request) {
    return workflowHttpFacade.completeTask(
        context(httpRequest, "workflow", "task"),
        tenantId,
        taskLid,
        request);
  }

  @GetMapping("/api/workflow/{tenantId}/instances/{instanceLid}/timeline")
  Object timeline(
      @PathVariable("tenantId") String tenantId,
      @PathVariable("instanceLid") String instanceLid,
      HttpServletRequest httpRequest) {
    return workflowHttpFacade.timeline(
        context(httpRequest, "workflow", "diagnostics"),
        tenantId,
        instanceLid);
  }

  @GetMapping("/api/workflow/{tenantId}/instances/{instanceLid}/compatibility")
  Object compatibility(
      @PathVariable("tenantId") String tenantId,
      @PathVariable("instanceLid") String instanceLid,
      @RequestParam("workflowCode") String workflowCode,
      HttpServletRequest httpRequest) {
    return workflowHttpFacade.compatibility(
        context(httpRequest, "workflow", "diagnostics"),
        tenantId,
        instanceLid,
        workflowCode);
  }

  @PostMapping("/api/workflow/{tenantId}/instances/{instanceLid}/nodes/{nodeCode}/timeout")
  Object recordTimeout(
      @PathVariable("tenantId") String tenantId,
      @PathVariable("instanceLid") String instanceLid,
      @PathVariable("nodeCode") String nodeCode,
      HttpServletRequest httpRequest,
      @RequestBody WorkflowNodeTimeoutRequest request) {
    return workflowHttpFacade.recordTimeout(
        context(httpRequest, "workflow", "diagnostics"),
        tenantId,
        instanceLid,
        nodeCode,
        request);
  }

  @PostMapping("/api/workflow/{tenantId}/instances/{instanceLid}/nodes/{nodeCode}/manual-intervention")
  Object markManualIntervention(
      @PathVariable("tenantId") String tenantId,
      @PathVariable("instanceLid") String instanceLid,
      @PathVariable("nodeCode") String nodeCode,
      HttpServletRequest httpRequest,
      @RequestBody WorkflowManualInterventionRequest request) {
    return workflowHttpFacade.markManualIntervention(
        context(httpRequest, "workflow", "diagnostics"),
        tenantId,
        instanceLid,
        nodeCode,
        request);
  }

  @PostMapping("/api/packages/precheck")
  Object precheckPackage(
      HttpServletRequest httpRequest,
      @RequestBody PackagePrecheckRequest request) {
    AuthenticatedRuntimeContext runtimeContext = context(httpRequest, "package", "manifest");
    return packageManifestHttpFacade.precheck(runtimeContext, request);
  }

  @ExceptionHandler(com.lowcode.common.error.BizException.class)
  Object handleBizException(com.lowcode.common.error.BizException ex, HttpServletRequest request) {
    ApiErrorResponse response = errorResponseFactory.fromBizException(ex, request);
    return ResponseEntity.status(response.status()).body(response.body());
  }

  @ExceptionHandler(RuntimeException.class)
  Object handleRuntimeException(RuntimeException ex, HttpServletRequest request) {
    ApiErrorResponse response = errorResponseFactory.fromRuntimeException(ex, request);
    return ResponseEntity.status(response.status()).body(response.body());
  }

  private AuthenticatedRuntimeContext context(HttpServletRequest request, String appCode, String objectCode) {
    String metaHash = request.getHeader("X-Meta-Hash") == null ? "mh-1" : request.getHeader("X-Meta-Hash");
    return contextResolver.resolve(request, appCode, objectCode, metaHash);
  }
}
