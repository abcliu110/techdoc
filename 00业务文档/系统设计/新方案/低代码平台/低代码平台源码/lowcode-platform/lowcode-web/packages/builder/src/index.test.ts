import { describe, expect, it } from "vitest";
import {
  addSessionField,
  analyzeFieldDeleteImpact,
  buildRelationFromLinkField,
  createModelingSession,
  createSessionObject,
  createFieldGridModel,
  deleteSessionField,
  generateDefaultSessionPages,
  publishPageSnapshot,
  publishSessionSnapshot,
  reorderSessionFields,
  runNoCodeOrderApprovalScenario,
  simulateAccess,
  updateSessionField
} from "./index";

describe("builder M2 contracts", () => {
  it("supports field grid editing and relation auto build", () => {
    const grid = createFieldGridModel([
      { code: "amount", name: "金额", fieldType: "currency", sortNo: 2 },
      { code: "customer", name: "客户", fieldType: "link", targetObjectCode: "customer", sortNo: 1 }
    ]);

    expect(grid.fields.map((field) => field.code)).toEqual(["customer", "amount"]);
    expect(buildRelationFromLinkField(grid.fields[0])).toEqual({
      sourceFieldCode: "customer",
      targetObjectCode: "customer",
      relationType: "many_to_one"
    });
  });

  it("reports impact, simulates permissions and publishes page snapshot", () => {
    expect(analyzeFieldDeleteImpact("amount", [
      { type: "page", code: "order_form", fieldCodes: ["amount"] },
      { type: "rule", code: "approve_required", fieldCodes: ["approval_comment"] }
    ])).toEqual([{ type: "page", code: "order_form" }]);

    expect(simulateAccess({
      roleCode: "sales",
      dataScope: "self",
      ownerUserLid: "u1",
      currentUserLid: "u2"
    }).allowed).toBe(false);

    expect(publishPageSnapshot("v1", { pageCode: "order_form", fields: ["amount"] })).toEqual({
      version: "v1",
      snapshot: {
        pageCode: "order_form",
        fields: ["amount"]
      }
    });
  });

  it("runs customer order approval no-code scenario through model page and publish steps", () => {
    expect(runNoCodeOrderApprovalScenario()).toEqual({
      objects: ["customer", "order", "order_item"],
      pages: ["customer_list", "order_form", "order_detail"],
      publishVersion: "v1",
      approvalReady: true,
      accessSimulationAllowed: true
    });
  });

  it("维护应用建模会话中的对象字段并生成默认页面 schema", () => {
    const created = createSessionObject(createModelingSession("crm"), {
      code: "customer",
      name: "客户"
    });
    const withFields = addSessionField(addSessionField(created, "customer", {
      code: "name",
      name: "客户名称",
      fieldType: "text"
    }), "customer", {
      code: "level",
      name: "客户等级",
      fieldType: "select"
    });
    const updated = updateSessionField(withFields, "customer", "level", { name: "等级" });
    const reordered = reorderSessionFields(updated, "customer", ["level", "name"]);
    const deleted = deleteSessionField(reordered, "customer", "name");
    const pages = generateDefaultSessionPages(reordered, "customer");

    expect(reordered.objects.customer.fields.map((field) => [field.code, field.sortNo])).toEqual([
      ["level", 1],
      ["name", 2]
    ]);
    expect(deleted.objects.customer.fields.map((field) => field.code)).toEqual(["level"]);
    expect(pages.list).toEqual({
      pageCode: "customer_list",
      pageType: "list",
      objectCode: "customer",
      fields: ["level", "name"]
    });
    expect(pages.form.fields).toEqual(["level", "name"]);
    expect(pages.detail.fields).toEqual(["level", "name"]);
  });

  it("发布应用建模会话快照并生成稳定 metaHash", () => {
    const session = createSessionObject(createModelingSession("crm"), {
      code: "customer",
      name: "客户"
    });

    expect(publishSessionSnapshot(session, "v1")).toEqual({
      version: "v1",
      appCode: "crm",
      metaHash: "mh-3830001757",
      snapshot: {
        objects: {
          customer: {
            code: "customer",
            name: "客户",
            fields: []
          }
        },
        pages: {}
      }
    });
  });
});
