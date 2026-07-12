import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import {
  buildC8C10Artifacts,
  REQUIRED_COMPONENT_STATES,
} from '../completeness/generate-c8-c10.mjs';

test('C8 expands every component into six independently executed state checks', () => {
  const artifacts = buildC8C10Artifacts(COMPONENT_MANIFESTS);
  assert.equal(
    artifacts.taskVerification.verifications.length,
    COMPONENT_MANIFESTS.length * REQUIRED_COMPONENT_STATES.length,
  );
  for (const manifest of COMPONENT_MANIFESTS) {
    const rows = artifacts.taskVerification.verifications
      .filter((row) => row.component_type === manifest.type);
    assert.deepEqual(rows.map((row) => row.state), REQUIRED_COMPONENT_STATES);
    assert.ok(rows.every((row) => /^sha256:[a-f0-9]{64}$/.test(row.output_hash)));
    assert.ok(rows.every((row) => row.result === 'RENDERED'));
  }
});

test('render execution cannot overclaim production completeness', () => {
  const artifacts = buildC8C10Artifacts(COMPONENT_MANIFESTS);
  assert.equal(artifacts.capabilityVerification.result, 'FAIL');
  assert.equal(artifacts.gateReport.run_result, 'FAIL');
  assert.equal(artifacts.gateReport.product_completeness, 'FAIL');
  assert.equal(artifacts.gateReport.prototype_delivery_result, 'PASS');
  assert.equal(artifacts.gateReport.production_readiness, 'FAIL');
  assert.equal(artifacts.gateReport.proof_boundary, 'LOCAL_INTERACTIVE_PROTOTYPE');
  assert.equal(artifacts.capabilityVerification.counts.prototype_verified_variants, 103);
  assert.ok(artifacts.gateReport.gaps.implementation_variants.length > 0);
  assert.ok(artifacts.missAnalysis.findings.some((item) => item.code === 'EVIDENCE_GAP'));
});

test('planned components stay disabled and do not become required gaps', () => {
  const artifacts = buildC8C10Artifacts(COMPONENT_MANIFESTS);
  const planned = COMPONENT_MANIFESTS.filter((item) => item.status === 'planned');
  assert.equal(artifacts.capabilityVerification.counts.planned_variants, planned.length);
  for (const manifest of planned) {
    assert.ok(!artifacts.gateReport.gaps.implementation_variants.includes(`VAR-COMP-${manifest.type.toUpperCase()}`));
  }
});

test('report keeps component and evidence counts mutually reconcilable', () => {
  const artifacts = buildC8C10Artifacts(COMPONENT_MANIFESTS);
  const counts = artifacts.gateReport.counts;
  assert.equal(counts.declared_variants, COMPONENT_MANIFESTS.length);
  assert.equal(counts.variant_prototype_cases, COMPONENT_MANIFESTS.length);
  assert.equal(counts.executed_state_checks, COMPONENT_MANIFESTS.length * 6);
  assert.equal(
    counts.required_variants,
    counts.verified_variants + artifacts.gateReport.gaps.implementation_variants.length,
  );
});

test('delivery audit manifest requires the C8-C10 evidence artifacts', async () => {
  const manifest = JSON.parse(await readFile(
    new URL('../completeness/artifact-manifest.yaml', import.meta.url),
    'utf8',
  ));
  const required = manifest.required_artifact_types_by_mode.DELIVERY_AUDIT;
  for (const type of ['capability-verification', 'task-verification', 'miss-analysis', 'capability-gate-report']) {
    assert.ok(required.includes(type), `${type} must be required`);
    const artifact = manifest.artifacts.find((item) => item.artifact_type === type);
    assert.ok(artifact?.non_empty);
    assert.match(artifact.sha256, /^sha256:[a-f0-9]{64}$/);
  }
});

test('C8 execution reconciles every required feature and scenario with test evidence', async () => {
  const features = JSON.parse(await readFile(new URL('../completeness/feature-inventory.yaml', import.meta.url), 'utf8'));
  const scenarios = JSON.parse(await readFile(new URL('../completeness/scenario-inventory.yaml', import.meta.url), 'utf8'));
  assert.ok(features.features.filter((item) => item.scope === 'REQUIRED').every((item) => item.result === 'PASS' && item.test_case_ids?.length && item.evidence_refs?.length));
  assert.ok(scenarios.scenarios.filter((item) => featureScope(features, item.feature_id) === 'REQUIRED').every((item) => item.result === 'PASS' && item.test_case_ids?.length && item.evidence_refs?.length));
});

function featureScope(features, featureId) {
  return features.features.find((item) => item.feature_id === featureId)?.scope;
}
