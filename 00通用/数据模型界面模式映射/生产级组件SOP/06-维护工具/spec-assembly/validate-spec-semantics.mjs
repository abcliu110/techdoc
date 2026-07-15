import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { getPointer, readJson } from "./shared.mjs";

const registeredChecks = new Set([
  "table-identity-contract",
  "sorting-contract",
  "filtering-contract",
  "selection-is-bound-to-row-identity",
  "pagination-contract",
  "column-pinning-contract",
  "column-sizing-contract",
]);
const riskOrder = { R1: 1, R2: 2, R3: 3 };

function issue(code, pointer, message) {
  return { code, pointer, message };
}

export function validateSpecSemantics(spec, effectiveSchema) {
  const issues = [];
  const states = new Set(Object.keys(spec.behavior?.states || {}));
  const regions = new Set(Object.keys(spec.view?.regions || {}));
  const actions = new Set(Object.keys(spec.api?.actions || {}));
  const oracles = new Set(Object.keys(spec.quality?.oracles || {}));

  for (const [index, transition] of (spec.behavior?.transitions || []).entries()) {
    for (const state of [...(transition.from || []), ...(transition.to || [])]) {
      if (!states.has(state)) issues.push(issue("SEM_TRANSITION_STATE", `/behavior/transitions/${index}`, `Unknown transition state: ${state}`));
    }
  }
  for (const [index, flow] of (spec.behavior?.exceptionFlows || []).entries()) {
    for (const state of flow.states || []) if (!states.has(state)) issues.push(issue("SEM_EXCEPTION_STATE", `/behavior/exceptionFlows/${index}/states`, `Unknown state: ${state}`));
    for (const region of flow.regions || []) if (!regions.has(region)) issues.push(issue("SEM_EXCEPTION_REGION", `/behavior/exceptionFlows/${index}/regions`, `Unknown region: ${region}`));
    if (!actions.has(flow.recoveryAction)) issues.push(issue("SEM_EXCEPTION_ACTION", `/behavior/exceptionFlows/${index}/recoveryAction`, `Unknown recovery action: ${flow.recoveryAction}`));
    if (!oracles.has(flow.oracle)) issues.push(issue("SEM_EXCEPTION_ORACLE", `/behavior/exceptionFlows/${index}/oracle`, `Unknown oracle: ${flow.oracle}`));
  }

  for (const [key, oracle] of Object.entries(spec.quality?.oracles || {})) {
    for (const pointer of oracle.references?.api || []) {
      if (!getPointer(spec, pointer).exists) issues.push(issue("SEM_ORACLE_API", `/quality/oracles/${key}/references/api`, `Unknown API pointer: ${pointer}`));
    }
    for (const state of oracle.references?.states || []) if (!states.has(state)) issues.push(issue("SEM_ORACLE_STATE", `/quality/oracles/${key}/references/states`, `Unknown state: ${state}`));
    for (const region of oracle.references?.regions || []) if (!regions.has(region)) issues.push(issue("SEM_ORACLE_REGION", `/quality/oracles/${key}/references/regions`, `Unknown region: ${region}`));
  }

  for (const [state, definition] of Object.entries(spec.behavior?.states || {})) {
    if (definition.userVisible && !spec.view?.statePresentation?.[state]) issues.push(issue("SEM_STATE_PRESENTATION", `/view/statePresentation/${state}`, `Missing presentation for ${state}`));
  }
  for (const [state, presentation] of Object.entries(spec.view?.statePresentation || {})) {
    if (!states.has(state)) issues.push(issue("SEM_PRESENTATION_STATE", `/view/statePresentation/${state}`, `Unknown presented state: ${state}`));
    for (const region of presentation.regions || []) if (!regions.has(region)) issues.push(issue("SEM_PRESENTATION_REGION", `/view/statePresentation/${state}/regions`, `Unknown region: ${region}`));
  }

  for (const check of effectiveSchema["x-required-semantic-checks"] || []) {
    if (!registeredChecks.has(check)) issues.push(issue("SEM_CHECK_UNREGISTERED", "/", `No registered implementation for semantic check: ${check}`));
  }
  if (spec.api?.features?.rowSelection?.identitySource !== "/behavior/identity/row/keyContract") {
    issues.push(issue("SEM_SELECTION_IDENTITY", "/api/features/rowSelection/identitySource", "Selection must bind to the row identity contract"));
  }

  const capabilityOracles = {
    sorting: "sortProducesSingleIntent",
    filtering: "filterPreservesSelection",
    rowSelection: "selectionStableAfterSort",
    pagination: "remoteQueryIsNotAppliedLocally",
    columnPinning: "fixedColumnBoundary",
    columnSizing: "headerBodyAlignment",
  };
  for (const [feature, oracle] of Object.entries(capabilityOracles)) {
    const source = feature.startsWith("column") ? spec.quality?.visualOracles : spec.quality?.oracles;
    if (spec.api?.features?.[feature] && !source?.[oracle]) issues.push(issue("SEM_CAPABILITY_ORACLE", `/quality/oracles/${oracle}`, `${feature} requires oracle ${oracle}`));
  }

  const minimumRisk = effectiveSchema["x-minimum-risk"] || "R1";
  if (!riskOrder[spec.risk?.level] || riskOrder[spec.risk.level] < riskOrder[minimumRisk]) issues.push(issue("SEM_RISK_LEVEL", "/risk/level", `Risk must be at least ${minimumRisk}`));
  const roles = new Set(spec.approval?.requiredRoles || []);
  for (const role of effectiveSchema["x-required-approval-roles"] || []) if (!roles.has(role)) issues.push(issue("SEM_APPROVAL_ROLE", "/approval/requiredRoles", `Missing required approval role: ${role}`));

  if (spec.lifecycle?.implementationAllowed !== false || spec.lifecycle?.specificationStatus !== "Draft") {
    issues.push(issue("SEM_SHADOW_ADMISSION", "/lifecycle", "Shadow candidate must remain Draft with implementationAllowed=false"));
  }
  if (spec.api?.status !== "proposed" || spec.approval?.status !== "pending" || (spec.approval?.records || []).length !== 0) {
    issues.push(issue("SEM_SHADOW_APPROVAL", "/approval", "Shadow candidate cannot claim frozen API or approval"));
  }

  return issues.sort((left, right) => left.code.localeCompare(right.code) || left.pointer.localeCompare(right.pointer));
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  const [specPath, schemaPath] = process.argv.slice(2);
  if (!specPath || !schemaPath) throw new Error("Usage: node validate-spec-semantics.mjs <spec> <effective-schema>");
  const issues = validateSpecSemantics(readJson(resolve(specPath)), readJson(resolve(schemaPath)));
  if (issues.length) {
    console.error(JSON.stringify({ status: "FAIL", issues }, null, 2));
    process.exitCode = 1;
  } else console.log(JSON.stringify({ status: "PASS", semanticChecks: "registered" }, null, 2));
}
