import {
  addSessionField,
  createModelingSession,
  createSessionObject,
  generateDefaultSessionPages,
  publishSessionSnapshot,
  updateSessionField,
  type BuilderField,
  type ModelingSession,
  type SessionPageSchema
} from "@lowcode/builder";
import {
  createRuntimePageViewModel,
  defaultFieldRegistry,
  escapeCsvCell,
  sanitizeRichText,
  validatePageSchema,
  type FieldPermission,
  type ObjectField,
  type RuntimeMeta,
  type RuntimePageSchema
} from "@lowcode/renderer";
import { createRequestEnvelope, type RequestEnvelope } from "@lowcode/shared";

export interface AppFieldTypeCapability {
  code: string;
  label: string;
  interactive: boolean;
}

export interface AppFieldRegistry {
  interactive: AppFieldTypeCapability[];
  placeholder: AppFieldTypeCapability[];
}

export interface CanvasComponentTemplate {
  code: string;
  label: string;
  fieldType: string;
  defaultLabel: string;
  typeLabel: string;
  required: boolean;
  inList: boolean;
  hidden: boolean;
  optionsText: string;
  codeHint?: string;
}

export interface DraftFieldDefinition {
  code: string;
  name: string;
  fieldType: string;
  required?: boolean;
  inList?: boolean;
  hidden?: boolean;
  options?: string[];
  placeholder?: string;
  helperText?: string;
  defaultValue?: string;
}

export interface FieldDraftInput {
  label: string;
  fieldType: string;
  required: boolean;
  inList: boolean;
  hidden: boolean;
  optionsText: string;
  codeHint?: string;
  placeholder?: string;
  helperText?: string;
  defaultValue?: string;
}

export interface PageLayoutConfig {
  columns: number;
  density: "compact" | "comfortable";
}

export type FormLayoutNodeKind =
  | "form"
  | "body"
  | "section"
  | "grid"
  | "field"
  | "action-bar"
  | "action";

export interface FormLayoutNode {
  id: string;
  kind: FormLayoutNodeKind;
  label: string;
  parentId?: string;
  fieldCode?: string;
  actionCode?: string;
  columns?: number;
  minColumns?: number;
  maxColumns?: number;
  span?: number;
  responsive?: "fixed" | "auto-fit";
  children?: FormLayoutNode[];
}

export interface DemoPageConfig {
  visibleFieldCodes: string[];
  layout: PageLayoutConfig;
  layoutTree: FormLayoutNode;
}

export type DesignerRuleConditionOperator = "required" | "equals" | "contains" | "notEquals" | "empty" | "notEmpty";

export type DesignerRuleActionType =
  | "show"
  | "hide"
  | "readonly"
  | "require"
  | "required"
  | "calculate"
  | "setValue"
  | "jump"
  | "notify"
  | "submit"
  | "submitAction";

export type DesignerRuleTargetType = "field" | "section" | "page" | "action" | "submit" | "notification";

export interface DesignerRuleCondition {
  fieldCode: string;
  operator: DesignerRuleConditionOperator;
  value?: unknown;
}

export interface DesignerRuleAction {
  type: DesignerRuleActionType;
  targetType: DesignerRuleTargetType;
  targetCode: string;
  value?: unknown;
  workflowActionCode?: string;
  workflowTransition?: {
    actionCode: string;
    from: string;
    to: string;
  };
  idempotencyKeyRequired?: boolean;
  sideEffectPolicy?: "none" | "outbox";
  effect?: "visible" | "hidden" | "readonly" | "required" | "value" | "jump" | "notify" | "workflow";
}

export interface DesignerRuleDefinition {
  code: string;
  name: string;
  resourceId: string;
  fieldCode?: string;
  operator?: "required" | "equals" | "contains";
  order?: number;
  enabled?: boolean;
  scope?: PageConfigName | "global";
  condition?: DesignerRuleCondition;
  actions?: DesignerRuleAction[];
  message: string;
}

export interface DesignerRuleDiagnostic {
  code: "rule-target-missing" | "rule-condition-field-missing" | "rule-conflict" | "hidden-without-permission";
  severity: ReadinessSeverity;
  ruleCode: string;
  targetCode: string;
  message: string;
  conditionKey?: string;
  involvedRuleCodes?: string[];
  priorityHint?: string;
  primaryAction?: string;
}

export interface DesignerFormRuleCenter {
  resourceId: string;
  scope: "global";
  ownerObjectCode: string;
  formDefinitionCode: string;
  versionMode: "draft-and-published-snapshot";
  publishGate: {
    validatesDanglingReference: boolean;
    validatesConflict: boolean;
    validatesPermissionBoundary: boolean;
  };
  rules: DesignerRuleDefinition[];
  diagnostics: DesignerRuleDiagnostic[];
  previewTest: {
    enabled: boolean;
    coversAllEnabledRules: boolean;
    sampleRecord: Record<string, unknown>;
  };
}

export interface DesignerFormTemplate {
  code: "create-form" | "edit-form" | "detail-form";
  name: string;
  pageType: PageConfigName;
  sourceTemplateCode?: DesignerFormTemplate["code"];
  reuseStrategy: "source" | "inherit-and-override" | "reference" | "copy-with-overrides";
  legacyReuseStrategy?: "inherit-and-override";
  templateVersion: number;
  overridePatch: Array<{
    op: "set-readonly";
    value: boolean;
  }>;
  readonly: boolean;
  layoutTree: FormLayoutNode;
}

export interface DesignerFormTemplateCatalog {
  resourceId: string;
  templates: DesignerFormTemplate[];
}

export interface DesignerSchemaJsonView {
  resourceId: string;
  schema: {
    fields: DraftFieldDefinition[];
    layout: DesignerLayoutBlueprint;
    rules: DesignerFormRuleCenter;
    permissions: DesignerPermissionMatrix;
    workflow: DesignerWorkflowBlueprint;
  };
}

export interface FormDesignerSurface {
  resourceId: string;
  tabs: Array<{
    code: "designer" | "preview" | "logic" | "json" | "theme" | "translation";
    label: string;
    enabled: boolean;
  }>;
  displayModes: Array<{
    code: "web" | "wizard" | "pdf";
    label: string;
  }>;
  toolbox: {
    categories: Array<{
      code: "basic" | "advanced" | "layout" | "data" | "action";
      label: string;
      components: Array<{
        code: string;
        label: string;
      }>;
    }>;
  };
  schemaProtocol: {
    jsonSchema: {
      type: "object";
      required: string[];
      properties: Record<string, {
        type: string;
        title: string;
      }>;
    };
    uiSchema: {
      type: "VerticalLayout";
      elements: Array<{
        type: "Control" | "Group";
        scope?: string;
        label?: string;
        elements?: Array<{
          type: "Control";
          scope: string;
        }>;
      }>;
    };
    data: Record<string, unknown>;
  };
  propertyGrid: {
    tabs: Array<{
      code: "property" | "style" | "validation" | "logic" | "action";
      label: string;
    }>;
  };
  outline: {
    nodes: Array<{
      id: string;
      kind: FormLayoutNodeKind;
      label: string;
    }>;
  };
  ioContract: {
    importJson: boolean;
    exportJson: boolean;
    exportSchema: boolean;
    versionedSnapshot: boolean;
  };
  formilyDesignable: {
    engine: "Designable";
    formCore: "Formily";
    schemaDialect: "JSON Schema + x-* 扩展";
    adapterPackages: string[];
    conversion: {
      jsonSchemaToFormily: boolean;
      formilyToJsonSchema: boolean;
      supportsJSchema: boolean;
    };
    reactions: Array<{
      type: "visible" | "required" | "value" | "disabled";
      sourceFieldCode: string;
      targetFieldCode: string;
    }>;
    workbenchPanels: Array<{
      code: "designer-canvas" | "component-tree" | "property-settings" | "history" | "schema-editor";
      label: string;
    }>;
    formilySchema: FormilySchemaObject;
    reactionDesigner: FormilyReactionDesigner;
    workbench: DesignableWorkbenchState;
  };
}

export interface FormilyReactionRule {
  source: string;
  target: string;
  when: string;
  fulfill: {
    state: Record<string, unknown>;
  };
  otherwise: {
    state: Record<string, unknown>;
  };
}

export interface FormilySchemaProperty {
  type: string;
  title: string;
  required?: boolean;
  enum?: string[];
  "x-decorator": "FormItem";
  "x-component": string;
  "x-component-props": Record<string, unknown>;
  "x-validator": Array<{
    required?: boolean;
    format?: string;
    message: string;
  }>;
  "x-reactions"?: Array<Omit<FormilyReactionRule, "source">>;
}

export interface FormilySchemaObject {
  type: "object";
  "x-component": "Form";
  "x-component-props": {
    labelCol: number;
    wrapperCol: number;
  };
  properties: Record<string, FormilySchemaProperty>;
}

export interface FormilyReactionDesigner {
  mode: "visual";
  rules: FormilyReactionRule[];
}

export interface DesignableWorkbenchState {
  selectedNodeId: string;
  selectedFieldCode: string;
  activePanel: "designer-canvas" | "component-tree" | "property-settings" | "history" | "schema-editor";
  history: {
    undoable: boolean;
    redoable: boolean;
  };
  schemaEditor: {
    editable: boolean;
    validatesBeforeImport: boolean;
  };
  dragSources: Array<{
    code: string;
    label: string;
  }>;
  propertyBindings: Array<{
    path: string;
    label: string;
  }>;
}

export type PageConfigName = "list" | "form" | "detail";

export type DesignerMode = "application" | "object" | "page" | "workflow" | "permission" | "integration";

export type DesignerWorkflowNodeKind = "start" | "approval" | "end";

export type DesignerPermissionCapability = "READ" | "WRITE" | "MASKED" | "NONE";

export interface DesignerLayoutField {
  code: string;
  label: string;
  fieldType: string;
  required: boolean;
  runtimeField: boolean;
}

export interface DesignerLayoutContainer {
  nodeId: string;
  parentId?: string;
  kind: FormLayoutNodeKind;
  label: string;
  columns?: number;
  minColumns?: number;
  maxColumns?: number;
  responsive?: FormLayoutNode["responsive"];
}

export interface DesignerFieldBinding {
  nodeId: string;
  fieldCode: string;
  sectionId?: string;
  label: string;
  fieldType: string;
  span: number;
}

export interface DesignerRuleBinding {
  nodeId: string;
  ruleCode: string;
  trigger: string;
}

export interface DesignerLayoutPage {
  pageType: PageConfigName;
  resourceId: string;
  title: string;
  columns: number;
  density: PageLayoutConfig["density"];
  nodeCount: number;
  fields: DesignerLayoutField[];
  containers: DesignerLayoutContainer[];
  fieldBindings: DesignerFieldBinding[];
  ruleBindings: DesignerRuleBinding[];
}

export interface DesignerLayoutBlueprint {
  resourceId: string;
  pages: DesignerLayoutPage[];
}

export interface DesignerWorkflowNode {
  code: string;
  name: string;
  kind: DesignerWorkflowNodeKind;
  assignee: string;
  terminal: boolean;
}

export interface DesignerWorkflowTransition {
  from: string;
  to: string;
  actionCode: string;
  actionName: string;
  idempotent: boolean;
  invokedByRuleCode?: string;
}

export interface DesignerWorkflowBlueprint {
  resourceId: string;
  name: string;
  publishReady: boolean;
  nodes: DesignerWorkflowNode[];
  transitions: DesignerWorkflowTransition[];
}

export interface DesignerPermissionRole {
  code: string;
  name: string;
  description: string;
}

export interface DesignerPermissionEntry {
  roleCode: string;
  resourceId: string;
  capability: DesignerPermissionCapability;
}

export interface DesignerFieldPermissionEntry {
  roleCode: string;
  fieldCode: string;
  permission: DesignerPermissionCapability;
}

export interface DesignerActionPermissionEntry {
  roleCode: string;
  actionCode: string;
  allowed: boolean;
}

export interface DesignerPermissionMatrix {
  resourceId: string;
  roles: DesignerPermissionRole[];
  entries: DesignerPermissionEntry[];
  fieldPermissions: DesignerFieldPermissionEntry[];
  actionPermissions: DesignerActionPermissionEntry[];
  publishReady: boolean;
}

export interface DesignerIntegrationChannel {
  code: "import" | "export" | "open-api" | "app-package";
  name: string;
  direction: "inbound" | "outbound" | "bidirectional";
  idempotent: boolean;
  securityPolicy: string;
}

export interface DesignerIntegrationContract {
  resourceId: string;
  channels: DesignerIntegrationChannel[];
  publishReady: boolean;
}

