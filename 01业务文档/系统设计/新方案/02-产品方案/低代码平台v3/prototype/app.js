import {
  applySchemaTransaction,
  createDesignerState,
  endSchemaTransaction,
  redo,
  selectField,
  setBusinessState,
  setDevice,
  switchWorkspace,
  undo,
  validateForPublish,
} from './designer-state.mjs?v=20260711-4';
import {
  COMPONENT_CATEGORIES,
  COMPONENT_MANIFESTS,
  filterComponents,
} from './component-registry.mjs?v=20260711-4';
import { insertMaterial, moveNode, removeNode, duplicateNode, validateSchema } from './schema-engine.mjs?v=20260711-4';
import { DESIGNER_STORAGE_KEY, WORKSPACE_STORAGE_KEY, decodeDesignerSnapshot, encodeDesignerSnapshot, decodeWorkspaceSnapshot, encodeWorkspaceSnapshot, createWorkspaceSnapshotValue } from './designer-storage.mjs?v=20260712-3';
import { readFieldProperties, updateFieldProperty } from './designer-properties.mjs?v=20260712-1';
import { projectFieldRenderer, rendererStyleAttribute } from './renderer-projection.mjs?v=20260711-1';
import { createSalesOrderDesignerSchema } from './header-schema.mjs?v=20260712-1';
import { buildComponentPrototypeCatalog } from './component-prototype-model.mjs?v=20260712-1';
import { renderComponentPrototype } from './component-renderer.mjs?v=20260712-1';
import { renderInteractiveComponent } from './component-runtime-renderer.mjs?v=20260712-3';
import { createComponentRuntimeState, executeComponentRuntimeAction } from './component-runtime-state.mjs?v=20260712-2';
import { runtimeActionEventName, runtimeActionPayload } from './component-runtime-events.mjs?v=20260712-1';
import { filterResourceItems } from './resource-search.mjs?v=20260712-1';
import { createCommandState, executeDesignerCommand, visibleRules } from './designer-commands.mjs?v=20260712-1';
import { DEFAULT_ENTRY_COLUMNS, createEntryView, updateColumnVisibility } from './entry-runtime-view.mjs?v=20260712-2';
import { createBusinessModelState, selectBusinessObject, addBusinessObject, addBusinessField, updateBusinessField, removeBusinessField, addBusinessRelation, addBusinessIndex, selectedBusinessObject } from './business-model-state.mjs?v=20260712-2';
import { createRuleBuilderState, executeRuleBuilderCommand, selectedRule, analyzeRuleDependencies } from './rule-builder-state.mjs?v=20260712-2';
import { createPermissionMatrixState, selectRole, addRole, updateFieldPolicy, updateOperationPolicy, permissionCoverage } from './permission-matrix-state.mjs?v=20260712-2';

const initialSchema = createSalesOrderDesignerSchema();

let state = createDesignerState({ schema: initialSchema });
try {
  const saved = localStorage.getItem(DESIGNER_STORAGE_KEY);
  if (saved) {
    const snapshot = decodeDesignerSnapshot(saved);
    state = createDesignerState({
      schema: snapshot.schema,
      device: snapshot.device,
      businessState: snapshot.businessState,
      statusMessage: '已恢复本地草稿',
    });
  }
} catch {
  localStorage.removeItem(DESIGNER_STORAGE_KEY);
}
let resourceTab = 'components';
let componentCategory = '';
let componentQuery = '';
let resourceQuery = '';
let inspectorTab = 'property';
let analysisTab = 'findings';
let zoom = 90;
let nodeSequence = 1;
let dropPosition = 'inside';
let componentStudioQuery = '';
let selectedComponentType = 'EntryGrid';
let componentStudioState = 'design';
const componentRuntimeStates = new Map();
const previewNodeRuntimeStates = new Map();
let commandState = createCommandState({
  rules: [
    { id: 'R-001', title: '客户变更带出信用信息', kind: 'ui', enabled: true },
    { id: 'R-002', title: '分录金额自动汇总', kind: 'business', enabled: true },
    { id: 'R-003', title: '超信用额度提示', kind: 'business', enabled: false },
    { id: 'R-004', title: '空客户阻止提交', kind: 'ui', enabled: true },
  ],
  entryRows: [
    { id: 'ROW-1', values: { materialCode: 'MAT-10021', materialName: '工业采集网关 Pro', qty: 20, unit: '台', taxPrice: 3280, amount: 65600, deliveryDate: '2026-07-18' } },
    { id: 'ROW-2', values: { materialCode: 'MAT-20408', materialName: '边缘计算模块', qty: 12, unit: '个', taxPrice: 4920, amount: 59040, deliveryDate: '2026-07-22' } },
    { id: 'ROW-3', values: { materialCode: 'SRV-00007', materialName: '实施服务', qty: 1, unit: '项', taxPrice: 4000, amount: 4000, deliveryDate: '2026-07-15' } },
  ],
});
let entryColumns = DEFAULT_ENTRY_COLUMNS.map((column) => ({ ...column }));
let businessModelState = createBusinessModelState();
let ruleBuilderState = createRuleBuilderState({ rules: commandState.rules.map((rule) => ({
  ...rule,
  trigger: { event: 'change', source: rule.kind === 'business' ? 'amount' : 'customer' },
  conditionGroup: { id: 'root', logic: 'all', conditions: [] },
  actions: [],
})) });
let permissionMatrixState = createPermissionMatrixState();
let previewData = {};
let previewSample = 'standard';
let previewDevice = 'desktop';
try {
  const savedWorkspaces = localStorage.getItem(WORKSPACE_STORAGE_KEY);
  if (savedWorkspaces) {
    const snapshot = decodeWorkspaceSnapshot(savedWorkspaces);
    businessModelState = snapshot.businessModelState || businessModelState;
    ruleBuilderState = snapshot.ruleBuilderState || ruleBuilderState;
    permissionMatrixState = snapshot.permissionMatrixState || permissionMatrixState;
    previewData = snapshot.previewData || previewData;
    previewSample = snapshot.previewSample || previewSample;
    previewDevice = snapshot.previewDevice || previewDevice;
    commandState = snapshot.commandState || commandState;
    entryColumns = snapshot.entryColumns || entryColumns;
    selectedComponentType = snapshot.selectedComponentType || selectedComponentType;
    for (const [type, runtimeState] of snapshot.componentRuntimeStates || []) componentRuntimeStates.set(type, runtimeState);
  }
} catch {
  localStorage.removeItem(WORKSPACE_STORAGE_KEY);
}
const componentPrototypeCatalog = buildComponentPrototypeCatalog(COMPONENT_MANIFESTS);

const root = document.querySelector('[data-testid="designer-root"]');
const resourceContent = document.querySelector('[data-testid="resource-content"]');
const resourceTitle = document.querySelector('[data-testid="resource-title"]');
const resourceSubtitle = document.querySelector('[data-testid="resource-subtitle"]');
const inspectorBody = document.querySelector('[data-testid="inspector-body"]');
const analysisBody = document.querySelector('[data-testid="analysis-body"]');
const previewDialog = document.querySelector('[data-dialog="preview"]');
const publishDialog = document.querySelector('[data-dialog="publish"]');

function workspaceSnapshotValue() {
  return createWorkspaceSnapshotValue({ businessModelState, ruleBuilderState, permissionMatrixState, commandState, entryColumns, selectedComponentType, componentRuntimeStates, previewData, previewSample, previewDevice });
}

function saveDesignerWorkspace() {
  localStorage.setItem(DESIGNER_STORAGE_KEY, encodeDesignerSnapshot(state));
  localStorage.setItem(WORKSPACE_STORAGE_KEY, encodeWorkspaceSnapshot(workspaceSnapshotValue()));
}

const WORKSPACE_META = {
  model: ['业务对象', '实体、字段、关系与索引'],
  page: ['页面资源', '组件、字段与页面结构'],
  components: ['组件目录', '逐组件设计、状态与运行原型'],
  rules: ['规则编排', '界面规则与业务规则'],
  permissions: ['权限设计', '角色、字段与操作权限'],
  preview: ['运行预览', '角色、数据与设备环境'],
};

function resourceMarkup() {
  if (state.activeWorkspace === 'components') return componentStudioResourceMarkup();
  if (state.activeWorkspace === 'model') {
    const objects = filterResourceItems(businessModelState.objects.map((object) => ({ ...object, title: object.name, terms: object.fields.flatMap((field) => [field.id, field.name, field.type]) })), resourceQuery);
    return `
      <label class="search-box"><span>⌕</span><input type="search" value="${resourceQuery}" placeholder="搜索业务对象或字段" data-workspace-search></label>
      <div class="object-list">
        ${objects.map((object) => objectRow(object.name, object.id, `${object.fields.length} 字段`, object.id === businessModelState.selectedObjectId, `data-business-object="${object.id}"`)).join('') || '<div class="editor-empty">没有匹配的业务对象或字段</div>'}
      </div>
      <button class="button secondary panel-create" type="button" data-model-action="add-object">＋ 新建业务对象</button>
      <div class="resource-group"><button type="button"><span>销售订单字段</span><span>⌃</span></button>
        <div class="tree-list">
          ${treeRow('Aa', '订单编码', '文本 · 唯一', 'orderNo', 1)}
          ${treeRow('客', '客户', '基础资料', 'customer', 1, true)}
          ${treeRow('日', '订单日期', '日期', 'orderDate', 1)}
          ${treeRow('组', '销售组织', '组织', 'salesOrg', 1)}
          ${treeRow('¥', '含税金额', '金额 · 计算', 'amount', 1)}
        </div>
      </div>`;
  }

  if (state.activeWorkspace === 'rules') {
    const rules = filterResourceItems(ruleBuilderState.rules.filter((rule) => commandState.ruleFilter === 'all' || rule.kind === commandState.ruleFilter).map((rule) => ({ ...rule, title: rule.title, terms: [rule.kind, rule.trigger?.event, rule.trigger?.source, ...rule.actions.flatMap((action) => [action.type, action.target])] })), resourceQuery);
    return `
      <div class="resource-tabs"><button class="resource-tab ${commandState.ruleFilter === 'all' ? 'active' : ''}" data-rule-filter="all">全部规则</button><button class="resource-tab ${commandState.ruleFilter === 'ui' ? 'active' : ''}" data-rule-filter="ui">界面</button><button class="resource-tab ${commandState.ruleFilter === 'business' ? 'active' : ''}" data-rule-filter="business">业务</button></div>
      <label class="search-box"><span>⌕</span><input type="search" value="${resourceQuery}" placeholder="搜索规则、字段或动作" data-workspace-search></label>
      <div class="rule-list">
        ${rules.map((rule) => ruleRow(rule.id, rule.title, rule.kind === 'ui' ? '界面规则' : '业务规则', rule.enabled)).join('') || '<div class="editor-empty">没有匹配的规则</div>'}
      </div>
      <button class="button secondary panel-create" type="button" data-action="add-rule">＋ 新建规则</button>`;
  }

  if (state.activeWorkspace === 'permissions') {
    const roles = filterResourceItems(permissionMatrixState.roles.map((role) => ({ ...role, title: role.name, terms: Object.keys(permissionMatrixState.fieldPolicies[role.id] || {}) })), resourceQuery);
    return `
      <label class="search-box"><span>⌕</span><input type="search" value="${resourceQuery}" placeholder="搜索角色或权限项" data-workspace-search></label>
      <div class="object-list">
        ${roles.map((role) => objectRow(role.name, role.id, Object.keys(permissionMatrixState.fieldPolicies[role.id] || {}).length ? '已配置' : '待配置', role.id === permissionMatrixState.selectedRoleId, `data-permission-role="${role.id}"`)).join('') || '<div class="editor-empty">没有匹配的角色或权限项</div>'}
      </div>
      <div class="resource-group"><button type="button"><span>权限覆盖摘要</span><span>⌃</span></button>
        <div class="property-content">
          <div class="metric"><strong>18</strong><span>字段权限</span></div>
          <div class="metric"><strong>6</strong><span>操作权限</span></div>
          <div class="risk-note">1 个字段缺少导出权限策略，发布准备将被阻断。</div>
        </div>
      </div>`;
  }

  if (state.activeWorkspace === 'preview') {
    return `
      <div class="property-content">
        <label class="property-row"><span>模拟角色</span><select class="property-select" data-resource-role><option>销售主管</option><option>销售专员</option><option>财务审核员</option></select></label>
        <label class="property-row"><span>数据样本</span><select class="property-select" data-preview-sample><option value="standard">销售订单示例 01</option><option value="empty">空数据</option><option value="long">极限长文本</option></select></label>
        <label class="property-row"><span>设备</span><select class="property-select" data-preview-device><option value="desktop">桌面 1440</option><option value="wide">桌面 1920</option><option value="tablet">平板 1024</option></select></label>
        <button class="button primary" type="button" data-action="preview">打开运行预览</button>
        <div class="risk-note">预览使用草稿 Schema 和模拟权限，不写入生产数据。</div>
      </div>`;
  }

  return `
    <div class="resource-tabs">
      <button class="resource-tab ${resourceTab === 'components' ? 'active' : ''}" data-resource-tab="components">组件</button>
      <button class="resource-tab ${resourceTab === 'fields' ? 'active' : ''}" data-resource-tab="fields">字段</button>
      <button class="resource-tab ${resourceTab === 'outline' ? 'active' : ''}" data-resource-tab="outline">大纲</button>
    </div>
    ${resourceTab === 'components' ? '' : `<label class="search-box"><span>⌕</span><input type="search" value="${resourceQuery}" placeholder="搜索字段或节点" data-resource-search></label>`}
    ${pageResourceBody()}`;
}

