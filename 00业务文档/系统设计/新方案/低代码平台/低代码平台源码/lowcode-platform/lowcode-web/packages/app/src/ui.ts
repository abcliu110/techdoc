import {
  createAppTypeRegistry,
  createCanvasComponentTemplates,
  createCsvEscapePreview,
  createDesignerReadinessReport,
  createDesignerWorkbench,
  createEmptyFieldDraft,
  getDesignerLayoutBlueprint,
  getFormDesignerSurface,
  getFormLayoutNodes,
  getDesignerWorkflowBlueprint,
  getFormRuleCenter,
  getFormTemplateCatalog,
  getIntegrationContract,
  createPreviewSnapshot,
  createFieldDraftFromPalette,
  getCommercialDesignerNavigation,
  getPermissionMatrix,
  getSchemaJsonView,
  getSelectedCanvasComponent,
  publishWorkbench,
  selectDesignerResource,
  updateWorkbenchField,
  type DemoWorkbench,
  type DesignerMode,
  type DemoPageConfig,
  type DesignerReadinessReport,
  type DraftFieldDefinition,
  type FieldDraftInput,
  type FormLayoutNode,
  type PageConfigName,
  type PreviewMode,
  type PublishedWorkbench,
  type CanvasComponentTemplate
} from "./index";
import type { RuntimeFieldViewModel } from "@lowcode/renderer";

export type DragState =
  | { source: "palette"; templateCode: string }
  | { source: "canvas"; fieldCode: string }
  | null;

type CanvasFieldView = RuntimeFieldViewModel & {
  required: boolean;
  inList: boolean;
};

export interface WorkbenchController {
  getState(): {
    workbench: DemoWorkbench;
    fieldDraft: FieldDraftInput;
    published: PublishedWorkbench;
    dragState: DragState;
    html: string;
  };
  undo(): void;
  redo(): void;
  saveDraft(): void;
  publish(): void;
  toggleQuickPreview(): void;
  setPreviewMode(previewMode: PreviewMode): void;
  selectResource(resourceId: string): void;
  openReadinessItem(readinessCode: string): void;
  selectField(fieldCode: string): void;
  addField(draft: FieldDraftInput): void;
  dropPaletteField(fieldType: string, targetIndex: number): void;
  dropExistingField(fieldCode: string, targetIndex: number): void;
  beginPaletteDrag(templateCode: string): void;
  beginCanvasDrag(fieldCode: string): void;
  dropOnCanvas(targetIndex: number): void;
  updateSelectedField(patch: Partial<DraftFieldDefinition>): void;
  updatePageConfig(page: PageConfigName, patch: Partial<DemoPageConfig>): void;
  moveSelectedField(direction: "up" | "down"): void;
  deleteSelectedField(): void;
}

export function createWorkbenchController(): WorkbenchController {
  const registry = createAppTypeRegistry();
  const templates = createCanvasComponentTemplates();
  const csvPreview = createCsvEscapePreview(["=SUM(A1:A2)", "+cmd", "safe"]);
  let workbench = createDesignerWorkbench();
  let fieldDraft = createEmptyFieldDraft();
  let published = buildPublished(workbench, "trace-designer-init", "publish-initial");
  let dragState: DragState = null;
  let historyStack: DemoWorkbench[] = [];
  let futureStack: DemoWorkbench[] = [];

  function syncPublished(traceId: string, idempotencyKey: string) {
    published = buildPublished(workbench, traceId, idempotencyKey);
  }

  function rememberCurrentWorkbench() {
    historyStack = [...historyStack, workbench].slice(-30);
    futureStack = [];
  }

  function html(): string {
    return renderWorkbenchHtml(
      workbench,
      fieldDraft,
      published,
      registry,
      templates,
      csvPreview,
      dragState,
      historyStack.length > 0,
      futureStack.length > 0
    );
  }

  return {
    getState() {
      return {
        workbench,
        fieldDraft,
        published,
        dragState,
        html: html()
      };
    },
    undo() {
      const previous = historyStack.at(-1);
      if (!previous) {
        return;
      }
      historyStack = historyStack.slice(0, -1);
      futureStack = [workbench, ...futureStack].slice(0, 30);
      workbench = previous;
      dragState = null;
      syncPublished("trace-designer-undo", `undo-${workbench.recordSchema.length}`);
    },
    redo() {
      const next = futureStack[0];
      if (!next) {
        return;
      }
      futureStack = futureStack.slice(1);
      historyStack = [...historyStack, workbench].slice(-30);
      workbench = next;
      dragState = null;
      syncPublished("trace-designer-redo", `redo-${workbench.recordSchema.length}`);
    },
    saveDraft() {
      rememberCurrentWorkbench();
      workbench = updateWorkbenchField(workbench, {
        type: "save-draft"
      });
      syncPublished("trace-designer-save", `save-${workbench.recordSchema.length}`);
    },
    publish() {
      const readiness = createDesignerReadinessReport(workbench);
      if (!readiness.summary.publishable) {
        workbench = {
          ...workbench,
          statusTag: "draft",
          statusMessage: `发布检查未通过：存在 ${readiness.summary.blocking} 个阻断项`,
          hasUnpublishedChanges: true
        };
        return;
      }

      published = buildPublished(workbench, "trace-designer-publish", `publish-${workbench.recordSchema.length}`);
      workbench = updateWorkbenchField(workbench, {
        type: "publish-success",
        metaHash: published.publishRequest.payload.metaHash
      });
      syncPublished("trace-designer-publish", `publish-${workbench.recordSchema.length}`);
    },
    toggleQuickPreview() {
      const nextMode: PreviewMode = workbench.previewMode === "form" ? "list" : "form";
      workbench = updateWorkbenchField(workbench, {
        type: "set-preview-mode",
        previewMode: nextMode
      });
      workbench = {
        ...workbench,
        statusMessage: `已切换到${nextMode === "form" ? "表单" : nextMode === "list" ? "列表" : "详情"}预览`
      };
      syncPublished(`trace-designer-${nextMode}`, `preview-${nextMode}`);
    },
    setPreviewMode(previewMode) {
      workbench = updateWorkbenchField(workbench, {
        type: "set-preview-mode",
        previewMode
      });
      workbench = {
        ...workbench,
        statusMessage: `已切换到${previewMode === "form" ? "表单" : previewMode === "list" ? "列表" : "详情"}预览`
      };
      syncPublished(`trace-designer-${previewMode}`, `preview-${previewMode}`);
    },
    selectResource(resourceId) {
      workbench = selectDesignerResource(workbench, resourceId);
      syncPublished("trace-designer-resource", `resource-${workbench.activeDesignerMode}`);
    },
    openReadinessItem(readinessCode) {
      const readiness = createDesignerReadinessReport(workbench);
      const item = readiness.items.find((candidate) => candidate.code === readinessCode);
      if (!item) {
        return;
      }
      workbench = {
        ...selectDesignerResource(workbench, item.resourceId),
        statusMessage: `已定位发布检查项：${item.label}`
      };
      syncPublished("trace-designer-readiness", `readiness-${readinessCode}`);
    },
    selectField(fieldCode) {
      workbench = updateWorkbenchField(workbench, {
        type: "select-field",
        fieldCode
      });
      syncPublished("trace-designer-select", `select-${fieldCode}`);
    },
    addField(draft) {
      fieldDraft = draft;
      rememberCurrentWorkbench();
      workbench = updateWorkbenchField(workbench, {
        type: "add-field",
        draft
      });
      fieldDraft = createEmptyFieldDraft();
      syncPublished("trace-designer-add", `add-${workbench.recordSchema.length}`);
    },
    dropPaletteField(fieldType, targetIndex) {
      rememberCurrentWorkbench();
      workbench = updateWorkbenchField(workbench, {
        type: "drop-palette-field",
        fieldType,
        targetIndex
      });
      fieldDraft = createFieldDraftFromPalette(fieldType);
      dragState = null;
      syncPublished("trace-designer-drop-palette", `drop-palette-${workbench.selectedFieldCode}`);
    },
    dropExistingField(fieldCode, targetIndex) {
      rememberCurrentWorkbench();
      workbench = updateWorkbenchField(workbench, {
        type: "drop-existing-field",
        sourceFieldCode: fieldCode,
        targetIndex
      });
      dragState = null;
      syncPublished("trace-designer-drop-existing", `drop-existing-${workbench.selectedFieldCode}`);
    },
    beginPaletteDrag(templateCode) {
      dragState = {
        source: "palette",
        templateCode
      };
    },
    beginCanvasDrag(fieldCode) {
      dragState = {
        source: "canvas",
        fieldCode
      };
    },
    dropOnCanvas(targetIndex) {
      if (!dragState) {
        return;
      }
      if (dragState.source === "palette") {
        this.dropPaletteField(dragState.templateCode, targetIndex);
        return;
      }
      this.dropExistingField(dragState.fieldCode, targetIndex);
    },
    updateSelectedField(patch) {
      rememberCurrentWorkbench();
      workbench = updateWorkbenchField(workbench, {
        type: "update-selected-field",
        patch
      });
      syncPublished("trace-designer-update", `update-${workbench.selectedFieldCode}`);
    },
    updatePageConfig(page, patch) {
      rememberCurrentWorkbench();
      workbench = updateWorkbenchField(workbench, {
        type: "update-page-config",
        page,
        patch
      });
      syncPublished("trace-designer-page-config", `page-config-${page}`);
    },
    moveSelectedField(direction) {
      rememberCurrentWorkbench();
      workbench = updateWorkbenchField(workbench, {
        type: "move-selected-field",
        direction
      });
      syncPublished("trace-designer-move", `move-${direction}-${workbench.selectedFieldCode}`);
    },
    deleteSelectedField() {
      rememberCurrentWorkbench();
      workbench = updateWorkbenchField(workbench, {
        type: "delete-selected-field"
      });
      syncPublished("trace-designer-delete", `delete-${workbench.recordSchema.length}`);
    }
  };
}

