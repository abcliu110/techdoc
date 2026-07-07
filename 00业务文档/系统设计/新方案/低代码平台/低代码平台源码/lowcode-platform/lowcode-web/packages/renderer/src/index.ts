/**
 * M2 Renderer 字段组件与页面 schema 契约。
 *
 * 这里先实现不依赖 React 的纯函数核心：字段注册、权限裁剪、富文本安全清洗、默认页面生成和提交 metaHash。
 * 后续真实组件可以复用这些契约，避免 UI 和运行态权限语义分叉。
 */
import {
  sanitizeSchemaProps,
  type FieldPermission,
  type FieldPermissionMap,
  type PageSchema,
  type RenderableSchemaNode,
  type RuntimePageSchema,
  type RuntimeRecord,
  type SchemaProps
} from "@lowcode/shared";

export { sanitizeSchemaProps };
export type {
  FieldPermission,
  FieldPermissionMap,
  PageSchema,
  RenderableSchemaNode,
  RuntimePageSchema,
  RuntimeRecord,
  SchemaProps
};

export interface ObjectField {
  code: string;
  name?: string;
  fieldType: string;
  inList?: boolean;
  required?: boolean;
}

export interface ObjectSchema {
  objectCode: string;
  fields: ObjectField[];
}

export interface RuntimeMeta extends ObjectSchema {
  requestMetaHash: string;
  permissions: FieldPermissionMap;
}

export interface RuntimeFieldViewModel {
  code: string;
  label: string;
  fieldType: string;
  permission: FieldPermission;
  value: unknown;
  editable: boolean;
}

export interface RuntimePageViewModel {
  pageCode: string;
  pageType: RuntimePageSchema["pageType"];
  pageSchemaVersion: string;
  requestId: string;
  fields: RuntimeFieldViewModel[];
  rows: RuntimeRecord[];
  submit: (values: RuntimeRecord) => ReturnType<typeof buildSubmitPayload>;
}

const BUILT_IN_FIELD_TYPES = [
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
] as const;

export function defaultFieldRegistry() {
  return {
    fieldTypes: () => [...BUILT_IN_FIELD_TYPES]
  };
}

export function renderFieldValue(
  fieldCode: string,
  value: unknown,
  permissions: FieldPermissionMap
): unknown {
  const permission = permissions[fieldCode] ?? "NONE";
  if (permission === "NONE") {
    return undefined;
  }
  if (permission === "MASKED") {
    return "***";
  }
  return value;
}

export function sanitizeRichText(input: string): string {
  return input
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/\son[a-z]+="[^"]*"/gi, "")
    .replace(/\son[a-z]+='[^']*'/gi, "")
    .replace(/\sjavascript:/gi, "");
}

export function createRenderableSchemaNode(input: {
  componentType: string;
  fieldCode?: string;
  props?: SchemaProps;
}): RenderableSchemaNode {
  return {
    componentType: input.componentType,
    fieldCode: input.fieldCode,
    props: sanitizeSchemaProps(input.componentType, input.props ?? {})
  };
}

export function buildSubmitPayload(values: Record<string, unknown>, requestMetaHash: string) {
  return {
    requestMetaHash,
    values
  };
}

export function createRuntimePageViewModel(input: {
  pageSchema: RuntimePageSchema;
  meta: RuntimeMeta;
  pageSchemaVersion: string;
  requestId: string;
  record?: RuntimeRecord;
  records?: RuntimeRecord[];
}): RuntimePageViewModel {
  const allowedFields = resolveAllowedFields(input.pageSchema, input.meta);
  return {
    pageCode: input.pageSchema.pageCode,
    pageType: input.pageSchema.pageType,
    pageSchemaVersion: input.pageSchemaVersion,
    requestId: input.requestId,
    fields: input.pageSchema.pageType === "list"
      ? []
      : allowedFields.map((field) => createFieldViewModel(field, input.meta, input.record ?? {}, input.pageSchema.pageType)),
    rows: input.pageSchema.pageType === "list"
      ? (input.records ?? []).map((record) => createListRow(allowedFields, input.meta.permissions, record))
      : [],
    submit: (values) => buildSubmitPayload(selectWritableValues(values, allowedFields, input.meta.permissions), input.meta.requestMetaHash)
  };
}