function componentStudioResourceMarkup() {
  const query = componentStudioQuery.trim().toLocaleLowerCase('zh-CN');
  const items = componentPrototypeCatalog.filter((item) => !query || [item.title, item.componentType, item.rendererKind].some((value) => value.toLocaleLowerCase('zh-CN').includes(query)));
  return `<div class="component-studio-resource">
    <label class="search-box"><span>⌕</span><input type="search" value="${componentStudioQuery}" placeholder="搜索组件或 Renderer" data-component-studio-search></label>
    <div class="palette-summary"><span><strong>${items.length}</strong> / ${componentPrototypeCatalog.length} 个原型案例</span></div>
    <div class="component-case-list" data-scroll-owner="component-case-list" data-scroll-axes="y">${items.map((item) => `<button type="button" class="component-case-row ${selectedComponentType === item.componentType ? 'active' : ''}" data-component-case="${item.componentType}"><span class="resource-icon">${item.title.slice(0, 1)}</span><span><strong>${item.title}</strong><small data-allow-truncation="true" title="${item.componentType} · ${item.rendererKind}">${item.componentType} · ${item.rendererKind}</small></span></button>`).join('')}</div>
  </div>`;
}

function componentStudioMarkup() {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === selectedComponentType) || COMPONENT_MANIFESTS[0];
  const model = componentPrototypeCatalog.find((item) => item.componentType === manifest.type);
  const states = [['design', '设计态'], ['configure', '配置态'], ['preview', '预览态'], ['runtime', '运行态'], ['failure', '异常态'], ['permission', '权限态']];
  return `<div class="component-studio-shell" data-component-case="${model.prototypeCaseId}">
    <header class="component-studio-header"><div><span class="studio-eyebrow">组件原型案例</span><h2>${manifest.title}</h2><p>${manifest.type} · ${model.rendererKind} · ${manifest.status}</p></div><span class="mini-badge ${manifest.status === 'planned' ? '' : 'on'}">${manifest.status === 'planned' ? '规划中' : '可设计'}</span></header>
    <div class="component-state-switcher" role="tablist" aria-label="组件状态">${states.map(([id, label]) => `<button type="button" class="segmented ${componentStudioState === id ? 'active' : ''}" data-component-state="${id}">${label}</button>`).join('')}</div>
    <div class="component-prototype-stage">${renderInteractiveComponent(manifest, componentStudioState, runtimeStateFor(manifest))}</div>
    <div class="component-contract-grid">
      <section><h3>属性组</h3><div class="contract-tags">${model.propertyGroups.map((item) => `<span>${item}</span>`).join('')}</div></section>
      <section><h3>结构与插槽</h3><div class="contract-tags">${model.structure.map((item) => `<span>${item}</span>`).join('')}</div></section>
      <section><h3>适用边界</h3><p>页面：${model.pageTypes.join(' / ')}</p><p>设备：${model.devices.join(' / ')}</p><p>绑定：${model.bindingKind}</p></section>
      <section><h3>父级约束</h3><p>${model.requiresParent.length ? model.requiresParent.join(' / ') : '无父级依赖'}</p><p>案例：${model.prototypeCaseId}</p></section>
    </div>
  </div>`;
}

function componentInspectorMarkup() {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === selectedComponentType) || COMPONENT_MANIFESTS[0];
  const model = componentPrototypeCatalog.find((item) => item.componentType === manifest.type);
  const current = runtimeStateFor(manifest);
  return `${propertySection('组件属性', renderInteractiveComponent(manifest, 'configure', current))}
    ${propertySection('能力合同', `<div class="property-content"><div class="binding-status"><strong>${model.rendererKind}</strong><span>${model.bindingKind} · ${manifest.status}</span></div><div class="contract-tags">${model.propertyGroups.map((item) => `<span>${item}</span>`).join('')}</div></div>`)}
    ${propertySection('结构与适用范围', `<div class="property-content"><p>结构：${model.structure.join(' / ')}</p><p>页面：${model.pageTypes.join(' / ')}</p><p>设备：${model.devices.join(' / ')}</p><p>父级：${model.requiresParent.join(' / ') || '无'}</p></div>`)}`;
}

function businessModelEditorMarkup() {
  const object = selectedBusinessObject(businessModelState);
  if (!object) return '<div class="editor-empty">请选择业务对象</div>';
  return `<header class="workspace-editor-header"><div><h2>${object.name}</h2><p>${object.id} · ${object.fields.length} 字段 · ${object.relations.length} 关系 · ${object.indexes.length} 索引</p></div><div class="editor-toolbar"><button type="button" data-model-action="add-field">新增字段</button><button type="button" data-model-action="add-relation">新增一对多关系</button><button type="button" data-model-action="add-index">新增索引</button></div></header><div class="workspace-editor-body"><section><table class="editor-table"><thead><tr><th>字段编码</th><th>名称</th><th>类型</th><th>页面引用</th><th></th></tr></thead><tbody>${object.fields.map((field) => `<tr><td>${field.id}</td><td><input data-model-field-name="${field.id}" value="${field.name}"></td><td><select data-model-field-type="${field.id}"><option>${field.type}</option><option>text</option><option>decimal</option><option>reference</option><option>date</option></select></td><td>${field.referencedByPage ? '已引用' : '未引用'}</td><td><button type="button" data-model-action="remove-field" data-field-id="${field.id}">删除</button></td></tr>`).join('')}</tbody></table></section><section class="editor-section"><h3>实体关系</h3>${object.relations.length ? object.relations.map((relation) => `<p>${relation.kind} → ${relation.targetId}</p>`).join('') : '<span>尚未配置关系</span>'}</section><section class="editor-section"><h3>索引</h3>${object.indexes.length ? object.indexes.map((index) => `<p>${index.id} · ${index.fieldId}${index.unique ? ' · 唯一' : ''}</p>`).join('') : '<span>尚未配置索引</span>'}</section>${businessModelState.message ? `<div class="risk-note">${businessModelState.message}</div>` : ''}</div>`;
}

function ruleEditorMarkup() {
  const rule = selectedRule(ruleBuilderState);
  if (!rule) return '<div class="editor-empty">请选择或新建规则</div>';
  const conditions = rule.conditionGroup.conditions.filter((item) => !item.conditions);
  return `<header class="workspace-editor-header"><div><h2>${rule.title}</h2><p>${rule.id} · ${rule.kind === 'ui' ? '界面规则' : '业务规则'}</p></div><div class="editor-toolbar"><button type="button" data-rule-action="add-condition">添加条件</button><button type="button" data-rule-action="add-action">添加动作</button><button type="button" data-rule-action="duplicate-rule">复制规则</button><button type="button" data-rule-action="run-rule">运行样本</button></div></header><div class="workspace-editor-body"><section class="editor-form"><label>触发事件<select data-rule-trigger="event"><option>${rule.trigger.event}</option><option>change</option><option>blur</option><option>submit</option></select></label><label>触发字段<input data-rule-trigger="source" value="${rule.trigger.source}"></label><label>样本客户<input data-rule-sample="customer" value="${ruleBuilderState.sampleData.customer || ''}"></label></section><section class="editor-section"><h3>条件（全部满足）</h3>${conditions.length ? `<table class="editor-table"><tbody>${conditions.map((condition) => `<tr><td>${condition.field}</td><td>${condition.operator}</td><td>${condition.value ?? ''}</td></tr>`).join('')}</tbody></table>` : '<div class="editor-empty">没有条件，规则总是匹配</div>'}</section><section class="editor-section"><h3>动作</h3>${rule.actions.length ? `<table class="editor-table"><tbody>${rule.actions.map((action) => `<tr><td>${action.type}</td><td>${action.target}</td><td>${action.value ?? ''}</td></tr>`).join('')}</tbody></table>` : '<div class="editor-empty">尚未配置动作</div>'}</section>${ruleBuilderState.lastRun ? `<div class="risk-note">运行结果：${ruleBuilderState.lastRun.status}；效果：${JSON.stringify(ruleBuilderState.lastRun.effects)}</div>` : ''}</div>`;
}

function permissionEditorMarkup() {
  const roleId = permissionMatrixState.selectedRoleId;
  const role = permissionMatrixState.roles.find((item) => item.id === roleId);
  const fields = ['customer', 'amount'];
  const labels = { customer: '客户', amount: '含税金额' };
  return `<header class="workspace-editor-header"><div><h2>${role?.name || '角色权限'}</h2><p>${roleId} · 字段、操作与导出权限</p></div><div class="editor-toolbar"><button type="button" data-permission-action="add-role">新增角色</button></div></header><div class="workspace-editor-body"><section><table class="editor-table"><thead><tr><th>字段</th><th>可见</th><th>可编辑</th><th>可导出</th><th>脱敏</th></tr></thead><tbody>${fields.map((fieldId) => { const policy = permissionMatrixState.fieldPolicies[roleId]?.[fieldId] || {}; return `<tr><td>${labels[fieldId]}</td>${['visible','edit','export','mask'].map((key) => `<td><input type="checkbox" data-permission-field="${fieldId}" data-permission-key="${key}" ${policy[key] ? 'checked' : ''}></td>`).join('')}</tr>`; }).join('')}</tbody></table></section><section class="editor-section"><h3>操作权限</h3><div class="editor-toolbar">${['save','submit','export'].map((operationId) => `<label><input type="checkbox" data-permission-operation="${operationId}" ${permissionMatrixState.operationPolicies[roleId]?.[operationId] ? 'checked' : ''}> ${operationId}</label>`).join('')}</div></section>${permissionMatrixState.message ? `<div class="risk-note">${permissionMatrixState.message}</div>` : ''}</div>`;
}

function workspaceEditorMarkup() {
  if (state.activeWorkspace === 'model') return businessModelEditorMarkup();
  if (state.activeWorkspace === 'rules') return ruleEditorMarkup();
  if (state.activeWorkspace === 'permissions') return permissionEditorMarkup();
  return '';
}

