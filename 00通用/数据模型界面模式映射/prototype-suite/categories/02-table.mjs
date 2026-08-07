function mount(ctx, html) {
  ctx.stage.innerHTML = `<div class="prototype-demo">${html}<output data-state aria-live="polite"></output></div>`;
  const q = (selector) => ctx.stage.querySelector(selector);
  const qa = (selector) => [...ctx.stage.querySelectorAll(selector)];
  const state = (value) => { q("[data-state]").textContent = String(value); ctx.setStatus?.(value, value); };
  const on = (selector, type, listener) => ctx.on(q(selector), type, listener);
  return { q, qa, state, on };
}

const rows = `<table><thead><tr><th>客户</th><th>金额</th></tr></thead><tbody data-body><tr><td>海风科技</td><td>1200</td></tr><tr><td>远山零售</td><td>860</td></tr></tbody></table>`;

export function renderDataGrid(ctx) {
  const ui = mount(ctx, `${rows}<button data-add>新增记录</button>`);
  ui.on("[data-add]", "click", () => { const tr = document.createElement("tr"); ["青禾制造", "640"].forEach((text) => { const td = document.createElement("td"); td.textContent = text; tr.append(td); }); ui.q("[data-body]").append(tr); ui.state(`rows:${ui.qa("tbody tr").length}`); });
  ui.state("rows:2");
}

export function renderEditableGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td contenteditable="true" data-cell>1200</td></tr></tbody></table><button data-commit>提交单元格</button>`);
  ui.on("[data-commit]", "click", () => ui.state(`committed:${ui.q("[data-cell]").textContent.trim()}`));
  ui.state("editBuffer:dirty");
}

export function renderBatchEditGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td><input type="checkbox" aria-label="选择海风" checked></td><td data-value>100</td></tr><tr><td><input type="checkbox" aria-label="选择远山" checked></td><td data-value>200</td></tr></tbody></table><button data-patch>批量增加 10</button>`);
  ui.on("[data-patch]", "click", () => { ui.qa("[data-value]").forEach((cell) => { cell.textContent = String(Number(cell.textContent) + 10); }); ui.state("batch:patched"); }); ui.state("batch:clean");
}

export function renderTreeGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td><button data-expand aria-expanded="false">▶ 华东区</button></td><td>2060</td></tr><tr data-child hidden><td>　上海</td><td>1200</td></tr></tbody></table>`);
  let open = false; ui.on("[data-expand]", "click", () => { open = !open; ui.q("[data-expand]").setAttribute("aria-expanded", String(open)); ui.q("[data-child]").hidden = !open; ui.state(`expanded:${open}`); }); ui.state("expanded:false");
}

export function renderMasterDetailGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td><button data-order="SO-01">SO-01</button></td></tr><tr><td><button data-order="SO-02">SO-02</button></td></tr></tbody></table><aside data-detail>未选择订单</aside>`);
  ui.qa("[data-order]").forEach((button) => ctx.on(button, "click", () => { ui.q("[data-detail]").textContent = `${button.dataset.order}：2 个明细行`; ui.state(`master:${button.dataset.order}`); })); ui.state("master:none");
}

