import test from 'node:test';
import assert from 'node:assert/strict';

import {
  COMPONENT_CATEGORIES,
  COMPONENT_MANIFESTS,
  acceptsChild,
  getAvailability,
  getManifest,
  isKnownNodeType,
  searchComponents,
} from '../prototype/component-registry.mjs';

test('registry exposes at least 64 unique manifests in ten categories', () => {
  assert.ok(COMPONENT_MANIFESTS.length >= 64);
  assert.equal(COMPONENT_CATEGORIES.length, 10);
  assert.equal(new Set(COMPONENT_MANIFESTS.map(({ type }) => type)).size, COMPONENT_MANIFESTS.length);
  assert.deepEqual(new Set(COMPONENT_MANIFESTS.map(({ category }) => category)), new Set(COMPONENT_CATEGORIES.map(({ id }) => id)));
});

test('each manifest carries the complete panel and runtime contract', () => {
  for (const manifest of COMPONENT_MANIFESTS) {
    assert.ok(Object.isFrozen(manifest), `${manifest.type} should be frozen`);
    assert.ok(manifest.title && manifest.aliases.length > 0);
    assert.ok(['ready', 'preview', 'planned'].includes(manifest.status));
    assert.equal(typeof manifest.rootAllowed, 'boolean');
    assert.ok(manifest.supportedPageTypes.length > 0 && manifest.supportedDevices.length > 0);
    assert.ok(manifest.inspectorPanels.length > 0 && manifest.runtimeRenderer && manifest.defaultSchema);
  }
});

test('entry and tree protocols remain separate manifests', () => {
  const types = ['EntryGrid', 'SubEntryGrid', 'TreeEntryGrid', 'TreeGrid', 'TreePicker'];
  for (const type of types) assert.equal(getManifest(type)?.type, type);
  assert.equal(new Set(types.map((type) => getManifest(type).runtimeRenderer)).size, types.length);
});

test('search matches titles, aliases and protocol types', () => {
  assert.ok(searchComponents('子表').some(({ type }) => type === 'SubEntryGrid'));
  assert.ok(searchComponents('tree picker').some(({ type }) => type === 'TreePicker'));
  assert.ok(searchComponents('MoneyField').some(({ type }) => type === 'MoneyField'));
  assert.deepEqual(searchComponents('definitely-not-a-component'), []);
});

test('availability explains page, device and maturity constraints', () => {
  assert.deepEqual(getAvailability('TextField', { pageType: 'bill', device: 'mobile' }), { available: true, state: 'ready', reasonCode: null, message: '' });
  assert.equal(getAvailability('Spreadsheet', { pageType: 'bill', device: 'mobile' }).reasonCode, 'DEVICE_UNSUPPORTED');
  assert.equal(getAvailability('AnalyticsWorkspace', { pageType: 'report', device: 'desktop' }).reasonCode, 'COMPONENT_PLANNED');
  assert.equal(getAvailability('EntryGrid', { pageType: 'masterData', device: 'desktop' }).reasonCode, 'PAGE_TYPE_UNSUPPORTED');
});

test('SubEntryGrid is conditional on a bound parent entry component', () => {
  assert.equal(getAvailability('SubEntryGrid', { pageType: 'bill', device: 'desktop', schemaNodeTypes: [] }).reasonCode, 'PARENT_ENTRY_REQUIRED');
  assert.equal(getAvailability('SubEntryGrid', { pageType: 'bill', device: 'desktop', schemaNodeTypes: ['EntryGrid'] }).available, true);
});

test('all required-parent components use the same availability contract', () => {
  assert.equal(getAvailability('TreeSubEntryGrid', { pageType: 'bill', device: 'desktop', schemaNodeTypes: [] }).reasonCode, 'PARENT_ENTRY_REQUIRED');
  assert.equal(getAvailability('SubCardEntry', { pageType: 'bill', device: 'desktop', schemaNodeTypes: [] }).reasonCode, 'PARENT_ENTRY_REQUIRED');
  assert.equal(getAvailability('SubCardEntry', { pageType: 'bill', device: 'desktop', schemaNodeTypes: ['CardEntry'] }).available, true);
  assert.equal(getAvailability('Pagination', { pageType: 'bill', device: 'desktop', schemaNodeTypes: [] }).reasonCode, 'REQUIRED_PARENT_MISSING');
  assert.equal(getAvailability('Pagination', { pageType: 'bill', device: 'desktop', schemaNodeTypes: ['DataGrid'] }).available, true);
});

test('unknown component is rejected explicitly', () => {
  assert.equal(getManifest('MissingWidget'), undefined);
  assert.equal(getAvailability('MissingWidget').reasonCode, 'UNKNOWN_COMPONENT');
});

test('registry is the single source of truth for schema component types', () => {
  for (const manifest of COMPONENT_MANIFESTS) {
    assert.equal(isKnownNodeType(manifest.type), true, `${manifest.type} should be a known schema type`);
    assert.equal(getManifest(manifest.type), manifest);
  }
  assert.equal(isKnownNodeType('FormPage'), true);
  assert.equal(isKnownNodeType('MissingWidget'), false);
});

test('registry owns component nesting and required-parent contracts', () => {
  assert.equal(acceptsChild('FormPage', 'Section'), true);
  assert.equal(acceptsChild('FormPage', 'TextField'), true);
  assert.equal(acceptsChild('FieldLayout', 'TextField'), true);
  assert.equal(acceptsChild('FieldLayout', 'EntryGrid'), false);
  assert.equal(acceptsChild('EntryGrid', 'SubEntryGrid'), true);
  assert.equal(acceptsChild('FormPage', 'SubEntryGrid'), false);
  assert.equal(acceptsChild('CardEntry', 'SubCardEntry'), true);
  assert.equal(acceptsChild('DataGrid', 'Pagination'), true);
  assert.equal(acceptsChild('Section', 'Pagination'), false);
});
