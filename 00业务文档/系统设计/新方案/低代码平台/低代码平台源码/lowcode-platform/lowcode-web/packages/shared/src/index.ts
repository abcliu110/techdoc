/**
 * Shared frontend contracts.
 *
 * T-001 intentionally exposes only stable shell types. Real renderer components, generated API types,
 * and field implementations are added in later milestones after the backend metamodel contracts exist.
 */

export const PAGE_TYPES = ["list", "form", "detail"] as const;
export type PageType = typeof PAGE_TYPES[number];

export const FIELD_PERMISSIONS = ["NONE", "READ", "WRITE", "MASKED"] as const;
export type FieldPermission = typeof FIELD_PERMISSIONS[number];
export type FieldPermissionMap = Record<string, FieldPermission>;

export type RuntimeRecord = Record<string, unknown>;

export interface PageSchema {
  fields: string[];
  fieldPermissions?: FieldPermissionMap;
  accessView?: FieldPermissionMap;
}

export interface RuntimePageSchema extends PageSchema {
  pageCode: string;
  pageType: PageType;
}

export type SchemaProps = Record<string, unknown>;

export interface RenderableSchemaNode {
  componentType: string;
  fieldCode?: string;
  props: SchemaProps;
}

export interface FieldValidationIssue {
  message: string;
  code?: string;
}

export interface FieldRuntimeContext<TOptions = unknown> {
  options: TOptions;
  record: RuntimeRecord;
}

export type FieldViewComponentId = string;
export type FieldEditComponentId = string;

/**
 * Request envelope used by future designer/runtime clients.
 *
 * The meta version travels with the payload so later write APIs can reject stale designer views.
 */
export interface RequestEnvelope<TPayload> {
  payload: TPayload;
  metaVersion: string;
  traceId: string;
}

/**
 * Minimal field component registry contract.
 *
 * M2 will replace the string placeholders with component references. T-001 keeps the shape visible
 * without pretending the renderer exists.
 */
export interface FieldComponentContract<
  TValue = unknown,
  TOptions = unknown,
  TValidationIssue = FieldValidationIssue
> {
  fieldType: string;
  view: FieldViewComponentId;
  edit: FieldEditComponentId;
  validate?: (value: TValue, context: FieldRuntimeContext<TOptions>) => TValidationIssue[];
  normalize?: (value: unknown, context: FieldRuntimeContext<TOptions>) => TValue | null;
}

export function createRequestEnvelope<TPayload>(
  payload: TPayload,
  metaVersion: string,
  traceId: string
): RequestEnvelope<TPayload> {
  return {
    payload,
    metaVersion,
    traceId
  };
}

const ALLOWED_SCHEMA_PROPS: Record<string, Set<string>> = {
  field: new Set(["label", "placeholder", "helpText", "required", "disabled", "readonly", "width"]),
  link: new Set(["title", "target", "rel"]),
  iframe: new Set(["title"]),
  text: new Set(["text", "variant", "align"]),
  section: new Set(["title", "collapsible", "defaultCollapsed"])
};

const BLOCKED_SCHEMA_PROPS = new Set(["dangerouslySetInnerHTML", "srcdoc"]);

export function sanitizeSchemaProps(componentType: string, props: SchemaProps): SchemaProps {
  const allowed = ALLOWED_SCHEMA_PROPS[componentType] ?? new Set<string>();
  return Object.entries(props).reduce<SchemaProps>((safeProps, [key, value]) => {
    if (!allowed.has(key) || BLOCKED_SCHEMA_PROPS.has(key) || key.toLowerCase().startsWith("on")) {
      return safeProps;
    }
    if (!isSafeSchemaPropValue(key, value)) {
      return safeProps;
    }
    safeProps[key] = value;
    return safeProps;
  }, {});
}

function isSafeSchemaPropValue(key: string, value: unknown): boolean {
  if (key === "style") {
    return false;
  }
  if (typeof value !== "string") {
    return true;
  }
  const normalized = value.trim().toLowerCase();
  return !normalized.startsWith("javascript:") && !normalized.includes("javascript:");
}
