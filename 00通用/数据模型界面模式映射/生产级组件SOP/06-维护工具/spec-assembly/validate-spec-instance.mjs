import { existsSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { escapePointerToken, getPointer, readJson, stableJson } from "./shared.mjs";

const supportedKeywords = new Set([
  "type", "required", "properties", "additionalProperties", "items", "minItems", "uniqueItems",
  "enum", "const", "pattern", "minLength", "minimum", "allOf", "$ref",
]);
const annotations = new Set(["$schema", "$id", "x-supported-keywords"]);

function issue(code, pointer, message) {
  return { code, pointer, message };
}

function same(left, right) {
  return stableJson(left) === stableJson(right);
}

function valueType(value) {
  if (value === null) return "null";
  if (Array.isArray(value)) return "array";
  return typeof value;
}

function assertSupportedSchema(schema) {
  for (const key of Object.keys(schema)) {
    if (supportedKeywords.has(key) || annotations.has(key) || key.startsWith("x-")) continue;
    throw new Error(`Unsupported schema keyword: ${key}`);
  }
  for (const child of Object.values(schema.properties || {})) assertSupportedSchema(child);
  if (schema.items && typeof schema.items === "object") assertSupportedSchema(schema.items);
  for (const child of schema.allOf || []) assertSupportedSchema(child);
}

function resolveRef(schemaPath, ref, v2Root) {
  if (typeof ref !== "string" || !ref || ref.includes("#")) throw new Error(`Only local file refs are supported: ${ref}`);
  const target = resolve(dirname(schemaPath), ref);
  const relation = relative(resolve(v2Root), target);
  if (relation.startsWith("..") || resolve(relation) === target && relation.startsWith("..")) {
    throw new Error(`Schema ref is outside v2 root: ${ref}`);
  }
  if (!existsSync(target)) throw new Error(`Missing schema ref: ${ref}`);
  return target;
}

function validateNode(value, schema, pointer, schemaPath, v2Root, issues) {
  assertSupportedSchema(schema);

  if (schema.$ref) {
    const target = resolveRef(schemaPath, schema.$ref, v2Root);
    validateNode(value, readJson(target), pointer, target, v2Root, issues);
  }
  for (const child of schema.allOf || []) validateNode(value, child, pointer, schemaPath, v2Root, issues);

  if (schema.type && valueType(value) !== schema.type) {
    issues.push(issue("SCHEMA_TYPE", pointer, `Expected ${schema.type}, received ${valueType(value)}`));
    return;
  }
  if (Object.prototype.hasOwnProperty.call(schema, "const") && !same(value, schema.const)) {
    issues.push(issue("SCHEMA_CONST", pointer, "Value does not match const"));
  }
  if (schema.enum && !schema.enum.some((candidate) => same(value, candidate))) {
    issues.push(issue("SCHEMA_ENUM", pointer, "Value is not in enum"));
  }
  if (typeof value === "string") {
    if (schema.minLength !== undefined && value.length < schema.minLength) issues.push(issue("SCHEMA_MIN_LENGTH", pointer, `String length must be at least ${schema.minLength}`));
    if (schema.pattern !== undefined && !new RegExp(schema.pattern, "u").test(value)) issues.push(issue("SCHEMA_PATTERN", pointer, `String does not match ${schema.pattern}`));
  }
  if (typeof value === "number" && schema.minimum !== undefined && value < schema.minimum) {
    issues.push(issue("SCHEMA_MINIMUM", pointer, `Number must be at least ${schema.minimum}`));
  }
  if (Array.isArray(value)) {
    if (schema.minItems !== undefined && value.length < schema.minItems) issues.push(issue("SCHEMA_MIN_ITEMS", pointer, `Array requires at least ${schema.minItems} items`));
    if (schema.uniqueItems && new Set(value.map((item) => stableJson(item))).size !== value.length) issues.push(issue("SCHEMA_UNIQUE_ITEMS", pointer, "Array items must be unique"));
    if (schema.items) value.forEach((item, index) => validateNode(item, schema.items, `${pointer}/${index}`, schemaPath, v2Root, issues));
  }
  if (value && typeof value === "object" && !Array.isArray(value)) {
    for (const key of schema.required || []) {
      if (!Object.prototype.hasOwnProperty.call(value, key)) issues.push(issue("SCHEMA_REQUIRED", `${pointer}/${escapePointerToken(key)}`, "Required value is missing"));
    }
    for (const [key, child] of Object.entries(schema.properties || {})) {
      if (Object.prototype.hasOwnProperty.call(value, key)) validateNode(value[key], child, `${pointer}/${escapePointerToken(key)}`, schemaPath, v2Root, issues);
    }
    if (schema.additionalProperties === false) {
      for (const key of Object.keys(value)) {
        if (!Object.prototype.hasOwnProperty.call(schema.properties || {}, key)) issues.push(issue("SCHEMA_ADDITIONAL_PROPERTY", `${pointer}/${escapePointerToken(key)}`, "Additional property is not allowed"));
      }
    }
  }
}

export function validateSpecInstance(instance, schemaPath, { v2Root = resolve(dirname(schemaPath), "..") } = {}) {
  const absoluteSchema = resolve(schemaPath);
  const schema = readJson(absoluteSchema);
  const declared = schema["x-supported-keywords"];
  if (declared) {
    for (const keyword of declared) if (!supportedKeywords.has(keyword)) throw new Error(`Unsupported schema keyword declared: ${keyword}`);
  }
  const issues = [];
  validateNode(instance, schema, "", absoluteSchema, v2Root, issues);

  const expectedKey = schema["x-component-key"];
  if (expectedKey && instance?.component?.key !== expectedKey) issues.push(issue("SPEC_COMPONENT_KEY", "/component/key", `Expected component key ${expectedKey}`));
  for (const pointer of schema["x-required-pointers"] || []) {
    const resolved = getPointer(instance, pointer);
    if (!resolved.exists) issues.push(issue("SPEC_REQUIRED_POINTER", pointer, "Required profile pointer is missing"));
    else {
      const requiredType = schema["x-required-types"]?.[pointer];
      if (requiredType && valueType(resolved.value) !== requiredType) issues.push(issue("SPEC_REQUIRED_TYPE", pointer, `Expected ${requiredType}`));
    }
  }
  return issues.sort((left, right) => left.code.localeCompare(right.code) || left.pointer.localeCompare(right.pointer));
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  const [specPath, schemaPath, v2Root] = process.argv.slice(2);
  if (!specPath || !schemaPath) throw new Error("Usage: node validate-spec-instance.mjs <spec> <schema> [v2-root]");
  const issues = validateSpecInstance(readJson(resolve(specPath)), resolve(schemaPath), { v2Root: v2Root ? resolve(v2Root) : undefined });
  if (issues.length) {
    console.error(JSON.stringify({ status: "FAIL", issues }, null, 2));
    process.exitCode = 1;
  } else console.log(JSON.stringify({ status: "PASS", validator: "project-json-schema-subset" }, null, 2));
}
