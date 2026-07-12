const DESIGN_KEYS = Object.freeze([
  'materialEntry',
  'schemaMutation',
  'propertyEditor',
  'serialization',
  'rehydration',
  'undoRedo',
]);

function hasValue(value) {
  return Array.isArray(value) ? value.length > 0 : Boolean(value);
}

export function buildComponentImplementationGate(manifests, prototypes, evidenceByType) {
  const prototypeByType = new Map(prototypes.map((item) => [item.componentType, item]));
  const rows = manifests.map((manifest) => {
    const prototype = prototypeByType.get(manifest.type);
    const evidence = evidenceByType[manifest.type] || {};
    const planned = manifest.status === 'planned';
    const designMissing = DESIGN_KEYS.filter((key) => !hasValue(evidence[key]));
    const consumerMissing = [
      ...(!hasValue(evidence.dedicatedRenderer) ? ['dedicatedRenderer'] : []),
      ...(!hasValue(evidence.testRefs) ? ['testRefs'] : []),
    ];
    const missing = planned ? [] : [...designMissing, ...consumerMissing];
    const actualMaturity = planned ? 'M1'
      : designMissing.length > 0 ? 'M2'
        : consumerMissing.length > 0 ? 'M3' : 'M4';

    return {
      variant_id: `VAR-COMP-${manifest.type.toUpperCase()}`,
      component_type: manifest.type,
      material_entry: evidence.materialEntry || null,
      schema_mutation: evidence.schemaMutation || null,
      prototype_model: 'prototype/component-prototype-model.mjs',
      renderer_kind: prototype.rendererKind,
      renderer_implementation: evidence.dedicatedRenderer || null,
      property_editor: evidence.propertyEditor || null,
      authoritative_state: 'page schema',
      consumer: evidence.dedicatedRenderer || null,
      test_refs: [...(evidence.testRefs || [])],
      prototype_case_id: evidence.prototypeCaseId || prototype.prototypeCaseId,
      missing_evidence: missing,
      actual_maturity: actualMaturity,
      result: planned ? 'PLANNED_DISABLED' : missing.length === 0 ? 'PASS' : 'FAIL',
    };
  });
  const gaps = rows.filter((row) => row.result === 'FAIL').map((row) => row.variant_id);
  return Object.freeze({ rows: Object.freeze(rows), gaps: Object.freeze(gaps), result: gaps.length ? 'FAIL' : 'PASS' });
}