export function renderWorkbenchDocument(): HTMLElement {
  const controller = createWorkbenchController();
  const container = document.createElement("div");
  container.className = "lc-shell";

  function rerender() {
    const state = controller.getState();
    container.innerHTML = state.html;
    bindActions();
  }

  function bindActions() {
    container.querySelector<HTMLButtonElement>('[data-action="save"]')
      ?.addEventListener("click", () => {
        controller.saveDraft();
        rerender();
      });
    container.querySelector<HTMLButtonElement>('[data-action="publish"]')
      ?.addEventListener("click", () => {
        controller.publish();
        rerender();
      });
    container.querySelector<HTMLButtonElement>('[data-action="preview"]')
      ?.addEventListener("click", () => {
        controller.toggleQuickPreview();
        rerender();
      });
    container.querySelector<HTMLButtonElement>('[data-action="undo"]')
      ?.addEventListener("click", () => {
        controller.undo();
        rerender();
      });
    container.querySelector<HTMLButtonElement>('[data-action="redo"]')
      ?.addEventListener("click", () => {
        controller.redo();
        rerender();
      });

    for (const button of container.querySelectorAll<HTMLButtonElement>("[data-preview-mode]")) {
      button.addEventListener("click", () => {
        const previewMode = button.dataset.previewMode as PreviewMode | undefined;
        if (!previewMode) {
          return;
        }
        controller.setPreviewMode(previewMode);
        rerender();
      });
    }

    for (const button of container.querySelectorAll<HTMLButtonElement>("[data-resource-id]")) {
      button.addEventListener("click", () => {
        const resourceId = button.dataset.resourceId;
        if (!resourceId) {
          return;
        }
        controller.selectResource(resourceId);
        rerender();
      });
    }

    for (const button of container.querySelectorAll<HTMLButtonElement>("[data-readiness-code]")) {
      button.addEventListener("click", () => {
        const readinessCode = button.dataset.readinessCode;
        if (!readinessCode) {
          return;
        }
        controller.openReadinessItem(readinessCode);
        rerender();
      });
    }

    for (const button of container.querySelectorAll<HTMLButtonElement>("[data-field-code]")) {
      button.addEventListener("click", () => {
        const fieldCode = button.dataset.fieldCode;
        if (!fieldCode) {
          return;
        }
        controller.selectField(fieldCode);
        rerender();
      });
    }

    for (const item of container.querySelectorAll<HTMLElement>('[data-drag-source="palette"]')) {
      item.addEventListener("dragstart", (event) => {
        const templateCode = item.dataset.templateCode;
        if (!templateCode) {
          return;
        }
        controller.beginPaletteDrag(templateCode);
        event.dataTransfer?.setData("application/x-lowcode-palette", templateCode);
        event.dataTransfer?.setData("text/plain", templateCode);
      });
    }

    for (const item of container.querySelectorAll<HTMLElement>('[data-drag-source="canvas-field"]')) {
      item.addEventListener("dragstart", (event) => {
        const fieldCode = item.dataset.fieldCode;
        if (!fieldCode) {
          return;
        }
        controller.beginCanvasDrag(fieldCode);
        event.dataTransfer?.setData("application/x-lowcode-field", fieldCode);
        event.dataTransfer?.setData("text/plain", fieldCode);
      });
    }

    for (const zone of container.querySelectorAll<HTMLElement>("[data-drop-zone-index]")) {
      zone.addEventListener("dragover", (event) => {
        event.preventDefault();
        zone.dataset.dropActive = "true";
      });
      zone.addEventListener("dragleave", () => {
        zone.dataset.dropActive = "false";
      });
      zone.addEventListener("drop", (event) => {
        event.preventDefault();
        zone.dataset.dropActive = "false";
        const targetIndex = Number(zone.dataset.dropZoneIndex ?? "0");
        const paletteCode = event.dataTransfer?.getData("application/x-lowcode-palette");
        const fieldCode = event.dataTransfer?.getData("application/x-lowcode-field");
        if (paletteCode) {
          controller.dropPaletteField(paletteCode, targetIndex);
        } else if (fieldCode) {
          controller.dropExistingField(fieldCode, targetIndex);
        } else {
          controller.dropOnCanvas(targetIndex);
        }
        rerender();
      });
    }

    container.querySelector<HTMLButtonElement>('[data-action="move-up"]')
      ?.addEventListener("click", () => {
        controller.moveSelectedField("up");
        rerender();
      });
    container.querySelector<HTMLButtonElement>('[data-action="move-down"]')
      ?.addEventListener("click", () => {
        controller.moveSelectedField("down");
        rerender();
      });
    container.querySelector<HTMLButtonElement>('[data-action="delete-field"]')
      ?.addEventListener("click", () => {
        controller.deleteSelectedField();
        rerender();
      });

    const addForm = container.querySelector<HTMLFormElement>('[data-form="add-field"]');
    addForm?.addEventListener("submit", (event) => {
      event.preventDefault();
      const formData = new FormData(addForm);
      controller.addField({
        label: String(formData.get("label") ?? ""),
        fieldType: String(formData.get("fieldType") ?? "text"),
        required: formData.get("required") === "on",
        inList: formData.get("inList") === "on",
        hidden: formData.get("hidden") === "on",
        optionsText: String(formData.get("optionsText") ?? "")
      });
      rerender();
    });

    const propertiesForm = container.querySelector<HTMLFormElement>('[data-form="properties"]');
    propertiesForm?.addEventListener("change", () => {
      const formData = new FormData(propertiesForm);
      controller.updateSelectedField({
        name: String(formData.get("name") ?? ""),
        fieldType: String(formData.get("fieldType") ?? "text"),
        required: formData.get("required") === "on",
        inList: formData.get("inList") === "on",
        hidden: formData.get("hidden") === "on",
        placeholder: String(formData.get("placeholder") ?? ""),
        helperText: String(formData.get("helperText") ?? ""),
        defaultValue: String(formData.get("defaultValue") ?? ""),
        options: String(formData.get("optionsText") ?? "")
          .split(/\r?\n|,/)
          .map((item) => item.trim())
          .filter(Boolean)
      });
      rerender();
    });

    const pageConfigForm = container.querySelector<HTMLFormElement>('[data-form="page-config"]');
    pageConfigForm?.addEventListener("change", () => {
      const formData = new FormData(pageConfigForm);
      controller.updatePageConfig(controller.getState().workbench.previewMode, {
        visibleFieldCodes: formData.getAll("visibleFieldCodes").map((value) => String(value)),
        layout: {
          columns: Number(formData.get("columns") ?? "2"),
          density: String(formData.get("density") ?? "comfortable") === "compact" ? "compact" : "comfortable"
        }
      });
      rerender();
    });

  }

  rerender();
  return container;
}

function buildPublished(workbench: DemoWorkbench, traceId: string, idempotencyKey: string): PublishedWorkbench {
  return publishWorkbench(workbench, {
    permissionPreset: "operator",
    traceId,
    idempotencyKey
  });
}

