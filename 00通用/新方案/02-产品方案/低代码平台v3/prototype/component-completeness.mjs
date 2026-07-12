const MATURITY_ORDER = Object.freeze([
  'catalogued',
  'designable',
  'previewable',
  'production-ready',
]);

const DESIGN_EVIDENCE = Object.freeze([
  'materialEntry',
  'schemaMutation',
  'propertyEditor',
  'serialization',
  'rehydration',
  'undoRedo',
]);

const PREVIEW_EVIDENCE = Object.freeze([
  'dedicatedRenderer',
  'interactionStates',
  'prototypeCaseId',
]);

const PRODUCTION_EVIDENCE = Object.freeze([
  'permissionContract',
  'securityReview',
  'accessibilityReview',
  'performanceReview',
  'serverContract',
]);

function hasEvidence(evidence, key) {
  return typeof evidence[key] === 'string' ? evidence[key].trim().length > 0 : evidence[key] === true;
}

function missingEvidence(evidence, keys) {
  return keys.filter((key) => !hasEvidence(evidence, key));
}

export function normalizeClaimedMaturity(status) {
  if (MATURITY_ORDER.includes(status)) return status;
  if (status === 'planned') return 'catalogued';
  if (status === 'preview') return 'previewable';
  if (status === 'ready') return 'production-ready';
  return 'catalogued';
}

export function evaluateComponentCompleteness(manifest, evidence = {}) {
  const designMissing = missingEvidence(evidence, DESIGN_EVIDENCE);
  const previewMissing = missingEvidence(evidence, PREVIEW_EVIDENCE);
  const productionMissing = missingEvidence(evidence, PRODUCTION_EVIDENCE);

  let verifiedMaturity = 'catalogued';
  if (designMissing.length === 0) verifiedMaturity = 'designable';
  if (designMissing.length === 0 && previewMissing.length === 0) verifiedMaturity = 'previewable';
  if (designMissing.length === 0 && previewMissing.length === 0 && productionMissing.length === 0) {
    verifiedMaturity = 'production-ready';
  }

  const claimedMaturity = normalizeClaimedMaturity(manifest.status);
  const claimIndex = MATURITY_ORDER.indexOf(claimedMaturity);
  const verifiedIndex = MATURITY_ORDER.indexOf(verifiedMaturity);
  const missing = [
    ...(claimIndex >= 1 ? designMissing : []),
    ...(claimIndex >= 2 ? previewMissing : []),
    ...(claimIndex >= 3 ? productionMissing : []),
  ];

  return Object.freeze({
    componentType: manifest.type,
    title: manifest.title,
    category: manifest.category,
    claimedMaturity,
    verifiedMaturity,
    prototypeCaseId: evidence.prototypeCaseId || null,
    missingEvidence: Object.freeze([...new Set(missing)]),
    gap: claimIndex > verifiedIndex,
    gapCode: claimIndex > verifiedIndex ? 'VARIANT_COVERAGE_GAP' : null,
  });
}

export function buildComponentCompletenessMatrix(manifests, evidenceByType = {}) {
  const rows = manifests.map((manifest) => evaluateComponentCompleteness(manifest, evidenceByType[manifest.type]));
  const gaps = rows.filter((row) => row.gap);
  return Object.freeze({
    generatedFrom: 'ComponentManifest + verification evidence',
    total: rows.length,
    claimedComplete: rows.filter((row) => row.claimedMaturity === 'production-ready').length,
    verifiedComplete: rows.filter((row) => row.verifiedMaturity === 'production-ready').length,
    gapCount: gaps.length,
    gate: gaps.length === 0 ? 'PASS' : 'FAIL',
    rows: Object.freeze(rows),
  });
}

export const COMPONENT_EVIDENCE_KEYS = Object.freeze({
  designable: DESIGN_EVIDENCE,
  previewable: PREVIEW_EVIDENCE,
  productionReady: PRODUCTION_EVIDENCE,
});