export type ReadinessSeverity = "pass" | "warning" | "blocking";

export type ReadinessStatus = "passed" | "needs-review" | "blocked";

export interface DesignerNavigationSection {
  code: "application" | "modeling" | "experience" | "automation" | "governance" | "integration";
  label: string;
  description: string;
}

export interface DesignerNavigationNode {
  id: string;
  sectionCode: DesignerNavigationSection["code"];
  label: string;
  resourceType: DesignerMode;
  active: boolean;
  status: "ready" | "draft" | "needs-review";
}

export interface DesignerNavigation {
  sections: DesignerNavigationSection[];
  nodes: DesignerNavigationNode[];
}

export interface DesignerReadinessItem {
  code: string;
  resourceId: string;
  label: string;
  severity: ReadinessSeverity;
  status: ReadinessStatus;
  message: string;
  fixHint: string;
  primaryAction: string;
  ownerPanel: DesignerMode;
}

export interface DesignerReadinessReport {
  summary: {
    total: number;
    passed: number;
    warning: number;
    blocking: number;
    publishable: boolean;
  };
  items: DesignerReadinessItem[];
}

export interface SelectedCanvasComponent {
  fieldCode: string;
  fieldName: string;
  pageType: PreviewMode;
  componentType: "form-field" | "list-column" | "detail-item";
  visible: boolean;
  sortIndex: number;
}

export interface DemoWorkbench {
  appCode: string;
  objectCode: string;
  version: string;
  session: ModelingSession;
  pages: Record<"list" | "form" | "detail", SessionPageSchema>;
  pageConfigs: Record<PageConfigName, DemoPageConfig>;
  rules: DesignerRuleDefinition[];
  recordSchema: DraftFieldDefinition[];
  previewRecord: Record<string, unknown>;
  selectedFieldCode: string;
  previewMode: PreviewMode;
  activeDesignerMode: DesignerMode;
  activeResourceId: string;
  statusTag: WorkbenchStatusTag;
  statusMessage: string;
  hasUnpublishedChanges: boolean;
  lastPublishedMetaHash?: string;
}

export interface ValidationIssue {
  field: string;
  message: string;
}

export interface ValidationResult {
  valid: boolean;
  errors: ValidationIssue[];
  sanitizedRecord?: Record<string, unknown>;
}

export interface PublishOptions {
  permissionPreset: "operator" | "viewer";
  traceId: string;
  idempotencyKey: string;
}

export interface PublishedWorkbench {
  publishRequest: RequestEnvelope<{
    idempotencyKey: string;
    metaHash: string;
    objectCode: string;
    permissionPreset: PublishOptions["permissionPreset"];
    pageSchemaVersion: string;
    pages: Record<PreviewMode, RuntimePageSchema>;
  }>;
  runtime: {
    list: ReturnType<typeof createRuntimePageViewModel>;
    form: ReturnType<typeof createRuntimePageViewModel>;
    detail: ReturnType<typeof createRuntimePageViewModel>;
  };
  previewError: {
    code: string;
    message: string;
    traceId: string;
  };
}

export type PreviewMode = "form" | "list" | "detail";
export const PAGE_SCHEMA_VERSION = "page-schema-v1";

export type WorkbenchStatusTag = "published" | "draft" | "saved";

export interface PreviewSnapshot {
  mode: PreviewMode;
  runtime: ReturnType<typeof createRuntimePageViewModel>;
  published: PublishedWorkbench;
}

export type WorkbenchAction =
  | { type: "add-field"; draft: FieldDraftInput }
  | { type: "drop-palette-field"; fieldType: string; targetIndex: number }
  | { type: "drop-existing-field"; sourceFieldCode: string; targetIndex: number }
  | { type: "select-field"; fieldCode: string }
  | { type: "set-preview-mode"; previewMode: PreviewMode }
  | { type: "select-resource"; resourceId: string }
  | { type: "update-selected-field"; patch: Partial<DraftFieldDefinition> }
  | { type: "update-page-config"; page: PageConfigName; patch: Partial<DemoPageConfig> }
  | { type: "delete-selected-field" }
  | { type: "move-selected-field"; direction: "up" | "down" }
  | { type: "save-draft" }
  | { type: "publish-success"; metaHash: string };

const INTERACTIVE_FIELD_TYPES = [
  { code: "text", label: "文本", interactive: true },
  { code: "decimal", label: "小数", interactive: true },
  { code: "date", label: "日期", interactive: true },
  { code: "select", label: "单选", interactive: true },
  { code: "checkbox", label: "勾选", interactive: true },
  { code: "link", label: "链接", interactive: true },
  { code: "richtext", label: "富文本", interactive: true },
  { code: "section", label: "分组", interactive: true },
  { code: "columns", label: "分栏", interactive: true },
  { code: "note", label: "说明文本", interactive: true }
] as const satisfies readonly AppFieldTypeCapability[];

const CANVAS_COMPONENT_TEMPLATES = [
  {
    code: "text",
    label: "基础输入",
    fieldType: "text",
    defaultLabel: "基础输入",
    typeLabel: "文本",
    required: false,
    inList: true,
    hidden: false,
    optionsText: "",
    codeHint: "basic_input"
  },
  {
    code: "number",
    label: "数字输入",
    fieldType: "decimal",
    defaultLabel: "数字输入",
    typeLabel: "数字",
    required: false,
    inList: true,
    hidden: false,
    optionsText: "",
    codeHint: "number_input"
  },
  {
    code: "date",
    label: "日期",
    fieldType: "date",
    defaultLabel: "日期字段",
    typeLabel: "日期",
    required: false,
    inList: true,
    hidden: false,
    optionsText: "",
    codeHint: "date_field"
  },
  {
    code: "select",
    label: "选择",
    fieldType: "select",
    defaultLabel: "选择项",
    typeLabel: "单选",
    required: false,
    inList: true,
    hidden: false,
    optionsText: "选项一\n选项二",
    codeHint: "select_field"
  },
  {
    code: "switch",
    label: "开关",
    fieldType: "checkbox",
    defaultLabel: "是否开启",
    typeLabel: "开关",
    required: false,
    inList: true,
    hidden: false,
    optionsText: "",
    codeHint: "switch_field"
  },
  {
    code: "richtext",
    label: "富文本",
    fieldType: "richtext",
    defaultLabel: "富文本内容",
    typeLabel: "富文本",
    required: false,
    inList: false,
    hidden: false,
    optionsText: "",
    codeHint: "richtext_content"
  },
  {
    code: "section",
    label: "分组",
    fieldType: "section",
    defaultLabel: "分组标题",
    typeLabel: "分组",
    required: false,
    inList: false,
    hidden: false,
    optionsText: "",
    codeHint: "fen_zu_biao_ti"
  },
  {
    code: "columns",
    label: "分栏",
    fieldType: "columns",
    defaultLabel: "多列栅格",
    typeLabel: "分栏",
    required: false,
    inList: false,
    hidden: false,
    optionsText: "",
    codeHint: "duo_lie_zha_ge"
  },
  {
    code: "note",
    label: "说明文本",
    fieldType: "note",
    defaultLabel: "说明文本",
    typeLabel: "说明",
    required: false,
    inList: false,
    hidden: false,
    optionsText: "",
    codeHint: "shuoming_wenben"
  }
] as const satisfies readonly CanvasComponentTemplate[];

const PLACEHOLDER_FIELD_TYPES = [
  "textarea",
  "integer",
  "currency",
  "percent",
  "multiselect",
  "datetime",
  "time",
  "user",
  "department",
  "org",
  "multilink",
  "table",
  "attachment",
  "image",
  "formula",
  "autonumber",
  "code",
  "textarea_long",
  "org_relation",
  "fetch_from",
  "signature",
  "location"
] as const;

const DESIGNER_NAVIGATION_SECTIONS: DesignerNavigationSection[] = [
  { code: "application", label: "应用", description: "应用信息、模块和菜单入口" },
  { code: "modeling", label: "对象", description: "业务对象、字段、关系和约束" },
  { code: "experience", label: "页面", description: "列表、表单和详情页面设计" },
  { code: "automation", label: "流程", description: "审批流、状态流和自动化动作" },
  { code: "governance", label: "权限", description: "角色、字段权限和页面访问控制" },
  { code: "integration", label: "集成", description: "导入导出、外部接口和应用包契约" }
];

const DEMO_FIELDS: DraftFieldDefinition[] = [
  { code: "customer_name", name: "客户名称", fieldType: "text", required: true, inList: true },
  { code: "contract_amount", name: "合同金额", fieldType: "decimal", required: true, inList: true },
  { code: "go_live_date", name: "上线日期", fieldType: "date", required: true, inList: true },
  { code: "industry", name: "行业", fieldType: "select", required: true, inList: true, options: ["retail", "service"] },
  { code: "is_active", name: "是否启用", fieldType: "checkbox", inList: true },
  { code: "owner_link", name: "负责人链接", fieldType: "link", required: true, inList: true },
  { code: "summary_html", name: "摘要说明", fieldType: "richtext", inList: true }
];

const DEMO_RULES: DesignerRuleDefinition[] = [
  {
    code: "amount-required",
    name: "合同金额必填校验",
    resourceId: "rule:customer_contract:amount-required",
    order: 10,
    enabled: true,
    scope: "form",
    fieldCode: "contract_amount",
    operator: "required",
    condition: {
      fieldCode: "contract_amount",
      operator: "required"
    },
    actions: [
      {
        type: "require",
        targetType: "field",
        targetCode: "contract_amount",
        effect: "required"
      }
    ],
    message: "合同金额是审批和回款的关键字段"
  },
  {
    code: "industry-service-summary-required",
    name: "服务行业摘要必填联动",
    resourceId: "rule:customer_contract:industry-service-summary-required",
    order: 20,
    enabled: true,
    scope: "form",
    fieldCode: "industry",
    operator: "equals",
    condition: {
      fieldCode: "industry",
      operator: "equals",
      value: "service"
    },
    actions: [
      {
        type: "require",
        targetType: "field",
        targetCode: "summary_html",
        effect: "required"
      },
      {
        type: "show",
        targetType: "field",
        targetCode: "summary_html",
        effect: "visible"
      },
      {
        type: "show",
        targetType: "section",
        targetCode: "form-business",
        effect: "visible"
      },
      {
        type: "hide",
        targetType: "page",
        targetCode: "detail",
        effect: "hidden"
      }
    ],
    message: "服务行业必须补充摘要说明，并展示业务属性分组"
  },
  {
    code: "submit-approval-action",
    name: "提交审批动作绑定",
    resourceId: "rule:customer_contract:submit-approval-action",
    order: 30,
    enabled: true,
    scope: "form",
    fieldCode: "customer_name",
    operator: "required",
    condition: {
      fieldCode: "customer_name",
      operator: "notEmpty"
    },
    actions: [
      {
        type: "submit",
        targetType: "submit",
        targetCode: "submit",
        workflowActionCode: "submit",
        workflowTransition: {
          actionCode: "submit",
          from: "draft",
          to: "dept_approval"
        },
        idempotencyKeyRequired: true,
        sideEffectPolicy: "outbox",
        effect: "workflow"
      },
      {
        type: "readonly",
        targetType: "field",
        targetCode: "owner_link",
        effect: "readonly"
      },
      {
        type: "calculate",
        targetType: "field",
        targetCode: "contract_amount",
        effect: "value"
      },
      {
        type: "jump",
        targetType: "page",
        targetCode: "detail",
        effect: "jump"
      },
      {
        type: "notify",
        targetType: "notification",
        targetCode: "approval-reminder",
        effect: "notify"
      }
    ],
    message: "表单提交按钮必须进入审批流程提交动作"
  }
];

export function createAppTypeRegistry(): AppFieldRegistry {
  return {
    interactive: [...INTERACTIVE_FIELD_TYPES],
    placeholder: PLACEHOLDER_FIELD_TYPES.map((code) => ({
      code,
      label: `${code}（占位）`,
      interactive: false
    }))
  };
}

export function createEmptyFieldDraft(): FieldDraftInput {
  return {
    label: "",
    fieldType: "text",
    required: false,
    inList: true,
    hidden: false,
    optionsText: ""
  };
}

export function updateFieldDraftValue<K extends keyof FieldDraftInput>(
  draft: FieldDraftInput,
  key: K,
  value: FieldDraftInput[K]
): FieldDraftInput {
  return {
    ...draft,
    [key]: value
  };
}