function renderWorkbenchHtml(
  workbench: DemoWorkbench,
  fieldDraft: FieldDraftInput,
  published: PublishedWorkbench,
  registry: ReturnType<typeof createAppTypeRegistry>,
  templates: CanvasComponentTemplate[],
  csvPreview: Array<{ raw: string; escaped: string }>,
  dragState: DragState,
  canUndo: boolean,
  canRedo: boolean
): string {
  const preview = createPreviewSnapshot(workbench, workbench.previewMode);
  const selectedField = workbench.recordSchema.find((field) => field.code === workbench.selectedFieldCode);
  const selectedComponent = getSelectedCanvasComponent(workbench);
  const navigation = getCommercialDesignerNavigation(workbench);
  const readiness = createDesignerReadinessReport(workbench);
  const isPrimaryFormDesigner = workbench.activeDesignerMode === "page" && workbench.previewMode === "form";
  return `
    <style>
      :root {
        color-scheme: light;
        --lc-bg: #f6f2ea;
        --lc-panel: rgba(255, 252, 246, 0.94);
        --lc-panel-strong: #f0e8d9;
        --lc-border: #d7c9ae;
        --lc-border-strong: #b59a6b;
        --lc-text: #201f1a;
        --lc-muted: #746d60;
        --lc-accent: #0e6b63;
        --lc-accent-soft: rgba(14, 107, 99, 0.1);
        --lc-danger: #8a3d30;
        --lc-canvas: #fcf8f1;
        --lc-shadow: 0 18px 40px rgba(56, 37, 10, 0.08);
      }

      * {
        box-sizing: border-box;
      }

      body {
        margin: 0;
        font-family: "Microsoft YaHei UI", "PingFang SC", sans-serif;
        color: var(--lc-text);
        background: #e9edf3;
      }

      button,
      input,
      select,
      textarea {
        font: inherit;
      }

      button {
        cursor: pointer;
      }

      .lc-shell {
        min-height: 100vh;
        padding: 0;
      }

      .lc-toolbar {
        display: grid;
        grid-template-columns: minmax(0, 1fr) auto;
        gap: 16px;
        align-items: center;
        padding: 18px 20px;
        background: linear-gradient(135deg, rgba(255, 253, 248, 0.98), rgba(245, 236, 219, 0.98));
        border: 1px solid var(--lc-border);
        box-shadow: var(--lc-shadow);
      }

      .lc-toolbar[data-primary-designer="true"] {
        display: none;
      }

      .lc-toolbar[data-primary-designer="true"] h1 {
        font-size: 21px;
      }

      .lc-toolbar[data-primary-designer="true"] p,
      .lc-toolbar[data-primary-designer="true"] .lc-kpis {
        display: none;
      }

      .lc-toolbar h1 {
        margin: 0;
        font-size: 26px;
      }

      .lc-toolbar p {
        margin: 6px 0 0;
        color: var(--lc-muted);
      }

      .lc-actions {
        display: flex;
        flex-wrap: wrap;
        justify-content: flex-end;
        gap: 10px;
      }

      .lc-action {
        border: 1px solid var(--lc-border-strong);
        background: #fffaf1;
        padding: 10px 16px;
        min-width: 92px;
      }

      .lc-action-primary {
        background: var(--lc-accent);
        color: #fff;
        border-color: var(--lc-accent);
      }

      .lc-status {
        margin-top: 14px;
        padding: 12px 16px;
        border: 1px solid rgba(14, 107, 99, 0.24);
        background: var(--lc-accent-soft);
      }

      .lc-toolbar[data-primary-designer="true"] + .lc-status {
        display: none;
      }

      .lc-status[data-status-tag="draft"] {
        border-color: rgba(138, 61, 48, 0.24);
        background: rgba(138, 61, 48, 0.08);
      }

      .lc-layout {
        display: grid;
        grid-template-columns: minmax(260px, 320px) minmax(0, 1fr) minmax(300px, 360px);
        gap: 16px;
        margin-top: 16px;
        align-items: start;
      }

      .lc-layout[data-secondary="true"] {
        grid-template-columns: 1fr;
        max-height: 42px;
        opacity: 0.56;
        overflow: hidden;
      }

      .lc-primary-studio {
        margin-top: 0;
      }

      .lc-primary-studio + .lc-layout[data-secondary="true"] {
        margin-top: 10px;
        border: 1px dashed rgba(116, 109, 96, 0.42);
        background: rgba(255, 253, 249, 0.62);
      }

      .lc-primary-studio + .lc-layout[data-secondary="true"]::before {
        content: "兼容区：旧三栏资源树、页面配置和调试信息已下沉，不再作为表单设计器主界面";
        display: block;
        padding: 10px 14px;
        color: var(--lc-muted);
        font-size: 13px;
      }

      .lc-primary-studio + .lc-layout[data-secondary="true"] > * {
        display: none;
      }

      .lc-panel {
        background: var(--lc-panel);
        border: 1px solid var(--lc-border);
        box-shadow: var(--lc-shadow);
        padding: 16px;
      }

      .lc-panel h2,
      .lc-panel h3 {
        margin: 0 0 12px;
      }

      .lc-kpis {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 8px;
        margin-top: 14px;
      }

      .lc-kpis article {
        padding: 10px;
        border: 1px solid var(--lc-border);
        background: var(--lc-panel-strong);
      }

      .lc-kpis strong,
      .lc-section-label {
        display: block;
        color: var(--lc-muted);
        font-size: 12px;
        margin-bottom: 4px;
      }

      .lc-field-list,
      .lc-field-tools,
      .lc-template-list {
        display: grid;
        gap: 10px;
        margin-top: 12px;
      }

      .lc-field-tools {
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }

      .lc-field-card {
        width: 100%;
        text-align: left;
        border: 1px solid var(--lc-border);
        background: #fffdf9;
        padding: 12px;
      }

      .lc-template-card {
        width: 100%;
        text-align: left;
        border: 1px dashed var(--lc-border-strong);
        background: #fffefb;
        color: var(--lc-text);
        padding: 12px;
      }

      .lc-template-card small {
        color: var(--lc-muted);
      }

      .lc-field-card[data-active="true"] {
        border-color: var(--lc-accent);
        background: rgba(14, 107, 99, 0.08);
      }

      .lc-template-card[data-dragging="true"] {
        border-style: solid;
        border-color: var(--lc-accent);
        background: rgba(14, 107, 99, 0.08);
      }

      .lc-field-card small {
        color: var(--lc-muted);
      }

      .lc-resource-tree {
        display: grid;
        gap: 12px;
      }

      .lc-resource-section {
        border: 1px solid var(--lc-border);
        background: rgba(255, 253, 249, 0.82);
        padding: 10px;
      }

      .lc-resource-list {
        display: grid;
        gap: 6px;
        margin-top: 8px;
      }

      .lc-resource-node {
        width: 100%;
        text-align: left;
        border: 1px solid transparent;
        background: transparent;
        padding: 8px 9px;
      }

      .lc-resource-node[data-active="true"] {
        border-color: var(--lc-accent);
        background: rgba(14, 107, 99, 0.1);
      }

      .lc-resource-node small,
      .lc-readiness-item small {
        color: var(--lc-muted);
      }

      .lc-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        margin-top: 8px;
      }

      .lc-tag {
        padding: 3px 8px;
        border: 1px solid var(--lc-border);
        background: var(--lc-panel-strong);
        font-size: 12px;
      }

      .lc-form {
        display: grid;
        gap: 12px;
      }

      .lc-form-row {
        display: grid;
        gap: 6px;
      }

      .lc-form-row input,
      .lc-form-row select,
      .lc-form-row textarea {
        width: 100%;
        border: 1px solid var(--lc-border);
        padding: 10px 12px;
        background: #fff;
      }

      .lc-check-grid {
        display: grid;
        gap: 8px;
      }

      .lc-checkbox {
        display: flex;
        align-items: center;
        gap: 8px;
        color: var(--lc-text);
      }

      .lc-submit {
        border: 1px solid var(--lc-accent);
        background: var(--lc-accent);
        color: #fff;
        padding: 10px 14px;
      }

      .lc-canvas {
        background:
          linear-gradient(180deg, rgba(255, 255, 255, 0.92), rgba(250, 245, 236, 0.95)),
          repeating-linear-gradient(
            90deg,
            rgba(181, 154, 107, 0.08) 0,
            rgba(181, 154, 107, 0.08) 1px,
            transparent 1px,
            transparent 32px
          );
        border: 1px solid var(--lc-border);
        min-height: 720px;
      }

      .lc-canvas-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        padding: 18px 18px 0;
      }

      .lc-toggle-group {
        display: inline-flex;
        border: 1px solid var(--lc-border);
        background: #fffaf1;
      }

      .lc-toggle {
        border: 0;
        background: transparent;
        padding: 8px 14px;
      }

      .lc-toggle[data-active="true"] {
        background: var(--lc-accent);
        color: #fff;
      }

      .lc-stage {
        padding: 18px;
      }

      .lc-designable-shell {
        display: grid;
        grid-template-rows: auto auto minmax(0, 1fr);
        min-height: 100vh;
        border: 0;
        border-radius: 0;
        background: #fff;
        box-shadow: 0 18px 38px rgba(15, 58, 118, 0.12);
        overflow: hidden;
      }

      .lc-studio-header {
        display: grid;
        grid-template-columns: 232px minmax(0, 1fr) 172px;
        gap: 0;
        align-items: center;
        min-height: 64px;
        padding: 0;
        color: #fff;
        border-bottom: 1px solid #2266c2;
        background: #2878e3;
      }

      .lc-studio-header small {
        color: rgba(255, 255, 255, 0.78);
      }

      .lc-bos-brand {
        display: flex;
        align-items: center;
        gap: 8px;
        height: 64px;
        padding: 0 14px;
        border-right: 1px solid rgba(255, 255, 255, 0.25);
        font-weight: 700;
      }

      .lc-bos-logo {
        width: 18px;
        height: 18px;
        border-radius: 3px;
        background: #fff;
        box-shadow: inset 0 0 0 5px #7db7ff;
      }

      .lc-bos-nav {
        display: flex;
        height: 64px;
        align-items: stretch;
      }

      .lc-bos-nav span {
        display: flex;
        align-items: center;
        padding: 0 18px;
        border-right: 1px solid rgba(255, 255, 255, 0.15);
      }

      .lc-bos-nav span[data-active="true"] {
        background: rgba(255, 255, 255, 0.18);
        font-weight: 700;
      }

      .lc-bos-title {
        padding: 0 12px;
        text-align: right;
        font-size: 12px;
      }

      .lc-window-dots {
        display: none;
      }

      .lc-studio-actions,
      .lc-designable-tabs {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
      }

      .lc-designable-tab {
        border: 1px solid #cbd8ea;
        border-radius: 3px;
        background: #fff;
        color: #1f2937;
        padding: 6px 10px;
        font-size: 12px;
      }

      .lc-designable-tab[data-active="true"] {
        border-color: #2f7be5;
        background: #eaf3ff;
        color: #1f5fba;
      }

      .lc-bos-editbar {
        display: grid;
        grid-template-columns: 314px minmax(0, 1fr) 188px;
        min-height: 74px;
        border-bottom: 1px solid #d7e3f2;
        background: #eef6ff;
      }

      .lc-bos-editbar-left {
        border-right: 1px solid #d7e3f2;
      }

      .lc-bos-editbar-tools {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 8px 18px;
      }

      .lc-bos-tool {
        min-width: 72px;
        border: 0;
        background: transparent;
        color: #315d91;
        font-size: 12px;
      }

      .lc-bos-tool::before {
        content: "";
        display: block;
        width: 17px;
        height: 17px;
        margin: 0 auto 2px;
        border: 2px solid #5d94d9;
        border-radius: 2px;
      }

      .lc-bos-editbar-right {
        display: flex;
        align-items: center;
        justify-content: center;
        border-left: 1px solid #d7e3f2;
        color: #315d91;
        font-weight: 700;
      }

      .lc-studio-body {
        display: grid;
        grid-template-columns: 314px minmax(0, 1fr) 188px;
        min-height: 0;
      }

      .lc-composite-panel {
        display: grid;
        grid-template-rows: auto minmax(0, 1fr);
        color: #1f2937;
        border-right: 1px solid #e8edf3;
        background: #f4f7fb;
      }

      .lc-composite-tabs {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 0;
        padding: 0;
        border-bottom: 1px solid #e8edf3;
        background: #fff;
      }

      .lc-composite-tab {
        min-height: 48px;
        border: 0;
        border-bottom: 2px solid transparent;
        background: transparent;
        color: #4b5563;
        font-weight: 700;
        font-size: 13px;
      }

      .lc-composite-tab[data-active="true"] {
        border-color: #2f7be5;
        background: #fbfdff;
        color: #1f5fba;
      }

      .lc-composite-body,
      .lc-settings-panel,
      .lc-workspace-panel {
        min-width: 0;
      }

      .lc-composite-body {
        padding: 10px;
        overflow: auto;
      }

      .lc-workspace-panel {
        display: grid;
        grid-template-rows: auto minmax(0, 1fr);
        background: #eef2f7;
      }

      .lc-designable-toolbar {
        display: none;
        grid-template-columns: minmax(0, 1fr) auto;
        gap: 12px;
        align-items: center;
        min-height: 58px;
        padding: 8px 14px;
        border-bottom: 1px solid #e8edf3;
        background: #fff;
      }

      .lc-viewport-panel {
        padding: 24px;
        overflow: auto;
      }

      .lc-view-panel[data-active="false"] {
        display: none;
      }

      .lc-view-panel-stack {
        display: grid;
        gap: 12px;
        margin-top: 12px;
      }

      .lc-designable-grid {
        display: grid;
        grid-template-columns: minmax(720px, 1fr);
        gap: 12px;
        min-height: calc(100vh - 220px);
        align-items: stretch;
      }

      .lc-designable-pane {
        min-height: 100%;
        padding: 14px;
        border: 1px solid #dce7f5;
        background: #fff;
      }

      .lc-designable-pane[data-role="designable-component-tree"] {
        display: none;
      }

      .lc-designable-pane[data-role="designable-canvas-pane"] .lc-layout-grid {
        grid-template-columns: repeat(3, minmax(190px, 1fr));
      }

      .lc-designable-pane[data-role="designable-canvas-pane"] .lc-layout-field {
        grid-column: auto;
      }

      .lc-designable-pane[data-role="designable-canvas-pane"] .lc-preview-field {
        grid-template-columns: minmax(0, 1fr);
      }

      .lc-designable-pane[data-role="designable-canvas-pane"] .lc-preview-field label {
        display: flex;
        justify-content: flex-start;
        gap: 8px;
        margin: 0 0 6px;
        text-align: left;
      }

      .lc-designable-pane[data-role="designable-canvas-pane"] .lc-preview-field small {
        color: #4b5563;
        text-align: left;
      }

      .lc-designable-tree {
        display: grid;
        gap: 7px;
        margin-top: 10px;
      }

      .lc-designable-node {
        width: 100%;
        text-align: left;
        border: 1px solid #e5eaf0;
        border-radius: 4px;
        background: #fff;
        color: var(--lc-text);
        padding: 8px;
      }

      .lc-designable-node[data-active="true"] {
        border-color: #2f7be5;
        background: #eef5ff;
      }

      .lc-designable-node small {
        color: var(--lc-muted);
      }

      .lc-settings-panel {
        color: #1f2937;
        border-left: 1px solid #e8edf3;
        background: #fff;
        overflow: auto;
      }

      .lc-settings-header {
        position: sticky;
        top: 0;
        z-index: 1;
        padding: 14px 16px;
        text-align: center;
        border-bottom: 1px solid #e8edf3;
        background: #f7fbff;
      }

      .lc-settings-section {
        padding: 10px 8px;
        border-bottom: 1px solid #edf1f5;
      }

      .lc-composite-panel .lc-section-label,
      .lc-settings-panel .lc-section-label {
        color: #1f2937;
      }

      .lc-composite-panel .lc-side-note {
        color: #1f2937;
        border-color: #e8edf3;
        background: #fff;
      }

      .lc-composite-panel .lc-side-note small,
      .lc-settings-panel small {
        color: #6b7280;
      }

      .lc-composite-panel .lc-template-list {
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 8px 6px;
      }

      .lc-composite-panel .lc-template-card {
        min-height: 76px;
        padding: 10px 4px 6px;
        position: relative;
        text-align: center;
        border: 0;
        border-radius: 0;
        background: transparent;
      }

      .lc-composite-panel .lc-template-card::before {
        content: "";
        position: absolute;
        left: 50%;
        top: 8px;
        display: block;
        width: 36px;
        height: 28px;
        transform: translateX(-50%);
        border: 2px solid #9ab3d8;
        border-radius: 3px;
      }

      .lc-composite-panel .lc-template-card strong {
        display: block;
        margin-top: 34px;
        font-size: 13px;
        line-height: 1.25;
      }

      .lc-composite-panel .lc-template-card small {
        display: none;
      }

      .lc-settings-panel .lc-protocol-row span,
      .lc-settings-panel .lc-protocol-row small {
        display: block;
        padding: 8px 10px;
        border: 1px solid #d8e1ec;
        border-radius: 4px;
        background: #fff;
      }

      .lc-bos-section-title {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin: 14px 0 8px;
        padding: 6px 8px;
        border: 1px solid #dce7f5;
        background: #eaf1fa;
        color: #244f82;
        font-weight: 700;
        font-size: 13px;
      }

      .lc-bos-search {
        width: 100%;
        height: 34px;
        margin: 8px 0 12px;
        padding: 0 10px;
        border: 1px solid #cfd8e6;
        background: #fff;
        color: #64748b;
      }

      .lc-bos-field-row {
        display: grid;
        grid-template-columns: 72px minmax(0, 1fr);
        gap: 6px;
        align-items: center;
        margin-top: 7px;
        font-size: 12px;
      }

      .lc-bos-input {
        min-height: 28px;
        padding: 4px 7px;
        border: 1px solid #d8e1ec;
        border-radius: 3px;
        background: #fff;
        color: #1f2937;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .lc-bos-bill-actions {
        display: flex;
        align-items: center;
        gap: 14px;
        margin: 0 0 12px;
        padding: 10px 36px;
        border: 1px dashed #d2dbe8;
        background: #fff;
      }

      .lc-bos-bill-button {
        min-width: 66px;
        padding: 8px 12px;
        border: 0;
        border-radius: 2px;
        background: #4f78e8;
        color: #fff;
        text-align: center;
        font-weight: 700;
      }

      .lc-bos-attachment {
        margin-top: 12px;
        padding: 12px 36px 28px;
        border: 1px dashed #d7dce5;
        background: #fff;
      }

      .lc-bos-attachment strong {
        display: block;
        margin-bottom: 14px;
        font-size: 18px;
      }

      .lc-bos-attachment-box {
        display: grid;
        place-items: center;
        min-height: 98px;
        border: 1px dashed #d7dce5;
        color: #8b95a5;
        background: #fbfcfe;
      }

      .lc-protocol-row {
        display: grid;
        gap: 4px;
        padding: 9px 0;
        border-bottom: 1px solid #edf1f5;
      }

      .lc-drop-zone {
        grid-column: 1 / -1;
        min-height: 0;
        height: 0;
        border-top: 1px dashed #3b82f6;
        background: transparent;
        margin: 0;
      }

      .lc-drop-zone[data-drop-active="true"] {
        border-color: #2563eb;
        box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.12);
      }

      .lc-compat-drop-zones {
        display: none;
      }

      .lc-form-preview {
        display: grid;
        gap: 0;
        border: 1px dashed #3b82f6;
        background: #fff;
      }

      .lc-layout-root,
      .lc-layout-body,
      .lc-layout-section,
      .lc-layout-grid,
      .lc-action-bar {
        display: grid;
        gap: 0;
      }

      .lc-layout-section {
        padding: 0;
        border: 1px solid #dce7f5;
        border-bottom: 0;
        background: #fff;
      }

      .lc-layout-section-header {
        display: flex;
        justify-content: space-between;
        gap: 10px;
        align-items: center;
        padding: 8px 12px;
        border-bottom: 1px solid #dce7f5;
        background: #edf5ff;
        color: #1f5fba;
      }

      .lc-layout-grid {
        grid-template-columns: repeat(var(--layout-columns, 2), minmax(144px, 1fr));
      }

      .lc-layout-field {
        grid-column: span var(--layout-span, 1);
        min-width: 144px;
        border-bottom: 1px dashed #3b82f6;
      }

      .lc-action-bar {
        grid-template-columns: minmax(0, 1fr) auto;
        align-items: center;
        padding: 12px 48px;
        border: 1px solid #dce7f5;
        background: #f8fbff;
      }

      .lc-action-button {
        border: 1px solid #3b82f6;
        border-radius: 4px;
        background: #3b82f6;
        color: #fff;
        padding: 9px 14px;
      }

      .lc-preview-field,
      .lc-detail-card {
        width: 100%;
        display: grid;
        grid-template-columns: 118px minmax(0, 1fr);
        gap: 12px;
        align-items: center;
        min-height: 54px;
        padding: 10px 48px;
        border: 0;
        color: var(--lc-text);
        background: #fff;
      }

      .lc-preview-field[data-selected="true"],
      .lc-detail-card[data-selected="true"] {
        outline: 1px dashed #3b82f6;
        outline-offset: -3px;
        background: rgba(59, 130, 246, 0.025);
      }

      .lc-preview-field label,
      .lc-detail-card label {
        display: grid;
        grid-template-columns: minmax(0, 1fr) auto;
        gap: 10px;
        align-items: start;
        font-weight: 700;
        margin-bottom: 8px;
      }

      .lc-preview-field label > span:first-child,
      .lc-detail-card label > span:first-child,
      .lc-preview-field small,
      .lc-detail-card small {
        overflow-wrap: anywhere;
      }

      .lc-required {
        color: var(--lc-danger);
      }

      .lc-preview-input {
        border: 0;
        border-bottom: 1px solid #8f97a3;
        border-radius: 0;
        background: #fff;
        min-height: 36px;
        padding: 7px 2px;
        display: flex;
        align-items: center;
        overflow-wrap: anywhere;
      }

      .lc-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
        background: rgba(255, 255, 255, 0.8);
      }

      .lc-table th,
      .lc-table td {
        padding: 10px 8px;
        border-bottom: 1px solid rgba(181, 154, 107, 0.35);
        text-align: left;
        vertical-align: top;
      }

      .lc-table th {
        color: var(--lc-muted);
        font-weight: 700;
      }

      .lc-detail-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 12px;
      }

      .lc-side-note,
      .lc-code {
        margin-top: 14px;
        padding: 12px;
        border: 1px solid var(--lc-border);
        background: #fffaf1;
      }

      .lc-context-panel,
      .lc-readiness-panel,
      .lc-rule-panel,
      .lc-debug-panel {
        margin-top: 14px;
        padding: 12px;
        border: 1px solid var(--lc-border);
        background: #fffdf9;
      }

      .lc-readiness-list {
        display: grid;
        gap: 8px;
        margin-top: 10px;
      }

      .lc-rule-grid,
      .lc-template-grid {
        display: grid;
        gap: 8px;
        margin-top: 10px;
      }

      .lc-readiness-item {
        border-left: 4px solid var(--lc-border-strong);
        padding: 8px 10px;
        background: #fffaf1;
      }

      .lc-rule-row,
      .lc-template-row {
        padding: 9px 10px;
        border: 1px solid var(--lc-border);
        background: #fffaf1;
      }

      .lc-readiness-item[data-severity="blocking"] {
        border-left-color: var(--lc-danger);
      }

      .lc-readiness-item[data-severity="warning"] {
        border-left-color: #a86f00;
      }

      .lc-code {
        font-size: 12px;
        line-height: 1.5;
        white-space: pre-wrap;
        overflow: auto;
      }

      .lc-empty {
        padding: 18px;
        border: 1px dashed var(--lc-border);
        color: var(--lc-muted);
        background: #fffdf9;
      }

      .lc-meta-line {
        display: grid;
        gap: 8px;
        margin-top: 10px;
      }

      @media (max-width: 1220px) {
        .lc-layout {
          grid-template-columns: 1fr;
        }

        .lc-form-preview,
        .lc-layout-grid,
        .lc-designable-grid,
        .lc-studio-body,
        .lc-kpis,
        .lc-detail-grid {
          grid-template-columns: 1fr;
        }

        .lc-composite-panel {
          grid-template-columns: 1fr;
        }

        .lc-field-tools {
          grid-template-columns: 1fr;
        }
      }
    </style>
    <section class="lc-toolbar" data-primary-designer="${isPrimaryFormDesigner}">
      <div>
        <h1>低代码设计器工作台</h1>
        <p>左侧选组件和字段，中间搭建画布，右侧改属性。当前支持表单、列表、详情预览与保存/发布闭环。</p>
        <div class="lc-kpis">
          <article><strong>对象编码</strong>${workbench.objectCode}</article>
          <article><strong>字段数量</strong>${workbench.recordSchema.length}</article>
          <article><strong>版本</strong>${workbench.version}</article>
        </div>
      </div>
      <div class="lc-actions">
        <button class="lc-action" data-action="undo" ${canUndo ? "" : "disabled"}>${canUndo ? "可以撤销" : "无可撤销"}</button>
        <button class="lc-action" data-action="redo" ${canRedo ? "" : "disabled"}>${canRedo ? "可以重做" : "无可重做"}</button>
        <button class="lc-action" data-action="save">保存</button>
        <button class="lc-action lc-action-primary" data-action="publish">发布</button>
        <button class="lc-action" data-action="preview">预览</button>
      </div>
    </section>
    <section class="lc-status" data-role="status" data-status-tag="${workbench.statusTag}">
      <strong>状态：</strong>${escapeHtml(workbench.statusMessage)}<br />
      <small>最新 metaHash：${published.publishRequest.payload.metaHash}</small>
      ${workbench.hasUnpublishedChanges ? '<br /><small>当前存在草稿未发布变更</small>' : ""}
    </section>
    ${isPrimaryFormDesigner
      ? `<section class="lc-primary-studio" data-role="primary-designable-studio" data-viewport-owner="true" data-contrast="high" data-density="readable">
          ${renderDesignableWorkbenchPanel(workbench, dragState)}
        </section>`
      : ""}
    <section
      class="lc-layout"
      data-role="${isPrimaryFormDesigner ? "legacy-three-column-workbench" : "standard-three-column-workbench"}"
      data-compat-role="${isPrimaryFormDesigner ? "legacy-workbench-compat" : ""}"
      data-secondary="${isPrimaryFormDesigner}"
    >
      ${isPrimaryFormDesigner ? '<span data-role="legacy-workbench-compat" hidden></span>' : ""}
      <aside class="lc-panel">
        <h2>资源树</h2>
        ${renderResourceTree(navigation)}
        <div class="lc-side-note">
          <span class="lc-section-label">可交互字段类型</span>
          <div class="lc-tags">
            ${registry.interactive.map((item) => `<span class="lc-tag">${escapeHtml(item.label)}</span>`).join("")}
          </div>
        </div>
        <div class="lc-side-note">
          <span class="lc-section-label">拖拽组件库</span>
          <div class="lc-template-list">
            ${templates.map((template) => `
              <button
                class="lc-template-card"
                draggable="true"
                data-drag-source="palette"
                data-template-code="${template.code}"
                data-palette-field-type="${template.code}"
                data-dragging="${dragState?.source === "palette" && dragState.templateCode === template.code}"
              >
                <strong>${escapeHtml(template.label)}</strong><br />
                <small>${escapeHtml(template.typeLabel)} / 拖到画布即可插入</small>
              </button>
            `).join("")}
          </div>
        </div>
        <div class="lc-side-note">
          <span class="lc-section-label">新增字段</span>
          <form class="lc-form" data-form="add-field">
            <label class="lc-form-row">
              <span>字段标签</span>
              <input name="label" value="${escapeHtml(fieldDraft.label)}" placeholder="例如：审批备注" />
            </label>
            <label class="lc-form-row">
              <span>字段类型</span>
              <select name="fieldType">
                ${registry.interactive.map((item) => `
                  <option value="${item.code}" ${item.code === fieldDraft.fieldType ? "selected" : ""}>${escapeHtml(item.label)}</option>
                `).join("")}
              </select>
            </label>
            <label class="lc-form-row">
              <span>选项列表</span>
              <textarea name="optionsText" rows="3" placeholder="单选字段时一行一个选项">${escapeHtml(fieldDraft.optionsText)}</textarea>
            </label>
            <div class="lc-check-grid">
              <label class="lc-checkbox"><input type="checkbox" name="required" ${fieldDraft.required ? "checked" : ""} />必填</label>
              <label class="lc-checkbox"><input type="checkbox" name="inList" ${fieldDraft.inList ? "checked" : ""} />列表显示</label>
              <label class="lc-checkbox"><input type="checkbox" name="hidden" ${fieldDraft.hidden ? "checked" : ""} />默认隐藏</label>
            </div>
            <button type="submit" class="lc-submit">新增字段</button>
          </form>
        </div>
        <div class="lc-field-tools">
          <button class="lc-action" data-action="move-up">上移</button>
          <button class="lc-action" data-action="move-down">下移</button>
          <button class="lc-action" data-action="delete-field">删除</button>
        </div>
        <div class="lc-field-list" data-role="field-list">
          ${workbench.recordSchema.map((field) => renderFieldCard(field, field.code === workbench.selectedFieldCode)).join("")}
        </div>
      </aside>
      <main class="lc-panel lc-canvas">
        <div class="lc-canvas-header">
          <div>
            <h2>设计画布</h2>
            <small>点击字段块可联动到右侧属性面板。预览模式切换会复用同一份发布快照。</small>
          </div>
          <div class="lc-toggle-group">
            <button class="lc-toggle" data-preview-mode="form" data-active="${workbench.previewMode === "form"}">表单预览</button>
            <button class="lc-toggle" data-preview-mode="list" data-active="${workbench.previewMode === "list"}">列表预览</button>
            <button class="lc-toggle" data-preview-mode="detail" data-active="${workbench.previewMode === "detail"}">详情预览</button>
          </div>
        </div>
        <div class="lc-side-note">
          <span class="lc-section-label">页面类型</span>
          <strong>${escapeHtml(formatPreviewMode(workbench.previewMode))}</strong><br />
          <small>对象与字段、页面 Schema、发布快照共用同一条设计链路。</small>
        </div>
        ${renderRuntimePreviewFeedback(workbench, published, readiness)}
        <div class="lc-stage">
          ${renderPreviewPanel(workbench, preview.runtime, dragState)}
        </div>
      </main>
      <aside class="lc-panel">
        <h2>属性 / 规则</h2>
        ${renderDesignerContextPanel(workbench)}
        <div class="lc-side-note">
          <span class="lc-section-label">当前选中组件</span>
          ${selectedComponent
            ? `<strong>${escapeHtml(selectedComponent.fieldName)}</strong><br />
               <small>${escapeHtml(formatComponentType(selectedComponent.componentType))} / ${escapeHtml(formatPreviewMode(selectedComponent.pageType))} / 序号 ${selectedComponent.sortIndex + 1}</small>`
            : '<small>当前没有选中画布组件</small>'}
        </div>
        ${renderLayoutNodeInspector(workbench)}
        ${renderReadinessPanel(readiness)}
        ${renderPageConfigPanel(workbench)}
        ${selectedField ? renderPropertiesPanel(selectedField) : '<div class="lc-empty">请先从左侧选择一个字段。</div>'}
        <div class="lc-debug-panel">
          <strong>高级调试</strong>
          <div class="lc-code">
            <strong>发布请求</strong>
            ${escapeHtml(formatJson(published.publishRequest))}
          </div>
          <div class="lc-code">
            <strong>CSV 公式转义演示</strong>
            ${escapeHtml(formatJson(csvPreview))}
          </div>
        </div>
        <div class="lc-meta-line">
          <small>预览告警：${escapeHtml(published.previewError.message)}</small>
          <small>traceId：${escapeHtml(published.previewError.traceId)}</small>
        </div>
      </aside>
    </section>
  `;
}