export function createDefaultListPage(object: ObjectSchema): PageSchema {
  return {
    fields: object.fields.filter((field) => field.inList).map((field) => field.code)
  };
}

export function createDefaultFormPage(object: ObjectSchema): PageSchema {
  return {
    fields: object.fields.map((field) => field.code)
  };
}

export function createDefaultDetailPage(object: ObjectSchema): PageSchema & { auditEntry: boolean } {
  return {
    fields: object.fields.map((field) => field.code),
    auditEntry: true
  };
}

export function validatePageSchema(object: ObjectSchema, schema: PageSchema): { valid: boolean; errors: string[] } {
  const fieldCodes = new Set(object.fields.map((field) => field.code));
  const errors = schema.fields
    .filter((fieldCode) => !fieldCodes.has(fieldCode))
    .map((fieldCode) => `字段 ${fieldCode} 不存在`);
  for (const field of object.fields) {
    const pagePermission = schema.fieldPermissions?.[field.code];
    if (field.required && (!schema.fields.includes(field.code) || pagePermission === "NONE")) {
      errors.push(`必填字段 ${field.code} 不能被页面隐藏`);
    }
    const accessPermission = schema.accessView?.[field.code];
    if (accessPermission && pagePermission && permissionRank(pagePermission) > permissionRank(accessPermission)) {
      errors.push(`页面不能把字段 ${field.code} 从 ${accessPermission} 放宽到 ${pagePermission}`);
    }
  }
  return {
    valid: errors.length === 0,
    errors
  };
}

export function escapeCsvCell(value: unknown): string {
  const text = String(value ?? "");
  return /^[=+\-@]/.test(text) ? `'${text}` : text;
}

export function filterSavedViewFields(fields: string[], permissions: FieldPermissionMap): string[] {
  return fields.filter((field) => (permissions[field] ?? "NONE") !== "NONE");
}

function permissionRank(permission: FieldPermission): number {
  return {
    NONE: 0,
    MASKED: 1,
    READ: 2,
    WRITE: 3
  }[permission];
}

function resolveAllowedFields(schema: RuntimePageSchema, meta: RuntimeMeta): ObjectField[] {
  const fieldsByCode = new Map(meta.fields.map((field) => [field.code, field]));
  return schema.fields.flatMap((fieldCode) => {
    const field = fieldsByCode.get(fieldCode);
    if (!field || (meta.permissions[fieldCode] ?? "NONE") === "NONE") {
      return [];
    }
    return [field];
  });
}

function createFieldViewModel(
  field: ObjectField,
  meta: RuntimeMeta,
  record: RuntimeRecord,
  pageType: RuntimePageSchema["pageType"]
): RuntimeFieldViewModel {
  const permission = meta.permissions[field.code] ?? "NONE";
  return {
    code: field.code,
    label: field.name ?? field.code,
    fieldType: field.fieldType,
    permission,
    value: renderFieldValue(field.code, record[field.code], meta.permissions),
    editable: pageType === "form" && permission === "WRITE"
  };
}

function createListRow(
  fields: ObjectField[],
  permissions: FieldPermissionMap,
  record: RuntimeRecord
): RuntimeRecord {
  return fields.reduce<RuntimeRecord>((row, field) => {
    row[field.code] = renderFieldValue(field.code, record[field.code], permissions);
    return row;
  }, {});
}

function selectWritableValues(
  values: RuntimeRecord,
  fields: ObjectField[],
  permissions: FieldPermissionMap
): RuntimeRecord {
  const writableFields = new Set(fields.filter((field) => permissions[field.code] === "WRITE").map((field) => field.code));
  return Object.keys(values).reduce<RuntimeRecord>((selected, key) => {
    if (writableFields.has(key)) {
      selected[key] = values[key];
    }
    return selected;
  }, {});
}