function runtimeStateFor(manifest) {
  if (!componentRuntimeStates.has(manifest.type)) componentRuntimeStates.set(manifest.type, createComponentRuntimeState(manifest));
  return componentRuntimeStates.get(manifest.type);
}

function updateComponentRuntime(action, payload = {}) {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === selectedComponentType);
  if (!manifest) return;
  const current = runtimeStateFor(manifest);
  const next = executeComponentRuntimeAction(current, action, payload);
  if (next !== current) componentRuntimeStates.set(manifest.type, next);
  render();
}

function pageResourceBody() {
  if (resourceTab === 'fields') {
    const fields = filterResourceItems([
      { id: 'orderNo', title: '订单编码', icon: 'Aa', meta: '文本 · 已使用' },
      { id: 'customer', title: '客户', icon: '客', meta: '基础资料 · 已使用' },
      { id: 'orderDate', title: '订单日期', icon: '日', meta: '日期 · 已使用' },
      { id: 'salesOrg', title: '销售组织', icon: '组', meta: '组织 · 已使用' },
      { id: 'amount', title: '含税金额', icon: '¥', meta: '金额 · 已使用' },
      { id: 'creditLimit', title: '信用额度', icon: '#', meta: '金额 · 未使用' },
      { id: 'address', title: '收货地址', icon: '地', meta: '地址 · 未使用' },
    ].map((field) => ({ ...field, terms: [field.meta] })), resourceQuery);
    return `<div class="tree-list">
      ${fields.map((field) => treeRow(field.icon, field.title, field.meta, field.id, 0, field.id === state.selectedNodeId)).join('') || '<div class="editor-empty">没有匹配的字段</div>'}
    </div>`;
  }
  if (resourceTab === 'outline') {
    if (!resourceQuery) return `<div class="tree-list">${schemaOutlineMarkup(state.schema.nodes[state.schema.rootId])}</div>`;
    const matches = filterResourceItems(Object.values(state.schema.nodes).map((node) => ({ id: node.id, title: node.props?.title || node.type, terms: [node.type] })), resourceQuery);
    return `<div class="tree-list">${matches.map((item) => treeRow('节', item.title, state.schema.nodes[item.id].type, item.id, 0, item.id === state.selectedNodeId)).join('') || '<div class="editor-empty">没有匹配的页面节点</div>'}</div>`;
  }
  return componentPaletteMarkup();
}

function schemaOutlineMarkup(node, depth = 0) {
  if (!node) return '';
  const manifest = COMPONENT_MANIFESTS.find((component) => component.type === node.type);
  const title = node.props?.title || manifest?.title || node.type;
  return `${treeRow(manifest?.icon || '节', title, node.type, node.id, depth, node.id === state.selectedNodeId)}${(node.children || [])
    .map((id) => schemaOutlineMarkup(state.schema.nodes[id], depth + 1)).join('')}`;
}

function componentPaletteMarkup() {
  const context = { query: componentQuery, category: componentCategory, pageType: 'bill', device: state.device, ancestorTypes: selectedSchemaTypes() };
  const results = filterComponents(context);
  const categories = componentCategory
    ? COMPONENT_CATEGORIES.filter(({ id }) => id === componentCategory)
    : COMPONENT_CATEGORIES;
  const groups = categories.map((category) => {
    const items = results.filter((component) => component.category === category.id);
    if (!items.length) return '';
    return `<section class="palette-group" data-component-group="${category.id}">
      <header><strong>${category.title}</strong><span>${items.length}</span></header>
      <div class="palette-grid">${items.map(componentCardMarkup).join('')}</div>
    </section>`;
  }).join('');
  return `<div class="component-palette" data-testid="component-palette">
    <div class="palette-tools">
      <label class="search-box palette-search"><span>⌕</span><input type="search" value="${componentQuery}" placeholder="搜索名称、别名或协议" data-component-search></label>
      <div class="palette-summary"><span><strong data-testid="component-count">${results.length}</strong> / ${COMPONENT_MANIFESTS.length} 个组件</span><span>拖到画布使用</span></div>
      <div class="category-filter" aria-label="组件分类" data-scroll-owner="category-filter" data-scroll-axes="x">
        <button type="button" class="category-chip ${componentCategory === '' ? 'active' : ''}" data-component-category="">全部</button>
        ${COMPONENT_CATEGORIES.map(({ id, title }) => `<button type="button" class="category-chip ${componentCategory === id ? 'active' : ''}" data-component-category="${id}">${title}</button>`).join('')}
      </div>
    </div>
    <div class="palette-results" data-scroll-owner="palette-results" data-scroll-axes="y">${groups || '<div class="palette-empty"><strong>没有匹配组件</strong><span>换一个关键词或分类。</span></div>'}</div>
  </div>`;
}

function selectedSchemaTypes() {
  const types = [];
  let node = state.schema?.nodes[state.selectedNodeId];
  while (node) {
    types.push(node.type);
    node = node.parentId ? state.schema.nodes[node.parentId] : null;
  }
  return types;
}

function componentCardMarkup(component) {
  const enabled = component.availability.enabled;
  const maturity = component.status === 'ready' ? '' : `<span class="maturity ${component.status}">${component.status === 'preview' ? '预览' : '规划'}</span>`;
  const reason = enabled ? `${component.type} · 拖放到画布` : component.availability.reason;
  return `<button class="palette-card ${enabled ? '' : 'disabled'}" type="button"
    draggable="true" data-component-type="${component.type}" data-add-component="${component.title}" data-keyboard-add
    aria-disabled="${!enabled}" title="${reason}">
    <span class="resource-icon">${component.icon}</span>
    <span class="palette-card-copy"><strong data-allow-truncation="true" title="${component.title}">${component.title}</strong><small data-allow-truncation="true" title="${reason}">${reason}</small></span>${maturity}
  </button>`;
}

function objectRow(title, code, meta, active = false, attributes = '') {
  return `<button type="button" class="object-row ${active ? 'active' : ''}" ${attributes}><span class="tree-type">BO</span><span class="row-copy"><strong>${title}</strong><span>${code}</span></span><span class="mini-badge">${meta}</span></button>`;
}

function treeRow(icon, title, meta, id = '', depth = 0, active = false) {
  return `<button type="button" class="tree-row depth-${depth} ${active ? 'active' : ''}" ${id ? `data-field-id="${id}"` : ''}><span class="tree-type">${icon}</span><span class="row-copy"><strong>${title}</strong><span>${meta}</span></span></button>`;
}

function ruleRow(code, title, meta, enabled) {
  return `<button type="button" class="rule-row ${code === commandState.selectedRuleId ? 'active' : ''}" data-rule="${code}"><span class="tree-type">◇</span><span class="row-copy"><strong>${title}</strong><span>${code} · ${meta}</span></span><span class="mini-badge ${enabled ? 'on' : ''}">${enabled ? '启用' : '停用'}</span></button>`;
}

function inspectorMarkup() {
  const field = schemaFieldDetails(state.selectedNodeId);
  if (inspectorTab === 'layout') {
    return `${propertySection('栅格与尺寸', `
      ${propertyRow('占用列宽', selectProperty('width', field.width, ['1/3', '1/2', '2/3', '整行']))}
      ${propertyRow('最小宽度', `<input class="property-input" data-property="minWidth" value="${field.minWidth}">`)}
      ${propertyRow('标签位置', selectProperty('labelPosition', field.labelPosition, ['顶部', '左侧']))}
      ${propertyRow('对齐方式', selectProperty('align', field.align, ['自动', '起始', '拉伸']))}
    `)}${propertySection('间距', `${propertyRow('外边距', `<input class="property-input" data-property="margin" value="${field.margin}">`)}${propertyRow('内边距', `<input class="property-input" data-property="padding" value="${field.padding}">`)}`)}${propertySection('响应式', `<div class="risk-note">当前版本以企业桌面端为主。最窄支持视口 1280px，低于该宽度进入受限模式。</div>`)}`;
  }
  if (inspectorTab === 'rule') {
    return `${propertySection('关联规则', `
      <div class="rule-card"><strong>R-001 客户变更带出信用信息</strong><span>当客户变化时，刷新信用额度、结算方式和价格政策。</span><button class="link-button" type="button" data-workspace-jump="rules">打开规则</button></div>
      <div class="rule-card"><strong>R-004 空客户阻止提交</strong><span>提交前校验客户非空，否则阻止操作并定位字段。</span></div>
    `)}${propertySection('字段事件', `${propertyRow('值变化', selectProperty('changeRule', field.changeRule, ['执行 R-001', '不执行规则']))}${propertyRow('校验失败', selectProperty('validationFailure', field.validationFailure, ['定位并提示', '仅显示提示', '阻止提交']))}`)}`;
  }
  if (inspectorTab === 'permission') {
    return `${propertySection('角色覆盖', `
      <div class="permission-card"><strong>销售主管</strong><span>可见 · 可编辑 · 可导出</span></div>
      <div class="permission-card"><strong>销售专员</strong><span>可见 · 可编辑 · 不可导出</span></div>
      <div class="permission-card"><strong>财务审核员</strong><span>可见 · 只读 · 可导出</span></div>
    `)}${propertySection('敏感数据', `${switchControl('字段脱敏', field.masked, 'masked')}${switchControl('记录审计', field.auditLogged, 'auditLogged')}<div class="risk-note">页面权限只能收紧服务端权限，不能扩大数据访问范围。</div>`)}`;
  }
  return `${propertySection('标识与绑定', `
    ${propertyRow('字段名称', `<input class="property-input" data-property="title" value="${field.title}">`)}
    ${propertyRow('字段编码', `<input class="property-input" value="${field.code}" readonly>`)}
    ${propertyRow('控件类型', selectProperty('controlType', field.type, ['文本字段', '多行文本', '基础资料字段', '日期字段', '金额字段']))}
    <div class="binding-card"><strong>${field.binding}</strong><span>双向绑定 · 类型一致 · 权限已继承</span></div>
  `)}${propertySection('显示与交互', `
    ${switchControl('必填', field.required, 'required')}
    ${switchControl('只读', field.readonly, 'readonly')}
    ${switchControl('显示标签', field.showLabel, 'showLabel')}
    ${propertyRow('帮助信息', `<input class="property-input" data-property="help" value="${field.help}">`)}
  `)}${propertySection('数据与校验', `
    ${propertyRow('提交策略', selectProperty('submitStrategy', field.submitStrategy, ['值变化时提交', '始终提交']))}
    ${propertyRow('空值策略', selectProperty('nullStrategy', field.nullStrategy, ['保留 null', '使用默认值']))}
    <div class="risk-note">字段变更会影响 2 条规则和 3 个角色权限。发布前将重新执行影响分析。</div>
  `)}`;
}

function schemaFieldDetails(id) {
  const persisted = readFieldProperties(state.schema, id);
  const node = state.schema?.nodes[id];
  const manifest = COMPONENT_MANIFESTS.find((component) => component.type === node?.type);
  return {
    ...fieldPropertyDefaults,
    title: node?.props?.title || manifest?.title || node?.type || '未选择组件',
    type: persisted.controlType || manifest?.title || node?.type || '组件',
    code: node?.id || '-',
    binding: node?.binding?.path || node?.binding?.entityId || (manifest?.dataBinding === 'none' ? '未绑定' : '等待绑定'),
    help: node ? `设计器组件 · ${node.type}` : '',
    ...(node?.props || {}),
    ...persisted,
  };
}

const fieldPropertyDefaults = Object.freeze({
  required: false,
  readonly: false,
  showLabel: true,
  masked: false,
  auditLogged: true,
  changeRule: '执行 R-001',
  validationFailure: '定位并提示',
  width: '整行',
  minWidth: '220 px',
  labelPosition: '顶部',
  align: '自动',
  margin: '8 / 8 / 8 / 8',
  padding: '0 / 0 / 0 / 0',
  submitStrategy: '值变化时提交',
  nullStrategy: '保留 null',
});

