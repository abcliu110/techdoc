package com.lowcode.common.api;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.common.error.ErrorCode;
import org.junit.jupiter.api.Test;

class ResultTest {

  @Test
  void success_shouldCarryDataAndTraceId() {
    Result<String> result = Result.success("ok", "trace-1");

    assertThat(result.code()).isEqualTo(ErrorCode.SUCCESS.code());
    assertThat(result.message()).isEqualTo(ErrorCode.SUCCESS.message());
    assertThat(result.data()).isEqualTo("ok");
    assertThat(result.traceId()).isEqualTo("trace-1");
  }

  @Test
  void failure_shouldExposeStableErrorCode() {
    Result<Void> result = Result.failure(ErrorCode.PARAM_INVALID, "bad input", "trace-2");

    assertThat(result.code()).isEqualTo("LC-COMM-0400");
    assertThat(result.message()).isEqualTo("bad input");
    assertThat(result.data()).isNull();
    assertThat(result.traceId()).isEqualTo("trace-2");
  }
}
