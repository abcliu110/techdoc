import {
  createDesignerState,
  selectField,
  switchWorkspace,
  validateForPublish,
} from './designer-state.mjs';

let state = createDesignerState();
let resourceTab = 'components';
let inspectorTab = 'property';
let analysisTab = 'findings';
let zoom = 90;

const root = document.querySelector('[data-testid="designer-root"]');
const resourceContent = document.querySelector('[data-testid="resource-content"]');
const resourceTitle = document.querySelector('[data-testid="resource-title"]');
const resourceSubtitle = document.querySelector('[data-testid="resource-subtitle"]');
const inspectorBody = document.querySelector('[data-testid="inspector-body"]');
const analysisBody = document.querySelector('[data-testid="analysis-body"]');
const previewDialog = document.querySelector('[data-dialog="preview"]');
const publishDialog = document.querySelector('[data-dialog="publish"]');

const FIELD_DETAILS = {
  orderNo: { title: '订单编码', type: '文本字段', code: 'orderNo', binding: 'SalesOrder.orderNo', required: true, readonly: true, width: '1/3', help: '系统按编码规则自动生成' },
  customer: { title: '客户', type: '基础资料字段', code: 'customer', binding: 'SalesOrder.customerId', required: true, readonly: false, width: '1/3', help: '选择已启用的客户档案' },
  orderDate: { title: '订单日期', type: '日期字段', code: 'orderDate', binding: 'SalesOrder.orderDate', required: true, readonly: false, width: '1/3', help: '默认使用当前业务日期' },
  salesOrg: { title: '销售组织', type: '组织字段', code: 'salesOrg', binding: 'SalesOrder.salesOrgId', required: false, readonly: false, width: '1/3', help: '受当前用户组织权限约束' },
  amount: { title: '含税金额', type: '金额字段', code: 'amount', binding: 'SalesOrder.totalAmount', required: false, readonly: true, width: '1/3', help: '由分录价税合计汇总' },
  entries: { title: '销售订单分录', type: '分录表格', code: 'entries', binding: 'SalesOrder.entries', required: true, readonly: false, width: '整行', help: '支持冻结列、批量录入和行列权限' },
};

const WORKSPACE_META = {
  model: ['业务对象', '实体、字段、关系与索引'],
  page: ['页面资源', '组件、字段与页面结构'],
  rules: ['规则编排', '界面规则与业务规则'],
  permissions: ['权限设计', '角色、字段与操作权限'],
  preview: ['运行预览', '角色、数据与设备环境'],
};