export function renderGroupedGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><th><button data-group aria-expanded="true">华东区（2）</button></th></tr><tr data-member><td>上海</td></tr><tr data-member><td>杭州</td></tr></tbody></table>`);
  let open = true; ui.on("[data-group]", "click", () => { open = !open; ui.qa("[data-member]").forEach((row) => { row.hidden = !open; }); ui.q("[data-group]").setAttribute("aria-expanded", String(open)); ui.state(`groupOpen:${open}`); }); ui.state("groupOpen:true");
}

export function renderPivotGrid(ctx) {
  const ui = mount(ctx, `<div data-axis>行：地区　列：季度　值：销售额</div><table><tbody><tr><td>华东</td><td data-pivot>1200</td></tr></tbody></table><button data-drill>下钻城市</button>`);
  ui.on("[data-drill]", "click", () => { ui.q("[data-axis]").textContent = "行：地区 / 城市　列：季度　值：销售额"; ui.q("[data-pivot]").textContent = "上海 720 / 杭州 480"; ui.state("pivotDepth:city"); }); ui.state("pivotDepth:region");
}

export function renderCrossTab(ctx) {
  const ui = mount(ctx, `<div data-cross>行轴：产品　列轴：月份</div><button data-swap>交换行列轴</button>`);
  let swapped = false; ui.on("[data-swap]", "click", () => { swapped = !swapped; ui.q("[data-cross]").textContent = swapped ? "行轴：月份　列轴：产品" : "行轴：产品　列轴：月份"; ui.state(`axes:${swapped ? "month-product" : "product-month"}`); }); ui.state("axes:product-month");
}

export function renderOlapGrid(ctx) {
  const ui = mount(ctx, `<nav data-path>全部地区</nav><button data-level>下钻华东</button><button data-up>上卷</button>`);
  let level = 0; const update = () => { ui.q("[data-path]").textContent = level ? "全部地区 / 华东 / 上海" : "全部地区"; ui.state(`olapLevel:${level}`); }; ui.on("[data-level]", "click", () => { level = 2; update(); }); ui.on("[data-up]", "click", () => { level = Math.max(0, level - 1); update(); }); update();
}

export function renderVirtualGrid(ctx) {
  const ui = mount(ctx, `<div data-window style="height:120px;overflow:auto;border:1px solid #aaa"><ol data-virtual></ol></div><button data-scroll>滚动到第 101 行</button>`);
  let start = 1; const draw = () => { const list = ui.q("[data-virtual]"); list.replaceChildren(...Array.from({ length: 8 }, (_, index) => { const li = document.createElement("li"); li.textContent = `记录 ${start + index}`; return li; })); ui.state(`windowStart:${start}`); }; ui.on("[data-scroll]", "click", () => { start = start === 1 ? 101 : 1; draw(); }); draw();
}

export function renderInfiniteGrid(ctx) {
  const ui = mount(ctx, `<ol data-infinite><li>记录 1</li><li>记录 2</li></ol><button data-load>加载下一批</button>`);
  let cursor = 2; ui.on("[data-load]", "click", () => { const list = ui.q("[data-infinite]"); for (let n = cursor + 1; n <= cursor + 2; n += 1) { const li = document.createElement("li"); li.textContent = `记录 ${n}`; list.append(li); } cursor += 2; ui.q("[data-load]").disabled = cursor >= 6; ui.state(cursor >= 6 ? "cursor:end" : `cursor:${cursor}`); }); ui.state("cursor:2");
}

export function renderServerGrid(ctx) {
  const ui = mount(ctx, `<div data-request>GET /orders?page=1&amp;size=20</div><button data-prev>上一页</button><button data-next>下一页</button>`);
  let page = 1; const update = () => { ui.q("[data-request]").textContent = `GET /orders?page=${page}&size=20`; ui.q("[data-prev]").disabled = page === 1; ui.state(`page:${page}/5`); }; ui.on("[data-prev]", "click", () => { page = Math.max(1, page - 1); update(); }); ui.on("[data-next]", "click", () => { page = Math.min(5, page + 1); update(); }); update();
}

export function renderFixedGrid(ctx) {
  const ui = mount(ctx, `<div data-scrollbox style="width:260px;overflow:auto"><table style="width:500px"><thead><tr><th style="position:sticky;top:0;left:0;background:white">固定列</th><th>Q1</th><th>Q2</th><th>Q3</th></tr></thead><tbody><tr><td style="position:sticky;left:0;background:white">客户 A</td><td>1</td><td>2</td><td>3</td></tr></tbody></table></div><button data-scroll-x>横向滚动</button>`);
  ui.on("[data-scroll-x]", "click", () => { ui.q("[data-scrollbox]").scrollLeft = 180; ui.state("scrollLeft:180;fixed:visible"); }); ui.state("scrollLeft:0;fixed:visible");
}

export function renderMultiHeaderGrid(ctx) {
  const ui = mount(ctx, `<table><thead><tr><th rowspan="2">客户</th><th colspan="2" data-head>2026 年</th></tr><tr data-sub><th>Q1</th><th>Q2</th></tr></thead></table><button data-head-toggle>折叠年度表头</button>`);
  let open = true; ui.on("[data-head-toggle]", "click", () => { open = !open; ui.q("[data-sub]").hidden = !open; ui.q("[data-head]").colSpan = open ? 2 : 1; ui.state(`headerExpanded:${open}`); }); ui.state("headerExpanded:true");
}

export function renderColumnGroupGrid(ctx) {
  const ui = mount(ctx, `<div><button data-group-toggle aria-expanded="true">财务列组</button></div><table><thead><tr><th data-finance>收入</th><th data-finance>成本</th><th>利润</th></tr></thead></table>`);
  let visible = true; ui.on("[data-group-toggle]", "click", () => { visible = !visible; ui.qa("[data-finance]").forEach((cell) => { cell.hidden = !visible; }); ui.q("[data-group-toggle]").setAttribute("aria-expanded", String(visible)); ui.state(`financeColumns:${visible ? 2 : 0}`); }); ui.state("financeColumns:2");
}

export function renderColumnManager(ctx) {
  const ui = mount(ctx, `<label><input type="checkbox" data-column checked> 显示手机号列</label><table><thead><tr><th>客户</th><th data-phone>手机号</th></tr></thead></table>`);
  ui.on("[data-column]", "change", () => { const checked = ui.q("[data-column]").checked; ui.q("[data-phone]").hidden = !checked; ui.state(`phoneVisible:${checked}`); }); ui.state("phoneVisible:true");
}

export function renderResizableGrid(ctx) {
  const ui = mount(ctx, `<table><thead><tr><th data-width style="width:120px">客户</th><th>金额</th></tr></thead></table><button data-widen>列宽 +40</button>`);
  let width = 120; ui.on("[data-widen]", "click", () => { width = width === 120 ? 160 : 120; ui.q("[data-width]").style.width = `${width}px`; ui.state(`columnWidth:${width}`); }); ui.state("columnWidth:120");
}

export function renderReorderableGrid(ctx) {
  const ui = mount(ctx, `<div data-columns><button data-column="customer">客户</button><button data-column="amount">金额</button><button data-column="status">状态</button></div><button data-reorder>把状态移到首列</button>`);
  let first = "customer"; ui.on("[data-reorder]", "click", () => { const box = ui.q("[data-columns]"); if (first === "customer") box.prepend(ui.q('[data-column="status"]')); else box.prepend(ui.q('[data-column="customer"]')); first = first === "customer" ? "status" : "customer"; ui.state(`firstColumn:${first}`); }); ui.state("firstColumn:customer");
}

export function renderRowSortGrid(ctx) {
  const ui = mount(ctx, `<ol data-rows><li data-row="A">高优先级</li><li data-row="B">中优先级</li><li data-row="C">低优先级</li></ol><button data-row-move>将低优先级移到顶部</button>`);
  let first = "A"; ui.on("[data-row-move]", "click", () => { const list = ui.q("[data-rows]"); list.prepend(first === "A" ? ui.q('[data-row="C"]') : ui.q('[data-row="A"]')); first = first === "A" ? "C" : "A"; ui.state(`firstRow:${first}`); }); ui.state("firstRow:A");
}

export function renderExpandableGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td><button data-expand-row aria-expanded="false">展开 SO-01</button></td></tr><tr data-expanded hidden><td>物流、付款和备注</td></tr></tbody></table>`);
  let open = false; ui.on("[data-expand-row]", "click", () => { open = !open; ui.q("[data-expanded]").hidden = !open; ui.q("[data-expand-row]").setAttribute("aria-expanded", String(open)); ui.state(`rowExpanded:${open}`); }); ui.state("rowExpanded:false");
}

