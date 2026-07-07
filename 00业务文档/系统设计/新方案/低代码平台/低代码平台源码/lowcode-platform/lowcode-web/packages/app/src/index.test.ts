import { describe, expect, it } from "vitest";
import {
  createAppTypeRegistry,
  createCsvEscapePreview,
  createDesignerReadinessReport,
  createDesignerWorkbench,
  createEmptyFieldDraft,
  getSelectedCanvasComponent,
  createPreviewSnapshot,
  createFieldDraftFromPalette,
  getBuiltInFieldTypes,
  getCommercialDesignerNavigation,
  getDesignerLayoutBlueprint,
  getFormLayoutNodes,
  getDesignerWorkflowBlueprint,
  getFormRuleCenter,
  getFormDesignerSurface,
  getFormTemplateCatalog,
  getIntegrationContract,
  getPermissionMatrix,
  getSchemaJsonView,
  publishWorkbench,
  selectDesignerResource,
  type DesignerRuleDefinition,
  updateFieldDraftValue,
  updateWorkbenchField,
  validateFormRuleCenter,
  validateDraftRecord
} from "./index";

describe("设计器工作台应用层", () => {
  it("注册 10 个可交互组件和 22 个占位字段能力", () => {
    const registry = createAppTypeRegistry();

    expect(registry.interactive.map((item) => item.code)).toEqual([
      "text",
      "decimal",
      "date",
      "select",
      "checkbox",
      "link",
      "richtext",
      "section",
      "columns",
      "note"
    ]);
    expect(registry.placeholder).toHaveLength(22);
  });

  it("组件库提供可拖拽字段和布局组件", () => {
    const registry = createAppTypeRegistry();

    expect(registry.interactive.map((item) => item.code)).toEqual([
      "text",
      "decimal",
      "date",
      "select",
      "checkbox",
      "link",
      "richtext",
      "section",
      "columns",
      "note"
    ]);
    expect(createFieldDraftFromPalette("section")).toMatchObject({
      label: "分组标题",
      fieldType: "section",
      inList: false
    });
  });

  it("新增字段草稿后可生成唯一编码并默认选中", () => {
    const workbench = createDesignerWorkbench();
    const next = updateFieldDraftValue(createEmptyFieldDraft(), "label", "审批备注");
    const nextType = updateFieldDraftValue(next, "fieldType", "text");
    const withField = updateWorkbenchField(workbench, {
      type: "add-field",
      draft: nextType
    });

    const added = withField.recordSchema.at(-1);

    expect(added?.code).toBe("shen_pi_bei_zhu");
    expect(added?.name).toBe("审批备注");
    expect(withField.selectedFieldCode).toBe("shen_pi_bei_zhu");
    expect(withField.previewRecord.shen_pi_bei_zhu).toBe("");
  });

  it("编辑字段属性后会同步到表单、列表与预览 schema", () => {
    const workbench = createDesignerWorkbench();
    const selected = updateWorkbenchField(workbench, {
      type: "select-field",
      fieldCode: "customer_name"
    });
    const renamed = updateWorkbenchField(selected, {
      type: "update-selected-field",
      patch: {
        name: "客户全称",
        fieldType: "select",
        required: false,
        hidden: true,
        options: ["央企", "零售"]
      }
    });
    const snapshot = createPreviewSnapshot(renamed, "list");

    const field = renamed.recordSchema.find((item) => item.code === "customer_name");

    expect(field).toMatchObject({
      name: "客户全称",
      fieldType: "select",
      required: false,
      hidden: true,
      options: ["央企", "零售"]
    });
    expect(renamed.pages.form.fields).not.toContain("customer_name");
    expect(renamed.pages.list.fields).not.toContain("customer_name");
    expect(snapshot.runtime.rows[0]).not.toHaveProperty("customer_name");
  });

  it("支持表单和列表预览的最小闭环", () => {
    const workbench = createDesignerWorkbench();
    const formPreview = createPreviewSnapshot(workbench, "form");
    const listPreview = createPreviewSnapshot(workbench, "list");

    expect(formPreview.runtime.fields.map((field) => field.code)).toContain("customer_name");
    expect(listPreview.runtime.rows[0]).toEqual({
      customer_name: "华北样板客户",
      contract_amount: "1200.50",
      go_live_date: "2026-07-06",
      industry: "retail",
      is_active: true,
      owner_link: "***",
      summary_html: "<p>首发版本</p>"
    });
  });

  it("支持详情预览并返回字段视图模型", () => {
    const workbench = createDesignerWorkbench();
    const detailPreview = createPreviewSnapshot(workbench, "detail");

    expect(detailPreview.mode).toBe("detail");
    expect(detailPreview.runtime.pageType).toBe("detail");
    expect(detailPreview.runtime.fields.map((field) => field.code)).toContain("contract_amount");
  });

  it("删除选中字段后会同步移除预览和 schema", () => {
    const workbench = createDesignerWorkbench();
    const selected = updateWorkbenchField(workbench, {
      type: "select-field",
      fieldCode: "industry"
    });
    const removed = updateWorkbenchField(selected, {
      type: "delete-selected-field"
    });
    const listPreview = createPreviewSnapshot(removed, "list");

    expect(removed.recordSchema.map((field) => field.code)).not.toContain("industry");
    expect(removed.previewRecord).not.toHaveProperty("industry");
    expect(removed.selectedFieldCode).toBe("go_live_date");
    expect(listPreview.runtime.rows[0]).not.toHaveProperty("industry");
  });

  it("支持字段上移和下移排序", () => {
    const workbench = createDesignerWorkbench();
    const selected = updateWorkbenchField(workbench, {
      type: "select-field",
      fieldCode: "industry"
    });
    const movedUp = updateWorkbenchField(selected, {
      type: "move-selected-field",
      direction: "up"
    });
    const movedDown = updateWorkbenchField(movedUp, {
      type: "move-selected-field",
      direction: "down"
    });

    expect(movedUp.recordSchema.map((field) => field.code).slice(0, 4)).toEqual([
      "customer_name",
      "contract_amount",
      "industry",
      "go_live_date"
    ]);
    expect(movedDown.recordSchema.map((field) => field.code).slice(0, 4)).toEqual([
      "customer_name",
      "contract_amount",
      "go_live_date",
      "industry"
    ]);
  });

  it("支持从组件库拖入字段到指定画布位置", () => {
    const workbench = createDesignerWorkbench();
    const next = updateWorkbenchField(workbench, {
      type: "drop-palette-field",
      fieldType: "note",
      targetIndex: 1
    });

    expect(next.recordSchema.map((field) => field.code).slice(0, 3)).toEqual([
      "customer_name",
      "shuoming_wenben",
      "contract_amount"
    ]);
    expect(next.selectedFieldCode).toBe("shuoming_wenben");
    expect(next.statusMessage).toContain("已拖入组件");
  });

  it("支持画布内拖拽字段重新排序", () => {
    const workbench = createDesignerWorkbench();
    const next = updateWorkbenchField(workbench, {
      type: "drop-existing-field",
      sourceFieldCode: "industry",
      targetIndex: 1
    });

    expect(next.recordSchema.map((field) => field.code).slice(0, 4)).toEqual([
      "customer_name",
      "industry",
      "contract_amount",
      "go_live_date"
    ]);
    expect(next.selectedFieldCode).toBe("industry");
    expect(next.statusMessage).toContain("已拖拽排序");
  });

  it("属性面板可读取当前选中的画布组件信息", () => {
    const workbench = updateWorkbenchField(createDesignerWorkbench(), {
      type: "select-field",
      fieldCode: "industry"
    });
    const component = getSelectedCanvasComponent(workbench);

    expect(component).toEqual({
      fieldCode: "industry",
      fieldName: "行业",
      pageType: "form",
      componentType: "form-field",
      visible: true,
      sortIndex: 3
    });
  });

  it("页面配置可切换可见字段与布局，并同步到运行态预览", () => {
    const workbench = updateWorkbenchField(createDesignerWorkbench(), {
      type: "update-page-config",
      page: "list",
      patch: {
        visibleFieldCodes: ["industry", "customer_name"],
        layout: {
          columns: 1,
          density: "compact"
        }
      }
    });
    const snapshot = createPreviewSnapshot(workbench, "list");

    expect(workbench.pageConfigs.list).toMatchObject({
      visibleFieldCodes: ["industry", "customer_name"],
      layout: {
        columns: 1,
        density: "compact"
      }
    });
    expect(workbench.pages.list.fields).toEqual(["industry", "customer_name"]);
    expect(Object.keys(snapshot.runtime.rows[0] ?? {})).toEqual(["industry", "customer_name"]);
    expect(workbench.statusTag).toBe("draft");
    expect(workbench.hasUnpublishedChanges).toBe(true);
  });

  it("字段类型变更会同步归一化预览记录，避免发布快照保留旧类型值", () => {
    const workbench = updateWorkbenchField(createDesignerWorkbench(), {
      type: "update-selected-field",
      patch: {
        fieldType: "select",
        options: ["北区", "南区"],
        defaultValue: "南区"
      }
    });
    const snapshot = createPreviewSnapshot(workbench, "form");
    const customerName = snapshot.runtime.fields.find((field) => field.code === "customer_name");

    expect(workbench.previewRecord.customer_name).toBe("南区");
    expect(customerName).toMatchObject({
      code: "customer_name",
      fieldType: "select",
      value: "南区"
    });
    expect(validateDraftRecord(workbench, workbench.previewRecord).valid).toBe(true);
  });

  it("拖拽新增组件后继续编辑属性会保持草稿未发布状态", () => {
    const workbench = updateWorkbenchField(createDesignerWorkbench(), {
      type: "drop-palette-field",
      fieldType: "note",
      targetIndex: 1
    });
    const updated = updateWorkbenchField(workbench, {
      type: "update-selected-field",
      patch: {
        name: "说明提示",
        placeholder: "请输入说明",
        helperText: "用于展示当前步骤提示",
        defaultValue: "默认说明"
      }
    });

    const field = updated.recordSchema.find((item) => item.code === "shuoming_wenben");
    expect(field).toMatchObject({
      name: "说明提示",
      placeholder: "请输入说明",
      helperText: "用于展示当前步骤提示",
      defaultValue: "默认说明"
    });
    expect(updated.statusTag).toBe("draft");
    expect(updated.hasUnpublishedChanges).toBe(true);
  });

  it("属性变更后会标记草稿未发布状态", () => {
    const workbench = createDesignerWorkbench();
    const updated = updateWorkbenchField(workbench, {
      type: "update-selected-field",
      patch: {
        name: "客户简称"
      }
    });

    expect(updated.statusTag).toBe("draft");
    expect(updated.statusMessage).toContain("草稿");
    expect(updated.statusMessage).toContain("客户简称");
  });

  it("保存和发布动作会反馈状态并清除草稿标记", () => {
    const workbench = updateWorkbenchField(createDesignerWorkbench(), {
      type: "add-field",
      draft: updateFieldDraftValue(createEmptyFieldDraft(), "label", "审批备注")
    });
    const saved = updateWorkbenchField(workbench, {
      type: "save-draft"
    });
    const published = updateWorkbenchField(saved, {
      type: "publish-success",
      metaHash: "mh-demo"
    });

    expect(saved.statusTag).toBe("saved");
    expect(saved.statusMessage).toContain("已保存草稿");
    expect(published.statusTag).toBe("published");
    expect(published.statusMessage).toContain("mh-demo");
    expect(published.hasUnpublishedChanges).toBe(false);
  });

  it("把对象建模发布成带 metaHash 和幂等键的运行态快照", () => {
    const published = publishWorkbench(createDesignerWorkbench(), {
      permissionPreset: "operator",
      traceId: "trace-publish-001",
      idempotencyKey: "publish-demo-001"
    });

    expect(published.publishRequest.metaVersion).toBe("v2026.07.07");
    expect(published.publishRequest.traceId).toBe("trace-publish-001");
    expect(published.publishRequest.payload.idempotencyKey).toBe("publish-demo-001");
    expect(published.publishRequest.payload.metaHash).toMatch(/^mh-/);
    expect(published.runtime.form.fields.map((field) => field.code)).toEqual([
      "customer_name",
      "contract_amount",
      "go_live_date",
      "industry",
      "is_active",
      "owner_link",
      "summary_html"
    ]);
  });

  it("发布快照包含页面 schema 版本和页面快照元数据", () => {
    const published = publishWorkbench(createDesignerWorkbench(), {
      permissionPreset: "operator",
      traceId: "trace-publish-schema",
      idempotencyKey: "publish-schema-001"
    });

    expect(published.publishRequest.payload).toMatchObject({
      objectCode: "customer_contract",
      pageSchemaVersion: "page-schema-v1"
    });
    expect(published.publishRequest.payload.pages.form).toEqual({
      pageCode: "customer_contract_form",
      pageType: "form",
      fields: [
        "customer_name",
        "contract_amount",
        "go_live_date",
        "industry",
        "is_active",
        "owner_link",
        "summary_html"
      ]
    });
  });

  it("预览快照会为 renderer 附带 requestId 与 pageSchemaVersion", () => {
    const snapshot = createPreviewSnapshot(createDesignerWorkbench(), "detail");

    expect(snapshot.published.publishRequest.traceId).toBe("trace-preview-detail");
    expect(snapshot.published.runtime.detail.requestId).toBe("trace-preview-detail");
    expect(snapshot.published.runtime.detail.pageSchemaVersion).toBe("page-schema-v1");
  });

  it("用运行时 schema 校验动态对象并阻断非法值", () => {
    const workbench = createDesignerWorkbench();
    const invalid = validateDraftRecord(workbench, {
      customer_name: "",
      contract_amount: 100,
      go_live_date: "2026/07/06",
      industry: "unknown",
      is_active: "true",
      owner_link: 12,
      summary_html: "<p onclick=\"alert(1)\">坏内容</p>"
    });

    expect(invalid.valid).toBe(false);
    expect(invalid.errors).toEqual([
      { field: "customer_name", message: "客户名称不能为空" },
      { field: "contract_amount", message: "合同金额必须是十进制字符串" },
      { field: "go_live_date", message: "上线日期必须是 yyyy-MM-dd" },
      { field: "industry", message: "行业必须来自已配置选项" },
      { field: "is_active", message: "是否启用必须是布尔值" },
      { field: "owner_link", message: "负责人链接必须是字符串" }
    ]);
  });

  it("生成 CSV 公式转义和错误条 traceId 演示数据", () => {
    const preview = createCsvEscapePreview(["=SUM(A1:A2)", "+cmd", "safe"]);
    const published = publishWorkbench(createDesignerWorkbench(), {
      permissionPreset: "viewer",
      traceId: "trace-error-009",
      idempotencyKey: "publish-demo-002"
    });

    expect(preview).toEqual([
      { raw: "=SUM(A1:A2)", escaped: "'=SUM(A1:A2)" },
      { raw: "+cmd", escaped: "'+cmd" },
      { raw: "safe", escaped: "safe" }
    ]);
    expect(published.previewError).toEqual({
      code: "LC-META-4091",
      message: "当前预览基于旧版元数据，请刷新后重试。",
      traceId: "trace-error-009"
    });
  });

  it("暴露 renderer 内建字段类型列表", () => {
    expect(getBuiltInFieldTypes()).toContain("rich_text");
  });

  it("提供商业应用设计器资源树而不是单对象字段列表", () => {
    const workbench = createDesignerWorkbench();
    const navigation = getCommercialDesignerNavigation(workbench);

    expect(navigation.sections.map((section) => section.code)).toEqual([
      "application",
      "modeling",
      "experience",
      "automation",
      "governance",
      "integration"
    ]);
    expect(navigation.nodes.map((node) => node.id)).toEqual([
      "app:lowcode_demo",
      "object:customer_contract",
      "page:customer_contract:list",
      "page:customer_contract:form",
      "page:customer_contract:detail",
      "workflow:customer_contract:approval",
      "permission:customer_contract",
      "integration:customer_contract"
    ]);
    expect(navigation.nodes.find((node) => node.id === workbench.activeResourceId)?.active).toBe(true);
  });

  it("支持在对象、页面、流程、权限和集成资源之间切换设计上下文", () => {
    const workflow = selectDesignerResource(createDesignerWorkbench(), "workflow:customer_contract:approval");
    const permission = selectDesignerResource(workflow, "permission:customer_contract");
    const integration = selectDesignerResource(permission, "integration:customer_contract");

    expect(workflow.activeDesignerMode).toBe("workflow");
    expect(workflow.statusMessage).toContain("审批流程");
    expect(permission.activeDesignerMode).toBe("permission");
    expect(integration.activeDesignerMode).toBe("integration");
  });

  it("生成商业发布检查报告并暴露规则提醒、流程、权限和集成基线", () => {
    const report = createDesignerReadinessReport(createDesignerWorkbench());

    expect(report.summary.total).toBeGreaterThanOrEqual(6);
    expect(report.summary.blocking).toBe(0);
    expect(report.summary.publishable).toBe(true);
    expect(report.items.map((item) => item.code)).toEqual([
      "object-fields",
      "page-layout",
      "business-rules",
      "workflow-approval",
      "permission-matrix",
      "integration-contract"
    ]);
    expect(report.items.map((item) => item.resourceId)).toEqual([
      "object:customer_contract",
      "page:customer_contract:form",
      "rule:customer_contract",
      "workflow:customer_contract:approval",
      "permission:customer_contract",
      "integration:customer_contract"
    ]);
    expect(report.items.find((item) => item.code === "business-rules")).toMatchObject({
      severity: "pass",
      status: "passed"
    });
    expect(report.items.find((item) => item.code === "workflow-approval")).toMatchObject({
      severity: "pass",
      status: "passed"
    });
    expect(report.items.find((item) => item.code === "permission-matrix")).toMatchObject({
      severity: "pass",
      status: "passed"
    });
  });

  it("业务规则引用不存在字段时会升级为阻断问题并定位到规则资源", () => {
    const workbench = updateWorkbenchField(
      updateWorkbenchField(createDesignerWorkbench(), {
        type: "select-field",
        fieldCode: "contract_amount"
      }),
      {
        type: "delete-selected-field"
      }
    );
    const report = createDesignerReadinessReport(workbench);

    expect(report.items.find((item) => item.code === "business-rules")).toMatchObject({
      severity: "blocking",
      status: "blocked",
      resourceId: "rule:customer_contract:amount-required"
    });
  });

  it("商业页面设计会输出列表、表单、详情的布局蓝图和字段映射", () => {
    const blueprint = getDesignerLayoutBlueprint(createDesignerWorkbench());

    expect(blueprint.pages.map((page) => page.pageType)).toEqual(["list", "form", "detail"]);
    expect(blueprint.pages.find((page) => page.pageType === "form")).toMatchObject({
      title: "客户合同表单页",
      columns: 4,
      density: "comfortable",
      nodeCount: 15
    });
    expect(blueprint.pages.find((page) => page.pageType === "list")?.fields.map((field) => field.code)).toContain("contract_amount");
  });

  it("表单页会生成独立布局树而不是只依赖字段顺序", () => {
    const workbench = createDesignerWorkbench();
    const nodes = getFormLayoutNodes(workbench, "form");

    expect(nodes.map((node) => node.kind)).toEqual([
      "form",
      "body",
      "section",
      "grid",
      "field",
      "field",
      "section",
      "grid",
      "field",
      "field",
      "field",
      "field",
      "field",
      "action-bar",
      "action"
    ]);
    expect(nodes.find((node) => node.id === "form-basic")?.label).toBe("基础信息");
    expect(nodes.find((node) => node.id === "form-basic-grid")).toMatchObject({
      kind: "grid",
      columns: 4
    });
    expect(nodes.find((node) => node.id === "field-customer_name")).toMatchObject({
      kind: "field",
      fieldCode: "customer_name",
      parentId: "form-basic-grid",
      span: 2
    });
    expect(workbench.recordSchema.map((field) => field.code)).not.toContain("form-basic");
  });

  it("商业布局蓝图会暴露容器节点、字段绑定和动态规则入口", () => {
    const blueprint = getDesignerLayoutBlueprint(createDesignerWorkbench());
    const formPage = blueprint.pages.find((page) => page.pageType === "form");

    expect(formPage?.nodeCount).toBeGreaterThan(formPage?.fields.length ?? 0);
    expect(formPage?.containers.map((container) => container.kind)).toContain("section");
    expect(formPage?.containers.map((container) => container.label)).toContain("业务属性");
    expect(formPage?.fieldBindings.find((binding) => binding.fieldCode === "owner_link")).toMatchObject({
      nodeId: "field-owner_link",
      sectionId: "form-business"
    });
    expect(formPage?.ruleBindings).toContainEqual({
      nodeId: "field-contract_amount",
      ruleCode: "amount-required",
      trigger: "保存校验"
    });
  });

  it("表单布局器支持容器级多列栅格和字段跨列而不是固定两列", () => {
    const workbench = createDesignerWorkbench();
    const nodes = getFormLayoutNodes(workbench, "form");
    const blueprint = getDesignerLayoutBlueprint(workbench);
    const formPage = blueprint.pages.find((page) => page.pageType === "form");

    expect(nodes.find((node) => node.id === "form-business-grid")).toMatchObject({
      kind: "grid",
      columns: 4,
      minColumns: 1,
      maxColumns: 6,
      responsive: "auto-fit"
    });
    expect(nodes.find((node) => node.id === "field-owner_link")).toMatchObject({
      kind: "field",
      span: 2
    });
    expect(nodes.find((node) => node.id === "field-summary_html")).toMatchObject({
      kind: "field",
      span: 4
    });
    expect(formPage?.fieldBindings.find((binding) => binding.fieldCode === "summary_html")).toMatchObject({
      span: 4
    });
  });

  it("表单设计器提供全局规则中心并暴露 IF/THEN 条件动作", () => {
    const center = getFormRuleCenter(createDesignerWorkbench());

    expect(center.resourceId).toBe("rule:customer_contract");
    expect(center.previewTest.enabled).toBe(true);
    expect(center.previewTest.sampleRecord.customer_name).toBe("华北样板客户");
    expect(center.rules.map((rule) => rule.code)).toEqual([
      "amount-required",
      "industry-service-summary-required",
      "submit-approval-action"
    ]);
    expect(center.rules[1]).toMatchObject({
      condition: {
        fieldCode: "industry",
        operator: "equals",
        value: "service"
      },
      actions: expect.arrayContaining([
        expect.objectContaining({
          type: "require",
          targetType: "field",
          targetCode: "summary_html"
        }),
        expect.objectContaining({
          type: "show",
          targetType: "section",
          targetCode: "form-business"
        })
      ])
    });
  });

  it("规则中心会检测失效目标、规则冲突和隐藏不等于权限", () => {
    const workbench = createDesignerWorkbench();
    const extraRules: DesignerRuleDefinition[] = [
      {
        code: "hide-owner",
        name: "隐藏负责人",
        resourceId: "rule:customer_contract:hide-owner",
        order: 40,
        enabled: true,
        scope: "form",
        condition: {
          fieldCode: "industry",
          operator: "equals",
          value: "retail"
        },
        actions: [
          {
            type: "hide",
            targetType: "field",
            targetCode: "owner_link",
            effect: "hidden"
          }
        ],
        message: "只隐藏负责人，不改变字段权限"
      },
      {
        code: "show-owner-conflict",
        name: "显示负责人冲突规则",
        resourceId: "rule:customer_contract:show-owner-conflict",
        order: 41,
        enabled: true,
        scope: "form",
        condition: {
          fieldCode: "industry",
          operator: "equals",
          value: "retail"
        },
        actions: [
          {
            type: "show",
            targetType: "field",
            targetCode: "owner_link",
            effect: "visible"
          }
        ],
        message: "与隐藏负责人规则冲突"
      },
      {
        code: "missing-target",
        name: "缺失目标规则",
        resourceId: "rule:customer_contract:missing-target",
        order: 42,
        enabled: true,
        scope: "form",
        condition: {
          fieldCode: "industry",
          operator: "equals",
          value: "retail"
        },
        actions: [
          {
            type: "readonly",
            targetType: "field",
            targetCode: "missing_field",
            effect: "readonly"
          }
        ],
        message: "引用不存在字段"
      }
    ];
    const broken = {
      ...workbench,
      rules: [
        ...workbench.rules,
        ...extraRules
      ]
    };
    const diagnostics = validateFormRuleCenter(broken);

    expect(diagnostics.find((item) => item.code === "rule-target-missing")).toMatchObject({
      severity: "blocking",
      ruleCode: "missing-target",
      targetCode: "missing_field"
    });
    expect(diagnostics.find((item) => item.code === "rule-conflict")).toMatchObject({
      severity: "blocking",
      targetCode: "owner_link"
    });
    expect(diagnostics.find((item) => item.code === "hidden-without-permission")).toMatchObject({
      severity: "warning",
      ruleCode: "hide-owner",
      targetCode: "owner_link"
    });
  });

  it("提交动作规则会绑定工作流动作并参与发布门禁", () => {
    const workbench = createDesignerWorkbench();
    const center = getFormRuleCenter(workbench);
    const report = createDesignerReadinessReport(workbench);

    expect(center.rules.find((rule) => rule.code === "submit-approval-action")?.actions).toContainEqual({
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
    });
    expect(report.items.find((item) => item.code === "business-rules")).toMatchObject({
      severity: "pass",
      status: "passed"
    });
  });

  it("表单模板目录支持新增、编辑和详情模板共享后派生", () => {
    const catalog = getFormTemplateCatalog(createDesignerWorkbench());

    expect(catalog.templates.map((template) => template.code)).toEqual([
      "create-form",
      "edit-form",
      "detail-form"
    ]);
    expect(catalog.templates.find((template) => template.code === "edit-form")).toMatchObject({
      sourceTemplateCode: "create-form",
      reuseStrategy: "reference"
    });
    expect(catalog.templates.find((template) => template.code === "detail-form")?.readonly).toBe(true);
  });

  it("高级 Schema 视图输出字段、布局、规则、权限和工作流的统一 JSON", () => {
    const schemaView = getSchemaJsonView(createDesignerWorkbench());

    expect(schemaView.resourceId).toBe("schema:customer_contract");
    expect(schemaView.schema.fields.map((field) => field.code)).toContain("customer_name");
    expect(schemaView.schema.layout.pages.find((page) => page.pageType === "form")?.containers.length).toBeGreaterThan(0);
    expect(schemaView.schema.rules.rules.map((rule) => rule.code)).toContain("submit-approval-action");
    expect(schemaView.schema.permissions.fieldPermissions.map((entry) => entry.fieldCode)).toContain("owner_link");
    expect(schemaView.schema.workflow.transitions.map((transition) => transition.actionCode)).toContain("submit");
  });

  it("页面列数配置会同步到布局树容器并限制在一到六列", () => {
    const workbench = createDesignerWorkbench();
    const sixColumn = updateWorkbenchField(workbench, {
      type: "update-page-config",
      page: "form",
      patch: {
        layout: {
          columns: 6,
          density: "comfortable"
        }
      }
    });
    const overflow = updateWorkbenchField(workbench, {
      type: "update-page-config",
      page: "form",
      patch: {
        layout: {
          columns: 99,
          density: "comfortable"
        }
      }
    });

    expect(sixColumn.pageConfigs.form.layout.columns).toBe(6);
    expect(getFormLayoutNodes(sixColumn, "form").find((node) => node.id === "form-business-grid")).toMatchObject({
      columns: 6,
      maxColumns: 6
    });
    expect(overflow.pageConfigs.form.layout.columns).toBe(6);
  });

  it("商业流程设计会输出节点、流转和发布门禁状态", () => {
    const workbench = createDesignerWorkbench();
    const workflow = getDesignerWorkflowBlueprint(workbench);

    expect(workflow.resourceId).toBe("workflow:customer_contract:approval");
    expect(workflow.nodes.map((node) => node.kind)).toEqual(["start", "approval", "end"]);
    expect(workflow.transitions.map((transition) => transition.actionCode)).toEqual(["submit", "approve"]);
    expect(workflow.publishReady).toBe(true);
  });

  it("权限矩阵会覆盖角色、页面、字段和按钮动作，并参与发布检查", () => {
    const workbench = createDesignerWorkbench();
    const matrix = getPermissionMatrix(workbench);
    const report = createDesignerReadinessReport(workbench);

    expect(matrix.roles.map((role) => role.code)).toEqual(["admin", "operator", "viewer"]);
    expect(matrix.entries).toContainEqual({
      roleCode: "operator",
      resourceId: "page:customer_contract:form",
      capability: "WRITE"
    });
    expect(matrix.fieldPermissions).toContainEqual({
      roleCode: "viewer",
      fieldCode: "owner_link",
      permission: "MASKED"
    });
    expect(matrix.actionPermissions).toContainEqual({
      roleCode: "operator",
      actionCode: "submit",
      allowed: true
    });
    expect(report.items.find((item) => item.code === "permission-matrix")).toMatchObject({
      severity: "pass",
      status: "passed"
    });
  });

  it("集成契约会覆盖导入、导出、开放 API 和应用包能力", () => {
    const contract = getIntegrationContract(createDesignerWorkbench());

    expect(contract.resourceId).toBe("integration:customer_contract");
    expect(contract.channels.map((channel) => channel.code)).toEqual(["import", "export", "open-api", "app-package"]);
    expect(contract.channels.every((channel) => channel.idempotent)).toBe(true);
    expect(contract.channels.find((channel) => channel.code === "export")).toMatchObject({
      securityPolicy: "字段权限裁剪 + CSV 公式转义"
    });
  });

  it("发布检查会在规则、流程、权限完整后只保留集成契约提醒", () => {
    const report = createDesignerReadinessReport(createDesignerWorkbench());

    expect(report.summary).toMatchObject({
      total: 6,
      passed: 5,
      warning: 1,
      blocking: 0,
      publishable: true
    });
    expect(report.items.find((item) => item.code === "business-rules")).toMatchObject({
      severity: "pass",
      status: "passed"
    });
    expect(report.items.find((item) => item.code === "workflow-approval")).toMatchObject({
      severity: "pass",
      status: "passed"
    });
    expect(report.items.find((item) => item.code === "integration-contract")).toMatchObject({
      severity: "warning",
      status: "needs-review"
    });
  });

  it("资源树状态会跟随发布检查结果，而不是硬编码待完善", () => {
    const navigation = getCommercialDesignerNavigation(createDesignerWorkbench());

    expect(navigation.nodes.find((node) => node.id === "workflow:customer_contract:approval")).toMatchObject({
      status: "ready"
    });
    expect(navigation.nodes.find((node) => node.id === "permission:customer_contract")).toMatchObject({
      status: "ready"
    });
    expect(navigation.nodes.find((node) => node.id === "integration:customer_contract")).toMatchObject({
      status: "needs-review"
    });
  });

  it("发布检查项会给出中文修复建议和主操作入口", () => {
    const report = createDesignerReadinessReport(createDesignerWorkbench());

    expect(report.items.find((item) => item.code === "business-rules")).toMatchObject({
      fixHint: "持续通过预览测试验证字段联动和提交动作。",
      primaryAction: "查看规则中心"
    });
    expect(report.items.find((item) => item.code === "integration-contract")).toMatchObject({
      fixHint: "进入集成设计，确认外部系统、鉴权方式、幂等键和失败处理策略。",
      primaryAction: "确认集成契约"
    });
  });

  it("列表页配置会过滤不允许列表展示的字段", () => {
    const workbench = updateWorkbenchField(
      updateWorkbenchField(createDesignerWorkbench(), {
        type: "select-field",
        fieldCode: "summary_html"
      }),
      {
        type: "update-selected-field",
        patch: {
          inList: false
        }
      }
    );
    const updated = updateWorkbenchField(workbench, {
      type: "update-page-config",
      page: "list",
      patch: {
        visibleFieldCodes: ["summary_html", "customer_name"]
      }
    });

    expect(updated.pageConfigs.list.visibleFieldCodes).toEqual(["customer_name"]);
    expect(updated.pages.list.fields).toEqual(["customer_name"]);
    expect(createPreviewSnapshot(updated, "list").runtime.rows[0]).not.toHaveProperty("summary_html");
  });

  it("隐藏字段会从所有页面、运行态预览和画布选中态中剔除", () => {
    const workbench = updateWorkbenchField(
      updateWorkbenchField(createDesignerWorkbench(), {
        type: "select-field",
        fieldCode: "industry"
      }),
      {
        type: "update-selected-field",
        patch: {
          hidden: true
        }
      }
    );

    expect(workbench.pageConfigs.form.visibleFieldCodes).not.toContain("industry");
    expect(workbench.pageConfigs.list.visibleFieldCodes).not.toContain("industry");
    expect(workbench.pageConfigs.detail.visibleFieldCodes).not.toContain("industry");
    expect(workbench.pages.form.fields).not.toContain("industry");
    expect(workbench.pages.list.fields).not.toContain("industry");
    expect(workbench.pages.detail.fields).not.toContain("industry");
    expect(getSelectedCanvasComponent(workbench)).toMatchObject({
      fieldCode: "industry",
      visible: false,
      sortIndex: -1
    });
    expect(publishWorkbench(workbench, {
      permissionPreset: "operator",
      traceId: "trace-hidden-field",
      idempotencyKey: "publish-hidden-field"
    }).runtime.form.fields.map((field) => field.code)).not.toContain("industry");
  });

  it("发布前会阻断引用未知字段的页面 schema", () => {
    const workbench = createDesignerWorkbench();
    const published = publishWorkbench({
      ...workbench,
      pages: {
        ...workbench.pages,
        list: {
          ...workbench.pages.list,
          fields: [...workbench.pages.list.fields, "ghost_field"]
        }
      }
    }, {
      permissionPreset: "operator",
      traceId: "trace-invalid-page-schema",
      idempotencyKey: "publish-invalid-page-schema"
    });

    expect(published.previewError).toEqual({
      code: "LC-META-4221",
      message: "页面 schema 发布校验失败：list: 字段 ghost_field 不存在",
      traceId: "trace-invalid-page-schema"
    });
  });

  it("布局组件不会污染业务字段权限和运行态元数据", () => {
    const workbench = updateWorkbenchField(createDesignerWorkbench(), {
      type: "drop-palette-field",
      fieldType: "section",
      targetIndex: 1
    });
    const published = publishWorkbench(workbench, {
      permissionPreset: "operator",
      traceId: "trace-layout-component",
      idempotencyKey: "publish-layout-component"
    });
    const matrix = getPermissionMatrix(workbench);

    expect(workbench.recordSchema.map((field) => field.code)).toContain("fen_zu_biao_ti");
    expect(published.runtime.form.fields.map((field) => field.code)).not.toContain("fen_zu_biao_ti");
    expect(matrix.fieldPermissions.map((entry) => entry.fieldCode)).not.toContain("fen_zu_biao_ti");
    expect(validateDraftRecord(workbench, workbench.previewRecord).valid).toBe(true);
  });
});

