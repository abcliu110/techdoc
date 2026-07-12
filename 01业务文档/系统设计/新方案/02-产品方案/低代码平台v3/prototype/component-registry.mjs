export const COMPONENT_CATEGORIES = Object.freeze([
  ['common', '常用推荐'],
  ['layout', '布局容器'],
  ['input', '输入字段'],
  ['reference', '业务引用'],
  ['data', '数据与单据'],
  ['hierarchy', '层级浏览'],
  ['display', '展示与媒体'],
  ['workflow', '导航与流程'],
  ['analytics', '分析与报表'],
  ['extension', '扩展能力'],
].map(([id, title]) => Object.freeze({ id, title })));

const ALL_PAGES = ['masterData', 'bill', 'dynamicForm', 'report'];
const ALL_DEVICES = ['desktop', 'tablet', 'mobile'];
const BILL_ONLY = ['bill'];

const TYPE_OVERRIDES = Object.freeze({
  text: 'TextField', money: 'MoneyField', spread: 'Spreadsheet',
  'tree-grid': 'TreeGrid', 'tree-picker': 'TreePicker', 'tree-browser': 'TreeBrowser',
  'column-browser': 'ColumnBrowser', 'entry-grid': 'EntryGrid',
  'sub-entry-grid': 'SubEntryGrid', 'tree-entry-grid': 'TreeEntryGrid',
  'tree-sub-entry-grid': 'TreeSubEntryGrid', 'card-entry': 'CardEntry',
  'sub-card-entry': 'SubCardEntry', 'embedded-analytics': 'AnalyticsWorkspace',
});

function protocolType(type) {
  return TYPE_OVERRIDES[type] || type.split('-').map((part) => part[0].toUpperCase() + part.slice(1)).join('');
}

function define(category, type, title, aliases = [], options = {}) {
  type = protocolType(type);
  const binding = options.dataBinding || (
    category === 'input' ? 'field' : category === 'reference' ? 'reference' : category === 'data' ? 'entity' : 'none'
  );
  return Object.freeze({
    type,
    title,
    aliases,
    category,
    icon: options.icon || title.slice(0, 1),
    status: options.status || 'ready',
    supportedPageTypes: options.supportedPageTypes || ALL_PAGES,
    supportedDevices: options.supportedDevices || ALL_DEVICES,
    dataBinding: binding,
    rootAllowed: options.rootAllowed ?? category !== 'common',
    accepts: options.accepts || inferAcceptedChildren(category, type),
    requiresParent: options.requiresParent || [],
    defaultSchema: options.defaultSchema || { type },
    inspectorPanels: options.inspectorPanels || ['property', 'layout', 'rule', 'permission'],
    runtimeRenderer: options.runtimeRenderer || `${type}-renderer`,
  });
}

function inferAcceptedChildren(category, type) {
  if (category !== 'layout') return [];
  if (type === 'FieldLayout' || type === 'FieldGroup') return ['field', 'reference', 'FieldGroup'];
  return ['component'];
}

