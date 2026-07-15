import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { dirname, isAbsolute, relative, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { getPointer, readJson, stableJson } from "./shared.mjs";

function issue(code, pointer, message) {
  return { code, pointer, message };
}

export function canonicalDigest(document) {
  return `sha256:${createHash("sha256").update(stableJson(document), "utf8").digest("hex")}`;
}

export function canonicalSopDigest(sop) {
  return canonicalDigest({
    sopVersion: sop.sopVersion,
    componentKey: sop.componentKey,
    specification: sop.specification,
    approvalPolicy: {
      authors: sop.approval?.authors || [],
      requiredRoles: sop.approval?.requiredRoles || [],
    },
    steps: sop.steps,
  });
}

function isInside(root, path) {
  const relation = relative(resolve(root), resolve(path));
  return relation === "" || (!isAbsolute(relation) && !relation.startsWith(".."));
}

function collectRequiredOracles(spec) {
  return [
    ...Object.keys(spec.quality?.oracles || {}).map((key) => `/quality/oracles/${key}`),
    ...Object.keys(spec.quality?.visualOracles || {}).map((key) => `/quality/visualOracles/${key}`),
  ].sort();
}

function scanDuplicatedAnswers(sop, spec, issues) {
  const apiNames = [...new Set(Object.values(spec.api?.events || {}).map((event) => event.name).filter(Boolean))];
  const typeNames = [...new Set([
    ...Object.values(spec.api?.props || {}).map((prop) => prop.type),
    ...Object.values(spec.api?.events || {}).map((event) => event.payload),
    ...Object.values(spec.api?.features || {}).map((feature) => feature.state),
  ].flatMap((value) => String(value || "").match(/\b[A-Z][A-Za-z0-9]*\b/g) || []))];
  for (const [index, step] of (sop.steps || []).entries()) {
    const text = `${step.action || ""} ${step.method || ""}`;
    for (const alias of spec.compatibility?.forbiddenSopAliases || []) {
      if (new RegExp(`\\b${alias.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\b`, "iu").test(text)) {
        issues.push(issue("SOP_DUPLICATED_ALIAS", `/steps/${index}/method`, `SOP repeats forbidden legacy alias: ${alias}`));
      }
    }
    if (/(?:\btype\s+[A-Z]|\binterface\s+[A-Z]|\b[A-Za-z_$][\w$]*\??\s*:\s*(?:string|number|boolean|readonly|[A-Z][\w$]*))/u.test(text)) {
      issues.push(issue("SOP_DUPLICATED_TYPE", `/steps/${index}/method`, "SOP must not define a TypeScript type or signature"));
    }
    if (/(?:p\d+\s*)?(?:<=|>=|<|>)\s*\d+(?:\.\d+)?\s*(?:ms|s|kb|mb|px|%)/iu.test(text)) {
      issues.push(issue("SOP_DUPLICATED_THRESHOLD", `/steps/${index}/method`, "SOP must not repeat a numeric threshold"));
    }
    if (/\b(?:given|when|then)\b\s*:/iu.test(text)) {
      issues.push(issue("SOP_DUPLICATED_ORACLE", `/steps/${index}/method`, "SOP must not repeat Given/When/Then conclusions"));
    }
    if (apiNames.some((name) => text.includes(name))) {
      issues.push(issue("SOP_DUPLICATED_API_NAME", `/steps/${index}/method`, "SOP must reference public API names through specification pointers"));
    }
    if (typeNames.some((name) => new RegExp(`\\b${name}\\b`, "u").test(text))) {
      issues.push(issue("SOP_DUPLICATED_TYPE_NAME", `/steps/${index}/method`, "SOP must reference public type names through specification pointers"));
    }
  }
}

function validateApproval(sop, issues) {
  const approval = sop.approval || {};
  if (sop.status !== "Approved") {
    if (approval.status === "approved" || (approval.records || []).length > 0) {
      issues.push(issue("SOP_STATUS_APPROVAL", "/approval", `${sop.status} SOP cannot carry approved records`));
    }
    return;
  }
  const authors = new Set(approval.authors || []);
  const records = approval.records || [];
  const sopDigest = canonicalSopDigest(sop);
  if (approval.status !== "approved" || records.length === 0) {
    issues.push(issue("SOP_APPROVAL_MISSING", "/approval", "Approved SOP requires digest-bound approval records"));
    return;
  }
  const covered = new Set();
  for (const [index, record] of records.entries()) {
    const pointer = `/approval/records/${index}`;
    if (authors.has(record.reviewer)) issues.push(issue("SOP_APPROVAL_AUTHOR", pointer, "SOP author cannot approve the same SOP"));
    if (!Number.isFinite(Date.parse(record.approvedAt || ""))) issues.push(issue("SOP_APPROVAL_RECORD", pointer, "Approval time is invalid"));
    if (record.sopVersion !== sop.sopVersion || record.sopDigest !== sopDigest || record.specificationVersion !== sop.specification?.version || record.specificationDigest !== sop.specification?.digest) {
      issues.push(issue("SOP_APPROVAL_BINDING", pointer, "Approval record is not bound to the current SOP and specification digest"));
    }
    covered.add(record.role);
  }
  for (const role of approval.requiredRoles || []) {
    if (!covered.has(role)) issues.push(issue("SOP_APPROVAL_ROLE", "/approval/records", `Missing required SOP approval role: ${role}`));
  }
}

export function validateSopReferences(sop, { sopPath, specificationsRoot, effectiveSchema, specificationDocument }) {
  const issues = [];
  const specPath = resolve(dirname(resolve(sopPath)), sop.specification?.path || "");
  let spec;

  if (!sop.specification?.path || !isInside(specificationsRoot, specPath) || !existsSync(specPath)) {
    issues.push(issue("SOP_SPEC_PATH", "/specification/path", "Specification path must resolve below the v2 candidate specification root"));
  } else spec = specificationDocument || readJson(specPath);

  if (spec) {
    if (sop.componentKey !== spec.component?.key) issues.push(issue("SOP_COMPONENT_KEY", "/componentKey", "SOP component key does not match specification"));
    if (sop.specification.version !== spec.specificationVersion) issues.push(issue("SOP_SPEC_VERSION", "/specification/version", "SOP specification version does not match"));

    const covered = new Set();
    const implemented = new Set();
    for (const [index, step] of (sop.steps || []).entries()) {
      for (const [field, pointers] of [["implements", step.implements], ["verifies", step.verifies]]) {
        for (const [pointerIndex, pointer] of (pointers || []).entries()) {
          const issuePointer = `/steps/${index}/${field}/${pointerIndex}`;
          if (typeof pointer !== "string" || !pointer.startsWith("/")) {
            issues.push(issue("SOP_POINTER_FORMAT", issuePointer, "Reference must be an absolute JSON Pointer"));
            continue;
          }
          if (!getPointer(spec, pointer).exists) {
            issues.push(issue("SOP_POINTER_MISSING", issuePointer, `Specification pointer does not exist: ${pointer}`));
            continue;
          }
          if (field === "implements") {
            const allowed = ["/api/", "/behavior/", "/view/", "/accessibility/", "/security/", "/compatibility/", "/risk/", "/quality/scaleFixtures", "/quality/performanceBudgets"];
            if (!allowed.some((prefix) => pointer.startsWith(prefix))) issues.push(issue("SOP_IMPLEMENT_PARTITION", issuePointer, `Pointer is not an implementable specification partition: ${pointer}`));
            else implemented.add(pointer);
          } else {
            if (!pointer.startsWith("/quality/oracles/") && !pointer.startsWith("/quality/visualOracles/")) issues.push(issue("SOP_VERIFY_PARTITION", issuePointer, `Verification must point to an oracle: ${pointer}`));
            else covered.add(pointer);
          }
        }
      }
    }
    for (const pointer of collectRequiredOracles(spec)) {
      if (!covered.has(pointer)) issues.push(issue("SOP_ORACLE_UNCOVERED", pointer, "Required oracle is not covered by an SOP step"));
    }
    for (const pointer of effectiveSchema?.["x-required-implementation-pointers"] || []) {
      if (!implemented.has(pointer)) issues.push(issue("SOP_IMPLEMENTATION_UNCOVERED", pointer, "Required implementation contract is not covered by an SOP step"));
    }
    scanDuplicatedAnswers(sop, spec, issues);
    validateApproval(sop, issues);

    const expectedDigest = canonicalDigest(spec);
    if (sop.specification.digest !== expectedDigest) {
      issues.push(issue("SOP_DIGEST_STALE", "/specification/digest", "Specification digest has changed"));
      if (sop.status === "Approved") issues.push(issue("SOP_APPROVED_STALE", "/status", "An approved SOP cannot remain approved after its specification changes"));
    }
  }

  const stale = issues.some((item) => item.code === "SOP_DIGEST_STALE");
  return {
    status: stale ? "Stale" : issues.length ? "Failed" : "Passed",
    issues: issues.sort((left, right) => left.code.localeCompare(right.code) || left.pointer.localeCompare(right.pointer)),
    componentKey: sop.componentKey,
    specificationDigest: spec ? canonicalDigest(spec) : null,
    requiredSemanticChecks: effectiveSchema?.["x-required-semantic-checks"] || [],
  };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  const [sopPath, specificationsRoot, effectiveSchemaPath] = process.argv.slice(2);
  if (!sopPath || !specificationsRoot || !effectiveSchemaPath) throw new Error("Usage: node validate-sop-references.mjs <sop> <specifications-root> <effective-schema>");
  const result = validateSopReferences(readJson(resolve(sopPath)), {
    sopPath: resolve(sopPath),
    specificationsRoot: resolve(specificationsRoot),
    effectiveSchema: readJson(resolve(effectiveSchemaPath)),
  });
  if (result.status !== "Passed") {
    console.error(JSON.stringify(result, null, 2));
    process.exitCode = 1;
  } else console.log(JSON.stringify(result, null, 2));
}
