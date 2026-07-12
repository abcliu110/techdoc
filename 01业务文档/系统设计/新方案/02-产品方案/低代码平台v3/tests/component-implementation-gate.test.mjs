import test from 'node:test';
import assert from 'node:assert/strict';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import { buildComponentPrototypeCatalog } from '../prototype/component-prototype-model.mjs';
import { buildComponentEvidenceInventory } from '../prototype/component-evidence-inventory.mjs';
import { buildComponentImplementationGate } from '../completeness/component-implementation-gate.mjs';

const prototypes = buildComponentPrototypeCatalog(COMPONENT_MANIFESTS);

function verifiedRendererEvidence(exceptType) {
  return Object.fromEntries(prototypes
    .filter((prototype) => prototype.componentType !== exceptType)
    .map((prototype) => [prototype.componentType, {
      dedicatedRenderer: `component-renderer.mjs#${prototype.rendererKind}`,
      testRefs: ['tests/component-renderer.test.mjs'],
    }]));
}

test('real renderer evidence closes M4 implementation gaps for required components', () => {
  const evidence = buildComponentEvidenceInventory(
    COMPONENT_MANIFESTS,
    verifiedRendererEvidence(),
  );
  const gate = buildComponentImplementationGate(COMPONENT_MANIFESTS, prototypes, evidence);

  assert.equal(gate.rows.length, COMPONENT_MANIFESTS.length);
  assert.equal(gate.gaps.length, 0);
  assert.equal(gate.result, 'PASS');
  assert.equal(gate.rows.filter((row) => row.result === 'PLANNED_DISABLED').length, 3);
  assert.ok(gate.rows
    .filter((row) => row.result === 'PASS')
    .every((row) => row.actual_maturity === 'M4' && row.test_refs.length > 0));
});

test('a required component without renderer evidence remains an M3 consumer gap', () => {
  const evidence = buildComponentEvidenceInventory(
    COMPONENT_MANIFESTS,
    verifiedRendererEvidence('TreeGrid'),
  );
  const gate = buildComponentImplementationGate(COMPONENT_MANIFESTS, prototypes, evidence);
  const row = gate.rows.find((item) => item.component_type === 'TreeGrid');

  assert.equal(row.actual_maturity, 'M3');
  assert.equal(row.result, 'FAIL');
  assert.deepEqual(row.missing_evidence, ['dedicatedRenderer', 'testRefs']);
  assert.deepEqual(gate.gaps, ['VAR-COMP-TREEGRID']);
});