export function createDesignerWorkbench(): DemoWorkbench {
  return createWorkbenchFromSchema(DEMO_FIELDS, {
    selectedFieldCode: DEMO_FIELDS[0].code,
    previewMode: "form",
    statusTag: "published",
    statusMessage: "已加载第一版设计器工作台",
    hasUnpublishedChanges: false
  });
}

export function createDemoWorkbench(): DemoWorkbench {
  return createDesignerWorkbench();
}

export function createFieldDraftFromPalette(templateCode: string): FieldDraftInput {
  const template = CANVAS_COMPONENT_TEMPLATES.find((item) => item.code === templateCode);
  if (!template) {
    throw new Error(`组件模板 ${templateCode} 不存在`);
  }

  return {
    label: template.defaultLabel,
    fieldType: template.fieldType,
    required: template.required,
    inList: template.inList,
    hidden: template.hidden,
    optionsText: template.optionsText,
    codeHint: template.codeHint
  };
}

export function createCanvasComponentTemplates(): CanvasComponentTemplate[] {
  return [...CANVAS_COMPONENT_TEMPLATES];
}

export function getCommercialDesignerNavigation(workbench: DemoWorkbench): DesignerNavigation {
  const readiness = createDesignerReadinessReport(workbench);
  const nodes: Array<Omit<DesignerNavigationNode, "active">> = [
    {
      id: `app:${workbench.appCode}`,
      sectionCode: "application",
      label: "低代码应用",
      resourceType: "application",
      status: "ready"
    },
    {
      id: `object:${workbench.objectCode}`,
      sectionCode: "modeling",
      label: "客户合同对象",
      resourceType: "object",
      status: workbench.hasUnpublishedChanges ? "draft" : "ready"
    },
    {
      id: `page:${workbench.objectCode}:list`,
      sectionCode: "experience",
      label: "客户合同列表页",
      resourceType: "page",
      status: "ready"
    },
    {
      id: `page:${workbench.objectCode}:form`,
      sectionCode: "experience",
      label: "客户合同表单页",
      resourceType: "page",
      status: "ready"
    },
    {
      id: `page:${workbench.objectCode}:detail`,
      sectionCode: "experience",
      label: "客户合同详情页",
      resourceType: "page",
      status: "ready"
    },
    {
      id: `workflow:${workbench.objectCode}:approval`,
      sectionCode: "automation",
      label: "客户合同审批流程",
      resourceType: "workflow",
      status: navigationStatusFromReadiness(readiness, "workflow-approval")
    },
    {
      id: `permission:${workbench.objectCode}`,
      sectionCode: "governance",
      label: "客户合同权限矩阵",
      resourceType: "permission",
      status: navigationStatusFromReadiness(readiness, "permission-matrix")
    },
    {
      id: `integration:${workbench.objectCode}`,
      sectionCode: "integration",
      label: "客户合同集成契约",
      resourceType: "integration",
      status: navigationStatusFromReadiness(readiness, "integration-contract")
    }
  ];

  return {
    sections: [...DESIGNER_NAVIGATION_SECTIONS],
    nodes: nodes.map((node) => ({
      ...node,
      active: node.id === workbench.activeResourceId
    }))
  };
}

export function selectDesignerResource(workbench: DemoWorkbench, resourceId: string): DemoWorkbench {
  const navigation = getCommercialDesignerNavigation(workbench);
  const normalizedResourceId = normalizeDesignerResourceId(workbench, resourceId);
  const node = navigation.nodes.find((item) => item.id === normalizedResourceId);
  if (!node) {
    return workbench;
  }

  return {
    ...workbench,
    activeDesignerMode: node.resourceType,
    activeResourceId: node.id,
    previewMode: resolvePreviewModeFromResource(node.id, workbench.previewMode),
    statusMessage: `已切换到${node.label}设计上下文`
  };
}

export function getDesignerLayoutBlueprint(workbench: DemoWorkbench): DesignerLayoutBlueprint {
  const pageTitles: Record<PageConfigName, string> = {
    list: "客户合同列表页",
    form: "客户合同表单页",
    detail: "客户合同详情页"
  };

  return {
    resourceId: `page:${workbench.objectCode}`,
    pages: (["list", "form", "detail"] as PageConfigName[]).map((pageType) => {
      const config = workbench.pageConfigs[pageType];
      const layoutNodes = getFormLayoutNodes(workbench, pageType);
      return {
        pageType,
        resourceId: `page:${workbench.objectCode}:${pageType}`,
        title: pageTitles[pageType],
        columns: config.layout.columns,
        density: config.layout.density,
        nodeCount: layoutNodes.length,
        fields: config.visibleFieldCodes.map((fieldCode) => {
          const field = findField(workbench, fieldCode);
          return {
            code: field.code,
            label: field.name,
            fieldType: field.fieldType,
            required: field.required === true,
            runtimeField: isRuntimeField(field)
          };
        }),
        containers: layoutNodes
          .filter((node) => node.kind !== "field" && node.kind !== "action")
          .map((node) => ({
            nodeId: node.id,
            parentId: node.parentId,
            kind: node.kind,
            label: node.label,
            columns: node.columns,
            minColumns: node.minColumns,
            maxColumns: node.maxColumns,
            responsive: node.responsive
          })),
        fieldBindings: layoutNodes
          .filter((node) => node.kind === "field" && node.fieldCode)
          .map((node) => {
            const field = findField(workbench, node.fieldCode ?? "");
            return {
              nodeId: node.id,
              fieldCode: field.code,
              sectionId: findNearestLayoutAncestor(layoutNodes, node.id, "section")?.id,
              label: field.name,
              fieldType: field.fieldType,
              span: node.span ?? 1
            };
          }),
        ruleBindings: createLayoutRuleBindings(layoutNodes, workbench.rules)
      };
    })
  };
}

export function getFormLayoutNodes(workbench: DemoWorkbench, pageType: PageConfigName): FormLayoutNode[] {
  return flattenLayoutTree(syncLayoutTreeWithPageConfig(workbench.pageConfigs[pageType].layoutTree, workbench.pageConfigs[pageType]));
}

export function getDesignerWorkflowBlueprint(workbench: DemoWorkbench): DesignerWorkflowBlueprint {
  return {
    resourceId: `workflow:${workbench.objectCode}:approval`,
    name: "客户合同审批流程",
    publishReady: true,
    nodes: [
      { code: "draft", name: "草稿提交", kind: "start", assignee: "发起人", terminal: false },
      { code: "dept_approval", name: "部门负责人审批", kind: "approval", assignee: "部门负责人", terminal: false },
      { code: "approved", name: "审批通过", kind: "end", assignee: "系统", terminal: true }
    ],
    transitions: [
      { from: "draft", to: "dept_approval", actionCode: "submit", actionName: "提交审批", idempotent: true, invokedByRuleCode: "submit-approval-action" },
      { from: "dept_approval", to: "approved", actionCode: "approve", actionName: "审批通过", idempotent: true }
    ]
  };
}

export function getFormRuleCenter(workbench: DemoWorkbench): DesignerFormRuleCenter {
  return {
    resourceId: `rule:${workbench.objectCode}`,
    scope: "global",
    ownerObjectCode: workbench.objectCode,
    formDefinitionCode: `${workbench.objectCode}.default`,
    versionMode: "draft-and-published-snapshot",
    publishGate: {
      validatesDanglingReference: true,
      validatesConflict: true,
      validatesPermissionBoundary: true
    },
    rules: [...workbench.rules].sort((first, second) => (first.order ?? 0) - (second.order ?? 0)),
    diagnostics: validateFormRuleCenter(workbench),
    previewTest: {
      enabled: true,
      coversAllEnabledRules: true,
      sampleRecord: { ...workbench.previewRecord }
    }
  };
}

export function validateFormRuleCenter(workbench: DemoWorkbench): DesignerRuleDiagnostic[] {
  const nodes = getFormLayoutNodes(workbench, "form");
  const fieldCodes = new Set(workbench.recordSchema.filter((field) => isRuntimeField(field)).map((field) => field.code));
  const sectionIds = new Set(nodes.filter((node) => node.kind === "section").map((node) => node.id));
  const actionCodes = new Set(nodes.filter((node) => node.kind === "action" && node.actionCode).map((node) => node.actionCode ?? ""));
  const permissions = getPermissionMatrix(workbench);
  const diagnostics: DesignerRuleDiagnostic[] = [];
  const activeRules = workbench.rules.filter((rule) => rule.enabled !== false);

  for (const rule of activeRules) {
    const conditionFieldCode = rule.condition?.fieldCode ?? rule.fieldCode;
    if (conditionFieldCode && !fieldCodes.has(conditionFieldCode)) {
      diagnostics.push({
        code: "rule-condition-field-missing",
        severity: "blocking",
        ruleCode: rule.code,
        targetCode: conditionFieldCode,
        message: `规则 ${rule.name} 的触发字段 ${conditionFieldCode} 不存在`
      });
    }

    for (const action of rule.actions ?? legacyRuleActions(rule)) {
      if (!ruleActionTargetExists(action, fieldCodes, sectionIds, actionCodes)) {
        diagnostics.push({
          code: "rule-target-missing",
          severity: "blocking",
          ruleCode: rule.code,
          targetCode: action.targetCode,
          message: `规则 ${rule.name} 的动作目标 ${action.targetCode} 不存在`
        });
      }

      if (action.type === "hide" && action.targetType === "field" && fieldHasWritablePermission(permissions, action.targetCode)) {
        diagnostics.push({
          code: "hidden-without-permission",
          severity: "warning",
          ruleCode: rule.code,
          targetCode: action.targetCode,
          message: `规则 ${rule.name} 只做 UI 隐藏，字段权限仍需单独收敛`
        });
      }
    }
  }

  for (const conflict of findRuleConflicts(activeRules)) {
    diagnostics.push(conflict);
  }

  return diagnostics;
}

export function getFormTemplateCatalog(workbench: DemoWorkbench): DesignerFormTemplateCatalog {
  return {
    resourceId: `template:${workbench.objectCode}`,
    templates: [
      {
        code: "create-form",
        name: "新增表单模板",
        pageType: "form",
        reuseStrategy: "source",
        templateVersion: 1,
        overridePatch: [],
        readonly: false,
        layoutTree: workbench.pageConfigs.form.layoutTree
      },
      {
        code: "edit-form",
        name: "编辑表单模板",
        pageType: "form",
        sourceTemplateCode: "create-form",
        reuseStrategy: "reference",
        legacyReuseStrategy: "inherit-and-override",
        templateVersion: 1,
        overridePatch: [],
        readonly: false,
        layoutTree: workbench.pageConfigs.form.layoutTree
      },
      {
        code: "detail-form",
        name: "详情表单模板",
        pageType: "detail",
        sourceTemplateCode: "create-form",
        reuseStrategy: "copy-with-overrides",
        legacyReuseStrategy: "inherit-and-override",
        templateVersion: 1,
        overridePatch: [
          {
            op: "set-readonly",
            value: true
          }
        ],
        readonly: true,
        layoutTree: workbench.pageConfigs.detail.layoutTree
      }
    ]
  };
}

export function getSchemaJsonView(workbench: DemoWorkbench): DesignerSchemaJsonView {
  return {
    resourceId: `schema:${workbench.objectCode}`,
    schema: {
      fields: workbench.recordSchema.map((field) => ({ ...field })),
      layout: getDesignerLayoutBlueprint(workbench),
      rules: getFormRuleCenter(workbench),
      permissions: getPermissionMatrix(workbench),
      workflow: getDesignerWorkflowBlueprint(workbench)
    }
  };
}

