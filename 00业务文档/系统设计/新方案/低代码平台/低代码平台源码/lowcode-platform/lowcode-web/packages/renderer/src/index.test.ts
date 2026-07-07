import { describe, expect, it } from "vitest";
import { sanitizeSchemaProps as sanitizeSharedSchemaProps } from "@lowcode/shared";
import {
  buildSubmitPayload,
  createDefaultDetailPage,
  createDefaultFormPage,
  createDefaultListPage,
  createRenderableSchemaNode,
  createRuntimePageViewModel,
  defaultFieldRegistry,
  escapeCsvCell,
  filterSavedViewFields,
  renderFieldValue,
  sanitizeSchemaProps,
  sanitizeRichText,
  validatePageSchema,
  type FieldPermission
} from "./index";

describe("renderer M2 contracts", () => {
  it("registers all 22 built-in field components", () => {
    expect(defaultFieldRegistry().fieldTypes()).toEqual([
      "text",
      "textarea",
      "rich_text",
      "integer",
      "decimal",
      "currency",
      "percent",
      "select",
      "multi_select",
      "boolean",
      "date",
      "datetime",
      "time",
      "user",
      "department",
      "org",
      "link",
      "multi_link",
      "table",
      "attachment",
      "image",
      "formula"
    ]);
  });

  it("renders field value according to field permission", () => {
    const permissions: Record<string, FieldPermission> = {
      hidden: "NONE",
      masked: "MASKED",
      readonly: "READ",
      writable: "WRITE"
    };

    expect(renderFieldValue("hidden", "secret", permissions)).toBeUndefined();
    expect(renderFieldValue("masked", "secret", permissions)).toBe("***");
    expect(renderFieldValue("readonly", "visible", permissions)).toBe("visible");
    expect(renderFieldValue("writable", "editable", permissions)).toBe("editable");
  });

  it("sanitizes rich text and keeps request meta hash on submit", () => {
    expect(sanitizeRichText('<img src=x onerror="alert(1)"><script>alert(2)</script><b>ok</b>'))
      .not.toContain("script");
    expect(sanitizeRichText('<img src=x onerror="alert(1)">')).not.toContain("onerror");

    expect(buildSubmitPayload({ amount: 1 }, "mh-1")).toEqual({
      requestMetaHash: "mh-1",
      values: { amount: 1 }
    });
  });

  it("filters schema props through component allowlists and blocks executable values", () => {
    expect(sanitizeSchemaProps("field", {
      label: "备注",
      placeholder: "请输入",
      onClick: "alert(1)",
      onfocus: "alert(1)",
      dangerouslySetInnerHTML: { __html: "<script>alert(1)</script>" },
      style: "background:url(javascript:alert(1))",
      disabled: true
    })).toEqual({
      label: "备注",
      placeholder: "请输入",
      disabled: true
    });

    expect(sanitizeSchemaProps("link", {
      href: "javascript:alert(1)",
      target: "_blank",
      title: "详情",
      rel: "noopener noreferrer",
      style: { color: "red" }
    })).toEqual({
      target: "_blank",
      title: "详情",
      rel: "noopener noreferrer"
    });

    expect(sanitizeSchemaProps("iframe", {
      src: "https://example.com/help",
      srcdoc: "<script>alert(1)</script>",
      title: "帮助",
      onLoad: "alert(1)"
    })).toEqual({
      title: "帮助"
    });
  });

  it("reuses shared schema prop sanitization as the single safety boundary", () => {
    expect(sanitizeSchemaProps).toBe(sanitizeSharedSchemaProps);
  });

  it("drops all props for unknown components instead of passing through unreviewed schema props", () => {
    expect(sanitizeSchemaProps("unknown-widget", {
      label: "备注",
      "data-testid": "note",
      onClick: "alert(1)"
    })).toEqual({});
  });

  it("creates renderable schema nodes with sanitized props as the only boundary", () => {
    expect(createRenderableSchemaNode({
      componentType: "field",
      fieldCode: "remark",
      props: {
        label: "备注",
        placeholder: "请输入",
        onClick: "alert(1)",
        dangerouslySetInnerHTML: { __html: "<script>alert(1)</script>" },
        style: "background:url(javascript:alert(1))"
      }
    })).toEqual({
      componentType: "field",
      fieldCode: "remark",
      props: {
        label: "备注",
        placeholder: "请输入"
      }
    });
  });

  it("generates default pages and blocks page schema that references unknown fields", () => {
    const object = {
      objectCode: "order",
      fields: [
        { code: "amount", fieldType: "currency", inList: true, required: true },
        { code: "remark", fieldType: "text", inList: false }
      ]
    };

    expect(createDefaultListPage(object).fields).toEqual(["amount"]);
    expect(createDefaultFormPage(object).fields).toEqual(["amount", "remark"]);
    expect(createDefaultDetailPage(object).auditEntry).toBe(true);
    expect(validatePageSchema(object, { fields: ["amount"] }).valid).toBe(true);
    expect(validatePageSchema(object, { fields: ["missing"] }).errors).toContain("字段 missing 不存在");
  });

  it("blocks hidden required fields readonly override and csv formula injection", () => {
    const object = {
      objectCode: "order",
      fields: [
        { code: "amount", fieldType: "currency", inList: true, required: true },
        { code: "remark", fieldType: "text", inList: true }
      ]
    };

    expect(validatePageSchema(object, {
      fields: ["remark"],
      fieldPermissions: { amount: "NONE", remark: "WRITE" }
    }).errors).toContain("必填字段 amount 不能被页面隐藏");

    expect(validatePageSchema(object, {
      fields: ["amount", "remark"],
      fieldPermissions: { amount: "WRITE" },
      accessView: { amount: "READ" }
    }).errors).toContain("页面不能把字段 amount 从 READ 放宽到 WRITE");

    expect(escapeCsvCell("=cmd|calc")).toBe("'=cmd|calc");
    expect(escapeCsvCell("+SUM(A1:A2)")).toBe("'+SUM(A1:A2)");
    expect(filterSavedViewFields(["amount", "secret"], { amount: "READ", secret: "NONE" })).toEqual(["amount"]);
  });

  it("根据页面 schema meta 和记录生成列表表单详情 view model 并保持权限裁剪一致", () => {
    const meta = {
      objectCode: "customer",
      requestMetaHash: "mh-1",
      fields: [
        { code: "name", name: "客户名称", fieldType: "text" },
        { code: "secret", name: "密级", fieldType: "text" },
        { code: "owner", name: "负责人", fieldType: "user" }
      ],
      permissions: {
        name: "WRITE",
        secret: "NONE",
        owner: "MASKED"
      } satisfies Record<string, FieldPermission>
    };
    const schema = {
      pageCode: "customer_form",
      pageType: "form" as const,
      fields: ["name", "secret", "owner"]
    };
    const record = { name: "张三", secret: "S1", owner: "u1" };

    const form = createRuntimePageViewModel({
      pageSchema: schema,
      meta,
      pageSchemaVersion: "page-schema-v1",
      requestId: "trace-form-1",
      record
    });
    const detail = createRuntimePageViewModel({
      pageSchema: { ...schema, pageType: "detail" },
      meta,
      pageSchemaVersion: "page-schema-v1",
      requestId: "trace-detail-1",
      record
    });
    const list = createRuntimePageViewModel({
      pageSchema: { ...schema, pageType: "list" },
      meta,
      pageSchemaVersion: "page-schema-v1",
      requestId: "trace-list-1",
      records: [record]
    });

    expect(form.fields).toEqual([
      { code: "name", label: "客户名称", fieldType: "text", permission: "WRITE", value: "张三", editable: true },
      { code: "owner", label: "负责人", fieldType: "user", permission: "MASKED", value: "***", editable: false }
    ]);
    expect(form.requestId).toBe("trace-form-1");
    expect(form.pageSchemaVersion).toBe("page-schema-v1");
    expect(detail.fields).toEqual([
      { code: "name", label: "客户名称", fieldType: "text", permission: "WRITE", value: "张三", editable: false },
      { code: "owner", label: "负责人", fieldType: "user", permission: "MASKED", value: "***", editable: false }
    ]);
    expect(list.rows).toEqual([{ name: "张三", owner: "***" }]);
    expect(form.submit({ name: "李四", secret: "S2", owner: "u2" })).toEqual({
      requestMetaHash: "mh-1",
      values: { name: "李四" }
    });
  });
});
