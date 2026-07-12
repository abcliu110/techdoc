package com.lowcode.metamodel.domain.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.LicensePolicyDef;
import org.junit.jupiter.api.Test;

class LicensePolicyEvaluatorTest {

  private final LicensePolicyEvaluator evaluator = new LicensePolicyEvaluator();

  @Test
  void evaluate_未授权和过期场景_保持数据读取与审计查看可用() {
    LicensePolicyDef policy =
        new LicensePolicyDef("online", "read_only", true, true, false, true);

    LicensePolicyDecision unlicensed =
        evaluator.evaluate(
            policy,
            new LicenseRuntimeContext(false, false, false, false, true, false));
    LicensePolicyDecision expired =
        evaluator.evaluate(
            policy,
            new LicenseRuntimeContext(true, true, false, false, true, false));

    assertThat(unlicensed.status()).isEqualTo(LicenseDecisionStatus.UNLICENSED);
    assertThat(unlicensed.allowDataRead()).isTrue();
    assertThat(unlicensed.allowAuditRead()).isTrue();
    assertThat(unlicensed.allowWrite()).isFalse();

    assertThat(expired.status()).isEqualTo(LicenseDecisionStatus.EXPIRED);
    assertThat(expired.allowDataRead()).isTrue();
    assertThat(expired.allowAuditRead()).isTrue();
    assertThat(expired.allowWrite()).isFalse();
  }

  @Test
  void evaluate_离线文件损坏且私有化无外网_进入只读降级不破坏审计查看() {
    LicensePolicyDef policy =
        new LicensePolicyDef("offline", "read_only", true, true, true, true);

    LicensePolicyDecision decision =
        evaluator.evaluate(
            policy,
            new LicenseRuntimeContext(true, false, false, true, false, true));

    assertThat(decision.status()).isEqualTo(LicenseDecisionStatus.OFFLINE_FILE_CORRUPTED);
    assertThat(decision.degraded()).isTrue();
    assertThat(decision.allowDataRead()).isTrue();
    assertThat(decision.allowAuditRead()).isTrue();
    assertThat(decision.allowWrite()).isFalse();
  }

  @Test
  void evaluate_已降级场景_继续保留只读能力并禁止新增变更() {
    LicensePolicyDef policy =
        new LicensePolicyDef("hybrid", "deny_new", true, true, true, true);

    LicensePolicyDecision decision =
        evaluator.evaluate(
            policy,
            new LicenseRuntimeContext(true, false, true, false, true, false));

    assertThat(decision.status()).isEqualTo(LicenseDecisionStatus.DEGRADED);
    assertThat(decision.allowDataRead()).isTrue();
    assertThat(decision.allowAuditRead()).isTrue();
    assertThat(decision.allowWrite()).isFalse();
    assertThat(decision.allowPackageInstall()).isFalse();
  }
}