describe("表单设计器知识库验收缺口", () => {
  it("规则中心全局模型应统一承载表单定义、版本快照、预览测试和发布门禁", () => {
    const center = getFormRuleCenter(createDesignerWorkbench());

    expect(center).toMatchObject({
      resourceId: "rule:customer_contract",
      scope: "global",
      ownerObjectCode: "customer_contract",
      formDefinitionCode: "customer_contract.default",
      versionMode: "draft-and-published-snapshot",
      publishGate: {
        validatesDanglingReference: true,
        validatesConflict: true,
        validatesPermissionBoundary: true
      },
      previewTest: {
        enabled: true,
        coversAllEnabledRules: true
      }
    });
  });

  it("规则目标和动作应覆盖字段、分组、页面、提交与通知的 IF/THEN 模型", () => {
    const center = getFormRuleCenter(createDesignerWorkbench());
    const targetTypes = new Set(center.rules.flatMap((rule) => rule.actions?.map((action) => action.targetType) ?? []));
    const actionTypes = new Set(center.rules.flatMap((rule) => rule.actions?.map((action) => action.type) ?? []));

    expect([...targetTypes].sort()).toEqual(["field", "notification", "page", "section", "submit"]);
    expect([...actionTypes].sort()).toEqual([
      "calculate",
      "hide",
      "jump",
      "notify",
      "readonly",
      "require",
      "show",
      "submit"
    ]);
  });

  it("规则冲突诊断应给出条件键、冲突规则集合、优先级和修复入口", () => {
    const workbench = createDesignerWorkbench();
    const diagnostics = validateFormRuleCenter({
      ...workbench,
      rules: [
        ...workbench.rules,
        {
          code: "hide-owner-for-retail",
          name: "零售行业隐藏负责人",
          resourceId: "rule:customer_contract:hide-owner-for-retail",
          order: 40,
          enabled: true,
          scope: "form",
          condition: {
            fieldCode: "industry",
            operator: "equals",
            value: "retail"
          },
          actions: [
            {
              type: "hide",
              targetType: "field",
              targetCode: "owner_link",
              effect: "hidden"
            }
          ],
          message: "零售行业隐藏负责人"
        },
        {
          code: "show-owner-for-retail",
          name: "零售行业显示负责人",
          resourceId: "rule:customer_contract:show-owner-for-retail",
          order: 41,
          enabled: true,
          scope: "form",
          condition: {
            fieldCode: "industry",
            operator: "equals",
            value: "retail"
          },
          actions: [
            {
              type: "show",
              targetType: "field",
              targetCode: "owner_link",
              effect: "visible"
            }
          ],
          message: "零售行业显示负责人"
        }
      ]
    });

    expect(diagnostics.find((item) => item.code === "rule-conflict")).toMatchObject({
      severity: "blocking",
      conditionKey: "industry.equals.retail",
      targetCode: "owner_link",
      involvedRuleCodes: ["hide-owner-for-retail", "show-owner-for-retail"],
      priorityHint: "按 order 或显式优先级保留唯一生效动作",
      primaryAction: "打开规则冲突诊断"
    });
  });

  it("隐藏字段不是权限控制，隐藏必填字段仍应保留服务端校验和字段权限矩阵", () => {
    const workbench = updateWorkbenchField(
      updateWorkbenchField(createDesignerWorkbench(), {
        type: "select-field",
        fieldCode: "contract_amount"
      }),
      {
        type: "update-selected-field",
        patch: {
          hidden: true,
          required: true
        }
      }
    );
    const matrix = getPermissionMatrix(workbench);
    const invalid = validateDraftRecord(workbench, {
      ...workbench.previewRecord,
      contract_amount: ""
    });

    expect(matrix.fieldPermissions).toContainEqual({
      roleCode: "operator",
      fieldCode: "contract_amount",
      permission: "WRITE"
    });
    expect(invalid.errors).toContainEqual({
      field: "contract_amount",
      message: "合同金额不能为空"
    });
  });

  it("提交动作规则应绑定工作流转移、幂等键策略和副作用 outbox", () => {
    const workbench = createDesignerWorkbench();
    const submitRule = getFormRuleCenter(workbench).rules.find((rule) => rule.code === "submit-approval-action");
    const workflow = getDesignerWorkflowBlueprint(workbench);

    expect(submitRule?.actions?.[0]).toMatchObject({
      type: "submit",
      targetType: "submit",
      targetCode: "submit",
      workflowTransition: {
        actionCode: "submit",
        from: "draft",
        to: "dept_approval"
      },
      idempotencyKeyRequired: true,
      sideEffectPolicy: "outbox"
    });
    expect(workflow.transitions.find((transition) => transition.actionCode === "submit")).toMatchObject({
      idempotent: true,
      invokedByRuleCode: "submit-approval-action"
    });
  });

  it("表单模板复用应区分引用和复制，并记录覆盖补丁避免多表单漂移", () => {
    const catalog = getFormTemplateCatalog(createDesignerWorkbench());

    expect(catalog.templates.find((template) => template.code === "create-form")).toMatchObject({
      reuseStrategy: "source",
      templateVersion: 1
    });
    expect(catalog.templates.find((template) => template.code === "edit-form")).toMatchObject({
      sourceTemplateCode: "create-form",
      reuseStrategy: "reference",
      overridePatch: []
    });
    expect(catalog.templates.find((template) => template.code === "detail-form")).toMatchObject({
      sourceTemplateCode: "create-form",
      reuseStrategy: "copy-with-overrides",
      overridePatch: [
        {
          op: "set-readonly",
          value: true
        }
      ]
    });
  });
});