function renderResourceTree(navigation: ReturnType<typeof getCommercialDesignerNavigation>): string {
  return `
    <nav class="lc-resource-tree" data-role="resource-tree">
      ${navigation.sections.map((section) => {
        const nodes = navigation.nodes.filter((node) => node.sectionCode === section.code);
        return `
          <section class="lc-resource-section" data-resource-section="${section.code}">
            <span class="lc-section-label">${escapeHtml(section.label)}</span>
            <small>${escapeHtml(section.description)}</small>
            <div class="lc-resource-list">
              ${nodes.map((node) => `
                <button
                  class="lc-resource-node"
                  data-resource-id="${escapeHtml(node.id)}"
                  data-resource-type="${node.resourceType}"
                  data-active="${node.active}"
                >
                  <strong>${escapeHtml(node.label)}</strong><br />
                  <small>${escapeHtml(node.status === "ready" ? "就绪" : node.status === "draft" ? "草稿" : "待完善")}</small>
                </button>
              `).join("")}
            </div>
          </section>
        `;
      }).join("")}
    </nav>
  `;
}

function renderDesignerContextPanel(workbench: DemoWorkbench): string {
  const activeMode = workbench.activeDesignerMode;
  const content: Record<DesignerMode, { title: string; lines: string[] }> = {
    application: {
      title: "应用设计",
      lines: ["应用信息", "菜单结构", "模块边界"]
    },
    object: {
      title: "对象设计",
      lines: ["字段建模", "编码规则", "唯一约束"]
    },
    page: {
      title: "页面设计",
      lines: ["页面布局", "组件属性", "条件显隐"]
    },
    workflow: {
      title: "流程设计",
      lines: ["提交审批", "节点流转", "终态检查"]
    },
    permission: {
      title: "权限设计",
      lines: ["角色矩阵", "字段权限", "按钮权限"]
    },
    integration: {
      title: "集成设计",
      lines: ["导入导出", "外部接口", "应用包契约"]
    }
  };
  const panel = content[activeMode];

  return `
    <section class="lc-context-panel" data-role="designer-context" data-designer-mode="${activeMode}">
      <span class="lc-section-label">${escapeHtml(panel.title)}</span>
      <div class="lc-tags">
        ${panel.lines.map((line) => `<span class="lc-tag">${escapeHtml(line)}</span>`).join("")}
      </div>
      ${renderActiveDesignerPanel(workbench)}
    </section>
  `;
}

