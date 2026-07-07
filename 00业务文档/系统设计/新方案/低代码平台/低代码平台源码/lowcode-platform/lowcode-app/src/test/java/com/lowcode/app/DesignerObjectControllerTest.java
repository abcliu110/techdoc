package com.lowcode.app;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.StandardCharsets;
import java.util.HexFormat;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration",
    "lowcode.gateway.shared-secret=test-gateway-secret",
    "lowcode.app.runtime.demo-enabled=true",
    "lowcode.app.workflow.demo-enabled=true"
})
@AutoConfigureMockMvc
class DesignerObjectControllerTest {

  @Autowired private MockMvc mockMvc;

  @Test
  void shouldExposeDesignerDraftLifecycleWithUnifiedResultAndTraceId() throws Exception {
    mockMvc.perform(post("/api/designer/object/add")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-add")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "name": "销售单",
                  "fields": [
                    {"code": "customerName", "name": "客户名称", "type": "text", "required": true},
                    {"code": "amount", "name": "金额", "type": "number", "required": true}
                  ]
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.message").value("success"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-add"))
        .andExpect(jsonPath("$.data.appCode").value("sales"))
        .andExpect(jsonPath("$.data.objectCode").value("invoice"))
        .andExpect(jsonPath("$.data.revision").value(1))
        .andExpect(jsonPath("$.data.fields[0].code").value("customerName"));

