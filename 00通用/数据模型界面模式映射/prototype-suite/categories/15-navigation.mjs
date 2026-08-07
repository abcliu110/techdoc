function mount(ctx, html) {
  ctx.stage.innerHTML = `<div class="prototype-demo">${html}<output class="prototype-state" data-demo-state aria-live="polite"></output></div>`;
  const q = (selector) => ctx.stage.querySelector(selector);
  const qa = (selector) => [...ctx.stage.querySelectorAll(selector)];
  const state = (value) => {
    q("[data-demo-state]").textContent = String(value);
    q("[data-demo-state]").dataset.state = String(value);
    ctx.setStatus(value, value);
  };
  const on = (selector, type, listener) => ctx.on(q(selector), type, listener);
  return { q, qa, state, on };
}

export function renderMultiLevelMenu(ctx) {
  const ui = mount(ctx, `<nav aria-label="三级业务菜单"><button data-action aria-expanded="false">销售管理</button><ul data-branch hidden><li><button data-child>订单中心</button></li><li><button data-child>退货管理</button></li></ul></nav>`);
  let open = false;
  ui.on("[data-action]", "click", () => { open = !open; ui.q("[data-action]").setAttribute("aria-expanded", String(open)); ui.q("[data-branch]").hidden = !open; ui.state(`menu:${open ? "sales-expanded" : "collapsed"}`); });
  ui.state("menu:collapsed");
}

export function renderDynamicRouteMenu(ctx) {
  const ui = mount(ctx, `<div><label>路由参数 <input data-param aria-label="路由参数" value="SO-2026-001"></label><button data-action>解析动态路由</button><code data-route>/orders/:id</code></div>`);
  ui.on("[data-action]", "click", () => { const id = ui.q("[data-param]").value.trim() || "new"; ui.q("[data-route]").textContent = `/orders/${id}`; ui.state(`route:/orders/${id}`); });
  ui.state("route:/orders/:id");
}

export function renderPermissionMenu(ctx) {
  const ui = mount(ctx, `<label>模拟角色 <select data-role aria-label="模拟角色"><option value="viewer">访客</option><option value="admin">管理员</option></select></label><nav><button>数据看板</button><button data-admin hidden>权限配置</button></nav><button data-action>应用菜单权限</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-role]").value = "admin"; const role = ui.q("[data-role]").value; ui.q("[data-admin]").hidden = role !== "admin"; ui.state(`visible:${role === "admin" ? 2 : 1};role:${role}`); });
  ui.state("visible:1;role:viewer");
}

export function renderMegaMenu(ctx) {
  const ui = mount(ctx, `<div role="menu" style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px"><button data-group="sales">销售<br><small>客户 · 商机</small></button><button data-group="supply">供应链<br><small>采购 · 库存</small></button><button data-group="finance">财务<br><small>应收 · 总账</small></button></div><button data-action>打开供应链分组</button>`);
  ui.on("[data-action]", "click", () => { ui.qa("[data-group]").forEach((node) => node.setAttribute("aria-current", String(node.dataset.group === "supply"))); ui.state("mega:group:supply;items:2"); });
  ui.state("mega:closed");
}

export function renderBreadcrumb(ctx) {
  const ui = mount(ctx, `<nav aria-label="面包屑"><button data-crumb="home">工作台</button> / <button data-crumb="orders">订单</button> / <span data-current>订单详情</span></nav><button data-action>返回订单层级</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-current]").textContent = "订单列表"; ui.state("breadcrumb:/workspace/orders"); });
  ui.state("breadcrumb:/workspace/orders/detail");
}

export function renderTabWorkspace(ctx) {
  const ui = mount(ctx, `<div role="tablist"><button role="tab" data-tab="home" aria-selected="true">首页</button><button role="tab" data-tab="order" aria-selected="false">订单 SO-001 ·</button></div><article data-panel>首页概览</article><button data-action>切换并标记订单页已修改</button>`);
  ui.on("[data-action]", "click", () => { ui.qa("[data-tab]").forEach((tab) => tab.setAttribute("aria-selected", String(tab.dataset.tab === "order"))); ui.q('[data-tab="order"]').textContent = "订单 SO-001 *"; ui.q("[data-panel]").textContent = "订单编辑工作区（未保存）"; ui.state("tabs:active:order;dirty:true"); });
  ui.state("tabs:active:home;dirty:false");
}

export function renderCommandPalette(ctx) {
  const ui = mount(ctx, `<div role="dialog" aria-label="命令面板"><label>命令 <input data-query aria-label="命令搜索" value="创建订单"></label><ul data-results><li>创建销售订单</li><li>创建采购订单</li></ul></div><button data-action>执行首个命令</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-results]").replaceChildren(Object.assign(document.createElement("li"), { textContent: "已打开：新建销售订单" })); ui.state("command:create-sales-order:executed"); });
  ui.state("command:query:create-order");
}

export function renderGlobalSearch(ctx) {
  const ui = mount(ctx, `<label>全局搜索 <input data-query aria-label="全局搜索" value="星河科技"></label><div data-results>等待搜索</div><button data-action>跨对象搜索</button>`);
  ui.on("[data-action]", "click", () => { const term = ui.q("[data-query]").value.trim(); ui.q("[data-results]").textContent = `客户：${term}（1） · 合同（2） · 工单（1）`; ui.state(`search:${term};groups:3;results:4`); });
  ui.state("search:idle");
}

export function renderRecentVisits(ctx) {
  const ui = mount(ctx, `<ol data-list><li data-path="/customers/88">星河科技客户档案 · 09:42</li><li>/orders/SO-001 · 09:38</li></ol><div data-target>当前：工作台</div><button data-action>恢复最近页面</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-target]").textContent = "当前：星河科技客户档案"; ui.state("recent:restored:/customers/88"); });
  ui.state("recent:current:/workspace");
}

export function renderFavorites(ctx) {
  const ui = mount(ctx, `<div data-resource>销售日报</div><button data-action aria-pressed="false">加入收藏</button><div data-folder>我的收藏（0）</div>`);
  let saved = false;
  ui.on("[data-action]", "click", () => { saved = !saved; ui.q("[data-action]").setAttribute("aria-pressed", String(saved)); ui.q("[data-action]").textContent = saved ? "取消收藏" : "加入收藏"; ui.q("[data-folder]").textContent = `我的收藏（${saved ? 1 : 0}）`; ui.state(`favorite:${saved};resource:sales-report`); });
  ui.state("favorite:false;resource:sales-report");
}

export function renderQuickLauncher(ctx) {
  const ui = mount(ctx, `<div data-launcher style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px"><button data-app="order">新建订单</button><button data-app="receipt">收款登记</button><button data-app="stock">库存查询</button></div><div data-opened>未启动</div><button data-action>启动收款登记</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-opened]").textContent = "已启动：收款登记（快捷入口）"; ui.state("launcher:opened:receipt"); });
  ui.state("launcher:idle");
}

