function mount(ctx, html) {
  ctx.stage.innerHTML = `<div class="prototype-demo">${html}<output class="prototype-state" data-state aria-live="polite"></output></div>`;
  const q = (selector) => ctx.stage.querySelector(selector);
  const qa = (selector) => [...ctx.stage.querySelectorAll(selector)];
  const state = (value) => { q("[data-state]").textContent = String(value); ctx.setStatus?.(value, value); };
  const on = (selector, type, listener) => ctx.on(q(selector), type, listener);
  return { q, qa, state, on };
}

export function renderGridLayout(ctx) {
  const ui = mount(ctx, `<div data-grid style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px"><b>1</b><b>2</b><b>3</b><b style="grid-column:span 2">4—5</b></div><button data-columns>切换 4 列</button>`);
  let columns = 3;
  ui.on("[data-columns]", "click", () => { columns = columns === 3 ? 4 : 3; ui.q("[data-grid]").style.gridTemplateColumns = `repeat(${columns},1fr)`; ui.state(`columns:${columns}`); });
  ui.state("columns:3");
}

export function renderRowColumn(ctx) {
  const ui = mount(ctx, `<div data-axis style="display:flex;gap:8px"><span>A</span><span>B</span><span>C</span></div><button data-direction>切换纵向</button>`);
  let vertical = false;
  ui.on("[data-direction]", "click", () => { vertical = !vertical; ui.q("[data-axis]").style.flexDirection = vertical ? "column" : "row"; ui.q("[data-direction]").textContent = vertical ? "切换横向" : "切换纵向"; ui.state(`direction:${vertical ? "column" : "row"}`); });
  ui.state("direction:row");
}

export function renderFlexLayout(ctx) {
  const ui = mount(ctx, `<div data-flex style="display:flex;gap:8px"><span>固定</span><span data-grow style="background:#eef;padding:8px">弹性项</span><span>固定</span></div><button data-grow-toggle>分配剩余空间</button>`);
  let grow = 0;
  ui.on("[data-grow-toggle]", "click", () => { grow = grow ? 0 : 1; ui.q("[data-grow]").style.flexGrow = String(grow); ui.state(`grow:${grow}`); });
  ui.state("grow:0");
}

export function renderMultiColumn(ctx) {
  const ui = mount(ctx, `<p data-flow style="column-count:2;column-gap:24px">第一段内容。第二段内容。第三段内容。第四段内容。第五段内容。第六段内容。</p><button data-column-count>使用 3 栏</button>`);
  let count = 2;
  ui.on("[data-column-count]", "click", () => { count = count === 2 ? 3 : 2; ui.q("[data-flow]").style.columnCount = String(count); ui.state(`columnCount:${count}`); });
  ui.state("columnCount:2");
}

export function renderSplitPane(ctx) {
  const ui = mount(ctx, `<div style="display:flex;height:130px"><div data-left style="width:50%;background:#eef">列表</div><button data-divider aria-label="向右调整分隔条">↔</button><div style="flex:1;background:#efe">详情</div></div>`);
  let ratio = 50;
  ui.on("[data-divider]", "click", () => { ratio = ratio === 50 ? 65 : 50; ui.q("[data-left]").style.width = `${ratio}%`; ui.state(`ratio:${ratio}`); });
  ui.state("ratio:50");
}

export function renderResizablePanel(ctx) {
  const ui = mount(ctx, `<div data-panel style="width:240px;height:100px;background:#eef">可调整面板</div><button data-resize>扩大面板</button>`);
  let width = 240;
  ui.on("[data-resize]", "click", () => { width = width === 240 ? 340 : 240; ui.q("[data-panel]").style.width = `${width}px`; ui.state(`width:${width}`); });
  ui.state("width:240");
}

export function renderDockLayout(ctx) {
  const ui = mount(ctx, `<div style="display:grid;grid-template-columns:1fr 1fr;gap:8px"><div data-tool style="padding:16px;background:#eef">工具箱</div><div data-dock style="padding:16px;border:2px dashed #999">右侧停靠区</div></div><button data-dock-action>停靠工具箱</button>`);
  let dock = "left";
  ui.on("[data-dock-action]", "click", () => { dock = dock === "left" ? "right" : "left"; const tool = ui.q("[data-tool]"); const zone = ui.q("[data-dock]"); dock === "right" ? zone.append(tool) : zone.parentElement.prepend(tool); ui.state(`dock:${dock}`); });
  ui.state("dock:left");
}

