import { components } from "../catalog.mjs";

const componentNames = new Map(components.map(({ key, name }) => [key, name]));

const systemObjects = Object.freeze({
  "sku-editor": ["工业网关 X2", "颜色与通信制式", "SKU 主数据"],
  "shopping-cart": ["星河科技采购清单", "工业网关 X2", "库存与价格快照"],
  "checkout": ["销售订单 SO-20260714-018", "星河科技信用额度", "收款与履约任务"],
  "order-tracker": ["销售订单 SO-20260714-018", "华东仓发运单", "客户交付时间线"],
  "stock-allocation": ["80 台网关需求", "华东仓与华南仓库存", "调拨任务"],
  "warehouse-map": ["华东仓", "A-01 库位", "上架任务"],
  "price-rule": ["工业网关 X2", "星河科技合同价", "销售报价"],
  "promotion-rule": ["星河科技促销资格", "订单金额 201000 元", "优惠核销记录"],
  "contract-editor": ["合同 CT-2026-088", "里程碑条款", "法务审批任务"],
  "invoice-editor": ["发票 INV-2026-0714", "销售订单 SO-20260714-018", "应收账款"],
  "voucher-entry": ["记账凭证 VCH-20260714-009", "借贷分录", "总账期间"],
  "account-tree": ["科目 1002 银行存款", "会计科目层级", "凭证分录"],
  "shift-attendance": ["员工林晓", "7 月 16 日早班", "考勤异常单"],
  "payroll-sheet": ["员工林晓", "2026-07 薪资期间", "工资发放批次"],
  "crm-relationship": ["客户星河科技", "联系人陈敏", "商机 OPP-2026-031"],
  "sales-funnel": ["商机 OPP-2026-031", "方案阶段", "销售预测"],
  "customer-profile": ["客户星河科技", "订单与回款行为", "高价值客户分群"],
  "ticket-workbench": ["工单 TK-108", "客户星河科技", "SLA 计时器"],
  "call-center": ["呼叫会话 CALL-0714-08", "客户星河科技", "工单 TK-108"],
  "logistics-tracker": ["运单 SHP-20260714-12", "南京配送节点", "订单交付承诺"],
  "medical-record": ["员工职业健康档案 EHR-101", "体检记录", "签名与访问审计"],
  "exam-editor": ["设备安全考试 EXAM-026", "试题与分值", "发布批次"],
  "question-bank": ["设备安全题库", "数据库主题标签", "考试 EXAM-026"],
  "course-planner": ["网关实施培训", "讲师李明", "101 培训室"],
  "seat-picker": ["培训场次 TRN-0718", "座位 A3", "员工报名记录"],
  "resource-booking": ["会议室 A", "10:30-11:30 时段", "项目评审日程"],
  "configurator": ["边缘控制器 E5", "CPU 与 GPU 选件", "报价明细"],
  "bom-editor": ["边缘控制器 E5", "风扇与主板 BOM", "生产成本版本"],
  "device-monitor": ["设备 CNC-07", "温度遥测 88C", "高温维修工单"],
  "alarm-rule": ["CNC-07 温度指标", "80C 持续 30 秒规则", "告警与值班通知"],
});

const financeSystems = new Set(["contract-editor", "invoice-editor", "voucher-entry", "account-tree", "payroll-sheet"]);
const operationsSystems = new Set(["stock-allocation", "warehouse-map", "logistics-tracker", "bom-editor", "device-monitor", "alarm-rule"]);
const peopleSystems = new Set(["shift-attendance", "medical-record", "exam-editor", "question-bank", "course-planner", "seat-picker", "resource-booking"]);

function rolePair(id) {
  if (financeSystems.has(id)) return ["陈敏｜财务经理", "周宁｜业务审批人"];
  if (operationsSystems.has(id)) return ["王蕾｜仓库主管", "罗强｜采购经理"];
  if (peopleSystems.has(id)) return ["李明｜实施顾问", "赵峰｜系统管理员"];
  return ["林晓｜销售代表", "周宁｜销售经理"];
}

