function mount(ctx, html) {
  ctx.stage.innerHTML = `<div class="prototype-demo">${html}<output class="prototype-state" data-demo-state aria-live="polite"></output></div>`;
  const q = (selector) => ctx.stage.querySelector(selector);
  const qa = (selector) => [...ctx.stage.querySelectorAll(selector)];
  const state = (value) => { q("[data-demo-state]").textContent = String(value); q("[data-demo-state]").dataset.state = String(value); ctx.setStatus(value, value); };
  const on = (selector, type, listener) => ctx.on(q(selector), type, listener);
  return { q, qa, state, on };
}

export function renderSkuEditor(ctx) {
  const ui = mount(ctx, `<fieldset><legend>颜色</legend><label><input data-color type="checkbox" value="红" checked> 红</label><label><input data-color type="checkbox" value="蓝" checked> 蓝</label></fieldset><fieldset><legend>尺码</legend><label><input data-size type="checkbox" value="M" checked> M</label><label><input data-size type="checkbox" value="L" checked> L</label></fieldset><div data-skus>待生成</div><button data-action>生成 SKU 组合</button>`);
  ui.on("[data-action]", "click", () => { const colors = ui.qa("[data-color]:checked").map((x) => x.value); const sizes = ui.qa("[data-size]:checked").map((x) => x.value); ui.q("[data-skus]").textContent = colors.flatMap((color) => sizes.map((size) => `${color}-${size}`)).join("、"); ui.state(`sku:generated:${colors.length * sizes.length};dimensions:2`); });
  ui.state("sku:generated:0;dimensions:2");
}

export function renderShoppingCart(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td>工业传感器</td><td>¥120</td><td><input data-qty type="number" value="2" min="1" aria-label="工业传感器数量"></td></tr></tbody></table><strong data-total>小计 ¥240</strong><button data-action>数量加一并重算</button>`);
  ui.on("[data-action]", "click", () => { const qty = Number(ui.q("[data-qty]").value) + 1; ui.q("[data-qty]").value = String(qty); ui.q("[data-total]").textContent = `小计 ¥${qty * 120}`; ui.state(`cart:qty:${qty};subtotal:${qty * 120}`); });
  ui.state("cart:qty:2;subtotal:240");
}

export function renderCheckout(ctx) {
  const ui = mount(ctx, `<div>商品 ¥1000 + 运费 ¥20</div><label>优惠码 <input data-code aria-label="优惠码" value="SAVE100"></label><strong data-pay>应付 ¥1020</strong><button data-action>应用优惠并结算</button>`);
  ui.on("[data-action]", "click", () => { const discount = ui.q("[data-code]").value === "SAVE100" ? 100 : 0; ui.q("[data-pay]").textContent = `应付 ¥${1020 - discount}（优惠 ¥${discount}）`; ui.state(`checkout:discount:${discount};payable:${1020 - discount};ready:true`); });
  ui.state("checkout:discount:0;payable:1020;ready:false");
}

export function renderOrderTracker(ctx) {
  const ui = mount(ctx, `<ol><li data-step="created">已下单</li><li data-step="paid">已支付</li><li data-step="shipped">待发货</li><li data-step="received">待收货</li></ol><button data-action>登记发货事件</button>`);
  ui.on("[data-action]", "click", () => { ui.q('[data-step="shipped"]').textContent = "已发货 · SF123456"; ui.q('[data-step="shipped"]').setAttribute("aria-current", "step"); ui.state("order:status:shipped;event:shipment-created"); });
  ui.state("order:status:paid;event:none");
}

export function renderStockAllocation(ctx) {
  const ui = mount(ctx, `<div>需求 80 件</div><label>华东仓 <input data-east type="number" value="50" max="60" aria-label="华东仓分配量"></label><label>华南仓 <input data-south type="number" value="30" max="50" aria-label="华南仓分配量"></label><div data-result>待校验</div><button data-action>校验库存分配</button>`);
  ui.on("[data-action]", "click", () => { const east = Number(ui.q("[data-east]").value); const south = Number(ui.q("[data-south]").value); const valid = east <= 60 && south <= 50 && east + south === 80; ui.q("[data-result]").textContent = valid ? "分配成功：需求与库存容量匹配" : "分配失败：检查总量或仓库容量"; ui.state(`allocation:${valid ? "valid" : "invalid"};east:${east};south:${south};demand:80`); });
  ui.state("allocation:pending;demand:80");
}

export function renderWarehouseMap(ctx) {
  const ui = mount(ctx, `<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px"><button data-bin="A-01" data-used="8">A-01 · 8/10</button><button data-bin="A-02" data-used="10" disabled>A-02 · 已满</button><button data-bin="A-03" data-used="2">A-03 · 2/10</button></div><div data-result>未选库位</div><button data-action>向 A-01 上架 2 件</button>`);
  ui.on("[data-action]", "click", () => { const bin = ui.q('[data-bin="A-01"]'); bin.dataset.used = "10"; bin.textContent = "A-01 · 10/10（已满）"; bin.disabled = true; ui.q("[data-result]").textContent = "上架完成，A-01 剩余容量 0"; ui.state("warehouse:bin:A-01;used:10;capacity:10;full:true"); });
  ui.state("warehouse:bin:A-01;used:8;capacity:10;full:false");
}

