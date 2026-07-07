package com.lowcode.app;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(properties = "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration")
@AutoConfigureMockMvc
class DesignerObjectControllerTest {

  @Autowired private MockMvc mockMvc;

  @Test
  void shouldExposeDesignerDraftLifecycleWithUnifiedResultAndTraceId() throws Exception {
    mockMvc.perform(post("/api/designer/object/add")
            .contentType(MediaType.APPLICATION_JSON)
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
            .header("X-Tenant-Id", "9")
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
}
