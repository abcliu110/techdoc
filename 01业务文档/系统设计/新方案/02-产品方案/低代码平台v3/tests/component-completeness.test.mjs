import test from 'node:test';
import assert from 'node:assert/strict';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import {
  buildComponentCompletenessMatrix,
  evaluateComponentCompleteness,
} from '../prototype/component-completeness.mjs';

const manifest = (status = 'ready') => ({
  type: 'ExampleField',
  title: 'Example field',
  category: 'input',
  status,
});

test('a catalogue status cannot replace implementation evidence', () => {
  const row = evaluateComponentCompleteness(manifest());
  assert.equal(row.claimedMaturity, 'production-ready');
  assert.equal(row.verifiedMaturity, 'catalogued');
  assert.equal(row.gapCode, 'VARIANT_COVERAGE_GAP');
  assert.ok(row.missingEvidence.includes('dedicatedRenderer'));
  assert.ok(row.missingEvidence.includes('prototypeCaseId'));
});

test('designable requires the complete reversible Schema workflow', () => {
  const row = evaluateComponentCompleteness(manifest('designable'), {
    materialEntry: true,
    schemaMutation: true,
    propertyEditor: true,
    serialization: true,
    rehydration: true,
  });
  assert.equal(row.verifiedMaturity, 'catalogued');
  assert.deepEqual(row.missingEvidence, ['undoRedo']);
});

test('previewable requires a dedicated renderer, states and an addressable prototype case', () => {
  const row = evaluateComponentCompleteness(manifest('previewable'), {
    materialEntry: true,
    schemaMutation: true,
    propertyEditor: true,
    serialization: true,
    rehydration: true,
    undoRedo: true,
    dedicatedRenderer: true,
    interactionStates: true,
    prototypeCaseId: 'case-example-field',
  });
  assert.equal(row.verifiedMaturity, 'previewable');
  assert.equal(row.gap, false);
});

test('current registry fails closed when no per-component evidence inventory is supplied', () => {
  const matrix = buildComponentCompletenessMatrix(COMPONENT_MANIFESTS);
  assert.equal(matrix.total, COMPONENT_MANIFESTS.length);
  assert.equal(matrix.gate, 'FAIL');
  assert.ok(matrix.gapCount > 0);
  assert.equal(matrix.verifiedComplete, 0);
});