const GROUPS = [
  ['common', [
    ['quick-section', '常用分区', ['最近使用', '推荐组件']],
  ]],
  ['layout', [
    ['field-layout', '字段布局', ['表单布局']], ['field-group', '字段组合', ['字段组']],
    ['section', '语义分区', ['Section', '区块']], ['columns', '约束多列', ['Columns', '列布局']],
    ['flex', '弹性布局', ['Flex']], ['advanced-panel', '高级面板', ['复合面板']],
    ['tabs', '页签', ['Tabs']], ['wizard', '向导', ['步骤表单']],
    ['split-pane', '分割容器', ['Split Pane'], { supportedDevices: ['desktop'] }],
    ['dashboard-grid', '栅格看板', ['Dashboard Grid'], { supportedDevices: ['desktop', 'tablet'] }],
    ['carousel', '轮播容器', ['Carousel']], ['drawer', '侧边栏/抽屉', ['Drawer', '侧滑面板']],
  ]],
  ['input', [
    ['text', '单行文本', ['Text']], ['textarea', '多行文本', ['Textarea']],
    ['multilingual-text', '多语言文本', ['i18n 文本']], ['masked-text', '掩码文本', ['Mask']],
    ['password', '密码', ['Password']], ['integer', '整数', ['Integer']],
    ['decimal', '小数', ['Decimal']], ['money', '金额', ['Money', '货币']],
    ['percent', '百分比', ['Percent']], ['measurement', '计量单位', ['单位数值']],
    ['stepper', '步进器', ['Stepper']], ['date', '日期', ['Date']],
    ['time', '时间', ['Time']], ['datetime', '日期时间', ['DateTime']],
    ['date-range', '日期范围', ['Date Range']], ['select', '下拉选择', ['Select']],
    ['radio-group', '单选组', ['Radio']], ['checkbox-group', '复选组', ['Checkbox']],
    ['switch', '开关', ['Switch']], ['cascader', '级联选择', ['Cascader']],
    ['tag-select', '标签选择', ['Tag Select']], ['rich-text-input', '富文本输入', ['Rich Text']],
    ['markdown-input', 'Markdown 输入', ['Markdown']], ['attachment', '附件', ['Attachment', '文件']],
    ['image-upload', '图片上传', ['Image Upload']],
  ]],
  ['reference', [
    ['reference-picker', '基础资料选择', ['基础资料', 'Reference Picker']],
    ['tree-reference-picker', '树形基础资料选择', ['树形基础资料']],
    ['parent-reference', '上级基础资料', ['父级资料']], ['group-picker', '分组选择', ['业务分组']],
    ['organization-picker', '组织选择', ['组织']], ['person-picker', '人员选择', ['人员']],
    ['department-picker', '部门选择', ['部门']], ['address-picker', '地址选择', ['行政区划']],
    ['master-data-id', '主数据内码', ['MDM 内码']], ['status-enum', '状态/枚举', ['业务枚举']],
  ]],
  ['data', [
    ['data-grid', 'DataGrid', ['数据表格']], ['tree-grid', 'TreeGrid', ['树形表格']],
    ['entry-grid', '单据体', ['分录表格'], { supportedPageTypes: BILL_ONLY }],
    ['sub-entry-grid', '子单据体', ['子表', '孙级分录'], { supportedPageTypes: BILL_ONLY, requiresParent: ['EntryGrid', 'TreeEntryGrid'] }],
    ['tree-entry-grid', '树形单据体', ['层级分录'], { supportedPageTypes: BILL_ONLY }],
    ['tree-sub-entry-grid', '树形子单据体', ['树形子表'], { supportedPageTypes: BILL_ONLY, requiresParent: ['EntryGrid', 'TreeEntryGrid'] }],
    ['card-entry', '卡片分录', ['卡片单据体'], { supportedPageTypes: BILL_ONLY }],
    ['sub-card-entry', '子卡片分录', ['子卡片'], { supportedPageTypes: BILL_ONLY, requiresParent: ['CardEntry'] }],
    ['readonly-grid', '只读表格', ['查询表格'], { dataBinding: 'query' }],
    ['spread', 'Spread 电子表格', ['Spreadsheet'], { status: 'planned', supportedDevices: ['desktop'] }],
    ['query-filter', '查询过滤器', ['Filter'], { dataBinding: 'query' }],
    ['pagination', '分页器', ['Pagination'], { requiresParent: ['DataGrid', 'TreeGrid', 'ReadonlyGrid'] }],
  ]],
  ['hierarchy', [
    ['tree', 'Tree', ['树控件']], ['tree-picker', 'Tree Picker', ['树选择器']],
    ['tree-browser', 'Tree Browser', ['树浏览器']], ['column-browser', 'Column Browser', ['分栏浏览器']],
  ]],
  ['display', [
    ['heading', '标题', ['Heading']], ['text-display', '文本展示', ['Text Display']],
    ['divider', '分隔线', ['Divider']], ['badge', '徽标', ['Badge']],
    ['alert', '提示', ['Alert']], ['empty-state', '空状态', ['Empty State']],
    ['progress', '进度', ['Progress']], ['statistic', '统计指标', ['Statistic']],
    ['timeline', '时间线', ['Timeline']], ['image', '图片', ['Image']],
    ['audio', '音频', ['Audio']], ['video', '视频', ['Video']],
    ['map', '地图', ['Map']], ['qrcode', '二维码', ['QR Code']],
    ['rich-text-display', '富文本展示', ['Rich Text Display']], ['markdown-display', 'Markdown 展示', ['Markdown Display']],
    ['web-office', 'WebOffice', ['Office'], { status: 'planned', supportedDevices: ['desktop'] }],
  ]],
  ['workflow', [
    ['action-bar', '操作栏', ['Action Bar']], ['button-group', '按钮组', ['Button Group']],
    ['context-menu', '上下文菜单', ['Context Menu']], ['navigation-menu', '导航菜单', ['Navigation']],
    ['tree-menu', '树形菜单', ['Tree Menu']], ['breadcrumb', '面包屑', ['Breadcrumb']],
    ['status-bar', '状态条', ['Status Bar']], ['approval-records', '审批记录', ['Approval']],
    ['process-trace', '流程轨迹', ['Process Trace']], ['operation-log', '操作日志', ['Audit Log']],
    ['comments', '评论协作', ['Comments']],
  ]],
  ['analytics', [
    ['metric-card', '指标卡', ['KPI']], ['chart', '基础图表', ['Chart']],
    ['combo-chart', '组合图表', ['Combo Chart']], ['pivot-table', '透视表', ['Pivot']],
    ['report-list', '报表列表', ['Report List'], { supportedPageTypes: ['report'] }],
    ['report-tree', '报表树', ['Report Tree'], { supportedPageTypes: ['report'] }],
    ['analytics-filter', '分析筛选器', ['Analytics Filter'], { dataBinding: 'query' }],
    ['embedded-analytics', '嵌入式分析工作区', ['轻分析', 'BI'], { status: 'planned' }],
  ]],
  ['extension', [
    ['iframe', 'IFrame', ['网页嵌入'], { status: 'preview' }],
    ['html', 'HTML', ['HTML 片段'], { status: 'preview' }],
    ['custom-component', '自定义组件', ['Custom Component'], { status: 'preview' }],
    ['component-composition', '组件组合', ['Composite']],
    ['page-fragment', '页面片段', ['Fragment']], ['business-template', '业务模板', ['Template']],
  ]],
];

