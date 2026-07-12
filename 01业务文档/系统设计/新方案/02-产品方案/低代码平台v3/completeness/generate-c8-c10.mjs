import { createHash } from 'node:crypto';
import { readFile, stat, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import { buildComponentEvidenceInventory } from '../prototype/component-evidence-inventory.mjs';
import { buildComponentCompletenessMatrix } from '../prototype/component-completeness.mjs';
import { renderInteractiveComponent } from '../prototype/component-runtime-renderer.mjs';
import { createComponentRuntimeState } from '../prototype/component-runtime-state.mjs';
import { getRuntimeContract } from '../prototype/component-runtime-contracts.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const executionId = 'COMPLETE-20260712-001';
const sha256 = (value) => `sha256:${createHash('sha256').update(value).digest('hex')}`;
const variantId = (type) => `VAR-COMP-${type.toUpperCase()}`;
const save = (name, value) => writeFile(join(here, name), `${JSON.stringify(value, null, 2)}\n`, 'utf8');

export const REQUIRED_COMPONENT_STATES = Object.freeze([
  'design', 'configure', 'preview', 'runtime', 'failure', 'permission',
]);

function executeStateChecks(manifests) {
  return manifests.flatMap((manifest) => REQUIRED_COMPONENT_STATES.map((state) => {
    const runtimeState = createComponentRuntimeState(manifest);
    const html = renderInteractiveComponent(manifest, state, runtimeState);
    const contract = getRuntimeContract(manifest);
    const identifiable = html.includes(`data-runtime-component="${manifest.type}"`)
      && (manifest.status === 'planned'
        ? html.includes('data-runtime-disabled="true"')
        : state === 'configure' ? html.includes('data-runtime-action="set-config"')
          : state === 'failure' ? html.includes('data-runtime-action="retry"')
            : state === 'permission' ? html.includes('data-runtime-action="set-permission"')
              : contract.actions.some((action) => html.includes(`data-runtime-action="${action}"`)));
    return {
      test_case_id: `TC-${manifest.type.toUpperCase()}-${state.toUpperCase()}`,
      prototype_case_id: `component-${manifest.type.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()}`,
      variant_id: variantId(manifest.type),
      component_type: manifest.type,
      state,
      oracle: 'interactive renderer exposes the component runtime contract for the requested state',
      output_hash: sha256(html),
      result: identifiable ? 'RENDERED' : 'FAIL',
    };
  }));
}

export function buildC8C10Artifacts(manifests, verifiedByType = {}) {
  const taskRows = executeStateChecks(manifests);
  const evidence = buildComponentEvidenceInventory(manifests, verifiedByType);
  const matrix = buildComponentCompletenessMatrix(manifests, evidence);
  const required = manifests.filter((item) => item.status !== 'planned');
  const planned = manifests.filter((item) => item.status === 'planned');
  const completeTypes = new Set(matrix.rows
    .filter((row) => row.verifiedMaturity === 'production-ready')
    .map((row) => row.componentType));
  const verified = required.filter((item) => completeTypes.has(item.type));
  const implementationGaps = required
    .filter((item) => !completeTypes.has(item.type))
    .map((item) => variantId(item.type));
  const failedStateChecks = taskRows.filter((row) => row.result === 'FAIL');
  const prototypeResult = failedStateChecks.length === 0 ? 'PASS' : 'FAIL';
  const productionResult = implementationGaps.length === 0 && failedStateChecks.length === 0 ? 'PASS' : 'FAIL';

  const taskVerification = {
    execution_id: executionId,
    proof_boundary: 'A rendered state proves an executable prototype case, not production readiness.',
    required_states: REQUIRED_COMPONENT_STATES,
    verifications: taskRows,
    counts: {
      total: taskRows.length,
      rendered: taskRows.length - failedStateChecks.length,
      failed: failedStateChecks.length,
    },
    result: prototypeResult,
  };
  const capabilityVerification = {
    execution_id: executionId,
    capability_id: 'CAP-COMPONENT-FAMILY',
    target_maturity: 'production-ready',
    counts: {
      declared_variants: manifests.length,
      required_variants: required.length,
      planned_variants: planned.length,
      prototype_verified_variants: required.length - new Set(failedStateChecks.map((row) => row.component_type)).size,
      verified_variants: verified.length,
    },
    variants: matrix.rows.map((row) => ({
      variant_id: variantId(row.componentType),
      component_type: row.componentType,
      prototype_case_id: row.prototypeCaseId,
      claimed_maturity: row.claimedMaturity,
      verified_maturity: row.verifiedMaturity,
      missing_evidence: row.missingEvidence,
      result: row.verifiedMaturity === 'production-ready' ? 'PASS' : 'FAIL',
    })),
    implementation_variant_gap: implementationGaps,
    prototype_delivery_result: prototypeResult,
    production_readiness_result: productionResult,
    result: productionResult,
  };
  const missAnalysis = {
    execution_id: executionId,
    findings: implementationGaps.length ? [{
      finding_id: 'MISS-C8-EVIDENCE',
      code: 'EVIDENCE_GAP',
      severity: 'P1',
      fact: `${implementationGaps.length} required component variants lack production-readiness evidence`,
      cause: 'Prototype renderer execution is available, but permission, security, accessibility, performance or server contracts remain unproven.',
      corrective_action: 'Attach named per-variant evidence; do not promote renderer execution to production proof.',
      status: 'OPEN',
    }] : [],
    result: implementationGaps.length ? 'FAIL' : 'PASS',
  };
  const gateReport = {
    run_id: executionId,
    spec_version: '1.1',
    mode: 'DELIVERY_AUDIT',
    stage_status: productionResult === 'PASS' ? 'passed' : 'failed',
    run_result: productionResult,
    product_completeness: productionResult,
    proof_boundary: 'LOCAL_INTERACTIVE_PROTOTYPE',
    prototype_delivery_result: prototypeResult,
    production_readiness: productionResult,
    counts: {
      prototype_applications: 1,
      prototype_units: 2,
      surfaces: 6,
      declared_variants: manifests.length,
      required_variants: required.length,
      verified_variants: verified.length,
      variant_prototype_cases: manifests.length,
      executed_state_checks: taskRows.length,
      failed_state_checks: failedStateChecks.length,
    },
    gaps: {
      required: failedStateChecks.length ? ['CAP-COMPONENT-FAMILY'] : [],
      claims: [],
      delivery: failedStateChecks.map((row) => row.variant_id),
      overclaim: implementationGaps,
      variants: implementationGaps,
      prototype_variants: failedStateChecks.map((row) => row.variant_id),
      implementation_variants: implementationGaps,
      aggregate_claims: implementationGaps.length ? ['FAMILY-COMPONENTS'] : [],
      unexpanded_variants: [],
    },
    evidence_refs: ['capability-verification.json', 'task-verification.json'],
    residual_risks: implementationGaps.length
      ? ['Production-readiness evidence is incomplete for required component variants.']
      : [],
  };
  return { taskVerification, capabilityVerification, missAnalysis, gateReport };
}

function reportMarkdown(report) {
  const lines = [
    '# Capability Gate Report',
    '',
    `- Run: ${report.run_id}`,
    `- Mode: ${report.mode}`,
    `- Prototype delivery result: ${report.prototype_delivery_result}`,
    `- Production readiness: ${report.production_readiness}`,
    `- Declared variants: ${report.counts.declared_variants}`,
    `- Required variants: ${report.counts.required_variants}`,
    `- Verified variants: ${report.counts.verified_variants}`,
    `- Executed state checks: ${report.counts.executed_state_checks}`,
    `- Implementation variant gaps: ${report.gaps.implementation_variants.length}`,
    '',
    'Renderer execution is prototype evidence only. Production completeness requires the full named evidence contract.',
    '',
  ];
  return lines.join('\n');
}

export async function writeC8C10Artifacts(manifests = COMPONENT_MANIFESTS, verifiedByType = {}) {
  const artifacts = buildC8C10Artifacts(manifests, verifiedByType);
  const featureInventory = JSON.parse(await readFile(join(here, 'feature-inventory.yaml'), 'utf8'));
  const scenarioInventory = JSON.parse(await readFile(join(here, 'scenario-inventory.yaml'), 'utf8'));
  const stateByFeature = new Map(artifacts.taskVerification.verifications.map((row) => [`FEAT-${row.component_type.toUpperCase()}-${row.state.toUpperCase()}`, row]));
  featureInventory.features = featureInventory.features.map((feature) => {
    if (feature.scope === 'PLANNED') return { ...feature, result: 'PLANNED_DISABLED' };
    const row = stateByFeature.get(feature.feature_id);
    return { ...feature, command_ids: row ? [`ACTION-${row.component_type.toUpperCase()}-${row.state.toUpperCase()}`] : feature.command_ids, test_case_ids: row ? [row.test_case_id] : [], evidence_refs: row ? ['task-verification.json'] : [], result: row?.result === 'RENDERED' ? 'PASS' : 'FAIL' };
  });
  const featureResult = new Map(featureInventory.features.map((feature) => [feature.feature_id, feature]));
  scenarioInventory.scenarios = scenarioInventory.scenarios.map((scenario) => {
    const feature = featureResult.get(scenario.feature_id);
    return { ...scenario, prototype_case_ids: feature?.test_case_ids?.length ? [`component-${scenario.variant_id.slice(9).toLowerCase()}`] : [], test_case_ids: feature?.test_case_ids || [], evidence_refs: feature?.evidence_refs || [], result: feature?.result || 'FAIL' };
  });
  await Promise.all([
    save('capability-verification.json', artifacts.capabilityVerification),
    save('task-verification.json', artifacts.taskVerification),
    save('miss-analysis.yaml', artifacts.missAnalysis),
    save('capability-gate-report.json', artifacts.gateReport),
    writeFile(join(here, 'capability-gate-report.md'), reportMarkdown(artifacts.gateReport), 'utf8'),
    save('feature-inventory.yaml', featureInventory),
    save('scenario-inventory.yaml', scenarioInventory),
  ]);
  return artifacts;
}

const C8_C10_ARTIFACTS = Object.freeze([
  ['capability-verification.json', 'capability-verification', 'C9'],
  ['task-verification.json', 'task-verification', 'C8'],
  ['miss-analysis.yaml', 'miss-analysis', 'C9'],
  ['capability-gate-report.json', 'capability-gate-report', 'C10'],
  ['capability-gate-report.md', 'capability-gate-report-markdown', 'C10'],
]);

async function refreshArtifactManifest() {
  const path = join(here, 'artifact-manifest.yaml');
  const manifest = JSON.parse(await readFile(path, 'utf8'));
  const replacements = new Set(C8_C10_ARTIFACTS.map(([, type]) => type));
  const records = [];
  for (const [name, artifactType, producerStage] of C8_C10_ARTIFACTS) {
    const artifactPath = join(here, name);
    const content = await readFile(artifactPath);
    records.push({
      artifact_id: `ART-${name.replace(/\W+/g, '-').toUpperCase()}`,
      path: `completeness/${name}`,
      artifact_type: artifactType,
      schema_version: '1.0',
      sha256: sha256(content),
      byte_size: (await stat(artifactPath)).size,
      non_empty: content.length > 0,
      producer_stage: producerStage,
      validation_refs: artifactType === 'task-verification'
        ? ['tests/completeness-c8-c10.test.mjs']
        : ['completeness/generate-c8-c10.mjs'],
    });
  }
  manifest.generated_at = new Date().toISOString();
  manifest.artifacts = [
    ...manifest.artifacts.filter((item) => !replacements.has(item.artifact_type)),
    ...records,
  ].sort((left, right) => left.artifact_type.localeCompare(right.artifact_type));
  const required = new Set(manifest.required_artifact_types_by_mode?.DELIVERY_AUDIT || []);
  for (const type of ['capability-verification', 'task-verification', 'miss-analysis', 'capability-gate-report']) {
    required.add(type);
  }
  manifest.required_artifact_types_by_mode = {
    ...manifest.required_artifact_types_by_mode,
    DELIVERY_AUDIT: [...required],
  };
  await save('artifact-manifest.yaml', manifest);
}

const invokedPath = process.argv[1] ? pathToFileURL(process.argv[1]).href : '';
if (import.meta.url === invokedPath) {
  const artifacts = await writeC8C10Artifacts();
  const executionPath = join(here, 'execution.yaml');
  const execution = JSON.parse(await readFile(executionPath, 'utf8'));
  execution.active_stage = 'C10';
  execution.stages.C8 = {
    status: artifacts.taskVerification.result === 'PASS' ? 'passed' : 'failed',
    outputs: ['task-verification.json'],
    verification: [`${artifacts.taskVerification.counts.total} component state checks executed`],
  };
  execution.stages.C9 = {
    status: artifacts.capabilityVerification.prototype_delivery_result === 'PASS' ? 'passed' : 'failed',
    outputs: ['capability-verification.json', 'miss-analysis.yaml'],
    verification: [`${artifacts.capabilityVerification.counts.prototype_verified_variants} required prototype variants verified`, `${artifacts.capabilityVerification.counts.verified_variants} variants have production-readiness evidence`],
  };
  execution.stages.C10 = {
    status: artifacts.gateReport.run_result === 'PASS' ? 'passed' : 'failed',
    outputs: ['capability-gate-report.json', 'capability-gate-report.md'],
    verification: [`${artifacts.gateReport.gaps.implementation_variants.length} production-readiness evidence gaps remain`],
  };
  execution.run_result = artifacts.gateReport.run_result;
  execution.product_completeness = artifacts.gateReport.product_completeness;
  execution.blockers = artifacts.gateReport.production_readiness === 'PASS' ? [] : ['production-readiness evidence gaps remain'];
  execution.residual_risks = artifacts.gateReport.residual_risks;
  await save('execution.yaml', execution);
  await refreshArtifactManifest();
  console.log(JSON.stringify({
    checks: artifacts.taskVerification.counts.total,
    verifiedVariants: artifacts.capabilityVerification.counts.verified_variants,
    gaps: artifacts.gateReport.gaps.implementation_variants.length,
    result: artifacts.gateReport.run_result,
  }));
}