export function renderPriceRule(ctx) {
  const ui = mount(ctx, `<ol data-rules><li data-rule="vip">优先级 20：VIP 九折</li><li data-rule="contract">优先级 10：合同价 ¥88</li></ol><div data-result>原价 ¥100</div><button data-action>计算命中价格</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-result]").textContent = "成交价 ¥88；命中合同价（优先级 10），VIP 规则未执行"; ui.state("price:88;winner:contract;priority:10"); });
  ui.state("price:100;winner:none");
}

export function renderPromotionRule(ctx) {
  const ui = mount(ctx, `<label>订单金额 <input data-amount type="number" value="520" aria-label="订单金额"></label><label><input data-member type="checkbox" checked aria-label="会员身份"> 会员</label><div data-result>待判断</div><button data-action>判断满减资格</button>`);
  ui.on("[data-action]", "click", () => { const amount = Number(ui.q("[data-amount]").value); const eligible = amount >= 500 && ui.q("[data-member]").checked; ui.q("[data-result]").textContent = eligible ? "满足：会员满 500 减 50" : "不满足活动条件"; ui.state(`promotion:${eligible ? "eligible" : "ineligible"};discount:${eligible ? 50 : 0}`); });
  ui.state("promotion:pending;discount:0");
}

export function renderContractEditor(ctx) {
  const ui = mount(ctx, `<label>里程碑 <input data-name aria-label="里程碑" value="项目验收"></label><label>付款比例 <input data-ratio type="number" aria-label="付款比例" value="40"></label><ol data-milestones><li>签约 30%</li><li>交付 30%</li></ol><button data-action>增加验收里程碑</button>`);
  ui.on("[data-action]", "click", () => { const item = document.createElement("li"); item.textContent = `${ui.q("[data-name]").value} ${ui.q("[data-ratio]").value}%`; ui.q("[data-milestones]").append(item); ui.state("contract:milestones:3;ratio-total:100;valid:true"); });
  ui.state("contract:milestones:2;ratio-total:60;valid:false");
}

export function renderInvoiceEditor(ctx) {
  const ui = mount(ctx, `<label>不含税金额 <input data-net type="number" value="1000" aria-label="不含税金额"></label><label>税率 <select data-rate aria-label="税率"><option value="0.13">13%</option></select></label><div data-total>待计算</div><button data-action>计算税额与价税合计</button>`);
  ui.on("[data-action]", "click", () => { const net = Number(ui.q("[data-net]").value); const tax = Math.round(net * Number(ui.q("[data-rate]").value) * 100) / 100; ui.q("[data-total]").textContent = `税额 ¥${tax.toFixed(2)}；价税合计 ¥${(net + tax).toFixed(2)}`; ui.state(`invoice:net:${net};tax:${tax.toFixed(2)};gross:${(net + tax).toFixed(2)}`); });
  ui.state("invoice:uncomputed");
}

export function renderVoucherEntry(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td>银行存款</td><td><input data-debit type="number" value="1000" aria-label="银行存款借方"></td><td>0</td></tr><tr><td>主营业务收入</td><td>0</td><td><input data-credit type="number" value="900" aria-label="主营业务收入贷方"></td></tr></tbody></table><div data-result>待校验</div><button data-action>校验借贷平衡</button>`);
  ui.on("[data-action]", "click", () => { const debit = Number(ui.q("[data-debit]").value); const credit = Number(ui.q("[data-credit]").value); const balanced = debit === credit; ui.q("[data-result]").textContent = balanced ? "借贷平衡" : `借贷不平，差额 ¥${Math.abs(debit - credit)}`; ui.state(`voucher:debit:${debit};credit:${credit};balanced:${balanced}`); });
  ui.state("voucher:unchecked");
}