export function getFormDesignerSurface(workbench: DemoWorkbench): FormDesignerSurface {
  const runtimeFields = workbench.recordSchema.filter((field) => isRuntimeField(field));
  const layoutNodes = getFormLayoutNodes(workbench, "form");
  const reactionDesigner = createFormilyReactionDesigner(workbench);

  return {
    resourceId: `form-designer:${workbench.objectCode}`,
    tabs: [
      { code: "designer", label: "设计", enabled: true },
      { code: "preview", label: "预览", enabled: true },
      { code: "logic", label: "逻辑", enabled: true },
      { code: "json", label: "JSON", enabled: true },
      { code: "theme", label: "主题", enabled: true },
      { code: "translation", label: "翻译", enabled: true }
    ],
    displayModes: [
      { code: "web", label: "Web 表单" },
      { code: "wizard", label: "向导表单" },
      { code: "pdf", label: "PDF 表单" }
    ],
    toolbox: {
      categories: [
        {
          code: "basic",
          label: "基础字段",
          components: [
            { code: "text", label: "文本" },
            { code: "decimal", label: "数字" },
            { code: "date", label: "日期" },
            { code: "select", label: "单选" },
            { code: "checkbox", label: "勾选" }
          ]
        },
        {
          code: "advanced",
          label: "高级字段",
          components: [
            { code: "richtext", label: "富文本" },
            { code: "link", label: "关联对象" },
            { code: "formula", label: "公式" },
            { code: "attachment", label: "附件" }
          ]
        },
        {
          code: "layout",
          label: "布局容器",
          components: [
            { code: "section", label: "分组" },
            { code: "tabs", label: "标签页" },
            { code: "grid", label: "栅格" },
            { code: "wizard-page", label: "向导页" },
            { code: "panel", label: "面板" }
          ]
        },
        {
          code: "data",
          label: "数据组件",
          components: [
            { code: "table", label: "子表" },
            { code: "fetch-from", label: "引用带出" },
            { code: "data-source", label: "数据源" }
          ]
        },
        {
          code: "action",
          label: "动作组件",
          components: [
            { code: "submit", label: "提交" },
            { code: "save-draft", label: "保存草稿" },
            { code: "reset", label: "重置" }
          ]
        }
      ]
    },
    schemaProtocol: {
      jsonSchema: createJsonSchemaProtocol(runtimeFields),
      uiSchema: createUiSchemaProtocol(workbench),
      data: { ...workbench.previewRecord }
    },
    propertyGrid: {
      tabs: [
        { code: "property", label: "属性" },
        { code: "style", label: "样式" },
        { code: "validation", label: "校验" },
        { code: "logic", label: "逻辑" },
        { code: "action", label: "动作" }
      ]
    },
    outline: {
      nodes: layoutNodes
        .filter((node) => node.kind !== "field" && node.kind !== "action")
        .map((node) => ({
          id: node.id,
          kind: node.kind,
          label: node.label
        }))
    },
    ioContract: {
      importJson: true,
      exportJson: true,
      exportSchema: true,
      versionedSnapshot: true
    },
    formilyDesignable: {
      engine: "Designable",
      formCore: "Formily",
      schemaDialect: "JSON Schema + x-* 扩展",
      adapterPackages: ["Ant Design", "Fusion", "业务组件"],
      conversion: {
        jsonSchemaToFormily: true,
        formilyToJsonSchema: true,
        supportsJSchema: true
      },
      reactions: [
        { type: "visible", sourceFieldCode: "industry", targetFieldCode: "summary_html" },
        { type: "required", sourceFieldCode: "industry", targetFieldCode: "summary_html" },
        { type: "value", sourceFieldCode: "industry", targetFieldCode: "contract_amount" },
        { type: "disabled", sourceFieldCode: "is_active", targetFieldCode: "owner_link" }
      ],
      workbenchPanels: [
        { code: "designer-canvas", label: "设计画布" },
        { code: "component-tree", label: "组件树" },
        { code: "property-settings", label: "属性设置" },
        { code: "history", label: "历史记录" },
        { code: "schema-editor", label: "Schema 编辑器" }
      ],
      formilySchema: createFormilySchema(workbench, reactionDesigner.rules),
      reactionDesigner,
      workbench: createDesignableWorkbenchState(workbench)
    }
  };
}

export function getPermissionMatrix(workbench: DemoWorkbench): DesignerPermissionMatrix {
  const roles: DesignerPermissionRole[] = [
    { code: "admin", name: "平台管理员", description: "维护对象、页面、流程、权限和集成契约" },
    { code: "operator", name: "业务经办人", description: "录入客户合同并提交审批" },
    { code: "viewer", name: "只读观察者", description: "查看已授权的客户合同数据" }
  ];
  const pageResourceIds = (["list", "form", "detail"] as PageConfigName[]).map((page) => `page:${workbench.objectCode}:${page}`);
  const entries: DesignerPermissionEntry[] = roles.flatMap((role) => pageResourceIds.map((resourceId) => ({
    roleCode: role.code,
    resourceId,
    capability: role.code === "viewer" ? "READ" : "WRITE"
  })));
  const runtimeFields = workbench.recordSchema.filter((field) => isRuntimeField(field));
  const fieldPermissions: DesignerFieldPermissionEntry[] = roles.flatMap((role) => runtimeFields.map((field) => ({
    roleCode: role.code,
    fieldCode: field.code,
    permission: resolveDesignerFieldPermission(role.code, field.code)
  })));
  const actionPermissions: DesignerActionPermissionEntry[] = roles.flatMap((role) => [
    { roleCode: role.code, actionCode: "submit", allowed: role.code !== "viewer" },
    { roleCode: role.code, actionCode: "approve", allowed: role.code === "admin" }
  ]);

  return {
    resourceId: `permission:${workbench.objectCode}`,
    roles,
    entries,
    fieldPermissions,
    actionPermissions,
    publishReady: entries.length > 0 && fieldPermissions.length > 0 && actionPermissions.length > 0
  };
}

export function getIntegrationContract(workbench: DemoWorkbench): DesignerIntegrationContract {
  return {
    resourceId: `integration:${workbench.objectCode}`,
    publishReady: true,
    channels: [
      {
        code: "import",
        name: "批量导入",
        direction: "inbound",
        idempotent: true,
        securityPolicy: "字段白名单 + 幂等导入批次"
      },
      {
        code: "export",
        name: "批量导出",
        direction: "outbound",
        idempotent: true,
        securityPolicy: "字段权限裁剪 + CSV 公式转义"
      },
      {
        code: "open-api",
        name: "开放 API",
        direction: "bidirectional",
        idempotent: true,
        securityPolicy: "租户鉴权 + 幂等键 + traceId"
      },
      {
        code: "app-package",
        name: "应用包安装升级",
        direction: "bidirectional",
        idempotent: true,
        securityPolicy: "包签名校验 + 兼容性预检"
      }
    ]
  };
}

export function createDesignerReadinessReport(workbench: DemoWorkbench): DesignerReadinessReport {
  const hasFields = workbench.recordSchema.filter((field) => isRuntimeField(field)).length > 0;
  const hasVisiblePages = Object.values(workbench.pageConfigs).every((config) => config.visibleFieldCodes.length > 0);
  const ruleCenter = getFormRuleCenter(workbench);
  const blockingRuleIssue = ruleCenter.diagnostics.find((diagnostic) => diagnostic.severity === "blocking");
  const warningRuleIssue = ruleCenter.diagnostics.find((diagnostic) => diagnostic.severity === "warning");
  const workflow = getDesignerWorkflowBlueprint(workbench);
  const permissionMatrix = getPermissionMatrix(workbench);
  const integrationContract = getIntegrationContract(workbench);
  const items: DesignerReadinessItem[] = [
    {
      code: "object-fields",
      resourceId: `object:${workbench.objectCode}`,
      label: "对象字段",
      severity: hasFields ? "pass" : "blocking",
      status: hasFields ? "passed" : "blocked",
      message: hasFields ? "对象已经配置可运行字段" : "对象缺少可运行字段",
      fixHint: hasFields ? "无需处理。" : "进入对象设计，至少新增一个可运行字段。",
      primaryAction: hasFields ? "查看对象字段" : "新增对象字段",
      ownerPanel: "object"
    },
    {
      code: "page-layout",
      resourceId: `page:${workbench.objectCode}:form`,
      label: "页面布局",
      severity: hasVisiblePages ? "pass" : "blocking",
      status: hasVisiblePages ? "passed" : "blocked",
      message: hasVisiblePages ? "列表、表单和详情页均有可见字段" : "存在没有可见字段的页面",
      fixHint: hasVisiblePages ? "无需处理。" : "进入页面设计，为列表、表单和详情页配置至少一个可见字段。",
      primaryAction: hasVisiblePages ? "查看页面布局" : "配置页面字段",
      ownerPanel: "page"
    },
    {
      code: "business-rules",
      resourceId: blockingRuleIssue
        ? findRuleResourceId(workbench, blockingRuleIssue.ruleCode)
        : `rule:${workbench.objectCode}`,
      label: "业务规则",
      severity: blockingRuleIssue ? "blocking" : "pass",
      status: blockingRuleIssue ? "blocked" : "passed",
      message: blockingRuleIssue
        ? blockingRuleIssue.message
        : warningRuleIssue
          ? `规则中心已可发布，仍有提醒：${warningRuleIssue.message}`
          : "规则中心已覆盖保存校验、字段联动、提交动作和预览测试",
      fixHint: blockingRuleIssue
        ? "进入规则中心，修复失效目标或冲突规则。"
        : "持续通过预览测试验证字段联动和提交动作。",
      primaryAction: blockingRuleIssue ? "修复规则中心" : "查看规则中心",
      ownerPanel: "object"
    },
    {
      code: "workflow-approval",
      resourceId: `workflow:${workbench.objectCode}:approval`,
      label: "审批流程",
      severity: workflow.publishReady ? "pass" : "blocking",
      status: workflow.publishReady ? "passed" : "blocked",
      message: workflow.publishReady ? "审批流程已配置提交动作、审批节点和终态" : "审批流程还缺少正式提交动作、终态和回退路径",
      fixHint: workflow.publishReady ? "无需处理。" : "进入流程设计，补齐提交动作、审批节点、终态和失败处理。",
      primaryAction: workflow.publishReady ? "查看审批流程" : "完善审批流程",
      ownerPanel: "workflow"
    },
    {
      code: "permission-matrix",
      resourceId: `permission:${workbench.objectCode}`,
      label: "权限矩阵",
      severity: permissionMatrix.publishReady ? "pass" : "blocking",
      status: permissionMatrix.publishReady ? "passed" : "blocked",
      message: permissionMatrix.publishReady ? "角色、页面、字段和按钮权限矩阵已配置" : "角色、页面、字段和按钮权限矩阵尚未完整配置",
      fixHint: permissionMatrix.publishReady ? "无需处理。" : "进入权限设计，补齐角色、页面、字段和按钮动作权限。",
      primaryAction: permissionMatrix.publishReady ? "查看权限矩阵" : "完善权限矩阵",
      ownerPanel: "permission"
    },
    {
      code: "integration-contract",
      resourceId: `integration:${workbench.objectCode}`,
      label: "集成契约",
      severity: integrationContract.publishReady ? "warning" : "blocking",
      status: integrationContract.publishReady ? "needs-review" : "blocked",
      message: integrationContract.publishReady ? "导入导出、开放 API 和应用包契约已形成基线，仍需人工确认外部对接方" : "导入导出、外部接口和应用包契约仍需确认",
      fixHint: integrationContract.publishReady
        ? "进入集成设计，确认外部系统、鉴权方式、幂等键和失败处理策略。"
        : "进入集成设计，补齐导入导出、开放 API 和应用包契约。",
      primaryAction: integrationContract.publishReady ? "确认集成契约" : "完善集成契约",
      ownerPanel: "integration"
    }
  ];

  return {
    summary: {
      total: items.length,
      passed: items.filter((item) => item.severity === "pass").length,
      warning: items.filter((item) => item.severity === "warning").length,
      blocking: items.filter((item) => item.severity === "blocking").length,
      publishable: items.every((item) => item.severity !== "blocking")
    },
    items
  };
}

