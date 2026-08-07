export const categoryNumber = "06";

function panel(ctx, title, ...children) { return ctx.el("div", { className: "demo col" }, ctx.el("h3", { text: title }), ...children); }
function result(ctx, text = "尚未选择") { return ctx.el("div", { className: "status", text }); }

function renderRemoteSelector(ctx) {
  const out = result(ctx, "输入后从服务端检索"); const search = ctx.button("搜索客户 A", "remote-search");
  ctx.on(search, "click", () => { out.textContent = "已选择：C-1008 · 客户 A"; ctx.setStatus("远程实体已选择", "remote:C-1008"); }); ctx.stage.append(panel(ctx, "远程单选", ctx.el("input", { "aria-label": "客户关键字", value: "客户 A" }), out, search)); return {};
}
function renderAsyncSelector(ctx) {
  const out = result(ctx, "空闲"); const load = ctx.button("异步加载选项", "async-load");
  ctx.on(load, "click", () => { out.textContent = "加载中…"; ctx.setStatus("选项加载中", "async:loading"); ctx.timeout(() => { out.textContent = "已加载 3 个选项"; ctx.setStatus("异步选项就绪", "async:ready"); }, 80); }); ctx.stage.append(panel(ctx, "异步选项生命周期", out, load)); return {};
}
function renderMultiSelect(ctx) {
  const tokens = ctx.el("div", { className: "row" }); const add = ctx.button("添加 华东", "multi-add");
  ctx.on(add, "click", () => { tokens.append(ctx.el("span", { className: "pill", text: "华东 ×" })); ctx.setStatus("已选择 1 项", "selected:1"); }); ctx.stage.append(panel(ctx, "多选令牌", tokens, add)); return {};
}
function renderTreeSelector(ctx) {
  const out = result(ctx); const choose = ctx.button("选择 华东 / 上海", "tree-choose");
  ctx.on(choose, "click", () => { out.textContent = "路径：全国 / 华东 / 上海"; ctx.setStatus("树节点已选择", "tree:shanghai"); }); ctx.stage.append(panel(ctx, "层级树选择", ctx.el("div", { className: "item", text: "▾ 全国  ▾ 华东  · 上海" }), out, choose)); return {};
}
function renderCascader(ctx) {
  const out = result(ctx, "第 1 级：省份"); const next = ctx.button("选择 浙江并进入城市", "cascade-next");
  ctx.on(next, "click", () => { out.textContent = "浙江 > 杭州；第 3 级等待区县"; ctx.setStatus("级联路径深度 2", "path:2"); }); ctx.stage.append(panel(ctx, "逐级选择", out, next)); return {};
}
function renderTableSelector(ctx) {
  const out = result(ctx); const row = ctx.button("选择订单 SO-2081", "table-row");
  ctx.on(row, "click", () => { row.classList.add("primary"); out.textContent = "SO-2081 / ¥12,800 / 待发货"; ctx.setStatus("表格行已选择", "row:SO-2081"); }); ctx.stage.append(panel(ctx, "多列实体选择", ctx.el("div", { className: "matrix" }, row), out)); return {};
}
function renderDialogSelector(ctx) {
  const modal = ctx.el("div", { className: "item", text: "选择弹窗已关闭" }); const open = ctx.button("打开选择弹窗", "dialog-open");
  ctx.on(open, "click", () => { modal.textContent = "弹窗：搜索、勾选、确认（已打开）"; ctx.setStatus("选择弹窗打开", "dialog:open"); }); ctx.stage.append(panel(ctx, "弹窗选择流程", modal, open)); return {};
}
function renderTransferSelector(ctx) {
  const left = ctx.el("div", { className: "item", text: "可选：销售组" }); const right = ctx.el("div", { className: "item", text: "已选：空" }); const move = ctx.button("移入销售组", "transfer-right");
  ctx.on(move, "click", () => { left.textContent = "可选：空"; right.textContent = "已选：销售组"; ctx.setStatus("穿梭完成 1 项", "transfer:1"); }); ctx.stage.append(panel(ctx, "双栏穿梭", ctx.el("div", { className: "row" }, left, move, right))); return {};
}
function renderOrderedTransfer(ctx) {
  const order = ctx.el("div", { className: "item", text: "已选：客户 > 金额 > 状态" }); const up = ctx.button("将状态移到最前", "order-up");
  ctx.on(up, "click", () => { order.textContent = "已选：状态 > 客户 > 金额"; ctx.setStatus("已选项顺序已改变", "order:status-first"); }); ctx.stage.append(panel(ctx, "有序穿梭", order, up)); return {};
}
function renderPersonSelector(ctx) {
  const out = result(ctx, "候选人显示忙闲状态"); const pick = ctx.button("选择 李明（空闲）", "person-pick");
  ctx.on(pick, "click", () => { out.textContent = "李明 · 产品部 · 当前可用"; ctx.setStatus("人员已选择", "person:liming"); }); ctx.stage.append(panel(ctx, "人员选择", out, pick)); return {};
}
function renderOrganizationSelector(ctx) {
  const out = result(ctx); const choose = ctx.button("选择 华东大区", "org-pick");
  ctx.on(choose, "click", () => { out.textContent = "集团 / 中国区 / 华东大区"; ctx.setStatus("组织路径已选择", "org:east"); }); ctx.stage.append(panel(ctx, "组织层级", out, choose)); return {};
}
function renderDepartmentSelector(ctx) {
  const out = result(ctx, "范围：仅当前部门"); const include = ctx.button("选择销售部并包含下级", "dept-scope");
  ctx.on(include, "click", () => { out.textContent = "销售部（包含 4 个下级部门）"; ctx.setStatus("部门范围包含下级", "department:descendants"); }); ctx.stage.append(panel(ctx, "部门范围", out, include)); return {};
}
function renderRoleSelector(ctx) {
  const out = result(ctx, "角色互斥检查未运行"); const choose = ctx.button("选择 审批人", "role-pick");
  ctx.on(choose, "click", () => { out.textContent = "审批人 · 32 位成员 · 与申请人角色不冲突"; ctx.setStatus("角色已选择", "role:approver"); }); ctx.stage.append(panel(ctx, "角色选择", out, choose)); return {};
}
function renderResourceSelector(ctx) {
  const out = result(ctx, "CPU 资源余量 8 核"); const reserve = ctx.button("选择 4 核资源", "resource-pick");
  ctx.on(reserve, "click", () => { out.textContent = "已预留 4 核；剩余 4 核"; ctx.setStatus("资源容量已占用", "capacity:4/8"); }); ctx.stage.append(panel(ctx, "容量约束资源", out, reserve)); return {};
}
function renderRelationSelector(ctx) {
  const out = result(ctx); const link = ctx.button("关联客户 C-1008", "relation-link");
  ctx.on(link, "click", () => { out.textContent = "当前合同 → 客户 C-1008（主要客户）"; ctx.setStatus("关系实体已绑定", "relation:C-1008"); }); ctx.stage.append(panel(ctx, "关联记录", out, link)); return {};
}
function renderMasterDataSelector(ctx) {
  const out = result(ctx, "主数据编码必须唯一"); const pick = ctx.button("选择 MD-CN-001", "master-pick");
  ctx.on(pick, "click", () => { out.textContent = "MD-CN-001 · 标准客户分类 · 版本 7"; ctx.setStatus("主数据已选择", "master:MD-CN-001"); }); ctx.stage.append(panel(ctx, "主数据选择", out, pick)); return {};
}
function renderAddressSelector(ctx) {
  const out = result(ctx); const locate = ctx.button("选择三级地址", "address-pick");
  ctx.on(locate, "click", () => { out.textContent = "浙江省 / 杭州市 / 西湖区 · 邮编 310000"; ctx.setStatus("结构化地址已选择", "address:330106"); }); ctx.stage.append(panel(ctx, "行政区地址", out, locate)); return {};
}
function renderMapSelector(ctx) {
  const marker = ctx.el("div", { className: "canvas", text: "地图画布：尚无标记" }); const place = ctx.button("在中心放置标记", "map-marker");
  ctx.on(place, "click", () => { marker.textContent = "📍 120.1307, 30.2590；地址已反查"; ctx.setStatus("地图坐标已选择", "coordinate:120.1307,30.2590"); }); ctx.stage.append(panel(ctx, "地图坐标", marker, place)); return {};
}
function renderDateSelector(ctx) {
  const out = result(ctx, "未选择日期"); const today = ctx.button("选择 2026-07-14", "date-pick");
  ctx.on(today, "click", () => { out.textContent = "2026-07-14（星期二）"; ctx.setStatus("单日已选择", "date:2026-07-14"); }); ctx.stage.append(panel(ctx, "单日选择", out, today)); return {};
}
function renderDateRangeSelector(ctx) {
  const out = result(ctx, "请选择开始和结束日期"); const choose = ctx.button("选择 7 月 14–18 日", "date-range");
  ctx.on(choose, "click", () => { out.textContent = "2026-07-14 — 2026-07-18，共 5 天"; ctx.setStatus("连续日期范围已选择", "days:5"); }); ctx.stage.append(panel(ctx, "日期范围", out, choose)); return {};
}
function renderTimeSlotSelector(ctx) {
  const out = result(ctx, "14:00 已被占用"); const pick = ctx.button("选择 15:00–15:30", "slot-pick");
  ctx.on(pick, "click", () => { out.textContent = "15:00–15:30 可用，已暂时锁定"; ctx.setStatus("时间段已锁定", "slot:15:00"); }); ctx.stage.append(panel(ctx, "可用时间段", out, pick)); return {};
}
function renderColorSelector(ctx) {
  const swatch = ctx.el("div", { className: "item", text: "#356F9F" }); const choose = ctx.button("选择品牌蓝", "color-pick");
  ctx.on(choose, "click", () => { swatch.style.background = "#356f9f"; swatch.style.color = "white"; ctx.setStatus("颜色值 #356F9F", "color:#356f9f"); }); ctx.stage.append(panel(ctx, "颜色值与预览", swatch, choose)); return {};
}
function renderIconSelector(ctx) {
  const preview = result(ctx, "未选择图标"); const choose = ctx.button("选择 ★ 收藏", "icon-pick");
  ctx.on(choose, "click", () => { preview.textContent = "★ favorite · 24px · filled"; ctx.setStatus("图标已选择", "icon:favorite"); }); ctx.stage.append(panel(ctx, "图标搜索与预览", preview, choose)); return {};
}
function renderFileSelector(ctx) {
  const out = result(ctx, "仅允许 PDF，最大 10 MB"); const choose = ctx.button("选择 合同.pdf", "file-pick");
  ctx.on(choose, "click", () => { out.textContent = "合同.pdf · 2.4 MB · application/pdf"; ctx.setStatus("文件校验通过", "file:valid"); }); ctx.stage.append(panel(ctx, "文件约束选择", out, choose)); return {};
}
function renderCompositeSelector(ctx) {
  const out = result(ctx, "需要客户、联系人和地址"); const choose = ctx.button("选择完整交付对象", "composite-pick");
  ctx.on(choose, "click", () => { out.textContent = "客户 C-1008 / 李明 / 杭州西湖区 / 默认联系人"; ctx.setStatus("复合对象已选择", "composite:complete"); }); ctx.stage.append(panel(ctx, "复合对象摘要", out, choose)); return {};
}

export const renderers06 = Object.freeze({
  "06:remote-selector": renderRemoteSelector, "06:async-selector": renderAsyncSelector, "06:multi-select": renderMultiSelect,
  "06:tree-selector": renderTreeSelector, "06:cascader": renderCascader, "06:table-selector": renderTableSelector,
  "06:dialog-selector": renderDialogSelector, "06:transfer-selector": renderTransferSelector, "06:ordered-transfer": renderOrderedTransfer,
  "06:person-selector": renderPersonSelector, "06:organization-selector": renderOrganizationSelector, "06:department-selector": renderDepartmentSelector,
  "06:role-selector": renderRoleSelector, "06:resource-selector": renderResourceSelector, "06:relation-selector": renderRelationSelector,
  "06:master-data-selector": renderMasterDataSelector, "06:address-selector": renderAddressSelector, "06:map-selector": renderMapSelector,
  "06:date-selector": renderDateSelector, "06:date-range-selector": renderDateRangeSelector, "06:time-slot-selector": renderTimeSlotSelector,
  "06:color-selector": renderColorSelector, "06:icon-selector": renderIconSelector, "06:file-selector": renderFileSelector,
  "06:composite-selector": renderCompositeSelector,
});
export const renderers = renderers06;
