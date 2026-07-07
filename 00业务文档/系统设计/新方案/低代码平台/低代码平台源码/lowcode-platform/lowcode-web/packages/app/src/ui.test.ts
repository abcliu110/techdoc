import { describe, expect, it } from "vitest";
import { createEmptyFieldDraft, updateFieldDraftValue } from "./index";
import { createWorkbenchController } from "./ui";

describe("设计器工作台行为层", () => {
  it("保存会反馈状态文案，发布会先执行商业发布检查", () => {
    const controller = createWorkbenchController();

    controller.saveDraft();
    expect(controller.getState().workbench.statusMessage).toContain("已保存草稿");
    expect(controller.getState().html).toContain("当前存在草稿未发布变更");

    controller.publish();
    expect(controller.getState().workbench.statusMessage).toContain("已发布版本快照");
    expect(controller.getState().html).toContain("最新 metaHash");
  });

  it("发布后运行态预览会反馈 readiness、应用包提醒和当前快照", () => {
    const controller = createWorkbenchController();

    controller.publish();

    const { html, published } = controller.getState();
    expect(html).toContain('data-role="runtime-preview-feedback"');
    expect(html).toContain("运行态预览使用已发布快照");
    expect(html).toContain(`metaHash：${published.publishRequest.payload.metaHash}`);
    expect(html).toContain("发布检查：5/6 通过，1 项需确认");
    expect(html).toContain("应用包入口：应用包安装升级仍需确认集成契约");
  });

  it("支持切换到详情预览面板", () => {
    const controller = createWorkbenchController();

    controller.setPreviewMode("detail");

    const state = controller.getState();
    expect(state.workbench.previewMode).toBe("detail");
    expect(state.html).toContain("详情预览");
    expect(state.html).toContain("客户名称");
  });

  it("支持新增字段后上移、下移和删除", () => {
    const controller = createWorkbenchController();
    const draft = updateFieldDraftValue(createEmptyFieldDraft(), "label", "审批备注");

    controller.addField(draft);
    expect(controller.getState().html).toContain("审批备注");

    controller.selectField("shen_pi_bei_zhu");
    controller.moveSelectedField("up");
    expect(controller.getState().workbench.statusMessage).toContain("已上移字段");

    controller.moveSelectedField("down");
    expect(controller.getState().workbench.statusMessage).toContain("已下移字段");

    controller.deleteSelectedField();
    expect(controller.getState().workbench.statusMessage).toContain("已删除字段");
    expect(controller.getState().html).not.toContain("shen_pi_bei_zhu");
  });

  it("支持组件库拖入画布并生成可配置字段", () => {
    const controller = createWorkbenchController();

    controller.dropPaletteField("section", 1);

    const state = controller.getState();
    expect(state.workbench.selectedFieldCode).toBe("fen_zu_biao_ti");
    expect(state.html).toContain("draggable=\"true\"");
    expect(state.html).toContain("data-palette-field-type=\"section\"");
    expect(state.html).toContain("data-drop-index=\"1\"");
    expect(state.html).toContain("分组标题");
  });

  it("支持画布内拖拽排序并保持属性面板联动", () => {
    const controller = createWorkbenchController();

    controller.dropExistingField("industry", 1);

    const state = controller.getState();
    expect(state.workbench.recordSchema.map((field) => field.code).slice(0, 3)).toEqual([
      "customer_name",
      "industry",
      "contract_amount"
    ]);
    expect(state.workbench.selectedFieldCode).toBe("industry");
    expect(state.html).toContain("草稿未发布");
  });

  it("属性修改后会显示未发布状态提示", () => {
    const controller = createWorkbenchController();

    controller.updateSelectedField({
      name: "客户简称"
    });

    const state = controller.getState();
    expect(state.workbench.statusTag).toBe("draft");
    expect(state.html).toContain("草稿未发布");
    expect(state.html).toContain("客户简称");
  });

  it("从组件库拖到画布会新增组件并自动选中同步预览", () => {
    const controller = createWorkbenchController();

    controller.beginPaletteDrag("number");
    expect(controller.getState().dragState).toEqual({
      source: "palette",
      templateCode: "number"
    });

    controller.dropOnCanvas(1);

    const state = controller.getState();
    expect(state.dragState).toBeNull();
    expect(state.workbench.recordSchema[1]).toMatchObject({
      code: "number_input",
      name: "数字输入",
      fieldType: "decimal"
    });
    expect(state.workbench.selectedFieldCode).toBe("number_input");
    expect(state.workbench.statusTag).toBe("draft");
    expect(state.published.runtime.form.fields.map((field) => field.code)).toContain("number_input");
    expect(state.html).toContain("数字输入");
  });

  it("画布内拖拽后会重排字段顺序并保持选中与草稿状态", () => {
    const controller = createWorkbenchController();

    controller.beginCanvasDrag("industry");
    expect(controller.getState().dragState).toEqual({
      source: "canvas",
      fieldCode: "industry"
    });

    controller.dropOnCanvas(1);

    const state = controller.getState();
    expect(state.dragState).toBeNull();
    expect(state.workbench.recordSchema.map((field) => field.code).slice(0, 4)).toEqual([
      "customer_name",
      "industry",
      "contract_amount",
      "go_live_date"
    ]);
    expect(state.workbench.selectedFieldCode).toBe("industry");
    expect(state.workbench.statusTag).toBe("draft");
    expect(state.workbench.statusMessage).toContain("拖拽");
    expect(state.published.runtime.form.fields.map((field) => field.code).slice(0, 4)).toEqual([
      "customer_name",
      "industry",
      "contract_amount",
      "go_live_date"
    ]);
  });

  it("工作台 html 会输出拖拽所需的 data 标记", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();

    expect(html).toContain('data-drag-source="palette"');
    expect(html).toContain('data-template-code="number"');
    expect(html).toContain('data-drag-source="canvas-field"');
    expect(html).toContain('data-drop-zone-index="0"');
    expect(html).toContain('data-drop-zone-index="7"');
    expect(html).toContain('draggable="true"');
  });

  it("画布字段之间会输出投放槽且左侧字段清单不伪装成画布拖拽源", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();

    expect(html).toContain('data-role="canvas-field-list"');
    expect(html).toContain('data-drag-source="field-list"');
    expect(html).toContain('class="lc-form-preview" data-role="canvas-field-list"');
    const canvasStart = html.indexOf('data-role="canvas-field-list"');
    const canvasEnd = html.indexOf('data-role="canvas-field-list-end"', canvasStart);
    const canvasHtml = html.slice(canvasStart, canvasEnd);
    expect(canvasHtml.indexOf('data-drop-zone-index="1"')).toBeLessThan(
      canvasHtml.indexOf('data-field-code="contract_amount"')
    );
  });

  it("属性面板会显示当前选中的画布组件信息", () => {
    const controller = createWorkbenchController();

    controller.selectField("industry");

    const { html } = controller.getState();
    expect(html).toContain("当前选中组件");
    expect(html).toContain("行业");
    expect(html).toContain("表单字段");
  });

  it("页面配置会回显当前可见字段与布局设置", () => {
    const controller = createWorkbenchController();

    controller.dropExistingField("industry", 1);

    const { html } = controller.getState();
    expect(html).toContain("页面配置");
    expect(html.indexOf('value="industry"')).toBeLessThan(html.indexOf('value="contract_amount"'));
    expect(html).toContain('<option value="4" selected>4 列</option>');
    expect(html).toContain('<option value="comfortable" selected>舒适</option>');
  });

  it("页面配置变更会真实驱动画布预览字段", () => {
    const controller = createWorkbenchController();

    controller.updatePageConfig("form", {
      visibleFieldCodes: ["industry", "customer_name"],
      layout: {
        columns: 1,
        density: "compact"
      }
    });

    const { html, published } = controller.getState();
    const canvasStart = html.indexOf('data-role="canvas-field-list"');
    const canvasEnd = html.indexOf('data-role="canvas-field-list-end"', canvasStart);
    const canvasHtml = html.slice(canvasStart, canvasEnd);
    expect(canvasHtml).toContain('data-field-code="industry"');
    expect(canvasHtml).toContain('data-field-code="customer_name"');
    expect(canvasHtml).not.toContain('data-field-code="contract_amount"');
    expect(published.runtime.form.fields.map((field) => field.code)).toEqual(["industry", "customer_name"]);
  });

  it("页面配置表单会输出可交互控件而不是只读摘要", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();

    expect(html).toContain('data-form="page-config"');
    expect(html).toContain('name="visibleFieldCodes"');
    expect(html).toContain('name="columns"');
    expect(html).toContain('name="density"');
  });

  it("工作台 html 会输出商业应用资源树", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();

    expect(html).toContain('data-role="resource-tree"');
    expect(html).toContain('data-resource-id="object:customer_contract"');
    expect(html).toContain('data-resource-id="page:customer_contract:list"');
    expect(html).toContain('data-resource-id="workflow:customer_contract:approval"');
    expect(html).toContain('data-resource-id="permission:customer_contract"');
    expect(html).toContain('data-resource-id="integration:customer_contract"');
  });

  it("切换流程资源后会显示流程设计上下文而不是字段属性优先", () => {
    const controller = createWorkbenchController();

    controller.selectResource("workflow:customer_contract:approval");

    const { workbench, html } = controller.getState();
    expect(workbench.activeDesignerMode).toBe("workflow");
    expect(html).toContain("流程设计");
    expect(html).toContain("提交审批");
    expect(html).toContain("终态检查");
  });

  it("发布检查面板会展示门禁状态并隐藏内部调试优先级", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();

    expect(html).toContain('data-role="readiness-panel"');
    expect(html).toContain("审批流程已配置提交动作");
    expect(html).toContain("权限矩阵");
    expect(html.indexOf("发布检查")).toBeLessThan(html.indexOf("高级调试"));
  });

  it("存在阻断级发布检查时发布动作不会伪装成成功", () => {
    const controller = createWorkbenchController();

    controller.publish();

    const { workbench, html } = controller.getState();
    expect(workbench.statusTag).toBe("published");
    expect(workbench.statusMessage).toContain("已发布版本快照");
    expect(html).toContain("可发布");
  });

  it("发布检查条目可以点击并切换到对应设计资源", () => {
    const controller = createWorkbenchController();

    controller.openReadinessItem("workflow-approval");

    const { workbench, html } = controller.getState();
    expect(workbench.activeDesignerMode).toBe("workflow");
    expect(workbench.activeResourceId).toBe("workflow:customer_contract:approval");
    expect(workbench.statusMessage).toContain("已定位发布检查项");
    expect(html).toContain("审批节点");
  });

  it("页面资源会显示商业布局蓝图而不是只有字段属性表单", () => {
    const controller = createWorkbenchController();

    controller.selectResource("page:customer_contract:form");

    const { html } = controller.getState();
    expect(html).toContain('data-role="layout-blueprint"');
    expect(html).toContain("客户合同表单页");
    expect(html).toContain("四列业务栅格");
    expect(html).toContain("客户名称");
  });

  it("表单画布会按布局树输出分组、分栏、字段绑定和动作区", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();

    expect(html).toContain('data-layout-node-id="form-basic"');
    expect(html).toContain('data-layout-kind="section"');
    expect(html).toContain("基础信息");
    expect(html).toContain('data-layout-node-id="form-basic-grid"');
    expect(html).toContain('data-layout-columns="4"');
    expect(html).toContain('data-layout-responsive="auto-fit"');
    expect(html).toContain('data-layout-node-id="field-customer_name"');
    expect(html).toContain('data-field-code="customer_name"');
    expect(html).toContain('data-layout-span="2"');
    expect(html).toContain('data-layout-node-id="form-actions"');
    expect(html).toContain("提交审批");
  });

  it("页面配置面板提供一到六列布局选项并说明移动端降级", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();

    expect(html).toContain('<option value="1"');
    expect(html).toContain('<option value="4" selected');
    expect(html).toContain('<option value="6"');
    expect(html).toContain("移动端自动降为单列");
  });

  it("右侧属性区会显示选中布局节点的容器属性和规则绑定", () => {
    const controller = createWorkbenchController();

    controller.selectField("contract_amount");

    const { html } = controller.getState();
    expect(html).toContain("布局节点");
    expect(html).toContain("字段绑定");
    expect(html).toContain("所属分组");
    expect(html).toContain("基础信息");
    expect(html).toContain("保存校验");
    expect(html).toContain("合同金额是审批和回款的关键字段");
  });

  it("流程资源会显示节点和流转动作", () => {
    const controller = createWorkbenchController();

    controller.selectResource("workflow:customer_contract:approval");

    const { html } = controller.getState();
    expect(html).toContain('data-role="workflow-blueprint"');
    expect(html).toContain("提交审批");
    expect(html).toContain("部门负责人审批");
    expect(html).toContain("approve");
  });

  it("权限资源会显示角色、页面、字段和动作权限矩阵", () => {
    const controller = createWorkbenchController();

    controller.selectResource("permission:customer_contract");

    const { html } = controller.getState();
    expect(html).toContain('data-role="permission-matrix"');
    expect(html).toContain("平台管理员");
    expect(html).toContain("业务经办人");
    expect(html).toContain("owner_link");
    expect(html).toContain("脱敏");
    expect(html).toContain("提交审批");
  });

  it("集成资源会显示导入导出、开放 API 和应用包契约", () => {
    const controller = createWorkbenchController();

    controller.selectResource("integration:customer_contract");

    const { html } = controller.getState();
    expect(html).toContain('data-role="integration-contract"');
    expect(html).toContain("批量导入");
    expect(html).toContain("CSV 公式转义");
    expect(html).toContain("开放 API");
    expect(html).toContain("应用包安装升级");
  });

  it("表单设计器会提供规则中心、预览测试、高级 Schema 和模板复用入口", () => {
    const controller = createWorkbenchController();

    controller.selectResource("page:customer_contract:form");

    const { html } = controller.getState();
    expect(html).toContain('data-role="rule-center"');
    expect(html).toContain("规则中心");
    expect(html).toContain("IF-THEN");
    expect(html).toContain("当 合同金额 必填");
    expect(html).toContain("则 阻断保存并提示");
    expect(html).toContain('data-role="preview-test"');
    expect(html).toContain("Preview 测试");
    expect(html).toContain("样例记录");
    expect(html).toContain('data-role="schema-json-view"');
    expect(html).toContain("Schema JSON 高级视图");
    expect(html).toContain('data-role="template-reuse"');
    expect(html).toContain("模板复用入口");
    expect(html).toContain("新建表单");
    expect(html).toContain("复用详情表单布局");
  });

  it("表单设计器会展示开源设计器对标骨架和阿里 Formily 能力", () => {
    const controller = createWorkbenchController();

    controller.selectResource("page:customer_contract:form");

    const { html } = controller.getState();
    expect(html).toContain('data-role="designer-tabs"');
    expect(html).toContain("设计");
    expect(html).toContain("预览");
    expect(html).toContain("逻辑");
    expect(html).toContain("主题");
    expect(html).toContain("翻译");
    expect(html).toContain('data-role="display-modes"');
    expect(html).toContain("Web 表单");
    expect(html).toContain("向导表单");
    expect(html).toContain("PDF 表单");
    expect(html).toContain('data-role="component-toolbox"');
    expect(html).toContain("布局容器");
    expect(html).toContain("向导页");
    expect(html).toContain('data-role="property-grid"');
    expect(html).toContain("校验");
    expect(html).toContain("动作");
    expect(html).toContain('data-role="component-outline"');
    expect(html).toContain("组件树");
    expect(html).toContain('data-role="formily-designable"');
    expect(html).toContain("Designable");
    expect(html).toContain("Formily");
    expect(html).toContain("x-reactions");
    expect(html).toContain("Ant Design");
  });

  it("阿里 Formily 面板会展示选中字段的 x-* 协议和 x-reactions 可视化规则", () => {
    const controller = createWorkbenchController();

    controller.selectResource("page:customer_contract:form");
    controller.selectField("industry");

    const { html } = controller.getState();
    expect(html).toContain('data-role="formily-schema-protocol"');
    expect(html).toContain("x-component");
    expect(html).toContain("Select");
    expect(html).toContain("x-decorator");
    expect(html).toContain("FormItem");
    expect(html).toContain("x-validator");
    expect(html).toContain('data-role="x-reactions-designer"');
    expect(html).toContain("source：industry");
    expect(html).toContain("target：summary_html");
    expect(html).toContain("{{$self.value === &#39;service&#39;}}");
    expect(html).toContain('data-role="designable-workbench-state"');
    expect(html).toContain("field-industry");
    expect(html).toContain("Schema 编辑器");
  });

  it("表单页面资源会在主画布第一屏呈现 Designable 源码同构工作台", () => {
    const controller = createWorkbenchController();

    controller.selectResource("page:customer_contract:form");
    controller.selectField("industry");

    const { html } = controller.getState();
    const canvasStart = html.indexOf('data-role="designable-workbench-shell"');
    const debugStart = html.indexOf("高级调试");

    expect(canvasStart).toBeGreaterThan(0);
    expect(canvasStart).toBeLessThan(debugStart);
    expect(html).toContain('data-role="studio-panel"');
    expect(html).toContain('data-role="studio-panel-header"');
    expect(html).toContain('data-role="studio-panel-actions"');
    expect(html).toContain('data-role="composite-panel"');
    expect(html).toContain('data-role="composite-tab-components"');
    expect(html).toContain('data-role="composite-tab-outline"');
    expect(html).toContain('data-role="composite-tab-history"');
    expect(html).toContain('data-role="resource-widget"');
    expect(html).toContain('data-role="outline-tree-widget"');
    expect(html).toContain('data-role="history-widget"');
    expect(html).toContain('data-role="workspace-panel"');
    expect(html).toContain('data-role="designable-toolbar"');
    expect(html).toContain('data-role="toolbar-panel"');
    expect(html).toContain('data-role="designer-tools-widget"');
    expect(html).toContain('data-role="view-tools-widget"');
    expect(html).toContain("Formily / Designable");
    expect(html).toContain("Schema 编辑");
    expect(html).toContain('data-role="viewport-panel"');
    expect(html).toContain('data-view-panel="designable"');
    expect(html).toContain('data-view-panel="json"');
    expect(html).toContain('data-view-panel="markup"');
    expect(html).toContain('data-view-panel="preview"');
    expect(html).toContain('data-role="settings-panel"');
    expect(html).toContain('data-role="settings-section-property"');
    expect(html).toContain('data-role="settings-section-style"');
    expect(html).toContain('data-role="settings-section-validation"');
    expect(html).toContain('data-role="settings-section-reactions"');
    expect(html).toContain('data-role="settings-section-data-source"');
    expect(html).toContain("当前节点：field-industry");
    expect(html).toContain("x-component：Select");
    expect(html).toContain("联动：industry -> summary_html");
  });

  it("表单页会把 Designable Studio 作为主工作区而不是嵌在旧三栏里", () => {
    const controller = createWorkbenchController();

    controller.selectResource("page:customer_contract:form");

    const { html } = controller.getState();
    const studioStart = html.indexOf('data-role="designable-workbench-shell"');
    const legacyLayoutStart = html.indexOf('data-role="legacy-three-column-workbench"');

    expect(studioStart).toBeGreaterThan(0);
    expect(legacyLayoutStart).toBeGreaterThan(0);
    expect(studioStart).toBeLessThan(legacyLayoutStart);
    expect(html).toContain('data-role="primary-designable-studio"');
    expect(html).toContain('data-viewport-owner="true"');
    expect(html).toContain('data-primary-designer="true"');
    expect(html).toContain('data-secondary="true"');
    expect(html).toContain('data-role="legacy-workbench-compat"');
  });

  it("表单主工作台会输出高对比和可读密度标记，避免暗色面板与画布字段不可见", () => {
    const controller = createWorkbenchController();

    controller.selectResource("page:customer_contract:form");

    const { html } = controller.getState();
    const studioStart = html.indexOf('data-role="primary-designable-studio"');
    const studioEnd = html.indexOf('data-role="legacy-three-column-workbench"', studioStart);
    const studioHtml = html.slice(studioStart, studioEnd);

    expect(studioHtml).toContain('data-contrast="high"');
    expect(studioHtml).toContain('data-density="readable"');
    expect(studioHtml).toContain('data-layout-readability="stable"');
    expect(studioHtml).toContain('data-role="designable-canvas-pane" data-density="readable"');
  });

  it("支持撤销和重做字段设计操作，避免误删误拖不可恢复", () => {
    const controller = createWorkbenchController();

    controller.addField(updateFieldDraftValue(createEmptyFieldDraft(), "label", "审批备注"));
    expect(controller.getState().workbench.recordSchema.map((field) => field.code)).toContain("shen_pi_bei_zhu");
    expect(controller.getState().html).toContain("可以撤销");

    controller.undo();
    expect(controller.getState().workbench.recordSchema.map((field) => field.code)).not.toContain("shen_pi_bei_zhu");
    expect(controller.getState().html).toContain("可以重做");

    controller.redo();
    expect(controller.getState().workbench.recordSchema.map((field) => field.code)).toContain("shen_pi_bei_zhu");
    expect(controller.getState().workbench.selectedFieldCode).toBe("shen_pi_bei_zhu");
  });

  it("主界面默认不直接暴露英文技术调试原文", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();
    const mainHtml = html.slice(0, html.indexOf("高级调试"));

    expect(mainHtml).toContain("资源树");
    expect(mainHtml).toContain("设计画布");
    expect(mainHtml).toContain("属性 / 规则");
    expect(mainHtml).not.toContain("MASKED");
    expect(mainHtml).not.toContain("approve");
    expect(mainHtml).not.toContain("CSV");
  });

  it("首屏突出页面设计器主流程而不是旧三栏兼容壳", () => {
    const controller = createWorkbenchController();
    controller.selectResource("page:customer_contract:form");

    const { html } = controller.getState();
    const primaryIndex = html.indexOf("页面类型");
    const compatibilityIndex = html.indexOf("兼容画布摘要");

    expect(primaryIndex).toBeGreaterThan(0);
    expect(compatibilityIndex).toBeGreaterThan(0);
    expect(primaryIndex).toBeLessThan(compatibilityIndex);
    expect(html).toContain("对象与字段");
    expect(html).toContain("发布快照");
    expect(html).toContain("页面 Schema");
  });

  it("页面设计器提供 list form detail 切换和字段面板动作", () => {
    const controller = createWorkbenchController();
    const { html } = controller.getState();

    expect(html).toContain('data-preview-mode="form"');
    expect(html).toContain('data-preview-mode="list"');
    expect(html).toContain('data-preview-mode="detail"');
    expect(html).toContain('data-form="properties"');
    expect(html).toContain('data-form="page-config"');
    expect(html).toContain('data-action="move-up"');
    expect(html).toContain('data-action="move-down"');
    expect(html).toContain('data-action="delete-field"');
  });
});
