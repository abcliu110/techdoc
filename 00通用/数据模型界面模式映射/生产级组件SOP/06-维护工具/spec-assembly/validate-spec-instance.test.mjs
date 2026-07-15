import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { validateSpecInstance } from "./validate-spec-instance.mjs";

function fixture(schema, instance) {
  const v2Root = mkdtempSync(join(tmpdir(), "spec-structure-"));
  mkdirSync(join(v2Root, "schemas"));
  const schemaPath = join(v2Root, "schemas", "test.schema.json");
  writeFileSync(schemaPath, JSON.stringify(schema));
  return { v2Root, schemaPath, instance };
}

const full = fixture({
  $schema: "https://json-schema.org/draft/2020-12/schema",
  "x-supported-keywords": ["type", "required", "properties", "additionalProperties", "items", "minItems", "uniqueItems", "enum", "const", "pattern", "minLength", "minimum", "allOf", "$ref"],
  allOf: [{
    type: "object",
    required: ["kind", "name", "count", "items"],
    properties: {
      kind: { const: "grid" },
      name: { type: "string", minLength: 3, pattern: "^[a-z]+$" },
      count: { type: "number", minimum: 1 },
      items: { type: "array", minItems: 2, uniqueItems: true, items: { enum: ["a", "b"] } },
    },
    additionalProperties: false,
  }],
}, { kind: "grid", name: "table", count: 2, items: ["a", "b"] });
assert.deepEqual(validateSpecInstance(full.instance, full.schemaPath, { v2Root: full.v2Root }), []);

const invalid = structuredClone(full.instance);
invalid.name = "X";
invalid.count = 0;
invalid.items = ["a", "a"];
invalid.extra = true;
assert.deepEqual(
  validateSpecInstance(invalid, full.schemaPath, { v2Root: full.v2Root }).map(({ code, pointer }) => ({ code, pointer })),
  [
    { code: "SCHEMA_ADDITIONAL_PROPERTY", pointer: "/extra" },
    { code: "SCHEMA_MIN_LENGTH", pointer: "/name" },
    { code: "SCHEMA_MINIMUM", pointer: "/count" },
    { code: "SCHEMA_PATTERN", pointer: "/name" },
    { code: "SCHEMA_UNIQUE_ITEMS", pointer: "/items" },
  ],
);

const typed = fixture({ type: "object", properties: { enabled: { type: "boolean" } }, additionalProperties: false }, { enabled: "yes" });
assert.equal(validateSpecInstance(typed.instance, typed.schemaPath, { v2Root: typed.v2Root })[0].code, "SCHEMA_TYPE");

const required = fixture({ type: "object", required: ["name"], properties: { name: { type: "string" } } }, {});
assert.deepEqual(validateSpecInstance(required.instance, required.schemaPath, { v2Root: required.v2Root })[0], {
  code: "SCHEMA_REQUIRED",
  pointer: "/name",
  message: "Required value is missing",
});

const unsupported = fixture({ type: "string", maxLength: 3 }, "abc");
assert.throws(() => validateSpecInstance(unsupported.instance, unsupported.schemaPath, { v2Root: unsupported.v2Root }), /unsupported schema keyword.*maxLength/i);

const missingRef = fixture({ $ref: "missing.schema.json" }, {});
assert.throws(() => validateSpecInstance(missingRef.instance, missingRef.schemaPath, { v2Root: missingRef.v2Root }), /missing schema ref/i);

const outsideRef = fixture({ $ref: "../../outside.schema.json" }, {});
assert.throws(() => validateSpecInstance(outsideRef.instance, outsideRef.schemaPath, { v2Root: outsideRef.v2Root }), /outside v2 root/i);

const pointers = fixture({
  type: "object",
  "x-component-key": "02:data-grid",
  "x-required-pointers": ["/api/props/data"],
  "x-required-types": { "/api/props/data": "object" },
}, { component: { key: "02:other" }, api: { props: {} } });
assert.deepEqual(
  validateSpecInstance(pointers.instance, pointers.schemaPath, { v2Root: pointers.v2Root }).map(({ code, pointer }) => ({ code, pointer })),
  [
    { code: "SPEC_COMPONENT_KEY", pointer: "/component/key" },
    { code: "SPEC_REQUIRED_POINTER", pointer: "/api/props/data" },
  ],
);

console.log(JSON.stringify({ status: "PASS", cases: 8 }, null, 2));