export function renderTabsLayout(ctx) {
  const ui = mount(ctx, `<div role="tablist"><button role="tab" data-tab="overview" aria-selected="true">概览</button><button role="tab" data-tab="history" aria-selected="false">历史</button></div><div data-panel>概览内容</div>`);
  ui.qa("[data-tab]").forEach((tab) => ctx.on(tab, "click", () => { ui.qa("[data-tab]").forEach((item) => item.setAttribute("aria-selected", String(item === tab))); ui.q("[data-panel]").textContent = tab.dataset.tab === "overview" ? "概览内容" : "历史记录内容"; ui.state(`active:${tab.dataset.tab}`); }));
  ui.state("active:overview");
}

export function renderAccordion(ctx) {
  const ui = mount(ctx, `<button data-section aria-expanded="false">高级设置</button><div data-content hidden>缓存、超时、重试</div>`);
  let open = false;
  ui.on("[data-section]", "click", () => { open = !open; ui.q("[data-section]").setAttribute("aria-expanded", String(open)); ui.q("[data-content]").hidden = !open; ui.state(`expanded:${open}`); });
  ui.state("expanded:false");
}

export function renderCardLayout(ctx) {
  const ui = mount(ctx, `<div data-cards style="display:grid;grid-template-columns:repeat(2,1fr);gap:16px"><article style="padding:18px;background:#eef">销售额</article><article style="padding:18px;background:#efe">订单数</article></div><button data-density>切换紧凑密度</button>`);
  let compact = false;
  ui.on("[data-density]", "click", () => { compact = !compact; ui.qa("article").forEach((card) => { card.style.padding = compact ? "6px" : "18px"; }); ui.state(`density:${compact ? "compact" : "comfortable"}`); });
  ui.state("density:comfortable");
}

export function renderMasonry(ctx) {
  const ui = mount(ctx, `<div data-masonry style="columns:2;column-gap:10px"><div style="height:45px;background:#eef">A</div><div style="height:85px;background:#efe">B</div><div style="height:65px;background:#fee">C</div></div><button data-balance>重新平衡瀑布流</button>`);
  let columns = 2;
  ui.on("[data-balance]", "click", () => { columns = columns === 2 ? 3 : 2; ui.q("[data-masonry]").style.columns = String(columns); ui.state(`masonryColumns:${columns}`); });
  ui.state("masonryColumns:2");
}

export function renderDashboard(ctx) {
  const ui = mount(ctx, `<div data-dashboard style="display:grid;grid-template-columns:1fr 1fr;gap:8px"><article data-widget="sales">销售</article><article data-widget="stock">库存</article></div><button data-widget-add>添加预警组件</button>`);
  let added = false;
  ui.on("[data-widget-add]", "click", () => { added = !added; const old = ui.q('[data-widget="alert"]'); if (old) old.remove(); else { const article = document.createElement("article"); article.dataset.widget = "alert"; article.textContent = "库存预警"; ui.q("[data-dashboard]").append(article); } ui.state(`widgets:${added ? 3 : 2}`); });
  ui.state("widgets:2");
}

export function renderDragGrid(ctx) {
  const ui = mount(ctx, `<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px"><button data-cell="1">订单</button><button data-cell="2">客户</button><button data-cell="3">库存</button></div><button data-move>将订单移动到第 3 格</button>`);
  let position = 1;
  ui.on("[data-move]", "click", () => { position = position === 1 ? 3 : 1; const order = ui.q('[data-cell="1"]'); const cells = ui.qa("[data-cell]"); position === 3 ? cells[2].after(order) : cells[0].before(order); ui.state(`orderPosition:${position}`); });
  ui.state("orderPosition:1");
}

export function renderFreeCanvas(ctx) {
  const ui = mount(ctx, `<div data-canvas style="height:150px;position:relative;border:1px solid #aaa"><button data-node style="position:absolute;left:20px;top:20px">节点 A</button></div><button data-move-node>移动节点</button>`);
  let moved = false;
  ui.on("[data-move-node]", "click", () => { moved = !moved; Object.assign(ui.q("[data-node]").style, { left: moved ? "150px" : "20px", top: moved ? "80px" : "20px" }); ui.state(`node:${moved ? "150,80" : "20,20"}`); });
  ui.state("node:20,20");
}

