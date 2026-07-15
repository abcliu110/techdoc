import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { assembleEffectiveSchema, stableJson } from "./assemble-effective-schema.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = join(scriptDir, "..", "..");
const assemblyPath = join(root, "04-机器索引与Schema", "v2", "assemblies", "02-data-grid.assembly.json");

const first = assembleEffectiveSchema(assemblyPath);
const second = assembleEffectiveSchema(assemblyPath);
assert.equal(stableJson(first), stableJson(second));
assert.equal(first["x-component-key"], "02:data-grid");
assert.equal(first["x-minimum-risk"], "R2");
assert.deepEqual(first["x-applied-profiles"], [
  "capability:column-pinning",
  "capability:column-sizing",
  "capability:filtering",
  "capability:pagination",
  "capability:row-selection",
  "capability:sorting",
  "category:table",
]);

function fixture({ profileKey = "capability:sorting", fileName = "sorting.profile.json", constraints = {}, profiles } = {}) {
  const v2 = mkdtempSync(join(tmpdir(), "spec-assembly-"));
  for (const directory of ["core", "profiles/capabilities", "assemblies"]) mkdirSync(join(v2, directory), { recursive: true });
  writeFileSync(join(v2, "core", "component-spec.schema.json"), JSON.stringify({ $schema: "https://json-schema.org/draft/2020-12/schema" }));
  writeFileSync(join(v2, "profiles", "capabilities", fileName), JSON.stringify({
    profileVersion: 1,
    profileKey,
    appliesTo: "component-spec-v2",
    constraints: {
      requiredPointers: ["/api/features/sorting"],
      requiredImplementationPointers: ["/api/features/sorting"],
      requiredSemanticChecks: ["sorting-contract"],
      minimumRisk: "R1",
      requiredApprovalRoles: [],
      requiredTypes: { "/api/features/sorting": "object" },
      incompatibleProfiles: [],
      ...constraints,
    },
  }));
  const assembly = join(v2, "assemblies", "test.assembly.json");
  writeFileSync(assembly, JSON.stringify({
    assemblyVersion: 1,
    componentKey: "02:test-grid",
    coreSchema: "../core/component-spec.schema.json",
    profiles: profiles || [`../profiles/capabilities/${fileName}`],
    dataModes: ["local"],
  }));
  return assembly;
}

assert.throws(
  () => assembleEffectiveSchema(fixture({ profiles: ["../profiles/capabilities/sorting.profile.json", "../profiles/capabilities/sorting.profile.json"] })),
  /duplicate profile/i,
);
assert.throws(() => {
  const assembly = fixture();
  const value = JSON.parse(readFileSync(assembly, "utf8"));
  value.assemblyVersion = 2;
  writeFileSync(assembly, JSON.stringify(value));
  assembleEffectiveSchema(assembly);
}, /assemblyVersion/i);
assert.throws(() => {
  const assembly = fixture();
  const v2 = join(dirname(assembly), "..");
  const profile = join(v2, "profiles", "capabilities", "sorting.profile.json");
  const value = JSON.parse(readFileSync(profile, "utf8"));
  value.profileVersion = 2;
  writeFileSync(profile, JSON.stringify(value));
  assembleEffectiveSchema(assembly);
}, /profileVersion/i);
assert.throws(() => {
  const assembly = fixture();
  const v2 = join(dirname(assembly), "..");
  const profile = join(v2, "profiles", "capabilities", "sorting.profile.json");
  const value = JSON.parse(readFileSync(profile, "utf8"));
  value.appliesTo = "other";
  writeFileSync(profile, JSON.stringify(value));
  assembleEffectiveSchema(assembly);
}, /appliesTo/i);
assert.throws(() => {
  const assembly = fixture({ constraints: { requiredPointers: ["not-a-pointer"] } });
  assembleEffectiveSchema(assembly);
}, /requiredPointers/i);
assert.throws(() => {
  const assembly = fixture({ constraints: { requiredSematicChecks: ["typo"] } });
  assembleEffectiveSchema(assembly);
}, /unknown constraint/i);
assert.throws(() => {
  const assembly = fixture();
  const value = JSON.parse(readFileSync(assembly, "utf8"));
  value.profile = value.profiles;
  writeFileSync(assembly, JSON.stringify(value));
  assembleEffectiveSchema(assembly);
}, /unknown assembly field/i);

{
  const assembly = fixture();
  const v2 = join(dirname(assembly), "..");
  writeFileSync(join(v2, "core", "alternate.schema.json"), JSON.stringify({ $schema: "https://json-schema.org/draft/2020-12/schema" }));
  const value = JSON.parse(readFileSync(assembly, "utf8"));
  value.coreSchema = "../core/alternate.schema.json";
  writeFileSync(assembly, JSON.stringify(value));
  assert.deepEqual(assembleEffectiveSchema(assembly).allOf, [{ $ref: "../core/alternate.schema.json" }]);
}
assert.throws(() => assembleEffectiveSchema(fixture({ profileKey: "capability:filtering" })), /profile key.*file/i);
assert.throws(() => assembleEffectiveSchema(fixture({ profiles: ["../../../outside.profile.json"] })), /outside v2 root/i);
assert.throws(() => assembleEffectiveSchema(fixture({ profiles: ["D:/outside.profile.json"] })), /outside v2 root/i);
assert.throws(
  () => assembleEffectiveSchema(fixture({ constraints: { incompatibleProfiles: ["capability:sorting"] } })),
  /incompatible profile/i,
);

const conflictAssembly = fixture({
  constraints: { requiredTypes: { "/api/features/sorting": "object" } },
});
const conflictV2 = join(dirname(conflictAssembly), "..");
writeFileSync(join(conflictV2, "profiles", "capabilities", "filtering.profile.json"), JSON.stringify({
  profileVersion: 1,
  profileKey: "capability:filtering",
  appliesTo: "component-spec-v2",
  constraints: {
    requiredPointers: ["/api/features/filtering"],
    requiredImplementationPointers: ["/api/features/filtering"],
    requiredSemanticChecks: ["filtering-contract"],
    minimumRisk: "R1",
    requiredApprovalRoles: [],
    requiredTypes: { "/api/features/sorting": "string" },
    incompatibleProfiles: [],
  },
}));
const conflict = JSON.parse(readFileSync(conflictAssembly, "utf8"));
conflict.profiles.push("../profiles/capabilities/filtering.profile.json");
writeFileSync(conflictAssembly, JSON.stringify(conflict));
assert.throws(() => assembleEffectiveSchema(conflictAssembly), /conflicting required type/i);

console.log(JSON.stringify({ status: "PASS", cases: 17 }, null, 2));