export function renderInlineDetailGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td><button data-inline>查看订单</button></td><td>SO-01</td></tr><tr data-inline-detail hidden><td colspan="2"><label>备注 <input data-note value="加急"></label></td></tr></tbody></table>`);
  ui.on("[data-inline]", "click", () => { const detail = ui.q("[data-inline-detail]"); detail.hidden = !detail.hidden; ui.state(`inlineDetail:${detail.hidden ? "closed" : "editing"}`); }); ui.state("inlineDetail:closed");
}

export function renderSelectionGrid(ctx) {
  const ui = mount(ctx, `<table><thead><tr><th><input type="checkbox" data-all aria-label="全选行"></th><th>客户</th></tr></thead><tbody><tr><td><input type="checkbox" data-row-check aria-label="选择海风科技"></td><td>海风科技</td></tr><tr><td><input type="checkbox" data-row-check aria-label="选择远山零售"></td><td>远山零售</td></tr></tbody></table>`);
  ui.on("[data-all]", "change", () => { const checked = ui.q("[data-all]").checked; ui.qa("[data-row-check]").forEach((input) => { input.checked = checked; input.closest("tr").classList.toggle("selected", checked); }); ui.state(`selected:${checked ? 2 : 0}`); }); ui.state("selected:0");
}

export function renderCellSelectionGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td><button data-cell="A1">A1</button></td><td><button data-cell="B1">B1</button></td></tr><tr><td><button data-cell="A2">A2</button></td><td><button data-cell="B2">B2</button></td></tr></tbody></table>`);
  ui.qa("[data-cell]").forEach((cell) => ctx.on(cell, "click", () => { ui.qa("[data-cell]").forEach((item) => item.classList.toggle("selected", item === cell)); ui.state(`activeCell:${cell.dataset.cell}`); })); ui.state("activeCell:none");
}

