import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { validateSpecSemantics } from "./validate-spec-semantics.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = join(scriptDir, "..", "..");
const specPath = join(root, "02-组件规范", "v2-candidates", "02-表格类", "02-data-grid.spec.json");
const schemaPath = join(root, "04-机器索引与Schema", "v2", "effective-schemas", "02-data-grid.schema.json");
const original = JSON.parse(readFileSync(specPath, "utf8"));
const effectiveSchema = JSON.parse(readFileSync(schemaPath, "utf8"));

assert.deepEqual(validateSpecSemantics(original, effectiveSchema), []);

function expectIssue(change, code) {
  const spec = structuredClone(original);
  change(spec);
  const issues = validateSpecSemantics(spec, effectiveSchema);
  assert.ok(issues.some((item) => item.code === code), `Expected ${code}, received ${JSON.stringify(issues)}`);
}

expectIssue((spec) => { spec.behavior.transitions[0].to = ["missingState"]; }, "SEM_TRANSITION_STATE");
expectIssue((spec) => { spec.behavior.exceptionFlows[0].regions = ["missingRegion"]; }, "SEM_EXCEPTION_REGION");
expectIssue((spec) => { spec.behavior.exceptionFlows[0].recoveryAction = "missingAction"; }, "SEM_EXCEPTION_ACTION");
expectIssue((spec) => {
  spec.behavior.recoveryActions = { retryFailedQuery: { kind: "api-command", api: "/api/actions/missing" } };
}, "SEM_RECOVERY_API");
expectIssue((spec) => { spec.behavior.exceptionFlows[0].oracle = "missingOracle"; }, "SEM_EXCEPTION_ORACLE");
expectIssue((spec) => { spec.quality.oracles.selectionStableAfterSort.references.api = ["/api/events/missing"]; }, "SEM_ORACLE_API");
expectIssue((spec) => { delete spec.view.statePresentation.refreshing; }, "SEM_STATE_PRESENTATION");
expectIssue((spec) => { spec.view.statePresentation.ready.regions = ["missingRegion"]; }, "SEM_PRESENTATION_REGION");
expectIssue((spec) => { effectiveSchema["x-required-semantic-checks"].push("unregistered-check"); }, "SEM_CHECK_UNREGISTERED");
effectiveSchema["x-required-semantic-checks"].pop();
expectIssue((spec) => { spec.api.features.rowSelection.identitySource = "/behavior/identity/row/index"; }, "SEM_SELECTION_IDENTITY");
expectIssue((spec) => { spec.api.features.sorting.event = "/api/events/filteringChange"; }, "SEM_SORTING_CONTRACT");
expectIssue((spec) => { spec.api.features.filtering.event = "/api/events/sortingChange"; }, "SEM_FILTERING_CONTRACT");
expectIssue((spec) => { spec.api.features.pagination.event = "/api/events/sortingChange"; }, "SEM_PAGINATION_CONTRACT");
expectIssue((spec) => { spec.api.features.columnPinning.identitySource = "/behavior/identity/row/keyContract"; }, "SEM_COLUMN_PINNING_CONTRACT");
expectIssue((spec) => { spec.api.features.columnSizing.identitySource = "/behavior/identity/row/keyContract"; }, "SEM_COLUMN_SIZING_CONTRACT");
expectIssue((spec) => { spec.behavior.identity.row.keyContract = "/api/props/data"; }, "SEM_TABLE_IDENTITY_CONTRACT");
expectIssue((spec) => { delete spec.quality.oracles.remoteQueryIsNotAppliedLocally; }, "SEM_CAPABILITY_ORACLE");
expectIssue((spec) => { spec.approval.requiredRoles = ["ux-a11y-reviewer"]; }, "SEM_APPROVAL_ROLE");
expectIssue((spec) => { spec.lifecycle.implementationAllowed = true; }, "SEM_SHADOW_ADMISSION");

console.log(JSON.stringify({ status: "PASS", cases: 19 }, null, 2));