function propertySection(title, content) {
  const sectionId = title.replace(/\s+/g, '-');
  const collapsed = Boolean(commandState.propertySections[sectionId]);
  return `<section class="property-section" data-property-section="${sectionId}"><button type="button" data-property-section-toggle="${sectionId}" aria-expanded="${!collapsed}"><span>${title}</span><span>${collapsed ? '⌄' : '⌃'}</span></button><div class="property-content" ${collapsed ? 'hidden' : ''}>${content}</div></section>`;
}

function propertyRow(label, control) {
  return `<label class="property-row"><span>${label}</span>${control}</label>`;
}

function selectProperty(property, current, options) {
  const values = [current, ...options.filter((option) => option !== current)];
  return `<select class="property-select" data-property="${property}">${values.map((option) => `<option>${option}</option>`).join('')}</select>`;
}

function switchControl(label, on, property = '') {
  return `<div class="switch-row"><span>${label}</span><button class="switch ${on ? 'on' : ''}" type="button" role="switch" aria-checked="${on}" ${property ? `data-toggle-property="${property}"` : ''}></button></div>`;
}

function analysisMarkup() {
  if (analysisTab === 'data') {
    return `<div class="metric-grid"><div class="metric"><strong>6 / 6</strong><span>字段绑定有效</span></div><div class="metric"><strong>2</strong><span>级联刷新链路</span></div><div class="metric"><strong>0</strong><span>断裂引用</span></div><div class="metric"><strong>未测量</strong><span>样本装载耗时</span></div></div>`;
  }
  if (analysisTab === 'performance') {
    return `<div class="metric-grid"><div class="metric"><strong>未测量</strong><span>运行性能基线</span></div><div class="metric"><strong>33</strong><span>当前分录单元格</span></div><div class="metric"><strong>待接入</strong><span>字段选择测量</span></div><div class="metric"><strong>待接入</strong><span>渲染追踪</span></div></div>`;
  }
  if (analysisTab === 'audit') {
    return `<div class="finding-row"><span class="severity">11:42</span><span class="finding-copy"><strong>客户字段标签更新</strong><span>陈设计 · 草稿 v18</span></span><button class="link-button" data-action="view-difference" data-difference-id="D-001">查看差异</button></div><div class="finding-row"><span class="severity">11:39</span><span class="finding-copy"><strong>销售主管权限集同步</strong><span>权限设计器 · 3 个字段</span></span><button class="link-button" data-action="view-difference" data-difference-id="D-002">查看差异</button></div>`;
  }
  return state.findings.filter((finding) => finding.open).map((finding) => `
    <div class="finding-row" data-finding-id="${finding.id}">
      <span class="severity ${finding.severity.toLowerCase()}">${finding.severity}</span>
      <span class="finding-copy"><strong>${finding.message}</strong><span>${finding.id} · ${finding.severity === 'P0' ? '发布阻断' : '建议处理'}</span></span>
      <button class="link-button" type="button" data-action="${finding.severity === 'P0' ? 'resolve-blocker' : 'locate-finding'}">${finding.severity === 'P0' ? '配置策略' : '定位'}</button>
    </div>`).join('') || `<div class="metric"><strong>没有未关闭问题</strong><span>可以进入发布准备。</span></div>`;
}

function render() {
  root.dataset.state = state.activeWorkspace;
  root.dataset.selected = state.selectedNodeId;
  document.querySelectorAll('[data-workspace]').forEach((button) => button.classList.toggle('active', button.dataset.workspace === state.activeWorkspace));
  [resourceTitle.textContent, resourceSubtitle.textContent] = WORKSPACE_META[state.activeWorkspace];
  resourceContent.innerHTML = resourceMarkup();
  const componentStudio = document.querySelector('[data-testid="component-studio"]');
  const workspaceEditor = document.querySelector('[data-testid="workspace-editor"]');
  const canvasFrame = document.querySelector('[data-testid="canvas-frame"]');
  const analysisPanel = document.querySelector('[data-testid="analysis-panel"]');
  const inComponentStudio = state.activeWorkspace === 'components';
  const inWorkspaceEditor = ['model', 'rules', 'permissions'].includes(state.activeWorkspace);
  componentStudio.hidden = !inComponentStudio;
  workspaceEditor.hidden = !inWorkspaceEditor;
  canvasFrame.hidden = inComponentStudio || inWorkspaceEditor;
  analysisPanel.hidden = inComponentStudio || inWorkspaceEditor || commandState.analysisCollapsed;
  if (inComponentStudio) componentStudio.innerHTML = componentStudioMarkup();
  if (inWorkspaceEditor) workspaceEditor.innerHTML = workspaceEditorMarkup();
  root.classList.toggle('left-collapsed', commandState.leftPanelCollapsed);
  root.classList.toggle('settings-open', commandState.settingsOpen);
  document.querySelectorAll('[data-page-tab]').forEach((button) => button.classList.toggle('active', button.dataset.pageTab === commandState.activePageTab));

  const field = schemaFieldDetails(state.selectedNodeId);
  const inspectorTitle = document.querySelector('[data-testid="inspector-title"]');
  const inspectorType = document.querySelector('[data-testid="inspector-type"]');
  if (inComponentStudio) {
    const manifest = COMPONENT_MANIFESTS.find((item) => item.type === selectedComponentType) || COMPONENT_MANIFESTS[0];
    inspectorTitle.textContent = manifest.title;
    inspectorType.textContent = `${manifest.type} · 组件属性`;
    inspectorBody.innerHTML = componentInspectorMarkup();
  } else {
    inspectorTitle.textContent = field.title;
    inspectorType.textContent = `${field.type} · ${field.code}`;
    inspectorBody.innerHTML = inspectorMarkup();
  }
  analysisBody.innerHTML = analysisMarkup();

  document.querySelectorAll('[data-field-id]').forEach((node) => node.classList.toggle('selected', node.dataset.fieldId === state.selectedNodeId));
  document.querySelector('[data-testid="breadcrumb"]').innerHTML = state.breadcrumb.map((part, index) => index === state.breadcrumb.length - 1 ? `<strong>${part}</strong>` : `<span>${part}</span><b>›</b>`).join('');
  document.querySelector('[data-testid="save-state"]').textContent = state.dirty ? '有未保存变更' : '草稿已保存';
  document.querySelector('[data-testid="role-label"]').textContent = state.role;
  document.querySelector('[data-testid="analysis-summary"]').textContent = summaryText();
  const findingCount = document.querySelector('[data-testid="finding-count"]');
  const openFindings = state.findings.filter((finding) => finding.open);
  findingCount.textContent = String(openFindings.length);
  findingCount.classList.toggle('danger', openFindings.some((finding) => finding.severity === 'P0' || finding.severity === 'P1'));
  document.querySelector('[data-testid="schema-node-count"]').textContent = String(Object.keys(state.schema.nodes).length);
  document.querySelector('[data-testid="schema-json"]').value = JSON.stringify(state.schema);
  document.querySelector('[data-testid="canvas-frame"]').dataset.device = state.device;
  document.querySelectorAll('[data-device]').forEach((button) => button.classList.toggle('active', button.dataset.device === state.device));
  document.querySelector('[data-business-state]').value = state.businessState;
  if (commandState.autoSave) {
    saveDesignerWorkspace();
  }
  renderAddedComponents();
  renderCommandConsumers();
  bindDynamicEvents();
}

function formatEntryValue(value, column) {
  if (value === '' || value === null || value === undefined) return '—';
  return column.numeric ? Number(value).toLocaleString('zh-CN', { minimumFractionDigits: column.id === 'qty' ? 0 : 2, maximumFractionDigits: 2 }) : String(value);
}

function renderCommandConsumers() {
  const tabHost = document.querySelector('[data-testid="page-tab-content"]');
  if (tabHost) {
    tabHost.dataset.activeTab = commandState.activePageTab;
    tabHost.querySelectorAll('[data-page-panel]').forEach((panel) => { panel.hidden = panel.dataset.pagePanel !== commandState.activePageTab; });
    tabHost.querySelectorAll('[data-page-value]').forEach((control) => { control.value = previewData[control.dataset.pageValue] ?? control.value; });
  }

  const settingsPanel = document.querySelector('[data-testid="settings-panel"]');
  if (settingsPanel) {
    settingsPanel.hidden = !commandState.settingsOpen;
    const autoSave = settingsPanel.querySelector('[data-setting="auto-save"]');
    autoSave?.classList.toggle('on', commandState.autoSave);
    autoSave?.setAttribute('aria-checked', String(commandState.autoSave));
    const defaultDevice = settingsPanel.querySelector('[data-setting="default-device"]');
    if (defaultDevice) defaultDevice.value = commandState.defaultDevice;
  }

  const view = createEntryView(commandState.entryRows, entryColumns);
  const table = document.querySelector('[data-testid="entry-runtime-table"]');
  if (table) {
    table.innerHTML = `<thead><tr><th class="row-no">#</th>${view.columns.map((column) => `<th class="${column.numeric ? 'number' : ''} ${column.sticky ? 'sticky-col' : ''}" ${column.width ? `style="width:${column.width}px"` : ''}>${column.label}</th>`).join('')}</tr></thead><tbody>${view.rows.map((row) => `<tr><td class="row-no">${row.number}</td>${view.columns.map((column) => `<td class="${column.numeric ? 'number' : ''} ${column.sticky ? 'sticky-col' : ''}" ${column.width ? `style="width:${column.width}px"` : ''}>${formatEntryValue(row.cells[column.id], column)}</td>`).join('')}</tr>`).join('')}</tbody><tfoot><tr><td class="row-no">合计</td>${view.columns.map((column) => `<td class="${column.numeric ? 'number' : ''}">${column.total ? formatEntryValue(view.totals[column.id], column) : ''}</td>`).join('')}</tr></tfoot>`;
  }
  const summary = document.querySelector('[data-testid="entry-summary"]');
  if (summary) summary.textContent = `${view.rows.length} 行 · ${view.columns.length} 列${commandState.entryRows.some((row) => row.values?.warehouse) ? ' · 已批填仓库 W-01' : ''}`;

  const columnPanel = document.querySelector('[data-testid="column-settings-panel"]');
  if (columnPanel) {
    columnPanel.hidden = !commandState.columnSettingsOpen;
    columnPanel.innerHTML = `<header><strong>列设置</strong><span>${view.columns.length} / ${entryColumns.length} 列可见</span></header><div>${entryColumns.map((column) => `<label><input type="checkbox" data-entry-column="${column.id}" ${column.visible === false ? '' : 'checked'}><span>${column.label}</span></label>`).join('')}</div>`;
  }

  const status = document.querySelector('.status-badge');
  if (status) status.textContent = commandState.submitted ? '已提交' : commandState.draftSaved ? '已暂存' : '草稿';
}

function summaryText() {
  const open = state.findings.filter((finding) => finding.open);
  const blockers = open.filter((finding) => finding.severity === 'P0' || finding.severity === 'P1');
  return `${blockers.length} 个阻断问题，${open.length - blockers.length} 个建议`;
}

