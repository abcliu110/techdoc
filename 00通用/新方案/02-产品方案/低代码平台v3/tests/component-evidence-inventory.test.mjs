import test from 'node:test';
import assert from 'node:assert/strict';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import {
  buildComponentEvidenceInventory,
  componentEvidence,
} from '../prototype/component-evidence-inventory.mjs';
import { buildComponentCompletenessMatrix } from '../prototype/component-completeness.mjs';

test('inventory creates independently addressable evidence for every component', () => {
  const inventory = buildComponentEvidenceInventory(COMPONENT_MANIFESTS);
  assert.equal(Object.keys(inventory).length, COMPONENT_MANIFESTS.length);
  for (const manifest of COMPONENT_MANIFESTS) {
    assert.match(inventory[manifest.type].prototypeCaseId, /^component-/);
  }
});

test('shared design infrastructure does not claim a dedicated renderer', () => {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === 'TextField');
  const evidence = componentEvidence(manifest);
  assert.equal(evidence.schemaMutation, 'schema-engine');
  assert.equal(evidence.dedicatedRenderer, false);
  assert.equal(evidence.securityReview, false);
});

test('completeness gate remains closed until component-specific evidence exists', () => {
  const inventory = buildComponentEvidenceInventory(COMPONENT_MANIFESTS);
  const matrix = buildComponentCompletenessMatrix(COMPONENT_MANIFESTS, inventory);
  assert.equal(matrix.gate, 'FAIL');
  assert.ok(matrix.rows.some((row) => row.missingEvidence.includes('dedicatedRenderer')));
  assert.equal(matrix.verifiedComplete, 0);
});

test('verified evidence is accepted only for the named component', () => {
  const manifests = COMPONENT_MANIFESTS.filter((item) => ['TextField', 'TreeGrid'].includes(item.type));
  const inventory = buildComponentEvidenceInventory(manifests, {
    TreeGrid: {
      dedicatedRenderer: 'tree-grid-renderer',
      permissionContract: 'tree-grid-permission-contract',
      securityReview: 'security-review-tree-grid',
      accessibilityReview: 'a11y-review-tree-grid',
      performanceReview: 'performance-review-tree-grid',
      serverContract: 'tree-grid-server-contract',
    },
  });
  assert.equal(inventory.TreeGrid.dedicatedRenderer, 'tree-grid-renderer');
  assert.equal(inventory.TextField.dedicatedRenderer, false);
});