export function renderAccountTree(ctx) {
  const ui = mount(ctx, `<ul><li><button data-account aria-expanded="false">1002 银行存款</button><ul data-children hidden><li>100201 工商银行</li><li>100202 招商银行</li></ul></li></ul><button data-action>展开银行明细科目</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-account]").setAttribute("aria-expanded", "true"); ui.q("[data-children]").hidden = false; ui.state("account:1002;expanded:true;children:2"); });
  ui.state("account:1002;expanded:false;children:0");
}

export function renderShiftAttendance(ctx) {
  const ui = mount(ctx, `<div>林晓：09:00–18:00</div><label>新增班次开始 <input data-start type="time" value="17:00" aria-label="班次开始"></label><label>结束 <input data-end type="time" value="21:00" aria-label="班次结束"></label><div data-result>待排班</div><button data-action>检测并安排班次</button>`);
  ui.on("[data-action]", "click", () => { const conflict = ui.q("[data-start]").value < "18:00"; ui.q("[data-result]").textContent = conflict ? "冲突：与 09:00–18:00 班次重叠" : "排班成功"; ui.state(`shift:${conflict ? "conflict" : "scheduled"};employee:林晓`); });
  ui.state("shift:pending;employee:林晓");
}

export function renderPayrollSheet(ctx) {
  const ui = mount(ctx, `<label>基本工资 <input data-base type="number" value="10000" aria-label="基本工资"></label><label>奖金 <input data-bonus type="number" value="2000" aria-label="奖金"></label><label>扣款 <input data-deduct type="number" value="800" aria-label="扣款"></label><strong data-net>待计算</strong><button data-action>计算应发工资</button>`);
  ui.on("[data-action]", "click", () => { const base = Number(ui.q("[data-base]").value); const bonus = Number(ui.q("[data-bonus]").value); const deduct = Number(ui.q("[data-deduct]").value); const net = base + bonus - deduct; ui.q("[data-net]").textContent = `应发 ¥${net}`; ui.state(`payroll:base:${base};bonus:${bonus};deduct:${deduct};net:${net}`); });
  ui.state("payroll:uncomputed");
}

export function renderCrmRelationship(ctx) {
  const ui = mount(ctx, `<div style="display:flex;gap:12px"><button data-node="customer">星河科技</button><span>—</span><button data-node="contact">联系人 陈敏</button><span>—</span><button data-node="opportunity">商机 80 万</button></div><aside data-detail>选择关系节点</aside><button data-action>聚焦商机关系</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-detail]").textContent = "商机：MES 升级 · 阶段：方案确认 · 决策人：陈敏"; ui.state("crm:focus:opportunity;links:2;amount:800000"); });
  ui.state("crm:focus:customer;links:2");
}