function renderReadinessPanel(readiness: DesignerReadinessReport): string {
  return `
    <section class="lc-readiness-panel" data-role="readiness-panel">
      <span class="lc-section-label">发布检查</span>
      <strong>${readiness.summary.blocking > 0 ? "存在阻断项" : "可发布"}</strong>
      <small>共 ${readiness.summary.total} 项，阻断 ${readiness.summary.blocking} 项，提醒 ${readiness.summary.warning} 项</small>
      <div class="lc-readiness-list">
        ${readiness.items.map((item) => `
          <button
            class="lc-readiness-item"
            data-severity="${item.severity}"
            data-readiness-code="${item.code}"
            data-resource-id="${escapeHtml(item.resourceId)}"
          >
            <strong>${escapeHtml(item.label)}</strong><br />
            <small>${escapeHtml(item.message)}</small><br />
            <small>${escapeHtml(item.primaryAction)}：${escapeHtml(item.fixHint)}</small>
          </button>
        `).join("")}
      </div>
    </section>
  `;
}

function renderRuntimePreviewFeedback(
  workbench: DemoWorkbench,
  published: PublishedWorkbench,
  readiness: DesignerReadinessReport
): string {
  const integrationItem = readiness.items.find((item) => item.code === "integration-contract");
  const packageChannel = getIntegrationContract(workbench).channels.find((channel) => channel.code === "app-package");

  return `
    <section class="lc-side-note" data-role="runtime-preview-feedback">
      <span class="lc-section-label">运行态预览反馈</span>
      <strong>${workbench.statusTag === "published" ? "运行态预览使用已发布快照" : "运行态预览仍在草稿快照中"}</strong><br />
      <small>metaHash：${escapeHtml(published.publishRequest.payload.metaHash)}</small>
      <div class="lc-tags">
        <span class="lc-tag">发布检查：${readiness.summary.passed}/${readiness.summary.total} 通过，${readiness.summary.warning} 项需确认</span>
        ${packageChannel && integrationItem
          ? `<span class="lc-tag">应用包入口：${escapeHtml(packageChannel.name)}仍需${escapeHtml(integrationItem.primaryAction)}</span>`
          : ""}
      </div>
    </section>
  `;
}

function renderActiveDesignerPanel(workbench: DemoWorkbench): string {
  if (workbench.activeDesignerMode === "page") {
    return `${renderLayoutBlueprintPanel(workbench)}${renderFormDesignerExtensions(workbench)}`;
  }
  if (workbench.activeDesignerMode === "workflow") {
    return renderWorkflowBlueprintPanel(workbench);
  }
  if (workbench.activeDesignerMode === "permission") {
    return renderPermissionMatrixPanel(workbench);
  }
  if (workbench.activeDesignerMode === "integration") {
    return renderIntegrationContractPanel(workbench);
  }
  return "";
}

function renderLayoutBlueprintPanel(workbench: DemoWorkbench): string {
  const blueprint = getDesignerLayoutBlueprint(workbench);
  const activePage = blueprint.pages.find((page) => page.pageType === workbench.previewMode) ?? blueprint.pages[0];
  const columnLabel = `${activePage.columns} 列栅格`;

  return `
    <section class="lc-blueprint-panel" data-role="layout-blueprint">
      <strong>${escapeHtml(activePage.title)}</strong>
      <small>${escapeHtml(columnLabel)} / ${activePage.density === "compact" ? "紧凑密度" : "舒适密度"} / ${activePage.nodeCount} 个节点</small>
      <div class="lc-blueprint-list">
        ${activePage.containers.map((container) => `
          <article class="lc-blueprint-row" data-layout-node="${escapeHtml(container.nodeId)}">
            <span>${escapeHtml(container.label)}</span>
            <small>${escapeHtml(formatLayoutKind(container.kind))}${container.columns ? ` / ${container.columns} 列 / ${escapeHtml(formatResponsiveMode(container.responsive))}` : ""}</small>
          </article>
        `).join("")}
      </div>
      <div class="lc-blueprint-list">
        ${activePage.fields.map((field) => `
          <article class="lc-blueprint-row" data-field-code="${escapeHtml(field.code)}">
            <span>${escapeHtml(field.label)}</span>
            <small>${escapeHtml(field.fieldType)}${field.required ? " / 必填" : ""}</small>
          </article>
        `).join("")}
      </div>
      <div class="lc-blueprint-list">
        ${activePage.fieldBindings.map((binding) => `
          <article class="lc-blueprint-row" data-layout-binding="${escapeHtml(binding.nodeId)}">
            <span>${escapeHtml(binding.label)}</span>
            <small>字段绑定 / ${escapeHtml(binding.sectionId ?? "页面根节点")} / 跨 ${binding.span} 列</small>
          </article>
        `).join("")}
      </div>
    </section>
  `;
}

function renderFormDesignerExtensions(workbench: DemoWorkbench): string {
  return `
    ${renderOpenSourceDesignerSurfacePanel(workbench)}
    ${renderRuleCenterPanel(workbench)}
    ${renderPreviewTestPanel(workbench)}
    ${renderSchemaJsonPanel(workbench)}
    ${renderTemplateReusePanel(workbench)}
  `;
}

function renderOpenSourceDesignerSurfacePanel(workbench: DemoWorkbench): string {
  const surface = getFormDesignerSurface(workbench);
  const selectedSchema = surface.formilyDesignable.formilySchema.properties[workbench.selectedFieldCode];
  const selectedReactions = surface.formilyDesignable.reactionDesigner.rules.filter((rule) => (
    rule.source === workbench.selectedFieldCode || rule.target === workbench.selectedFieldCode
  ));
  return `
    <section class="lc-rule-panel" data-role="open-source-designer-surface">
      <span class="lc-section-label">开源表单设计器骨架</span>
      <div class="lc-tags" data-role="designer-tabs">
        ${surface.tabs.map((tab) => `<span class="lc-tag">${escapeHtml(tab.label)}</span>`).join("")}
      </div>
      <div class="lc-tags" data-role="display-modes">
        ${surface.displayModes.map((mode) => `<span class="lc-tag">${escapeHtml(mode.label)}</span>`).join("")}
      </div>
      <div class="lc-blueprint-list" data-role="component-toolbox">
        ${surface.toolbox.categories.map((category) => `
          <article class="lc-blueprint-row" data-toolbox-category="${escapeHtml(category.code)}">
            <span>${escapeHtml(category.label)}</span>
            <small>${category.components.map((component) => escapeHtml(component.label)).join(" / ")}</small>
          </article>
        `).join("")}
      </div>
      <div class="lc-tags" data-role="property-grid">
        <span class="lc-section-label">属性网格</span>
        ${surface.propertyGrid.tabs.map((tab) => `<span class="lc-tag">${escapeHtml(tab.label)}</span>`).join("")}
      </div>
      <div class="lc-blueprint-list" data-role="component-outline">
        <span class="lc-section-label">组件树</span>
        ${surface.outline.nodes.map((node) => `
          <article class="lc-blueprint-row" data-outline-node="${escapeHtml(node.id)}">
            <span>${escapeHtml(node.label)}</span>
            <small>${escapeHtml(formatLayoutKind(node.kind))}</small>
          </article>
        `).join("")}
      </div>
      <div class="lc-blueprint-list" data-role="formily-designable">
        <article class="lc-blueprint-row">
          <span>${escapeHtml(surface.formilyDesignable.engine)} / ${escapeHtml(surface.formilyDesignable.formCore)}</span>
          <small>${escapeHtml(surface.formilyDesignable.schemaDialect)} / x-reactions / ${surface.formilyDesignable.adapterPackages.map((name) => escapeHtml(name)).join(" / ")}</small>
        </article>
        ${surface.formilyDesignable.workbenchPanels.map((panel) => `
          <article class="lc-blueprint-row" data-formily-panel="${escapeHtml(panel.code)}">
            <span>${escapeHtml(panel.label)}</span>
            <small>阿里 Designable 工作台面板</small>
          </article>
        `).join("")}
      </div>
      ${selectedSchema
        ? `
          <div class="lc-blueprint-list" data-role="formily-schema-protocol">
            <span class="lc-section-label">Formily x-* 协议</span>
            <article class="lc-blueprint-row">
              <span>${escapeHtml(selectedSchema.title)}</span>
              <small>x-component：${escapeHtml(selectedSchema["x-component"])} / x-decorator：${escapeHtml(selectedSchema["x-decorator"])}</small>
            </article>
            <article class="lc-blueprint-row">
              <span>x-validator</span>
              <small>${selectedSchema["x-validator"].map((validator) => escapeHtml(validator.message)).join(" / ") || "暂无字段级校验器"}</small>
            </article>
            <article class="lc-blueprint-row">
              <span>x-component-props</span>
              <small>${escapeHtml(formatJson(selectedSchema["x-component-props"]))}</small>
            </article>
          </div>
        `
        : ""}
      <div class="lc-blueprint-list" data-role="x-reactions-designer">
        <span class="lc-section-label">x-reactions 可视化规则</span>
        ${(selectedReactions.length > 0 ? selectedReactions : surface.formilyDesignable.reactionDesigner.rules).map((rule) => `
          <article class="lc-blueprint-row" data-reaction-source="${escapeHtml(rule.source)}" data-reaction-target="${escapeHtml(rule.target)}">
            <span>source：${escapeHtml(rule.source)} / target：${escapeHtml(rule.target)}</span>
            <small>${escapeHtml(rule.when)} / fulfill ${escapeHtml(formatJson(rule.fulfill.state))} / otherwise ${escapeHtml(formatJson(rule.otherwise.state))}</small>
          </article>
        `).join("")}
      </div>
      <div class="lc-blueprint-list" data-role="designable-workbench-state">
        <span class="lc-section-label">Designable 工作台状态</span>
        <article class="lc-blueprint-row">
          <span>${escapeHtml(surface.formilyDesignable.workbench.selectedNodeId)}</span>
          <small>当前面板：${escapeHtml(formatDesignablePanel(surface.formilyDesignable.workbench.activePanel))} / Schema 编辑器：${surface.formilyDesignable.workbench.schemaEditor.editable ? "可编辑" : "只读"}</small>
        </article>
        <article class="lc-blueprint-row">
          <span>拖拽源</span>
          <small>${surface.formilyDesignable.workbench.dragSources.map((item) => escapeHtml(item.label)).join(" / ")}</small>
        </article>
      </div>
    </section>
  `;
}

function renderRuleCenterPanel(workbench: DemoWorkbench): string {
  const ruleCenter = getFormRuleCenter(workbench);
  return `
    <section class="lc-rule-panel" data-role="rule-center">
      <span class="lc-section-label">规则中心</span>
      <strong>IF-THEN 规则链</strong>
      <div class="lc-rule-grid">
        ${ruleCenter.rules.map((rule) => `
          <article class="lc-rule-row" data-rule-code="${escapeHtml(rule.code)}">
            <span>当 ${escapeHtml(formatRuleCondition(rule))}</span><br />
            <small>则 ${escapeHtml(formatRuleActions(rule))}</small>
          </article>
        `).join("")}
      </div>
      <div class="lc-meta-line">
        ${ruleCenter.diagnostics.length > 0
          ? ruleCenter.diagnostics.map((item) => `<small>${escapeHtml(item.message)}</small>`).join("")
          : "<small>规则引用完整，发布前仍以后端全图校验为准。</small>"}
      </div>
    </section>
  `;
}

function renderPreviewTestPanel(workbench: DemoWorkbench): string {
  const ruleCenter = getFormRuleCenter(workbench);
  return `
    <section class="lc-rule-panel" data-role="preview-test">
      <span class="lc-section-label">Preview 测试</span>
      <strong>${ruleCenter.previewTest.enabled ? "已启用样例记录校验" : "未启用预览测试"}</strong>
      <div class="lc-code">
        <strong>样例记录</strong>
        ${escapeHtml(formatJson(ruleCenter.previewTest.sampleRecord))}
      </div>
    </section>
  `;
}

function renderSchemaJsonPanel(workbench: DemoWorkbench): string {
  const schemaView = getSchemaJsonView(workbench);
  return `
    <section class="lc-rule-panel" data-role="schema-json-view">
      <span class="lc-section-label">Schema JSON 高级视图</span>
      <strong>字段、布局、规则、权限、流程统一预览</strong>
      <div class="lc-tags">
        <span class="lc-tag">字段 ${schemaView.schema.fields.length}</span>
        <span class="lc-tag">页面 ${schemaView.schema.layout.pages.length}</span>
        <span class="lc-tag">规则 ${schemaView.schema.rules.rules.length}</span>
        <span class="lc-tag">角色 ${schemaView.schema.permissions.roles.length}</span>
        <span class="lc-tag">流程节点 ${schemaView.schema.workflow.nodes.length}</span>
      </div>
      <small>完整 JSON 由 Schema 编辑器管理，主界面只展示结构摘要，避免把内部枚举和调试原文直接暴露给业务设计人员。</small>
    </section>
  `;
}

