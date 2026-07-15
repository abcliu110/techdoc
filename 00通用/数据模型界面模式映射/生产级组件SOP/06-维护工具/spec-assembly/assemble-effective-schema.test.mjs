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
      requiredSemanticChecks: ["sorting-contract"],
      minimumRisk: "R1",
      requiredApprovalRoles: [],
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
assert.throws(() => assembleEffectiveSchema(fixture({ profileKey: "capability:filtering" })), /profile key.*file/i);
assert.throws(() => assembleEffectiveSchema(fixture({ profiles: ["../../../outside.profile.json"] })), /outside v2 root/i);
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
    requiredSemanticChecks: ["filtering-contract"],
    minimumRisk: "R1",
    requiredApprovalRoles: [],
    requiredTypes: { "/api/features/sorting": "string" },
  },
}));
const conflict = JSON.parse(readFileSync(conflictAssembly, "utf8"));
conflict.profiles.push("../profiles/capabilities/filtering.profile.json");
writeFileSync(conflictAssembly, JSON.stringify(conflict));
assert.throws(() => assembleEffectiveSchema(conflictAssembly), /conflicting required type/i);

console.log(JSON.stringify({ status: "PASS", cases: 9 }, null, 2));
