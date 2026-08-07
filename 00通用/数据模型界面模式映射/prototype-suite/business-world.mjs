export const enterprise = Object.freeze({
  name: "华辰工业设备集团",
  tenant: "HC-INDUSTRY",
  organizations: Object.freeze({ headquarters: "集团总部", east: "华东事业部", south: "华南事业部", sales: "上海销售部", factory: "苏州工厂", eastWarehouse: "华东仓", southWarehouse: "华南仓" }),
});

export const people = Object.freeze({
  sales: Object.freeze({ id: "U-101", name: "林晓", role: "销售代表" }),
  salesManager: Object.freeze({ id: "U-108", name: "周宁", role: "销售经理" }),
  finance: Object.freeze({ id: "U-203", name: "陈敏", role: "财务经理" }),
  warehouse: Object.freeze({ id: "U-306", name: "王蕾", role: "仓库主管" }),
  procurement: Object.freeze({ id: "U-407", name: "罗强", role: "采购经理" }),
  consultant: Object.freeze({ id: "U-512", name: "李明", role: "实施顾问" }),
  admin: Object.freeze({ id: "U-001", name: "赵峰", role: "系统管理员" }),
});

export const customers = Object.freeze({
  xinghe: Object.freeze({ id: "C-1008", name: "星河科技", creditAvailable: 160000, overdueReceivable: 42000 }),
  yuanshan: Object.freeze({ id: "C-1021", name: "远山零售", creditAvailable: 520000, overdueReceivable: 0 }),
  qinghe: Object.freeze({ id: "C-1036", name: "青禾制造", creditAvailable: 280000, overdueReceivable: 18000 }),
});

export const products = Object.freeze({
  gateway: Object.freeze({ id: "GW-X2", name: "工业网关 X2", eastAvailable: 8, southAvailable: 35, listPrice: 10000 }),
  controller: Object.freeze({ id: "EC-E5", name: "边缘控制器 E5", eastAvailable: 42, southAvailable: 16, listPrice: 6800 }),
  sensors: Object.freeze({ id: "SS-S1", name: "传感器套件 S1", eastAvailable: 120, southAvailable: 80, listPrice: 1200 }),
});

export const documents = Object.freeze({
  salesOrder: Object.freeze({ id: "SO-20260714-018", amount: 201000, requestedDiscount: 12, status: "审批中" }),
  purchaseRequest: Object.freeze({ id: "PR-20260714-006", status: "待采购经理审批" }),
  contract: Object.freeze({ id: "CT-2026-088", status: "法务复核中" }),
  invoice: Object.freeze({ id: "INV-2026-0714", status: "待开票" }),
  workOrder: Object.freeze({ id: "WO-2026-0418", status: "处理中", slaHours: 8 }),
});

export const warehouses = Object.freeze({
  east: Object.freeze({ id: "WH-EAST", name: "华东仓", gatewayAvailable: 8, gatewayReserved: 12 }),
  south: Object.freeze({ id: "WH-SOUTH", name: "华南仓", gatewayAvailable: 35, gatewayReserved: 6 }),
});

export const auditFacts = Object.freeze({
  correlationId: "TRACE-20260714-018",
  policyVersion: "POLICY-2026.07",
  dataVersion: 7,
});

export const worldFacts = Object.freeze({ currency: "CNY", orderAmount: 201000, requestedDiscount: 12, salesDiscountLimit: 8, creditAvailable: 160000, creditGap: 41000, eastGatewayAvailable: 8, southGatewayAvailable: 35, overdueReceivable: 42000 });

export function money(value) {
  return new Intl.NumberFormat("zh-CN", { style: "currency", currency: "CNY", maximumFractionDigits: 0 }).format(value);
}

export function appendLabeledValue(root, label, value, className = "business-field") {
  const field = document.createElement("div"); field.className = className;
  const caption = document.createElement("span"); caption.className = "business-label"; caption.textContent = label;
  const content = document.createElement("strong"); content.textContent = String(value);
  field.append(caption, content); root.append(field); return field;
}

export function appendTimelineItem(root, title, detail, state = "pending") {
  const item = document.createElement("div"); item.className = `business-timeline-item ${state}`;
  const heading = document.createElement("strong"); heading.textContent = title;
  const copy = document.createElement("span"); copy.textContent = detail;
  item.append(heading, copy); root.append(item); return item;
}

export function appendBusinessNotice(root, title, detail, tone = "decision") {
  const notice = document.createElement("section");
  notice.className = `business-notice business-${tone}`;
  const heading = document.createElement("strong"); heading.textContent = title;
  const copy = document.createElement("span"); copy.textContent = detail;
  notice.append(heading, copy); root.append(notice); return notice;
}

export function appendBusinessResult(root, title, detail, tone = "success") {
  const result = appendBusinessNotice(root, title, detail, tone);
  result.setAttribute("role", tone === "error" ? "alert" : "status");
  result.setAttribute("aria-live", tone === "error" ? "assertive" : "polite");
  return result;
}
