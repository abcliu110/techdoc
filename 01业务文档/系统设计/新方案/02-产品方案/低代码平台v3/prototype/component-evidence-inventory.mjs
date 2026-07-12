import { componentPrototype } from './component-prototype-model.mjs';

const DESIGN_WORKFLOW = Object.freeze({
  materialEntry: 'component-registry',
  schemaMutation: 'schema-engine',
  propertyEditor: 'designer-properties',
  serialization: 'designer-storage',
  rehydration: 'designer-storage',
  undoRedo: 'designer-state',
});

/**
 * Build conservative per-component evidence. Shared infrastructure can prove the
 * reversible design workflow, but it cannot prove a dedicated runtime renderer
 * or production review for every registered component.
 */
export function componentEvidence(manifest, verified = {}) {
  if (!manifest?.type) throw new TypeError('A registered component manifest is required');
  const prototype = componentPrototype(manifest);
  const planned = manifest.status === 'planned';
  return Object.freeze({
    ...(planned ? {} : DESIGN_WORKFLOW),
    prototypeCaseId: prototype.prototypeCaseId,
    interactionStates: prototype.states.design?.status === 'specified'
      && prototype.states.preview?.status === 'specified'
      && prototype.states.failure?.status === 'specified'
      && prototype.states.permission?.status === 'specified',
    dedicatedRenderer: verified.dedicatedRenderer || false,
    testRefs: Object.freeze([...(verified.testRefs || [])]),
    permissionContract: verified.permissionContract || false,
    securityReview: verified.securityReview || false,
    accessibilityReview: verified.accessibilityReview || false,
    performanceReview: verified.performanceReview || false,
    serverContract: verified.serverContract || false,
  });
}

export function buildComponentEvidenceInventory(manifests, verifiedByType = {}) {
  return Object.freeze(Object.fromEntries(manifests.map((manifest) => [
    manifest.type,
    componentEvidence(manifest, verifiedByType[manifest.type]),
  ])));
}
