package com.lowcode.common.tenant;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

class TenantContextTest {

  @AfterEach
  void tearDown() {
    TenantContext.clear();
  }

  @Test
  void requireTenantId_shouldFailFastWhenMissing() {
    assertThatThrownBy(TenantContext::requireTenantId)
        .isInstanceOf(BizException.class)
        .extracting("errorCode")
        .isEqualTo(ErrorCode.TENANT_REQUIRED);
  }

  @Test
  void requireTenantId_shouldReturnCurrentTenant() {
    TenantContext.setTenantId(1001L);

    assertThat(TenantContext.requireTenantId()).isEqualTo(1001L);
  }
}