function renderTemplateReusePanel(workbench: DemoWorkbench): string {
  const catalog = getFormTemplateCatalog(workbench);
  return `
    <section class="lc-rule-panel" data-role="template-reuse">
      <span class="lc-section-label">模板复用入口</span>
      <strong>表单模板复用</strong>
      <div class="lc-tags">
        <span class="lc-tag">新建表单</span>
        <span class="lc-tag">复用详情表单布局</span>
      </div>
      <div class="lc-template-grid">
        ${catalog.templates.map((template) => `
          <article class="lc-template-row" data-form-template="${escapeHtml(template.code)}">
            <span>${escapeHtml(formatFormTemplateName(template.name))}</span><br />
            <small>${escapeHtml(formatTemplateReuseStrategy(template.code, template.reuseStrategy, template.sourceTemplateCode))}</small>
          </article>
        `).join("")}
      </div>
    </section>
  `;
}

function renderWorkflowBlueprintPanel(workbench: DemoWorkbench): string {
  const workflow = getDesignerWorkflowBlueprint(workbench);
  return `
    <section class="lc-blueprint-panel" data-role="workflow-blueprint">
      <strong>${escapeHtml(workflow.name)}</strong>
      <small>${workflow.publishReady ? "发布门禁已通过" : "发布门禁未通过"}</small>
      <div class="lc-blueprint-list">
        ${workflow.nodes.map((node) => `
          <article class="lc-blueprint-row" data-workflow-node="${escapeHtml(node.code)}">
            <span>${escapeHtml(node.name)}</span>
            <small>${escapeHtml(node.kind === "approval" ? "审批节点" : node.kind === "start" ? "起始节点" : "终态节点")} / ${escapeHtml(node.assignee)}</small>
          </article>
        `).join("")}
      </div>
      <div class="lc-blueprint-list">
        ${workflow.transitions.map((transition) => `
          <article class="lc-blueprint-row" data-workflow-action="${escapeHtml(transition.actionCode)}">
            <span>${escapeHtml(transition.actionName)}</span>
            <small>${escapeHtml(formatWorkflowNodeCode(transition.from))} 到 ${escapeHtml(formatWorkflowNodeCode(transition.to))} / ${escapeHtml(transition.actionName)}</small>
          </article>
        `).join("")}
      </div>
    </section>
  `;
}

function renderPermissionMatrixPanel(workbench: DemoWorkbench): string {
  const matrix = getPermissionMatrix(workbench);
  return `
    <section class="lc-blueprint-panel" data-role="permission-matrix">
      <strong>角色权限矩阵</strong>
      <small>${matrix.roles.length} 个角色 / ${matrix.entries.length} 条页面权限 / ${matrix.fieldPermissions.length} 条字段权限</small>
      <div class="lc-blueprint-list">
        ${matrix.roles.map((role) => `
          <article class="lc-blueprint-row" data-role-code="${escapeHtml(role.code)}">
            <span>${escapeHtml(role.name)}</span>
            <small>${escapeHtml(role.description)}</small>
          </article>
        `).join("")}
      </div>
      <div class="lc-blueprint-list">
        ${matrix.fieldPermissions.slice(0, 8).map((entry) => `
          <article class="lc-blueprint-row" data-field-permission="${escapeHtml(`${entry.roleCode}:${entry.fieldCode}`)}">
            <span>${escapeHtml(entry.fieldCode)}</span>
            <small>${escapeHtml(formatRoleCode(entry.roleCode))} / ${escapeHtml(formatPermissionCapability(entry.permission))}</small>
          </article>
        `).join("")}
        ${matrix.actionPermissions.map((entry) => `
          <article class="lc-blueprint-row" data-action-permission="${escapeHtml(`${entry.roleCode}:${entry.actionCode}`)}">
            <span>${escapeHtml(formatActionCode(entry.actionCode))}</span>
            <small>${escapeHtml(formatRoleCode(entry.roleCode))} / ${entry.allowed ? "允许" : "禁止"}</small>
          </article>
        `).join("")}
      </div>
    </section>
  `;
}

function formatComponentType(componentType: "form-field" | "list-column" | "detail-item"): string {
  if (componentType === "list-column") {
    return "列表列";
  }
  if (componentType === "detail-item") {
    return "详情项";
  }
  return "表单字段";
}

function formatPreviewMode(pageType: PreviewMode): string {
  if (pageType === "list") {
    return "列表页";
  }
  if (pageType === "detail") {
    return "详情页";
  }
  return "表单页";
}

function formatWorkflowNodeCode(code: string): string {
  const labels: Record<string, string> = {
    draft: "草稿提交",
    dept_approval: "部门负责人审批",
    approved: "审批通过"
  };
  return labels[code] ?? code;
}

function formatRoleCode(roleCode: string): string {
  const labels: Record<string, string> = {
    admin: "平台管理员",
    operator: "业务经办人",
    viewer: "只读观察者"
  };
  return labels[roleCode] ?? roleCode;
}

function formatPermissionCapability(permission: string): string {
  const labels: Record<string, string> = {
    READ: "可读",
    WRITE: "可写",
    MASKED: "脱敏",
    NONE: "不可见"
  };
  return labels[permission] ?? permission;
}

function formatActionCode(actionCode: string): string {
  const labels: Record<string, string> = {
    submit: "提交审批",
    approve: "审批通过"
  };
  return labels[actionCode] ?? actionCode;
}

function renderIntegrationContractPanel(workbench: DemoWorkbench): string {
  const contract = getIntegrationContract(workbench);
  return `
    <section class="lc-blueprint-panel" data-role="integration-contract">
      <strong>集成契约基线</strong>
      <small>${contract.publishReady ? "具备发布基线，外部对接方仍需人工确认" : "缺少集成契约"}</small>
      <div class="lc-blueprint-list">
        ${contract.channels.map((channel) => `
          <article class="lc-blueprint-row" data-integration-channel="${escapeHtml(channel.code)}">
            <span>${escapeHtml(channel.name)}</span>
            <small>${escapeHtml(channel.direction)} / ${channel.idempotent ? "幂等" : "非幂等"} / ${escapeHtml(channel.securityPolicy)}</small>
          </article>
        `).join("")}
      </div>
    </section>
  `;
}

function renderPreviewPanel(
  workbench: DemoWorkbench,
  runtime: ReturnType<typeof createPreviewSnapshot>["runtime"],
  dragState: DragState
): string {
  if (workbench.activeDesignerMode === "page" && workbench.previewMode === "form") {
    return renderLegacyWorkbenchCompatPanel(workbench, dragState);
  }
  if (workbench.previewMode === "list") {
    return renderListPreview(runtime.rows[0] ?? {}, workbench, dragState);
  }
  if (workbench.previewMode === "detail") {
    return renderDetailPreview(workbench, dragState);
  }
  return renderFormPreview(workbench, dragState);
}

function renderLegacyWorkbenchCompatPanel(workbench: DemoWorkbench, dragState: DragState): string {
  return `
    <section class="lc-side-note" data-role="legacy-workbench-canvas-summary">
      <span class="lc-section-label">兼容画布摘要</span>
      <strong>主设计器已经上移到页面首屏</strong><br />
      <small>这里保留旧三栏入口，用于页面配置、发布检查和调试信息，不再承载主要表单设计体验。</small>
      ${renderFormPreview(workbench, dragState)}
    </section>
  `;
}

