import { mkdirSync, writeFileSync } from "node:fs";
import { basename, dirname, join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { readJson, resolveInside, stableJson } from "./shared.mjs";

const riskOrder = { R1: 1, R2: 2, R3: 3 };

function expectedProfileKey(path) {
  const kind = basename(dirname(path)) === "categories" ? "category" : "capability";
  return `${kind}:${basename(path, ".profile.json")}`;
}

function rejectUnknownFields(value, allowed, label) {
  const unknown = Object.keys(value).filter((key) => !allowed.has(key));
  if (unknown.length) throw new Error(`Unknown ${label} field: ${unknown.sort().join(", ")}`);
}

function requireStringArray(value, label, { pointer = false } = {}) {
  if (!Array.isArray(value)) throw new Error(`${label} must be an array`);
  if (new Set(value).size !== value.length) throw new Error(`${label} must not contain duplicates`);
  for (const item of value) {
    if (typeof item !== "string" || !item) throw new Error(`${label} must contain non-empty strings`);
    if (pointer && !item.startsWith("/")) throw new Error(`${label} must contain JSON Pointers`);
  }
}

function validateProfile(profile, path) {
  rejectUnknownFields(profile, new Set(["profileVersion", "profileKey", "appliesTo", "constraints"]), "profile");
  if (profile.profileVersion !== 1) throw new Error(`profileVersion must be 1: ${path}`);
  if (profile.appliesTo !== "component-spec-v2") throw new Error(`Profile appliesTo must be component-spec-v2: ${path}`);
  if (!profile.constraints || typeof profile.constraints !== "object" || Array.isArray(profile.constraints)) throw new Error(`Profile constraints are required: ${path}`);
  const constraints = profile.constraints;
  rejectUnknownFields(constraints, new Set([
    "requiredPointers", "requiredImplementationPointers", "requiredSemanticChecks", "minimumRisk",
    "requiredApprovalRoles", "requiredTypes", "incompatibleProfiles",
  ]), "constraint");
  requireStringArray(constraints.requiredPointers, "requiredPointers", { pointer: true });
  requireStringArray(constraints.requiredImplementationPointers, "requiredImplementationPointers", { pointer: true });
  requireStringArray(constraints.requiredSemanticChecks, "requiredSemanticChecks");
  requireStringArray(constraints.requiredApprovalRoles, "requiredApprovalRoles");
  requireStringArray(constraints.incompatibleProfiles, "incompatibleProfiles");
  if (!constraints.requiredTypes || typeof constraints.requiredTypes !== "object" || Array.isArray(constraints.requiredTypes)) throw new Error("requiredTypes must be an object");
  for (const [pointer, type] of Object.entries(constraints.requiredTypes)) {
    if (!pointer.startsWith("/") || typeof type !== "string" || !type) throw new Error("requiredTypes entries must map JSON Pointers to type names");
  }
}

export function assembleEffectiveSchema(assemblyPath) {
  const absoluteAssembly = resolve(assemblyPath);
  const v2Root = resolve(dirname(absoluteAssembly), "..");
  const assembly = readJson(absoluteAssembly);
  rejectUnknownFields(assembly, new Set(["assemblyVersion", "componentKey", "coreSchema", "profiles", "dataModes"]), "assembly");
  if (assembly.assemblyVersion !== 1) throw new Error("assemblyVersion must be 1");
  if (typeof assembly.componentKey !== "string" || !/^\d{2}:[a-z0-9-]+$/.test(assembly.componentKey)) throw new Error("assembly componentKey is invalid");
  if (typeof assembly.coreSchema !== "string" || !assembly.coreSchema) throw new Error("assembly coreSchema is required");
  if (!Array.isArray(assembly.profiles) || assembly.profiles.length === 0) throw new Error("assembly profiles must not be empty");
  if (!Array.isArray(assembly.dataModes) || assembly.dataModes.length === 0) throw new Error("assembly dataModes must not be empty");
  const corePath = resolveInside(v2Root, dirname(absoluteAssembly), assembly.coreSchema, "Core schema");
  readJson(corePath);

  const profilePaths = assembly.profiles.map((path) => resolveInside(v2Root, dirname(absoluteAssembly), path, "Profile"));
  if (new Set(profilePaths).size !== profilePaths.length) throw new Error("Duplicate profile path in assembly");

  const profiles = profilePaths.map(readJson);
  const keys = profiles.map((profile, index) => {
    validateProfile(profile, profilePaths[index]);
    const expected = expectedProfileKey(profilePaths[index]);
    if (profile.profileKey !== expected) throw new Error(`Profile key does not match file: expected ${expected}`);
    return profile.profileKey;
  });
  if (new Set(keys).size !== keys.length) throw new Error("Duplicate profile key in assembly");

  const applied = new Set(keys);
  const requiredPointers = new Set();
  const implementationPointers = new Set();
  const semanticChecks = new Set();
  const approvalRoles = new Set();
  const requiredTypes = {};
  let minimumRisk = "R1";

  for (const profile of profiles) {
    const constraints = profile.constraints || {};
    for (const incompatible of constraints.incompatibleProfiles || []) {
      if (applied.has(incompatible)) throw new Error(`Incompatible profile combination: ${profile.profileKey} and ${incompatible}`);
    }
    for (const pointer of constraints.requiredPointers || []) requiredPointers.add(pointer);
    for (const pointer of constraints.requiredImplementationPointers || []) implementationPointers.add(pointer);
    for (const check of constraints.requiredSemanticChecks || []) semanticChecks.add(check);
    for (const role of constraints.requiredApprovalRoles || []) approvalRoles.add(role);
    if (!riskOrder[constraints.minimumRisk]) throw new Error(`Invalid minimum risk: ${constraints.minimumRisk}`);
    if (riskOrder[constraints.minimumRisk] > riskOrder[minimumRisk]) minimumRisk = constraints.minimumRisk;
    for (const [pointer, type] of Object.entries(constraints.requiredTypes || {})) {
      if (requiredTypes[pointer] && requiredTypes[pointer] !== type) {
        throw new Error(`Conflicting required type for ${pointer}: ${requiredTypes[pointer]} and ${type}`);
      }
      requiredTypes[pointer] = type;
    }
  }

  const id = assembly.componentKey.replace(":", "-");
  return {
    $schema: "https://json-schema.org/draft/2020-12/schema",
    $id: `effective/${id}.schema.json`,
    allOf: [{ $ref: assembly.coreSchema }],
    "x-component-key": assembly.componentKey,
    "x-applied-profiles": [...applied].sort(),
    "x-required-pointers": [...requiredPointers].sort(),
    "x-required-implementation-pointers": [...implementationPointers].sort(),
    "x-required-semantic-checks": [...semanticChecks].sort(),
    "x-minimum-risk": minimumRisk,
    "x-required-approval-roles": [...approvalRoles].sort(),
    "x-required-types": Object.fromEntries(Object.entries(requiredTypes).sort(([left], [right]) => left.localeCompare(right))),
    "x-data-modes": [...new Set(assembly.dataModes || [])].sort(),
  };
}

export { stableJson } from "./shared.mjs";

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  const [assemblyPath, outputPath] = process.argv.slice(2);
  if (!assemblyPath || !outputPath) throw new Error("Usage: node assemble-effective-schema.mjs <assembly> <output>");
  const output = assembleEffectiveSchema(assemblyPath);
  mkdirSync(dirname(resolve(outputPath)), { recursive: true });
  writeFileSync(resolve(outputPath), stableJson(output), "utf8");
  console.log(JSON.stringify({ status: "PASS", componentKey: output["x-component-key"], output: resolve(outputPath) }, null, 2));
}