export const COMPONENT_MANIFESTS = Object.freeze(GROUPS.flatMap(([category, items]) =>
  items.map(([type, title, aliases, options]) => define(category, type, title, aliases, options)),
));

export function evaluateComponent(manifest, context = {}) {
  const pageType = context.pageType || 'dynamicForm';
  if (manifest.status === 'planned') return { enabled: false, reason: '规划中：运行时尚未接入' };
  if (!manifest.supportedPageTypes.includes(pageType)) {
    return { enabled: false, reason: manifest.supportedPageTypes.includes('bill') ? '仅单据页面可用' : '当前页面类型不可用' };
  }
  if (manifest.requiresParent.length > 0 && !manifest.requiresParent.some((type) => (context.ancestorTypes || []).includes(type))) {
    const label = manifest.type.includes('sub-') ? '请先创建并选择父单据体' : `需要父组件：${manifest.requiresParent.join(' / ')}`;
    return { enabled: false, reason: label };
  }
  return { enabled: true, reason: '' };
}

export function filterComponents(context = {}) {
  const query = (context.query || '').trim().toLocaleLowerCase('zh-CN');
  return COMPONENT_MANIFESTS
    .filter((manifest) => !query || [manifest.type, manifest.title, ...manifest.aliases].some((value) => value.toLocaleLowerCase('zh-CN').includes(query)))
    .filter((manifest) => !context.category || manifest.category === context.category)
    .map((manifest) => ({ ...manifest, availability: evaluateComponent(manifest, context) }));
}

