import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const prototypeRoot = resolve(here, '../prototype');

test('prototype exposes stable workbench regions and test hooks', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');

  for (const hook of [
    'designer-root',
    'topbar',
    'workspace-nav',
    'resource-panel',
    'design-canvas',
    'property-inspector',
    'analysis-panel',
    'preview-dialog',
    'publish-dialog',
  ]) {
    assert.match(html, new RegExp(`data-testid=["']${hook}["']`));
  }
});

test('prototype keeps UI code native and references no remote runtime assets', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  assert.doesNotMatch(html, /https?:\/\//);
  assert.match(html, /styles\.css/);
  assert.match(html, /app\.js/);
});

test('the page and changed storage dependency use the current module revision', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');
  assert.match(html, /app\.js\?v=20260712-9/);
  assert.match(html, /styles\.css\?v=20260712-5/);
  assert.match(app, /designer-storage\.mjs\?v=20260712-3/);
});

test('clickable non-button canvas regions expose keyboard semantics', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  assert.match(html, /data-testid="field-entries"[^>]*role="button"[^>]*tabindex="0"/);
});

test('finding count exposes a stable hook for state synchronization', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  assert.match(html, /data-testid="finding-count"/);
});

test('prototype labels unmeasured runtime data and local persistence honestly', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(html, /rel="icon" href="data:,"/);
  assert.doesNotMatch(app, /\d+\s*ms|交互性能评分|已写入设计服务/);
  assert.match(app, /未测量/);
  assert.match(app, /本地原型/);
});

test('page designer exposes a complete searchable and draggable component palette', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(html, /data-palette-host/);
  assert.match(app, /data-testid="component-palette"/);
  assert.match(app, /COMPONENT_CATEGORIES/);
  assert.match(app, /COMPONENT_MANIFESTS/);
  assert.match(app, /data-testid="component-count"/);
  assert.match(app, /data-component-category/);
  assert.match(app, /draggable="true"/);
  assert.match(app, /data-component-type/);
  assert.match(app, /dragstart/);
  assert.match(app, /drop/);
});

test('component design studio is an independently addressable prototype unit', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(html, /data-workspace="components"/);
  assert.match(html, /data-testid="component-studio"/);
  assert.match(app, /componentStudioMarkup/);
  assert.match(app, /data-component-case/);
  assert.match(app, /data-component-state/);
  assert.match(app, /componentInspectorMarkup/);
  assert.match(app, /renderInteractiveComponent\(manifest, 'configure'/);
  assert.match(app, /data-testid="inspector-title"/);
});

test('visible runtime and tool commands have rendered consumers', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');
  assert.match(html, /data-testid="page-tab-content"/);
  assert.match(html, /data-testid="settings-panel"/);
  assert.match(html, /data-testid="column-settings-panel"/);
  assert.match(app, /renderCommandConsumers/);
  assert.match(app, /commandState\.activePageTab/);
  assert.match(app, /commandState\.settingsOpen/);
  assert.match(app, /commandState\.columnSettingsOpen/);
});

test('every visible business page tab contains editable persisted fields instead of placeholder copy', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');
  assert.doesNotMatch(html, /page-placeholder|placeholder-content/);
  for (const field of ['warehouse', 'deliveryMethod', 'paymentTerms', 'invoiceType', 'contractFile', 'externalRemark', 'internalRemark']) {
    assert.match(html, new RegExp(`data-page-value="${field}"`));
  }
  assert.match(app, /previewData = \{ \.\.\.previewData, \[control\.dataset\.pageValue\]: control\.value \}/);
});

test('visible resource searches and permission switches have state consumers', async () => {
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(app, /data-workspace-search/);
  assert.match(app, /data-resource-search/);
  assert.match(app, /resourceQuery = event\.target\.value/);
  assert.match(app, /switchControl\('字段脱敏', field\.masked, 'masked'\)/);
  assert.match(app, /switchControl\('记录审计', field\.auditLogged, 'auditLogged'\)/);
  assert.match(app, /selectProperty\('changeRule', field\.changeRule/);
  assert.match(app, /selectProperty\('validationFailure', field\.validationFailure/);
});

test('unimplemented list and detail views are disabled instead of simulating a switch', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(html, /data-view="list"[^>]*disabled/);
  assert.match(html, /data-view="detail"[^>]*disabled/);
  assert.doesNotMatch(app, /视图已切换/);
});

test('runtime preview removes designer-only drag, move, selection and placeholder affordances', async () => {
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(app, /sanitizePreviewTree/);
  assert.match(app, /schema-move-actions/);
  assert.match(app, /placeholder-node/);
  assert.match(app, /removeAttribute\('draggable'\)/);
  assert.match(app, /removeAttribute\('data-schema-drop-target'\)/);
  assert.match(app, /hydratePreviewComponentRuntimes/);
  assert.match(app, /previewNodeRuntimeStates/);
});

test('runtime preview routes value and file controls through change instead of click', async () => {
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');
  const events = await readFile(resolve(prototypeRoot, 'component-runtime-events.mjs'), 'utf8');

  assert.match(app, /runtimeActionEventName\(control\.dataset\.runtimeAction\) === event\.type/);
  assert.match(app, /runtimeActionPayload\(control\)/);
  assert.match(events, /'add-file'/);
  assert.match(events, /file: control\.files\?\.\[0\]/);
  assert.match(events, /control\.value/);
});

test('all field selection paths use the schema-backed field catalog', async () => {
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(app, /createSalesOrderDesignerSchema/);
  assert.doesNotMatch(app, /BASE_FIELD_DETAILS/);
  assert.doesNotMatch(app, /(?<!BASE_)FIELD_DETAILS/);
});

test('text properties stage on input while selects commit on change', async () => {
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(app, /control\.addEventListener\('input', stageFieldProperty\)/);
  assert.match(app, /control\.addEventListener\('blur', endFieldPropertyEdit\)/);
  assert.match(app, /control\.addEventListener\('change', finishFieldPropertyEdit\)/);
});
