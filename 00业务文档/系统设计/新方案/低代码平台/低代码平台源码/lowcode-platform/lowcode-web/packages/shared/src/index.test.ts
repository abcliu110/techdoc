import { describe, expect, it } from "vitest";
import {
  FIELD_PERMISSIONS,
  PAGE_TYPES,
  createRequestEnvelope,
  sanitizeSchemaProps,
  type FieldComponentContract,
  type PageSchema,
  type RenderableSchemaNode,
  type RuntimePageSchema,
  type RuntimeRecord,
  type SchemaProps
} from "./index";

describe("shared contracts", () => {
  it("exports stable page types and field permissions", () => {
    expect(PAGE_TYPES).toEqual(["list", "form", "detail"]);
    expect(FIELD_PERMISSIONS).toEqual(["NONE", "READ", "WRITE", "MASKED"]);
  });

  it("createRequestEnvelope keeps payload and meta version together", () => {
    const envelope = createRequestEnvelope({ code: "customer" }, "v1", "trace-1");

    expect(envelope).toEqual({
      payload: { code: "customer" },
      metaVersion: "v1",
      traceId: "trace-1"
    });
  });

  it("exports stable runtime page schema and runtime record contracts", () => {
    const record: RuntimeRecord = {
      customerName: "华北样板客户",
      contractAmount: 1200.5
    };
    const pageSchema: PageSchema = {
      fields: ["customerName", "contractAmount"],
      fieldPermissions: {
        customerName: "READ",
        contractAmount: "WRITE"
      }
    };
    const runtimePageSchema: RuntimePageSchema = {
      ...pageSchema,
      pageCode: "customer_form",
      pageType: "form"
    };

    expect(record).toEqual({
      customerName: "华北样板客户",
      contractAmount: 1200.5
    });
    expect(runtimePageSchema).toEqual({
      pageCode: "customer_form",
      pageType: "form",
      fields: ["customerName", "contractAmount"],
      fieldPermissions: {
        customerName: "READ",
        contractAmount: "WRITE"
      }
    });
  });

  it("FieldComponentContract keeps stable field runtime hooks without requiring React", () => {
    const contract: FieldComponentContract<string, { maxLength: number }> = {
      fieldType: "text",
      view: "TextView",
      edit: "TextEdit",
      validate: (value, context) => value.length > context.options.maxLength ? [{ message: "too long" }] : [],
      normalize: (value) => typeof value === "string" ? value.trim() : null
    };

    expect(contract.fieldType).toBe("text");
    expect(contract.validate?.("abcdef", { options: { maxLength: 5 }, record: {} })).toEqual([{ message: "too long" }]);
    expect(contract.normalize?.("  ok  ", { options: { maxLength: 5 }, record: {} })).toBe("ok");
  });

  it("exports shared schema prop sanitization and schema node contracts for renderer reuse", () => {
    const props: SchemaProps = {
      label: "备注",
      placeholder: "请输入",
      onClick: "alert(1)",
      dangerouslySetInnerHTML: { __html: "<script>alert(1)</script>" },
      disabled: true
    };
    const node: RenderableSchemaNode = {
      componentType: "field",
      fieldCode: "remark",
      props: sanitizeSchemaProps("field", props)
    };

    expect(node).toEqual({
      componentType: "field",
      fieldCode: "remark",
      props: {
        label: "备注",
        placeholder: "请输入",
        disabled: true
      }
    });
    expect(sanitizeSchemaProps("unknown-widget", { label: "备注" })).toEqual({});
  });
});
