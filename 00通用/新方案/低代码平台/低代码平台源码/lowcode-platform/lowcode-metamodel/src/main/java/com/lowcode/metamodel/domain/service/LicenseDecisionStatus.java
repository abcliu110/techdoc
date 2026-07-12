package com.lowcode.metamodel.domain.service;

/** License 判定结果状态。 */
public enum LicenseDecisionStatus {
  ACTIVE,
  UNLICENSED,
  EXPIRED,
  DEGRADED,
  OFFLINE_FILE_CORRUPTED
}
