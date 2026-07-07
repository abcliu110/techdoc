package com.lowcode.app.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.StandardCharsets;
import java.util.HexFormat;
import java.util.List;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.objenesis.ObjenesisStd;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

@WebMvcTest(WorkflowPluginController.class)
@Import({
    WorkflowPluginControllerTest.WorkflowPluginControllerTestConfig.class,
    ApiErrorResponseFactory.class
})
class WorkflowPluginControllerTest {

  @Autowired private MockMvc mockMvc;

  @TestConfiguration
  static class WorkflowPluginControllerTestConfig {

    private static final ObjenesisStd OBJENESIS = new ObjenesisStd();

    @Bean
    WorkflowHttpFacade workflowHttpFacade() {
      return new WorkflowHttpFacade();
    }

    @Bean
    PackageManifestHttpFacade packageManifestHttpFacade() {
      return OBJENESIS.newInstance(StubPackageManifestHttpFacade.class);
    }

    @Bean
    AuthenticatedRuntimeContextResolver authenticatedRuntimeContextResolver() {
      return new AuthenticatedRuntimeContextResolver("test-gateway-secret");
    }
  }

  static final class StubPackageManifestHttpFacade extends PackageManifestHttpFacade {

    @Override
    PackagePrecheckResponse precheck(PackagePrecheckRequest request) {
      String packageCode = request.manifest() == null ? null : request.manifest().packageCode();
      if (packageCode == null || packageCode.isBlank()) {
        return new PackagePrecheckResponse(false, List.of(
            new PackagePrecheckError("manifest.packageCode", "PACKAGE_CODE_REQUIRED", "packageCode required")));
      }
      return new PackagePrecheckResponse(true, List.of());
    }
  }

