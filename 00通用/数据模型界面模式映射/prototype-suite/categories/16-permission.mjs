function mount(ctx, html) {
  ctx.stage.innerHTML = `<div class="prototype-demo">${html}<output class="prototype-state" data-demo-state aria-live="polite"></output></div>`;
  const q = (selector) => ctx.stage.querySelector(selector);
  const qa = (selector) => [...ctx.stage.querySelectorAll(selector)];
  const state = (value) => { q("[data-demo-state]").textContent = String(value); q("[data-demo-state]").dataset.state = String(value); ctx.setStatus(value, value); };
  const on = (selector, type, listener) => ctx.on(q(selector), type, listener);
  return { q, qa, state, on };
}

export function renderPermissionMatrix(ctx) {
  const ui = mount(ctx, `<table><thead><tr><th>资源</th><th>查看</th><th>编辑</th></tr></thead><tbody><tr><th>订单</th><td><input data-view type="checkbox" checked aria-label="订单查看权限"></td><td><input data-edit type="checkbox" aria-label="订单编辑权限"></td></tr></tbody></table><button data-action>授予订单编辑</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-edit]").checked = true; ui.state("matrix:orders:view+edit;changed:1"); });
  ui.state("matrix:orders:view;changed:0");
}

export function renderRolePermission(ctx) {
  const ui = mount(ctx, `<label>角色 <select data-role aria-label="角色"><option>销售专员</option></select></label><label><input data-grant type="checkbox" aria-label="导出客户权限"> 导出客户</label><div data-diff>无变更</div><button data-action>加入角色授权草稿</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-grant]").checked = true; ui.q("[data-diff]").textContent = "+ customer.export"; ui.state("role:sales;diff:+customer.export"); });
  ui.state("role:sales;diff:none");
}

export function renderMenuPermissionTree(ctx) {
  const ui = mount(ctx, `<ul><li><label><input data-parent type="checkbox" aria-label="销售管理菜单"> 销售管理</label><ul><li><label><input data-child type="checkbox" aria-label="订单菜单"> 订单</label></li><li><label><input data-child type="checkbox" aria-label="客户菜单"> 客户</label></li></ul></li></ul><button data-action>授予整个销售菜单</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-parent]").checked = true; ui.qa("[data-child]").forEach((node) => { node.checked = true; }); ui.state("menu-tree:sales:checked;descendants:2"); });
  ui.state("menu-tree:sales:unchecked;descendants:0");
}

export function renderDataPermission(ctx) {
  const ui = mount(ctx, `<label>数据范围 <select data-scope aria-label="数据范围"><option value="self">本人</option><option value="department">本部门</option></select></label><code data-filter>owner_id = current_user</code><button data-action>预览部门范围 SQL</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-scope]").value = "department"; ui.q("[data-filter]").textContent = "department_id IN current_department_tree"; ui.state("data-scope:department;rows:128"); });
  ui.state("data-scope:self;rows:18");
}

export function renderFieldPermission(ctx) {
  const ui = mount(ctx, `<table><tr><th>手机号</th><td data-phone>138****8899</td><td><select data-mode aria-label="手机号字段权限"><option value="masked">脱敏可见</option><option value="editable">可编辑</option></select></td></tr></table><button data-action>切换为可编辑字段</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-mode]").value = "editable"; const input = document.createElement("input"); input.value = "13800138899"; input.setAttribute("aria-label", "手机号"); ui.q("[data-phone]").replaceChildren(input); ui.state("field:phone:editable;masked:false"); });
  ui.state("field:phone:read;masked:true");
}

export function renderRowPolicy(ctx) {
  const ui = mount(ctx, `<label>订单金额 <input data-amount type="number" aria-label="订单金额" value="12000"></label><label>区域 <select data-region aria-label="区域"><option>华东</option><option>华南</option></select></label><div data-result>待评估</div><button data-action>评估行级策略</button>`);
  ui.on("[data-action]", "click", () => { const allowed = Number(ui.q("[data-amount]").value) <= 10000 && ui.q("[data-region]").value === "华东"; ui.q("[data-result]").textContent = allowed ? "允许查看" : "拒绝：金额超过区域经理阈值"; ui.state(`row-policy:${allowed ? "allow" : "deny"};rule:amount<=10000&&region=华东`); });
  ui.state("row-policy:pending");
}

export function renderOrgEditor(ctx) {
  const ui = mount(ctx, `<ul><li>总部<ul data-hq><li data-team>华东销售部</li><li data-target>华南事业部</li></ul></li></ul><button data-action>将华东销售部移动到华南事业部</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-target]").append(ui.q("[data-team]")); ui.state("org:华东销售部->华南事业部;depth:2"); });
  ui.state("org:华东销售部->总部;depth:1");
}

