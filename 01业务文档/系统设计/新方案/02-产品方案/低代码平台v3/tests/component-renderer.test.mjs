import test from 'node:test';
import assert from 'node:assert/strict';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import { renderComponentPrototype } from '../prototype/component-renderer.mjs';

test('every component renders an identifiable prototype in every required state', () => {
  for (const manifest of COMPONENT_MANIFESTS) {
    for (const state of ['design', 'configure', 'preview', 'runtime', 'failure', 'permission']) {
      const html = renderComponentPrototype(manifest, state);
      assert.match(html, new RegExp(`data-prototype-component="${manifest.type}"`));
      assert.match(html, new RegExp(`data-prototype-state="${state}"`));
      assert.doesNotMatch(html, /等待绑定数据字段|generic-placeholder/);
    }
  }
});

test('complex component renderers expose their specialized structure', () => {
  const entry = COMPONENT_MANIFESTS.find((item) => item.type === 'EntryGrid');
  const tree = COMPONENT_MANIFESTS.find((item) => item.type === 'TreeGrid');
  const chart = COMPONENT_MANIFESTS.find((item) => item.type === 'Chart');
  assert.match(renderComponentPrototype(entry, 'preview'), /data-part="rows"/);
  assert.match(renderComponentPrototype(tree, 'preview'), /data-part="tree-column"/);
  assert.match(renderComponentPrototype(chart, 'preview'), /data-part="plot"/);
});

test('renderer escapes manifest text and rejects unknown state', () => {
  const manifest = { ...COMPONENT_MANIFESTS[0], title: '<script>alert(1)</script>' };
  assert.doesNotMatch(renderComponentPrototype(manifest, 'design'), /<script>/);
  assert.throws(() => renderComponentPrototype(manifest, 'unknown'), /Unsupported prototype state/);
});
