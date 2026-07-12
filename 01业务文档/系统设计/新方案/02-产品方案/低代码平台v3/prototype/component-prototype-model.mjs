const CATEGORY_RENDERERS = Object.freeze({
  common: 'section-layout',
  layout: 'layout-container',
  input: 'field-input',
  reference: 'business-reference',
  data: 'data-surface',
  hierarchy: 'hierarchy-browser',
  display: 'content-display',
  workflow: 'command-workflow',
  analytics: 'analytics-view',
  extension: 'sandboxed-extension',
});

const SPECIALIZED = Object.freeze({
  Columns: ['columns-layout', ['column-a', 'column-b']],
  Tabs: ['tabs-layout', ['tab-list', 'tab-panel']],
  Wizard: ['wizard-flow', ['step-navigation', 'step-content', 'validation-summary']],
  SplitPane: ['split-layout', ['primary-region', 'splitter', 'secondary-region']],
  DashboardGrid: ['dashboard-grid', ['grid-canvas', 'dashboard-card']],
  EntryGrid: ['entry-grid', ['toolbar', 'columns', 'rows', 'summary']],
  SubEntryGrid: ['sub-entry-grid', ['parent-row-context', 'child-toolbar', 'child-rows']],
  TreeEntryGrid: ['tree-entry-grid', ['tree-column', 'entry-columns', 'hierarchy-rows']],
  TreeSubEntryGrid: ['tree-sub-entry-grid', ['parent-context', 'tree-column', 'child-rows']],
  CardEntry: ['card-entry', ['toolbar', 'card-template', 'cards']],
  SubCardEntry: ['sub-card-entry', ['parent-card-context', 'child-cards']],
  DataGrid: ['data-grid', ['toolbar', 'columns', 'rows', 'pagination']],
  TreeGrid: ['tree-grid', ['tree-column', 'data-columns', 'expand-state', 'rows']],
  Tree: ['tree', ['search', 'tree-nodes', 'expand-state']],
  TreePicker: ['tree-picker', ['trigger', 'search', 'tree-nodes', 'selection']],
  TreeBrowser: ['tree-browser', ['search', 'tree-pane', 'detail-pane']],
  ColumnBrowser: ['column-browser', ['path', 'level-columns', 'selection']],
  Chart: ['chart', ['legend', 'plot', 'axes', 'empty-state']],
  ComboChart: ['combo-chart', ['legend', 'primary-series', 'secondary-series', 'axes']],
  PivotTable: ['pivot-table', ['dimensions', 'measures', 'pivot-grid']],
  CustomComponent: ['custom-component-host', ['input-contract', 'sandbox', 'output-contract', 'error-boundary']],
  ComponentComposition: ['component-composition', ['slots', 'child-components', 'input-output-map']],
  PageFragment: ['page-fragment', ['fragment-parameters', 'fragment-content']],
  BusinessTemplate: ['business-template', ['template-parameters', 'generated-content']],
  IFrame: ['iframe-host', ['url-policy', 'sandbox', 'loading-state', 'error-boundary']],
  Html: ['html-host', ['sanitized-content', 'error-boundary']],
});

const PROPERTY_GROUPS = Object.freeze({
  layout: ['structure', 'layout', 'responsive', 'visibility'],
  input: ['binding', 'value', 'validation', 'interaction', 'layout', 'permission'],
  reference: ['reference-object', 'display', 'filter', 'selection', 'permission'],
  data: ['entity-or-query', 'columns', 'rows', 'commands', 'permission'],
  hierarchy: ['data-source', 'key-mapping', 'expand', 'selection', 'loading'],
  display: ['content', 'appearance', 'empty-state', 'accessibility'],
  workflow: ['commands', 'state', 'permission', 'feedback'],
  analytics: ['dataset', 'dimensions', 'measures', 'interaction', 'empty-state'],
  extension: ['inputs', 'outputs', 'security', 'resources', 'error-boundary'],
  common: ['structure', 'layout', 'visibility'],
});

function stateContract(manifest, state) {
  if (manifest.status === 'planned') return { status: 'disabled', reason: 'component-planned' };
  if (state === 'failure') return { status: 'specified', cases: ['invalid-binding', 'unsupported-context', 'renderer-error'] };
  if (state === 'permission') return { status: 'specified', cases: ['hidden', 'readonly', 'denied'] };
  return { status: 'specified', entry: `${state}:${manifest.type}` };
}

export function componentPrototype(manifest) {
  if (!manifest?.type) throw new TypeError('A registered component manifest is required');
  const specialized = SPECIALIZED[manifest.type];
  const rendererKind = specialized?.[0] || CATEGORY_RENDERERS[manifest.category] || 'component-surface';
  const structure = specialized?.[1] || [
    manifest.category === 'input' || manifest.category === 'reference' ? 'label' : 'content',
    manifest.dataBinding === 'none' ? 'state' : 'binding',
    'feedback',
  ];
  return Object.freeze({
    componentType: manifest.type,
    title: manifest.title,
    prototypeCaseId: `component-${manifest.type.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()}`,
    equivalenceClassId: `renderer-${rendererKind}`,
    rendererKind,
    structure: Object.freeze(structure),
    propertyGroups: Object.freeze(PROPERTY_GROUPS[manifest.category] || ['property', 'layout']),
    pageTypes: Object.freeze([...manifest.supportedPageTypes]),
    devices: Object.freeze([...manifest.supportedDevices]),
    requiresParent: Object.freeze([...manifest.requiresParent]),
    bindingKind: manifest.dataBinding,
    states: Object.freeze(Object.fromEntries(
      ['design', 'configure', 'preview', 'runtime', 'failure', 'permission']
        .map((state) => [state, Object.freeze(stateContract(manifest, state))]),
    )),
  });
}

export function buildComponentPrototypeCatalog(manifests) {
  return Object.freeze(manifests.map(componentPrototype));
}
