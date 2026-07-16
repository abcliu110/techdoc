import assert from "node:assert/strict";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { verifyTableFamilyV2 } from "./verify-table-family-v2.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = join(scriptDir, "..", "..");
const result = verifyTableFamilyV2(root);

assert.equal(result.status, "PASS");
assert.deepEqual(result.components.map((item) => item.componentKey), ["02:tree-grid", "02:master-detail-grid"]);
for (const component of result.components) {
  assert.equal(component.specificationStatus, "ReviewReady");
  assert.equal(component.implementationAllowed, false);
  assert.equal(component.generatedArtifacts, 5);
  assert.match(component.digest, /^sha256:[a-f0-9]{64}$/u);
}
assert.equal(result.components[0].appliedProfiles, 6);
assert.equal(result.components[1].appliedProfiles, 2);

console.log(JSON.stringify({ status: "PASS", cases: 13 }, null, 2));