function bindDynamicEvents() {
  document.querySelectorAll('[data-property-section-toggle]').forEach((button) => button.addEventListener('click', () => {
    commandState = executeDesignerCommand(commandState, 'toggle-property-section', { sectionId: button.dataset.propertySectionToggle });
    render();
  }));
  resourceContent.querySelectorAll('[data-business-object]').forEach((button) => button.addEventListener('click', () => {
    businessModelState = selectBusinessObject(businessModelState, button.dataset.businessObject);
    render();
  }));
  resourceContent.querySelectorAll('[data-permission-role]').forEach((button) => button.addEventListener('click', () => {
    permissionMatrixState = selectRole(permissionMatrixState, button.dataset.permissionRole);
    render();
  }));
  document.querySelectorAll('[data-model-action]').forEach((button) => button.addEventListener('click', () => {
    const action = button.dataset.modelAction;
    if (action === 'add-object') businessModelState = addBusinessObject(businessModelState);
    if (action === 'add-field') businessModelState = addBusinessField(businessModelState);
    if (action === 'remove-field') businessModelState = removeBusinessField(businessModelState, button.dataset.fieldId);
    if (action === 'add-relation') businessModelState = addBusinessRelation(businessModelState, businessModelState.objects.find((item) => item.id !== businessModelState.selectedObjectId)?.id);
    if (action === 'add-index') businessModelState = addBusinessIndex(businessModelState, selectedBusinessObject(businessModelState)?.fields[0]?.id, true);
    render();
  }));
  document.querySelectorAll('[data-model-field-name], [data-model-field-type]').forEach((control) => control.addEventListener('change', () => {
    const fieldId = control.dataset.modelFieldName || control.dataset.modelFieldType;
    businessModelState = updateBusinessField(businessModelState, fieldId, control.dataset.modelFieldName ? { name: control.value } : { type: control.value });
    render();
  }));
  document.querySelectorAll('[data-rule-trigger]').forEach((control) => control.addEventListener('change', () => {
    const rule = selectedRule(ruleBuilderState);
    const event = control.dataset.ruleTrigger === 'event' ? control.value : rule.trigger.event;
    const source = control.dataset.ruleTrigger === 'source' ? control.value : rule.trigger.source;
    ruleBuilderState = executeRuleBuilderCommand(ruleBuilderState, 'set-trigger', { event, source });
    render();
  }));
  document.querySelectorAll('[data-rule-sample]').forEach((control) => control.addEventListener('change', () => {
    ruleBuilderState = executeRuleBuilderCommand(ruleBuilderState, 'set-sample-value', { field: control.dataset.ruleSample, value: control.value });
    render();
  }));
  document.querySelectorAll('[data-rule-action]').forEach((button) => button.addEventListener('click', () => {
    const action = button.dataset.ruleAction;
    if (action === 'add-condition') ruleBuilderState = executeRuleBuilderCommand(ruleBuilderState, action, { parentGroupId: 'root', condition: { field: 'customer', operator: 'notEmpty', value: null } });
    else if (action === 'add-action') ruleBuilderState = executeRuleBuilderCommand(ruleBuilderState, action, { action: { type: 'message', target: 'form', value: '规则已执行' } });
    else ruleBuilderState = executeRuleBuilderCommand(ruleBuilderState, action);
    render();
  }));
  document.querySelectorAll('[data-permission-field]').forEach((control) => control.addEventListener('change', () => {
    permissionMatrixState = updateFieldPolicy(permissionMatrixState, { roleId: permissionMatrixState.selectedRoleId, fieldId: control.dataset.permissionField, key: control.dataset.permissionKey, value: control.checked });
    render();
  }));
  document.querySelectorAll('[data-permission-operation]').forEach((control) => control.addEventListener('change', () => {
    permissionMatrixState = updateOperationPolicy(permissionMatrixState, { roleId: permissionMatrixState.selectedRoleId, operationId: control.dataset.permissionOperation, allow: control.checked });
    render();
  }));
  document.querySelectorAll('[data-permission-action="add-role"]').forEach((button) => button.addEventListener('click', () => { permissionMatrixState = addRole(permissionMatrixState); render(); }));
  document.querySelectorAll('[data-runtime-action]').forEach((control) => {
    const action = control.dataset.runtimeAction;
    const eventName = runtimeActionEventName(action);
    control.addEventListener(eventName, () => {
      updateComponentRuntime(action, runtimeActionPayload(control));
    });
  });
  document.querySelectorAll('[data-entry-column]').forEach((input) => input.addEventListener('change', () => {
    entryColumns = updateColumnVisibility(entryColumns, input.dataset.entryColumn, input.checked);
    render();
  }));
  document.querySelectorAll('[data-page-value]').forEach((control) => control.addEventListener('change', () => {
    previewData = { ...previewData, [control.dataset.pageValue]: control.value };
    if (commandState.autoSave) saveDesignerWorkspace();
  }));
  resourceContent.querySelector('[data-component-studio-search]')?.addEventListener('input', (event) => {
    componentStudioQuery = event.target.value;
    render();
  });
  resourceContent.querySelectorAll('[data-workspace-search], [data-resource-search]').forEach((control) => control.addEventListener('input', (event) => {
    resourceQuery = event.target.value;
    const cursor = resourceQuery.length;
    const selector = event.target.matches('[data-workspace-search]') ? '[data-workspace-search]' : '[data-resource-search]';
    render();
    const input = resourceContent.querySelector(selector);
    input?.focus();
    input?.setSelectionRange(cursor, cursor);
  }));
  resourceContent.querySelectorAll('[data-component-case]').forEach((button) => button.addEventListener('click', () => {
    selectedComponentType = button.dataset.componentCase;
    render();
  }));
  document.querySelectorAll('[data-component-state]').forEach((button) => button.addEventListener('click', () => {
    componentStudioState = button.dataset.componentState;
    render();
  }));
  resourceContent.querySelectorAll('[data-resource-tab]').forEach((button) => button.addEventListener('click', () => { resourceTab = button.dataset.resourceTab; render(); }));
  resourceContent.querySelectorAll('[data-rule-filter]').forEach((button) => button.addEventListener('click', () => {
    commandState = executeDesignerCommand(commandState, 'filter-rules', { filter: button.dataset.ruleFilter });
    render();
  }));
  resourceContent.querySelectorAll('[data-rule]').forEach((button) => button.addEventListener('click', () => {
    commandState = executeDesignerCommand(commandState, 'select-rule', { ruleId: button.dataset.rule });
    ruleBuilderState = executeRuleBuilderCommand(ruleBuilderState, 'select-rule', { ruleId: button.dataset.rule });
    render();
  }));
  resourceContent.querySelectorAll('[data-component-category]').forEach((button) => button.addEventListener('click', () => { componentCategory = button.dataset.componentCategory; render(); }));
  resourceContent.querySelector('[data-component-search]')?.addEventListener('input', (event) => {
    componentQuery = event.target.value;
    const cursor = componentQuery.length;
    render();
    const input = resourceContent.querySelector('[data-component-search]');
    input?.focus();
    input?.setSelectionRange(cursor, cursor);
  });
  resourceContent.querySelectorAll('[data-field-id]').forEach((button) => button.addEventListener('click', () => selectNode(button.dataset.fieldId)));
  resourceContent.querySelectorAll('[data-add-component]').forEach((button) => button.addEventListener('click', () => {
    if (button.getAttribute('aria-disabled') === 'true') return toast('当前不能使用此组件', button.title);
    dropPosition = 'inside';
    placeComponent(button.dataset.componentType, selectedSchemaTarget());
  }));
  resourceContent.querySelectorAll('[data-keyboard-add]').forEach((button) => button.addEventListener('keydown', (event) => {
    if (!['Enter', ' '].includes(event.key) || button.getAttribute('aria-disabled') === 'true') return;
    event.preventDefault();
    dropPosition = 'inside';
    placeComponent(button.dataset.componentType, selectedSchemaTarget());
  }));
  resourceContent.querySelectorAll('[data-component-type]').forEach((button) => button.addEventListener('dragstart', (event) => {
    if (button.getAttribute('aria-disabled') === 'true') return event.preventDefault();
    event.dataTransfer.effectAllowed = 'copy';
    event.dataTransfer.setData('application/x-lowcode-component', button.dataset.componentType);
    event.dataTransfer.setData('text/plain', button.dataset.componentType);
    root.dataset.dragging = 'component';
  }));
  resourceContent.querySelectorAll('[data-action="preview"]').forEach((button) => button.addEventListener('click', openPreview));
  resourceContent.querySelector('[data-resource-role]')?.addEventListener('change', (event) => { state = { ...state, role: event.target.value }; render(); });
  resourceContent.querySelector('[data-preview-sample]')?.addEventListener('change', (event) => { previewSample = event.target.value; applyPreviewSample(); render(); });
  resourceContent.querySelector('[data-preview-device]')?.addEventListener('change', (event) => { previewDevice = event.target.value; render(); });
  resourceContent.querySelectorAll('.resource-group > button').forEach((button) => button.addEventListener('click', () => {
    const body = button.nextElementSibling;
    if (body) body.hidden = !body.hidden;
    button.setAttribute('aria-expanded', String(!body?.hidden));
  }));

  inspectorBody.querySelectorAll('[data-property]').forEach((control) => {
    if (control.tagName === 'SELECT') control.addEventListener('change', finishFieldPropertyEdit);
    else {
      control.addEventListener('input', stageFieldProperty);
      control.addEventListener('blur', endFieldPropertyEdit);
    }
  });
  inspectorBody.querySelectorAll('[data-toggle-property]').forEach((button) => button.addEventListener('click', () => {
    const property = button.dataset.toggleProperty;
    commitFieldProperty(property, !schemaFieldDetails(state.selectedNodeId)[property]);
  }));
  inspectorBody.querySelector('[data-workspace-jump]')?.addEventListener('click', () => setWorkspace('rules'));

  analysisBody.querySelector('[data-action="resolve-blocker"]')?.addEventListener('click', () => {
    commandState = executeDesignerCommand(commandState, 'set-permission-policy', { fieldId: 'creditLimit', roleId: 'SalesManager', export: 'allow' });
    const policyExists = commandState.permissionPolicies.creditLimit?.SalesManager?.export === 'allow';
    state = { ...state, findings: state.findings.map((finding) => finding.id === 'F-PERM-001' ? { ...finding, open: !policyExists } : finding), statusMessage: policyExists ? '已保存客户信用额度导出权限策略' : '权限策略保存失败', dirty: policyExists || state.dirty };
    render();
    toast(policyExists ? '权限策略已保存' : '权限策略未保存', policyExists ? '发布准备将基于策略对象重新计算权限覆盖' : '请补齐字段、角色和导出决策');
  });
}

const componentDropzone = document.querySelector('[data-component-dropzone]');
componentDropzone.addEventListener('click', (event) => {
  if (event.target.closest('.table-actions button, .business-actions button, .page-tabs button')) return;
  const schemaNode = event.target.closest('[data-schema-node]');
  if (schemaNode) return selectSchemaNode(schemaNode.dataset.schemaNode);
  const fieldNode = event.target.closest('[data-field-id]');
  if (fieldNode) selectNode(fieldNode.dataset.fieldId);
});
componentDropzone.addEventListener('dragover', (event) => {
  if (!event.dataTransfer.types.includes('application/x-lowcode-component') && !event.dataTransfer.types.includes('application/x-lowcode-node')) return;
  event.preventDefault();
  event.dataTransfer.dropEffect = event.dataTransfer.types.includes('application/x-lowcode-node') ? 'move' : 'copy';
  componentDropzone.classList.add('accepting-drop');
  document.querySelectorAll('[data-schema-drop-target]').forEach((node) => node.classList.remove('active-drop-target'));
  const target = event.target.closest('[data-schema-drop-target]');
  if (target) {
    dropPosition = dropPositionForPointer(target, event.clientY);
    target.dataset.dropPosition = dropPosition;
    target.classList.add('active-drop-target');
  } else {
    dropPosition = 'inside';
  }
});