export function updateWorkbenchField(workbench: DemoWorkbench, action: WorkbenchAction): DemoWorkbench {
  if (action.type === "select-field") {
    return {
      ...workbench,
      selectedFieldCode: action.fieldCode
    };
  }

  if (action.type === "set-preview-mode") {
    return {
      ...workbench,
      previewMode: action.previewMode
    };
  }

  if (action.type === "select-resource") {
    return selectDesignerResource(workbench, action.resourceId);
  }

  if (action.type === "save-draft") {
    return {
      ...workbench,
      statusTag: "saved",
      statusMessage: `已保存草稿，共 ${workbench.recordSchema.length} 个字段，尚未发布`,
      hasUnpublishedChanges: true
    };
  }

  if (action.type === "publish-success") {
    return {
      ...workbench,
      statusTag: "published",
      statusMessage: `已发布版本快照，metaHash：${action.metaHash}`,
      hasUnpublishedChanges: false,
      lastPublishedMetaHash: action.metaHash
    };
  }

  if (action.type === "add-field") {
    const nextField = createFieldFromDraft(action.draft, workbench.recordSchema);
    const previewRecord = {
      ...workbench.previewRecord,
      [nextField.code]: createPreviewValue(nextField)
    };

    return createWorkbenchFromSchema([...workbench.recordSchema, nextField], {
      previewRecord,
      selectedFieldCode: nextField.code,
      previewMode: "form",
      statusTag: "draft",
      statusMessage: `草稿未发布：已新增字段 ${nextField.name}`,
      hasUnpublishedChanges: true,
      lastPublishedMetaHash: workbench.lastPublishedMetaHash,
      rules: workbench.rules
    });
  }

  if (action.type === "drop-palette-field") {
    const paletteDraft = createFieldDraftFromPalette(action.fieldType);
    const droppedField = createFieldFromDraft(paletteDraft, workbench.recordSchema);
    const targetIndex = clampDropIndex(action.targetIndex, workbench.recordSchema.length);
    const nextSchema = [...workbench.recordSchema];
    nextSchema.splice(targetIndex, 0, droppedField);

    return createWorkbenchFromSchema(nextSchema, {
      previewRecord: {
        ...workbench.previewRecord,
        [droppedField.code]: createPreviewValue(droppedField)
      },
      selectedFieldCode: droppedField.code,
      previewMode: "form",
      statusTag: "draft",
      statusMessage: `草稿未发布：已拖入组件 ${droppedField.name}`,
      hasUnpublishedChanges: true,
      lastPublishedMetaHash: workbench.lastPublishedMetaHash,
      rules: workbench.rules
    });
  }

  if (action.type === "drop-existing-field") {
    return reorderFieldByDropIndex(workbench, action.sourceFieldCode, action.targetIndex);
  }

  if (action.type === "update-page-config") {
    const nextLayout = {
      ...workbench.pageConfigs[action.page].layout,
      ...(action.patch.layout ?? {})
    };
    const normalizedLayout: PageLayoutConfig = {
      ...nextLayout,
      columns: normalizeLayoutColumns(nextLayout.columns)
    };
    const nextVisibleFieldCodes = action.patch.visibleFieldCodes
      ? filterVisibleFieldCodes(action.patch.visibleFieldCodes, workbench.recordSchema)
      : workbench.pageConfigs[action.page].visibleFieldCodes;
    const nextPageConfigs = {
      ...workbench.pageConfigs,
      [action.page]: {
        ...workbench.pageConfigs[action.page],
        ...action.patch,
        layout: normalizedLayout,
        visibleFieldCodes: nextVisibleFieldCodes,
        layoutTree: syncLayoutTreeGridColumns(
          syncLayoutTreeWithFieldCodes(
            action.patch.layoutTree ?? workbench.pageConfigs[action.page].layoutTree,
            nextVisibleFieldCodes
          ),
          normalizedLayout.columns
        )
      }
    } satisfies DemoWorkbench["pageConfigs"];

    return createWorkbenchFromSchema(workbench.recordSchema, {
      previewRecord: workbench.previewRecord,
      selectedFieldCode: workbench.selectedFieldCode,
      previewMode: workbench.previewMode,
      statusTag: "draft",
      statusMessage: `草稿未发布：已更新${formatPageLabel(action.page)}页配置`,
      hasUnpublishedChanges: true,
      lastPublishedMetaHash: workbench.lastPublishedMetaHash,
      pageConfigs: nextPageConfigs,
      rules: workbench.rules
    });
  }

  if (action.type === "delete-selected-field") {
    const currentIndex = workbench.recordSchema.findIndex((field) => field.code === workbench.selectedFieldCode);
    const nextSchema = workbench.recordSchema.filter((field) => field.code !== workbench.selectedFieldCode);
    const nextSelectedField = nextSchema[Math.max(0, currentIndex - 1)] ?? nextSchema[0];
    const nextPreviewRecord = removePreviewValue(workbench.previewRecord, workbench.selectedFieldCode);

    return createWorkbenchFromSchema(nextSchema, {
      previewRecord: nextPreviewRecord,
      selectedFieldCode: nextSelectedField?.code ?? "",
      previewMode: workbench.previewMode,
      statusTag: "draft",
      statusMessage: `草稿未发布：已删除字段 ${findField(workbench, workbench.selectedFieldCode).name}`,
      hasUnpublishedChanges: true,
      lastPublishedMetaHash: workbench.lastPublishedMetaHash,
      rules: workbench.rules
    });
  }

  if (action.type === "move-selected-field") {
    const currentIndex = workbench.recordSchema.findIndex((field) => field.code === workbench.selectedFieldCode);
    const nextIndex = action.direction === "up" ? currentIndex - 1 : currentIndex + 1;
    if (currentIndex < 0 || nextIndex < 0 || nextIndex >= workbench.recordSchema.length) {
      return workbench;
    }

    const nextSchema = [...workbench.recordSchema];
    const [movedField] = nextSchema.splice(currentIndex, 1);
    nextSchema.splice(nextIndex, 0, movedField);

    return createWorkbenchFromSchema(nextSchema, {
      previewRecord: workbench.previewRecord,
      selectedFieldCode: movedField.code,
      previewMode: workbench.previewMode,
      statusTag: "draft",
      statusMessage: `草稿未发布：已${action.direction === "up" ? "上移" : "下移"}字段 ${movedField.name}`,
      hasUnpublishedChanges: true,
      lastPublishedMetaHash: workbench.lastPublishedMetaHash,
      rules: workbench.rules
    });
  }

  const current = findField(workbench, workbench.selectedFieldCode);
  const patch = normalizeFieldPatch({
    ...current,
    ...action.patch
  }, current);
  const nextSchema = workbench.recordSchema.map((field) => (
    field.code === workbench.selectedFieldCode
      ? {
        ...field,
        ...patch
      }
      : field
  ));
  const nextPreviewRecord = normalizePreviewRecordForSchema(
    nextSchema,
    renamePreviewValue(workbench.previewRecord, current.code, current.code),
    current.code
  );

  return createWorkbenchFromSchema(nextSchema, {
    previewRecord: nextPreviewRecord,
    selectedFieldCode: current.code,
    previewMode: workbench.previewMode,
    statusTag: "draft",
    statusMessage: `草稿未发布：已更新字段 ${patch.name ?? current.name}`,
    hasUnpublishedChanges: true,
    lastPublishedMetaHash: workbench.lastPublishedMetaHash,
    pageConfigs: syncPageConfigsWithSchema(workbench.pageConfigs, nextSchema),
    rules: workbench.rules
  });
}

export function createPreviewSnapshot(workbench: DemoWorkbench, mode: PreviewMode): PreviewSnapshot {
  const published = publishWorkbench(workbench, {
    permissionPreset: "operator",
    traceId: `trace-preview-${mode}`,
    idempotencyKey: `preview-${mode}`
  });

  return {
    mode,
    runtime: published.runtime[mode],
    published
  };
}

export function insertFieldFromTemplate(
  workbench: DemoWorkbench,
  template: CanvasComponentTemplate,
  targetIndex: number
): DemoWorkbench {
  return updateWorkbenchField(workbench, {
    type: "drop-palette-field",
    fieldType: template.code,
    targetIndex
  });
}

export function reorderFieldByDropIndex(
  workbench: DemoWorkbench,
  sourceFieldCode: string,
  targetIndex: number
): DemoWorkbench {
  const currentIndex = workbench.recordSchema.findIndex((field) => field.code === sourceFieldCode);
  if (currentIndex < 0) {
    return workbench;
  }

  const nextSchema = [...workbench.recordSchema];
  const [movedField] = nextSchema.splice(currentIndex, 1);
  const normalizedIndex = clampDropIndex(targetIndex, nextSchema.length);
  nextSchema.splice(normalizedIndex, 0, movedField);

  return createWorkbenchFromSchema(nextSchema, {
    previewRecord: workbench.previewRecord,
    selectedFieldCode: movedField.code,
    previewMode: workbench.previewMode,
    statusTag: "draft",
    statusMessage: `草稿未发布：已拖拽排序 ${movedField.name}`,
    hasUnpublishedChanges: true,
    lastPublishedMetaHash: workbench.lastPublishedMetaHash,
    pageConfigs: reorderPageConfigsBySchema(workbench.pageConfigs, nextSchema),
    rules: workbench.rules
  });
}

export function getSelectedCanvasComponent(workbench: DemoWorkbench): SelectedCanvasComponent | null {
  const field = workbench.recordSchema.find((item) => item.code === workbench.selectedFieldCode);
  if (!field) {
    return null;
  }

  const visibleFieldCodes = workbench.pageConfigs[workbench.previewMode].visibleFieldCodes;
  return {
    fieldCode: field.code,
    fieldName: field.name,
    pageType: workbench.previewMode,
    componentType: workbench.previewMode === "list"
      ? "list-column"
      : workbench.previewMode === "detail"
        ? "detail-item"
        : "form-field",
    visible: visibleFieldCodes.includes(field.code),
    sortIndex: visibleFieldCodes.indexOf(field.code)
  };
}

export function validateDraftRecord(workbench: DemoWorkbench, record: Record<string, unknown>): ValidationResult {
  const errors: ValidationIssue[] = [];
  const sanitizedRecord: Record<string, unknown> = {};

  for (const field of workbench.recordSchema) {
    const value = record[field.code];
    switch (field.fieldType) {
      case "text":
        if (field.required && typeof value === "string" && value.trim().length === 0) {
          errors.push({ field: field.code, message: `${field.name}不能为空` });
        }
        if (typeof value === "string") {
          sanitizedRecord[field.code] = value;
        }
        break;
      case "decimal":
        if (field.required && typeof value === "string" && value.trim().length === 0) {
          errors.push({ field: field.code, message: `${field.name}不能为空` });
          break;
        }
        if (typeof value !== "string" || !/^-?\d+(\.\d+)?$/.test(value)) {
          errors.push({ field: field.code, message: `${field.name}必须是十进制字符串` });
        } else {
          sanitizedRecord[field.code] = value;
        }
        break;
      case "date":
        if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
          errors.push({ field: field.code, message: `${field.name}必须是 yyyy-MM-dd` });
        } else {
          sanitizedRecord[field.code] = value;
        }
        break;
      case "select":
        if (typeof value !== "string" || !(field.options ?? []).includes(value)) {
          errors.push({ field: field.code, message: `${field.name}必须来自已配置选项` });
        } else {
          sanitizedRecord[field.code] = value;
        }
        break;
      case "checkbox":
        if (typeof value !== "boolean") {
          errors.push({ field: field.code, message: `${field.name}必须是布尔值` });
        } else {
          sanitizedRecord[field.code] = value;
        }
        break;
      case "link":
        if (typeof value !== "string") {
          errors.push({ field: field.code, message: `${field.name}必须是字符串` });
        } else {
          sanitizedRecord[field.code] = value;
        }
        break;
      case "richtext":
        if (typeof value === "string") {
          sanitizedRecord[field.code] = sanitizeRichText(value);
        }
        break;
      default:
        sanitizedRecord[field.code] = value;
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    sanitizedRecord
  };
}

export function publishWorkbench(workbench: DemoWorkbench, options: PublishOptions): PublishedWorkbench {
  const published = publishSessionSnapshot(workbench.session, workbench.version);
  const permissions = createPermissionPreset(options.permissionPreset);
  const meta = createRuntimeMeta(workbench, published.metaHash, permissions);
  const listPage = createRuntimePageSchema(workbench.pages.list, "list");
  const formPage = createRuntimePageSchema(workbench.pages.form, "form");
  const detailPage = createRuntimePageSchema(workbench.pages.detail, "detail");
  const pageSchemaErrors = collectPageSchemaErrors(meta, {
    list: listPage,
    form: formPage,
    detail: detailPage
  });

  return {
    publishRequest: createRequestEnvelope({
      idempotencyKey: options.idempotencyKey,
      metaHash: published.metaHash,
      objectCode: workbench.objectCode,
      permissionPreset: options.permissionPreset,
      pageSchemaVersion: PAGE_SCHEMA_VERSION,
      pages: {
        list: listPage,
        form: formPage,
        detail: detailPage
      }
    }, workbench.version, options.traceId),
    runtime: {
      list: createRuntimePageViewModel({
        pageSchema: listPage,
        meta,
        pageSchemaVersion: PAGE_SCHEMA_VERSION,
        requestId: options.traceId,
        records: [workbench.previewRecord]
      }),
      form: createRuntimePageViewModel({
        pageSchema: formPage,
        meta,
        pageSchemaVersion: PAGE_SCHEMA_VERSION,
        requestId: options.traceId,
        record: workbench.previewRecord
      }),
      detail: createRuntimePageViewModel({
        pageSchema: detailPage,
        meta,
        pageSchemaVersion: PAGE_SCHEMA_VERSION,
        requestId: options.traceId,
        record: workbench.previewRecord
      })
    },
    previewError: {
      code: pageSchemaErrors.length > 0 ? "LC-META-4221" : "LC-META-4091",
      message: pageSchemaErrors.length > 0
        ? `页面 schema 发布校验失败：${pageSchemaErrors.join("；")}`
        : "当前预览基于旧版元数据，请刷新后重试。",
      traceId: options.traceId
    }
  };
}

