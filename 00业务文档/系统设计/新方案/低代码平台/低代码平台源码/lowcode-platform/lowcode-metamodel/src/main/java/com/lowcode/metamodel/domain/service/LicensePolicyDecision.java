package com.lowcode.metamodel.domain.service;

/** License 策略评估结果。 */
public record LicensePolicyDecision(
    LicenseDecisionStatus status,
    boolean degraded,
    boolean allowDataRead,
    boolean allowAuditRead,
    boolean allowWrite,
    boolean allowPackageInstall) {}