export function renderClipboardGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td data-copy>海风科技</td><td data-paste>空</td></tr></tbody></table><button data-copy-action>复制 A1</button><button data-paste-action>粘贴到 B1</button>`);
  let buffer = ""; ui.on("[data-copy-action]", "click", () => { buffer = ui.q("[data-copy]").textContent; ui.state(`clipboard:${buffer}`); }); ui.on("[data-paste-action]", "click", () => { ui.q("[data-paste]").textContent = buffer || "空"; ui.state(`pasted:${Boolean(buffer)}`); }); ui.state("clipboard:empty");
}

export function renderFilterGrid(ctx) {
  const ui = mount(ctx, `<label>客户筛选 <input data-filter value="海风"></label><table><tbody><tr data-name="海风科技"><td>海风科技</td></tr><tr data-name="远山零售"><td>远山零售</td></tr></tbody></table><button data-apply>应用筛选</button>`);
  ui.on("[data-apply]", "click", () => { const term = ui.q("[data-filter]").value; let shown = 0; ui.qa("[data-name]").forEach((row) => { row.hidden = !row.dataset.name.includes(term); if (!row.hidden) shown += 1; }); ui.state(`filteredRows:${shown}`); }); ui.state("filteredRows:2");
}

export function renderSortGrid(ctx) {
  const ui = mount(ctx, `<div><button data-sort="amount">金额</button><button data-sort="date">日期</button></div><ol data-priority></ol>`);
  const priority = []; ui.qa("[data-sort]").forEach((button) => ctx.on(button, "click", () => { if (!priority.includes(button.dataset.sort)) priority.push(button.dataset.sort); ui.q("[data-priority]").textContent = priority.map((key, index) => `${index + 1}. ${key}`).join(" / "); ui.state(`sort:${priority.join(",")}`); })); ui.state("sort:none");
}

export function renderSummaryGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td>华东</td><td data-amount>120</td></tr><tr><td>华东</td><td data-amount>80</td></tr></tbody><tfoot><tr data-summary hidden><th>小计</th><th data-total></th></tr></tfoot></table><button data-sum>计算分组小计</button>`);
  ui.on("[data-sum]", "click", () => { const total = ui.qa("[data-amount]").reduce((sum, cell) => sum + Number(cell.textContent), 0); ui.q("[data-total]").textContent = String(total); ui.q("[data-summary]").hidden = false; ui.state(`subtotal:${total}`); }); ui.state("subtotal:none");
}

export function renderFrozenGrid(ctx) {
  const ui = mount(ctx, `<div data-frozen>冻结边界：客户列之后</div><button data-freeze>冻结到金额列</button>`);
  let boundary = "customer"; ui.on("[data-freeze]", "click", () => { boundary = boundary === "customer" ? "amount" : "customer"; ui.q("[data-frozen]").textContent = `冻结边界：${boundary === "customer" ? "客户列" : "金额列"}之后`; ui.state(`frozen:${boundary}`); }); ui.state("frozen:customer");
}

export function renderSpreadsheetGrid(ctx) {
  const ui = mount(ctx, `<label>A1 <input data-a value="8"></label><label>B1 <input data-b value="4"></label><label>C1 公式 <input data-formula value="=A1+B1"></label><output data-result></output><button data-calc>计算公式</button>`);
  ui.on("[data-calc]", "click", () => { const result = Number(ui.q("[data-a]").value) + Number(ui.q("[data-b]").value); ui.q("[data-result]").textContent = String(result); ui.state(`formulaResult:${result}`); }); ui.state("formulaResult:none");
}