export function renderResponsiveLayout(ctx) {
  const ui = mount(ctx, `<div data-viewport style="width:720px;max-width:100%;border:1px solid #aaa"><nav data-responsive-nav>桌面导航</nav><main>响应式内容</main></div><button data-device>预览手机宽度</button>`);
  let mobile = false;
  ui.on("[data-device]", "click", () => { mobile = !mobile; ui.q("[data-viewport]").style.width = mobile ? "360px" : "720px"; ui.q("[data-responsive-nav]").textContent = mobile ? "☰" : "桌面导航"; ui.state(`viewport:${mobile ? 360 : 720}`); });
  ui.state("viewport:720");
}

export function renderAdaptiveBreakpoint(ctx) {
  const ui = mount(ctx, `<div data-breakpoint style="display:grid;grid-template-columns:2fr 1fr"><main>主内容</main><aside data-adaptive>辅助信息</aside></div><button data-breakpoint-toggle>进入窄屏断点</button>`);
  let breakpoint = "lg";
  ui.on("[data-breakpoint-toggle]", "click", () => { breakpoint = breakpoint === "lg" ? "sm" : "lg"; ui.q("[data-breakpoint]").style.gridTemplateColumns = breakpoint === "sm" ? "1fr" : "2fr 1fr"; ui.q("[data-adaptive]").hidden = breakpoint === "sm"; ui.state(`breakpoint:${breakpoint}`); });
  ui.state("breakpoint:lg");
}

export function renderNestedContainer(ctx) {
  const ui = mount(ctx, `<div style="padding:12px;border:2px solid #888">页面<div data-nested style="margin:10px;padding:10px;border:2px solid #58a">区域<div style="margin:8px;padding:8px;background:#eef">卡片</div></div></div><button data-nest>增加一层容器</button>`);
  let depth = 2;
  ui.on("[data-nest]", "click", () => { depth = depth === 2 ? 3 : 2; ui.q("[data-nested]").style.outline = depth === 3 ? "4px double #d89b00" : "none"; ui.state(`depth:${depth}`); });
  ui.state("depth:2");
}

export function renderConfigurablePage(ctx) {
  const ui = mount(ctx, `<div data-slots style="display:grid;grid-template-areas:'header header' 'main aside';grid-template-columns:2fr 1fr"><header style="grid-area:header">页头槽位</header><main style="grid-area:main">内容槽位</main><aside data-slot style="grid-area:aside">侧栏槽位</aside></div><button data-slot-toggle>隐藏侧栏槽位</button>`);
  let aside = true;
  ui.on("[data-slot-toggle]", "click", () => { aside = !aside; ui.q("[data-slot]").hidden = !aside; ui.q("[data-slots]").style.gridTemplateColumns = aside ? "2fr 1fr" : "1fr"; ui.state(`aside:${aside}`); });
  ui.state("aside:true");
}

export function renderMultiColumnEditor(ctx) {
  const ui = mount(ctx, `<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px"><textarea aria-label="源码">const a = 1;</textarea><pre data-preview>预览</pre><aside data-outline>大纲</aside></div><button data-pane>切换大纲</button>`);
  let outline = true;
  ui.on("[data-pane]", "click", () => { outline = !outline; ui.q("[data-outline]").hidden = !outline; ui.state(`outline:${outline}`); });
  ui.state("outline:true");
}

export function renderImmersive(ctx) {
  const ui = mount(ctx, `<div data-immersive style="padding:20px;border:1px solid #aaa"><header data-chrome>工具栏</header><main>专注编辑区</main></div><button data-focus-mode>进入沉浸模式</button>`);
  let immersive = false;
  ui.on("[data-focus-mode]", "click", () => { immersive = !immersive; ui.q("[data-chrome]").hidden = immersive; ui.q("[data-immersive]").style.minHeight = immersive ? "220px" : "auto"; ui.state(`immersive:${immersive}`); });
  ui.state("immersive:false");
}

export function renderMasterDetail(ctx) {
  const ui = mount(ctx, `<div style="display:grid;grid-template-columns:1fr 2fr;gap:8px"><nav><button data-record="A">客户 A</button><button data-record="B">客户 B</button></nav><article data-detail>请选择客户</article></div>`);
  ui.qa("[data-record]").forEach((record) => ctx.on(record, "click", () => { ui.q("[data-detail]").textContent = `${record.textContent} 的联系人与订单`; ui.state(`selected:${record.dataset.record}`); }));
  ui.state("selected:none");
}

