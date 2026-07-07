/**
 * M2 Model Builder 纯函数契约。
 *
 * 这些函数先固定建模、影响分析、权限模拟和发布快照语义，后续 UI 可以直接调用，避免设计器只保存配置却无法发布校验。
 */
import type { PageType, RuntimePageSchema } from "@lowcode/shared";

export interface BuilderField {
  code: string;
  name: string;
  fieldType: string;
  sortNo: number;
  targetObjectCode?: string;
}

export interface BuilderObject {
  code: string;
  name: string;
  fields: BuilderField[];
}

export type SessionPageType = PageType;

export interface SessionPageSchema extends RuntimePageSchema {
  objectCode: string;
}

export interface ModelingSession {
  appCode: string;
  objects: Record<string, BuilderObject>;
  pages: Record<string, SessionPageSchema>;
}

export interface ImpactReference {
  type: string;
  code: string;
  fieldCodes: string[];
}

export function createFieldGridModel(fields: BuilderField[]) {
  return {
    fields: [...fields].sort((left, right) => left.sortNo - right.sortNo)
  };
}

export function createModelingSession(appCode: string): ModelingSession {
  return {
    appCode,
    objects: {},
    pages: {}
  };
}

export function createSessionObject(
  session: ModelingSession,
  object: { code: string; name: string }
): ModelingSession {
  return {
    ...session,
    objects: {
      ...session.objects,
      [object.code]: {
        ...object,
        fields: session.objects[object.code]?.fields ?? []
      }
    }
  };
}

export function addSessionField(
  session: ModelingSession,
  objectCode: string,
  field: Omit<BuilderField, "sortNo"> & Partial<Pick<BuilderField, "sortNo">>
): ModelingSession {
  const object = requireSessionObject(session, objectCode);
  const sortNo = field.sortNo ?? object.fields.length + 1;
  const fields = createFieldGridModel([...object.fields, { ...field, sortNo }]).fields;
  return replaceSessionObject(session, { ...object, fields });
}

export function updateSessionField(
  session: ModelingSession,
  objectCode: string,
  fieldCode: string,
  patch: Partial<Omit<BuilderField, "code">>
): ModelingSession {
  const object = requireSessionObject(session, objectCode);
  return replaceSessionObject(session, {
    ...object,
    fields: object.fields.map((field) => field.code === fieldCode ? { ...field, ...patch } : field)
  });
}

export function deleteSessionField(session: ModelingSession, objectCode: string, fieldCode: string): ModelingSession {
  const object = requireSessionObject(session, objectCode);
  return replaceSessionObject(session, {
    ...object,
    fields: normalizeFieldOrder(object.fields.filter((field) => field.code !== fieldCode))
  });
}

export function reorderSessionFields(session: ModelingSession, objectCode: string, fieldCodes: string[]): ModelingSession {
  const object = requireSessionObject(session, objectCode);
  const byCode = new Map(object.fields.map((field) => [field.code, field]));
  const ordered = fieldCodes.flatMap((fieldCode) => {
    const field = byCode.get(fieldCode);
    return field ? [field] : [];
  });
  const orderedCodes = new Set(ordered.map((field) => field.code));
  const missing = object.fields.filter((field) => !orderedCodes.has(field.code));
  return replaceSessionObject(session, {
    ...object,
    fields: normalizeFieldOrder([...ordered, ...missing])
  });
}

export function generateDefaultSessionPages(
  session: ModelingSession,
  objectCode: string
): Record<SessionPageType, SessionPageSchema> {
  const object = requireSessionObject(session, objectCode);
  const fields = createFieldGridModel(object.fields).fields.map((field) => field.code);
  return {
    list: createSessionPageSchema(objectCode, "list", fields),
    form: createSessionPageSchema(objectCode, "form", fields),
    detail: createSessionPageSchema(objectCode, "detail", fields)
  };
}

export function publishSessionSnapshot(session: ModelingSession, version: string) {
  const snapshot = {
    objects: session.objects,
    pages: session.pages
  };
  return {
    version,
    appCode: session.appCode,
    metaHash: `mh-${hashStableJson(snapshot)}`,
    snapshot
  };
}

