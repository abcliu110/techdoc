export const categoryNumber = "05";

function frame(ctx, title, ...children) {
  return ctx.el("div", { className: "demo col" }, ctx.el("h3", { text: title }), ...children);
}

function renderAdvancedQueryBuilder(ctx) {
  const list = ctx.el("div", { className: "col" }, ctx.el("div", { className: "item", text: "状态 = 已启用" }));
  const add = ctx.button("添加金额条件", "add-predicate");
  ctx.on(add, "click", () => { list.append(ctx.el("div", { className: "item active", text: "金额 > 10,000" })); ctx.setStatus("已构建 2 个 AND 条件", "predicates:2"); });
  ctx.stage.append(frame(ctx, "查询结构", list, add)); return {};
}

function renderConditionGroup(ctx) {
  const operator = ctx.el("strong", { text: "AND" }); const toggle = ctx.button("切换为 OR", "toggle-group");
  ctx.on(toggle, "click", () => { operator.textContent = "OR"; ctx.setStatus("条件组使用 OR", "operator:or"); });
  ctx.stage.append(frame(ctx, "条件组 A", ctx.el("div", { className: "item" }, "地区 = 华东 ", operator, " 金额 > 5000"), toggle)); return {};
}

function renderNestedLogicQuery(ctx) {
  const tree = ctx.el("div", { className: "item", text: "AND ├─ 状态=有效 └─ 地区=华东" }); const nest = ctx.button("嵌套 OR 分组", "nest-group");
  ctx.on(nest, "click", () => { tree.textContent = "AND ├─ 状态=有效 └─ OR ├─ 华东 └─ 华南"; ctx.setStatus("逻辑深度 2", "depth:2"); });
  ctx.stage.append(frame(ctx, "布尔表达式树", tree, nest)); return {};
}

function renderFilterPanel(ctx) {
  const result = ctx.el("div", { className: "status", text: "显示全部 128 条" }); const apply = ctx.button("应用筛选", "apply-filter");
  ctx.on(apply, "click", () => { result.textContent = "已应用：进行中 + 华东，共 23 条"; ctx.setStatus("筛选已应用", "applied:2"); });
  ctx.stage.append(frame(ctx, "综合筛选", ctx.el("div", { className: "row" }, ctx.el("select", { "aria-label": "状态" }, ctx.el("option", { text: "进行中" })), ctx.el("select", { "aria-label": "地区" }, ctx.el("option", { text: "华东" }))), result, apply)); return {};
}

function renderQuickFilterBar(ctx) {
  const count = ctx.el("div", { className: "status", text: "全部：96" }); const overdue = ctx.button("仅看逾期 8", "quick-overdue");
  ctx.on(overdue, "click", () => { count.textContent = "逾期：8"; overdue.classList.add("primary"); ctx.setStatus("快捷视图：逾期", "quick:overdue"); });
  ctx.stage.append(frame(ctx, "快捷视图", ctx.el("div", { className: "toolbar" }, overdue, ctx.button("我负责的 17", "quick-owned", { disabled: true })), count)); return {};
}

function renderFacetedFilter(ctx) {
  const result = ctx.el("div", { className: "status", text: "候选 64 条" }); const bucket = ctx.button("华东 (21)", "facet-east");
  ctx.on(bucket, "click", () => { bucket.classList.add("primary"); result.textContent = "华东 ∩ 已成交：12 条"; ctx.setStatus("分面桶已选择", "facets:east+won"); });
  ctx.stage.append(frame(ctx, "分面计数", ctx.el("div", { className: "row" }, bucket, ctx.el("span", { className: "pill", text: "已成交 (33)" })), result)); return {};
}

function renderSavedQuery(ctx) {
  const saved = ctx.el("div", { className: "col", text: "尚未保存" }); const save = ctx.button("保存当前查询", "save-query");
  ctx.on(save, "click", () => { saved.replaceChildren(ctx.el("div", { className: "item active", text: "本月高价值客户 · 3 条件" })); ctx.setStatus("查询快照已保存", "saved:1"); });
  ctx.stage.append(frame(ctx, "查询快照", ctx.el("input", { value: "本月高价值客户", "aria-label": "查询名称" }), saved, save)); return {};
}

