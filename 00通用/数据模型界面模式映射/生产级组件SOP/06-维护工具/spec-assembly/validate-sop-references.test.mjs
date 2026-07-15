import assert from "node:assert/strict";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { canonicalDigest, canonicalSopDigest, validateSopReferences } from "./validate-sop-references.mjs";
import { readJson } from "./shared.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = join(scriptDir, "..", "..");
const specRoot = join(root, "02-组件规范", "v2-candidates");
const specPath = join(specRoot, "02-表格类", "02-data-grid.spec.json");
const sopPath = join(root, "03-生产SOP", "组件实施SOP-v2-candidates", "02-data-grid.implementation-sop.json");
const effectiveSchema = readJson(join(root, "04-机器索引与Schema", "v2", "effective-schemas", "02-data-grid.schema.json"));
const spec = readJson(specPath);
const allOracles = [
  ...Object.keys(spec.quality.oracles).map((key) => `/quality/oracles/${key}`),
  ...Object.keys(spec.quality.visualOracles).map((key) => `/quality/visualOracles/${key}`),
];

function validSop() {
  return {
    sopVersion: "0.2.0",
    componentKey: "02:data-grid",
    status: "Draft",
    approval: {
      status: "pending",
      authors: ["Codex"],
      requiredRoles: ["component-maintainer", "test-reviewer"],
      records: [],
    },
    specification: {
      path: "../../02-组件规范/v2-candidates/02-表格类/02-data-grid.spec.json",
      version: spec.specificationVersion,
      digest: canonicalDigest(spec),
    },
    steps: [{
      key: "allContracts",
      action: "implement-and-verify",
      method: "先建立失败测试，再实现规范引用，并保存通过证据。",
      implements: effectiveSchema["x-required-implementation-pointers"],
      verifies: allOracles,
      evidenceKinds: ["red-output", "green-output", "interaction-test"],
    }],
  };
}

function validate(sop) {
  return validateSopReferences(sop, { sopPath, specificationsRoot: specRoot, effectiveSchema });
}

assert.equal(validate(validSop()).status, "Passed");

function expectIssue(change, code, status = "Failed") {
  const sop = validSop();
  change(sop);
  const result = validate(sop);
  assert.equal(result.status, status);
  assert.ok(result.issues.some((item) => item.code === code), `Expected ${code}, received ${JSON.stringify(result)}`);
}