export function renderPropertyGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><th><label for="property-title">标题</label></th><td><input id="property-title" data-property value="客户卡片"></td></tr><tr><th><label for="property-visible">可见</label></th><td><input id="property-visible" type="checkbox" data-visible checked></td></tr></tbody></table><button data-property-save>应用属性</button>`);
  ui.on("[data-property-save]", "click", () => ui.state(`property:${ui.q("[data-property]").value};visible:${ui.q("[data-visible]").checked}`)); ui.state("property:unchanged");
}

export function renderKeyValueGrid(ctx) {
  const ui = mount(ctx, `<dl data-pairs><div><dt>timeout</dt><dd>30</dd></div></dl><label>键 <input data-key value="retry"></label><label>值 <input data-value value="3"></label><button data-pair-add>添加键值</button>`);
  ui.on("[data-pair-add]", "click", () => { const div = document.createElement("div"), dt = document.createElement("dt"), dd = document.createElement("dd"); dt.textContent = ui.q("[data-key]").value; dd.textContent = ui.q("[data-value]").value; div.append(dt, dd); ui.q("[data-pairs]").append(div); ui.state(`pairs:${ui.qa("[data-pairs] > div").length}`); }); ui.state("pairs:1");
}

export function renderComparisonGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><th>本期</th><td data-current>120</td></tr><tr><th>上期</th><td data-previous>100</td></tr></tbody></table><button data-compare>标记变化</button>`);
  ui.on("[data-compare]", "click", () => { const delta = Number(ui.q("[data-current]").textContent) - Number(ui.q("[data-previous]").textContent); ui.q("[data-current]").style.background = delta > 0 ? "#dff5df" : "#fdd"; ui.state(`delta:+${delta}`); }); ui.state("delta:none");
}

export function renderMatrixGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><th></th><th>读</th><th>写</th></tr><tr><th>管理员</th><td><button data-matrix="read">✓</button></td><td><button data-matrix="write">—</button></td></tr></tbody></table>`);
  ui.qa("[data-matrix]").forEach((cell) => ctx.on(cell, "click", () => { cell.textContent = cell.textContent === "✓" ? "—" : "✓"; ui.state(`${cell.dataset.matrix}:${cell.textContent === "✓"}`); })); ui.state("matrix:initial");
}

export function renderDiffGrid(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><th>旧值</th><td>待审核</td><th>新值</th><td data-new>已通过</td></tr></tbody></table><button data-apply-diff>应用新值</button>`);
  ui.on("[data-apply-diff]", "click", () => { ui.q("[data-new]").style.background = "#dff5df"; ui.state("diff:applied"); }); ui.state("diff:pending");
}

export const tableRenderers = {
  "02:data-grid":renderDataGrid,"02:editable-grid":renderEditableGrid,"02:batch-edit-grid":renderBatchEditGrid,"02:tree-grid":renderTreeGrid,"02:master-detail-grid":renderMasterDetailGrid,"02:grouped-grid":renderGroupedGrid,"02:pivot-grid":renderPivotGrid,"02:cross-tab":renderCrossTab,"02:olap-grid":renderOlapGrid,"02:virtual-grid":renderVirtualGrid,"02:infinite-grid":renderInfiniteGrid,"02:server-grid":renderServerGrid,"02:fixed-grid":renderFixedGrid,"02:multi-header-grid":renderMultiHeaderGrid,"02:column-group-grid":renderColumnGroupGrid,"02:column-manager":renderColumnManager,"02:resizable-grid":renderResizableGrid,"02:reorderable-grid":renderReorderableGrid,"02:row-sort-grid":renderRowSortGrid,"02:expandable-grid":renderExpandableGrid,"02:inline-detail-grid":renderInlineDetailGrid,"02:selection-grid":renderSelectionGrid,"02:cell-selection-grid":renderCellSelectionGrid,"02:clipboard-grid":renderClipboardGrid,"02:filter-grid":renderFilterGrid,"02:sort-grid":renderSortGrid,"02:summary-grid":renderSummaryGrid,"02:frozen-grid":renderFrozenGrid,"02:spreadsheet-grid":renderSpreadsheetGrid,"02:property-grid":renderPropertyGrid,"02:key-value-grid":renderKeyValueGrid,"02:comparison-grid":renderComparisonGrid,"02:matrix-grid":renderMatrixGrid,"02:diff-grid":renderDiffGrid,
};
export const renderers02 = tableRenderers;
export default tableRenderers;
