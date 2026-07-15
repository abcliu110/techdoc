import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { isImplementationAllowed } from "./build-component-spec-index.mjs";
import { validateSpecification } from "./validate-component-specifications.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = resolve(scriptDir, "..");

function loadSpec(relativePath) {
  return JSON.parse(readFileSync(join(root, ...relativePath.split("/")), "utf8"));
}

function entryFor(spec, overrides = {}) {
  return {
    componentKey: spec.identity.componentKey,
    specificationStatus: spec.lifecycle,
    implementationAllowed: false,
    ...overrides,
  };
}

function expectRejected(spec, entry, pattern) {
  assert.throws(() => validateSpecification(spec, entry), pattern);
}

const dataGrid = loadSpec("02-组件规范/02-表格类/02-data-grid.spec.json");
assert.doesNotThrow(() => validateSpecification(dataGrid, entryFor(dataGrid)));
assert.equal(isImplementationAllowed(dataGrid, true), false);
assert.equal(dataGrid.specificationVersion, "0.2.0");
assert.match(dataGrid.dataContract.dataSource, /DataGridDataSource/);
assert.ok(dataGrid.publicApi.props.some((prop) => prop.name === "data" && prop.type.includes("DataGridDataSource")));
assert.ok(!dataGrid.publicApi.props.some((prop) => prop.name === "mode"), "DataGrid must not expose the engine mode prop");
assert.ok(dataGrid.exceptionFlows.some((flow) => flow.id === "stale-remote-result"));
assert.equal(dataGrid.sourceTrace.implementationSop, "03-生产SOP/组件实施SOP/02-data-grid.implementation-sop.md");

const componentIndex = JSON.parse(readFileSync(join(root, "04-机器索引与Schema", "component-spec-index.json"), "utf8"));
assert.equal(componentIndex.schemaVersion, 3);
const dataGridIndexEntry = componentIndex.components.find((entry) => entry.componentKey === "02:data-grid");
assert.ok(dataGridIndexEntry.blockers.some((blocker) => blocker.includes("公开 API 尚未冻结")));
assert.ok(dataGridIndexEntry.blockers.some((blocker) => blocker.includes("审批尚未完成")));
assert.equal(dataGridIndexEntry.implementationSopPath, "03-生产SOP/组件实施SOP/02-data-grid.implementation-sop.md");

{
  const spec = structuredClone(dataGrid);
  delete spec.schemaVersion;
  expectRejected(spec, entryFor(spec), /schemaVersion/);
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "Certified";
  expectRejected(spec, entryFor(spec, { specificationStatus: "Certified" }), /lifecycle/);
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "ImplementationReady";
  spec.publicApi.status = "frozen";
  spec.openDecisions = [];
  spec.approval.status = "approved";
  spec.approval.records = [];
  assert.equal(isImplementationAllowed(spec, true), false, "Index must reject approval status without role records");
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "ImplementationReady";
  spec.publicApi.status = "frozen";
  spec.openDecisions = [];
  spec.approval.status = "approved";
  spec.approval.records = spec.approval.requiredRoles.map((role, i) => ({
    role,
    reviewer: `independent-reviewer-${i}`,
    status: "approved",
    approvedAt: "2026-07-15T00:00:00Z",
    specificationRevision: spec.specificationVersion,
  }));
  assert.equal(isImplementationAllowed(spec), false, "Admission must reject a fully approved spec without implementation SOP evidence");
  assert.equal(isImplementationAllowed(spec, true), true, "Admission may allow a fully approved spec with implementation SOP evidence");
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "ImplementationReady";
  spec.openDecisions = [];
  spec.approval.status = "approved";
  spec.approval.records = spec.approval.requiredRoles.map((role) => ({
    role,
    status: "approved",
    specificationRevision: spec.specificationVersion,
  }));
  assert.equal(isImplementationAllowed(spec, true), false, "Index must reject a proposed public API");
}

{
  const spec = structuredClone(dataGrid);
  spec.purpose = {};
  expectRejected(spec, entryFor(spec), /purpose must not be empty/);
}

{
  const spec = structuredClone(dataGrid);
  delete spec.identity.exportName;
  expectRejected(spec, entryFor(spec), /identity\.exportName/);
}

{
  const spec = structuredClone(dataGrid);
  spec.specificationVersion = "latest";
  expectRejected(spec, entryFor(spec), /specificationVersion/);
}

{
  const spec = structuredClone(dataGrid);
  spec.approval.requiredRoles = [];
  expectRejected(spec, entryFor(spec), /approval\.requiredRoles/);
}

{
  const spec = structuredClone(dataGrid);
  spec.risk.signals = [];
  expectRejected(spec, entryFor(spec), /risk\.signals/);
}

{
  const spec = structuredClone(dataGrid);
  spec.risk.signals = ["invented-signal"];
  expectRejected(spec, entryFor(spec), /risk\.signals\[0\]/);
}

{
  const spec = structuredClone(dataGrid);
  spec.risk.level = "R1";
  expectRejected(spec, entryFor(spec), /minimum level is R2/);
}

{
  const spec = structuredClone(dataGrid);
  spec.approval.requiredRoles = ["author"];
  expectRejected(spec, entryFor(spec), /requiredRoles\[0\]/);
}

{
  const spec = structuredClone(dataGrid);
  spec.openDecisions = ["decide later"];
  expectRejected(spec, entryFor(spec), /openDecisions\[0\]/);
}