const COMPONENT_BY_TYPE = new Map(COMPONENT_MANIFESTS.map((manifest) => [manifest.type, manifest]));

export const INTERNAL_NODE_TYPES = Object.freeze([
  'FormPage', 'Column', 'TabPane', 'WizardStep', 'SplitRegion', 'DashboardCard',
]);

const INTERNAL_NODE_LABELS = Object.freeze({
  FormPage: '页面', Column: '列', TabPane: '页签页', WizardStep: '向导步骤',
  SplitRegion: '分割区域', DashboardCard: '看板卡片',
});

export function isRegisteredComponent(type) {
  return COMPONENT_BY_TYPE.has(type);
}

export function isKnownNodeType(type) {
  return isRegisteredComponent(type) || INTERNAL_NODE_TYPES.includes(type);
}

export function getNodeLabel(type) {
  return getManifest(type)?.title || INTERNAL_NODE_LABELS[type] || type;
}

export function acceptsChild(parentType, childType) {
  if (!isKnownNodeType(parentType) || !isKnownNodeType(childType) || childType === 'FormPage') return false;
  if (parentType === 'FormPage') {
    const child = getManifest(childType);
    return Boolean(child?.rootAllowed && child.requiresParent.length === 0);
  }

  const structuralRules = {
    Columns: ['Column'],
    Tabs: ['TabPane'],
    Wizard: ['WizardStep'],
    SplitPane: ['SplitRegion'],
    DashboardGrid: ['DashboardCard'],
    EntryGrid: ['SubEntryGrid'],
    TreeEntryGrid: ['SubEntryGrid', 'TreeSubEntryGrid'],
    CardEntry: ['SubCardEntry'],
  };
  if (structuralRules[parentType]) return structuralRules[parentType].includes(childType);

  const parent = getManifest(parentType);
  if (!parent) return ['Column', 'TabPane', 'WizardStep', 'SplitRegion', 'DashboardCard'].includes(parentType);
  const child = getManifest(childType);
  if (!child) return false;
  if (child.requiresParent.length > 0) return child.requiresParent.includes(parentType);
  return parent.accepts.some((accepted) => (
    accepted === 'component'
    || accepted === childType
    || accepted === child.category
    || accepted === child.dataBinding
  ));
}

export function getManifest(type) {
  return COMPONENT_BY_TYPE.get(type);
}

export function searchComponents(query, context = {}) {
  return filterComponents({ ...context, query });
}

export function getAvailability(type, context = {}) {
  const manifest = getManifest(type);
  if (!manifest) return { available: false, state: 'blocked', reasonCode: 'UNKNOWN_COMPONENT', message: '未知组件' };
  const pageType = context.pageType || 'dynamicForm';
  const device = context.device || 'desktop';
  if (!manifest.supportedPageTypes.includes(pageType)) {
    return { available: false, state: 'blocked', reasonCode: 'PAGE_TYPE_UNSUPPORTED', message: '当前页面类型不支持此组件' };
  }
  if (!manifest.supportedDevices.includes(device)) {
    return { available: false, state: 'blocked', reasonCode: 'DEVICE_UNSUPPORTED', message: '当前设备不支持此组件' };
  }
  if (manifest.status === 'planned') {
    return { available: false, state: 'planned', reasonCode: 'COMPONENT_PLANNED', message: '组件规划中' };
  }
  if (manifest.requiresParent.length > 0 && !manifest.requiresParent.some((parent) => (context.schemaNodeTypes || []).includes(parent))) {
    const entryDependent = manifest.requiresParent.some((parent) => ['EntryGrid', 'TreeEntryGrid', 'CardEntry'].includes(parent));
    return {
      available: false,
      state: 'blocked',
      reasonCode: entryDependent ? 'PARENT_ENTRY_REQUIRED' : 'REQUIRED_PARENT_MISSING',
      message: entryDependent ? '请先创建并绑定父单据体' : `需要父组件：${manifest.requiresParent.map(getNodeLabel).join(' / ')}`,
    };
  }
  return { available: true, state: manifest.status, reasonCode: null, message: '' };
}