function renderDesignableWorkbenchPanel(workbench: DemoWorkbench, dragState: DragState): string {
  const surface = getFormDesignerSurface(workbench);
  const selectedSchema = surface.formilyDesignable.formilySchema.properties[workbench.selectedFieldCode];
  const selectedReactions = surface.formilyDesignable.reactionDesigner.rules.filter((rule) => (
    rule.source === workbench.selectedFieldCode || rule.target === workbench.selectedFieldCode
  ));
  const reactions = selectedReactions.length > 0 ? selectedReactions : surface.formilyDesignable.reactionDesigner.rules;
  const layoutNodes = getFormLayoutNodes(workbench, "form");
  const activeField = workbench.recordSchema.find((field) => field.code === workbench.selectedFieldCode);
  const controlTiles = ["文本", "金额", "日期", "下拉", "复选框", "附件", "图片", "富文本"];
  const businessTiles = ["单据编号", "基础资料", "组织", "物料", "币别", "客户", "部门", "人员"];

  return `
    <section class="lc-designable-shell" data-role="designable-workbench-shell" data-source-layout="alibaba-designable">
      <header class="lc-studio-header" data-role="studio-panel-header">
        <div class="lc-window-dots" aria-hidden="true">
          <span class="lc-window-dot"></span>
          <span class="lc-window-dot"></span>
          <span class="lc-window-dot"></span>
        </div>
        <div class="lc-bos-brand">
          <span class="lc-bos-logo" aria-hidden="true"></span>
          <span>低代码 BOS</span>
        </div>
        <nav class="lc-bos-nav">
          <span data-active="true">表单设计</span>
          <span>业务对象</span>
          <span>业务规则</span>
          <span>权限发布</span>
        </nav>
        <div class="lc-bos-title">
          <strong>客户合同单据设计器</strong><br />
          <small>BOS 业务对象建模 / 单据表单 / 权限规则配置 <span hidden>Formily / Designable StudioPanel / CompositePanel / WorkspacePanel / ViewportPanel / SettingsPanel</span></small>
        </div>
      </header>
      <div class="lc-bos-editbar">
        <div class="lc-bos-editbar-left"></div>
        <div class="lc-bos-editbar-tools" data-role="studio-panel-actions">
          <button class="lc-bos-tool">重做</button>
          <button class="lc-bos-tool">删除</button>
          <button class="lc-bos-tool">前移</button>
          <button class="lc-bos-tool">后移</button>
          <button class="lc-bos-tool">撤销</button>
          <button class="lc-bos-tool">剪切</button>
          <button class="lc-bos-tool">复制</button>
          <button class="lc-bos-tool">粘贴</button>
          <button class="lc-bos-tool">保存</button>
        </div>
        <div class="lc-bos-editbar-right">字段属性</div>
      </div>
      <div class="lc-studio-body" data-role="studio-panel">
        <aside class="lc-composite-panel" data-role="composite-panel">
          <nav class="lc-composite-tabs">
            <button class="lc-composite-tab" data-role="composite-tab-components" data-active="true">组件</button>
            <button class="lc-composite-tab" data-role="composite-tab-outline">结构</button>
            <button class="lc-composite-tab" data-role="composite-tab-history">历史</button>
          </nav>
          <div class="lc-composite-body">
            <section data-role="resource-widget">
              <input class="lc-bos-search" value="查找字段|控件" readonly />
              <div class="lc-bos-section-title">控件字段 <span>⌄</span></div>
              <div class="lc-template-list">
                ${controlTiles.map((label, index) => `
                  <article class="lc-template-card" data-toolbox-category="${escapeHtml(surface.toolbox.categories[index % surface.toolbox.categories.length]?.code ?? "basic")}">
                    <strong>${escapeHtml(label)}</strong><br />
                    <small>ResourceWidget / 组件源</small>
                  </article>
                `).join("")}
              </div>
              <div class="lc-bos-section-title">业务字段 <span>⌄</span></div>
              <div class="lc-template-list">
                ${businessTiles.map((label, index) => `
                  <article class="lc-template-card" data-toolbox-category="${escapeHtml(surface.toolbox.categories[index % surface.toolbox.categories.length]?.code ?? "business")}">
                    <strong>${escapeHtml(label)}</strong><br />
                    <small>业务对象字段</small>
                  </article>
                `).join("")}
              </div>
            </section>
            <section class="lc-side-note" data-role="outline-tree-widget">
              <div class="lc-bos-section-title">页面结构 <span>⌄</span></div>
              <div class="lc-designable-tree">
                ${layoutNodes.map((node) => `
                  <button
                    class="lc-designable-node"
                    data-active="${node.fieldCode === workbench.selectedFieldCode}"
                    data-layout-node-id="${escapeHtml(node.id)}"
                  >
                    <span>${escapeHtml(node.label)}</span><br />
                    <small>${escapeHtml(formatLayoutKind(node.kind))}${node.fieldCode ? ` / ${escapeHtml(node.fieldCode)}` : ""}</small>
                  </button>
                `).join("")}
              </div>
            </section>
            <section class="lc-side-note" data-role="history-widget">
              <span class="lc-section-label">HistoryWidget / 历史记录</span>
              <small>最近操作：选择 ${escapeHtml(activeField?.name ?? "页面根节点")}，拖拽、属性修改、发布快照进入撤销栈。</small>
            </section>
          </div>
        </aside>
        <main class="lc-workspace-panel" data-role="workspace-panel">
          <div class="lc-designable-toolbar" data-role="toolbar-panel">
            <span data-role="designable-toolbar" hidden></span>
            <div data-role="designer-tools-widget">
              <strong>新增 删除 保存 修改 提交 审核 打印</strong><br />
              <small>DesignerToolsWidget：选择、拖拽、撤销、重做、设备预览</small>
            </div>
            <div class="lc-designable-tabs" data-role="view-tools-widget">
              <span class="lc-designable-tab" data-active="true">表单</span>
              <span class="lc-designable-tab">单据体</span>
              <span class="lc-designable-tab">业务规则</span>
              <span class="lc-designable-tab">Schema 编辑</span>
              <span class="lc-designable-tab" hidden>设计 JSON Tree Markup Preview</span>
            </div>
          </div>
          <section class="lc-viewport-panel" data-role="viewport-panel">
            <section class="lc-side-note">
              <span class="lc-section-label">对象与字段</span>
              <strong>${escapeHtml(workbench.objectCode)}</strong><br />
              <small>字段面板、页面 Schema、默认页面和发布快照围绕同一个对象工作。</small>
            </section>
            <section class="lc-view-panel" data-view-panel="designable" data-active="true">
              <span class="lc-section-label">客户合同单据 / ViewPanel / DESIGNABLE</span>
              <div class="lc-designable-grid" data-role="designable-main-grid">
                <aside class="lc-designable-pane" data-role="designable-component-tree">
                  <span class="lc-section-label">ComponentTreeWidget</span>
                  <div class="lc-designable-tree">
                    ${layoutNodes.map((node) => `
                      <button
                        class="lc-designable-node"
                        data-active="${node.fieldCode === workbench.selectedFieldCode}"
                        data-layout-node-id="${escapeHtml(node.id)}"
                      >
                        <span>${escapeHtml(node.label)}</span><br />
                        <small>${escapeHtml(formatLayoutKind(node.kind))}${node.fieldCode ? ` / ${escapeHtml(node.fieldCode)}` : ""}</small>
                      </button>
                    `).join("")}
                  </div>
                </aside>
                <section class="lc-designable-pane" data-role="designable-canvas-pane" data-density="readable">
                  <span class="lc-section-label">设计画布</span>
                  <div class="lc-bos-bill-actions">
                    ${["新增", "删除", "保存", "修改", "提交", "审核", "提交并新增", "打印", "更多", "退出"].map((label) => `
                      <span class="lc-bos-bill-button">${escapeHtml(label)}</span>
                    `).join("")}
                  </div>
                  ${renderFormPreview(workbench, dragState)}
                  <section class="lc-bos-attachment">
                    <strong>附件</strong>
                    <small>支持 ctrl+v 粘贴截图</small>
                    <div class="lc-bos-attachment-box">附件内容区</div>
                  </section>
                </section>
              </div>
            </section>
            <div class="lc-view-panel-stack">
              <section class="lc-side-note lc-view-panel" data-view-panel="json" data-active="false">
                <span class="lc-section-label">ViewPanel / JSONTREE</span>
                <small>JSON Tree 由 SchemaEditorWidget 管理，当前字段 ${escapeHtml(workbench.selectedFieldCode)}。</small>
              </section>
              <section class="lc-side-note lc-view-panel" data-view-panel="markup" data-active="false">
                <span class="lc-section-label">ViewPanel / MARKUP</span>
                <small>MarkupSchemaWidget 输出组件源码视图。</small>
              </section>
              <section class="lc-side-note lc-view-panel" data-view-panel="preview" data-active="false">
                <span class="lc-section-label">ViewPanel / PREVIEW</span>
                <small>PreviewWidget 使用发布快照渲染运行态表单。</small>
              </section>
            </div>
          </section>
        </main>
        <aside class="lc-settings-panel" data-role="settings-panel">
          <div class="lc-settings-header">
            <strong>字段属性</strong><br />
            <small>当前节点：${escapeHtml(surface.formilyDesignable.workbench.selectedNodeId)}</small>
          </div>
          <section class="lc-settings-section" data-role="settings-section-property">
            <div class="lc-bos-section-title">基础属性 <span>⌄</span></div>
            ${selectedSchema
              ? `
                <strong>${escapeHtml(selectedSchema.title)}</strong>
                <div class="lc-bos-field-row"><span>字段标识</span><span class="lc-bos-input">${escapeHtml(workbench.selectedFieldCode)}</span></div>
                <div class="lc-bos-field-row"><span>字段名称</span><span class="lc-bos-input">${escapeHtml(selectedSchema.title)}</span></div>
                <div class="lc-bos-field-row"><span>控件类型</span><span class="lc-bos-input">${escapeHtml(selectedSchema["x-component"])}</span></div>
                <div class="lc-bos-field-row"><span>装饰器</span><span class="lc-bos-input">${escapeHtml(selectedSchema["x-decorator"])}</span></div>
                <div class="lc-protocol-row" hidden>
                  <span>x-component：${escapeHtml(selectedSchema["x-component"])}</span>
                  <small>x-decorator：${escapeHtml(selectedSchema["x-decorator"])}</small>
                  <span>x-component-props</span>
                  <small>${escapeHtml(formatJson(selectedSchema["x-component-props"]))}</small>
                </div>
              `
              : "<small>当前节点没有绑定 Formily 字段协议。</small>"}
          </section>
          <section class="lc-settings-section" data-role="settings-section-style">
            <div class="lc-bos-section-title">布局属性 <span>⌄</span></div>
            <div class="lc-bos-field-row"><span>所属分组</span><span class="lc-bos-input">基本信息</span></div>
            <div class="lc-bos-field-row"><span>标签宽度</span><span class="lc-bos-input">120 px</span></div>
            <div class="lc-bos-field-row"><span>跨列</span><span class="lc-bos-input">1</span></div>
          </section>
          <section class="lc-settings-section" data-role="settings-section-validation">
            <div class="lc-bos-section-title">业务规则 / 校验 <span>⌄</span></div>
            ${selectedSchema
              ? selectedSchema["x-validator"].map((validator) => `<small>${escapeHtml(validator.message)}</small>`).join("<br />")
              : "<small>暂无校验器</small>"}
          </section>
          <section class="lc-settings-section" data-role="settings-section-reactions">
            <div class="lc-bos-section-title">联动 / 状态控制 <span>⌄</span></div>
            ${reactions.map((rule) => `
              <div class="lc-protocol-row">
                <span>联动：${escapeHtml(rule.source)} -> ${escapeHtml(rule.target)}</span>
                <small>${escapeHtml(rule.when)}</small>
              </div>
            `).join("")}
          </section>
          <section class="lc-settings-section" data-role="settings-section-data-source">
            <div class="lc-bos-section-title">权限 / 事件 <span>⌄</span></div>
            <div class="lc-bos-field-row"><span>权限</span><span class="lc-bos-input">可见 / 可编辑 / 脱敏</span></div>
            <div class="lc-bos-field-row"><span>事件</span><span class="lc-bos-input">保存前 / 提交后 / 插件</span></div>
            <small>对象：${escapeHtml(workbench.objectCode)} / 字段：${escapeHtml(workbench.selectedFieldCode)}</small>
          </section>
        </aside>
      </div>
    </section>
  `;
}

function renderFieldCard(field: DraftFieldDefinition, active: boolean): string {
  return `
    <button
      class="lc-field-card"
      data-field-code="${field.code}"
      data-drag-source="field-list"
      data-active="${active}"
    >
      <strong>${escapeHtml(field.name)}</strong><br />
      <small>${escapeHtml(field.code)} / ${escapeHtml(field.fieldType)}</small>
      <div class="lc-tags">
        ${field.required ? '<span class="lc-tag">必填</span>' : ""}
        ${field.inList ? '<span class="lc-tag">列表</span>' : ""}
        ${field.hidden ? '<span class="lc-tag">隐藏</span>' : ""}
      </div>
    </button>
  `;
}

function renderFormPreview(workbench: DemoWorkbench, dragState: DragState): string {
  const visibleFields = createCanvasRuntimeFields(workbench);
  const runtimeFields = new Map(visibleFields.map((field) => [field.code, field]));
  const root = workbench.pageConfigs.form.layoutTree;
  return `
    <div class="lc-form-preview" data-role="canvas-field-list" data-density="readable">
      ${renderLayoutNode(root, workbench, runtimeFields, dragState)}
      <div class="lc-compat-drop-zones" aria-hidden="true">
        ${workbench.recordSchema.map((_, index) => renderDropZone(index, dragState)).join("")}
      </div>
      ${renderDropZone(workbench.recordSchema.length, dragState)}
    </div>
    <span data-role="canvas-field-list-end" hidden></span>
  `;
}

function renderLayoutNode(
  node: FormLayoutNode,
  workbench: DemoWorkbench,
  runtimeFields: Map<string, CanvasFieldView>,
  dragState: DragState,
  parentColumns = 1
): string {
  if (node.kind === "form") {
    return `
      <section class="lc-layout-root" data-layout-node-id="${escapeHtml(node.id)}" data-layout-kind="form">
        ${(node.children ?? []).map((child) => renderLayoutNode(child, workbench, runtimeFields, dragState, parentColumns)).join("")}
      </section>
    `;
  }

  if (node.kind === "body") {
    return `
      <section class="lc-layout-body" data-layout-node-id="${escapeHtml(node.id)}" data-layout-kind="body">
        ${(node.children ?? []).map((child) => renderLayoutNode(child, workbench, runtimeFields, dragState, parentColumns)).join("")}
      </section>
    `;
  }

  if (node.kind === "section") {
    return `
      <section class="lc-layout-section" data-layout-node-id="${escapeHtml(node.id)}" data-layout-kind="section">
        <div class="lc-layout-section-header">
          <strong>${escapeHtml(node.label)}</strong>
          <small>分组</small>
        </div>
        ${(node.children ?? []).map((child) => renderLayoutNode(child, workbench, runtimeFields, dragState, parentColumns)).join("")}
      </section>
    `;
  }

  if (node.kind === "grid") {
    const columns = node.columns ?? 2;
    return `
      <div
        class="lc-layout-grid"
        data-layout-readability="stable"
        data-layout-node-id="${escapeHtml(node.id)}"
        data-layout-kind="grid"
        data-layout-columns="${columns}"
        data-layout-min-columns="${node.minColumns ?? 1}"
        data-layout-max-columns="${node.maxColumns ?? columns}"
        data-layout-responsive="${node.responsive ?? "fixed"}"
        style="--layout-columns: ${columns}"
      >
        ${(node.children ?? []).map((child) => renderLayoutNode(child, workbench, runtimeFields, dragState, columns)).join("")}
      </div>
    `;
  }

  if (node.kind === "field" && node.fieldCode) {
    const field = runtimeFields.get(node.fieldCode);
    if (!field) {
      return "";
    }
    const span = Math.max(1, Math.min(parentColumns, node.span ?? 1));

    return `
      <div
        class="lc-layout-field"
        data-layout-node-id="${escapeHtml(node.id)}"
        data-layout-kind="field"
        data-layout-span="${span}"
        style="--layout-span: ${span}"
      >
        ${renderDropZone(getSchemaIndex(workbench, field.code), dragState)}
        <button
          class="lc-preview-field"
          draggable="true"
          data-field-code="${field.code}"
          data-drag-source="canvas-field"
          data-selected="${field.code === workbench.selectedFieldCode}"
        >
          <label>
            <span>${escapeHtml(field.label)}</span>
            <span>${field.required ? '<span class="lc-required">必填</span>' : "可选"}</span>
          </label>
          <div class="lc-preview-input">${escapeHtml(renderPreviewValue(field.value))}</div>
          <small>${escapeHtml(field.fieldType)} / ${field.inList ? "列表可见" : "仅表单"}</small>
        </button>
      </div>
    `;
  }

  if (node.kind === "action-bar") {
    return `
      <section class="lc-action-bar" data-layout-node-id="${escapeHtml(node.id)}" data-layout-kind="action-bar">
        <div>
          <strong>${escapeHtml(node.label)}</strong><br />
          <small>按钮权限会跟随权限矩阵和流程动作</small>
        </div>
        ${(node.children ?? []).map((child) => renderLayoutNode(child, workbench, runtimeFields, dragState, parentColumns)).join("")}
      </section>
    `;
  }

  if (node.kind === "action") {
    return `
      <button class="lc-action-button" data-layout-node-id="${escapeHtml(node.id)}" data-layout-kind="action">
        ${escapeHtml(node.label)}
      </button>
    `;
  }

  return "";
}

function renderListPreview(row: Record<string, unknown>, workbench: DemoWorkbench, dragState: DragState): string {
  const visibleFields = workbench.pages.list.fields;
  return `
    <div class="lc-list-preview" data-role="canvas-field-list">
      ${renderDropZone(0, dragState)}
      <table class="lc-table">
        <thead>
          <tr>${visibleFields.map((fieldCode) => `<th>${escapeHtml(findFieldLabel(workbench, fieldCode))}</th>`).join("")}</tr>
        </thead>
        <tbody>
          <tr>${visibleFields.map((fieldCode) => `<td>${escapeHtml(renderPreviewValue(row[fieldCode]))}</td>`).join("")}</tr>
        </tbody>
      </table>
      ${Array.from({ length: workbench.recordSchema.length }, (_, index) => renderDropZone(index + 1, dragState)).join("")}
    </div>
  `;
}

