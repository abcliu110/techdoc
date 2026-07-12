import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const generatedAt = new Date().toISOString();
const executionId = 'COMPLETE-20260712-001';

const save = async (name, value) => {
  await writeFile(join(here, name), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
};

const componentScope = (manifest) => manifest.status === 'planned' ? 'PLANNED' : 'REQUIRED';
const componentTarget = (manifest) => manifest.status === 'planned' ? 'M1' : 'M4';
const variantId = (manifest) => `VAR-COMP-${manifest.type.toUpperCase()}`;

const coreCapabilities = [
  ['CAP-BO', 'Business object and field modeling', 'P0', 'M4'],
  ['CAP-PAGE', 'Schema-driven page design', 'P0', 'M5'],
  ['CAP-RULE', 'Rule authoring and execution', 'P0', 'M4'],
  ['CAP-PERMISSION', 'Role and field permission design', 'P0', 'M4'],
  ['CAP-PREVIEW', 'Role, sample and device preview', 'P0', 'M4'],
  ['CAP-PUBLISH', 'Evidence-based publish analysis', 'P0', 'M4'],
  ['CAP-COMPONENT-FAMILY', 'Registered component family', 'P0', 'M4'],
].map(([capability_id, name, criticality, target_maturity]) => ({
  capability_id,
  name,
  source_refs: ['design/product-design.md', 'design/component-protocols.md'],
  user_outcome: name,
  scope: 'REQUIRED',
  criticality,
  applicable_when: 'prototype_scope == v3',
  dependencies: capability_id === 'CAP-COMPONENT-FAMILY' ? ['CAP-PAGE'] : [],
  feature_ids: [],
  task_ids: [],
  surface_ids: [],
  prototype_unit_ids: [],
  proof_profile: capability_id === 'CAP-PAGE' ? 'CONFIGURATION_EDITOR' : 'COMMAND',
  architecture_path: 'EQUIVALENT_MODEL',
  target_maturity,
  actual_maturity: 'M0',
  target_evidence_maturity: 'E3',
  actual_evidence_maturity: 'E0',
  test_case_ids: [],
  evidence_refs: [],
  result: 'NOT_RUN',
  finding_ids: [],
}));

const variants = COMPONENT_MANIFESTS.map((manifest) => ({
  variant_id: variantId(manifest),
  family_id: 'FAMILY-COMPONENTS',
  stable_key: manifest.type,
  name: manifest.title,
  category: manifest.category,
  source_refs: ['prototype/component-registry.mjs'],
  registry_claim: manifest.status,
  scope: componentScope(manifest),
  applicable_operation_ids: manifest.status === 'planned'
    ? ['OP-CATALOGUE', 'OP-DISABLED-EXPLANATION']
    : ['OP-DESIGN', 'OP-CONFIGURE', 'OP-PREVIEW', 'OP-RUNTIME'],
  proof_obligations: manifest.status === 'planned'
    ? ['catalogue', 'disabled-explanation']
    : ['design', 'configure', 'preview', 'runtime'],
  equivalence_class_id: null,
  equivalence_certificate_ref: null,
  scenario_ids: [],
  prototype_case_ids: [],
  prototype_unit_ids: [],
  implementation_refs: [],
  test_case_ids: [],
  evidence_refs: [],
  target_maturity: componentTarget(manifest),
  actual_maturity: 'M1',
  result: 'NOT_RUN',
  finding_ids: [],
}));

const features = variants.flatMap((variant) => variant.applicable_operation_ids.map((operation) => ({
  feature_id: `FEAT-${variant.stable_key.toUpperCase()}-${operation.slice(3)}`,
  capability_id: 'CAP-COMPONENT-FAMILY',
  variant_id: variant.variant_id,
  name: `${variant.name} / ${operation}`,
  operation_id: operation,
  scope: variant.scope,
  command_ids: [],
  task_ids: [`TASK-${variant.stable_key.toUpperCase()}`],
  result: 'NOT_RUN',
})));

const scenarios = variants.flatMap((variant) => variant.applicable_operation_ids.map((operation) => ({
  scenario_id: `SCN-${variant.stable_key.toUpperCase()}-${operation.slice(3)}`,
  feature_id: `FEAT-${variant.stable_key.toUpperCase()}-${operation.slice(3)}`,
  variant_id: variant.variant_id,
  task_id: `TASK-${variant.stable_key.toUpperCase()}`,
  kind: operation === 'OP-DISABLED-EXPLANATION' ? 'boundary' : 'normal',
  preconditions: operation === 'OP-DISABLED-EXPLANATION'
    ? ['component dependency is unavailable']
    : ['designer is editable', 'legal target exists'],
  expected_outcome: `${variant.name} satisfies ${operation}`,
  prototype_case_ids: [],
  test_case_ids: [],
  evidence_refs: [],
  result: 'NOT_RUN',
})));

for (const variant of variants) {
  variant.scenario_ids = scenarios.filter((item) => item.variant_id === variant.variant_id).map((item) => item.scenario_id);
}

await mkdir(here, { recursive: true });

await save('execution.yaml', {
  manifest_schema_version: '1.0',
  execution_id: executionId,
  spec_id: '08-complex-product-completeness',
  spec_version: '1.1',
  generated_at: generatedAt,
  mode: 'DELIVERY_AUDIT',
  active_stage: 'C5',
  stages: {
    C0: { status: 'passed', outputs: ['product-charter.yaml', 'scope-draft.yaml'] },
    C1: { status: 'passed', outputs: ['capability-baseline.yaml', 'variant-inventory.yaml'] },
    C2: { status: 'failed', outputs: ['capability-reconciliation.yaml'] },
    C3: { status: 'passed', outputs: ['scope-contract.yaml'] },
    C4: { status: 'passed', outputs: ['feature-inventory.yaml', 'scenario-inventory.yaml'] },
    C5: { status: 'in_progress', outputs: [] },
  },
  run_result: 'FAIL',
  product_completeness: 'NOT_ASSESSED',
  blockers: ['C5-C10 not complete'],
});

await save('product-charter.yaml', {
  execution_id: executionId,
  product: 'Enterprise low-code form designer V3 prototype',
  product_type: 'complex enterprise design tool',
  primary_roles: ['application designer', 'business modeler'],
  core_tasks: ['model business objects', 'compose forms and entries', 'configure rules and permissions', 'preview runtime', 'analyze publishing'],
  prototype_boundary: 'local evidence-backed interactive prototype',
  non_goals: ['production database writes', 'real permission center', 'formal production publish', 'reports', 'mobile-first full editing', 'arbitrary JavaScript execution'],
});

await save('scope-draft.yaml', {
  execution_id: executionId,
  candidate_required_capability_ids: coreCapabilities.map((item) => item.capability_id),
  enumerable_families: ['FAMILY-COMPONENTS'],
  unresolved: [],
});

await save('capability-baseline.yaml', {
  execution_id: executionId,
  source_classes: ['D', 'B', 'C', 'E', 'R'],
  capabilities: coreCapabilities,
});

await save('variant-inventory.yaml', {
  execution_id: executionId,
  families: [{
    family_id: 'FAMILY-COMPONENTS',
    name: 'Registered component family',
    source_snapshots: [{
      source_id: 'SRC-COMPONENT-REGISTRY',
      location: 'prototype/component-registry.mjs',
      artifact_hash: 'PENDING_C6_HASH',
      member_ids: variants.map((item) => item.variant_id),
    }],
    family_operations: ['OP-DESIGN', 'OP-CONFIGURE', 'OP-PREVIEW', 'OP-RUNTIME'],
    declared_count: COMPONENT_MANIFESTS.length,
    inventory_count: variants.length,
    scope: 'REQUIRED',
    variant_ids: variants.map((item) => item.variant_id),
    unexpanded_variant_ids: [],
    aggregate_result: 'NOT_RUN',
  }],
  variants,
});

await save('capability-reconciliation.yaml', {
  execution_id: executionId,
  result: 'PASS',
  independent_inputs: ['design/product-design.md', 'design/component-taxonomy.md', 'design/component-protocols.md', 'prototype visible claims'],
  findings: [
    { finding_id: 'REC-001', type: 'BASELINE_CONFLICT', severity: 'P1', fact: 'component protocol summary previously stated 64 targets while the registry exposes 106 members', resolution: 'RESOLVED_BY_REGISTRY_SNAPSHOT', evidence_refs: ['design/component-protocols.md', 'prototype/component-registry.mjs', 'variant-inventory.yaml'] },
    { finding_id: 'REC-002', type: 'MATURITY_CONFLICT', severity: 'P1', fact: 'registry enablement status was previously ambiguous with evidence maturity', resolution: 'RESOLVED_BY_SEMANTIC_SEPARATION', evidence_refs: ['design/component-protocols.md', 'prototype/component-completeness.mjs'] },
    { finding_id: 'REC-003', type: 'AGGREGATE_CLAIM_WITHOUT_PROOF', severity: 'P1', fact: 'registry status alone does not prove per-component behavior', resolution: 'RESOLVED_BY_MEMBER_EVIDENCE', evidence_refs: ['prototype/component-evidence-inventory.mjs', 'prototype/component-renderer.mjs', 'tests/component-renderer.test.mjs'] },
  ],
});

await save('scope-contract.yaml', {
  execution_id: executionId,
  frozen_at: generatedAt,
  freeze_revision: 1,
  required_capability_ids: coreCapabilities.map((item) => item.capability_id),
  component_family: {
    family_id: 'FAMILY-COMPONENTS',
    inventory_count: variants.length,
    required_variant_ids: variants.filter((item) => item.scope === 'REQUIRED').map((item) => item.variant_id),
    planned_variant_ids: variants.filter((item) => item.scope === 'PLANNED').map((item) => item.variant_id),
    aggregate_claim_policy: 'FAIL unless every applicable member has current per-operation evidence or a valid equivalence certificate',
  },
  change_policy: 'append-only scope change ledger required after freeze',
});

await save('feature-inventory.yaml', { execution_id: executionId, features });
await save('scenario-inventory.yaml', {
  execution_id: executionId,
  required_dimensions: ['normal', 'boundary', 'failure', 'recovery'],
  note: 'C5 must add failure and recovery scenarios where the component protocol makes them applicable.',
  scenarios,
});

console.log(JSON.stringify({
  executionId,
  components: variants.length,
  requiredComponents: variants.filter((item) => item.scope === 'REQUIRED').length,
  plannedComponents: variants.filter((item) => item.scope === 'PLANNED').length,
  features: features.length,
  scenarios: scenarios.length,
  nextStage: 'C5',
}));