    mockMvc.perform(post("/api/designer/object/get")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-get")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-get"))
        .andExpect(jsonPath("$.data.name").value("销售单"))
        .andExpect(jsonPath("$.data.revision").value(1));

    mockMvc.perform(post("/api/designer/object/list")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-list")
            .content("""
                {
                  "appCode": "sales"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-list"))
        .andExpect(jsonPath("$.data.records[0].objectCode").value("invoice"))
        .andExpect(jsonPath("$.data.records[0].revision").value(1));

    mockMvc.perform(post("/api/designer/object/validate")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-validate")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-validate"))
        .andExpect(jsonPath("$.data.valid").value(true))
        .andExpect(jsonPath("$.data.errors").isEmpty());

    mockMvc.perform(post("/api/designer/object/update")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-update")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "name": "销售单-更新",
                  "revision": 1,
                  "fields": [
                    {"code": "customerName", "name": "客户名称", "type": "text", "required": true},
                    {"code": "amount", "name": "金额", "type": "number", "required": true},
                    {"code": "status", "name": "状态", "type": "select", "required": false}
                  ]
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-update"))
        .andExpect(jsonPath("$.data.revision").value(2))
        .andExpect(jsonPath("$.data.fields[2].code").value("status"));

    mockMvc.perform(post("/api/designer/object/publish")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-publish")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "revision": 2
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-publish"))
        .andExpect(jsonPath("$.data.snapshot.object.code").value("invoice"))
        .andExpect(jsonPath("$.data.snapshot.object.name").value("销售单-更新"))
        .andExpect(jsonPath("$.data.snapshot.fields[0].code").value("customerName"))
        .andExpect(jsonPath("$.data.snapshot.fields[1].type").value("number"))
        .andExpect(jsonPath("$.data.snapshot.defaultPages.list.type").value("list"))
        .andExpect(jsonPath("$.data.snapshot.defaultPages.form.type").value("form"))
        .andExpect(jsonPath("$.data.snapshot.defaultPages.detail.type").value("detail"))
        .andExpect(jsonPath("$.data.snapshot.metaVersion").value("sales:invoice:2"))
        .andExpect(jsonPath("$.data.snapshot.metaHash").isString());

    mockMvc.perform(post("/api/designer/object/preview")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-preview")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-preview"))
        .andExpect(jsonPath("$.data.object.code").value("invoice"))
        .andExpect(jsonPath("$.data.defaultPages.list.type").value("list"))
        .andExpect(jsonPath("$.data.metaHash").isString());

    mockMvc.perform(post("/api/designer/object/del")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-del")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "revision": 2
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-del"))
        .andExpect(jsonPath("$.data.deleted").value(true));
  }

  @Test
  void shouldValidateDesignerDraftAndHideInternalDetails() throws Exception {
    mockMvc.perform(post("/api/designer/object/add")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-invalid-1")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "",
                  "name": "",
                  "fields": [
                    {"code": "dup", "name": "重复1", "type": "text", "required": true},
                    {"code": "dup", "name": "重复2", "type": "unknown", "required": false}
                  ]
                }
                """))
        .andExpect(status().isUnprocessableEntity())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-invalid-1"))
        .andExpect(jsonPath("$.message").value("设计态草稿校验失败"))
        .andExpect(jsonPath("$.data.valid").value(false))
        .andExpect(jsonPath("$.data.errors.length()").value(4))
        .andExpect(jsonPath("$.data.errors[0].field").exists())
        .andExpect(jsonPath("$.data.errors[0].message").exists())
        .andExpect(jsonPath("$.stackTrace").doesNotExist())
        .andExpect(jsonPath("$.exception").doesNotExist());

    mockMvc.perform(post("/api/designer/object/add")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-invalid-2")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "name": "销售单",
                  "fields": [
                    {"code": "amount", "name": "金额", "type": "number", "required": true}
                  ]
                }
                """))
        .andExpect(status().isOk());

    mockMvc.perform(post("/api/designer/object/update")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-designer-invalid-3")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "name": "销售单",
                  "revision": 99,
                  "fields": [
                    {"code": "amount", "name": "金额", "type": "number", "required": true}
                  ]
                }
                """))
        .andExpect(status().isConflict())
        .andExpect(jsonPath("$.code").value("LC-META-4090"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-invalid-3"))
        .andExpect(jsonPath("$.message").value("设计态草稿版本冲突"));
  }

  @Test
  void shouldRejectUnsignedDesignerRequests() throws Exception {
    mockMvc.perform(post("/api/designer/object/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "9")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "designer-1")
            .header("X-Trace-Id", "trace-designer-unsigned")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "name": "销售单",
                  "fields": []
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("网关签名无效"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-unsigned"));
  }

  @Test
  void shouldRejectTamperedDesignerGatewayHeaders() throws Exception {
    mockMvc.perform(post("/api/designer/object/add")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Workspace-Id", "71")
            .header("X-Trace-Id", "trace-designer-tampered-workspace")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "name": "销售单",
                  "fields": []
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("网关签名无效"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-tampered-workspace"));

    mockMvc.perform(post("/api/designer/object/list")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Role-Codes", "admin")
            .header("X-Trace-Id", "trace-designer-tampered-role")
            .content("""
                {
                  "appCode": "sales"
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("网关签名无效"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-tampered-role"));
  }

  @Test
  void shouldRejectDesignerRequestsMissingSignedContextHeaders() throws Exception {
    mockMvc.perform(post("/api/designer/object/add")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignatureWithoutWorkspace())
            .header("X-Trace-Id", "trace-designer-missing-workspace")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice",
                  "name": "销售单",
                  "fields": []
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("工作区不能为空"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-missing-workspace"));

    mockMvc.perform(post("/api/designer/object/get")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignatureWithoutUser())
            .header("X-Trace-Id", "trace-designer-missing-user")
            .content("""
                {
                  "appCode": "sales",
                  "objectCode": "invoice"
                }
                """))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("LC-COMM-0400"))
        .andExpect(jsonPath("$.message").value("用户不能为空"))
        .andExpect(jsonPath("$.traceId").value("trace-designer-missing-user"));
  }

  private static RequestPostProcessor gatewaySignature() {
    return request -> {
      String timestamp = String.valueOf(System.currentTimeMillis());
      request.addHeader("X-Tenant-Id", "9");
      request.addHeader("X-Workspace-Id", "70");
      request.addHeader("X-User-Lid", "designer-1");
      request.addHeader("X-Role-Codes", "designer");
      request.addHeader("X-Meta-Hash", "mh-1");
      request.addHeader("X-Gateway-Timestamp", timestamp);
      request.addHeader("X-Gateway-Signature", hmac(canonicalPayload(request, timestamp)));
      return request;
    };
  }

  private static RequestPostProcessor gatewaySignatureWithoutWorkspace() {
    return request -> {
      String timestamp = String.valueOf(System.currentTimeMillis());
      request.addHeader("X-Tenant-Id", "9");
      request.addHeader("X-User-Lid", "designer-1");
      request.addHeader("X-Role-Codes", "designer");
      request.addHeader("X-Meta-Hash", "mh-1");
      request.addHeader("X-Gateway-Timestamp", timestamp);
      request.addHeader("X-Gateway-Signature", hmac(canonicalPayload(request, timestamp)));
      return request;
    };
  }

  private static RequestPostProcessor gatewaySignatureWithoutUser() {
    return request -> {
      String timestamp = String.valueOf(System.currentTimeMillis());
      request.addHeader("X-Tenant-Id", "9");
      request.addHeader("X-Workspace-Id", "70");
      request.addHeader("X-Role-Codes", "designer");
      request.addHeader("X-Meta-Hash", "mh-1");
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
        header(request, "X-Meta-Hash"));
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
