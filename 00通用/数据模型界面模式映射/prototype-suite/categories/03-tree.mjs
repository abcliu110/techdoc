function mount(ctx, html) {
  ctx.stage.innerHTML = `<div class="prototype-demo">${html}<output data-state aria-live="polite"></output></div>`;
  const q = (selector) => ctx.stage.querySelector(selector), qa = (selector) => [...ctx.stage.querySelectorAll(selector)];
  const state = (value) => { q("[data-state]").textContent = String(value); ctx.setStatus?.(value, value); };
  const on = (selector, type, listener) => ctx.on(q(selector), type, listener);
  return { q, qa, state, on };
}

export function renderTreeView(ctx) {
  const ui = mount(ctx, `<ul><li><button data-node="root">产品</button><ul><li><button data-node="crm">CRM</button></li><li><button data-node="erp">ERP</button></li></ul></li></ul>`);
  ui.qa("[data-node]").forEach((node) => ctx.on(node, "click", () => { ui.qa("[data-node]").forEach((item) => item.classList.toggle("selected", item === node)); ui.state(`selected:${node.dataset.node}`); })); ui.state("selected:none");
}
export function renderCheckboxTree(ctx) {
  const ui = mount(ctx, `<label><input type="checkbox" data-parent> 华东区</label><ul><li><label><input type="checkbox" data-child> 上海</label></li><li><label><input type="checkbox" data-child> 杭州</label></li></ul>`);
  ui.on("[data-parent]", "change", () => { const checked = ui.q("[data-parent]").checked; ui.qa("[data-child]").forEach((child) => { child.checked = checked; }); ui.state(`checked:${checked ? 3 : 0}`); }); ui.qa("[data-child]").forEach((child) => ctx.on(child, "change", () => { const count = ui.qa("[data-child]:checked").length; ui.q("[data-parent]").indeterminate = count === 1; ui.state(`childrenChecked:${count}`); })); ui.state("checked:0");
}
export function renderRadioTree(ctx) {
  const ui = mount(ctx, `<fieldset><legend>选择唯一分类</legend><label><input type="radio" name="category" data-radio="hardware"> 硬件</label><label><input type="radio" name="category" data-radio="software"> 软件</label></fieldset>`);
  ui.qa("[data-radio]").forEach((radio) => ctx.on(radio, "change", () => ui.state(`selected:${radio.dataset.radio}`))); ui.state("selected:none");
}
export function renderLazyTree(ctx) {
  const ui = mount(ctx, `<ul><li><button data-load aria-expanded="false">▶ 华南区</button><ul data-children></ul></li></ul>`);
  let loaded = false; ui.on("[data-load]", "click", () => { if (!loaded) { ["广州", "深圳"].forEach((text) => { const li = document.createElement("li"); li.textContent = text; ui.q("[data-children]").append(li); }); loaded = true; } ui.q("[data-load]").setAttribute("aria-expanded", "true"); ui.state("lazy:loaded:2"); }); ui.state("lazy:idle");
}
export function renderVirtualTree(ctx) {
  const ui = mount(ctx, `<ul data-window></ul><button data-next-window>显示第 101 个节点</button>`);
  let start = 1; const draw = () => { const list = ui.q("[data-window]"); list.replaceChildren(...Array.from({length:7},(_,i)=>{const li=document.createElement("li");li.textContent=`节点 ${start+i}`;return li;})); ui.state(`windowStart:${start}`); }; ui.on("[data-next-window]", "click",()=>{start=start===1?101:1;draw();}); draw();
}
export function renderSearchTree(ctx) {
  const ui = mount(ctx, `<label>搜索节点 <input data-search value="上海"></label><ul><li>中国<ul><li>华东<ul><li data-node="上海">上海</li><li data-node="杭州">杭州</li></ul></li></ul></li></ul><button data-find>定位节点</button>`);
  ui.on("[data-find]", "click",()=>{const term=ui.q("[data-search]").value;const node=ui.qa("[data-node]").find((item)=>item.dataset.node.includes(term));ui.qa("[data-node]").forEach((item)=>item.classList.toggle("selected",item===node));ui.state(node?`revealed:${node.dataset.node}`:"revealed:none");}); ui.state("revealed:none");
}
export function renderDraggableTree(ctx) {
  const ui = mount(ctx, `<ul><li data-parent="root">根目录<ul data-root><li data-node="report">报表</li><li data-node="archive">归档<ul data-archive></ul></li></ul></li></ul><button data-reparent>移动报表到归档</button>`);
  let parent="root";ui.on("[data-reparent]","click",()=>{parent=parent==="root"?"archive":"root";ui.q(parent==="archive"?"[data-archive]":"[data-root]").append(ui.q('[data-node="report"]'));ui.state(`parent:${parent}`);});ui.state("parent:root");
}
export function renderEditableTree(ctx) {
  const ui=mount(ctx,`<ul><li><span data-label>销售资料</span> <button data-edit>重命名</button></li></ul>`);let editing=false;ui.on("[data-edit]","click",()=>{editing=!editing;ui.q("[data-label]").contentEditable=String(editing);ui.q("[data-label]").focus();ui.q("[data-edit]").textContent=editing?"保存":"重命名";ui.state(`editing:${editing}`);});ui.state("editing:false");
}
export function renderContextTree(ctx) {
  const ui=mount(ctx,`<button data-target>项目文档</button><menu data-menu hidden><button data-command="duplicate">复制节点</button><button data-command="delete">删除节点</button></menu>`);ui.on("[data-target]","contextmenu",(event)=>{event.preventDefault();ui.q("[data-menu]").hidden=false;ui.state("menu:open");});ui.qa("[data-command]").forEach((button)=>ctx.on(button,"click",()=>{ui.q("[data-menu]").hidden=true;ui.state(`command:${button.dataset.command}`);}));ui.state("menu:closed");
}
export function renderFileTree(ctx) {
  const ui=mount(ctx,`<ul data-files><li data-file="readme">README.md</li></ul><button data-new-file>新建文件</button><button data-rename-file>重命名</button>`);ui.on("[data-new-file]","click",()=>{if(!ui.q('[data-file="draft"]')){const li=document.createElement("li");li.dataset.file="draft";li.textContent="draft.md";ui.q("[data-files]").append(li);}ui.state("file:created");});ui.on("[data-rename-file]","click",()=>{const file=ui.q('[data-file="draft"]');if(file){file.textContent="proposal.md";ui.state("file:renamed");}});ui.state("file:initial");
}
export function renderOrgTree(ctx) {
  const ui=mount(ctx,`<ul><li>总部<ul><li data-unit="sales">销售部</li><li data-unit="tech">技术部<ul data-tech></ul></li></ul></li></ul><button data-org-move>将销售部并入技术中心</button>`);let parent="hq";ui.on("[data-org-move]","click",()=>{parent=parent==="hq"?"tech":"hq";if(parent==="tech")ui.q("[data-tech]").append(ui.q('[data-unit="sales"]'));else ui.q('[data-unit="tech"]').before(ui.q('[data-unit="sales"]'));ui.state(`orgParent:${parent}`);});ui.state("orgParent:hq");
}
export function renderCategoryTree(ctx) {
  const ui=mount(ctx,`<ul><li>商品分类<ul><li><button data-category="office">办公用品</button></li><li><button data-category="digital">数码设备</button></li></ul></li></ul><aside data-products>未选择分类</aside>`);ui.qa("[data-category]").forEach((button)=>ctx.on(button,"click",()=>{ui.q("[data-products]").textContent=button.dataset.category==="office"?"纸张、笔、文件夹":"电脑、显示器、键盘";ui.state(`category:${button.dataset.category}`);}));ui.state("category:none");
}
export function renderRegionTree(ctx) {
  const ui=mount(ctx,`<button data-region="china">中国</button> › <button data-region="east">华东</button> › <button data-region="shanghai">上海</button><output data-path></output>`);ui.qa("[data-region]").forEach((button)=>ctx.on(button,"click",()=>{ui.q("[data-path]").textContent=`当前位置：中国 / ${button.textContent}`;ui.state(`region:${button.dataset.region}`);}));ui.state("region:china");
}
export function renderMenuTree(ctx) {
  const ui=mount(ctx,`<ul><li><label><input type="checkbox" data-menu="dashboard" checked> 仪表盘</label></li><li><label><input type="checkbox" data-menu="admin"> 管理设置</label></li></ul>`);ui.qa("[data-menu]").forEach((input)=>ctx.on(input,"change",()=>ui.state(`${input.dataset.menu}:${input.checked?"enabled":"disabled"}`)));ui.state("menus:initial");
}
export function renderPermissionTree(ctx) {
  const ui=mount(ctx,`<label><input type="checkbox" data-parent checked> 客户管理（继承）</label><ul><li><label><input type="checkbox" data-child checked disabled> 查看客户</label></li><li><label><input type="checkbox" data-child checked disabled> 编辑客户</label></li></ul><button data-override>覆盖继承</button>`);let inherited=true;ui.on("[data-override]","click",()=>{inherited=!inherited;ui.qa("[data-child]").forEach((input)=>{input.disabled=inherited;});ui.state(`inherited:${inherited}`);});ui.state("inherited:true");
}
export function renderDependencyTree(ctx) {
  const ui=mount(ctx,`<ul><li>订单服务<ul><li data-dependent>库存服务</li><li data-dependent>支付服务</li></ul></li></ul><button data-impact>分析变更影响</button>`);ui.on("[data-impact]","click",()=>{ui.qa("[data-dependent]").forEach((node)=>node.style.background="#ffe2a8");ui.state("impacted:2");});ui.state("impacted:0");
}
export function renderRelationshipTree(ctx) {
  const ui=mount(ctx,`<div data-relation>客户 → 订单 → 商品</div><button data-direction>反向查看关系</button>`);let direction="out";ui.on("[data-direction]","click",()=>{direction=direction==="out"?"in":"out";ui.q("[data-relation]").textContent=direction==="out"?"客户 → 订单 → 商品":"商品 ← 订单 ← 客户";ui.state(`direction:${direction}`);});ui.state("direction:out");
}
export function renderOutlineTree(ctx) {
  const ui=mount(ctx,`<nav><button data-heading="intro">1. 简介</button><button data-heading="design">2. 设计</button></nav><article data-section>文档正文</article>`);ui.qa("[data-heading]").forEach((button)=>ctx.on(button,"click",()=>{ui.q("[data-section]").textContent=`已定位：${button.textContent}`;ui.state(`heading:${button.dataset.heading}`);}));ui.state("heading:none");
}
export function renderMindmapTree(ctx) {
  const ui=mount(ctx,`<div data-map>产品 <span>— 需求</span> <span>— 设计</span></div><button data-branch>添加研发分支</button>`);let branches=2;ui.on("[data-branch]","click",()=>{if(branches===2){const span=document.createElement("span");span.textContent=" — 研发";span.dataset.newBranch="";ui.q("[data-map]").append(span);branches=3;}else{ui.q("[data-new-branch]")?.remove();branches=2;}ui.state(`branches:${branches}`);});ui.state("branches:2");
}
export function renderGenealogyTree(ctx) {
  const ui=mount(ctx,`<div>第一代：<button data-person="grandparent">祖辈</button></div><div>第二代：<button data-person="parent">父辈</button></div><div>第三代：<button data-person="child">子代</button></div><aside data-profile>选择成员</aside>`);ui.qa("[data-person]").forEach((button)=>ctx.on(button,"click",()=>{ui.q("[data-profile]").textContent=`焦点成员：${button.textContent}；展示上下两代`;ui.state(`focus:${button.dataset.person}`);}));ui.state("focus:none");
}

export const treeRenderers={"03:tree-view":renderTreeView,"03:checkbox-tree":renderCheckboxTree,"03:radio-tree":renderRadioTree,"03:lazy-tree":renderLazyTree,"03:virtual-tree":renderVirtualTree,"03:search-tree":renderSearchTree,"03:draggable-tree":renderDraggableTree,"03:editable-tree":renderEditableTree,"03:context-tree":renderContextTree,"03:file-tree":renderFileTree,"03:org-tree":renderOrgTree,"03:category-tree":renderCategoryTree,"03:region-tree":renderRegionTree,"03:menu-tree":renderMenuTree,"03:permission-tree":renderPermissionTree,"03:dependency-tree":renderDependencyTree,"03:relationship-tree":renderRelationshipTree,"03:outline-tree":renderOutlineTree,"03:mindmap-tree":renderMindmapTree,"03:genealogy-tree":renderGenealogyTree};
export const renderers03=treeRenderers;
export default treeRenderers;