function collectPageSchemaErrors(
  meta: RuntimeMeta,
  pages: Record<RuntimePageSchema["pageType"], RuntimePageSchema>
): string[] {
  return Object.entries(pages).flatMap(([pageName, pageSchema]) => {
    const validation = validatePageSchema(meta, pageSchema);
    return validation.errors.map((error) => `${pageName}: ${error}`);
  });
}

export function createCsvEscapePreview(values: string[]): Array<{ raw: string; escaped: string }> {
  return values.map((raw) => ({
    raw,
    escaped: escapeCsvCell(raw)
  }));
}

export function getBuiltInFieldTypes(): string[] {
  return defaultFieldRegistry().fieldTypes();
}

function createDefaultPageConfigs(schema: DraftFieldDefinition[]): Record<PageConfigName, DemoPageConfig> {
  const runtimeFieldCodes = schema.filter((field) => isRuntimeField(field) && !field.hidden).map((field) => field.code);
  const listFieldCodes = schema.filter((field) => isRuntimeField(field) && !field.hidden && field.inList).map((field) => field.code);
  return {
    form: {
      visibleFieldCodes: runtimeFieldCodes,
      layout: {
        columns: 4,
        density: "comfortable"
      },
      layoutTree: createDefaultFormLayoutTree("form", runtimeFieldCodes)
    },
    list: {
      visibleFieldCodes: listFieldCodes,
      layout: {
        columns: 1,
        density: "compact"
      },
      layoutTree: createDefaultFormLayoutTree("list", listFieldCodes)
    },
    detail: {
      visibleFieldCodes: runtimeFieldCodes,
      layout: {
        columns: 4,
        density: "comfortable"
      },
      layoutTree: createDefaultFormLayoutTree("detail", runtimeFieldCodes)
    }
  };
}

function createDefaultFormLayoutTree(pageType: PageConfigName, fieldCodes: string[]): FormLayoutNode {
  const [first = "", second = "", ...rest] = fieldCodes;
  const basicFieldCodes = [first, second].filter(Boolean);
  const businessFieldCodes = rest.filter(Boolean);
  const pageLabel = pageType === "form" ? "客户合同表单" : pageType === "detail" ? "客户合同详情" : "客户合同列表";
  const gridColumns = pageType === "list" ? 1 : 4;

  return {
    id: `${pageType}-root`,
    kind: "form",
    label: pageLabel,
    children: [
      {
        id: `${pageType}-body`,
        kind: "body",
        label: "主体区域",
        parentId: `${pageType}-root`,
        children: [
          {
            id: `${pageType}-basic`,
            kind: "section",
            label: "基础信息",
            parentId: `${pageType}-body`,
            children: [
              {
                id: `${pageType}-basic-grid`,
                kind: "grid",
                label: pageType === "list" ? "列表单列栅格" : "四列基础栅格",
                parentId: `${pageType}-basic`,
                columns: gridColumns,
                minColumns: 1,
                maxColumns: 6,
                responsive: "auto-fit",
                children: basicFieldCodes.map((fieldCode) => createFieldLayoutNode(pageType, fieldCode, `${pageType}-basic-grid`))
              }
            ]
          },
          {
            id: `${pageType}-business`,
            kind: "section",
            label: "业务属性",
            parentId: `${pageType}-body`,
            children: [
              {
                id: `${pageType}-business-grid`,
                kind: "grid",
                label: pageType === "list" ? "列表业务栅格" : "四列业务栅格",
                parentId: `${pageType}-business`,
                columns: gridColumns,
                minColumns: 1,
                maxColumns: 6,
                responsive: "auto-fit",
                children: businessFieldCodes.map((fieldCode) => createFieldLayoutNode(pageType, fieldCode, `${pageType}-business-grid`))
              }
            ]
          },
          {
            id: `${pageType}-actions`,
            kind: "action-bar",
            label: "动作区",
            parentId: `${pageType}-body`,
            children: [
              {
                id: `${pageType}-action-submit`,
                kind: "action",
                label: "提交审批",
                parentId: `${pageType}-actions`,
                actionCode: "submit"
              }
            ]
          }
        ]
      }
    ]
  };
}

function createFieldLayoutNode(pageType: PageConfigName, fieldCode: string, parentId: string): FormLayoutNode {
  return {
    id: pageType === "form" ? `field-${fieldCode}` : `${pageType}-field-${fieldCode}`,
    kind: "field",
    label: fieldCode,
    parentId,
    fieldCode,
    span: inferDefaultFieldSpan(fieldCode)
  };
}

function syncLayoutTreeWithPageConfig(layoutTree: FormLayoutNode, pageConfig: DemoPageConfig): FormLayoutNode {
  return syncLayoutTreeWithFieldCodes(layoutTree, pageConfig.visibleFieldCodes);
}

function syncLayoutTreeWithFieldCodes(layoutTree: FormLayoutNode, fieldCodes: string[]): FormLayoutNode {
  const nodes = flattenLayoutTree(layoutTree);
  const existingFieldCodes = nodes
    .filter((node) => node.kind === "field" && node.fieldCode)
    .map((node) => node.fieldCode ?? "");
  const missingCodes = fieldCodes.filter((fieldCode) => !existingFieldCodes.includes(fieldCode));

  const pruned = pruneLayoutTreeFields(layoutTree, new Set(fieldCodes));
  if (missingCodes.length === 0) {
    return pruned;
  }

  return appendFieldNodesToBusinessGrid(pruned, missingCodes);
}

function syncLayoutTreeGridColumns(layoutTree: FormLayoutNode, columns: number): FormLayoutNode {
  const normalizedColumns = normalizeLayoutColumns(columns);
  return {
    ...layoutTree,
    children: layoutTree.children?.map((child) => syncLayoutTreeGridColumns(child, normalizedColumns)),
    ...(layoutTree.kind === "grid"
      ? {
        columns: normalizedColumns,
        minColumns: 1,
        maxColumns: 6,
        responsive: layoutTree.responsive ?? "auto-fit"
      }
      : {})
  };
}

function pruneLayoutTreeFields(node: FormLayoutNode, allowedFieldCodes: Set<string>): FormLayoutNode {
  return {
    ...node,
    children: node.children
      ?.filter((child) => child.kind !== "field" || (child.fieldCode !== undefined && allowedFieldCodes.has(child.fieldCode)))
      .map((child) => pruneLayoutTreeFields(child, allowedFieldCodes))
  };
}

function appendFieldNodesToBusinessGrid(layoutTree: FormLayoutNode, fieldCodes: string[]): FormLayoutNode {
  const pageType = layoutTree.id.startsWith("list-") ? "list" : layoutTree.id.startsWith("detail-") ? "detail" : "form";
  const targetGridId = `${pageType}-business-grid`;

  function append(node: FormLayoutNode): FormLayoutNode {
    if (node.id === targetGridId) {
      return {
        ...node,
        children: [
          ...(node.children ?? []),
          ...fieldCodes.map((fieldCode) => createFieldLayoutNode(pageType, fieldCode, targetGridId))
        ]
      };
    }

    return {
      ...node,
      children: node.children?.map((child) => append(child))
    };
  }

  return append(layoutTree);
}

function flattenLayoutTree(root: FormLayoutNode): FormLayoutNode[] {
  return [root, ...(root.children ?? []).flatMap((child) => flattenLayoutTree(child))];
}

function normalizeLayoutColumns(columns: number): number {
  if (!Number.isFinite(columns)) {
    return 4;
  }
  return Math.max(1, Math.min(6, Math.round(columns)));
}

function inferDefaultFieldSpan(fieldCode: string): number {
  if (fieldCode === "summary_html") {
    return 4;
  }
  if (fieldCode === "customer_name" || fieldCode === "contract_amount" || fieldCode === "owner_link") {
    return 2;
  }
  return 1;
}

function findNearestLayoutAncestor(
  nodes: FormLayoutNode[],
  nodeId: string,
  kind: FormLayoutNodeKind
): FormLayoutNode | undefined {
  const byId = new Map(nodes.map((node) => [node.id, node]));
  let current = byId.get(nodeId);
  while (current?.parentId) {
    current = byId.get(current.parentId);
    if (current?.kind === kind) {
      return current;
    }
  }
  return undefined;
}

function createLayoutRuleBindings(nodes: FormLayoutNode[], rules: DesignerRuleDefinition[]): DesignerRuleBinding[] {
  return rules.flatMap((rule) => {
    const boundFieldCode = rule.actions?.find((action) => action.targetType === "field")?.targetCode ?? rule.fieldCode;
    const node = nodes.find((candidate) => candidate.kind === "field" && candidate.fieldCode === boundFieldCode);
    return node
      ? [{
        nodeId: node.id,
        ruleCode: rule.code,
        trigger: formatRuleTrigger(rule)
      }]
      : [];
  });
}

function createJsonSchemaProtocol(fields: DraftFieldDefinition[]): FormDesignerSurface["schemaProtocol"]["jsonSchema"] {
  return {
    type: "object",
    required: fields.filter((field) => field.required).map((field) => field.code),
    properties: fields.reduce<FormDesignerSurface["schemaProtocol"]["jsonSchema"]["properties"]>((result, field) => {
      result[field.code] = {
        type: mapJsonSchemaFieldType(field.fieldType),
        title: field.name
      };
      return result;
    }, {})
  };
}

function createUiSchemaProtocol(workbench: DemoWorkbench): FormDesignerSurface["schemaProtocol"]["uiSchema"] {
  const nodes = getFormLayoutNodes(workbench, "form");
  const basicFields = nodes
    .filter((node) => node.kind === "field" && node.parentId === "form-basic-grid" && node.fieldCode)
    .map((node) => node.fieldCode ?? "");
  const businessFields = nodes
    .filter((node) => node.kind === "field" && node.parentId === "form-business-grid" && node.fieldCode)
    .map((node) => node.fieldCode ?? "");

  return {
    type: "VerticalLayout",
    elements: [
      {
        type: "Group",
        label: "基础信息",
        elements: basicFields.map((fieldCode) => ({
          type: "Control",
          scope: `#/properties/${fieldCode}`
        }))
      },
      ...businessFields.map((fieldCode) => ({
        type: "Control" as const,
        scope: `#/properties/${fieldCode}`
      }))
    ]
  };
}

function createFormilySchema(workbench: DemoWorkbench, reactions: FormilyReactionRule[]): FormilySchemaObject {
  const reactionsBySource = reactions.reduce<Record<string, FormilySchemaProperty["x-reactions"]>>((result, reaction) => {
    result[reaction.source] = [
      ...(result[reaction.source] ?? []),
      {
        target: reaction.target,
        when: reaction.when,
        fulfill: reaction.fulfill,
        otherwise: reaction.otherwise
      }
    ];
    return result;
  }, {});

  return {
    type: "object",
    "x-component": "Form",
    "x-component-props": {
      labelCol: 6,
      wrapperCol: 12
    },
    properties: workbench.recordSchema
      .filter((field) => isRuntimeField(field))
      .reduce<Record<string, FormilySchemaProperty>>((result, field) => {
        result[field.code] = {
          type: mapFormilySchemaFieldType(field.fieldType),
          title: field.name,
          required: field.required === true,
          enum: field.fieldType === "select" ? field.options ?? [] : undefined,
          "x-decorator": "FormItem",
          "x-component": mapFormilyComponent(field.fieldType),
          "x-component-props": createFormilyComponentProps(field),
          "x-validator": createFormilyValidators(field),
          "x-reactions": reactionsBySource[field.code]
        };
        return result;
      }, {})
  };
}

function createFormilyReactionDesigner(workbench: DemoWorkbench): FormilyReactionDesigner {
  const aggregated = new Map<string, FormilyReactionRule>();
  const rules = workbench.rules.flatMap<FormilyReactionRule>((rule) => {
    const condition = rule.condition;
    if (!rule.enabled || !condition) {
      return [];
    }

    return (rule.actions ?? [])
      .filter((action) => action.targetType === "field")
      .map((action) => ({
        source: condition.fieldCode ?? rule.fieldCode ?? "",
        target: action.targetCode,
        when: formatFormilyReactionWhen(condition),
        fulfill: {
          state: createFormilyReactionState(action, true)
        },
        otherwise: {
          state: createFormilyReactionState(action, false)
        }
      }))
      .filter((reaction) => reaction.source.length > 0 && reaction.target.length > 0);
  });

  for (const rule of rules) {
    const key = `${rule.source}|${rule.target}|${rule.when}`;
    const previous = aggregated.get(key);
    if (!previous) {
      aggregated.set(key, rule);
      continue;
    }

    aggregated.set(key, {
      ...previous,
      fulfill: {
        state: {
          ...previous.fulfill.state,
          ...rule.fulfill.state
        }
      },
      otherwise: {
        state: {
          ...previous.otherwise.state,
          ...rule.otherwise.state
        }
      }
    });
  }

  return {
    mode: "visual",
    rules: Array.from(aggregated.values())
  };
}