function dropPositionForPointer(target, pointerY) {
  const bounds = target.getBoundingClientRect();
  const ratio = bounds.height ? (pointerY - bounds.top) / bounds.height : 0.5;
  if (ratio < 0.25) return dropPosition = 'before';
  if (ratio > 0.75) return dropPosition = 'after';
  return dropPosition = target.classList.contains('schema-container') ? 'inside' : 'after';
}
componentDropzone.addEventListener('dragleave', (event) => {
  if (!componentDropzone.contains(event.relatedTarget)) componentDropzone.classList.remove('accepting-drop');
});
componentDropzone.addEventListener('drop', (event) => {
  const type = event.dataTransfer.getData('application/x-lowcode-component');
  const sourceId = event.dataTransfer.getData('application/x-lowcode-node');
  if (!type && !sourceId) return;
  event.preventDefault();
  componentDropzone.classList.remove('accepting-drop');
  delete root.dataset.dragging;
  const targetId = event.target.closest('[data-schema-drop-target]')?.dataset.schemaDropTarget || 'page';
  document.querySelectorAll('[data-schema-drop-target]').forEach((node) => node.classList.remove('active-drop-target'));
  if (sourceId) moveSchemaNode(sourceId, targetId, dropPosition);
  else placeComponent(type, targetId);
});
document.addEventListener('dragend', () => {
  componentDropzone.classList.remove('accepting-drop');
  document.querySelectorAll('[data-schema-drop-target]').forEach((node) => node.classList.remove('active-drop-target'));
  delete root.dataset.dragging;
});

function selectedSchemaTarget() {
  const selected = state.schema?.nodes[state.selectedNodeId];
  return selected ? selected.id : 'page';
}

function commitFieldProperty(property, value) {
  const fieldId = state.selectedNodeId;
  const nextSchema = updateFieldProperty(state.schema, fieldId, property, value);
  state = applySchemaTransaction(state, nextSchema, fieldId, '已更新字段属性');
  if (property === 'title') {
    state = {
      ...state,
      inspectorTitle: value,
      breadcrumb: [...state.breadcrumb.slice(0, -1), value],
    };
  }
  render();
  toast('属性已更新', '修改已写入页面 Schema，可撤销并随草稿恢复');
}

function stageFieldProperty(event) {
  const property = event.target.dataset.property;
  const current = schemaFieldDetails(state.selectedNodeId);
  const value = property === 'title' ? event.target.value.trim() || current.title : event.target.value;
  const fieldId = state.selectedNodeId;
  const nextSchema = updateFieldProperty(state.schema, fieldId, property, value);
  state = applySchemaTransaction(state, nextSchema, fieldId, '正在编辑字段属性', `property:${fieldId}:${property}`);
  if (property === 'title') {
    state = {
      ...state,
      inspectorTitle: value,
      breadcrumb: [...state.breadcrumb.slice(0, -1), value],
    };
    document.querySelector('[data-testid="inspector-title"]').textContent = value;
    document.querySelector('[data-testid="breadcrumb"]').innerHTML = state.breadcrumb.map((part, index) => index === state.breadcrumb.length - 1 ? `<strong>${part}</strong>` : `<span>${part}</span><b>›</b>`).join('');
  }
  localStorage.setItem(DESIGNER_STORAGE_KEY, encodeDesignerSnapshot(state));
  document.querySelector('[data-testid="schema-json"]').value = JSON.stringify(state.schema);
  document.querySelector('[data-testid="save-state"]').textContent = '有未保存变更';
  syncCanvasFieldProperties();
}

function endFieldPropertyEdit() {
  state = endSchemaTransaction(state);
}

function finishFieldPropertyEdit(event) {
  const property = event.target.dataset.property;
  const current = schemaFieldDetails(state.selectedNodeId);
  const value = property === 'title' ? event.target.value.trim() || current.title : event.target.value;
  commitFieldProperty(property, value);
}

function createNodeId(type) {
  let id;
  do id = `${type.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()}-${nodeSequence++}`;
  while (state.schema.nodes[id]);
  return id;
}

function placeComponent(type, targetId = 'page') {
  const manifest = COMPONENT_MANIFESTS.find((component) => component.type === type);
  const id = createNodeId(type);
  const isSubEntry = ['SubEntryGrid', 'TreeSubEntryGrid', 'SubCardEntry'].includes(type);
  const needsLayout = targetId === 'page' && dropPosition === 'inside' && ['input', 'reference'].includes(manifest?.category);
  let result = needsLayout ? { accepted: false, reasonCode: 'INVALID_PARENT' } : insertMaterial(state.schema, {
    id,
    type,
    targetId,
    position: dropPosition,
    device: state.device,
    props: { ...manifest?.defaultSchema?.props, title: manifest?.title || type },
    ...(isSubEntry ? {
      binding: { entityId: `${id}-entity` },
      relation: { parentKey: 'id', foreignKey: 'parentId' },
    } : {}),
  });
  if (!result.accepted && result.reasonCode === 'INVALID_PARENT' && targetId !== 'page' && ['input', 'reference'].includes(manifest?.category)) {
    targetId = 'page';
  }
  if (!result.accepted && result.reasonCode === 'INVALID_PARENT' && targetId === 'page' && ['input', 'reference'].includes(manifest?.category)) {
    const layoutId = createNodeId('FieldLayout');
    const layout = insertMaterial(state.schema, {
      id: layoutId,
      type: 'FieldLayout',
      targetId: 'page',
      position: 'inside',
      props: { title: '字段布局' },
    });
    if (layout.accepted) {
      result = insertMaterial(layout.nextSchema, {
        id,
        type,
        targetId: layoutId,
        position: dropPosition,
        device: state.device,
        props: { ...manifest?.defaultSchema?.props, title: manifest?.title || type },
        ...(isSubEntry ? {
          binding: { entityId: `${id}-entity` },
          relation: { parentKey: 'id', foreignKey: 'parentId' },
        } : {}),
      });
    }
  }
  if (!result.accepted) {
    document.querySelector('[data-testid="drop-result"]').textContent = result.message;
    toast('无法放置组件', result.message);
    return false;
  }
  state = applySchemaTransaction(state, result.nextSchema, result.selectedNodeId, `已添加${manifest?.title || type}`);
  render();
  document.querySelector('[data-testid="drop-result"]').textContent = `已添加${manifest?.title || type}`;
  toast('组件已放置', `${manifest?.title || type} 已写入页面 Schema，可撤销`);
  return true;
}

function moveSchemaNode(sourceId, targetId, position = 'inside') {
  const result = moveNode(state.schema, { sourceId, targetId, position });
  if (!result.accepted) {
    document.querySelector('[data-testid="drop-result"]').textContent = result.message;
    toast('无法移动组件', result.message);
    return false;
  }
  state = applySchemaTransaction(state, result.nextSchema, result.selectedNodeId, '已调整组件布局');
  render();
  document.querySelector('[data-testid="drop-result"]').textContent = '组件布局已更新';
  return true;
}

function moveByCommand(sourceId, command) {
  const source = state.schema.nodes[sourceId];
  const parent = source && state.schema.nodes[source.parentId];
  if (!source || !parent) return false;
  const index = parent.children.indexOf(sourceId);
  if (command === 'move-up' && index > 0) return moveSchemaNode(sourceId, parent.children[index - 1], 'before');
  if (command === 'move-down' && index < parent.children.length - 1) return moveSchemaNode(sourceId, parent.children[index + 1], 'after');
  if (command === 'move-out' && parent.parentId) return moveSchemaNode(sourceId, parent.id, 'after');
  if (command === 'move-in' && index > 0) return moveSchemaNode(sourceId, parent.children[index - 1], 'inside');
  document.querySelector('[data-testid="drop-result"]').textContent = '当前位置不能执行该移动';
  return false;
}

function renderAddedComponents() {
  const host = document.querySelector('[data-testid="schema-components"]');
  const entryHost = document.querySelector('[data-testid="entry-schema-components"]');
  if (!host || !entryHost) return;
  renderHeaderFields();
  const rootChildren = (state.schema?.nodes.page?.children || [])
    .filter((id) => id !== 'entries' && id !== 'header-fields').map((id) => state.schema.nodes[id]).filter(Boolean);
  const entryChildren = (state.schema?.nodes.entries?.children || [])
    .map((id) => state.schema.nodes[id]).filter(Boolean);
  host.hidden = rootChildren.length === 0;
  host.innerHTML = rootChildren.map(schemaNodeMarkup).join('');
  entryHost.hidden = entryChildren.length === 0;
  entryHost.innerHTML = entryChildren.map(schemaNodeMarkup).join('');
  document.querySelectorAll('[data-testid="schema-components"] [data-schema-node], [data-testid="entry-schema-components"] [data-schema-node]').forEach((node) => node.addEventListener('click', (event) => {
    event.stopPropagation();
    selectSchemaNode(node.dataset.schemaNode);
  }));
  document.querySelectorAll('[data-schema-node]').forEach((node) => node.addEventListener('dragstart', (event) => {
    event.stopPropagation();
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('application/x-lowcode-node', node.dataset.schemaNode);
    root.dataset.dragging = 'node';
  }));
  document.querySelectorAll('[data-move-command]').forEach((button) => button.addEventListener('click', (event) => {
    event.stopPropagation();
    moveByCommand(button.closest('[data-schema-node]').dataset.schemaNode, button.dataset.moveCommand);
  }));
  document.querySelectorAll('[data-node-command]').forEach((button) => button.addEventListener('click', (event) => {
    event.stopPropagation();
    const nodeId = button.closest('[data-schema-node]')?.dataset.schemaNode;
    const result = button.dataset.nodeCommand === 'duplicate' ? duplicateNode(state.schema, nodeId) : removeNode(state.schema, nodeId);
    if (!result.accepted) return toast('操作失败', result.message);
    state = applySchemaTransaction(state, result.nextSchema, result.selectedNodeId, button.dataset.nodeCommand === 'duplicate' ? '已复制组件' : '已删除组件');
    render();
    toast(button.dataset.nodeCommand === 'duplicate' ? '组件已复制' : '组件已删除', '修改已写入 Schema，可撤销');
  }));
  syncCanvasFieldProperties();
}

function renderHeaderFields() {
  const host = document.querySelector('[data-testid="header-schema-fields"]');
  const layout = state.schema?.nodes['header-fields'];
  if (!host || !layout) return;
  const addField = host.querySelector('[data-action="add-field"]');
  host.querySelectorAll('[data-header-schema-field]').forEach((node) => node.remove());
  const markup = (layout.children || []).map((id) => state.schema.nodes[id]).filter(Boolean).map((node) => {
    const field = schemaFieldDetails(node.id);
    const projection = projectFieldRenderer(field);
    return `<button class="field-node ${state.selectedNodeId === node.id ? 'selected' : ''}" type="button" draggable="true" data-header-schema-field data-field-id="${node.id}" data-schema-id="${node.id}" data-component-type="${node.type}" data-schema-node="${node.id}" data-schema-drop-target="${node.id}" data-testid="field-${node.id}" data-width="${field.width}" data-label-position="${projection.labelPosition}" style="${rendererStyleAttribute(projection.style)}" title="${field.help}">
      <span class="field-label ${field.required ? 'required' : ''}" ${field.showLabel ? '' : 'hidden'}>${field.title}</span>
      <span class="field-control ${field.readonly ? 'readonly' : ''} ${projection.control}" data-renderer="${projection.control}"><span class="field-control-value" data-allow-truncation="true">${field.readonly ? '只读值' : '等待输入'}</span><b aria-hidden="true">${projection.control === 'reference' ? '⌄' : ''}</b></span>
    </button>`;
  }).join('');
  addField?.insertAdjacentHTML('beforebegin', markup);
}