export function renderUserRole(ctx) {
  const ui = mount(ctx, `<div>用户：林晓</div><label><input data-role type="checkbox" aria-label="销售专员角色" checked> 销售专员</label><label><input data-role type="checkbox" aria-label="合同审批员角色"> 合同审批员</label><button data-action>增加合同审批员</button>`);
  ui.on("[data-action]", "click", () => { ui.qa("[data-role]")[1].checked = true; ui.state("user:林晓;roles:sales,contract-approver"); });
  ui.state("user:林晓;roles:sales");
}

export function renderDepartmentUser(ctx) {
  const ui = mount(ctx, `<div style="display:flex;gap:12px"><ul data-source><li data-user>周宁（未分配）</li></ul><ul data-target><li>客服一组：王蕾</li></ul></div><button data-action>分配周宁到客服一组</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-user]").textContent = "客服一组：周宁"; ui.q("[data-target]").append(ui.q("[data-user]")); ui.state("department:service-1;members:2;added:周宁"); });
  ui.state("department:service-1;members:1");
}

export function renderResourceGrant(ctx) {
  const ui = mount(ctx, `<div>资源：2026 年预算表</div><label>到期时间 <input data-expiry type="date" aria-label="授权到期时间" value="2026-07-31"></label><button data-action>签发临时授权</button><div data-token>未授权</div>`);
  ui.on("[data-action]", "click", () => { const expiry = ui.q("[data-expiry]").value; ui.q("[data-token]").textContent = `已授权给财务协作组，${expiry} 到期`; ui.state(`grant:active;resource:budget;expiry:${expiry}`); });
  ui.state("grant:none;resource:budget");
}

export function renderPermissionInheritance(ctx) {
  const ui = mount(ctx, `<div>总部策略：允许导出 <span data-inherited>→ 华东分公司（继承）</span></div><label><input data-override type="checkbox" aria-label="覆盖继承权限"> 本节点禁止导出</label><button data-action>创建覆盖规则</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-override]").checked = true; ui.q("[data-inherited]").textContent = "→ 华东分公司（已覆盖：禁止）"; ui.state("inheritance:override;effective:deny-export"); });
  ui.state("inheritance:inherited;effective:allow-export");
}

export function renderPermissionConflict(ctx) {
  const ui = mount(ctx, `<ul><li>销售专员：允许编辑客户</li><li>敏感数据策略：禁止编辑高风险客户</li></ul><div data-result>尚未分析</div><button data-action>检测用户“林晓”的冲突</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-result]").textContent = "发现 1 个冲突；显式拒绝优先，有效结果：禁止"; ui.state("conflict:1;winner:explicit-deny"); });
  ui.state("conflict:unchecked");
}

export function renderApproverPicker(ctx) {
  const ui = mount(ctx, `<label>审批金额 <input data-amount type="number" aria-label="审批金额" value="50000"></label><div data-person>候选：部门经理</div><button data-action>按规则选择审批人</button>`);
  ui.on("[data-action]", "click", () => { const amount = Number(ui.q("[data-amount]").value); const person = amount >= 30000 ? "财务总监 · 陈敏" : "部门经理 · 罗强"; ui.q("[data-person]").textContent = `已选：${person}`; ui.state(`approver:${amount >= 30000 ? "finance-director" : "manager"};amount:${amount}`); });
  ui.state("approver:unresolved");
}

export function renderConditionalGrant(ctx) {
  const ui = mount(ctx, `<label>条件字段 <select data-field aria-label="授权条件字段"><option>department</option></select></label><label>值 <input data-value aria-label="授权条件值" value="华东"></label><div data-preview>未生成</div><button data-action>生成条件授权</button>`);
  ui.on("[data-action]", "click", () => { const value = ui.q("[data-value]").value; ui.q("[data-preview]").textContent = `当 department = ${value} 时允许 customer.read`; ui.state(`conditional-grant:department=${value};effect:allow-read`); });
  ui.state("conditional-grant:empty");
}

export function renderTenantConfig(ctx) {
  const ui = mount(ctx, `<label>当前租户 <select data-tenant aria-label="当前租户"><option value="tenant-a">星河集团</option><option value="tenant-b">远山科技</option></select></label><div data-resource>数据源：db_tenant_a；主题：蓝色</div><button data-action>切换并加载远山租户配置</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-tenant]").value = "tenant-b"; ui.q("[data-resource]").textContent = "数据源：db_tenant_b；主题：绿色"; ui.state("tenant:tenant-b;isolation:db_tenant_b"); });
  ui.state("tenant:tenant-a;isolation:db_tenant_a");
}