{
  const spec = structuredClone(dataGrid);
  spec.boundaries.inScope = [];
  expectRejected(spec, entryFor(spec), /boundaries\.inScope/);
}

{
  const spec = structuredClone(dataGrid);
  delete spec.publicApi.props[0].type;
  expectRejected(spec, entryFor(spec), /publicApi\.props\[0\]\.type/);
}

{
  const spec = structuredClone(dataGrid);
  delete spec.stateMachine.transitions[0].event;
  expectRejected(spec, entryFor(spec), /stateMachine\.transitions\[0\]\.event/);
}

{
  const spec = structuredClone(dataGrid);
  spec.acceptanceOracles[1].id = spec.acceptanceOracles[0].id;
  expectRejected(spec, entryFor(spec), /duplicate acceptance oracle id/);
}

for (const field of [
  "keyboardAndFocus",
  "accessibility",
  "visualAndResponsive",
  "performance",
  "security",
  "compatibility",
  "sourceTrace",
]) {
  const spec = structuredClone(dataGrid);
  spec[field] = { x: "x" };
  expectRejected(spec, entryFor(spec), new RegExp(field));
}

{
  const spec = structuredClone(dataGrid);
  delete spec.exceptionFlows[0].oracle;
  expectRejected(spec, entryFor(spec), /exceptionFlows\[0\]\.oracle/);
}

{
  const spec = structuredClone(dataGrid);
  spec.primaryFlow.steps[0].action = "载入上下文";
  expectRejected(spec, entryFor(spec), /generic rather than component-specific/);
}

{
  const spec = loadSpec("02-组件规范/18-业务领域复合组件/18-stock-allocation.spec.json");
  spec.risk.level = "R2";
  expectRejected(spec, entryFor(spec), /minimum level is R3/);
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "ImplementationReady";
  expectRejected(
    spec,
    entryFor(spec, { specificationStatus: "ImplementationReady", implementationAllowed: true }),
    /publicApi\.status|open decisions|approval/,
  );
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "ImplementationReady";
  spec.publicApi.status = "frozen";
  spec.openDecisions = [];
  spec.approval.status = "approved";
  spec.approval.requiredRoles = ["ux-a11y-reviewer"];
  spec.approval.records = [{
    role: "ux-a11y-reviewer",
    reviewer: "reviewer-b",
    status: "approved",
    approvedAt: "2026-07-15T00:00:00Z",
    specificationRevision: spec.specificationVersion,
  }];
  expectRejected(
    spec,
    entryFor(spec, { specificationStatus: "ImplementationReady", implementationAllowed: true }),
    /R2 requires component-maintainer/,
  );
  assert.equal(isImplementationAllowed(spec, true), false, "Index must require component-maintainer for R2");
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "ImplementationReady";
  spec.publicApi.status = "frozen";
  spec.openDecisions = [];
  spec.approval.status = "approved";
  spec.approval.records = spec.approval.requiredRoles.map((role) => ({
    role,
    status: "approved",
    specificationRevision: spec.specificationVersion,
  }));
  expectRejected(
    spec,
    entryFor(spec, { specificationStatus: "ImplementationReady", implementationAllowed: true }),
    /approval\.records\[0\]\.reviewer/,
  );
  assert.equal(isImplementationAllowed(spec, true), false, "Index must reject incomplete approval records");
}

{
  const spec = loadSpec("02-组件规范/16-权限与组织管理类/16-permission-matrix.spec.json");
  spec.lifecycle = "ImplementationReady";
  spec.publicApi.status = "frozen";
  spec.openDecisions = [];
  spec.approval.status = "approved";
  spec.approval.requiredRoles = ["component-maintainer", "domain-security-reviewer"];
  spec.approval.records = spec.approval.requiredRoles.map((role, i) => ({
    role,
    reviewer: `reviewer-${i}`,
    status: "approved",
    approvedAt: "2026-07-15T00:00:00Z",
    specificationRevision: spec.specificationVersion,
  }));
  assert.equal(isImplementationAllowed(spec, true), false, "R3 index admission must require test or accessibility review");
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "ImplementationReady";
  spec.publicApi.status = "frozen";
  spec.openDecisions = [];
  spec.approval.status = "approved";
  spec.approval.authors = ["reviewer-a"];
  spec.approval.records = spec.approval.requiredRoles.map((role) => ({
    role,
    reviewer: "reviewer-a",
    status: "approved",
    approvedAt: "2026-07-15T00:00:00Z",
    specificationRevision: spec.specificationVersion,
  }));
  expectRejected(
    spec,
    entryFor(spec, { specificationStatus: "ImplementationReady", implementationAllowed: true }),
    /approval\.records\[0\] is invalid/,
  );
}

{
  const spec = structuredClone(dataGrid);
  spec.lifecycle = "ImplementationReady";
  spec.publicApi.status = "frozen";
  spec.openDecisions = [];
  spec.approval.status = "approved";
  spec.approval.records = [];
  expectRejected(
    spec,
    entryFor(spec, { specificationStatus: "ImplementationReady", implementationAllowed: true }),
    /approval records must cover every required role/,
  );
}

{
  const spec = structuredClone(dataGrid);
  expectRejected(spec, entryFor(spec, { implementationAllowed: true }), /cannot be implemented before approval/);
}

console.log(JSON.stringify({ status: "PASS", cases: 38 }, null, 2));
