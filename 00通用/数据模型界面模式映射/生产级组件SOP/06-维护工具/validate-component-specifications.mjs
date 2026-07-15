import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { hasRequiredApprovals, validApprovalRecord } from "./implementation-admission.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = resolve(scriptDir, "..");
const indexPath = join(root, "04-机器索引与Schema", "component-spec-index.json");
const schemaPath = join(root, "04-机器索引与Schema", "component-spec.schema.json");

assert.ok(existsSync(schemaPath), `Missing component specification schema: ${schemaPath}`);
assert.ok(existsSync(indexPath), `Missing component specification index: ${indexPath}`);

const index = JSON.parse(readFileSync(indexPath, "utf8"));
const forbiddenGenericActions = [
  "载入上下文",
  "把领域对象、关系与操作组合成可连续完成任务的复合界面",
  "把结构化数据、运行状态与用户操作组织为可连续理解和操作的界面",
];
const allowedApprovalRoles = new Set(["component-maintainer", "ux-a11y-reviewer", "test-reviewer", "domain-security-reviewer"]);
const riskSignalMinimums = new Map([
  ["local-view", "R1"], ["navigation-context", "R1"],
  ["data-integrity", "R2"], ["async-state", "R2"], ["persistent-business-state", "R2"], ["large-data", "R2"],
  ["permission", "R3"], ["identity", "R3"], ["multi-tenant", "R3"], ["sensitive-data", "R3"],
  ["money", "R3"], ["inventory", "R3"], ["order", "R3"], ["payment", "R3"], ["invoice", "R3"],
  ["settlement", "R3"], ["irreversible", "R3"], ["cross-system", "R3"],
]);

function requireObject(value, label) {
  assert.ok(value && typeof value === "object" && !Array.isArray(value), `${label} must be an object`);
  assert.ok(Object.keys(value).length > 0, `${label} must not be empty`);
}

function requireNonEmptyString(value, label) {
  assert.equal(typeof value, "string", `${label} must be a string`);
  assert.ok(value.trim().length > 0, `${label} must not be empty`);
  assert.doesNotMatch(value, /\b(?:TBD|TODO|FIXME)\b|后续补充|视情况/u, `${label} contains an unresolved placeholder`);
}

function validateStep(step, label) {
  requireObject(step, label);
  for (const field of ["actor", "precondition", "control", "action", "stateTransition", "observable", "oracle"]) {
    requireNonEmptyString(step[field], `${label}.${field}`);
  }
  for (const generic of forbiddenGenericActions) {
    assert.ok(!step.action.includes(generic), `${label}.action is generic rather than component-specific`);
  }
}

