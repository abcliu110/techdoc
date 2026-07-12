const KIND_BY_TYPE = Object.freeze({
  Textarea: 'textarea', MultilingualText: 'locale-text', MaskedText: 'masked-input', Password: 'password',
  Integer: 'number', Decimal: 'number', MoneyField: 'money', Percent: 'percent', Measurement: 'measurement', Stepper: 'stepper',
  Date: 'date', Time: 'time', Datetime: 'datetime-local', DateRange: 'date-range', Select: 'select', RadioGroup: 'radio', CheckboxGroup: 'checkbox', Switch: 'switch', Cascader: 'cascader', TagSelect: 'tags',
  RichTextInput: 'rich-text', MarkdownInput: 'markdown', Attachment: 'file', ImageUpload: 'image-upload',
  ReferencePicker: 'reference', TreeReferencePicker: 'tree-reference', ParentReference: 'reference', GroupPicker: 'reference', OrganizationPicker: 'reference', PersonPicker: 'reference', DepartmentPicker: 'reference', AddressPicker: 'address', MasterDataId: 'readonly-id', StatusEnum: 'select',
  DataGrid: 'grid', TreeGrid: 'tree-grid', EntryGrid: 'entry-grid', SubEntryGrid: 'sub-grid', TreeEntryGrid: 'tree-entry-grid', TreeSubEntryGrid: 'tree-sub-grid', CardEntry: 'card-list', SubCardEntry: 'sub-card-list', ReadonlyGrid: 'readonly-grid', Spreadsheet: 'spreadsheet', QueryFilter: 'query-filter', Pagination: 'pagination',
  Tree: 'tree', TreePicker: 'tree-picker', TreeBrowser: 'tree-browser', ColumnBrowser: 'column-browser',
  Heading: 'heading', TextDisplay: 'text', Divider: 'divider', Badge: 'badge', Alert: 'alert', EmptyState: 'empty', Progress: 'progress', Statistic: 'statistic', Timeline: 'timeline', Image: 'image', Audio: 'audio', Video: 'video', Map: 'map', Qrcode: 'qrcode', RichTextDisplay: 'rich-text-display', MarkdownDisplay: 'markdown-display', WebOffice: 'office',
  ActionBar: 'actions', ButtonGroup: 'buttons', ContextMenu: 'context-menu', NavigationMenu: 'navigation', TreeMenu: 'tree-menu', Breadcrumb: 'breadcrumb', StatusBar: 'status', ApprovalRecords: 'approval', ProcessTrace: 'process', OperationLog: 'log', Comments: 'comments',
  MetricCard: 'metric', Chart: 'chart', ComboChart: 'combo-chart', PivotTable: 'pivot', ReportList: 'report-list', ReportTree: 'report-tree', AnalyticsFilter: 'analytics-filter', AnalyticsWorkspace: 'analytics-workspace',
  Iframe: 'iframe', Html: 'html', CustomComponent: 'custom', ComponentComposition: 'composition', PageFragment: 'fragment', BusinessTemplate: 'template',
  QuickSection: 'section', FieldLayout: 'field-layout', FieldGroup: 'field-group', Section: 'section', Columns: 'columns', Flex: 'flex', AdvancedPanel: 'panel', Tabs: 'tabs', Wizard: 'wizard', SplitPane: 'split', DashboardGrid: 'dashboard', Carousel: 'carousel', Drawer: 'drawer',
});

function defaultKind(manifest) {
  return KIND_BY_TYPE[manifest.type] || (manifest.category === 'input' ? 'text-input' : manifest.category);
}

function actionsFor(kind, manifest) {
  if (manifest.status === 'planned') return [];
  if (manifest.category === 'common' || manifest.category === 'layout') return ['select-node'];
  if (manifest.category === 'reference') return ['select'];
  if (manifest.category === 'hierarchy') return ['expand', 'select-node'];
  if (['text-input','textarea','locale-text','masked-input','password','number','money','percent','measurement','stepper','date','time','datetime-local','date-range','rich-text','markdown','address'].includes(kind)) return ['set-value'];
  if (['select','radio','checkbox','cascader','tags','reference','tree-reference','tree-picker'].includes(kind)) return ['select'];
  if (kind === 'switch') return ['toggle'];
  if (['file','image-upload'].includes(kind)) return ['add-file','remove-file'];
  if (manifest.category === 'data' && kind !== 'pagination') return ['add-row','remove-row'];
  if (kind === 'pagination') return ['next-page','previous-page'];
  if (kind === 'qrcode') return ['set-value'];
  if (['chart','combo-chart','pivot','metric','report-list','analytics-filter'].includes(kind)) return ['select-node','refresh'];
  if (['audio','video'].includes(kind)) return ['toggle-play'];
  if (['map'].includes(kind)) return ['set-location'];
  if (kind === 'comments') return ['add-comment'];
  if (manifest.category === 'workflow') return ['trigger-command'];
  if (manifest.category === 'analytics') return ['select-node'];
  if (manifest.category === 'extension') return ['trigger-command'];
  return ['trigger-command'];
}

export function getRuntimeContract(manifest) {
  if (!manifest?.type || !manifest.category) throw new TypeError('A registered component manifest is required');
  const controlKind = defaultKind(manifest);
  return Object.freeze({
    componentType: manifest.type,
    category: manifest.category,
    controlKind,
    valueKind: manifest.dataBinding,
    actions: Object.freeze(actionsFor(controlKind, manifest)),
    permissionModes: Object.freeze(['allow', 'readonly', 'hidden']),
    failureModes: Object.freeze(['invalid-binding', 'unsupported-context', 'runtime-error']),
    disabled: manifest.status === 'planned',
  });
}

export function buildRuntimeContracts(manifests) {
  const contracts = manifests.map(getRuntimeContract);
  if (new Set(contracts.map((item) => item.componentType)).size !== manifests.length) throw new Error('Duplicate component runtime contract');
  return Object.freeze(contracts);
}
