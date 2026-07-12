import test from 'node:test';
import assert from 'node:assert/strict';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import { buildComponentPrototypeCatalog, componentPrototype } from '../prototype/component-prototype-model.mjs';

test('every registered component receives an addressable prototype case and state matrix', () => {
  const catalog = buildComponentPrototypeCatalog(COMPONENT_MANIFESTS);
  assert.equal(catalog.length, COMPONENT_MANIFESTS.length);
  assert.equal(new Set(catalog.map((item) => item.prototypeCaseId)).size, catalog.length);
  for (const item of catalog) {
    assert.match(item.prototypeCaseId, /^component-/);
    assert.deepEqual(Object.keys(item.states), ['design', 'configure', 'preview', 'runtime', 'failure', 'permission']);
    assert.ok(item.rendererKind);
    assert.ok(item.propertyGroups.length > 0);
  }
});

test('complex component families use specialized renderers rather than a generic placeholder', () => {
  for (const type of ['Columns', 'Tabs', 'Wizard', 'SplitPane', 'DashboardGrid', 'EntryGrid', 'SubEntryGrid', 'TreeEntryGrid', 'TreeGrid', 'TreePicker', 'Chart', 'PivotTable', 'CustomComponent']) {
    const item = componentPrototype(COMPONENT_MANIFESTS.find((manifest) => manifest.type === type));
    assert.notEqual(item.rendererKind, 'generic-placeholder', type);
    assert.ok(item.structure.length > 0, type);
  }
});

test('prototype cases retain page, device, binding and parent constraints', () => {
  const subEntry = componentPrototype(COMPONENT_MANIFESTS.find((manifest) => manifest.type === 'SubEntryGrid'));
  assert.deepEqual(subEntry.requiresParent, ['EntryGrid', 'TreeEntryGrid']);
  assert.equal(subEntry.bindingKind, 'entity');
  assert.deepEqual(subEntry.pageTypes, ['bill']);
});