function renderSavedView(ctx) {
  const columns = ctx.el("div", { className: "status", text: "列：客户 / 金额 / 状态" }); const restore = ctx.button("恢复销售视图", "restore-view");
  ctx.on(restore, "click", () => { columns.textContent = "列：阶段 / 负责人 / 预计成交；排序：金额↓"; ctx.setStatus("完整视图已恢复", "view:sales"); });
  ctx.stage.append(frame(ctx, "视图包含查询、排序和列", columns, restore)); return {};
}

function renderQueryTemplate(ctx) {
  const output = ctx.el("code", { className: "item", text: "createdAt >= :startDate" }); const resolve = ctx.button("代入本月参数", "resolve-template");
  ctx.on(resolve, "click", () => { output.textContent = "createdAt >= 2026-07-01"; ctx.setStatus("模板参数已解析", "resolved:2026-07"); });
  ctx.stage.append(frame(ctx, "参数化查询", ctx.el("input", { type: "date", value: "2026-07-01", "aria-label": "开始日期" }), output, resolve)); return {};
}

function renderDynamicQueryForm(ctx) {
  const fields = ctx.el("div", { className: "col" }, ctx.el("div", { className: "field", text: "字段：状态（枚举）" })); const load = ctx.button("加载金额字段元数据", "load-field");
  ctx.on(load, "click", () => { fields.append(ctx.el("div", { className: "field", text: "字段：金额（数值范围）" })); ctx.setStatus("Schema 生成 2 个查询字段", "fields:2"); });
  ctx.stage.append(frame(ctx, "元数据驱动查询", fields, load)); return {};
}

function renderQueryDsl(ctx) {
  const source = ctx.el("textarea", { rows: 4, "aria-label": "查询 DSL", value: "status = 'OPEN'" }); const diagnostic = ctx.el("div", { className: "status", text: "等待解析" }); const parse = ctx.button("解析 DSL", "parse-dsl");
  ctx.on(parse, "click", () => { const valid = /^\w+\s*(=|>|<)\s*.+/.test(source.value.trim()); diagnostic.textContent = valid ? "AST: Equal(status, OPEN)" : "语法错误：缺少操作符"; ctx.setStatus(valid ? "DSL 解析成功" : "DSL 解析失败", valid ? "dsl:valid" : "dsl:error"); });
  ctx.stage.append(frame(ctx, "查询 DSL", source, diagnostic, parse)); return {};
}

function renderFullTextSearch(ctx) {
  const excerpt = ctx.el("div", { className: "item", text: "季度经营分析与客户增长报告" }); const search = ctx.button("搜索“客户”", "search-text");
  ctx.on(search, "click", () => { excerpt.replaceChildren("季度经营分析与", ctx.el("mark", { text: "客户" }), "增长报告"); ctx.setStatus("命中 1 个片段", "hits:1"); });
  ctx.stage.append(frame(ctx, "全文索引", ctx.el("input", { value: "客户", "aria-label": "搜索词" }), excerpt, search)); return {};
}

function renderSemanticSearch(ctx) {
  const ranked = ctx.el("div", { className: "col", text: "等待理解意图" }); const run = ctx.button("按“续费风险”检索", "semantic-run");
  ctx.on(run, "click", () => { ranked.replaceChildren(ctx.el("div", { className: "item active", text: "客户流失预警 · 相似度 0.91" }), ctx.el("div", { className: "item", text: "合同到期清单 · 0.78" })); ctx.setStatus("语义结果已按相似度排序", "semantic:ranked"); });
  ctx.stage.append(frame(ctx, "语义检索", ranked, run)); return {};
}

function renderNaturalLanguageQuery(ctx) {
  const plan = ctx.el("div", { className: "status", text: "尚未解释" }); const interpret = ctx.button("解释问题", "interpret-query");
  ctx.on(interpret, "click", () => { plan.textContent = "计划：筛选 华东；聚合 销售额；排序 DESC；限制 10"; ctx.setStatus("置信度 93%，等待确认", "plan:review"); });
  ctx.stage.append(frame(ctx, "自然语言转查询", ctx.el("input", { value: "华东销售额前十", "aria-label": "自然语言问题" }), plan, interpret)); return {};
}