function createDesignableWorkbenchState(workbench: DemoWorkbench): DesignableWorkbenchState {
  return {
    selectedNodeId: `field-${workbench.selectedFieldCode}`,
    selectedFieldCode: workbench.selectedFieldCode,
    activePanel: "property-settings",
    history: {
      undoable: true,
      redoable: true
    },
    schemaEditor: {
      editable: true,
      validatesBeforeImport: true
    },
    dragSources: [
      { code: "Input", label: "文本输入" },
      { code: "NumberPicker", label: "数字输入" },
      { code: "DatePicker", label: "日期选择" },
      { code: "Select", label: "单选下拉" },
      { code: "FormGrid", label: "表单栅格" },
      { code: "FormTab", label: "标签页" }
    ],
    propertyBindings: [
      { path: "title", label: "字段标题" },
      { path: "required", label: "必填" },
      { path: "x-decorator", label: "装饰器" },
      { path: "x-component", label: "组件" },
      { path: "x-component-props", label: "组件属性" },
      { path: "x-validator", label: "校验器" },
      { path: "x-reactions", label: "联动规则" }
    ]
  };
}

function formatFormilyReactionWhen(condition: DesignerRuleCondition): string {
  if (condition.operator === "equals") {
    return `{{$self.value === '${String(condition.value ?? "")}'}}`;
  }
  if (condition.operator === "notEquals") {
    return `{{$self.value !== '${String(condition.value ?? "")}'}}`;
  }
  if (condition.operator === "notEmpty" || condition.operator === "required") {
    return "{{$self.value !== undefined && $self.value !== ''}}";
  }
  if (condition.operator === "empty") {
    return "{{$self.value === undefined || $self.value === ''}}";
  }
  if (condition.operator === "contains") {
    return `{{String($self.value ?? '').includes('${String(condition.value ?? "")}')}}`;
  }
  return "{{$self.value !== undefined}}";
}

function createFormilyReactionState(action: DesignerRuleAction, fulfilled: boolean): Record<string, unknown> {
  if (action.type === "show") {
    return { visible: fulfilled };
  }
  if (action.type === "hide") {
    return { visible: !fulfilled };
  }
  if (action.type === "require" || action.type === "required") {
    return { required: fulfilled };
  }
  if (action.type === "readonly") {
    return { disabled: fulfilled };
  }
  if (action.type === "setValue" || action.type === "calculate") {
    return fulfilled ? { value: action.value ?? "" } : { value: undefined };
  }
  return { visible: true };
}

function mapFormilySchemaFieldType(fieldType: string): string {
  if (fieldType === "decimal") {
    return "number";
  }
  if (fieldType === "checkbox") {
    return "boolean";
  }
  return "string";
}

function mapFormilyComponent(fieldType: string): string {
  const components: Record<string, string> = {
    text: "Input",
    decimal: "NumberPicker",
    date: "DatePicker",
    select: "Select",
    checkbox: "Checkbox",
    link: "AssociationSelect",
    richtext: "RichText"
  };
  return components[fieldType] ?? "Input";
}

function createFormilyComponentProps(field: DraftFieldDefinition): Record<string, unknown> {
  return {
    placeholder: field.placeholder ?? `请输入${field.name}`,
    allowClear: true,
    options: field.fieldType === "select"
      ? (field.options ?? []).map((option) => ({
        label: option,
        value: option
      }))
      : undefined
  };
}

function createFormilyValidators(field: DraftFieldDefinition): FormilySchemaProperty["x-validator"] {
  const validators: FormilySchemaProperty["x-validator"] = [];

  if (field.required) {
    validators.push({
      required: true,
      message: `${field.name}不能为空`
    });
  }
  if (field.fieldType === "date") {
    validators.push({
      format: "date",
      message: `${field.name}必须是日期`
    });
  }
  return validators;
}

function mapJsonSchemaFieldType(fieldType: string): string {
  if (fieldType === "decimal") {
    return "number";
  }
  if (fieldType === "checkbox") {
    return "boolean";
  }
  return "string";
}

function legacyRuleActions(rule: DesignerRuleDefinition): DesignerRuleAction[] {
  if (!rule.fieldCode) {
    return [];
  }
  return [
    {
      type: rule.operator === "required" ? "required" : "readonly",
      targetType: "field",
      targetCode: rule.fieldCode,
      effect: rule.operator === "required" ? "required" : "readonly"
    }
  ];
}

function ruleActionTargetExists(
  action: DesignerRuleAction,
  fieldCodes: Set<string>,
  sectionIds: Set<string>,
  actionCodes: Set<string>
): boolean {
  if (action.targetType === "field") {
    return fieldCodes.has(action.targetCode);
  }
  if (action.targetType === "section") {
    return sectionIds.has(action.targetCode);
  }
  if (action.targetType === "action") {
    return actionCodes.has(action.targetCode);
  }
  if (action.targetType === "submit") {
    return actionCodes.has(action.targetCode);
  }
  if (action.targetType === "notification") {
    return action.targetCode.length > 0;
  }
  return action.targetCode.length > 0;
}

function fieldHasWritablePermission(permissions: DesignerPermissionMatrix, fieldCode: string): boolean {
  return permissions.fieldPermissions.some((entry) => (
    entry.fieldCode === fieldCode && (entry.permission === "WRITE" || entry.permission === "READ" || entry.permission === "MASKED")
  ));
}

function findRuleConflicts(rules: DesignerRuleDefinition[]): DesignerRuleDiagnostic[] {
  const diagnostics: DesignerRuleDiagnostic[] = [];
  const seen = new Map<string, DesignerRuleDefinition>();

  for (const rule of rules) {
    for (const action of rule.actions ?? legacyRuleActions(rule)) {
      const effect = normalizeRuleActionEffect(action);
      if (!effect) {
        continue;
      }
      const key = `${formatRuleConditionKey(rule)}|${action.targetType}|${action.targetCode}`;
      const previous = seen.get(key);
      if (previous && hasOppositeRuleEffect(previous, effect, action.targetCode)) {
        diagnostics.push({
          code: "rule-conflict",
          severity: "blocking",
          ruleCode: rule.code,
          targetCode: action.targetCode,
          conditionKey: formatRuleConditionKey(rule),
          involvedRuleCodes: [previous.code, rule.code],
          priorityHint: "按 order 或显式优先级保留唯一生效动作",
          primaryAction: "打开规则冲突诊断",
          message: `规则 ${previous.name} 与 ${rule.name} 对同一条件和目标产生冲突动作`
        });
        continue;
      }
      seen.set(`${key}|${effect}`, rule);
      if (!previous) {
        seen.set(key, rule);
      }
    }
  }

  return diagnostics;
}

function hasOppositeRuleEffect(previous: DesignerRuleDefinition, effect: string, targetCode: string): boolean {
  return (previous.actions ?? legacyRuleActions(previous)).some((action) => (
    action.targetCode === targetCode && areOppositeRuleEffects(normalizeRuleActionEffect(action), effect)
  ));
}

function areOppositeRuleEffects(first?: string, second?: string): boolean {
  return (first === "visible" && second === "hidden") || (first === "hidden" && second === "visible");
}

function normalizeRuleActionEffect(action: DesignerRuleAction): string | undefined {
  if (action.effect) {
    return action.effect;
  }
  if (action.type === "show") {
    return "visible";
  }
  if (action.type === "hide") {
    return "hidden";
  }
  return action.type;
}

function formatRuleConditionKey(rule: DesignerRuleDefinition): string {
  const condition = rule.condition;
  if (!condition) {
    return `${rule.fieldCode ?? ""}:${rule.operator ?? ""}`;
  }
  return `${condition.fieldCode}.${condition.operator}.${String(condition.value ?? "")}`;
}

function formatRuleTrigger(rule: DesignerRuleDefinition): string {
  if (rule.actions?.some((action) => action.type === "submit" || action.type === "submitAction")) {
    return "提交动作";
  }
  if (rule.actions?.some((action) => action.type === "show" || action.type === "hide")) {
    return "字段联动";
  }
  return "保存校验";
}

function findRuleResourceId(workbench: DemoWorkbench, ruleCode: string): string {
  return workbench.rules.find((rule) => rule.code === ruleCode)?.resourceId ?? `rule:${workbench.objectCode}`;
}

function syncPageConfigsWithSchema(
  pageConfigs: Record<PageConfigName, DemoPageConfig>,
  schema: DraftFieldDefinition[]
): Record<PageConfigName, DemoPageConfig> {
  const listAllowed = new Set(schema.filter((field) => isRuntimeField(field) && !field.hidden && field.inList).map((field) => field.code));

  return {
    form: {
      ...pageConfigs.form,
      visibleFieldCodes: filterVisibleFieldCodes(pageConfigs.form.visibleFieldCodes, schema),
      layoutTree: syncLayoutTreeWithFieldCodes(
        pageConfigs.form.layoutTree ?? createDefaultFormLayoutTree("form", pageConfigs.form.visibleFieldCodes),
        filterVisibleFieldCodes(pageConfigs.form.visibleFieldCodes, schema)
      )
    },
    list: {
      ...pageConfigs.list,
      visibleFieldCodes: filterVisibleFieldCodes(pageConfigs.list.visibleFieldCodes, schema).filter((code) => listAllowed.has(code)),
      layoutTree: syncLayoutTreeWithFieldCodes(
        pageConfigs.list.layoutTree ?? createDefaultFormLayoutTree("list", pageConfigs.list.visibleFieldCodes),
        filterVisibleFieldCodes(pageConfigs.list.visibleFieldCodes, schema).filter((code) => listAllowed.has(code))
      )
    },
    detail: {
      ...pageConfigs.detail,
      visibleFieldCodes: filterVisibleFieldCodes(pageConfigs.detail.visibleFieldCodes, schema),
      layoutTree: syncLayoutTreeWithFieldCodes(
        pageConfigs.detail.layoutTree ?? createDefaultFormLayoutTree("detail", pageConfigs.detail.visibleFieldCodes),
        filterVisibleFieldCodes(pageConfigs.detail.visibleFieldCodes, schema)
      )
    }
  };
}

function reorderPageConfigsBySchema(
  pageConfigs: Record<PageConfigName, DemoPageConfig>,
  schema: DraftFieldDefinition[]
): Record<PageConfigName, DemoPageConfig> {
  const synced = syncPageConfigsWithSchema(pageConfigs, schema);
  const runtimeFieldCodes = schema.filter((field) => isRuntimeField(field) && !field.hidden).map((field) => field.code);
  const listFieldCodes = schema.filter((field) => isRuntimeField(field) && !field.hidden && field.inList).map((field) => field.code);

  return {
    form: {
      ...synced.form,
      visibleFieldCodes: orderVisibleCodesBySchema(synced.form.visibleFieldCodes, runtimeFieldCodes)
    },
    list: {
      ...synced.list,
      visibleFieldCodes: orderVisibleCodesBySchema(synced.list.visibleFieldCodes, listFieldCodes)
    },
    detail: {
      ...synced.detail,
      visibleFieldCodes: orderVisibleCodesBySchema(synced.detail.visibleFieldCodes, runtimeFieldCodes)
    }
  };
}

function applyPageConfigsToPages(
  rawPages: Record<PageConfigName, SessionPageSchema>,
  pageConfigs: Record<PageConfigName, DemoPageConfig>
): Record<PageConfigName, SessionPageSchema> {
  return {
    list: {
      ...rawPages.list,
      fields: pageConfigs.list.visibleFieldCodes
    },
    form: {
      ...rawPages.form,
      fields: pageConfigs.form.visibleFieldCodes
    },
    detail: {
      ...rawPages.detail,
      fields: pageConfigs.detail.visibleFieldCodes
    }
  };
}

function orderVisibleCodesBySchema(visibleCodes: string[], schemaOrderedCodes: string[]): string[] {
  const visible = new Set(visibleCodes);
  return schemaOrderedCodes.filter((code) => visible.has(code));
}

function filterVisibleFieldCodes(fieldCodes: string[], schema: DraftFieldDefinition[]): string[] {
  const runtimeFieldCodes = new Set(schema.filter((field) => isRuntimeField(field) && !field.hidden).map((field) => field.code));
  return fieldCodes.filter((code) => runtimeFieldCodes.has(code));
}

