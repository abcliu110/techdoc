const EDITABLE_PROPERTIES = new Set([
  'title',
  'controlType',
  'required',
  'readonly',
  'showLabel',
  'masked',
  'auditLogged',
  'changeRule',
  'validationFailure',
  'help',
  'width',
  'minWidth',
  'labelPosition',
  'align',
  'margin',
  'padding',
  'submitStrategy',
  'nullStrategy',
]);

export function readFieldProperties(schema, fieldId) {
  if (!fieldId) return {};
  return structuredClone(schema?.fieldProperties?.[fieldId] || {});
}

export function updateFieldProperty(schema, fieldId, property, value) {
  if (!schema?.nodes || !fieldId) throw new Error('Field property update requires a schema and field id');
  if (!EDITABLE_PROPERTIES.has(property)) throw new Error(`Unsupported field property: ${property}`);

  const nextSchema = structuredClone(schema);
  nextSchema.fieldProperties = {
    ...(nextSchema.fieldProperties || {}),
    [fieldId]: {
      ...(nextSchema.fieldProperties?.[fieldId] || {}),
      [property]: value,
    },
  };

  const node = nextSchema.nodes[fieldId];
  if (node) node.props = { ...(node.props || {}), [property]: value };
  return nextSchema;
}