function renderDateRangeFilter(ctx) {
  const result = ctx.el("div", { className: "status", text: "未限定日期" }); const preset = ctx.button("选择最近 7 天", "date-preset");
  ctx.on(preset, "click", () => { result.textContent = "2026-07-08 00:00 — 2026-07-14 23:59（Asia/Shanghai）"; ctx.setStatus("日期范围有效", "date:last7"); });
  ctx.stage.append(frame(ctx, "日期区间", result, preset)); return {};
}

function renderNumericRangeFilter(ctx) {
  const min = ctx.el("input", { type: "number", value: 100, "aria-label": "最小值" }); const max = ctx.el("input", { type: "number", value: 500, "aria-label": "最大值" }); const apply = ctx.button("应用数值范围", "numeric-range");
  ctx.on(apply, "click", () => { const valid = Number(min.value) <= Number(max.value); ctx.setStatus(valid ? `[${min.value}, ${max.value}]` : "下界不能大于上界", valid ? "range:valid" : "range:error"); });
  ctx.stage.append(frame(ctx, "包含边界的数值区间", ctx.el("div", { className: "row" }, min, max), apply)); return {};
}

function renderTagFilter(ctx) {
  const selected = new Set(); const result = ctx.el("div", { className: "status", text: "未选择标签" }); const tag = ctx.button("重点客户", "toggle-tag");
  ctx.on(tag, "click", () => { selected.add("重点客户"); tag.classList.add("primary"); result.textContent = "全部匹配：重点客户"; ctx.setStatus("标签条件已启用", "tags:vip"); });
  ctx.stage.append(frame(ctx, "标签匹配", tag, result)); return {};
}

function renderCrossFieldQuery(ctx) {
  const result = ctx.el("div", { className: "status", text: "尚未比较字段" }); const compare = ctx.button("比较实收与应收", "compare-fields");
  ctx.on(compare, "click", () => { result.textContent = "实收 8,000 < 应收 10,000，命中欠款条件"; ctx.setStatus("跨字段条件命中", "compare:hit"); });
  ctx.stage.append(frame(ctx, "字段引用比较", ctx.el("code", { className: "item", text: "paidAmount < receivableAmount" }), result, compare)); return {};
}

function renderAggregateCondition(ctx) {
  const result = ctx.el("div", { className: "status", text: "未执行聚合" }); const execute = ctx.button("执行 HAVING", "aggregate-run");
  ctx.on(execute, "click", () => { result.textContent = "华东：SUM(金额)=128,000，满足 > 100,000"; ctx.setStatus("聚合条件命中 1 组", "groups:1"); });
  ctx.stage.append(frame(ctx, "先分组再筛选", ctx.el("div", { className: "item", text: "GROUP BY 地区 HAVING SUM(金额) > 100000" }), result, execute)); return {};
}

function renderQueryHistory(ctx) {
  const current = ctx.el("div", { className: "status", text: "当前：全部客户" }); const replay = ctx.button("重放昨日查询", "replay-query");
  ctx.on(replay, "click", () => { current.textContent = "已恢复：状态=跟进中，结果 31 条（昨日 16:42）"; ctx.setStatus("历史查询已重放", "history:replayed"); });
  ctx.stage.append(frame(ctx, "执行历史", ctx.el("div", { className: "item", text: "昨日 16:42 · 跟进中 · 31 条" }), current, replay)); return {};
}

export const renderers05 = Object.freeze({
  "05:advanced-query-builder": renderAdvancedQueryBuilder,
  "05:condition-group": renderConditionGroup,
  "05:nested-logic-query": renderNestedLogicQuery,
  "05:filter-panel": renderFilterPanel,
  "05:quick-filter-bar": renderQuickFilterBar,
  "05:faceted-filter": renderFacetedFilter,
  "05:saved-query": renderSavedQuery,
  "05:saved-view": renderSavedView,
  "05:query-template": renderQueryTemplate,
  "05:dynamic-query-form": renderDynamicQueryForm,
  "05:query-dsl": renderQueryDsl,
  "05:full-text-search": renderFullTextSearch,
  "05:semantic-search": renderSemanticSearch,
  "05:natural-language-query": renderNaturalLanguageQuery,
  "05:date-range-filter": renderDateRangeFilter,
  "05:numeric-range-filter": renderNumericRangeFilter,
  "05:tag-filter": renderTagFilter,
  "05:cross-field-query": renderCrossFieldQuery,
  "05:aggregate-condition": renderAggregateCondition,
  "05:query-history": renderQueryHistory,
});
export const renderers = renderers05;
