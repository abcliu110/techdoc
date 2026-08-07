export const categoryNumber = "07";
function desk(ctx, title, ...children) { return ctx.el("div", { className: "demo col" }, ctx.el("h3", { text: title }), ...children); }
function output(ctx, text = "等待操作") { return ctx.el("div", { className: "status", text }); }

function renderRichTextEditor(ctx) {
  const text = ctx.el("div", { className: "item", contentEditable: "true", role: "textbox", "aria-label": "富文本正文", text: "选择这段文字并应用强调。" }); const bold = ctx.button("应用粗体", "rich-bold");
  ctx.on(bold, "click", () => { text.style.fontWeight = "700"; ctx.setStatus("当前段落已应用 strong 标记", "mark:bold"); }); ctx.stage.append(desk(ctx, "语义富文本", ctx.el("div", { className: "toolbar" }, bold), text)); return {};
}
function renderMarkdownEditor(ctx) {
  const source = ctx.el("textarea", { rows: 5, "aria-label": "Markdown 源码", value: "## 交付说明\n- 已验证" }); const preview = output(ctx, "预览未生成"); const run = ctx.button("生成预览", "markdown-preview");
  ctx.on(run, "click", () => { preview.replaceChildren(ctx.el("h2", { text: "交付说明" }), ctx.el("li", { text: "已验证" })); ctx.setStatus("Markdown 预览已同步", "preview:markdown"); }); ctx.stage.append(desk(ctx, "Markdown 源码与预览", source, preview, run)); return {};
}
function renderCodeEditor(ctx) {
  const source = ctx.el("textarea", { rows: 5, spellcheck: false, "aria-label": "JavaScript 代码", value: "return 6 * 7;" }); const consoleNode = output(ctx, "控制台空闲"); const run = ctx.button("运行代码", "code-run");
  ctx.on(run, "click", () => { const value = source.value.includes("6 * 7") ? 42 : "SyntaxError"; consoleNode.textContent = `输出：${value}`; ctx.setStatus(value === 42 ? "运行成功" : "运行失败", value === 42 ? "run:42" : "run:error"); }); ctx.stage.append(desk(ctx, "代码与诊断", source, consoleNode, run)); return {};
}
function renderJsonEditor(ctx) {
  const source = ctx.el("textarea", { rows: 5, "aria-label": "JSON 文本", value: "{\"enabled\":true}" }); const tree = output(ctx, "等待校验"); const validate = ctx.button("校验并生成树", "json-validate");
  ctx.on(validate, "click", () => { try { const value = JSON.parse(source.value); tree.textContent = `root > enabled : ${value.enabled}`; ctx.setStatus("JSON 有效", "json:valid"); } catch { tree.textContent = "JSON 语法错误"; ctx.setStatus("JSON 无效", "json:error"); } }); ctx.stage.append(desk(ctx, "JSON 文本 ↔ 树", source, tree, validate)); return {};
}
function renderYamlEditor(ctx) {
  const source = ctx.el("textarea", { rows: 5, "aria-label": "YAML 文本", value: "service:\n  enabled: true" }); const diagnostic = output(ctx, "等待缩进检查"); const validate = ctx.button("检查 YAML", "yaml-validate");
  ctx.on(validate, "click", () => { const valid = source.value.split("\n").slice(1).every((line) => /^  \w+/.test(line)); diagnostic.textContent = valid ? "service.enabled = true" : "第 2 行缩进错误"; ctx.setStatus(valid ? "YAML 有效" : "YAML 无效", valid ? "yaml:valid" : "yaml:error"); }); ctx.stage.append(desk(ctx, "缩进结构", source, diagnostic, validate)); return {};
}
function renderXmlEditor(ctx) {
  const source = ctx.el("textarea", { rows: 5, "aria-label": "XML 文本", value: "<order><id>1008</id></order>" }); const tree = output(ctx, "等待解析"); const parse = ctx.button("解析元素树", "xml-parse");
  ctx.on(parse, "click", () => { const parsed = new DOMParser().parseFromString(source.value, "application/xml"); const error = parsed.querySelector("parsererror"); tree.textContent = error ? "XML 标签不匹配" : "order / id = 1008"; ctx.setStatus(error ? "XML 无效" : "XML 有效", error ? "xml:error" : "xml:valid"); }); ctx.stage.append(desk(ctx, "XML 元素树", source, tree, parse)); return {};
}
function renderFormulaEditor(ctx) {
  const formula = ctx.el("input", { value: "price * quantity", "aria-label": "公式" }); const out = output(ctx, "price=120, quantity=3"); const evaluate = ctx.button("计算公式", "formula-evaluate");
  ctx.on(evaluate, "click", () => { out.textContent = "结果：360（Number）"; ctx.setStatus("公式求值成功", "formula:360"); }); ctx.stage.append(desk(ctx, "字段公式", formula, out, evaluate)); return {};
}
function renderExpressionEditor(ctx) {
  const expression = ctx.el("input", { value: "customer.level === 'VIP'", "aria-label": "表达式" }); const out = output(ctx, "scope.customer.level = VIP"); const test = ctx.button("测试表达式", "expression-test");
  ctx.on(test, "click", () => { out.textContent = "Boolean(true)"; ctx.setStatus("表达式命中", "expression:true"); }); ctx.stage.append(desk(ctx, "受限表达式", expression, out, test)); return {};
}
function renderSqlEditor(ctx) {
  const sql = ctx.el("textarea", { rows: 4, "aria-label": "SQL", value: "SELECT id, name FROM customer WHERE status = :status" }); const out = output(ctx, "参数 status=ACTIVE"); const run = ctx.button("执行参数化查询", "sql-run");
  ctx.on(run, "click", () => { out.textContent = "2 行：C-1008 / 星河科技；C-1021 / 青山商贸"; ctx.setStatus("SQL 执行完成", "rows:2"); }); ctx.stage.append(desk(ctx, "SQL 与结果集", sql, out, run)); return {};
}
function renderVisualQueryEditor(ctx) {
  const graph = ctx.el("div", { className: "canvas", text: "customer" }); const join = ctx.button("关联 order.customer_id", "visual-join");
  ctx.on(join, "click", () => { graph.textContent = "customer ── customer.id = order.customer_id ── order"; ctx.setStatus("查询图新增 1 条 JOIN", "joins:1"); }); ctx.stage.append(desk(ctx, "查询图", graph, join)); return {};
}
function renderTemplateEditor(ctx) {
  const source = ctx.el("textarea", { rows: 4, "aria-label": "模板", value: "您好，{{customerName}}" }); const out = output(ctx); const preview = ctx.button("使用示例数据预览", "template-preview");
  ctx.on(preview, "click", () => { out.textContent = source.value.replace("{{customerName}}", "星河科技"); ctx.setStatus("模板变量已插值", "template:resolved"); }); ctx.stage.append(desk(ctx, "变量模板", source, out, preview)); return {};
}
function renderEmailTemplateEditor(ctx) {
  const subject = ctx.el("input", { value: "{{name}}，合同即将到期", "aria-label": "邮件主题" }); const out = output(ctx, "等待邮件预览"); const preview = ctx.button("生成移动端邮件预览", "email-preview");
  ctx.on(preview, "click", () => { out.textContent = "主题：李明，合同即将到期 · 视口 390px"; ctx.setStatus("邮件主题和正文已预览", "email:mobile"); }); ctx.stage.append(desk(ctx, "邮件模板", subject, ctx.el("textarea", { rows: 3, "aria-label": "邮件正文", value: "请于 7 月 31 日前确认续签。" }), out, preview)); return {};
}
function renderDocumentEditor(ctx) {
  const outline = ctx.el("div", { className: "item", text: "1. 背景\n2. 方案\n3. 验证" }); const activate = ctx.button("跳转到“验证”章节", "document-section");
  ctx.on(activate, "click", () => { outline.textContent = "当前章节：3. 验证（引用 2，附件 1）"; ctx.setStatus("文档大纲已联动", "section:verification"); }); ctx.stage.append(desk(ctx, "结构化文档", outline, activate)); return {};
}
function renderSpreadsheetEditor(ctx) {
  const cell = ctx.el("input", { value: "=B2*C2", "aria-label": "D2 公式" }); const out = output(ctx, "B2=120，C2=3"); const recalc = ctx.button("重算 D2", "sheet-recalc");
  ctx.on(recalc, "click", () => { out.textContent = "D2 = 360"; ctx.setStatus("工作表公式已重算", "cell:D2=360"); }); ctx.stage.append(desk(ctx, "电子表格单元格", ctx.el("div", { className: "matrix" }, cell), out, recalc)); return {};
}
function renderDiffEditor(ctx) {
  const hunk = ctx.el("div", { className: "item", text: "- 超时 30 秒\n+ 超时 60 秒" }); const accept = ctx.button("接受此差异块", "diff-accept");
  ctx.on(accept, "click", () => { hunk.textContent = "超时 60 秒（已接受）"; ctx.setStatus("差异块已接受", "hunk:accepted"); }); ctx.stage.append(desk(ctx, "基线与变更", hunk, accept)); return {};
}
function renderVersionEditor(ctx) {
  const versions = output(ctx, "比较 v5 → v7"); const restore = ctx.button("恢复 v5", "version-restore");
  ctx.on(restore, "click", () => { versions.textContent = "新版本 v8 已从 v5 创建，历史 v7 保留"; ctx.setStatus("旧版本已恢复为新修订", "restored:v5-as-v8"); }); ctx.stage.append(desk(ctx, "版本比较与恢复", versions, restore)); return {};
}
function renderCollaborativeEditor(ctx) {
  const doc = ctx.el("div", { className: "item", text: "共享文档 · 李明正在第 2 段" }); const merge = ctx.button("应用王芳的远程操作", "collab-merge");
  ctx.on(merge, "click", () => { doc.textContent = "共享文档 · 已合并 op#42 · 待确认操作 0"; ctx.setStatus("远程操作已合并", "ops:0"); }); ctx.stage.append(desk(ctx, "多人协同", doc, merge)); return {};
}
function renderDiagramEditor(ctx) {
  const canvas = ctx.el("div", { className: "canvas" }, ctx.el("div", { className: "node", style: { left: "40px", top: "60px" }, text: "开始" })); const add = ctx.button("添加审批节点", "diagram-add");
  ctx.on(add, "click", () => { canvas.append(ctx.el("div", { className: "node selected", style: { left: "240px", top: "150px" }, text: "审批" })); ctx.setStatus("图形新增节点并选中", "nodes:2"); }); ctx.stage.append(desk(ctx, "节点与连线", canvas, add)); return {};
}
function renderImageAnnotationEditor(ctx) {
  const image = ctx.el("div", { className: "canvas", text: "图像 800×600" }); const annotate = ctx.button("在 (120,90) 标注缺陷", "image-annotate");
  ctx.on(annotate, "click", () => { image.append(ctx.el("div", { className: "node selected", style: { left: "120px", top: "90px" }, text: "缺陷 #1" })); ctx.setStatus("标注坐标已保存", "annotation:120,90"); }); ctx.stage.append(desk(ctx, "图像坐标标注", image, annotate)); return {};
}
function renderSchemaEditor(ctx) {
  const tree = ctx.el("div", { className: "item", text: "customer\n└─ name: string" }); const add = ctx.button("添加必填约束", "schema-constraint");
  ctx.on(add, "click", () => { tree.textContent = "customer\n└─ name: string [required]"; ctx.setStatus("Schema 约束有效", "schema:required-name"); }); ctx.stage.append(desk(ctx, "Schema 字段树", tree, add)); return {};
}

export const renderers07 = Object.freeze({
  "07:rich-text-editor": renderRichTextEditor, "07:markdown-editor": renderMarkdownEditor, "07:code-editor": renderCodeEditor,
  "07:json-editor": renderJsonEditor, "07:yaml-editor": renderYamlEditor, "07:xml-editor": renderXmlEditor,
  "07:formula-editor": renderFormulaEditor, "07:expression-editor": renderExpressionEditor, "07:sql-editor": renderSqlEditor,
  "07:visual-query-editor": renderVisualQueryEditor, "07:template-editor": renderTemplateEditor, "07:email-template-editor": renderEmailTemplateEditor,
  "07:document-editor": renderDocumentEditor, "07:spreadsheet-editor": renderSpreadsheetEditor, "07:diff-editor": renderDiffEditor,
  "07:version-editor": renderVersionEditor, "07:collaborative-editor": renderCollaborativeEditor, "07:diagram-editor": renderDiagramEditor,
  "07:image-annotation-editor": renderImageAnnotationEditor, "07:schema-editor": renderSchemaEditor,
});
export const renderers = renderers07;