export function renderSidebar(ctx) {
  const ui = mount(ctx, `<div style="display:flex"><aside data-sidebar style="width:180px">导航菜单</aside><main style="flex:1">工作区</main></div><button data-collapse>折叠侧栏</button>`);
  let collapsed = false;
  ui.on("[data-collapse]", "click", () => { collapsed = !collapsed; ui.q("[data-sidebar]").style.width = collapsed ? "48px" : "180px"; ui.q("[data-sidebar]").textContent = collapsed ? "☰" : "导航菜单"; ui.state(`collapsed:${collapsed}`); });
  ui.state("collapsed:false");
}

export function renderDrawerWorkspace(ctx) {
  const ui = mount(ctx, `<div data-workspace style="height:150px;position:relative;overflow:hidden;border:1px solid #aaa"><main>列表工作区</main><aside data-drawer hidden style="position:absolute;right:0;top:0;width:60%;height:100%;background:#eef">订单详情 <button data-close>关闭</button></aside></div><button data-open>打开详情抽屉</button>`);
  const setOpen = (open) => { ui.q("[data-drawer]").hidden = !open; ui.state(`drawer:${open ? "open" : "closed"}`); };
  ui.on("[data-open]", "click", () => setOpen(true)); ui.on("[data-close]", "click", () => setOpen(false));
  setOpen(false);
}

export function renderMultiWindow(ctx) {
  const ui = mount(ctx, `<div style="position:relative;height:170px"><button data-window="orders" style="position:absolute;left:20px;top:20px;width:180px;height:100px">订单窗口</button><button data-window="customer" style="position:absolute;left:140px;top:50px;width:180px;height:100px">客户窗口</button></div>`);
  let z = 2;
  ui.qa("[data-window]").forEach((win) => ctx.on(win, "click", () => { win.style.zIndex = String(++z); ui.state(`focused:${win.dataset.window}`); }));
  ui.state("focused:none");
}

export function renderSavedWorkspace(ctx) {
  const ui = mount(ctx, `<div data-layout style="display:grid;grid-template-columns:2fr 1fr;gap:8px"><main>查询结果</main><aside>筛选器</aside></div><button data-save>保存当前工作区</button><button data-restore>恢复工作区</button>`);
  let saved = false;
  ui.on("[data-save]", "click", () => { saved = true; ui.q("[data-layout]").style.gridTemplateColumns = "1fr 2fr"; ui.state("workspace:saved"); });
  ui.on("[data-restore]", "click", () => { ui.q("[data-layout]").style.gridTemplateColumns = saved ? "2fr 1fr" : "1fr 1fr"; ui.state(saved ? "workspace:restored" : "workspace:none"); });
  ui.state("workspace:default");
}

export const layoutRenderers = {
  "01:grid-layout": renderGridLayout,
  "01:row-column": renderRowColumn,
  "01:flex-layout": renderFlexLayout,
  "01:multi-column": renderMultiColumn,
  "01:split-pane": renderSplitPane,
  "01:resizable-panel": renderResizablePanel,
  "01:dock-layout": renderDockLayout,
  "01:tabs-layout": renderTabsLayout,
  "01:accordion": renderAccordion,
  "01:card-layout": renderCardLayout,
  "01:masonry": renderMasonry,
  "01:dashboard": renderDashboard,
  "01:drag-grid": renderDragGrid,
  "01:free-canvas": renderFreeCanvas,
  "01:responsive-layout": renderResponsiveLayout,
  "01:adaptive-breakpoint": renderAdaptiveBreakpoint,
  "01:nested-container": renderNestedContainer,
  "01:configurable-page": renderConfigurablePage,
  "01:multi-column-editor": renderMultiColumnEditor,
  "01:immersive": renderImmersive,
  "01:master-detail": renderMasterDetail,
  "01:sidebar": renderSidebar,
  "01:drawer-workspace": renderDrawerWorkspace,
  "01:multi-window": renderMultiWindow,
  "01:saved-workspace": renderSavedWorkspace,
};

export const renderers01 = layoutRenderers;

export default layoutRenderers;