function syncCanvasFieldProperties() {
  componentDropzone.querySelectorAll('[data-field-id]').forEach((fieldNode) => {
    const field = schemaFieldDetails(fieldNode.dataset.fieldId);
    if (fieldNode.matches('.entry-section')) {
      const heading = fieldNode.querySelector(':scope > .section-heading strong');
      if (heading) heading.textContent = field.title;
    } else {
      const label = fieldNode.querySelector(':scope > .field-label');
      const control = fieldNode.querySelector(':scope > .field-control');
      if (!label) return;
      label.textContent = field.title;
      label.classList.toggle('required', field.required);
      label.hidden = !field.showLabel;
      control?.classList.toggle('readonly', field.readonly);
    }
    const projection = projectFieldRenderer(field);
    fieldNode.dataset.width = field.width;
    fieldNode.dataset.labelPosition = projection.labelPosition;
    Object.assign(fieldNode.style, projection.style);
    if (!fieldNode.matches('.entry-section')) {
      const control = fieldNode.querySelector(':scope > .field-control');
      if (control) {
        control.dataset.renderer = projection.control;
        control.classList.toggle('reference', projection.control === 'reference');
        control.classList.toggle('multiline', projection.control === 'textarea');
        control.classList.toggle('number', projection.control === 'number');
        control.classList.toggle('date', projection.control === 'date');
      }
    }
    fieldNode.title = field.help;
  });
}

function schemaNodeMarkup(node) {
  const manifest = COMPONENT_MANIFESTS.find((component) => component.type === node.type);
  const field = schemaFieldDetails(node.id);
  const title = field.title;
  const projection = projectFieldRenderer(field);
  const isContainer = [
    'Section', 'FieldLayout', 'FieldGroup', 'Flex', 'Columns', 'Column',
    'Tabs', 'TabPane', 'Wizard', 'WizardStep', 'SplitPane', 'SplitRegion',
    'AdvancedPanel', 'DashboardGrid', 'DashboardCard', 'EntryGrid',
    'TreeEntryGrid', 'CardEntry', 'SubEntryGrid', 'TreeSubEntryGrid', 'SubCardEntry',
  ].includes(node.type);
  const children = (node.children || []).map((id) => state.schema.nodes[id]).filter(Boolean);
  if (isContainer) {
    return `<section class="schema-component schema-container ${state.selectedNodeId === node.id ? 'selected' : ''}" draggable="true" data-schema-id="${node.id}" data-component-type="${node.type}" data-schema-node="${node.id}" data-schema-drop-target="${node.id}">
      <header><span class="resource-icon">${manifest?.icon || '容'}</span><strong>${title}</strong><small>${node.type}</small>${moveCommands()}</header>
      <div class="schema-container-body">${children.length ? children.map(schemaNodeMarkup).join('') : '<span class="empty-drop-hint">拖入兼容组件</span>'}</div>
    </section>`;
  }
  return `<div role="button" tabindex="0" class="schema-component schema-field ${state.selectedNodeId === node.id ? 'selected' : ''}" draggable="true" data-schema-id="${node.id}" data-component-type="${node.type}" data-schema-node="${node.id}" data-schema-drop-target="${node.id}" data-width="${field.width}" data-label-position="${projection.labelPosition}" style="${rendererStyleAttribute(projection.style)}" title="${field.help}">
    <span class="field-label ${field.required ? 'required' : ''}" ${field.showLabel ? '' : 'hidden'}>${title}</span><span class="field-control ${field.readonly ? 'readonly' : ''} ${projection.control}" data-renderer="${projection.control}"><span class="field-control-value" data-allow-truncation="true">${manifest?.dataBinding === 'none' ? node.type : '等待输入'}</span><b aria-hidden="true">${projection.control === 'reference' ? '⌄' : ''}</b></span>${moveCommands()}
  </div>`;
}

function moveCommands() {
  return `<span class="schema-move-actions" aria-label="布局移动">
    <button type="button" title="上移" aria-label="上移" data-move-command="move-up">↑</button>
    <button type="button" title="下移" aria-label="下移" data-move-command="move-down">↓</button>
    <button type="button" title="移入前一容器" aria-label="移入前一容器" data-move-command="move-in">→</button>
    <button type="button" title="移出当前容器" aria-label="移出当前容器" data-move-command="move-out">←</button>
    <button type="button" title="复制组件" aria-label="复制组件" data-node-command="duplicate">⧉</button>
    <button type="button" title="删除组件" aria-label="删除组件" data-node-command="delete">×</button>
  </span>`;
}

function selectSchemaNode(id) {
  const node = state.schema?.nodes[id];
  if (!node) return;
  state = {
    ...state,
    selectedNodeId: id,
        inspectorTitle: schemaFieldDetails(id).title,
    inspectorType: node.type,
        breadcrumb: ['销售订单', '新增组件', schemaFieldDetails(id).title],
  };
  render();
}

function selectNode(fieldId) {
  if (!state.schema?.nodes[fieldId]) return;
  return selectSchemaNode(fieldId);
}

function setWorkspace(workspace) {
  resourceQuery = '';
  state = switchWorkspace(state, workspace);
  render();
}

function setInspector(tab) {
  inspectorTab = tab;
  document.querySelectorAll('[data-inspector]').forEach((button) => button.classList.toggle('active', button.dataset.inspector === tab));
  inspectorBody.innerHTML = inspectorMarkup();
  bindDynamicEvents();
}

function setAnalysis(tab) {
  analysisTab = tab;
  document.querySelectorAll('[data-analysis]').forEach((button) => button.classList.toggle('active', button.dataset.analysis === tab));
  analysisBody.innerHTML = analysisMarkup();
  bindDynamicEvents();
}

function openPreview() {
  const source = sanitizePreviewTree(document.querySelector('.page-shell').cloneNode(true));
  hydratePreviewControls(source);
  hydratePreviewComponentRuntimes(source);
  document.querySelector('[data-testid="preview-surface"]').replaceChildren(source);
  document.querySelector('[data-testid="preview-role"]').value = state.role;
  document.querySelector('[data-testid="preview-surface"]').dataset.device = previewDevice;
  previewDialog.hidden = false;
  root.dataset.state = 'preview-open';
}

function previewRuntimeState(nodeId, manifest) {
  if (!previewNodeRuntimeStates.has(nodeId)) previewNodeRuntimeStates.set(nodeId, createComponentRuntimeState(manifest));
  return previewNodeRuntimeStates.get(nodeId);
}

function hydratePreviewComponentRuntimes(source) {
  source.querySelectorAll('.schema-component[data-schema-id]').forEach((element) => {
    const nodeId = element.dataset.schemaId;
    const node = state.schema.nodes[nodeId];
    const manifest = COMPONENT_MANIFESTS.find((item) => item.type === node?.type);
    if (!manifest) return;
    const hasNestedComponent = element.querySelector(':scope .schema-component') !== null;
    if (hasNestedComponent) {
      const toolbar = document.createElement('div');
      toolbar.className = 'preview-container-toolbar';
      toolbar.innerHTML = `<strong>${manifest.title}</strong><button type="button" data-runtime-action="select-node" data-runtime-node="${nodeId}" data-runtime-key="next">切换区域</button>`;
      element.prepend(toolbar);
      return;
    }
    element.outerHTML = `<div class="preview-runtime-node" data-runtime-node="${nodeId}">${renderInteractiveComponent(manifest, 'runtime', previewRuntimeState(nodeId, manifest))}</div>`;
  });
}

function rerenderOpenPreview() {
  if (previewDialog.hidden) return;
  const source = sanitizePreviewTree(document.querySelector('.page-shell').cloneNode(true));
  hydratePreviewControls(source);
  hydratePreviewComponentRuntimes(source);
  document.querySelector('[data-testid="preview-surface"]').replaceChildren(source);
  document.querySelector('[data-testid="preview-surface"]').dataset.device = previewDevice;
}

function executePreviewRuntimeControl(control) {
  const host = control.closest('[data-runtime-node]');
  if (!host) return;
  const node = state.schema.nodes[host.dataset.runtimeNode];
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === node?.type);
  if (!manifest) return;
  const current = previewRuntimeState(node.id, manifest);
  previewNodeRuntimeStates.set(node.id, executeComponentRuntimeAction(current, control.dataset.runtimeAction, runtimeActionPayload(control)));
  rerenderOpenPreview();
}

function hydratePreviewControls(source) {
  source.querySelectorAll('.field-node:not(.entry-section), .schema-field').forEach((fieldNode) => {
    const control = fieldNode.querySelector('.field-control');
    if (!control) return;
    const renderer = control.dataset.renderer;
    const readonly = control.classList.contains('readonly') || state.role === '财务审核员';
    let input;
    if (renderer === 'reference') {
      input = document.createElement('select');
      input.innerHTML = '<option value="">请选择</option><option value="CUST-001">华东工业客户</option><option value="CUST-002">北方制造客户</option>';
    } else if (renderer === 'textarea') input = document.createElement('textarea');
    else {
      input = document.createElement('input');
      input.type = renderer === 'number' ? 'number' : renderer === 'date' ? 'date' : 'text';
    }
    input.className = 'preview-input';
    input.dataset.previewField = fieldNode.dataset.schemaId || '';
    input.value = previewData[input.dataset.previewField] ?? '';
    input.disabled = readonly;
    control.replaceWith(input);
  });
}

function applyPreviewSample() {
  if (previewSample === 'empty') previewData = {};
  else if (previewSample === 'long') previewData = { orderNo: 'SO-2026-EXTREMELY-LONG-ORDER-NUMBER-000001', customer: 'CUST-002', orderDate: '2026-12-31', salesOrg: '全球销售组织华东大区智能制造事业部', amount: '99999999.99' };
  else previewData = { orderNo: 'SO-2026-0018', customer: 'CUST-001', orderDate: '2026-07-12', salesOrg: '华东销售组织', amount: '128640' };
}

function sanitizePreviewTree(source) {
  source.querySelectorAll('.selection-label, .schema-move-actions, .empty-drop-hint, .placeholder-node').forEach((node) => node.remove());
  source.querySelectorAll('.selected, .active-drop-target').forEach((node) => node.classList.remove('selected', 'active-drop-target'));
  source.querySelectorAll('*').forEach((node) => {
    node.removeAttribute('draggable');
    node.removeAttribute('data-field-id');
    node.removeAttribute('data-schema-node');
    node.removeAttribute('data-schema-drop-target');
    node.removeAttribute('data-move-command');
    if (node.classList.contains('schema-component')) {
      node.removeAttribute('role');
      node.removeAttribute('tabindex');
    }
  });
  source.removeAttribute('data-schema-drop-target');
  return source;
}

function openPublish() {
  const schemaValidation = validateSchema(state.schema);
  const dependencyAnalysis = analyzeRuleDependencies(ruleBuilderState.rules);
  const invalidRules = ruleBuilderState.rules.filter((rule) => !rule.trigger?.event || !rule.trigger?.source || !Array.isArray(rule.actions));
  const permissionCheck = permissionCoverage(permissionMatrixState, ['customer', 'amount'], ['save', 'submit', 'export']);
  const rendererGaps = Object.values(state.schema.nodes).filter((node) => {
    const manifest = COMPONENT_MANIFESTS.find((item) => item.type === node.type);
    return manifest && (manifest.status === 'planned' || !manifest.runtimeRenderer);
  });
  const result = validateForPublish(state, {
    schema: {
      status: schemaValidation.valid ? 'passed' : 'failed',
      detail: schemaValidation.valid
        ? `${Object.keys(state.schema.nodes).length} 个节点，0 个结构错误`
        : schemaValidation.errors.map((error) => error.message).join('；'),
    },
    rules: {
      status: !dependencyAnalysis.hasCycle && invalidRules.length === 0 ? 'passed' : 'failed',
      detail: dependencyAnalysis.hasCycle ? `发现规则依赖环：${dependencyAnalysis.cycle.join(' → ')}` : invalidRules.length ? `${invalidRules.length} 条规则合同不完整` : `${ruleBuilderState.rules.length} 条规则依赖与合同有效`,
    },
    permissions: {
      status: permissionCheck.complete ? 'passed' : 'failed',
      detail: permissionCheck.complete ? `${permissionMatrixState.roles.length} 个角色权限覆盖完整` : `缺少 ${permissionCheck.missing.length} 项字段或操作策略`,
    },
    renderer: {
      status: rendererGaps.length === 0 ? 'passed' : 'failed',
      detail: rendererGaps.length === 0 ? `${Object.keys(state.schema.nodes).length} 个节点具备运行 Renderer` : `${rendererGaps.length} 个节点缺少可用 Renderer`,
    },
  });
  const content = document.querySelector('[data-testid="publish-content"]');
  content.innerHTML = `
    <div class="publish-result ${result.allowed ? 'ready' : ''}" data-testid="publish-result" data-status="${result.status}">
      <header><span class="result-icon">${result.allowed ? '✓' : '!'}</span><span class="result-copy"><strong>${result.allowed ? '发布前校验通过' : '发布准备被阻断'}</strong><span>${result.message}</span></span></header>
      <div class="check-list">
        ${result.checks.map(checkRow).join('')}
      </div>
    </div>`;
  document.querySelector('[data-action="create-release"]').disabled = !result.allowed;
  publishDialog.hidden = false;
  root.dataset.state = `publish-${result.status}`;
}