describe("开源表单设计器对标能力", () => {
  it("设计器应提供类似 SurveyJS 的设计、预览、逻辑、JSON、主题、翻译多视图", () => {
    const surface = getFormDesignerSurface(createDesignerWorkbench());

    expect(surface.tabs.map((tab) => tab.code)).toEqual([
      "designer",
      "preview",
      "logic",
      "json",
      "theme",
      "translation"
    ]);
    expect(surface.tabs.find((tab) => tab.code === "json")).toMatchObject({
      label: "JSON",
      enabled: true
    });
    expect(surface.tabs.find((tab) => tab.code === "logic")).toMatchObject({
      label: "逻辑",
      enabled: true
    });
  });

  it("设计器应提供类似 Form.io 的 Web、Wizard、PDF 表单形态和组件工具箱分类", () => {
    const surface = getFormDesignerSurface(createDesignerWorkbench());

    expect(surface.displayModes.map((mode) => mode.code)).toEqual(["web", "wizard", "pdf"]);
    expect(surface.toolbox.categories.map((category) => category.code)).toEqual([
      "basic",
      "advanced",
      "layout",
      "data",
      "action"
    ]);
    expect(surface.toolbox.categories.find((category) => category.code === "layout")?.components.map((item) => item.code)).toEqual([
      "section",
      "tabs",
      "grid",
      "wizard-page",
      "panel"
    ]);
  });

  it("设计器应提供类似 JSON Forms 的 JSON Schema、UI Schema、Data 三层协议", () => {
    const surface = getFormDesignerSurface(createDesignerWorkbench());

    expect(surface.schemaProtocol).toMatchObject({
      jsonSchema: {
        type: "object",
        required: ["customer_name", "contract_amount", "go_live_date", "industry", "owner_link"]
      },
      data: {
        customer_name: "华北样板客户"
      }
    });
    expect(surface.schemaProtocol.uiSchema.type).toBe("VerticalLayout");
    expect(surface.schemaProtocol.uiSchema.elements.map((element) => element.type)).toContain("Control");
    expect(surface.schemaProtocol.uiSchema.elements.map((element) => element.type)).toContain("Group");
  });

  it("设计器应具备属性网格、组件树和导入导出契约，而不是只有画布预览", () => {
    const surface = getFormDesignerSurface(createDesignerWorkbench());

    expect(surface.propertyGrid.tabs.map((tab) => tab.code)).toEqual([
      "property",
      "style",
      "validation",
      "logic",
      "action"
    ]);
    expect(surface.outline.nodes.map((node) => node.kind)).toEqual([
      "form",
      "body",
      "section",
      "grid",
      "section",
      "grid",
      "action-bar"
    ]);
    expect(surface.ioContract).toMatchObject({
      importJson: true,
      exportJson: true,
      exportSchema: true,
      versionedSnapshot: true
    });
  });

  it("应对标阿里 Formily Designable 的设计引擎、组件适配和 x-reactions 联动", () => {
    const surface = getFormDesignerSurface(createDesignerWorkbench());

    expect(surface.formilyDesignable).toMatchObject({
      engine: "Designable",
      formCore: "Formily",
      schemaDialect: "JSON Schema + x-* 扩展",
      adapterPackages: ["Ant Design", "Fusion", "业务组件"],
      conversion: {
        jsonSchemaToFormily: true,
        formilyToJsonSchema: true,
        supportsJSchema: true
      }
    });
    expect(surface.formilyDesignable.reactions.map((reaction) => reaction.type)).toEqual([
      "visible",
      "required",
      "value",
      "disabled"
    ]);
    expect(surface.formilyDesignable.workbenchPanels.map((panel) => panel.code)).toEqual([
      "designer-canvas",
      "component-tree",
      "property-settings",
      "history",
      "schema-editor"
    ]);
  });

  it("阿里 Formily 对标必须输出可运行的 x-* Schema 协议而不是只展示名称", () => {
    const surface = getFormDesignerSurface(createDesignerWorkbench());
    const customerName = surface.formilyDesignable.formilySchema.properties.customer_name;
    const amount = surface.formilyDesignable.formilySchema.properties.contract_amount;
    const summary = surface.formilyDesignable.formilySchema.properties.summary_html;

    expect(surface.formilyDesignable.formilySchema).toMatchObject({
      type: "object",
      "x-component": "Form",
      "x-component-props": {
        labelCol: 6,
        wrapperCol: 12
      }
    });
    expect(customerName).toMatchObject({
      title: "客户名称",
      required: true,
      "x-decorator": "FormItem",
      "x-component": "Input",
      "x-validator": [{ required: true, message: "客户名称不能为空" }]
    });
    expect(amount).toMatchObject({
      type: "number",
      "x-component": "NumberPicker",
      "x-decorator": "FormItem"
    });
    expect(summary["x-component"]).toBe("RichText");
  });

  it("阿里 Designable 对标必须记录工作台选中节点、历史、拖拽源和属性面板绑定", () => {
    const selected = updateWorkbenchField(createDesignerWorkbench(), {
      type: "select-field",
      fieldCode: "industry"
    });
    const surface = getFormDesignerSurface(selected);

    expect(surface.formilyDesignable.workbench).toMatchObject({
      selectedNodeId: "field-industry",
      selectedFieldCode: "industry",
      activePanel: "property-settings",
      history: {
        undoable: true,
        redoable: true
      },
      schemaEditor: {
        editable: true,
        validatesBeforeImport: true
      }
    });
    expect(surface.formilyDesignable.workbench.dragSources.map((item) => item.code)).toEqual([
      "Input",
      "NumberPicker",
      "DatePicker",
      "Select",
      "FormGrid",
      "FormTab"
    ]);
    expect(surface.formilyDesignable.workbench.propertyBindings.map((item) => item.path)).toEqual([
      "title",
      "required",
      "x-decorator",
      "x-component",
      "x-component-props",
      "x-validator",
      "x-reactions"
    ]);
  });

  it("x-reactions 可视化模型必须能表达 source、target、when、fulfill 和 otherwise", () => {
    const surface = getFormDesignerSurface(createDesignerWorkbench());
    const reaction = surface.formilyDesignable.reactionDesigner.rules.find((item) => item.target === "summary_html");

    expect(reaction).toMatchObject({
      source: "industry",
      target: "summary_html",
      when: "{{$self.value === 'service'}}",
      fulfill: {
        state: {
          visible: true,
          required: true
        }
      },
      otherwise: {
        state: {
          visible: false,
          required: false
        }
      }
    });
    expect(surface.formilyDesignable.formilySchema.properties.industry["x-reactions"]).toEqual([
      {
        target: "summary_html",
        when: "{{$self.value === 'service'}}",
        fulfill: {
          state: {
            visible: true,
            required: true
          }
        },
        otherwise: {
          state: {
            visible: false,
            required: false
          }
        }
      }
    ]);
  });
});