function isRuntimeField(field: DraftFieldDefinition): boolean {
  return field.fieldType !== "section" && field.fieldType !== "columns" && field.fieldType !== "note";
}

function formatPageLabel(page: PageConfigName): string {
  if (page === "form") {
    return "表单";
  }
  if (page === "list") {
    return "列表";
  }
  return "详情";
}

function resolvePreviewModeFromResource(resourceId: string, fallback: PreviewMode): PreviewMode {
  if (resourceId.endsWith(":list")) {
    return "list";
  }
  if (resourceId.endsWith(":form")) {
    return "form";
  }
  if (resourceId.endsWith(":detail")) {
    return "detail";
  }
  return fallback;
}

function normalizeDesignerResourceId(workbench: DemoWorkbench, resourceId: string): string {
  if (resourceId.startsWith(`rule:${workbench.objectCode}:`)) {
    return `object:${workbench.objectCode}`;
  }
  return resourceId;
}

function navigationStatusFromReadiness(
  readiness: DesignerReadinessReport,
  readinessCode: string
): DesignerNavigationNode["status"] {
  const item = readiness.items.find((candidate) => candidate.code === readinessCode);
  if (!item) {
    return "needs-review";
  }
  if (item.severity === "pass") {
    return "ready";
  }
  if (item.severity === "blocking") {
    return "needs-review";
  }
  return "needs-review";
}

function resolveDesignerFieldPermission(roleCode: string, fieldCode: string): DesignerPermissionCapability {
  if (fieldCode === "owner_link") {
    return "MASKED";
  }
  if (roleCode === "viewer") {
    return "READ";
  }
  return "WRITE";
}

function createWorkbenchFromSchema(
  schema: DraftFieldDefinition[],
  options?: {
    previewRecord?: Record<string, unknown>;
    selectedFieldCode?: string;
    previewMode?: PreviewMode;
    statusTag?: WorkbenchStatusTag;
    statusMessage?: string;
    hasUnpublishedChanges?: boolean;
    lastPublishedMetaHash?: string;
    pageConfigs?: Record<PageConfigName, DemoPageConfig>;
    rules?: DesignerRuleDefinition[];
  }
): DemoWorkbench {
  const objectCode = "customer_contract";
  const version = "v2026.07.07";
  let session = createSessionObject(createModelingSession("lowcode_demo"), {
    code: objectCode,
    name: "客户合同"
  });

  const visibleFields = schema.filter((field) => !field.hidden && isRuntimeField(field));
  for (const field of visibleFields) {
    session = addSessionField(session, objectCode, toBuilderField(field));
  }

  for (const field of visibleFields) {
    const latest = session.objects[objectCode]?.fields.find((item) => item.code === field.code);
    if (latest) {
      session = updateSessionField(session, objectCode, field.code, {
        name: field.name,
        fieldType: mapFieldType(field.fieldType),
        targetObjectCode: field.fieldType === "link" ? "employee" : undefined,
        sortNo: latest.sortNo
      });
    }
  }

  const rawPages = generateDefaultSessionPages(session, objectCode);
  const pageConfigs = options?.pageConfigs ?? createDefaultPageConfigs(schema);
  const syncedPageConfigs = syncPageConfigsWithSchema(pageConfigs, schema);
  const pages = applyPageConfigsToPages(rawPages, syncedPageConfigs);
  const previewRecord = ensurePreviewRecord(schema, options?.previewRecord);

  return {
    appCode: "lowcode_demo",
    objectCode,
    version,
    session,
    pages,
    pageConfigs: syncedPageConfigs,
    rules: options?.rules ?? DEMO_RULES,
    recordSchema: schema,
    previewRecord,
    selectedFieldCode: options?.selectedFieldCode ?? schema[0]?.code ?? "",
    previewMode: options?.previewMode ?? "form",
    activeDesignerMode: "page",
    activeResourceId: `page:${objectCode}:form`,
    statusTag: options?.statusTag ?? "draft",
    statusMessage: options?.statusMessage ?? "设计器工作台已就绪",
    hasUnpublishedChanges: options?.hasUnpublishedChanges ?? true,
    lastPublishedMetaHash: options?.lastPublishedMetaHash
  };
}

function ensurePreviewRecord(
  schema: DraftFieldDefinition[],
  previewRecord?: Record<string, unknown>
): Record<string, unknown> {
  return schema.reduce<Record<string, unknown>>((result, field) => {
    const currentValue = previewRecord?.[field.code];
    result[field.code] = isPreviewValueCompatible(field, currentValue) ? currentValue : createPreviewValue(field);
    return result;
  }, {});
}

function normalizePreviewRecordForSchema(
  schema: DraftFieldDefinition[],
  previewRecord: Record<string, unknown>,
  changedFieldCode: string
): Record<string, unknown> {
  return schema.reduce<Record<string, unknown>>((result, field) => {
    const currentValue = previewRecord[field.code];
    if (field.code === changedFieldCode) {
      result[field.code] = createPreviewValue(field);
      return result;
    }
    result[field.code] = isPreviewValueCompatible(field, currentValue) ? currentValue : createPreviewValue(field);
    return result;
  }, {});
}

function findField(workbench: DemoWorkbench, fieldCode: string): DraftFieldDefinition {
  const field = workbench.recordSchema.find((item) => item.code === fieldCode);
  if (!field) {
    throw new Error(`字段 ${fieldCode} 不存在`);
  }
  return field;
}

function createFieldFromDraft(draft: FieldDraftInput, existing: DraftFieldDefinition[]): DraftFieldDefinition {
  const label = draft.label.trim();
  if (!label) {
    throw new Error("字段名称不能为空");
  }

  return {
    code: ensureUniqueFieldCode(draft.codeHint || label, existing),
    name: label,
    fieldType: draft.fieldType,
    required: draft.required,
    inList: draft.inList,
    hidden: draft.hidden,
    options: normalizeOptionsText(draft.optionsText),
    placeholder: draft.placeholder?.trim() || undefined,
    helperText: draft.helperText?.trim() || undefined,
    defaultValue: draft.defaultValue?.trim() || undefined
  };
}

function normalizeFieldPatch(
  draft: DraftFieldDefinition,
  current: DraftFieldDefinition
): Partial<DraftFieldDefinition> {
  return {
    name: draft.name.trim() || current.name,
    fieldType: draft.fieldType,
    required: draft.required ?? false,
    inList: draft.hidden ? false : draft.inList,
    hidden: draft.hidden ?? false,
    options: draft.fieldType === "select" ? (draft.options ?? []) : undefined,
    placeholder: draft.placeholder?.trim() || undefined,
    helperText: draft.helperText?.trim() || undefined,
    defaultValue: draft.defaultValue?.trim() || undefined
  };
}

function ensureUniqueFieldCode(label: string, existing: DraftFieldDefinition[]): string {
  const base = slugifyFieldLabel(label) || "field";
  const used = new Set(existing.map((field) => field.code));
  if (!used.has(base)) {
    return base;
  }

  let index = 2;
  while (used.has(`${base}_${index}`)) {
    index += 1;
  }
  return `${base}_${index}`;
}

function slugifyFieldLabel(label: string): string {
  if (/^[a-zA-Z][a-zA-Z0-9_]*$/.test(label)) {
    return label.replace(/_+/g, "_").toLowerCase();
  }

  const specialMap: Record<string, string> = {
    审: "shen",
    批: "pi",
    备: "bei",
    注: "zhu"
  };
  const normalized = Array.from(label.trim())
    .map((char) => specialMap[char] ?? char)
    .join(" ")
    .replace(/[^a-zA-Z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .toLowerCase();

  return normalized.replace(/_+/g, "_");
}

function normalizeOptionsText(optionsText: string): string[] | undefined {
  const options = optionsText
    .split(/\r?\n|,/)
    .map((item) => item.trim())
    .filter(Boolean);

  return options.length > 0 ? options : undefined;
}

function renamePreviewValue(
  previewRecord: Record<string, unknown>,
  previousCode: string,
  nextCode: string
): Record<string, unknown> {
  if (previousCode === nextCode) {
    return { ...previewRecord };
  }

  const { [previousCode]: previousValue, ...rest } = previewRecord;
  return {
    ...rest,
    [nextCode]: previousValue
  };
}

function removePreviewValue(previewRecord: Record<string, unknown>, removedCode: string): Record<string, unknown> {
  const rest = { ...previewRecord };
  Reflect.deleteProperty(rest, removedCode);
  return rest;
}

function createPreviewValue(field: DraftFieldDefinition): unknown {
  if (field.defaultValue && isPreviewValueCompatible(field, field.defaultValue)) {
    return field.defaultValue;
  }

  switch (field.fieldType) {
    case "decimal":
      return "1200.50";
    case "date":
      return "2026-07-06";
    case "select":
      return field.options?.[0] ?? "retail";
    case "checkbox":
      return true;
    case "link":
      return "owner-001";
    case "richtext":
      return "<p>首发版本</p>";
    case "section":
      return "基础信息分组";
    case "columns":
      return "多列栅格";
    case "note":
      return "这里可以补充字段说明和填写提示";
    default:
      return defaultPreviewText(field.code);
  }
}

function isPreviewValueCompatible(field: DraftFieldDefinition, value: unknown): boolean {
  switch (field.fieldType) {
    case "decimal":
      return typeof value === "string" && /^-?\d+(\.\d+)?$/.test(value);
    case "date":
      return typeof value === "string" && /^\d{4}-\d{2}-\d{2}$/.test(value);
    case "select":
      return typeof value === "string" && (field.options ?? []).includes(value);
    case "checkbox":
      return typeof value === "boolean";
    case "text":
    case "link":
    case "richtext":
    case "section":
    case "columns":
    case "note":
      return typeof value === "string";
    default:
      return value !== undefined;
  }
}

function defaultPreviewText(fieldCode: string): string {
  const previewMap: Record<string, string> = {
    customer_name: "华北样板客户",
    summary_html: "<p>首发版本</p>"
  };
  return previewMap[fieldCode] ?? "";
}

function toBuilderField(field: DraftFieldDefinition): Omit<BuilderField, "sortNo"> {
  return {
    code: field.code,
    name: field.name,
    fieldType: mapFieldType(field.fieldType),
    targetObjectCode: field.fieldType === "link" ? "employee" : undefined
  };
}

function createPermissionPreset(preset: PublishOptions["permissionPreset"]): Record<string, FieldPermission> {
  if (preset === "operator") {
    return {
      customer_name: "WRITE",
      contract_amount: "WRITE",
      go_live_date: "WRITE",
      industry: "WRITE",
      is_active: "WRITE",
      owner_link: "MASKED",
      summary_html: "WRITE"
    };
  }
  return {
    customer_name: "READ",
    contract_amount: "READ",
    go_live_date: "READ",
    industry: "READ",
    is_active: "READ",
    owner_link: "MASKED",
    summary_html: "READ"
  };
}

function createRuntimeMeta(
  workbench: DemoWorkbench,
  requestMetaHash: string,
  permissions: Record<string, FieldPermission>
): RuntimeMeta {
  return {
    objectCode: workbench.objectCode,
    requestMetaHash,
    fields: workbench.recordSchema
      .filter((field) => !field.hidden)
      .map<ObjectField>((field) => ({
        code: field.code,
        name: field.name,
        fieldType: mapFieldType(field.fieldType),
        inList: field.inList,
        required: field.required
      })),
    permissions: buildFieldPermissions(workbench, permissions)
  };
}

function buildFieldPermissions(
  workbench: DemoWorkbench,
  permissions: Record<string, FieldPermission>
): Record<string, FieldPermission> {
  return workbench.recordSchema.reduce<Record<string, FieldPermission>>((result, field) => {
    result[field.code] = field.hidden ? "NONE" : (permissions[field.code] ?? "WRITE");
    return result;
  }, {});
}

function createRuntimePageSchema(
  schema: SessionPageSchema,
  pageType: RuntimePageSchema["pageType"]
): RuntimePageSchema {
  return {
    pageCode: schema.pageCode,
    pageType,
    fields: schema.fields
  };
}

function mapFieldType(fieldType: string): string {
  if (fieldType === "richtext") {
    return "rich_text";
  }
  if (fieldType === "checkbox") {
    return "boolean";
  }
  if (fieldType === "section" || fieldType === "columns" || fieldType === "note") {
    return "text";
  }
  return fieldType;
}

function clampDropIndex(targetIndex: number, maxIndex: number): number {
  if (targetIndex < 0) {
    return 0;
  }
  if (targetIndex > maxIndex) {
    return maxIndex;
  }
  return targetIndex;
}