function checkRow(check) {
  const passed = check.status === 'passed';
  const marker = passed ? '✓' : check.status === 'failed' ? '×' : '—';
  return `<div class="check-row"><span class="check-state ${passed ? 'pass' : 'fail'}">${marker}</span><strong>${check.label}</strong><small>${check.detail}</small></div>`;
}

function closeDialog(name) {
  document.querySelector(`[data-dialog="${name}"]`).hidden = true;
  root.dataset.state = state.activeWorkspace;
}

function toast(title, message) {
  const region = document.querySelector('[data-testid="toast-region"]');
  const element = document.createElement('div');
  element.className = 'toast';
  element.innerHTML = `<strong>${title}</strong><span>${message}</span>`;
  region.append(element);
  window.setTimeout(() => element.remove(), 3200);
}

document.querySelectorAll('[data-workspace]').forEach((button) => button.addEventListener('click', () => setWorkspace(button.dataset.workspace)));
document.querySelectorAll('[data-document-workspace]').forEach((button) => button.addEventListener('click', () => setWorkspace(button.dataset.documentWorkspace)));
document.querySelectorAll('[data-field-id]').forEach((button) => button.addEventListener('click', () => selectNode(button.dataset.fieldId)));
document.querySelectorAll('[data-inspector]').forEach((button) => button.addEventListener('click', () => setInspector(button.dataset.inspector)));
document.querySelectorAll('[data-analysis]').forEach((button) => button.addEventListener('click', () => setAnalysis(button.dataset.analysis)));
document.querySelectorAll('[data-device]').forEach((button) => button.addEventListener('click', () => { state = setDevice(state, button.dataset.device); render(); root.dataset.state = `device-${state.device}`; }));
document.querySelector('[data-business-state]').addEventListener('change', (event) => { state = setBusinessState(state, event.target.value); render(); });
document.querySelectorAll('[data-close]').forEach((button) => button.addEventListener('click', () => closeDialog(button.dataset.close)));

document.addEventListener('click', (event) => {
  const action = event.target.closest('[data-action]')?.dataset.action;
  if (!action) return;
  const actionTarget = event.target.closest('[data-action]');
  if (action === 'preview') openPreview();
  if (action === 'home') setWorkspace('model');
  if (action === 'more' || action === 'user-menu') {
    const menu = document.querySelector('[data-testid="command-menu"]');
    menu.hidden = false;
    menu.innerHTML = action === 'more'
      ? '<button type="button" data-menu-command="duplicate-selected">复制所选组件</button><button type="button" data-menu-command="delete-selected">删除所选组件</button><button type="button" data-menu-command="show-outline">在大纲中定位</button>'
      : '<button type="button" data-menu-command="save-now">立即保存</button><button type="button" data-menu-command="open-settings">设计设置</button>';
  }
  if (action === 'publish') openPublish();
  if (action === 'check') { setAnalysis('findings'); toast('检查已完成', summaryText()); }
  if (action === 'role') { state = { ...state, role: state.role === '销售主管' ? '销售专员' : '销售主管' }; render(); toast('模拟角色已切换', state.role); }
  if (action === 'zoom-in' || action === 'zoom-out') {
    zoom = Math.max(70, Math.min(110, zoom + (action === 'zoom-in' ? 10 : -10)));
    document.querySelector('[data-testid="zoom-value"]').textContent = `${zoom}%`;
    document.querySelector('[data-testid="canvas-frame"]').style.transform = `scale(${zoom / 100})`;
    root.dataset.state = `zoom-${zoom}`;
  }
  if (action === 'fit') { zoom = 90; document.querySelector('[data-testid="zoom-value"]').textContent = '90%'; document.querySelector('[data-testid="canvas-frame"]').style.transform = 'scale(.9)'; root.dataset.state = 'zoom-fit'; }
  if (action === 'undo') {
    const next = undo(state);
    if (next === state) toast('没有可撤销操作', '当前草稿历史已到起点');
    else { state = next; render(); toast('已撤销', '页面 Schema 已恢复到上一步'); }
  }
  if (action === 'redo') {
    const next = redo(state);
    if (next === state) toast('没有可重做操作', '请先执行新的设计操作');
    else { state = next; render(); toast('已重做', '页面 Schema 已恢复下一步'); }
  }
  if (action === 'add-field') { resourceTab = 'fields'; render(); toast('字段面板已打开', '选择未使用字段添加到当前分区'); }
  if (action === 'settings' || action === 'collapse-left' || action === 'collapse-analysis') {
    commandState = executeDesignerCommand(commandState, action);
    render();
    toast('界面状态已更新', action === 'settings' ? '设计设置状态已切换' : '面板显示状态已切换');
  }
  if (action === 'add-rule') {
    commandState = executeDesignerCommand(commandState, 'add-rule');
    ruleBuilderState = executeRuleBuilderCommand(ruleBuilderState, 'duplicate-rule');
    render();
    toast('规则已创建', ruleBuilderState.selectedRuleId || commandState.selectedRuleId);
  }
  if (action === 'select-page-tab') {
    commandState = executeDesignerCommand(commandState, action, { tab: actionTarget.dataset.pageTab });
    render();
  }
  if (action === 'save-draft' || action === 'submit-runtime') {
    commandState = executeDesignerCommand(commandState, action);
    state = { ...state, dirty: action !== 'save-draft', statusMessage: action === 'save-draft' ? '运行数据已暂存' : '运行表单已提交' };
    if (action === 'save-draft') saveDesignerWorkspace();
    render();
    toast(action === 'save-draft' ? '暂存完成' : '提交完成', action === 'save-draft' ? '本地原型运行数据已保存' : '运行态已进入提交结果状态');
  }
  if (action === 'add-entry-row') {
    commandState = executeDesignerCommand(commandState, action);
    render();
    toast('已增加分录行', `当前 ${commandState.entryRows.length} 行`);
  }
  if (action === 'batch-fill') {
    commandState = executeDesignerCommand(commandState, action, { values: { warehouse: 'W-01' } });
    render();
    toast('批量填充完成', `${commandState.entryRows.length} 行已写入默认仓库`);
  }
  if (action === 'column-settings') {
    commandState = executeDesignerCommand(commandState, action);
    render();
    toast('列设置已更新', commandState.columnSettingsOpen ? '列设置面板已打开' : '列设置面板已关闭');
  }
  if (action === 'view-difference') {
    commandState = executeDesignerCommand(commandState, action, { differenceId: actionTarget.dataset.differenceId });
    toast('差异已定位', commandState.activeDifferenceId);
  }
  if (action === 'locate-finding') {
    const findingId = actionTarget.closest('[data-finding-id]')?.dataset.findingId;
    commandState = executeDesignerCommand(commandState, action, { findingId });
    toast('问题已定位', findingId || '未找到问题');
  }
  if (action === 'create-release' && !actionTarget.disabled) {
    commandState = executeDesignerCommand(commandState, action);
    const version = commandState.candidateVersion;
    closeDialog('publish');
    state = { ...state, dirty: false, statusMessage: `候选版本 v${version} 已生成` };
    render();
    toast('候选版本已生成', `版本 v${version} 等待正式发布审批`);
  }
});

document.querySelector('[data-testid="command-menu"]').addEventListener('click', (event) => {
  const command = event.target.closest('[data-menu-command]')?.dataset.menuCommand;
  if (!command) return;
  const menu = event.currentTarget;
  if (command === 'duplicate-selected' || command === 'delete-selected') {
    const result = command === 'duplicate-selected' ? duplicateNode(state.schema, state.selectedNodeId) : removeNode(state.schema, state.selectedNodeId);
    if (result.accepted) state = applySchemaTransaction(state, result.nextSchema, result.selectedNodeId, command === 'duplicate-selected' ? '已复制组件' : '已删除组件');
    else toast('操作失败', result.message);
  }
  if (command === 'show-outline') { resourceTab = 'outline'; state = switchWorkspace(state, 'page'); }
  if (command === 'open-settings') commandState = executeDesignerCommand(commandState, 'settings');
  if (command === 'save-now') { state = { ...state, dirty: false, statusMessage: '草稿已保存' }; saveDesignerWorkspace(); }
  menu.hidden = true;
  render();
});

document.querySelector('[data-testid="inspector-search"]').addEventListener('input', (event) => {
  const query = event.target.value.trim().toLocaleLowerCase('zh-CN');
  inspectorBody.querySelectorAll('.property-section').forEach((section) => { section.hidden = Boolean(query) && !section.textContent.toLocaleLowerCase('zh-CN').includes(query); });
});

document.querySelector('[data-setting="auto-save"]').addEventListener('click', () => {
  commandState = executeDesignerCommand(commandState, 'set-auto-save', { enabled: !commandState.autoSave });
  render();
});
document.querySelector('[data-setting="default-device"]').addEventListener('change', (event) => {
  commandState = executeDesignerCommand(commandState, 'set-default-device', { device: event.target.value });
  state = setDevice(state, commandState.defaultDevice);
  render();
});

document.querySelector('[data-testid="preview-role"]').addEventListener('change', (event) => {
  state = { ...state, role: event.target.value };
  document.querySelectorAll('[data-testid="preview-surface"] .preview-input').forEach((input) => { input.disabled = state.role === '财务审核员'; });
  root.dataset.state = `preview-${state.role}`;
});
document.querySelector('[data-testid="preview-surface"]').addEventListener('change', (event) => {
  const input = event.target.closest('[data-preview-field]');
  if (input) {
    previewData = { ...previewData, [input.dataset.previewField]: input.value };
    if (commandState.autoSave) saveDesignerWorkspace();
  }
  const control = event.target.closest('[data-runtime-action]');
  if (control && runtimeActionEventName(control.dataset.runtimeAction) === event.type) executePreviewRuntimeControl(control);
});
document.querySelector('[data-testid="preview-surface"]').addEventListener('click', (event) => {
  const control = event.target.closest('[data-runtime-action]');
  if (!control) return;
  if (runtimeActionEventName(control.dataset.runtimeAction) === event.type) executePreviewRuntimeControl(control);
});

document.addEventListener('keydown', (event) => {
  const selectable = event.target.closest('[role="button"][data-field-id]');
  if (selectable && (event.key === 'Enter' || event.key === ' ')) {
    event.preventDefault();
    selectNode(selectable.dataset.fieldId);
    return;
  }
  if (event.key === 'Escape') {
    if (!previewDialog.hidden) closeDialog('preview');
    if (!publishDialog.hidden) closeDialog('publish');
  }
  if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 's') {
    event.preventDefault();
    state = { ...state, dirty: false, statusMessage: '草稿已保存' };
    saveDesignerWorkspace();
    render();
    toast('保存成功', '草稿 v18 已保存到本地原型状态');
  }
});

render();
