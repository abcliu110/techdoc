package com.lowcode.metamodel.domain.service;

import com.lowcode.metamodel.domain.def.LicensePolicyDef;

/** License 降级策略评估器。 */
public class LicensePolicyEvaluator {

  public LicensePolicyDecision evaluate(LicensePolicyDef policy, LicenseRuntimeContext context) {
    if (!context.licensed()) {
      return readonly(LicenseDecisionStatus.UNLICENSED, policy);
    }
    if (context.expired()) {
      return readonly(LicenseDecisionStatus.EXPIRED, policy);
    }
    if (context.offlineFileCorrupted() && context.privateDeployment() && !context.internetReachable()) {
      return readonly(LicenseDecisionStatus.OFFLINE_FILE_CORRUPTED, policy);
    }
    if (context.degraded()) {
      return readonly(LicenseDecisionStatus.DEGRADED, policy);
    }
    return new LicensePolicyDecision(LicenseDecisionStatus.ACTIVE, false, true, true, true, true);
  }

  private static LicensePolicyDecision readonly(LicenseDecisionStatus status, LicensePolicyDef policy) {
    return new LicensePolicyDecision(status, true, policy.allowDataRead(), policy.allowAuditRead(), false, false);
  }
}