function renderDetailPreview(workbench: DemoWorkbench, dragState: DragState): string {
  const visibleFields = createCanvasRuntimeFields(workbench);
  return `
    <div>
      <h3>详情预览</h3>
      <div class="lc-detail-grid" data-role="canvas-field-list">
        ${visibleFields.map((field) => `
          ${renderDropZone(getSchemaIndex(workbench, field.code), dragState)}
          <button
            class="lc-detail-card"
            draggable="true"
            data-field-code="${field.code}"
            data-drag-source="canvas-field"
            data-selected="${field.code === workbench.selectedFieldCode}"
          >
            <label>
              <span>${escapeHtml(field.label)}</span>
              <span>${field.required ? '<span class="lc-required">必填</span>' : "详情字段"}</span>
            </label>
            <div class="lc-preview-input">${escapeHtml(renderPreviewValue(field.value))}</div>
            <small>${escapeHtml(field.code)}</small>
          </button>
        `).join("")}
        ${renderDropZone(workbench.recordSchema.length, dragState)}
      </div>
    </div>
  `;
}

function createCanvasRuntimeFields(workbench: DemoWorkbench): CanvasFieldView[] {
  const runtimeFields = new Map(
    createPreviewSnapshot(workbench, workbench.previewMode).runtime.fields.map((field) => [field.code, field])
  );

  return workbench.recordSchema.flatMap((field) => {
    if (field.fieldType === "section" || field.fieldType === "columns" || field.fieldType === "note") {
      return [{
        code: field.code,
        label: field.name,
        fieldType: field.fieldType,
        permission: "WRITE" as const,
        value: workbench.previewRecord[field.code],
        editable: true,
        required: field.required === true,
        inList: field.inList === true
      }];
    }

    const runtimeField = runtimeFields.get(field.code);
    return runtimeField
      ? [{
        ...runtimeField,
        required: field.required === true,
        inList: field.inList === true
      }]
      : [];
  });
}

function getSchemaIndex(workbench: DemoWorkbench, fieldCode: string): number {
  const index = workbench.recordSchema.findIndex((field) => field.code === fieldCode);
  return index < 0 ? workbench.recordSchema.length : index;
}

function findFieldLabel(workbench: DemoWorkbench, fieldCode: string): string {
  return workbench.recordSchema.find((field) => field.code === fieldCode)?.name ?? fieldCode;
}

function renderPageConfigPanel(workbench: DemoWorkbench): string {
  const pageConfig = workbench.pageConfigs[workbench.previewMode];
  const visibleCodes = new Set(pageConfig.visibleFieldCodes);
  const candidateFields = workbench.recordSchema.filter((field) => (
    field.fieldType !== "section" && field.fieldType !== "columns" && field.fieldType !== "note" && !field.hidden
  ));

  return `
    <form class="lc-form lc-side-note" data-form="page-config">
      <span class="lc-section-label">页面配置</span>
      <div class="lc-check-grid">
        ${candidateFields.map((field) => `
          <label class="lc-checkbox">
            <input
              type="checkbox"
              name="visibleFieldCodes"
              value="${escapeHtml(field.code)}"
              ${visibleCodes.has(field.code) ? "checked" : ""}
            />
            ${escapeHtml(field.name)}
          </label>
        `).join("")}
      </div>
      <label class="lc-form-row">
        <span>布局列数</span>
        <select name="columns">
          ${[1, 2, 3, 4, 5, 6].map((columns) => `
            <option value="${columns}" ${pageConfig.layout.columns === columns ? "selected" : ""}>${columns} 列</option>
          `).join("")}
        </select>
        <small>桌面端使用栅格列数，移动端自动降为单列。</small>
      </label>
      <label class="lc-form-row">
        <span>密度</span>
        <select name="density">
          <option value="comfortable" ${pageConfig.layout.density === "comfortable" ? "selected" : ""}>舒适</option>
          <option value="compact" ${pageConfig.layout.density === "compact" ? "selected" : ""}>紧凑</option>
        </select>
      </label>
    </form>
  `;
}

function renderLayoutNodeInspector(workbench: DemoWorkbench): string {
  const nodes = getFormLayoutNodes(workbench, workbench.previewMode);
  const selectedNode = nodes.find((node) => node.fieldCode === workbench.selectedFieldCode) ?? nodes[0];
  const section = selectedNode ? findAncestorLayoutNode(nodes, selectedNode.id, "section") : undefined;
  const rules = workbench.rules.filter((rule) => rule.fieldCode === selectedNode?.fieldCode);

  return `
    <section class="lc-side-note" data-role="layout-node-inspector">
      <span class="lc-section-label">布局节点</span>
      ${selectedNode
        ? `
          <strong>${escapeHtml(formatLayoutKind(selectedNode.kind))}</strong><br />
          <small>结构路径：${escapeHtml(formatLayoutPath(nodes, selectedNode.id))}</small>
          <div class="lc-tags">
            <span class="lc-tag">字段绑定：${escapeHtml(selectedNode.fieldCode ?? "无")}</span>
            <span class="lc-tag">所属分组：${escapeHtml(section?.label ?? "页面根节点")}</span>
          </div>
          <div class="lc-meta-line">
            ${rules.length > 0
              ? rules.map((rule) => `<small>${escapeHtml(formatRuleOperator(rule.operator ?? rule.condition?.operator ?? "custom"))}：${escapeHtml(rule.message)}</small>`).join("")
              : "<small>当前节点暂无保存校验规则</small>"}
          </div>
        `
        : "<small>当前没有可检查的布局节点</small>"}
    </section>
  `;
}

function findAncestorLayoutNode(
  nodes: FormLayoutNode[],
  nodeId: string,
  kind: FormLayoutNode["kind"]
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

function formatLayoutPath(nodes: FormLayoutNode[], nodeId: string): string {
  const byId = new Map(nodes.map((node) => [node.id, node]));
  const path: string[] = [];
  let current = byId.get(nodeId);
  while (current) {
    path.unshift(current.label);
    current = current.parentId ? byId.get(current.parentId) : undefined;
  }
  return path.join(" > ");
}

function formatLayoutKind(kind: FormLayoutNode["kind"]): string {
  const labels: Record<FormLayoutNode["kind"], string> = {
    form: "页面根节点",
    body: "主体区域",
    section: "分组",
    grid: "分栏",
    field: "字段绑定",
    "action-bar": "动作区",
    action: "按钮动作"
  };
  return labels[kind];
}

function formatDesignablePanel(panel: string): string {
  const labels: Record<string, string> = {
    "designer-canvas": "设计画布",
    "component-tree": "组件树",
    "property-settings": "属性设置",
    history: "历史记录",
    "schema-editor": "Schema 编辑器"
  };
  return labels[panel] ?? panel;
}

function formatResponsiveMode(mode: FormLayoutNode["responsive"]): string {
  if (mode === "auto-fit") {
    return "响应式自适应";
  }
  return "固定列";
}

function formatRuleOperator(operator: string): string {
  const labels: Record<string, string> = {
    required: "保存校验",
    equals: "相等校验",
    contains: "包含校验"
  };
  return labels[operator] ?? operator;
}

function formatRuleCondition(rule: DemoWorkbench["rules"][number]): string {
  const fieldName = findFieldLabelFromRule(rule);
  if (rule.operator === "required") {
    return `${fieldName} 必填`;
  }
  if (rule.condition) {
    return `${fieldName} ${formatRuleOperator(rule.condition.operator)} ${String(rule.condition.value ?? "")}`;
  }
  return `${fieldName} 变更`;
}

function formatRuleActions(rule: DemoWorkbench["rules"][number]): string {
  const actions = rule.actions ?? [];
  if (rule.operator === "required") {
    return `阻断保存并提示：${rule.message}`;
  }
  if (actions.length === 0) {
    return `提示：${rule.message}`;
  }
  return actions.map((action) => {
    if (action.type === "require") {
      return `要求填写 ${formatRuleTargetCode(action.targetCode)}`;
    }
    if (action.type === "show") {
      return `显示 ${formatRuleTargetCode(action.targetCode)}`;
    }
    if (action.type === "hide") {
      return `隐藏 ${formatRuleTargetCode(action.targetCode)}`;
    }
    if (action.type === "setValue") {
      return `设置 ${formatRuleTargetCode(action.targetCode)}`;
    }
    if (action.type === "submit" || action.type === "submitAction") {
      return `触发流程 ${formatActionCode(action.workflowActionCode ?? action.targetCode)}`;
    }
    return `执行 ${formatRuleTargetCode(action.targetCode)}`;
  }).join("；");
}

function findFieldLabelFromRule(rule: DemoWorkbench["rules"][number]): string {
  return formatRuleTargetCode(rule.condition?.fieldCode ?? rule.fieldCode ?? rule.code);
}

function formatRuleTargetCode(code: string): string {
  const labels: Record<string, string> = {
    customer_name: "客户名称",
    contract_amount: "合同金额",
    go_live_date: "上线日期",
    industry: "行业",
    is_active: "是否启用",
    owner_link: "负责人链接",
    summary_html: "摘要说明",
    submit: "提交审批",
    approve: "审批通过"
  };
  return labels[code] ?? code;
}

function formatFormTemplateName(name: string): string {
  if (name === "新增表单模板") {
    return "新建表单";
  }
  return name;
}

function formatTemplateReuseStrategy(templateCode: string, strategy: string, sourceTemplateCode?: string): string {
  if (templateCode === "detail-form") {
    return "复用详情表单布局";
  }
  if (sourceTemplateCode === "create-form") {
    return strategy === "inherit-and-override" ? "复用新建表单布局，可覆盖局部配置" : "复用新建表单布局";
  }
  return "作为模板源维护";
}

function renderPropertiesPanel(field: DraftFieldDefinition): string {
  return `
    <form class="lc-form" data-form="properties">
      <label class="lc-form-row">
        <span>字段标签</span>
        <input name="name" value="${escapeHtml(field.name)}" />
      </label>
      <label class="lc-form-row">
        <span>字段编码</span>
        <input value="${escapeHtml(field.code)}" disabled />
      </label>
      <label class="lc-form-row">
        <span>字段类型</span>
        <select name="fieldType">
          <option value="text" ${field.fieldType === "text" ? "selected" : ""}>文本</option>
          <option value="decimal" ${field.fieldType === "decimal" ? "selected" : ""}>小数</option>
          <option value="date" ${field.fieldType === "date" ? "selected" : ""}>日期</option>
          <option value="select" ${field.fieldType === "select" ? "selected" : ""}>单选</option>
          <option value="checkbox" ${field.fieldType === "checkbox" ? "selected" : ""}>勾选</option>
          <option value="link" ${field.fieldType === "link" ? "selected" : ""}>链接</option>
          <option value="richtext" ${field.fieldType === "richtext" ? "selected" : ""}>富文本</option>
        </select>
      </label>
      <label class="lc-form-row">
        <span>选项列表</span>
        <textarea name="optionsText" rows="3" placeholder="单选字段时一行一个选项">${escapeHtml((field.options ?? []).join("\n"))}</textarea>
      </label>
      <label class="lc-form-row">
        <span>占位提示</span>
        <input name="placeholder" value="${escapeHtml(field.placeholder ?? "")}" />
      </label>
      <label class="lc-form-row">
        <span>帮助文本</span>
        <input name="helperText" value="${escapeHtml(field.helperText ?? "")}" />
      </label>
      <label class="lc-form-row">
        <span>默认值</span>
        <input name="defaultValue" value="${escapeHtml(field.defaultValue ?? "")}" />
      </label>
      <div class="lc-check-grid">
        <label class="lc-checkbox"><input type="checkbox" name="required" ${field.required ? "checked" : ""} />必填</label>
        <label class="lc-checkbox"><input type="checkbox" name="inList" ${field.inList ? "checked" : ""} />列表显示</label>
        <label class="lc-checkbox"><input type="checkbox" name="hidden" ${field.hidden ? "checked" : ""} />隐藏字段</label>
      </div>
    </form>
  `;
}

function renderDropZone(dropIndex: number, dragState: DragState): string {
  return `
    <div
      class="lc-drop-zone"
      data-drop-index="${dropIndex}"
      data-drop-zone-index="${dropIndex}"
      data-drop-active="${dragState !== null}"
    ></div>
  `;
}

function renderPreviewValue(value: unknown): string {
  if (typeof value === "boolean") {
    return value ? "是" : "否";
  }
  return String(value ?? "");
}

function formatJson(value: unknown): string {
  return JSON.stringify(value, null, 2);
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}