export function renderStepper(ctx) {
  const ui = mount(ctx, `<ol><li data-step="1" aria-current="step">基本信息</li><li data-step="2">商品明细</li><li data-step="3">提交确认</li></ol><label>订单名称 <input data-name aria-label="订单名称"></label><button data-action>校验并进入下一步</button>`);
  ui.on("[data-action]", "click", () => { const valid = ui.q("[data-name]").value.trim().length > 0; if (valid) { ui.q('[data-step="1"]').removeAttribute("aria-current"); ui.q('[data-step="2"]').setAttribute("aria-current", "step"); } ui.state(valid ? "step:2;validation:passed" : "step:1;validation:name-required"); });
  ui.state("step:1;validation:pending");
}

export function renderGuidedTour(ctx) {
  const ui = mount(ctx, `<div style="display:flex;gap:8px"><button data-target="filter">筛选</button><button data-target="export">导出</button></div><aside data-tip role="dialog">第 1/2 步：先设置筛选条件</aside><button data-action>下一条引导</button>`);
  let step = 1;
  ui.on("[data-action]", "click", () => { step = step === 1 ? 2 : 1; ui.q("[data-tip]").textContent = step === 2 ? "第 2/2 步：导出当前结果" : "第 1/2 步：先设置筛选条件"; ui.state(`tour:step:${step};target:${step === 2 ? "export" : "filter"}`); });
  ui.state("tour:step:1;target:filter");
}

export function renderAnchorToc(ctx) {
  const ui = mount(ctx, `<nav aria-label="页内目录"><button data-anchor="overview">概览</button><button data-anchor="metrics">指标</button><button data-anchor="history">历史</button></nav><section data-section>概览章节</section><button data-action>跳到指标章节</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-section]").textContent = "指标章节：销售额、转化率、客单价"; ui.q('[data-anchor="metrics"]').setAttribute("aria-current", "location"); ui.state("anchor:metrics;scrollTop:420"); });
  ui.state("anchor:overview;scrollTop:0");
}

export function renderDocumentOutline(ctx) {
  const ui = mount(ctx, `<ol><li>1 概述</li><li><button data-heading aria-expanded="false">2 实施方案</button><ol data-children hidden><li>2.1 架构</li><li>2.2 验收</li></ol></li></ol><button data-action>展开实施方案大纲</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-heading]").setAttribute("aria-expanded", "true"); ui.q("[data-children]").hidden = false; ui.state("outline:expanded:implementation;headings:4"); });
  ui.state("outline:collapsed;headings:2");
}