  @Test
  void shouldExposeMinimalWorkflowRuntimeHttpSurface() throws Exception {
    String startResponse = mockMvc.perform(post("/api/workflow/expense/start")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-1")
            .content("""
                {
                  "recordLid": "record-1",
                  "traceId": "trace-wf-1"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.instanceLid").exists())
        .andExpect(jsonPath("$.workflowCode").value("expense"))
        .andReturn()
        .getResponse()
        .getContentAsString();

    String instanceLid = startResponse.replaceAll(".*\\\"instanceLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    String taskResponse = mockMvc.perform(post("/api/workflow/3/instances/" + instanceLid + "/tasks")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-task")
            .content("{\"nodeCode\":\"approve\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.assigneeRole").value("manager"))
        .andReturn()
        .getResponse()
        .getContentAsString();

    String taskLid = taskResponse.replaceAll(".*\\\"taskLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    mockMvc.perform(post("/api/workflow/3/tasks/" + taskLid + "/claim")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "user-1", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-2")
            .content("{\"assigneeUser\":\"user-1\",\"traceId\":\"trace-wf-2\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value("CLAIMED"));

    mockMvc.perform(post("/api/workflow/3/tasks/" + taskLid + "/complete")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "user-1", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-3")
            .content("{\"assigneeUser\":\"user-1\",\"decision\":\"approved\",\"traceId\":\"trace-wf-3\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value("COMPLETED"));
  }

  @Test
  void shouldExposeWorkflowDiagnosticsAndManualOperationSurface() throws Exception {
    String startResponse = mockMvc.perform(post("/api/workflow/expense/start")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-diagnostics")
            .content("{\"recordLid\":\"record-diagnostics\"}"))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString();

    String instanceLid = startResponse.replaceAll(".*\\\"instanceLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    mockMvc.perform(get("/api/workflow/3/instances/" + instanceLid + "/timeline")
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-timeline"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.events[0].eventType").value("INSTANCE_STARTED"));

    mockMvc.perform(get("/api/workflow/3/instances/" + instanceLid + "/compatibility?workflowCode=expense")
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-compatibility"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.strategy").value("PINNED_OLD_VERSION"));

    mockMvc.perform(post("/api/workflow/3/instances/" + instanceLid + "/nodes/approve/timeout")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-timeout")
            .content("""
                {
                  "timeoutAt": "2026-07-07T05:00:00Z",
                  "maxRetry": 2
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.state.status").value("TIMEOUT"));

    mockMvc.perform(post("/api/workflow/3/instances/" + instanceLid + "/nodes/approve/manual-intervention")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-manual")
            .content("{\"reason\":\"manual review\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.state.status").value("MANUAL_INTERVENTION"));
  }

  @Test
  void shouldRejectWorkflowDiagnosticsWhenRequestDoesNotMatchInstanceOrValidTimeout() throws Exception {
    String startResponse = mockMvc.perform(post("/api/workflow/expense/start")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-diagnostics-invalid")
            .content("{\"recordLid\":\"record-diagnostics-invalid\"}"))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString();

    String instanceLid = startResponse.replaceAll(".*\\\"instanceLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    mockMvc.perform(get("/api/workflow/3/instances/" + instanceLid + "/compatibility?workflowCode=other")
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-compatibility-invalid"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("流程编码与实例不一致"));

    mockMvc.perform(post("/api/workflow/3/instances/" + instanceLid + "/nodes/approve/timeout")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-timeout-null")
            .content("{\"maxRetry\":2}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("超时时间不能为空"));

    mockMvc.perform(post("/api/workflow/3/instances/" + instanceLid + "/nodes/approve/timeout")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-timeout-negative")
            .content("""
                {
                  "timeoutAt": "2026-07-07T05:00:00Z",
                  "maxRetry": -1
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("最大重试次数不能为负数"));
  }

  @Test
  void shouldExposePackageManifestPrecheckSurface() throws Exception {
    mockMvc.perform(post("/api/packages/precheck")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-precheck")
            .content("""
                {
                  "manifest": {
                    "packageCode": "customer_pkg",
                    "version": "1.0.0",
                    "license": "commercial",
                    "objects": ["customer"],
                    "permissions": ["customer:read"],
                    "compatibility": {
                      "minPlatformVersion": "0.1.0",
                      "maxTestedPlatformVersion": "0.1.x",
                      "apiLevel": "M3"
                    },
                    "runtimeEnabled": true
                  },
                  "context": {
                    "availableObjects": ["customer"],
                    "grantedPermissions": ["customer:read"],
                    "platformVersion": "0.1.0",
                    "apiLevel": "M3"
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.passed").value(true))
        .andExpect(jsonPath("$.errors").isEmpty());
  }

  @Test
  void shouldHidePackagePrecheckErrorDetailsBehindStableResponse() throws Exception {
    mockMvc.perform(post("/api/packages/precheck")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-precheck-invalid")
            .content("""
                {
                  "manifest": {
                    "packageCode": "",
                    "version": "",
                    "objects": ["missing"],
                    "runtimeEnabled": true
                  },
                  "context": {
                    "availableObjects": [],
                    "grantedPermissions": []
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.passed").value(false))
        .andExpect(jsonPath("$.errors[0].code").exists())
        .andExpect(jsonPath("$.errors[0].path").exists());
  }

  @Test
  void shouldRejectUnsignedWorkflowAndPackageRequests() throws Exception {
    mockMvc.perform(post("/api/workflow/expense/start")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "starter-a")
            .content("""
                {
                  "recordLid": "record-1",
                  "traceId": "trace-unsigned"
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("网关签名无效"));

    mockMvc.perform(post("/api/packages/precheck")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "package-admin")
            .content("{\"manifest\":{\"packageCode\":\"pkg\",\"version\":\"1\",\"runtimeEnabled\":true},\"context\":{}}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("网关签名无效"));
  }

  @Test
  void shouldRejectWorkflowTaskRequestWhenTenantPathDiffersFromGatewayContext() throws Exception {
    String startResponse = mockMvc.perform(post("/api/workflow/expense/start")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-tenant-mismatch")
            .content("{\"recordLid\":\"record-tenant-mismatch\"}"))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString();

    String instanceLid = startResponse.replaceAll(".*\\\"instanceLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    mockMvc.perform(post("/api/workflow/4/instances/" + instanceLid + "/tasks")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-tenant-mismatch-task")
            .content("{\"nodeCode\":\"approve\"}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("租户与网关上下文不一致"));

    String taskResponse = mockMvc.perform(post("/api/workflow/3/instances/" + instanceLid + "/tasks")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-tenant-mismatch-task-ok")
            .content("{\"nodeCode\":\"approve\"}"))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString();

    String taskLid = taskResponse.replaceAll(".*\\\"taskLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    mockMvc.perform(post("/api/workflow/4/tasks/" + taskLid + "/claim")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "user-1", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-tenant-mismatch-claim")
            .content("{\"assigneeUser\":\"user-1\"}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("租户与网关上下文不一致"));

    mockMvc.perform(post("/api/workflow/4/tasks/" + taskLid + "/complete")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "user-1", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-tenant-mismatch-complete")
            .content("{\"assigneeUser\":\"user-1\",\"decision\":\"approved\"}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("租户与网关上下文不一致"));
  }

  @Test
  void shouldRejectWorkflowTaskRequestWhenBodyUserDiffersFromGatewayContext() throws Exception {
    String startResponse = mockMvc.perform(post("/api/workflow/expense/start")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-user-mismatch")
            .content("{\"recordLid\":\"record-user-mismatch\"}"))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString();

    String instanceLid = startResponse.replaceAll(".*\\\"instanceLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    String taskResponse = mockMvc.perform(post("/api/workflow/3/instances/" + instanceLid + "/tasks")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "starter-a", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-user-mismatch-task")
            .content("{\"nodeCode\":\"approve\"}"))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString();

    String taskLid = taskResponse.replaceAll(".*\\\"taskLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    mockMvc.perform(post("/api/workflow/3/tasks/" + taskLid + "/claim")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "user-1", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-user-mismatch-claim")
            .content("{\"assigneeUser\":\"user-2\"}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("用户与网关上下文不一致"));

    mockMvc.perform(post("/api/workflow/3/tasks/" + taskLid + "/claim")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "user-1", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-user-mismatch-claim-ok")
            .content("{\"assigneeUser\":\"user-1\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.assigneeUser").value("user-1"));

    mockMvc.perform(post("/api/workflow/3/tasks/" + taskLid + "/complete")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "user-1", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-wf-user-mismatch-complete")
            .content("{\"assigneeUser\":\"user-2\",\"decision\":\"approved\"}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("用户与网关上下文不一致"));
  }

  private static RequestPostProcessor gatewaySignature(
      String tenantId,
      String workspaceId,
      String userLid,
      String roleCodes,
      String metaHash) {
    return request -> {
      String timestamp = String.valueOf(System.currentTimeMillis());
      request.addHeader("X-Tenant-Id", tenantId);
      request.addHeader("X-Workspace-Id", workspaceId);
      request.addHeader("X-User-Lid", userLid);
      request.addHeader("X-Role-Codes", roleCodes);
      request.addHeader("X-Meta-Hash", metaHash);
      request.addHeader("X-Gateway-Timestamp", timestamp);
      request.addHeader("X-Gateway-Signature", hmac(canonicalPayload(request, timestamp, metaHash)));
      return request;
    };
  }

  private static String canonicalPayload(
      org.springframework.mock.web.MockHttpServletRequest request,
      String timestamp,
      String metaHash) {
    return String.join("\n",
        request.getMethod(),
        request.getRequestURI(),
        timestamp,
        header(request, "X-Tenant-Id"),
        header(request, "X-Workspace-Id"),
        header(request, "X-User-Lid"),
        header(request, "X-Role-Codes"),
        metaHash);
  }

  private static String hmac(String payload) {
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      mac.init(new SecretKeySpec("test-gateway-secret".getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
      return HexFormat.of().formatHex(mac.doFinal(payload.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception ex) {
      throw new IllegalStateException(ex);
    }
  }

  private static String header(org.springframework.mock.web.MockHttpServletRequest request, String name) {
    String value = request.getHeader(name);
    return value == null ? "" : value.trim();
  }
}