function metadata(componentId) {
  const category = componentId.slice(0, 2);
  const id = componentId.slice(3);
  const name = componentNames.get(componentId) || id;
  if (category === "15") {
    return {
      business: {
        level: "B", role: "林晓｜销售代表", task: `在不中断订单处理的前提下使用${name}定位下一项工作`,
        objects: [name, "销售订单 SO-20260714-018"],
        rule: "必须保留当前订单、工作区和未保存标记；无权访问的入口不得暴露",
        exception: "目标入口已失效、无访问权限或存在未保存订单时阻止静默跳转",
        effect: "保留销售上下文并把林晓带到可继续处理的订单任务",
      },
      readiness: {
        recovery: "返回销售工作区并恢复订单 SO-20260714-018 的导航上下文",
        keyboard: "Tab 定位导航控件，Enter 执行，Esc 返回当前工作区",
        riskCapabilities: ["navigation-context"],
      },
    };
  }
  if (category === "16") {
    return {
      business: {
        level: "B", role: "赵峰｜系统管理员", task: `在租户 HC-INDUSTRY 内核验并配置${name}`,
        objects: [name, "租户 HC-INDUSTRY", "策略 POLICY-2026.07"],
        rule: "授权必须限定租户、组织、资源和动作范围；显式拒绝优先且每次变更写入审计",
        exception: "越出租户或组织范围、策略冲突、审批缺失时拒绝保存并显示命中规则",
        effect: "更新有效权限范围，同时生成可追溯且可撤销的策略变更记录",
      },
      readiness: {
        recovery: "撤销未提交授权并恢复 POLICY-2026.07 的上一个有效版本",
        keyboard: "Tab 进入权限控件，Space 切换，Enter 应用，Esc 取消未提交变更",
        riskCapabilities: ["safety-audit", "scope-explanation", "deny-reason", "audit-trail"],
      },
    };
  }
  if (category === "17") {
    return {
      business: {
        level: "B", role: "周宁｜销售经理", task: `围绕订单 SO-20260714-018 使用${name}完成跨岗位协作`,
        objects: [name, "销售订单 SO-20260714-018", "TRACE-20260714-018"],
        rule: "消息、批注和协作编辑必须绑定对象版本；离线重放和重复提交不得产生重复业务动作",
        exception: "网络中断、对象版本冲突、通知对象无权访问时保留草稿并解释失败范围",
        effect: "把协作结果同步给相关岗位，并将发送、冲突和重试写入操作时间线",
      },
      readiness: {
        recovery: "拉取最新对象版本后合并草稿，只重放尚未确认的协作动作",
        keyboard: "Tab 到达编辑与操作控件，Enter 提交，Esc 关闭浮层并保留草稿",
        riskCapabilities: ["safety-audit", "conflict-resolution", "offline-replay", "duplicate-safety"],
      },
    };
  }

  const objects = systemObjects[id];
  const [operator, reviewer] = rolePair(id);
  const crossModuleRule = `${objects[0]}通过当前规则校验且${objects[1]}版本未变化后，才允许更新${objects[2]}`;
  const compensation = `撤销${name}的未完成事务，恢复${objects[1]}快照并取消尚未执行的${objects[2]}下游动作`;
  return {
    business: {
      level: "C", role: `${operator}；${reviewer}`, task: `协同完成${name}的校验、确认与下游交接`, objects,
      rule: crossModuleRule,
      exception: `${objects[1]}发生并发变化、约束冲突或审批拒绝时冻结下游动作并保留现场`,
      effect: `${objects[0]}的处理结果同步到${objects[2]}，并记录金额、库存、排期、权限或 SLA 影响`,
      responsibilities: [`${operator}：录入并提交业务事实`, `${reviewer}：复核规则、影响和例外`],
      crossModuleRule,
      timeline: [`${operator}载入${objects[0]}`, `系统校验${objects[1]}与关联约束`, `${reviewer}确认后更新${objects[2]}`],
      compensation,
    },
    readiness: {
      recovery: compensation,
      keyboard: "Tab 依序到达对象、校验和提交控件，Enter 执行，Esc 返回上一个可恢复状态",
      riskCapabilities: ["system-impact", "responsibility-boundary", "event-timeline", "compensation"],
    },
  };
}