export function validateSpecification(spec, entry) {
  assert.equal(spec.schemaVersion, 1, `${entry.componentKey}.schemaVersion must be 1`);
  requireNonEmptyString(spec.specificationVersion, `${entry.componentKey}.specificationVersion`);
  assert.match(spec.specificationVersion, /^\d+\.\d+\.\d+$/, `${entry.componentKey}.specificationVersion must use x.y.z format`);
  assert.ok(["Draft", "ReviewReady", "ImplementationReady"].includes(spec.lifecycle), `${entry.componentKey}.lifecycle is invalid`);
  for (const field of [
    "identity", "purpose", "boundaries", "dataContract", "publicApi", "stateMachine",
    "primaryFlow", "keyboardAndFocus", "accessibility", "visualAndResponsive", "performance",
    "security", "compatibility", "risk", "sourceTrace",
  ]) requireObject(spec[field], `${entry.componentKey}.${field}`);
  assert.ok(Array.isArray(spec.exceptionFlows) && spec.exceptionFlows.length > 0, `${entry.componentKey}.exceptionFlows must not be empty`);
  assert.ok(Array.isArray(spec.acceptanceOracles) && spec.acceptanceOracles.length > 0, `${entry.componentKey}.acceptanceOracles must not be empty`);
  assert.ok(Array.isArray(spec.openDecisions), `${entry.componentKey}.openDecisions must be an array`);
  for (const [i, decision] of spec.openDecisions.entries()) {
    requireObject(decision, `${entry.componentKey}.openDecisions[${i}]`);
    requireNonEmptyString(decision.id, `${entry.componentKey}.openDecisions[${i}].id`);
    requireNonEmptyString(decision.question, `${entry.componentKey}.openDecisions[${i}].question`);
  }
  for (const field of ["componentKey", "legacyId", "name", "englishName", "category", "exportName", "packageSubpath"]) {
    requireNonEmptyString(spec.identity[field], `${entry.componentKey}.identity.${field}`);
  }
  assert.ok(Array.isArray(spec.approval.requiredRoles) && spec.approval.requiredRoles.length > 0, `${entry.componentKey}.approval.requiredRoles must not be empty`);
  spec.approval.requiredRoles.forEach((role, i) => assert.ok(allowedApprovalRoles.has(role), `${entry.componentKey}.approval.requiredRoles[${i}] is invalid`));
  assert.ok(Array.isArray(spec.approval.authors) && spec.approval.authors.length > 0, `${entry.componentKey}.approval.authors must not be empty`);
  spec.approval.authors.forEach((author, i) => requireNonEmptyString(author, `${entry.componentKey}.approval.authors[${i}]`));
  assert.ok(Array.isArray(spec.approval.records), `${entry.componentKey}.approval.records must be an array`);
  assert.equal(spec.identity.componentKey, entry.componentKey);
  assert.equal(spec.lifecycle, entry.specificationStatus);
  if (entry.specificationVersion !== undefined) assert.equal(spec.specificationVersion, entry.specificationVersion);

  for (const field of ["inScope", "outOfScope"]) {
    assert.ok(Array.isArray(spec.boundaries[field]) && spec.boundaries[field].length > 0, `${entry.componentKey}.boundaries.${field} must not be empty`);
    spec.boundaries[field].forEach((value, i) => requireNonEmptyString(value, `${entry.componentKey}.boundaries.${field}[${i}]`));
  }
  assert.ok(Array.isArray(spec.publicApi.props) && spec.publicApi.props.length > 0, `${entry.componentKey} requires public props`);
  assert.ok(Array.isArray(spec.publicApi.events), `${entry.componentKey} requires public events`);
  for (const [i, prop] of spec.publicApi.props.entries()) {
    requireObject(prop, `${entry.componentKey}.publicApi.props[${i}]`);
    requireNonEmptyString(prop.name, `${entry.componentKey}.publicApi.props[${i}].name`);
    requireNonEmptyString(prop.type, `${entry.componentKey}.publicApi.props[${i}].type`);
    assert.equal(typeof prop.required, "boolean", `${entry.componentKey}.publicApi.props[${i}].required must be boolean`);
  }
  for (const [i, event] of spec.publicApi.events.entries()) {
    requireObject(event, `${entry.componentKey}.publicApi.events[${i}]`);
    requireNonEmptyString(event.name, `${entry.componentKey}.publicApi.events[${i}].name`);
    requireNonEmptyString(event.payload, `${entry.componentKey}.publicApi.events[${i}].payload`);
  }
  assert.ok(Array.isArray(spec.stateMachine.states) && spec.stateMachine.states.length > 1, `${entry.componentKey} requires states`);
  assert.ok(Array.isArray(spec.stateMachine.transitions) && spec.stateMachine.transitions.length > 0, `${entry.componentKey} requires transitions`);
  for (const [i, transition] of spec.stateMachine.transitions.entries()) {
    requireObject(transition, `${entry.componentKey}.stateMachine.transitions[${i}]`);
    for (const field of ["from", "event", "to"]) requireNonEmptyString(transition[field], `${entry.componentKey}.stateMachine.transitions[${i}].${field}`);
  }
  for (const field of ["model", "keys", "focusRecovery"]) requireNonEmptyString(spec.keyboardAndFocus[field], `${entry.componentKey}.keyboardAndFocus.${field}`);
  for (const field of ["semantics", "announcements"]) requireNonEmptyString(spec.accessibility[field], `${entry.componentKey}.accessibility.${field}`);
  for (const field of ["desktop", "mobile"]) requireNonEmptyString(spec.visualAndResponsive[field], `${entry.componentKey}.visualAndResponsive.${field}`);
  for (const field of ["states", "themes"]) {
    assert.ok(Array.isArray(spec.visualAndResponsive[field]) && spec.visualAndResponsive[field].length > 0, `${entry.componentKey}.visualAndResponsive.${field} must not be empty`);
  }
  for (const field of ["fixture", "budget"]) requireNonEmptyString(spec.performance[field], `${entry.componentKey}.performance.${field}`);
  assert.ok(Array.isArray(spec.security.rules) && spec.security.rules.length > 0, `${entry.componentKey}.security.rules must not be empty`);
  spec.security.rules.forEach((rule, i) => requireNonEmptyString(rule, `${entry.componentKey}.security.rules[${i}]`));
  requireNonEmptyString(spec.compatibility.legacy, `${entry.componentKey}.compatibility.legacy`);
  assert.ok(Array.isArray(spec.compatibility.breakingSurfaces) && spec.compatibility.breakingSurfaces.length > 0, `${entry.componentKey}.compatibility.breakingSurfaces must not be empty`);
  requireNonEmptyString(spec.sourceTrace.catalog, `${entry.componentKey}.sourceTrace.catalog`);
  assert.ok(Array.isArray(spec.sourceTrace.correctedFacts) && spec.sourceTrace.correctedFacts.length > 0, `${entry.componentKey}.sourceTrace.correctedFacts must not be empty`);
  assert.ok(Array.isArray(spec.primaryFlow.steps) && spec.primaryFlow.steps.length >= 2, `${entry.componentKey} requires at least two component actions`);
  spec.primaryFlow.steps.forEach((step, i) => validateStep(step, `${entry.componentKey}.primaryFlow.steps[${i}]`));

  for (const [i, flow] of spec.exceptionFlows.entries()) {
    requireObject(flow, `${entry.componentKey}.exceptionFlows[${i}]`);
    for (const field of ["id", "trigger", "blockedEffect", "retainedState", "recovery", "focusResult", "oracle"]) {
      requireNonEmptyString(flow[field], `${entry.componentKey}.exceptionFlows[${i}].${field}`);
    }
  }
  const oracleIds = new Set();
  for (const [i, oracle] of spec.acceptanceOracles.entries()) {
    requireObject(oracle, `${entry.componentKey}.acceptanceOracles[${i}]`);
    for (const field of ["id", "given", "when", "then"]) requireNonEmptyString(oracle[field], `${entry.componentKey}.acceptanceOracles[${i}].${field}`);
    assert.ok(!oracleIds.has(oracle.id), `${entry.componentKey} has duplicate acceptance oracle id: ${oracle.id}`);
    oracleIds.add(oracle.id);
  }

  assert.match(spec.risk.level, /^R[123]$/);
  assert.ok(Array.isArray(spec.risk.signals) && spec.risk.signals.length > 0, `${entry.componentKey}.risk.signals must not be empty`);
  spec.risk.signals.forEach((signal, i) => assert.ok(riskSignalMinimums.has(signal), `${entry.componentKey}.risk.signals[${i}] is invalid`));
  assert.ok(Array.isArray(spec.risk.triggers) && spec.risk.triggers.length > 0, `${entry.componentKey} requires risk triggers`);
  assert.ok(Array.isArray(spec.risk.invariants) && spec.risk.invariants.length > 0, `${entry.componentKey} requires risk invariants`);
  const riskOrder = { R1: 1, R2: 2, R3: 3 };
  const minimumRisk = spec.identity.category === "16"
    ? "R3"
    : spec.risk.signals.reduce((highest, signal) => riskOrder[riskSignalMinimums.get(signal)] > riskOrder[highest] ? riskSignalMinimums.get(signal) : highest, "R1");
  assert.ok(riskOrder[spec.risk.level] >= riskOrder[minimumRisk], `${entry.componentKey} minimum level is ${minimumRisk} from structured risk signals`);
  if (spec.risk.level === "R3") {
    assert.ok(spec.approval.requiredRoles.includes("component-maintainer"), `${entry.componentKey} R3 requires a component library maintainer`);
    assert.ok(spec.approval.requiredRoles.some((role) => role === "test-reviewer" || role === "ux-a11y-reviewer"), `${entry.componentKey} R3 requires test or accessibility review`);
    assert.ok(spec.approval.requiredRoles.includes("domain-security-reviewer"), `${entry.componentKey} R3 requires domain or security review`);
  }
  if (["R2", "R3"].includes(spec.risk.level)) {
    assert.ok(spec.approval.requiredRoles.includes("component-maintainer"), `${entry.componentKey} ${spec.risk.level} requires component-maintainer`);
  }
  assert.equal(spec.publicApi.status, spec.lifecycle === "ImplementationReady" ? "frozen" : "proposed", `${entry.componentKey}.publicApi.status does not match lifecycle`);
  if (spec.lifecycle === "ImplementationReady") {
    assert.equal(spec.openDecisions.length, 0, `${entry.componentKey} cannot be ImplementationReady with open decisions`);
    assert.equal(spec.approval.status, "approved", `${entry.componentKey} requires approval`);
    for (const [i, record] of spec.approval.records.entries()) {
      requireObject(record, `${entry.componentKey}.approval.records[${i}]`);
      requireNonEmptyString(record.role, `${entry.componentKey}.approval.records[${i}].role`);
      requireNonEmptyString(record.reviewer, `${entry.componentKey}.approval.records[${i}].reviewer`);
      requireNonEmptyString(record.approvedAt, `${entry.componentKey}.approval.records[${i}].approvedAt`);
      requireNonEmptyString(record.specificationRevision, `${entry.componentKey}.approval.records[${i}].specificationRevision`);
      assert.ok(validApprovalRecord(record, spec), `${entry.componentKey}.approval.records[${i}] is invalid`);
    }
    assert.ok(hasRequiredApprovals(spec), `${entry.componentKey} approval records must cover every required role`);
  } else {
    assert.equal(entry.implementationAllowed, false, `${entry.componentKey} cannot be implemented before approval`);
  }
}

export function validateIndex() {
  let validated = 0;
  for (const entry of index.components) {
    if (!entry.specPath) continue;
    const path = join(root, ...entry.specPath.split("/"));
    const spec = JSON.parse(readFileSync(path, "utf8"));
    validateSpecification(spec, entry);
    validated += 1;
  }

  return {
    status: "PASS",
    catalogComponents: index.catalogComponents,
    validatedSpecifications: validated,
    implementationReady: index.components.filter((entry) => entry.specificationStatus === "ImplementationReady").length,
    implementationAllowed: index.components.filter((entry) => entry.implementationAllowed).length,
  };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  console.log(JSON.stringify(validateIndex(), null, 2));
}
