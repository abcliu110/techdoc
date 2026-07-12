package com.lowcode.common.error;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class BizExceptionTest {

  @Test
  void constructor_shouldPreserveErrorCodeAndMessage() {
    BizException exception = new BizException(ErrorCode.TENANT_REQUIRED, "tenant missing");

    assertThat(exception.errorCode()).isEqualTo(ErrorCode.TENANT_REQUIRED);
    assertThat(exception.getMessage()).isEqualTo("tenant missing");
  }
}