function resourceMarkup() {
  if (state.activeWorkspace === 'model') {
    return `
      <label class="search-box"><span>⌕</span><input type="search" placeholder="搜索业务对象或字段"></label>
      <div class="object-list">
        ${objectRow('销售订单', 'SalesOrder', '18 字段', true)}
        ${objectRow('销售订单分录', 'SalesOrderEntry', '12 字段')}
        ${objectRow('客户', 'Customer', '24 字段')}
        ${objectRow('物料', 'Material', '31 字段')}
        ${objectRow('销售组织', 'SalesOrganization', '9 字段')}
      </div>
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
    return `
      <div class="resource-tabs"><button class="resource-tab active">全部规则</button><button class="resource-tab">界面</button><button class="resource-tab">业务</button></div>
      <label class="search-box"><span>⌕</span><input type="search" placeholder="搜索规则、字段或动作"></label>
      <div class="rule-list">
        ${ruleRow('R-001', '客户变更带出信用信息', '客户 · 3 个动作', true)}
        ${ruleRow('R-002', '分录金额自动汇总', '销售订单分录 · 2 个动作', true)}
        ${ruleRow('R-003', '超信用额度提示', '含税金额 · 1 个动作', false)}
        ${ruleRow('R-004', '空客户阻止提交', '提交前 · 1 个校验', true)}
      </div>
      <button class="button secondary panel-create" type="button" data-action="add-rule">＋ 新建规则</button>`;
  }

  if (state.activeWorkspace === 'permissions') {
    return `
      <label class="search-box"><span>⌕</span><input type="search" placeholder="搜索角色或权限项"></label>
      <div class="object-list">
        ${objectRow('销售主管', 'SalesManager', '完整编辑', true)}
        ${objectRow('销售专员', 'SalesRepresentative', '受限编辑')}
        ${objectRow('财务审核员', 'FinanceAuditor', '金额可见')}
        ${objectRow('仓储人员', 'WarehouseOperator', '交付字段')}
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
        <label class="property-row"><span>数据样本</span><select class="property-select"><option>销售订单示例 01</option><option>空数据</option><option>极限长文本</option></select></label>
        <label class="property-row"><span>设备</span><select class="property-select"><option>桌面 1440</option><option>桌面 1920</option><option>平板 1024</option></select></label>
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
    <label class="search-box"><span>⌕</span><input type="search" placeholder="搜索组件、字段或节点" data-resource-search></label>
    ${pageResourceBody()}`;
}

function pageResourceBody() {
  if (resourceTab === 'fields') {
    return `<div class="tree-list">
      ${treeRow('Aa', '订单编码', '文本 · 已使用', 'orderNo', 0)}
      ${treeRow('客', '客户', '基础资料 · 已使用', 'customer', 0, true)}
      ${treeRow('日', '订单日期', '日期 · 已使用', 'orderDate', 0)}
      ${treeRow('组', '销售组织', '组织 · 已使用', 'salesOrg', 0)}
      ${treeRow('¥', '含税金额', '金额 · 已使用', 'amount', 0)}
      ${treeRow('#', '信用额度', '金额 · 未使用', 'creditLimit', 0)}
      ${treeRow('地', '收货地址', '地址 · 未使用', 'address', 0)}
    </div>`;
  }
  if (resourceTab === 'outline') {
    return `<div class="tree-list">
      ${treeRow('页', '销售订单', 'FormPage', '', 0)}
      ${treeRow('区', '基本信息', 'FormSection', '', 1)}
      ${treeRow('客', '客户', 'ReferenceField', 'customer', 2, true)}
      ${treeRow('日', '订单日期', 'DateField', 'orderDate', 2)}
      ${treeRow('表', '销售订单分录', 'EntryTable', 'entries', 1)}
      ${treeRow('栏', '底部操作栏', 'ActionBar', '', 1)}
    </div>`;
  }
  return `
    ${resourceGroup('布局容器', [['▦','栅格'],['⇆','弹性行'],['▤','分区'],['页','页签'],['↕','分割面板'],['⌑','侧边栏']])}
    ${resourceGroup('业务字段', [['Aa','文本'],['#','数值'],['日','日期'],['客','基础资料'],['组','组织'],['人','人员']])}
    ${resourceGroup('业务组件', [['表','分录表格'],['栏','操作栏'],['态','状态条'],['审','审批记录'],['附','附件'],['志','操作日志']])}`;
}

function resourceGroup(title, items) {
  return `<div class="resource-group"><button type="button"><span>${title}</span><span>⌃</span></button><div class="resource-items">${items.map(([icon, label]) => `<button class="resource-item" type="button" data-add-component="${label}"><span class="resource-icon">${icon}</span><span>${label}</span></button>`).join('')}</div></div>`;
}

function objectRow(title, code, meta, active = false) {
  return `<button type="button" class="object-row ${active ? 'active' : ''}"><span class="tree-type">BO</span><span class="row-copy"><strong>${title}</strong><span>${code}</span></span><span class="mini-badge">${meta}</span></button>`;
}

function treeRow(icon, title, meta, id = '', depth = 0, active = false) {
  return `<button type="button" class="tree-row depth-${depth} ${active ? 'active' : ''}" ${id ? `data-field-id="${id}"` : ''}><span class="tree-type">${icon}</span><span class="row-copy"><strong>${title}</strong><span>${meta}</span></span></button>`;
}

function ruleRow(code, title, meta, enabled) {
  return `<button type="button" class="rule-row ${code === 'R-001' ? 'active' : ''}" data-rule="${code}"><span class="tree-type">◇</span><span class="row-copy"><strong>${title}</strong><span>${code} · ${meta}</span></span><span class="mini-badge ${enabled ? 'on' : ''}">${enabled ? '启用' : '停用'}</span></button>`;
}

function inspectorMarkup() {
  const field = FIELD_DETAILS[state.selectedNodeId] || FIELD_DETAILS.customer;
  if (inspectorTab === 'layout') {
    return `${propertySection('栅格与尺寸', `
      ${propertyRow('占用列宽', `<select class="property-select"><option>${field.width}</option><option>1/2</option><option>整行</option></select>`)}
      ${propertyRow('最小宽度', '<input class="property-input" value="220 px">')}
      ${propertyRow('标签位置', '<select class="property-select"><option>顶部</option><option>左侧</option></select>')}
      ${propertyRow('对齐方式', '<select class="property-select"><option>自动</option><option>起始</option><option>拉伸</option></select>')}
    `)}${propertySection('间距', `${propertyRow('外边距', '<input class="property-input" value="8 / 8 / 8 / 8">')}${propertyRow('内边距', '<input class="property-input" value="0 / 0 / 0 / 0">')}`)}${propertySection('响应式', `<div class="risk-note">当前版本以企业桌面端为主。最窄支持视口 1280px，低于该宽度进入受限模式。</div>`)}`;
  }
  if (inspectorTab === 'rule') {
    return `${propertySection('关联规则', `
      <div class="rule-card"><strong>R-001 客户变更带出信用信息</strong><span>当客户变化时，刷新信用额度、结算方式和价格政策。</span><button class="link-button" type="button" data-workspace-jump="rules">打开规则</button></div>
      <div class="rule-card"><strong>R-004 空客户阻止提交</strong><span>提交前校验客户非空，否则阻止操作并定位字段。</span></div>
    `)}${propertySection('字段事件', `${propertyRow('值变化', '<select class="property-select"><option>执行 R-001</option></select>')}${propertyRow('校验失败', '<select class="property-select"><option>定位并提示</option></select>')}`)}`;
  }
  if (inspectorTab === 'permission') {
    return `${propertySection('角色覆盖', `
      <div class="permission-card"><strong>销售主管</strong><span>可见 · 可编辑 · 可导出</span></div>
      <div class="permission-card"><strong>销售专员</strong><span>可见 · 可编辑 · 不可导出</span></div>
      <div class="permission-card"><strong>财务审核员</strong><span>可见 · 只读 · 可导出</span></div>
    `)}${propertySection('敏感数据', `${switchControl('字段脱敏', false)}${switchControl('记录审计', true)}<div class="risk-note">页面权限只能收紧服务端权限，不能扩大数据访问范围。</div>`)}`;
  }
  return `${propertySection('标识与绑定', `
    ${propertyRow('字段名称', `<input class="property-input" data-property="label" value="${field.title}">`)}
    ${propertyRow('字段编码', `<input class="property-input" value="${field.code}" readonly>`)}
    ${propertyRow('控件类型', `<select class="property-select"><option>${field.type}</option><option>文本字段</option></select>`)}
    <div class="binding-card"><strong>${field.binding}</strong><span>双向绑定 · 类型一致 · 权限已继承</span></div>
  `)}${propertySection('显示与交互', `
    ${switchControl('必填', field.required, 'required')}
    ${switchControl('只读', field.readonly, 'readonly')}
    ${switchControl('显示标签', true)}
    ${propertyRow('帮助信息', `<input class="property-input" value="${field.help}">`)}
  `)}${propertySection('数据与校验', `
    ${propertyRow('提交策略', '<select class="property-select"><option>值变化时提交</option><option>始终提交</option></select>')}
    ${propertyRow('空值策略', '<select class="property-select"><option>保留 null</option><option>使用默认值</option></select>')}
    <div class="risk-note">字段变更会影响 2 条规则和 3 个角色权限。发布前将重新执行影响分析。</div>
  `)}`;
}

function propertySection(title, content) {
  return `<section class="property-section"><button type="button"><span>${title}</span><span>⌃</span></button><div class="property-content">${content}</div></section>`;
}

function propertyRow(label, control) {
  return `<label class="property-row"><span>${label}</span>${control}</label>`;
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
    return `<div class="finding-row"><span class="severity">11:42</span><span class="finding-copy"><strong>客户字段标签更新</strong><span>陈设计 · 草稿 v18</span></span><button class="link-button">查看差异</button></div><div class="finding-row"><span class="severity">11:39</span><span class="finding-copy"><strong>销售主管权限集同步</strong><span>权限设计器 · 3 个字段</span></span><button class="link-button">查看差异</button></div>`;
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

  const field = FIELD_DETAILS[state.selectedNodeId] || FIELD_DETAILS.customer;
  document.querySelector('[data-testid="inspector-title"]').textContent = field.title;
  document.querySelector('[data-testid="inspector-type"]').textContent = `${field.type} · ${field.code}`;
  inspectorBody.innerHTML = inspectorMarkup();
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
  bindDynamicEvents();
}

function summaryText() {
  const open = state.findings.filter((finding) => finding.open);
  const blockers = open.filter((finding) => finding.severity === 'P0' || finding.severity === 'P1');
  return `${blockers.length} 个阻断问题，${open.length - blockers.length} 个建议`;
}

function bindDynamicEvents() {
  resourceContent.querySelectorAll('[data-resource-tab]').forEach((button) => button.addEventListener('click', () => { resourceTab = button.dataset.resourceTab; render(); }));
  resourceContent.querySelectorAll('[data-field-id]').forEach((button) => button.addEventListener('click', () => selectNode(button.dataset.fieldId)));
  resourceContent.querySelectorAll('[data-add-component]').forEach((button) => button.addEventListener('click', () => toast('组件已进入放置模式', `请选择画布位置以添加“${button.dataset.addComponent}”`)));
  resourceContent.querySelectorAll('[data-action="preview"]').forEach((button) => button.addEventListener('click', openPreview));
  resourceContent.querySelector('[data-resource-role]')?.addEventListener('change', (event) => { state = { ...state, role: event.target.value }; render(); });

  inspectorBody.querySelector('[data-property="label"]')?.addEventListener('change', (event) => {
    const field = FIELD_DETAILS[state.selectedNodeId];
    field.title = event.target.value.trim() || field.title;
    state = { ...state, inspectorTitle: field.title, breadcrumb: [...state.breadcrumb.slice(0, -1), field.title], dirty: true };
    render();
    toast('属性已更新', '字段标签已同步到画布和路径');
  });
  inspectorBody.querySelectorAll('[data-toggle-property]').forEach((button) => button.addEventListener('click', () => {
    button.classList.toggle('on');
    button.setAttribute('aria-checked', String(button.classList.contains('on')));
    state = { ...state, dirty: true };
    document.querySelector('[data-testid="save-state"]').textContent = '有未保存变更';
  }));
  inspectorBody.querySelector('[data-workspace-jump]')?.addEventListener('click', () => setWorkspace('rules'));

  analysisBody.querySelector('[data-action="resolve-blocker"]')?.addEventListener('click', () => {
    state = { ...state, findings: state.findings.map((finding) => finding.id === 'F-PERM-001' ? { ...finding, open: false } : finding), statusMessage: '已补充客户信用额度导出权限策略', dirty: true };
    render();
    toast('阻断问题已关闭', '发布准备将重新计算权限覆盖');
  });
}

function selectNode(fieldId) {
  if (!FIELD_DETAILS[fieldId]) return;
  state = selectField(state, fieldId);
  render();
}

function setWorkspace(workspace) {
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
  const source = document.querySelector('.page-shell').cloneNode(true);
  source.querySelectorAll('.selection-label').forEach((node) => node.remove());
  source.querySelectorAll('.selected').forEach((node) => node.classList.remove('selected'));
  source.querySelectorAll('[data-field-id]').forEach((node) => node.removeAttribute('data-field-id'));
  document.querySelector('[data-testid="preview-surface"]').replaceChildren(source);
  document.querySelector('[data-testid="preview-role"]').value = state.role;
  previewDialog.hidden = false;
  root.dataset.state = 'preview-open';
}

function openPublish() {
  const result = validateForPublish(state);
  const content = document.querySelector('[data-testid="publish-content"]');
  content.innerHTML = `
    <div class="publish-result ${result.allowed ? 'ready' : ''}" data-testid="publish-result" data-status="${result.status}">
      <header><span class="result-icon">${result.allowed ? '✓' : '!'}</span><span class="result-copy"><strong>${result.allowed ? '发布前校验通过' : '发布准备被阻断'}</strong><span>${result.message}</span></span></header>
      <div class="check-list">
        ${checkRow('Schema 结构与字段引用', true, '18 个字段，0 个断裂引用')}
        ${checkRow('规则依赖与循环检测', true, '4 条规则，无循环')}
        ${checkRow('角色与字段权限覆盖', result.allowed, result.allowed ? '4 个角色覆盖完整' : '客户信用额度缺少导出策略')}
        ${checkRow('运行态兼容性', true, 'Renderer 2.4 · 兼容')}
      </div>
    </div>`;
  document.querySelector('[data-action="create-release"]').disabled = !result.allowed;
  publishDialog.hidden = false;
  root.dataset.state = `publish-${result.status}`;
}

function checkRow(label, pass, detail) {
  return `<div class="check-row"><span class="check-state ${pass ? 'pass' : 'fail'}">${pass ? '✓' : '×'}</span><strong>${label}</strong><small>${detail}</small></div>`;
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
document.querySelectorAll('[data-field-id]').forEach((button) => button.addEventListener('click', () => selectNode(button.dataset.fieldId)));
document.querySelectorAll('[data-inspector]').forEach((button) => button.addEventListener('click', () => setInspector(button.dataset.inspector)));
document.querySelectorAll('[data-analysis]').forEach((button) => button.addEventListener('click', () => setAnalysis(button.dataset.analysis)));
document.querySelectorAll('[data-view]').forEach((button) => button.addEventListener('click', () => { document.querySelectorAll('[data-view]').forEach((item) => item.classList.toggle('active', item === button)); toast('视图已切换', `当前视图：${button.textContent}`); }));
document.querySelectorAll('[data-device]').forEach((button) => button.addEventListener('click', () => { document.querySelectorAll('[data-device]').forEach((item) => item.classList.toggle('active', item === button)); document.querySelector('[data-testid="canvas-frame"]').dataset.device = button.dataset.device; root.dataset.state = `device-${button.dataset.device}`; }));
document.querySelectorAll('[data-close]').forEach((button) => button.addEventListener('click', () => closeDialog(button.dataset.close)));

document.addEventListener('click', (event) => {
  const action = event.target.closest('[data-action]')?.dataset.action;
  if (!action) return;
  if (action === 'preview') openPreview();
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
  if (action === 'undo') toast('没有可撤销操作', '当前草稿历史已到起点');
  if (action === 'redo') toast('没有可重做操作', '请先执行新的设计操作');
  if (action === 'add-field') { resourceTab = 'fields'; render(); toast('字段面板已打开', '选择未使用字段添加到当前分区'); }
  if (action === 'create-release') { closeDialog('publish'); state = { ...state, dirty: false, statusMessage: '候选版本 v19 已生成' }; render(); toast('候选版本已生成', '版本 v19 等待正式发布审批'); }
});

document.querySelector('[data-testid="preview-role"]').addEventListener('change', (event) => {
  state = { ...state, role: event.target.value };
  const customer = document.querySelector('[data-testid="preview-surface"] .reference');
  if (customer) customer.classList.toggle('readonly', state.role === '财务审核员');
  root.dataset.state = `preview-${state.role}`;
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
    render();
    toast('保存成功', '草稿 v18 已保存到本地原型状态');
  }
});

render();