export function renderSalesFunnel(ctx) {
  const ui = mount(ctx, `<ol><li data-stage="lead">线索 12</li><li data-stage="proposal">方案 5</li><li data-stage="won">赢单 2</li></ol><div data-deal>商机 A · 当前：线索</div><button data-action>推进商机到方案阶段</button>`);
  ui.on("[data-action]", "click", () => { ui.q('[data-stage="lead"]').textContent = "线索 11"; ui.q('[data-stage="proposal"]').textContent = "方案 6"; ui.q("[data-deal]").textContent = "商机 A · 当前：方案"; ui.state("funnel:deal:A;from:lead;to:proposal;lead:11;proposal:6"); });
  ui.state("funnel:deal:A;stage:lead;lead:12;proposal:5");
}

export function renderCustomerProfile(ctx) {
  const ui = mount(ctx, `<div>客户：星河科技</div><ul><li>年收入 500 万</li><li>近 30 天活跃 8 次</li><li>逾期 0 次</li></ul><div data-segment>未分群</div><button data-action>计算客户分群</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-segment]").textContent = "高价值 · 高活跃 · 低风险"; ui.state("customer:segment:high-value-active;score:92;risk:low"); });
  ui.state("customer:segment:unknown");
}

export function renderTicketWorkbench(ctx) {
  const ui = mount(ctx, `<div>工单 TK-108 · SLA 剩余 35 分钟</div><label>处理人 <select data-owner aria-label="工单处理人"><option>林晓</option><option>王蕾</option></select></label><div data-status>处理中</div><button data-action>转派王蕾并暂停 SLA</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-owner]").value = "王蕾"; ui.q("[data-status]").textContent = "等待现场信息 · SLA 已暂停"; ui.state("ticket:TK-108;owner:王蕾;status:waiting;SLA:paused"); });
  ui.state("ticket:TK-108;owner:林晓;status:processing;SLA:35m");
}

export function renderCallCenter(ctx) {
  const ui = mount(ctx, `<div data-call>来电：138****8899 · 未接通</div><article data-customer>客户信息尚未加载</article><button data-action>接听并弹出客户资料</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-call]").textContent = "通话中 · 00:01 · 已录音"; ui.q("[data-customer]").textContent = "星河科技 · 最近工单 TK-108 · VIP"; ui.state("call:connected;customer:星河科技;recording:true"); });
  ui.state("call:ringing;customer:unknown");
}

export function renderLogisticsTracker(ctx) {
  const ui = mount(ctx, `<ol data-route><li>上海仓 · 已揽收</li><li>苏州中转 · 运输中</li><li data-next>南京 · 待到达</li></ol><button data-action>接收南京到达轨迹</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-next]").textContent = "南京 · 已到达 10:32"; const item = document.createElement("li"); item.textContent = "客户地址 · 派送中"; ui.q("[data-route]").append(item); ui.state("logistics:status:delivering;events:4;location:南京"); });
  ui.state("logistics:status:in-transit;events:3;location:苏州");
}

export function renderMedicalRecord(ctx) {
  const ui = mount(ctx, `<label>主诉 <textarea data-chief aria-label="主诉">持续咳嗽 3 天</textarea></label><label>诊断 <input data-diagnosis aria-label="诊断" value="急性上呼吸道感染"></label><div data-version>草稿 v1</div><button data-action>签署病历版本</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-version]").textContent = "已签署 v2 · 内容锁定 · 医师张宁"; ui.q("[data-chief]").readOnly = true; ui.q("[data-diagnosis]").readOnly = true; ui.state("record:version:2;signed:true;editable:false"); });
  ui.state("record:version:1;signed:false;editable:true");
}

export function renderExamEditor(ctx) {
  const ui = mount(ctx, `<div data-paper><article>单选题 1 · 10 分</article><article>判断题 1 · 5 分</article></div><label>新增题分值 <input data-score type="number" value="15" aria-label="新增题分值"></label><strong data-total>总分 15</strong><button data-action>加入简答题并重算</button>`);
  ui.on("[data-action]", "click", () => { const score = Number(ui.q("[data-score]").value); const article = document.createElement("article"); article.textContent = `简答题 1 · ${score} 分`; ui.q("[data-paper]").append(article); ui.q("[data-total]").textContent = `总分 ${15 + score}`; ui.state(`exam:questions:3;total:${15 + score}`); });
  ui.state("exam:questions:2;total:15");
}

export function renderQuestionBank(ctx) {
  const ui = mount(ctx, `<label>知识点 <select data-topic aria-label="知识点"><option value="all">全部</option><option value="database">数据库</option></select></label><ul data-list><li>SQL 基础</li><li>事务隔离</li><li>网络协议</li></ul><button data-action>筛选数据库并选题</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-topic]").value = "database"; ui.q("[data-list]").innerHTML = "<li>✓ SQL 基础</li><li>✓ 事务隔离</li>"; ui.state("question-bank:topic:database;visible:2;selected:2"); });
  ui.state("question-bank:topic:all;visible:3;selected:0");
}