export function renderContextMenu(ctx) {
  const ui = mount(ctx, `<div data-row tabindex="0">订单 SO-001</div><div data-menu role="menu" hidden><button role="menuitem" data-copy>复制订单号</button><button role="menuitem">查看详情</button></div><button data-action>在行位置打开菜单</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-menu]").hidden = false; Object.assign(ui.q("[data-menu]").style, { marginLeft: "80px", marginTop: "4px" }); ui.state("context:open;x:80;y:4;target:SO-001"); });
  ui.state("context:closed");
}

export function renderConfigurableToolbar(ctx) {
  const ui = mount(ctx, `<div data-toolbar role="toolbar"><button data-item="save">保存</button><button data-item="print">打印</button><button data-item="export">导出</button></div><button data-action>隐藏打印并前置导出</button>`);
  ui.on("[data-action]", "click", () => { ui.q('[data-item="print"]').hidden = true; ui.q("[data-toolbar]").prepend(ui.q('[data-item="export"]')); ui.state("toolbar:order:export,save;hidden:print"); });
  ui.state("toolbar:order:save,print,export;hidden:none");
}

export function renderRibbon(ctx) {
  const ui = mount(ctx, `<div role="tablist"><button data-tab="home" aria-selected="true">开始</button><button data-tab="data" aria-selected="false">数据</button></div><div data-group>剪贴板 · 字体 · 对齐</div><button data-action>激活数据功能区</button>`);
  ui.on("[data-action]", "click", () => { ui.qa("[data-tab]").forEach((tab) => tab.setAttribute("aria-selected", String(tab.dataset.tab === "data"))); ui.q("[data-group]").textContent = "刷新 · 排序 · 数据验证"; ui.state("ribbon:tab:data;commands:3"); });
  ui.state("ribbon:tab:home;commands:3");
}

export function renderShortcutManager(ctx) {
  const ui = mount(ctx, `<label>命令 <select data-command aria-label="命令"><option>保存</option><option>导出</option></select></label><label>快捷键 <input data-shortcut aria-label="快捷键" value="Ctrl+S"></label><div data-conflict>未检测</div><button data-action>检测并绑定</button>`);
  ui.on("[data-action]", "click", () => { const shortcut = ui.q("[data-shortcut]").value; const conflict = shortcut.toLowerCase() === "ctrl+s"; ui.q("[data-conflict]").textContent = conflict ? "冲突：Ctrl+S 已绑定保存" : "可用，绑定成功"; ui.state(`shortcut:${shortcut};${conflict ? "conflict:save" : "bound:export"}`); });
  ui.state("shortcut:unvalidated");
}

export function renderWorkspaceSwitcher(ctx) {
  const ui = mount(ctx, `<div role="listbox"><button data-space="sales" aria-selected="true">销售工作区</button><button data-space="service" aria-selected="false">客服工作区</button></div><div data-layout>销售漏斗 · 本月订单</div><button data-action>切换客服工作区</button>`);
  ui.on("[data-action]", "click", () => { ui.qa("[data-space]").forEach((space) => space.setAttribute("aria-selected", String(space.dataset.space === "service"))); ui.q("[data-layout]").textContent = "待处理工单 · SLA 预警"; ui.state("workspace:service;layout:tickets"); });
  ui.state("workspace:sales;layout:funnel");
}

export const navigationRenderers = Object.freeze({
  "15:multi-level-menu": renderMultiLevelMenu,
  "15:dynamic-route-menu": renderDynamicRouteMenu,
  "15:permission-menu": renderPermissionMenu,
  "15:mega-menu": renderMegaMenu,
  "15:breadcrumb": renderBreadcrumb,
  "15:tab-workspace": renderTabWorkspace,
  "15:command-palette": renderCommandPalette,
  "15:global-search": renderGlobalSearch,
  "15:recent-visits": renderRecentVisits,
  "15:favorites": renderFavorites,
  "15:quick-launcher": renderQuickLauncher,
  "15:stepper": renderStepper,
  "15:guided-tour": renderGuidedTour,
  "15:anchor-toc": renderAnchorToc,
  "15:document-outline": renderDocumentOutline,
  "15:context-menu": renderContextMenu,
  "15:configurable-toolbar": renderConfigurableToolbar,
  "15:ribbon": renderRibbon,
  "15:shortcut-manager": renderShortcutManager,
  "15:workspace-switcher": renderWorkspaceSwitcher,
});
export const renderers15 = navigationRenderers;
export const renderers = renderers15;