export function renderDataScope(ctx) {
  const ui = mount(ctx, `<div>组织树：总部 / 华东 / 上海</div><label><input data-subtree type="checkbox" aria-label="包含下级组织"> 包含下级</label><div data-preview>可见：上海（42 条）</div><button data-action>预览华东及下级范围</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-subtree]").checked = true; ui.q("[data-preview]").textContent = "可见：华东、上海、杭州、南京（316 条）"; ui.state("data-range:华东+descendants;orgs:4;rows:316"); });
  ui.state("data-range:上海;orgs:1;rows:42");
}

export function renderPolicyEditor(ctx) {
  const ui = mount(ctx, `<ol data-policies><li data-policy="deny">优先级 10：拒绝外部网络下载</li><li data-policy="allow">优先级 20：允许财务角色下载</li></ol><button data-action>提高财务允许策略优先级</button>`);
  ui.on("[data-action]", "click", () => { const allow = ui.q('[data-policy="allow"]'); allow.textContent = "优先级 5：允许财务角色下载"; ui.q("[data-policies]").prepend(allow); ui.state("policy-order:allow-finance,deny-external;effective:allow-finance"); });
  ui.state("policy-order:deny-external,allow-finance;effective:deny");
}

export function renderAclEditor(ctx) {
  const ui = mount(ctx, `<ol data-acl><li data-entry="group">1. 协作组：读取</li><li data-entry="user">2. 用户林晓：编辑</li></ol><button data-action>将用户规则移到首位</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-acl]").prepend(ui.q('[data-entry="user"]')); ui.qa("[data-acl] li")[0].textContent = "1. 用户林晓：编辑"; ui.qa("[data-acl] li")[1].textContent = "2. 协作组：读取"; ui.state("acl-order:user-edit,group-read;effective:edit"); });
  ui.state("acl-order:group-read,user-edit;effective:read");
}

export function renderCredentialManager(ctx) {
  const ui = mount(ctx, `<div>API Key：sk_live_••••7A2C</div><div data-version>版本 v3 · 有效</div><button data-action>轮换凭证并撤销旧版本</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-version]").textContent = "版本 v4 · 有效；v3 · 已撤销"; ui.state("credential:v4:active;v3:revoked"); });
  ui.state("credential:v3:active");
}

export function renderAuditViewer(ctx) {
  const ui = mount(ctx, `<label>操作类型 <select data-type aria-label="审计操作类型"><option value="all">全部</option><option value="permission">权限变更</option></select></label><table><tbody data-rows><tr><td>登录</td><td>林晓</td></tr><tr><td>权限变更</td><td>管理员</td></tr></tbody></table><button data-action>筛选权限变更并展开证据</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-type]").value = "permission"; ui.q("[data-rows]").innerHTML = "<tr><td>权限变更</td><td>管理员</td><td>customer.export: deny → allow</td></tr>"; ui.state("audit:type:permission;events:1;detail:expanded"); });
  ui.state("audit:type:all;events:2");
}

export const permissionRenderers = Object.freeze({
  "16:permission-matrix": renderPermissionMatrix,
  "16:role-permission": renderRolePermission,
  "16:menu-permission-tree": renderMenuPermissionTree,
  "16:data-permission": renderDataPermission,
  "16:field-permission": renderFieldPermission,
  "16:row-policy": renderRowPolicy,
  "16:org-editor": renderOrgEditor,
  "16:user-role": renderUserRole,
  "16:department-user": renderDepartmentUser,
  "16:resource-grant": renderResourceGrant,
  "16:permission-inheritance": renderPermissionInheritance,
  "16:permission-conflict": renderPermissionConflict,
  "16:approver-picker": renderApproverPicker,
  "16:conditional-grant": renderConditionalGrant,
  "16:tenant-config": renderTenantConfig,
  "16:data-scope": renderDataScope,
  "16:policy-editor": renderPolicyEditor,
  "16:acl-editor": renderAclEditor,
  "16:credential-manager": renderCredentialManager,
  "16:audit-viewer": renderAuditViewer,
});
export const renderers16 = permissionRenderers;
export const renderers = renderers16;