expectIssue((sop) => { sop.specification.path = "../../../04-机器索引与Schema/component-spec.schema.json"; }, "SOP_SPEC_PATH");
expectIssue((sop) => { sop.specification.path = "D:/outside.spec.json"; }, "SOP_SPEC_PATH");
expectIssue((sop) => { sop.componentKey = "02:tree-grid"; }, "SOP_COMPONENT_KEY");
expectIssue((sop) => { sop.specification.version = "9.9.9"; }, "SOP_SPEC_VERSION");
expectIssue((sop) => { sop.steps[0].implements = ["not-a-pointer"]; }, "SOP_POINTER_FORMAT");
expectIssue((sop) => { sop.steps[0].implements = ["/api/props/missing"]; }, "SOP_POINTER_MISSING");
expectIssue((sop) => { sop.steps[0].implements = ["/approval/status"]; }, "SOP_IMPLEMENT_PARTITION");
expectIssue((sop) => { sop.steps[0].verifies = ["/api/props/data", ...allOracles]; }, "SOP_VERIFY_PARTITION");
expectIssue((sop) => { sop.steps[0].verifies = allOracles.slice(1); }, "SOP_ORACLE_UNCOVERED");
expectIssue((sop) => { sop.steps[0].implements = []; }, "SOP_IMPLEMENTATION_UNCOVERED");
expectIssue((sop) => { sop.specification.digest = "sha256:deadbeef"; }, "SOP_DIGEST_STALE", "Stale");
{
  const changedSpec = structuredClone(spec);
  changedSpec.quality.performanceBudgets.interaction.value += 1;
  const sop = validSop();
  sop.specification.digest = canonicalDigest(spec);
  const result = validateSopReferences(sop, {
    sopPath,
    specificationsRoot: specRoot,
    effectiveSchema,
    specificationDocument: changedSpec,
  });
  assert.equal(result.status, "Stale");
  assert.ok(result.issues.some((item) => item.code === "SOP_DIGEST_STALE"));
}
expectIssue((sop) => { sop.status = "Approved"; sop.specification.digest = "sha256:deadbeef"; }, "SOP_APPROVED_STALE", "Stale");
expectIssue((sop) => { sop.status = "Approved"; }, "SOP_APPROVAL_MISSING");
expectIssue((sop) => {
  sop.status = "Approved";
  sop.approval.status = "approved";
  sop.approval.records = sop.approval.requiredRoles.map((role) => ({
    role,
    reviewer: "Codex",
    approvedAt: "2026-07-15T00:00:00Z",
    sopVersion: sop.sopVersion,
    sopDigest: canonicalSopDigest(sop),
    specificationVersion: sop.specification.version,
    specificationDigest: sop.specification.digest,
  }));
}, "SOP_APPROVAL_AUTHOR");
expectIssue((sop) => { sop.approval.status = "approved"; }, "SOP_STATUS_APPROVAL");
{
  const sop = validSop();
  sop.status = "Approved";
  sop.approval.status = "approved";
  sop.approval.records = sop.approval.requiredRoles.map((role, index) => ({
    role,
    reviewer: `reviewer-${index}`,
    approvedAt: "2026-07-15T00:00:00Z",
    sopVersion: sop.sopVersion,
    sopDigest: canonicalSopDigest(sop),
    specificationVersion: sop.specification.version,
    specificationDigest: sop.specification.digest,
  }));
  assert.equal(validate(sop).status, "Passed");
  sop.steps[0].method += " Changed after approval.";
  const result = validate(sop);
  assert.equal(result.status, "Failed");
  assert.ok(result.issues.some((item) => item.code === "SOP_APPROVAL_BINDING"));
}
{
  const sop = validSop();
  sop.status = "Approved";
  sop.approval.status = "approved";
  sop.approval.records = sop.approval.requiredRoles.map((role, index) => ({
    role,
    reviewer: `reviewer-${index}`,
    approvedAt: "2026-07-15T00:00:00Z",
    sopVersion: sop.sopVersion,
    sopDigest: canonicalSopDigest(sop),
    specificationVersion: sop.specification.version,
    specificationDigest: sop.specification.digest,
  }));
  sop.approval.requiredRoles.pop();
  const result = validate(sop);
  assert.equal(result.status, "Failed");
  assert.ok(result.issues.some((item) => item.code === "SOP_APPROVAL_BINDING"));
}
expectIssue((sop) => { sop.steps[0].method = "Infer the public type from rows."; }, "SOP_DUPLICATED_ALIAS");
expectIssue((sop) => { sop.steps[0].method = "Call onSelectionChange after sorting."; }, "SOP_DUPLICATED_ALIAS");
expectIssue((sop) => { sop.steps[0].method = "Reuse querySnapshot for retry."; }, "SOP_DUPLICATED_ALIAS");
expectIssue((sop) => { sop.steps[0].method = "Use value: string as the callback contract."; }, "SOP_DUPLICATED_TYPE");
expectIssue((sop) => { sop.steps[0].method = "Call rowSelection.onChange after the action."; }, "SOP_DUPLICATED_API_NAME");
expectIssue((sop) => { sop.steps[0].method = "Build the DataGridQueryRequest before the action."; }, "SOP_DUPLICATED_TYPE_NAME");
expectIssue((sop) => { sop.steps[0].method = "Require p95 <= 100ms before passing."; }, "SOP_DUPLICATED_THRESHOLD");

console.log(JSON.stringify({ status: "PASS", cases: 24 }, null, 2));