export function buildRelationFromLinkField(field: BuilderField) {
  if (field.fieldType !== "link" || !field.targetObjectCode) {
    throw new Error("只有 link 字段可以自动生成关系");
  }
  return {
    sourceFieldCode: field.code,
    targetObjectCode: field.targetObjectCode,
    relationType: "many_to_one"
  };
}

export function analyzeFieldDeleteImpact(fieldCode: string, references: ImpactReference[]) {
  return references
    .filter((reference) => reference.fieldCodes.includes(fieldCode))
    .map((reference) => ({ type: reference.type, code: reference.code }));
}

export function simulateAccess(input: {
  roleCode: string;
  dataScope: "self" | "all";
  ownerUserLid: string;
  currentUserLid: string;
}) {
  if (input.dataScope === "all") {
    return { allowed: true, reason: "ALL 数据范围允许访问" };
  }
  return {
    allowed: input.ownerUserLid === input.currentUserLid,
    reason: input.ownerUserLid === input.currentUserLid ? "SELF 数据范围匹配" : "SELF 数据范围不匹配"
  };
}

export function publishPageSnapshot(version: string, snapshot: { pageCode: string; fields: string[] }) {
  return {
    version,
    snapshot
  };
}

export function runNoCodeOrderApprovalScenario() {
  const customer = createFieldGridModel([
    { code: "name", name: "客户名称", fieldType: "text", sortNo: 1 },
    { code: "level", name: "客户等级", fieldType: "select", sortNo: 2 }
  ]);
  const order = createFieldGridModel([
    { code: "customer", name: "客户", fieldType: "link", targetObjectCode: "customer", sortNo: 1 },
    { code: "amount", name: "金额", fieldType: "currency", sortNo: 2 },
    { code: "approval_comment", name: "审批意见", fieldType: "text", sortNo: 3 }
  ]);
  const orderItem = createFieldGridModel([
    { code: "product_name", name: "商品", fieldType: "text", sortNo: 1 },
    { code: "qty", name: "数量", fieldType: "decimal", sortNo: 2 }
  ]);
  const relation = buildRelationFromLinkField(order.fields[0]);
  const access = simulateAccess({
    roleCode: "manager",
    dataScope: "all",
    ownerUserLid: "sales-1",
    currentUserLid: "manager-1"
  });
  const published = publishPageSnapshot("v1", {
    pageCode: "order_form",
    fields: order.fields.map((field) => field.code)
  });

  return {
    objects: customer.fields.length > 0 && order.fields.length > 0 && orderItem.fields.length > 0
      ? ["customer", "order", "order_item"]
      : [],
    pages: ["customer_list", "order_form", "order_detail"],
    publishVersion: published.version,
    approvalReady: relation.targetObjectCode === "customer" && order.fields.some((field) => field.code === "approval_comment"),
    accessSimulationAllowed: access.allowed
  };
}

function createSessionPageSchema(objectCode: string, pageType: SessionPageType, fields: string[]): SessionPageSchema {
  return {
    pageCode: `${objectCode}_${pageType}`,
    pageType,
    objectCode,
    fields
  };
}

function normalizeFieldOrder(fields: BuilderField[]): BuilderField[] {
  return fields.map((field, index) => ({ ...field, sortNo: index + 1 }));
}

function replaceSessionObject(session: ModelingSession, object: BuilderObject): ModelingSession {
  return {
    ...session,
    objects: {
      ...session.objects,
      [object.code]: object
    }
  };
}

function requireSessionObject(session: ModelingSession, objectCode: string): BuilderObject {
  const object = session.objects[objectCode];
  if (!object) {
    throw new Error(`对象 ${objectCode} 不存在`);
  }
  return object;
}

function hashStableJson(value: unknown): number {
  const json = JSON.stringify(sortKeys(value));
  let hash = 2166136261;
  for (let index = 0; index < json.length; index += 1) {
    hash ^= json.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

function sortKeys(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(sortKeys);
  }
  if (value && typeof value === "object") {
    return Object.keys(value)
      .sort()
      .reduce<Record<string, unknown>>((result, key) => {
        result[key] = sortKeys((value as Record<string, unknown>)[key]);
        return result;
      }, {});
  }
  return value;
}
