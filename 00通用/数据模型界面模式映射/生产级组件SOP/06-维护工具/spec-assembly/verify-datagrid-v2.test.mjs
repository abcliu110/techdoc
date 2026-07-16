import assert from "node:assert/strict";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { verifyDataGridV2 } from "./verify-datagrid-v2.mjs";
import { findSpecs } from "../build-component-spec-index.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = join(scriptDir, "..", "..");
const result = verifyDataGridV2(root);

assert.equal(result.status, "PASS");
assert.equal(result.componentKey, "02:data-grid");
assert.equal(result.specificationStatus, "Draft");
assert.equal(result.implementationAllowed, false);
assert.equal(result.structuralIssues, 0);
assert.equal(result.semanticIssues, 0);
assert.equal(result.referenceStatus, "Passed");
assert.equal(result.generatedArtifacts, 5);
assert.equal(result.appliedProfiles, 7);
assert.equal(findSpecs(join(root, "02-组件规范")).length, 7, "v1 discovery must ignore v2 Shadow candidates");

console.log(JSON.stringify({ status: "PASS", cases: 10 }, null, 2));
