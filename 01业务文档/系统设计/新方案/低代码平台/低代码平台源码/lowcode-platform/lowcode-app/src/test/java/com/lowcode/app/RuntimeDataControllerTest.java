package com.lowcode.app.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.StandardCharsets;
import java.util.HexFormat;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

@WebMvcTest(RuntimeDataController.class)
@Import({
    RuntimeDataControllerTest.RuntimeDataControllerTestConfig.class,
    ApiErrorResponseFactory.class
})
class RuntimeDataControllerTest {

  @Autowired private MockMvc mockMvc;

  @TestConfiguration
  static class RuntimeDataControllerTestConfig {

    @Bean
    AuthenticatedRuntimeContextResolver authenticatedRuntimeContextResolver() {
      return new AuthenticatedRuntimeContextResolver("test-gateway-secret");
    }

    @Bean
    RuntimeHttpFacade runtimeHttpFacade() {
      try {
        Class<?> type = Class.forName("com.lowcode.app.api.InMemoryRuntimeHttpFacade");
        var constructor = type.getDeclaredConstructor();
        constructor.setAccessible(true);
        return (RuntimeHttpFacade) constructor.newInstance();
      } catch (ReflectiveOperationException ex) {
        throw new IllegalStateException(ex);
      }
    }
  }

  @Test
  void shouldExposeAddListTransitionAndExplainHttpContracts() throws Exception {
    mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "7000")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager,auditor")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-1")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-add-1",
                  "values": {
                    "amount": "12000",
                    "remark": "待审批"
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.recordLid").exists())
        .andExpect(jsonPath("$.revision").value(1));

    mockMvc.perform(post("/api/data/sales/order/list")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "7000")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager,auditor")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-2")
            .content("""
                {
                  "fields": ["amount", "secret_amount"],
                  "filters": [],
                  "sorts": [],
                  "pageNo": 1,
                  "pageSize": 20
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].amount").value(12000))
        .andExpect(jsonPath("$[0].secret_amount").doesNotExist());

    mockMvc.perform(post("/api/permission/explain")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "7000")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager,auditor")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-3")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "order",
                  "operation": "UPDATE"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.allowed").value(true))
        .andExpect(jsonPath("$.reasons[0]").value("运行态角色权限通过"));
  }

  @Test
  void shouldExposeFullT102HttpSurfaceWithStableResultContract() throws Exception {
    String addResponse = mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-full-1")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-full-add-1",
                  "values": {
                    "amount": "9000",
                    "remark": "完整接口面"
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.recordLid").exists())
        .andReturn()
        .getResponse()
        .getContentAsString();

    String recordLid = addResponse.replaceAll(".*\\\"recordLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    mockMvc.perform(post("/api/data/sales/order/meta")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-full-2")
            .content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.objectCode").value("order"))
        .andExpect(jsonPath("$.fields[0]").value("amount"));

    mockMvc.perform(post("/api/data/sales/order/get")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-full-3")
            .content("{\"recordLid\":\"" + recordLid + "\",\"fields\":[\"amount\",\"remark\"]}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.lid").value(recordLid))
        .andExpect(jsonPath("$.amount").value(9000));

    mockMvc.perform(post("/api/data/sales/order/suggest")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-full-4")
            .content("{\"keyword\":\"完整\",\"fields\":[\"remark\"],\"limit\":10}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].lid").value(recordLid));

    mockMvc.perform(post("/api/data/sales/order/export")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-full-5")
            .content("{\"fields\":[\"amount\",\"secret_amount\"]}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].amount").value(9000))
        .andExpect(jsonPath("$[0].secret_amount").doesNotExist());

    mockMvc.perform(post("/api/data/sales/order/action")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-full-6")
            .content("{\"recordLid\":\"" + recordLid
                + "\",\"actionCode\":\"approve\",\"parameters\":{\"approval_comment\":\"同意\"},\"requestMetaHash\":\"mh-1\",\"idempotencyKey\":\"http-full-action-1\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.toState").value("approved"));

    mockMvc.perform(post("/api/data/sales/order/importPreview")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-full-7")
            .content("{\"rows\":[{\"amount\":\"100\",\"remark\":\"导入行\"}]}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.taskId").value("trace-http-full-7-import"))
        .andExpect(jsonPath("$.errors").isEmpty());

    mockMvc.perform(post("/api/data/sales/order/importCommit")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-full-8")
            .content("{\"taskId\":\"trace-http-full-7-import\",\"idempotencyKey\":\"http-full-import-1\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.createdCount").value(1));

    mockMvc.perform(post("/api/data/sales/order/del")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-full-9")
            .content("{\"recordLid\":\"" + recordLid + "\",\"revision\":2,\"requestMetaHash\":\"mh-1\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.deleted").value(true));
  }

  @Test
  void shouldRejectMissingTenantWorkspaceOrUserOverHttp() throws Exception {
    mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-tenant-missing")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-add-2",
                  "values": {
                    "amount": "1"
                  }
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0401"))
        .andExpect(jsonPath("$.message").value("租户不能为空"))
        .andExpect(jsonPath("$.data").doesNotExist())
        .andExpect(jsonPath("$.traceId").value("trace-http-tenant-missing"));

    mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-workspace-missing")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-add-3",
                  "values": {
                    "amount": "1"
                  }
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("工作区不能为空"))
        .andExpect(jsonPath("$.traceId").value("trace-http-workspace-missing"));

    mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .with(gatewaySignature())
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-user-missing")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-add-4",
                  "values": {
                    "amount": "1"
                  }
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("用户不能为空"))
        .andExpect(jsonPath("$.traceId").value("trace-http-user-missing"));
  }

  @Test
  void shouldResolveEmptyRoleCodesAsNoPrivilege() throws Exception {
    mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-norole-add")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-add-5",
                  "values": {
                    "amount": "100"
                  }
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-add"));

    mockMvc.perform(post("/api/permission/explain")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-norole-explain")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "order",
                  "operation": "UPDATE"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.allowed").value(false))
        .andExpect(jsonPath("$.reasons[0]").value("运行态角色权限未通过"));
  }

  @Test
  void shouldRejectRuntimeCrudAndImportSurfaceWhenRoleCodesAreEmpty() throws Exception {
    mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-norole-add-deny")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-add-deny",
                  "values": {
                    "amount": "100"
                  }
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-add-deny"));

    mockMvc.perform(post("/api/data/sales/order/list")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-norole-list")
            .content("""
                {
                  "fields": ["amount"],
                  "filters": [],
                  "sorts": [],
                  "pageNo": 1,
                  "pageSize": 20
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-list"));

    mockMvc.perform(post("/api/data/sales/order/get")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-norole-get")
            .content("""
                {
                  "recordLid": "R999",
                  "fields": ["amount"]
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-get"));

    mockMvc.perform(post("/api/data/sales/order/update")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-norole-update")
            .content("""
                {
                  "recordLid": "R999",
                  "revision": 1,
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-update-deny",
                  "values": {
                    "remark": "denied"
                  }
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-update"));

    mockMvc.perform(post("/api/data/sales/order/del")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-norole-del")
            .content("""
                {
                  "recordLid": "R999",
                  "revision": 1,
                  "requestMetaHash": "mh-1"
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-del"));

    mockMvc.perform(post("/api/data/sales/order/export")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Trace-Id", "trace-http-norole-export")
            .content("""
                {
                  "fields": ["amount"]
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-export"));

    mockMvc.perform(post("/api/data/sales/order/importPreview")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Trace-Id", "trace-http-norole-import-preview")
            .content("""
                {
                  "rows": [
                    {
                      "amount": "100",
                      "remark": "deny"
                    }
                  ]
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-import-preview"));

    mockMvc.perform(post("/api/data/sales/order/importCommit")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-norole-import-commit")
            .content("""
                {
                  "taskId": "trace-http-missing-import",
                  "idempotencyKey": "http-import-deny"
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-import-commit"));

    mockMvc.perform(post("/api/data/sales/order/suggest")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Trace-Id", "trace-http-norole-suggest")
            .content("""
                {
                  "keyword": "deny",
                  "fields": ["remark"],
                  "limit": 10
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-suggest"));

    mockMvc.perform(post("/api/data/sales/order/meta")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Trace-Id", "trace-http-norole-meta")
            .content("{}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-norole-meta"));
  }

  @Test
  void shouldIsolateRecordsAcrossWorkspacesWithinSameTenant() throws Exception {
    String workspaceSevenRecord = mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70000")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-workspace-70000-add")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-workspace-70000-add",
                  "values": {
                    "amount": "700",
                    "remark": "workspace-70000"
                  }
                }
                """))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString()
        .replaceAll(".*\\\"recordLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    String workspaceEightRecord = mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "80000")
            .header("X-User-Lid", "manager-2")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-workspace-80000-add")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-workspace-80000-add",
                  "values": {
                    "amount": "800",
                    "remark": "workspace-80000"
                  }
                }
                """))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString()
        .replaceAll(".*\\\"recordLid\\\":\\\"([^\\\"]+)\\\".*", "$1");

    mockMvc.perform(post("/api/data/sales/order/list")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70000")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-workspace-70000-list")
            .content("""
                {
                  "fields": ["amount", "remark"],
                  "filters": [],
                  "sorts": [],
                  "pageNo": 1,
                  "pageSize": 20
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].lid").value(workspaceSevenRecord))
        .andExpect(jsonPath("$[0].remark").value("workspace-70000"))
        .andExpect(jsonPath("$[1]").doesNotExist());

    mockMvc.perform(post("/api/data/sales/order/get")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70000")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-workspace-cross-get")
            .content("{\"recordLid\":\"" + workspaceEightRecord + "\",\"fields\":[\"amount\",\"remark\"]}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-workspace-cross-get"));

    mockMvc.perform(post("/api/data/sales/order/suggest")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70000")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-workspace-cross-suggest")
            .content("""
                {
                  "keyword": "workspace-80000",
                  "fields": ["remark"],
                  "limit": 10
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0]").doesNotExist());

    mockMvc.perform(post("/api/data/sales/order/importPreview")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70000")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-workspace-import-preview")
            .content("""
                {
                  "rows": [
                    {
                      "amount": "701",
                      "remark": "workspace-70000-import"
                    }
                  ]
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.taskId").value("trace-http-workspace-import-preview-import"))
        .andExpect(jsonPath("$.errors").isEmpty());

    mockMvc.perform(post("/api/data/sales/order/importCommit")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "80000")
            .header("X-User-Lid", "manager-2")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-workspace-cross-import")
            .content("""
                {
                  "taskId": "trace-http-workspace-import-preview-import",
                  "idempotencyKey": "http-workspace-cross-import"
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-workspace-cross-import"));
  }

  @Test
  void shouldHideInternalRuntimeExceptionDetails() throws Exception {
    mockMvc.perform(post("/api/data/sales/missing/get")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .with(gatewaySignature())
            .header("X-Role-Codes", "manager")
            .header("X-Trace-Id", "trace-http-safe-error")
            .content("""
                {
                  "recordLid": "01INVALID",
                  "fields": ["amount"]
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("请求处理失败"))
        .andExpect(jsonPath("$.traceId").value("trace-http-safe-error"))
        .andExpect(jsonPath("$.stackTrace").doesNotExist())
        .andExpect(jsonPath("$.exception").doesNotExist())
        .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("select "))))
        .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("lc_rt_"))))
        .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("com.lowcode"))));
  }

  @Test
  void shouldRejectUnsignedRuntimeRequestHeaders() throws Exception {
    mockMvc.perform(post("/api/data/sales/order/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "manager-1")
            .header("X-Role-Codes", "manager")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-unsigned")
            .content("""
                {
                  "requestMetaHash": "mh-1",
                  "idempotencyKey": "http-unsigned",
                  "values": {
                    "amount": "1"
                  }
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("网关签名无效"))
        .andExpect(jsonPath("$.traceId").value("trace-http-unsigned"));
  }

  @Test
  void shouldNotExplainEmptyRoleAsAllowed() throws Exception {
    mockMvc.perform(post("/api/permission/explain")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "user-no-role")
            .with(gatewaySignature())
            .header("X-Role-Codes", " , ")
            .header("X-Meta-Hash", "mh-1")
            .header("X-Trace-Id", "trace-http-explain-deny")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "order",
                  "operation": "UPDATE"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.allowed").value(false))
        .andExpect(jsonPath("$.reasons[0]").value("运行态角色权限未通过"));
  }

  private static RequestPostProcessor gatewaySignature() {
    return request -> {
      String timestamp = String.valueOf(System.currentTimeMillis());
      request.addHeader("X-Gateway-Timestamp", timestamp);
      request.addHeader("X-Gateway-Signature", hmac(canonicalPayload(request, timestamp)));
      return request;
    };
  }

  private static String canonicalPayload(
      org.springframework.mock.web.MockHttpServletRequest request,
      String timestamp) {
    return String.join("\n",
        request.getMethod(),
        request.getRequestURI(),
        timestamp,
        header(request, "X-Tenant-Id"),
        header(request, "X-Workspace-Id"),
        header(request, "X-User-Lid"),
        header(request, "X-Role-Codes"),
        header(request, "X-Meta-Hash").isBlank() ? "mh-1" : header(request, "X-Meta-Hash"));
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