function contract(componentId, changed, reset) {
  const { business, readiness } = metadata(componentId);
  const steps = [
    { action: "click", selector: "[data-readiness-start]", path: "primary" },
    { action: "click", selector: "[data-action]", path: "primary" },
    { action: "click", selector: "[data-readiness-exception]", path: "exception" },
    { action: "click", selector: "[data-readiness-exception]", path: "recovery" },
    { action: "click", selector: "[data-readiness-recovery]", path: "recovery" },
  ];
  return Object.freeze({
    componentId,
    componentKey: componentId,
    steps: Object.freeze(steps.map(Object.freeze)),
    observe: "#prototypeState",
    changed,
    reset,
    business: Object.freeze({ ...business, objects: Object.freeze(business.objects), responsibilities: business.responsibilities && Object.freeze(business.responsibilities), timeline: business.timeline && Object.freeze(business.timeline) }),
    readiness: Object.freeze({ ...readiness, states: Object.freeze(["initial", "primary", "exception", "recovered"]), riskCapabilities: Object.freeze(readiness.riskCapabilities) }),
  });
}

const definitions = [
  ["15:multi-level-menu", "menu:sales-expanded", "menu:collapsed"],
  ["15:dynamic-route-menu", "route:/orders/SO-2026-001", "route:/orders/:id"],
  ["15:permission-menu", "visible:2;role:admin", "visible:1;role:viewer"],
  ["15:mega-menu", "mega:group:supply;items:2", "mega:closed"],
  ["15:breadcrumb", "breadcrumb:/workspace/orders", "breadcrumb:/workspace/orders/detail"],
  ["15:tab-workspace", "tabs:active:order;dirty:true", "tabs:active:home;dirty:false"],
  ["15:command-palette", "command:create-sales-order:executed", "command:query:create-order"],
  ["15:global-search", "search:星河科技;groups:3;results:4", "search:idle"],
  ["15:recent-visits", "recent:restored:/customers/88", "recent:current:/workspace"],
  ["15:favorites", "favorite:true;resource:sales-report", "favorite:false;resource:sales-report"],
  ["15:quick-launcher", "launcher:opened:receipt", "launcher:idle"],
  ["15:stepper", "step:1;validation:name-required", "step:1;validation:pending"],
  ["15:guided-tour", "tour:step:2;target:export", "tour:step:1;target:filter"],
  ["15:anchor-toc", "anchor:metrics;scrollTop:420", "anchor:overview;scrollTop:0"],
  ["15:document-outline", "outline:expanded:implementation;headings:4", "outline:collapsed;headings:2"],
  ["15:context-menu", "context:open;x:80;y:4;target:SO-001", "context:closed"],
  ["15:configurable-toolbar", "toolbar:order:export,save;hidden:print", "toolbar:order:save,print,export;hidden:none"],
  ["15:ribbon", "ribbon:tab:data;commands:3", "ribbon:tab:home;commands:3"],
  ["15:shortcut-manager", "shortcut:Ctrl+S;conflict:save", "shortcut:unvalidated"],
  ["15:workspace-switcher", "workspace:service;layout:tickets", "workspace:sales;layout:funnel"],
  ["16:permission-matrix", "matrix:orders:view+edit;changed:1", "matrix:orders:view;changed:0"],
  ["16:role-permission", "role:sales;diff:+customer.export", "role:sales;diff:none"],
  ["16:menu-permission-tree", "menu-tree:sales:checked;descendants:2", "menu-tree:sales:unchecked;descendants:0"],
  ["16:data-permission", "data-scope:department;rows:128", "data-scope:self;rows:18"],
  ["16:field-permission", "field:phone:editable;masked:false", "field:phone:read;masked:true"],
  ["16:row-policy", "row-policy:deny;rule:amount<=10000&&region=华东", "row-policy:pending"],
  ["16:org-editor", "org:华东销售部->华南事业部;depth:2", "org:华东销售部->总部;depth:1"],
  ["16:user-role", "user:林晓;roles:sales,contract-approver", "user:林晓;roles:sales"],
  ["16:department-user", "department:service-1;members:2;added:周宁", "department:service-1;members:1"],
  ["16:resource-grant", "grant:active;resource:budget;expiry:2026-07-31", "grant:none;resource:budget"],
  ["16:permission-inheritance", "inheritance:override;effective:deny-export", "inheritance:inherited;effective:allow-export"],
  ["16:permission-conflict", "conflict:1;winner:explicit-deny", "conflict:unchecked"],
  ["16:approver-picker", "approver:finance-director;amount:50000", "approver:unresolved"],
  ["16:conditional-grant", "conditional-grant:department=华东;effect:allow-read", "conditional-grant:empty"],
  ["16:tenant-config", "tenant:tenant-b;isolation:db_tenant_b", "tenant:tenant-a;isolation:db_tenant_a"],
  ["16:data-scope", "data-range:华东+descendants;orgs:4;rows:316", "data-range:上海;orgs:1;rows:42"],
  ["16:policy-editor", "policy-order:allow-finance,deny-external;effective:allow-finance", "policy-order:deny-external,allow-finance;effective:deny"],
  ["16:acl-editor", "acl-order:user-edit,group-read;effective:edit", "acl-order:group-read,user-edit;effective:read"],
  ["16:credential-manager", "credential:v4:active;v3:revoked", "credential:v3:active"],
  ["16:audit-viewer", "audit:type:permission;events:1;detail:expanded", "audit:type:all;events:2"],
  ["17:instant-chat", "chat:sent;messages:2;text-length:28", "chat:connected;messages:1"],
  ["17:conversation-list", "conversation:sales;unread:0", "conversation:none;unread:3"],
  ["17:comments", "comment:resolved;open:0", "comment:open;open:1"],
  ["17:threaded-replies", "thread:replies:collapsed;count:2", "thread:replies:expanded;count:2"],
  ["17:document-annotation", "annotation:range-18-22;comments:1", "annotation:none;comments:0"],
  ["17:image-annotation", "image-annotation:x:68;y:42;count:1", "image-annotation:count:0"],
  ["17:mention-picker", "mention:user-102;notified:true", "mention:query:陈敏;candidates:2"],
  ["17:message-center", "message-center:archived:1;pending:1;all:5", "message-center:pending:2;all:5"],
  ["17:notification-center", "notifications:filter:unread;visible:1;unread:0", "notifications:filter:all;visible:2;unread:1"],
  ["17:online-presence", "presence:online:2;viewers:2", "presence:online:1;viewers:1"],
  ["17:collaborative-cursor", "cursor:user-102;x:180;y:80;revision:8", "cursor:user-102;x:20;y:20;revision:7"],
  ["17:collaborative-editing", "collab-doc:revision:12;editors:2;merged:true", "collab-doc:revision:11;editors:1"],
  ["17:conflict-resolver", "conflict:resolved;choice:remote;revision:13", "conflict:unresolved;versions:local,remote"],
  ["17:activity-timeline", "timeline:filter:status;events:1", "timeline:filter:all;events:3"],
  ["17:operation-log", "operation-log:event:update-order;detail:expanded", "operation-log:detail:collapsed"],
  ["17:audit-trail", "audit-chain:valid;events:3;broken:0", "audit-chain:unchecked;events:3"],
  ["17:ticket-conversation", "ticket:status:waiting-customer;messages:2", "ticket:status:processing;messages:1"],
  ["17:message-template", "template:rendered;variables:2;html:false", "template:draft;variables:2"],
  ["17:subscription-config", "subscription:event:stock-alert;channels:email,in-app", "subscription:event:stock-alert;channels:email"],
  ["17:offline-reconnect", "network:online;replayed:2;pending:0", "network:offline;pending:2"],
  ["18:sku-editor", "sku:generated:4;dimensions:2", "sku:generated:0;dimensions:2"],
  ["18:shopping-cart", "cart:qty:3;subtotal:360", "cart:qty:2;subtotal:240"],
  ["18:checkout", "checkout:discount:100;payable:920;ready:true", "checkout:discount:0;payable:1020;ready:false"],
  ["18:order-tracker", "order:status:shipped;event:shipment-created", "order:status:paid;event:none"],
  ["18:stock-allocation", "allocation:valid;east:50;south:30;demand:80", "allocation:pending;demand:80"],
  ["18:warehouse-map", "warehouse:bin:A-01;used:10;capacity:10;full:true", "warehouse:bin:A-01;used:8;capacity:10;full:false"],
  ["18:price-rule", "price:88;winner:contract;priority:10", "price:100;winner:none"],
  ["18:promotion-rule", "promotion:eligible;discount:50", "promotion:pending;discount:0"],
  ["18:contract-editor", "contract:milestones:3;ratio-total:100;valid:true", "contract:milestones:2;ratio-total:60;valid:false"],
  ["18:invoice-editor", "invoice:net:1000;tax:130.00;gross:1130.00", "invoice:uncomputed"],
  ["18:voucher-entry", "voucher:debit:1000;credit:900;balanced:false", "voucher:unchecked"],
  ["18:account-tree", "account:1002;expanded:true;children:2", "account:1002;expanded:false;children:0"],
  ["18:shift-attendance", "shift:conflict;employee:林晓", "shift:pending;employee:林晓"],
  ["18:payroll-sheet", "payroll:base:10000;bonus:2000;deduct:800;net:11200", "payroll:uncomputed"],
  ["18:crm-relationship", "crm:focus:opportunity;links:2;amount:800000", "crm:focus:customer;links:2"],
  ["18:sales-funnel", "funnel:deal:A;from:lead;to:proposal;lead:11;proposal:6", "funnel:deal:A;stage:lead;lead:12;proposal:5"],
  ["18:customer-profile", "customer:segment:high-value-active;score:92;risk:low", "customer:segment:unknown"],
  ["18:ticket-workbench", "ticket:TK-108;owner:王蕾;status:waiting;SLA:paused", "ticket:TK-108;owner:林晓;status:processing;SLA:35m"],
  ["18:call-center", "call:connected;customer:星河科技;recording:true", "call:ringing;customer:unknown"],
  ["18:logistics-tracker", "logistics:status:delivering;events:4;location:南京", "logistics:status:in-transit;events:3;location:苏州"],
  ["18:medical-record", "record:version:2;signed:true;editable:false", "record:version:1;signed:false;editable:true"],
  ["18:exam-editor", "exam:questions:3;total:30", "exam:questions:2;total:15"],
  ["18:question-bank", "question-bank:topic:database;visible:2;selected:2", "question-bank:topic:all;visible:3;selected:0"],
  ["18:course-planner", "course:conflict;room:101;time:09:00", "course:pending"],
  ["18:seat-picker", "seat:A3;status:selected;price:80", "seat:none;available:3;sold:1"],
  ["18:resource-booking", "booking:conflict;resource:room-A;start:10:30;end:11:30", "booking:unchecked;resource:room-A"],
  ["18:configurator", "config:cpu:pro;gpu:true;compatible:true;price:7800", "config:cpu:standard;gpu:false;compatible:true;price:5000"],
  ["18:bom-editor", "bom:parts:3;fan-qty:2;cost:1960", "bom:parts:2;cost:1800"],
  ["18:device-monitor", "device:CNC-07;temperature:88;alarm:high-temp", "device:CNC-07;temperature:72;alarm:none"],
  ["18:alarm-rule", "alarm-rule:triggered;current:88;threshold:80;duration:30", "alarm-rule:pending"],
];

export const enterpriseInteractionContracts = Object.freeze(Object.fromEntries(
  definitions.map(([componentId, changed, reset, steps]) => [componentId, contract(componentId, changed, reset, steps)]),
));

export default enterpriseInteractionContracts;
