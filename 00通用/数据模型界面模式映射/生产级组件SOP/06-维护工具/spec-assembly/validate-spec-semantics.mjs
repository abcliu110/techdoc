import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { getPointer, readJson } from "./shared.mjs";

const riskOrder = { R1: 1, R2: 2, R3: 3 };

function issue(code, pointer, message) {
  return { code, pointer, message };
}

const registeredChecks = new Map([
  ["table-identity-contract", (spec) => {
    const issues = [];
    const row = getPointer(spec, spec.behavior?.identity?.row?.keyContract || "");
    const column = getPointer(spec, spec.behavior?.identity?.column?.keyContract || "");
    if (!row.exists || row.value?.semantic !== "row-identity-source") issues.push(issue("SEM_TABLE_IDENTITY_CONTRACT", "/behavior/identity/row/keyContract", "Row identity must reference a row identity source"));
    if (!column.exists || column.value?.semantic !== "column-identity-source") issues.push(issue("SEM_TABLE_IDENTITY_CONTRACT", "/behavior/identity/column/keyContract", "Column identity must reference a column identity source"));
    return issues;
  }],
  ["tree-table-identity-contract", (spec) => {
    const issues = [];
    const node = getPointer(spec, spec.behavior?.identity?.row?.keyContract || "");
    const column = getPointer(spec, spec.behavior?.identity?.column?.keyContract || "");
    const treeColumn = getPointer(spec, "/api/props/treeColumnId");
    if (!node.exists || node.value?.semantic !== "node-identity-source") {
      issues.push(issue("SEM_TREE_TABLE_IDENTITY_CONTRACT", "/behavior/identity/row/keyContract", "Tree row identity must reference a node identity source"));
    }
    if (!column.exists || column.value?.semantic !== "column-identity-source") {
      issues.push(issue("SEM_TREE_TABLE_IDENTITY_CONTRACT", "/behavior/identity/column/keyContract", "Tree columns must reference a column identity source"));
    }
    if (!treeColumn.exists || treeColumn.value?.semantic !== "tree-column-identity-source") {
      issues.push(issue("SEM_TREE_TABLE_IDENTITY_CONTRACT", "/api/props/treeColumnId", "TreeGrid must declare the hierarchy column identity source"));
    }
    return issues;
  }],
  ["master-detail-identity-contract", (spec) => {
    const issues = [];
    const detail = getPointer(spec, spec.behavior?.identity?.row?.keyContract || "");
    const master = getPointer(spec, spec.behavior?.identity?.column?.keyContract || "");
    if (!master.exists || master.value?.semantic !== "master-row-identity-source") {
      issues.push(issue("SEM_MASTER_DETAIL_IDENTITY_CONTRACT", "/behavior/identity/column/keyContract", "Master identity must reference the master grid contract"));
    }
    if (!detail.exists || detail.value?.semantic !== "detail-row-identity-source") {
      issues.push(issue("SEM_MASTER_DETAIL_IDENTITY_CONTRACT", "/behavior/identity/row/keyContract", "Detail identity must reference the detail grid contract"));
    }
    return issues;
  }],
  ["sorting-contract", (spec) => getPointer(spec, spec.api?.features?.sorting?.event || "").value?.capability === "sorting" ? [] : [issue("SEM_SORTING_CONTRACT", "/api/features/sorting/event", "Sorting must reference an event with sorting capability")]],
  ["filtering-contract", (spec) => getPointer(spec, spec.api?.features?.filtering?.event || "").value?.capability === "filtering" ? [] : [issue("SEM_FILTERING_CONTRACT", "/api/features/filtering/event", "Filtering must reference an event with filtering capability")]],
  ["selection-is-bound-to-row-identity", (spec) => spec.api?.features?.rowSelection?.identitySource === "/behavior/identity/row/keyContract" ? [] : [issue("SEM_SELECTION_IDENTITY", "/api/features/rowSelection/identitySource", "Selection must bind to the row identity contract")]],
  ["pagination-contract", (spec) => getPointer(spec, spec.api?.features?.pagination?.event || "").value?.capability === "pagination" ? [] : [issue("SEM_PAGINATION_CONTRACT", "/api/features/pagination/event", "Pagination must reference an event with pagination capability")]],
  ["column-pinning-contract", (spec) => spec.api?.features?.columnPinning?.identitySource === "/behavior/identity/column/keyContract" ? [] : [issue("SEM_COLUMN_PINNING_CONTRACT", "/api/features/columnPinning/identitySource", "Column pinning must bind to column identity")]],
  ["column-sizing-contract", (spec) => spec.api?.features?.columnSizing?.identitySource === "/behavior/identity/column/keyContract" ? [] : [issue("SEM_COLUMN_SIZING_CONTRACT", "/api/features/columnSizing/identitySource", "Column sizing must bind to column identity")]],
]);

export function validateSpecSemantics(spec, effectiveSchema) {
  const issues = [];
  const states = new Set(Object.keys(spec.behavior?.states || {}));
  const regions = new Set(Object.keys(spec.view?.regions || {}));
  const recoveryActions = new Set(Object.keys(spec.behavior?.recoveryActions || {}));
  const oracles = new Set(Object.keys(spec.quality?.oracles || {}));

  for (const [index, transition] of (spec.behavior?.transitions || []).entries()) {
    for (const state of [...(transition.from || []), ...(transition.to || [])]) {
      if (!states.has(state)) issues.push(issue("SEM_TRANSITION_STATE", `/behavior/transitions/${index}`, `Unknown transition state: ${state}`));
    }
  }
  for (const [index, flow] of (spec.behavior?.exceptionFlows || []).entries()) {
    for (const state of flow.states || []) if (!states.has(state)) issues.push(issue("SEM_EXCEPTION_STATE", `/behavior/exceptionFlows/${index}/states`, `Unknown state: ${state}`));
    for (const region of flow.regions || []) if (!regions.has(region)) issues.push(issue("SEM_EXCEPTION_REGION", `/behavior/exceptionFlows/${index}/regions`, `Unknown region: ${region}`));
    if (!recoveryActions.has(flow.recoveryAction)) issues.push(issue("SEM_EXCEPTION_ACTION", `/behavior/exceptionFlows/${index}/recoveryAction`, `Unknown recovery action: ${flow.recoveryAction}`));
    if (!oracles.has(flow.oracle)) issues.push(issue("SEM_EXCEPTION_ORACLE", `/behavior/exceptionFlows/${index}/oracle`, `Unknown oracle: ${flow.oracle}`));
  }
  for (const [key, action] of Object.entries(spec.behavior?.recoveryActions || {})) {
    if (action.kind === "api-command" && (!action.api || !getPointer(spec, action.api).exists)) {
      issues.push(issue("SEM_RECOVERY_API", `/behavior/recoveryActions/${key}/api`, `Recovery action references an unknown API: ${action.api}`));
    }
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
    const validate = registeredChecks.get(check);
    if (!validate) issues.push(issue("SEM_CHECK_UNREGISTERED", "/", `No registered implementation for semantic check: ${check}`));
    else issues.push(...validate(spec));
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

  const reviewOnlyStatuses = new Set(["Draft", "ReviewReady"]);
  if (spec.lifecycle?.implementationAllowed !== false || !reviewOnlyStatuses.has(spec.lifecycle?.specificationStatus)) {
    issues.push(issue("SEM_SHADOW_ADMISSION", "/lifecycle", "Shadow candidate must remain review-only with implementationAllowed=false"));
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
