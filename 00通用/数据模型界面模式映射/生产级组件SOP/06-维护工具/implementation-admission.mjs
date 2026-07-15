const allowedApprovalRoles = new Set([
  "component-maintainer",
  "ux-a11y-reviewer",
  "test-reviewer",
  "domain-security-reviewer",
]);

export function validApprovalRecord(record, spec) {
  return Boolean(
    record
    && allowedApprovalRoles.has(record.role)
    && typeof record.reviewer === "string"
    && record.reviewer.trim()
    && record.status === "approved"
    && typeof record.approvedAt === "string"
    && Number.isFinite(Date.parse(record.approvedAt))
    && record.specificationRevision === spec.specificationVersion
    && !spec.approval.authors.includes(record.reviewer),
  );
}

export function hasRequiredApprovals(spec) {
  if (!Array.isArray(spec.approval?.authors) || spec.approval.authors.length === 0) return false;
  if (!Array.isArray(spec.approval.requiredRoles) || spec.approval.requiredRoles.length === 0) return false;
  if (["R2", "R3"].includes(spec.risk?.level) && !spec.approval.requiredRoles.includes("component-maintainer")) return false;
  if (spec.risk?.level === "R3" && !spec.approval.requiredRoles.includes("domain-security-reviewer")) return false;
  if (spec.risk?.level === "R3" && !spec.approval.requiredRoles.some((role) => role === "test-reviewer" || role === "ux-a11y-reviewer")) return false;
  const approvedRoles = new Set(
    (spec.approval.records || []).filter((record) => validApprovalRecord(record, spec)).map((record) => record.role),
  );
  return spec.approval.records?.every((record) => validApprovalRecord(record, spec))
    && spec.approval.requiredRoles.every((role) => allowedApprovalRoles.has(role) && approvedRoles.has(role));
}

export function isImplementationAllowed(spec) {
  return spec.lifecycle === "ImplementationReady"
    && spec.publicApi?.status === "frozen"
    && spec.openDecisions?.length === 0
    && spec.approval?.status === "approved"
    && hasRequiredApprovals(spec);
}