export function renderCoursePlanner(ctx) {
  const ui = mount(ctx, `<div>周一 09:00 · 101 教室 · 高等数学</div><label>新课程时间 <input data-time type="time" value="09:00" aria-label="新课程时间"></label><label>教室 <select data-room aria-label="教室"><option>101</option><option>102</option></select></label><div data-result>待编排</div><button data-action>检测课程冲突</button>`);
  ui.on("[data-action]", "click", () => { const conflict = ui.q("[data-time]").value === "09:00" && ui.q("[data-room]").value === "101"; ui.q("[data-result]").textContent = conflict ? "冲突：101 教室已被高等数学占用" : "编排成功"; ui.state(`course:${conflict ? "conflict" : "scheduled"};room:${ui.q("[data-room]").value};time:${ui.q("[data-time]").value}`); });
  ui.state("course:pending");
}

export function renderSeatPicker(ctx) {
  const ui = mount(ctx, `<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:6px"><button data-seat="A1">A1</button><button data-seat="A2" disabled>A2 已售</button><button data-seat="A3">A3</button><button data-seat="A4">A4</button></div><div data-result>未选座</div><button data-action>选择 A3</button>`);
  ui.on("[data-action]", "click", () => { const seat = ui.q('[data-seat="A3"]'); seat.setAttribute("aria-pressed", "true"); seat.textContent = "A3 已选"; ui.q("[data-result]").textContent = "已选 A3 · ¥80"; ui.state("seat:A3;status:selected;price:80"); });
  ui.state("seat:none;available:3;sold:1");
}

export function renderResourceBooking(ctx) {
  const ui = mount(ctx, `<div>会议室 A · 10:00–11:00 已被研发例会占用</div><label>开始 <input data-start type="time" value="10:30" aria-label="预订开始"></label><label>结束 <input data-end type="time" value="11:30" aria-label="预订结束"></label><div data-result>待检查</div><button data-action>检查预订碰撞</button>`);
  ui.on("[data-action]", "click", () => { const start = ui.q("[data-start]").value; const end = ui.q("[data-end]").value; const conflict = start < "11:00" && end > "10:00"; ui.q("[data-result]").textContent = conflict ? "冲突：与研发例会重叠 30 分钟" : "时段可预订"; ui.state(`booking:${conflict ? "conflict" : "available"};resource:room-A;start:${start};end:${end}`); });
  ui.state("booking:unchecked;resource:room-A");
}

