package com.lowcode.app;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.app.api.AuthenticatedRuntimeContext;
import com.lowcode.app.api.AuthenticatedRuntimeContextResolver;
import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;

class AuthenticatedRuntimeContextResolverTest {

  private static final String SECRET = "test-gateway-secret";
  private static final Clock FIXED_CLOCK = Clock.fixed(Instant.parse("2026-07-07T00:00:00Z"), ZoneOffset.UTC);

  private final AuthenticatedRuntimeContextResolver resolver =
      new AuthenticatedRuntimeContextResolver(SECRET, FIXED_CLOCK, 300_000L);

  @Test
  void shouldResolveControlledHeadersIntoRuntimeContext() {
    MockHttpServletRequest request = new MockHttpServletRequest();
    request.addHeader("X-Tenant-Id", "3");
    request.addHeader("X-Workspace-Id", "7");
    request.addHeader("X-User-Lid", "user-1");
    request.addHeader("X-Role-Codes", "manager, auditor ,manager");
    request.addHeader("X-Trace-Id", "trace-1");
    sign(request);

    AuthenticatedRuntimeContext context = resolver.resolve(request, "sales", "order", "mh-1");

    assertThat(context.tenantId()).isEqualTo(3L);
    assertThat(context.workspaceId()).isEqualTo(7L);
    assertThat(context.userLid()).isEqualTo("user-1");
    assertThat(context.roleCodes()).containsExactlyInAnyOrder("manager", "auditor");
    assertThat(context.traceId()).isEqualTo("trace-1");
    assertThat(context.appCode()).isEqualTo("sales");
    assertThat(context.objectCode()).isEqualTo("order");
    assertThat(context.metaHash()).isEqualTo("mh-1");
  }

  @Test
  void shouldResolveEmptyRoleCodesAsEmptyPermissionSet() {
    MockHttpServletRequest request = new MockHttpServletRequest();
    request.addHeader("X-Tenant-Id", "3");
    request.addHeader("X-Workspace-Id", "7");
    request.addHeader("X-User-Lid", "user-1");
    request.addHeader("X-Role-Codes", " , ");
    sign(request);

    AuthenticatedRuntimeContext context = resolver.resolve(request, "sales", "order", "mh-1");

    assertThat(context.roleCodes()).isEmpty();
    assertThat(context.traceId()).isEqualTo("trace-http");
  }

  @Test
  void shouldFailFastWhenRequiredHeadersAreMissing() {
    MockHttpServletRequest request = new MockHttpServletRequest();
    sign(request);

    assertThatThrownBy(() -> resolver.resolve(request, "sales", "order", "mh-1"))
        .isInstanceOf(BizException.class)
        .satisfies(ex -> {
          BizException bizException = (BizException) ex;
          assertThat(bizException.errorCode()).isEqualTo(ErrorCode.TENANT_REQUIRED);
          assertThat(bizException.getMessage()).isEqualTo("租户不能为空");
        });

    request.addHeader("X-Tenant-Id", "3");
    sign(request);
    assertThatThrownBy(() -> resolver.resolve(request, "sales", "order", "mh-1"))
        .isInstanceOf(BizException.class)
        .satisfies(ex -> {
          BizException bizException = (BizException) ex;
          assertThat(bizException.errorCode()).isEqualTo(ErrorCode.PARAM_INVALID);
          assertThat(bizException.getMessage()).isEqualTo("工作区不能为空");
        });

    request.addHeader("X-Workspace-Id", "7");
    sign(request);
    assertThatThrownBy(() -> resolver.resolve(request, "sales", "order", "mh-1"))
        .isInstanceOf(BizException.class)
        .satisfies(ex -> {
          BizException bizException = (BizException) ex;
          assertThat(bizException.errorCode()).isEqualTo(ErrorCode.PARAM_INVALID);
          assertThat(bizException.getMessage()).isEqualTo("用户不能为空");
    });
  }