export function renderConfigurator(ctx) {
  const ui = mount(ctx, `<label>处理器 <select data-cpu aria-label="处理器"><option value="standard">标准版</option><option value="pro">专业版</option></select></label><label><input data-gpu type="checkbox" aria-label="独立显卡"> 独立显卡</label><div data-result>基础配置 ¥5000</div><button data-action>选择专业版并校验兼容性</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-cpu]").value = "pro"; ui.q("[data-gpu]").checked = true; ui.q("[data-result]").textContent = "配置兼容：专业版 + 独立显卡 · ¥7800"; ui.state("config:cpu:pro;gpu:true;compatible:true;price:7800"); });
  ui.state("config:cpu:standard;gpu:false;compatible:true;price:5000");
}

export function renderBomEditor(ctx) {
  const ui = mount(ctx, `<ul><li>整机 ×1<ul data-parts><li>主板 ×1</li><li>电源 ×1</li></ul></li></ul><button data-action>加入风扇组件 ×2 并展开成本</button><div data-cost>材料成本 ¥1800</div>`);
  ui.on("[data-action]", "click", () => { const item = document.createElement("li"); item.textContent = "风扇 ×2 · ¥160"; ui.q("[data-parts]").append(item); ui.q("[data-cost]").textContent = "材料成本 ¥1960"; ui.state("bom:parts:3;fan-qty:2;cost:1960"); });
  ui.state("bom:parts:2;cost:1800");
}

export function renderDeviceMonitor(ctx) {
  const ui = mount(ctx, `<div>设备 CNC-07</div><meter data-temp min="0" max="100" value="72">72°C</meter><div data-status>运行中 · 温度 72°C</div><button data-action>接收高温遥测</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-temp]").value = 88; ui.q("[data-status]").textContent = "告警 · 温度 88°C · 建议停机检查"; ui.state("device:CNC-07;temperature:88;alarm:high-temp"); });
  ui.state("device:CNC-07;temperature:72;alarm:none");
}

export function renderAlarmRule(ctx) {
  const ui = mount(ctx, `<label>温度阈值 <input data-threshold type="number" value="80" aria-label="温度阈值"></label><label>持续秒数 <input data-duration type="number" value="30" aria-label="持续秒数"></label><label>当前温度 <input data-current type="number" value="88" aria-label="当前温度"></label><div data-result>待评估</div><button data-action>评估告警规则</button>`);
  ui.on("[data-action]", "click", () => { const threshold = Number(ui.q("[data-threshold]").value); const current = Number(ui.q("[data-current]").value); const triggered = current > threshold; ui.q("[data-result]").textContent = triggered ? `触发高温告警：${current} > ${threshold}，等待持续条件确认` : "未触发"; ui.state(`alarm-rule:${triggered ? "triggered" : "normal"};current:${current};threshold:${threshold};duration:${ui.q("[data-duration]").value}`); });
  ui.state("alarm-rule:pending");
}

export const businessRenderers = Object.freeze({
  "18:sku-editor": renderSkuEditor,
  "18:shopping-cart": renderShoppingCart,
  "18:checkout": renderCheckout,
  "18:order-tracker": renderOrderTracker,
  "18:stock-allocation": renderStockAllocation,
  "18:warehouse-map": renderWarehouseMap,
  "18:price-rule": renderPriceRule,
  "18:promotion-rule": renderPromotionRule,
  "18:contract-editor": renderContractEditor,
  "18:invoice-editor": renderInvoiceEditor,
  "18:voucher-entry": renderVoucherEntry,
  "18:account-tree": renderAccountTree,
  "18:shift-attendance": renderShiftAttendance,
  "18:payroll-sheet": renderPayrollSheet,
  "18:crm-relationship": renderCrmRelationship,
  "18:sales-funnel": renderSalesFunnel,
  "18:customer-profile": renderCustomerProfile,
  "18:ticket-workbench": renderTicketWorkbench,
  "18:call-center": renderCallCenter,
  "18:logistics-tracker": renderLogisticsTracker,
  "18:medical-record": renderMedicalRecord,
  "18:exam-editor": renderExamEditor,
  "18:question-bank": renderQuestionBank,
  "18:course-planner": renderCoursePlanner,
  "18:seat-picker": renderSeatPicker,
  "18:resource-booking": renderResourceBooking,
  "18:configurator": renderConfigurator,
  "18:bom-editor": renderBomEditor,
  "18:device-monitor": renderDeviceMonitor,
  "18:alarm-rule": renderAlarmRule,
});
export const renderers18 = businessRenderers;
export const renderers = renderers18;