  @Test
  void shouldRejectUntrustedGatewayHeaders() {
    MockHttpServletRequest request = new MockHttpServletRequest();
    request.addHeader("X-Tenant-Id", "3");
    request.addHeader("X-Workspace-Id", "7");
    request.addHeader("X-User-Lid", "user-1");

    assertThatThrownBy(() -> resolver.resolve(request, "sales", "order", "mh-1"))
        .isInstanceOf(BizException.class)
        .satisfies(ex -> {
          BizException bizException = (BizException) ex;
          assertThat(bizException.errorCode()).isEqualTo(ErrorCode.PARAM_INVALID);
          assertThat(bizException.getMessage()).isEqualTo("网关签名无效");
        });

    request.addHeader("X-Gateway-Timestamp", String.valueOf(FIXED_CLOCK.millis()));
    request.addHeader("X-Gateway-Signature", "bad-secret");
    assertThatThrownBy(() -> resolver.resolve(request, "sales", "order", "mh-1"))
        .isInstanceOf(BizException.class)
        .satisfies(ex -> {
          BizException bizException = (BizException) ex;
          assertThat(bizException.errorCode()).isEqualTo(ErrorCode.PARAM_INVALID);
          assertThat(bizException.getMessage()).isEqualTo("网关签名无效");
        });
  }

  @Test
  void shouldRejectExpiredGatewaySignature() {
    MockHttpServletRequest request = new MockHttpServletRequest();
    request.setMethod("POST");
    request.setRequestURI("/api/data/sales/order/add");
    request.addHeader("X-Tenant-Id", "3");
    request.addHeader("X-Workspace-Id", "7");
    request.addHeader("X-User-Lid", "user-1");
    request.addHeader("X-Gateway-Timestamp", String.valueOf(FIXED_CLOCK.millis() - 300_001L));
    request.addHeader("X-Gateway-Signature", hmac(request));

    assertThatThrownBy(() -> resolver.resolve(request, "sales", "order", "mh-1"))
        .isInstanceOf(BizException.class)
        .satisfies(ex -> {
          BizException bizException = (BizException) ex;
          assertThat(bizException.errorCode()).isEqualTo(ErrorCode.PARAM_INVALID);
          assertThat(bizException.getMessage()).isEqualTo("网关签名无效");
        });
  }

  @Test
  void shouldRejectTamperedRoleHeaderAfterGatewaySignature() {
    MockHttpServletRequest request = new MockHttpServletRequest();
    request.setMethod("POST");
    request.setRequestURI("/api/data/sales/order/add");
    request.addHeader("X-Tenant-Id", "3");
    request.addHeader("X-Workspace-Id", "7");
    request.addHeader("X-User-Lid", "user-1");
    request.addHeader("X-Role-Codes", "auditor");
    sign(request);
    request.removeHeader("X-Role-Codes");
    request.addHeader("X-Role-Codes", "manager");

    assertThatThrownBy(() -> resolver.resolve(request, "sales", "order", "mh-1"))
        .isInstanceOf(BizException.class)
        .satisfies(ex -> {
          BizException bizException = (BizException) ex;
          assertThat(bizException.errorCode()).isEqualTo(ErrorCode.PARAM_INVALID);
          assertThat(bizException.getMessage()).isEqualTo("网关签名无效");
        });
  }

  private static void sign(MockHttpServletRequest request) {
    request.setMethod("POST");
    request.setRequestURI("/api/data/sales/order/add");
    request.removeHeader("X-Gateway-Timestamp");
    request.removeHeader("X-Gateway-Signature");
    request.addHeader("X-Gateway-Timestamp", String.valueOf(FIXED_CLOCK.millis()));
    request.addHeader("X-Gateway-Signature", hmac(request));
  }

  private static String hmac(MockHttpServletRequest request) {
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
      byte[] digest = mac.doFinal(canonicalPayload(request).getBytes(StandardCharsets.UTF_8));
      StringBuilder hex = new StringBuilder(digest.length * 2);
      for (byte value : digest) {
        hex.append(String.format("%02x", value));
      }
      return hex.toString();
    } catch (Exception ex) {
      throw new IllegalStateException(ex);
    }
  }

  private static String canonicalPayload(MockHttpServletRequest request) {
    return String.join("\n",
        request.getMethod(),
        request.getRequestURI(),
        header(request, "X-Gateway-Timestamp"),
        header(request, "X-Tenant-Id"),
        header(request, "X-Workspace-Id"),
        header(request, "X-User-Lid"),
        header(request, "X-Role-Codes"),
        "mh-1");
  }

  private static String header(MockHttpServletRequest request, String name) {
    String value = request.getHeader(name);
    return value == null ? "" : value.trim();
  }
}
